#include <SDL2/SDL.h>
#include <unistd.h>

#include "threading.h"
#include "util.h"
#include "args.h"

typedef uint8_t u8;
typedef uint16_t u16;
typedef uint32_t u32, hword;
typedef uint64_t word;
#define RT 0777777
#define LT 0777777000000

int winsize = 1024;

void
err(char *fmt, ...)
{
	va_list ap;
	va_start(ap, fmt);
	fprintf(stderr, "error: ");
	vfprintf(stderr, fmt, ap);
	fprintf(stderr, "\n");
	va_end(ap);
	exit(1);
}


int sock;

/*
 * CRT simulation ported from https://www.masswerk.at/minskytron/
 */

typedef struct Color Color;
struct Color
{
	u8 r, g, b, a;
};

typedef struct Pixel Pixel;
struct Pixel
{
	u16 x, y;
	u8 l;
};

typedef struct CRT CRT;
struct CRT
{
	Pixel pxlist[1024*1024];
	int numPixels;
	int phos1List[1024*1024];
	int numPhos1;
	int phos2List[1024*1024];
	int numPhos2;
	int clearList[1024*1024];
	int numClearPixels;
	int tmpList[1024*1024];
	int numTmp;

	u8 pxvals[1024*1024];	// intensity
	u8 phos1vals[1024*1024];
	u8 phos2vals[1024*1024];

	u32 pixels[1024*1024];	// RGB values
};


static SDL_Window *window;
static SDL_Renderer *renderer;

static Lock crtlock;

static Color phos1 = { 0x3d, 0xaa, 0xf7, 0xff };
static Color phos1blur = { 0, 0x63, 0xeb, 0xff };
static Color phos2 = { 0x79, 0xcc, 0x3e, 0xff };
static Color phos2aged = { 0x7e, 0xba, 0x1e, 0xff };
#define RGBA(r, g, b, a) ((r)<<24 | (g)<<16 | (b)<<8 | (a))
#define RGB(r, g, b) RGBA(r, g, b, 255);
static u8 pxintensity[8];
static Color phos1ramp[256];
static Color phos2ramp[256];
static u32 bg = 0;

static float pixelSustainPercent = 0.935;
static int pixelSustainMin = 6;
static int pixelSustainMax = 144;
static float pixelSustainSensitivity = 1.715;
static float pixelSustainRangeOffset = 0.45;
static float pixelSustainFactor;
static float pixelSustainFactorMin = 0.8;
static float pixelSustainFactorMax = 1.0;

static int blurLevelsDefault = 4;
static float blurFactorSquare = 0.3;
static float blurFactorLinear = 0.024;
static float blurFactorDiagonal = 0.3;

static int phos2AlphaCorr = 25;
static int phos2MinVal;
static int pixelIntensityMax = 240;
static int pixelIntensityMin = 8;
static int pixelHaloMinIntensity = 28;
static int intensityRange;
static int intensityOffset;

static float sustainFuzzyness = 0.015;
static float sustainFactor;
static int sustainTransferCf;

float frand(void) { return (double)rand()/RAND_MAX; }

static void
crtinit(void)
{
	int i, j, ofs;
	Color col1, col2;
	float c;
	int psm;

	intensityRange = pixelIntensityMax - pixelIntensityMin;
	intensityOffset = pixelIntensityMin+(1.0-pixelSustainRangeOffset)*intensityRange;
	sustainTransferCf = intensityOffset * pixelSustainSensitivity;
	pixelSustainFactor = pixelSustainFactorMin +
		pixelSustainPercent*(pixelSustainFactorMax-pixelSustainFactorMin);
	sustainFactor = pixelSustainFactor;


	/* Intensities */
	for(i = 0; i < 8; i++)
		pxintensity[i] = pixelIntensityMin + i/7.0 * intensityRange;

	/* Phosphor 1 ramp */
	ofs = pxintensity[4]/4;
	for(i = 0; i < ofs; i++){
		phos1ramp[i] = phos1blur;
		phos1ramp[i].a = i < pixelHaloMinIntensity ?
			pixelHaloMinIntensity : i;
	}
	for(j = 0; i < 256; i++, j++){
		c = (float)j/(255-ofs);
		c *= c;
		phos1ramp[i].r = phos1blur.r*(1.0-c) + phos1.r*c;
		phos1ramp[i].g = phos1blur.g*(1.0-c) + phos1.g*c;
		phos1ramp[i].b = phos1blur.b*(1.0-c) + phos1.b*c;
		phos1ramp[i].a = i < pixelHaloMinIntensity ?
			pixelHaloMinIntensity : i;
	}

	/* Phosphor 2 ramp */
	col1 = phos2;
	col2 = phos2aged;

	c = (255-phos2AlphaCorr)/255.0;
	col1.r *= c; col1.g *= c; col1.b *= c;
	c = (255-phos2AlphaCorr*0.25)/255.0;
	col2.r *= c; col2.g *= c; col2.b *= c;
	psm = pixelSustainMax + phos2AlphaCorr;

	phos2MinVal = 0;
	for(i = 0; i < 256; i++){
		c = i/255.0;
		phos2ramp[i].r = col1.r*c + col2.r*(1.0-c);
		phos2ramp[i].g = col1.g*c + col2.g*(1.0-c);
		phos2ramp[i].b = col1.b*c + col2.b*(1.0-c);
		phos2ramp[i].a = psm*(c + -0.5*(cos(M_PI*c) - 1))/2.0;
		if(phos2ramp[i].a < 3)
			phos2MinVal = i;
	}
}

#define AGETHRESH 10
u32 age;

static void*
pixelthread(void *arg)
{
	u32 cmd;
	int x;
	int y;
	int intensity;
	int i, v;
	Pixel *px;
	CRT *crt = arg;

	while(readn(sock, &cmd, 4) == 0){
		/* Queue pixel to display */
		x = cmd&01777;
		y = cmd>>10 & 01777;
//printf("%o %o\n", x, y);
		y = 1023-y;
		intensity = cmd>>20 & 7;

		intensity = pxintensity[intensity];
		i = 1024*y + x;
		v = crt->pxvals[i];

		lock(&crtlock);
		if(cmd & 1<<23)
			age++;

		if(intensity){
			if(v == 0){
				/* Add new pixel */
				px = &crt->pxlist[crt->numPixels++];
				px->x = x;
				px->y = y;
				px->l = blurLevelsDefault;
				crt->pxvals[i] = intensity;
			}else if(intensity > v)
				/* Intensify old pixel */
				crt->pxvals[i] = intensity;
		}
		unlock(&crtlock);
	}
	exit(1);
}


/* Intensify phos1 value */
static void
renderpixel(CRT *crt, int x, int y, int a, int level)
{
	int p, v, b;
	float f;

	p = y*1024 + x;
	v = crt->phos1vals[p];
	if(v >= 255) return;
	if(v == 0){
//		printf("adding phos1 %d\n", p);
		crt->phos1List[crt->numPhos1++] = p;
	}
	v += a;
	crt->phos1vals[p] = v > 255 ? 255 : v;

	if(--level){
		f = a/255.0;
		b = f*f*255*blurFactorSquare + a*blurFactorLinear;
		if(b > 0){
			if(x < 1023) renderpixel(crt, x+1, y, b, level);
			if(y < 1023) renderpixel(crt, x, y+1, b, level);
			if(x > 0) renderpixel(crt, x-1, y, b, level);
			if(y > 0) renderpixel(crt, x, y-1, b, level);
			b *= blurFactorDiagonal;
			if(b > 0){
				if(y > 0){
					if(x < 1023)
						renderpixel(crt, x+1, y-1, b, level);
					if(x > 0)
						renderpixel(crt, x-1, y-1, b, level);
				}
				if(y < 1023){
					if(x < 1023)
						renderpixel(crt, x+1, y+1, b, level);
					if(x > 0)
						renderpixel(crt, x-1, y+1, b, level);
				}
			}
		}
	}
}

/* Intensify all phos1 values from queued pixels */
static void
renderpixels(CRT *crt)
{
	int i, p;
	Pixel *px;

	lock(&crtlock);
	px = crt->pxlist;
	for(i = 0; i < crt->numPixels; i++){
		p = 1024*px->y + px->x;
		renderpixel(crt, px->x, px->y, crt->pxvals[p], px->l);
		crt->pxvals[p] = 0;
		px++;
	}
	crt->numPixels = 0;
	unlock(&crtlock);
}

static void
drawtoscreen(CRT *crt, int i, int phos2, int phos1)
{
	float c;
	int r, g, b, a;
	Color p1col = phos1ramp[phos1];
	Color p2col = phos2ramp[phos2];

	if(phos2 == 0 || phos1 == 255){
		/* only Phosphor 1 */
		p1col.a = (phos2 == 0 && phos1 < pixelHaloMinIntensity) ?
			pixelHaloMinIntensity : phos1;
		crt->pixels[i] = RGBA(p1col.r, p1col.g, p1col.b, p1col.a);
	}else{
		/* both phosphors */
		c = p2col.a/255.0 * (1.0 - phos1/255.0);
		r = (p1col.r + p2col.r*c + p1col.r + p2col.r)/2.0;
		g = (p1col.g + p2col.g*c + p1col.g + p2col.g)/2.0;
		b = (p1col.b + p2col.b*c + p1col.b + p2col.b)/2.0;
		a = phos1 + p2col.a;
		if(r > 255) r = 255;
		if(g > 255) g = 255;
		if(b > 255) b = 255;
		if(a > 255) a = 255;
		crt->pixels[i] = RGBA(r, g, b, a);
	}
}

static void
render(CRT *crt)
{
	int i, p, v, u;
	float f;
	Color c;

	renderpixels(crt);

	/* clear faded phos1 pixels */
	for(i = 0; i < crt->numClearPixels; i++)
		crt->pixels[crt->clearList[i]] = bg;
	crt->numClearPixels = 0;

	/* process phosphor 2 */
	for(i = 0; i < crt->numPhos2; i++){
		p = crt->phos2List[i];
		c = phos2ramp[crt->phos2vals[p]];
		crt->pixels[p] = RGBA(c.r, c.g, c.b, c.a);
	}

	/* process phosphor 1 */
	for(i = 0; i < crt->numPhos1; i++){
		p = crt->phos1List[i];
		v = crt->phos1vals[p];
		if(v >= pixelSustainMin){
			/* Phos1 bright enough, leave a Phos2 trace */
			if(crt->phos2vals[p] == 0)
				crt->phos2List[crt->numPhos2++] = p;
			f = v >= intensityOffset ?
				1.0 :
				1.0 - (float)(intensityOffset-v)/sustainTransferCf;
			u = f*255;
			if(crt->phos2vals[p] < u)
				crt->phos2vals[p] = u;
		}else if(crt->phos2vals[p] == 0)
			/* Not bright enough,
			 * clear pixel if phos2 wasn't drawn */
			crt->clearList[crt->numClearPixels++] = p;
		/* Apply pixel with phos1 and phos2 values */
		drawtoscreen(crt, p, crt->phos2vals[p], v);
		crt->phos1vals[p] = 0;
	}
	crt->numPhos1 = 0;

	/* fade phosphor 2 */
	crt->numTmp = 0;
	for(i = 0; i < crt->numPhos2; i++){
		p = crt->phos2List[i];
		v = crt->phos2vals[p];
		v *= sustainFactor*(1.0-(frand()-0.5)*sustainFuzzyness);
		if(v >= phos2MinVal){
			crt->phos2vals[p] = v;
			crt->tmpList[crt->numTmp++] = p;
		}else{
			crt->phos2vals[p] = 0;
			crt->pixels[p] = bg;
		}
	}
	memcpy(crt->phos2List, crt->tmpList, crt->numTmp*sizeof(int));
	crt->numPhos2 = crt->numTmp;
}

/* Controllers */

#define NUMJOYS 4

//u32 joys[NUMJOYS];

typedef struct Joy Joy;
struct Joy
{
	int i;
	u32 b;
	u32 (*map)(int btn);
} joys[NUMJOYS];

void
updatejoy(Joy *j)
{
	u32 joy;
	joy = j->b | j->i<<24;
	// TODO: this causes flickering for some reason
	write(sock, &joy, 4);
//	printf("%d %X\n", j->i, joy);
}

#define KEY1(m) joys[0].b |= (m); break
#define KEY2(m) joys[1].b |= (m); break

u32 modes[2] = { 0, SDL_WINDOW_FULLSCREEN_DESKTOP };
int fullscreen;

SDL_Rect texrect;

void
resize(void)
{
	int w, h;
	SDL_GetWindowSize(window, &w, &h);
	printf("resize %d %d\n", w, h);
	texrect.x = (w-1024)/2;
	texrect.y = (h-1024)/2;
}

void
keydn(int scancode)
{
	int i;
	u32 ojoys[NUMJOYS];

	for(i = 0; i < NUMJOYS; i++)
		ojoys[i] = joys[i].b;
	switch(scancode){
	case SDL_SCANCODE_ESCAPE:
		exit(0);
		break;

	case SDL_SCANCODE_E: KEY1(04);
	case SDL_SCANCODE_X: KEY1(010);
	case SDL_SCANCODE_C: KEY1(020000);
	case SDL_SCANCODE_A: KEY1(020);
	case SDL_SCANCODE_D: KEY1(040);
	case SDL_SCANCODE_S: KEY1(0100);
	case SDL_SCANCODE_W: KEY1(0200);

	case SDL_SCANCODE_U: KEY2(04);
	case SDL_SCANCODE_N: KEY2(010);
	case SDL_SCANCODE_M: KEY2(020000);
	case SDL_SCANCODE_J: KEY2(020);
	case SDL_SCANCODE_L: KEY2(040);
	case SDL_SCANCODE_K: KEY2(0100);
	case SDL_SCANCODE_I: KEY2(0200);

	case SDL_SCANCODE_F:
		fullscreen = !fullscreen;
		SDL_SetWindowFullscreen(window, modes[fullscreen]);
		resize();
		break;
	}
	for(i = 0; i < NUMJOYS; i++)
		if(joys[i].b != ojoys[i])
			updatejoy(&joys[i]);
}

#undef KEY1
#undef KEY2
#define KEY1(m) joys[0].b &= ~(m); break;
#define KEY2(m) joys[1].b &= ~(m); break;

void
keyup(int scancode)
{
	int i;
	u32 ojoys[NUMJOYS];

	for(i = 0; i < NUMJOYS; i++)
		ojoys[i] = joys[i].b;
	switch(scancode){
	case SDL_SCANCODE_E: KEY1(04);
	case SDL_SCANCODE_X: KEY1(010);
	case SDL_SCANCODE_C: KEY1(020000);
	case SDL_SCANCODE_A: KEY1(020);
	case SDL_SCANCODE_D: KEY1(040);
	case SDL_SCANCODE_S: KEY1(0100);
	case SDL_SCANCODE_W: KEY1(0200);

	case SDL_SCANCODE_U: KEY2(04);
	case SDL_SCANCODE_N: KEY2(010);
	case SDL_SCANCODE_M: KEY2(020000);
	case SDL_SCANCODE_J: KEY2(020);
	case SDL_SCANCODE_L: KEY2(040);
	case SDL_SCANCODE_K: KEY2(0100);
	case SDL_SCANCODE_I: KEY2(0200);
	}
	for(i = 0; i < NUMJOYS; i++)
		if(joys[i].b != ojoys[i])
			updatejoy(&joys[i]);
}

u32
btnmap_ds2(int btn)
{
	switch(btn){
	case 2: return 020000;	/* cross - beam */
	case 1: return 010;	/* circle - torpedo */
	case 0: return 0100000;	/* triangle - destruct */
	case 3: return 4;	/* square - hyperspace */
	}
	return 0;
}

u32
btnmap_ds3(int btn)
{
	switch(btn){
	case 0: return 020000;	/* cross - beam */
	case 1: return 010;	/* circle - torpedo */
	case 2: return 0100000;	/* triangle - destruct */
	case 3: return 4;	/* square - hyperspace */

	case 13: return 0200;	/* up */
	case 14: return 0100;	/* down */
	case 15: return 020;	/* left */
	case 16: return 040;	/* right */
	}
	return 0;
}

void
joyhat(SDL_JoyHatEvent *he)
{
//	printf("%d %d %d\n", he->which, he->hat, he->value);
	u32 i, b;
	i = he->which;
	if(i >= NUMJOYS)
		return;

	b = 0;
	switch(he->value){
	case SDL_HAT_UP:	b = 0200; break;
	case SDL_HAT_RIGHTUP:	b = 0240; break;
	case SDL_HAT_RIGHT:	b = 0040; break;
	case SDL_HAT_RIGHTDOWN:	b = 0140; break;
	case SDL_HAT_DOWN:	b = 0100; break;
	case SDL_HAT_LEFTDOWN:	b = 0120; break;
	case SDL_HAT_LEFT:	b = 0020; break;
	case SDL_HAT_LEFTUP:	b = 0220; break;
	}

	joys[i].b &= ~0360;
	joys[i].b |= b;
	updatejoy(&joys[i]);
}

void
joybtn(SDL_JoyButtonEvent *be)
{
	u32 i, b;
	i = be->which;
	if(i >= NUMJOYS)
		return;

	b = joys[i].map(be->button);
	if(be->state){
		joys[i].b |= b;
		updatejoy(&joys[i]);
	}else{
		joys[i].b &= ~b;
		updatejoy(&joys[i]);
	}

//	printf("%d %d %d. %o\n", be->which, be->button, be->state, joys[i].b);
}

void
joyinit(void)
{
	int i, n;
	SDL_Joystick *j;

	SDL_JoystickEventState(SDL_ENABLE);

	for(i = 0; i < NUMJOYS; i++){
		joys[i].i = i;
		joys[i].map = btnmap_ds3;
	}

	n = SDL_NumJoysticks();
	for(i = 0; i < n && i < NUMJOYS; i++){
		j = SDL_JoystickOpen(i);
		if(j == nil)
			continue;
		if(strcmp(SDL_JoystickNameForIndex(i), "Twin USB Joystick") == 0)
			joys[i].map = btnmap_ds2;
		printf("joy %d: %s\n", i, SDL_JoystickNameForIndex(i));
	}
}

int penstate;

void
mouse(int button, int state, int x, int y)
{
	u32 pen = 0x80000000;
	pen |= x;
	pen |= y<<10;
	if(state) pen |= 1<<20;
	if(state || penstate != !!state)
		write(sock, &pen, 4);
	penstate = !!state;
//	printf("%d %d %d %d\n", button, state, x, y);
}

void
winev(SDL_WindowEvent *we)
{
	switch(we->event){
	case SDL_WINDOWEVENT_RESIZED:
//		texrect.x = (we->data1-winsize)/2;
//		texrect.y = (we->data2-winsize)/2;
		resize();
	//	printf("res %d %d\n", we->data1, we->data2);
		break;
	}
}

static void*
renderthread(void *arg)
{
	CRT *crt;
	SDL_Event ev;
	SDL_MouseButtonEvent *mbev;
	SDL_MouseMotionEvent *mmev;
	SDL_Texture *tex;

	crt = arg;

	crtinit();

	SDL_Init(SDL_INIT_EVERYTHING);

	SDL_SetHint(SDL_HINT_JOYSTICK_ALLOW_BACKGROUND_EVENTS,"1");

	joyinit();

	if(SDL_CreateWindowAndRenderer(winsize, winsize, 0, &window, &renderer) < 0)
		err("SDL_CreateWindowAndRenderer() failed: %s\n", SDL_GetError());
	tex = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_RGBA8888,
		SDL_TEXTUREACCESS_STREAMING, 1024, 1024);
	SDL_SetTextureBlendMode(tex, SDL_BLENDMODE_BLEND);
	texrect.x = 0;
	texrect.y = 0;
	texrect.w = winsize;
	texrect.h = winsize;

	SDL_ShowCursor(SDL_DISABLE);

	for(;;){
		while(SDL_PollEvent(&ev))
			switch(ev.type){
			case SDL_WINDOWEVENT:
				winev(&ev.window);
				break;

			case SDL_KEYDOWN:
				keydn(ev.key.keysym.scancode);
//				if(ev.key.keysym.scancode == SDL_SCANCODE_Q)
//					exit(0);
				break;
			case SDL_KEYUP:
				keyup(ev.key.keysym.scancode);
				break;

			case SDL_JOYBUTTONDOWN:
			case SDL_JOYBUTTONUP:
				joybtn(&ev.jbutton);
				break;
			case SDL_JOYHATMOTION:
				joyhat(&ev.jhat);
				break;
			case SDL_JOYDEVICEADDED:
				// ev.jdevice SDL_JoyDeviceEvent
				break;
			case SDL_JOYDEVICEREMOVED:
				break;

			case SDL_MOUSEMOTION:
				mmev = (SDL_MouseMotionEvent*)&ev;
				mouse(0, mmev->state, mmev->x, mmev->y);
				break;
			case SDL_MOUSEBUTTONDOWN:
			case SDL_MOUSEBUTTONUP:
				mbev = (SDL_MouseButtonEvent*)&ev;
				mouse(mbev->button, mbev->state, mbev->x, mbev->y);
				break;
			}
		SDL_SetRenderDrawColor(renderer, 0x00, 0x00, 0x00, 0x00);
		SDL_RenderClear(renderer);

#ifdef AGE
		if(age >= AGETHRESH){
			lock(&crtlock);
			age -= AGETHRESH;
			unlock(&crtlock);
			render(crt);
			SDL_UpdateTexture(tex, nil, crt->pixels, 1024*sizeof(u32));
		}
#else
		render(crt);
		SDL_UpdateTexture(tex, nil, crt->pixels, 1024*sizeof(u32));
		SDL_Delay(30);
#endif

		SDL_RenderCopy(renderer, tex, nil, &texrect);
	//	SDL_RenderCopy(renderer, tex, nil, nil);

		SDL_RenderPresent(renderer);
	}
	return nil;
}

void
startcrt(int fd, void *arg)
{
	static CRT CRT_;

	sock = fd;
	threadcreate(pixelthread, &CRT_);
	threadcreate(renderthread, &CRT_);
for(;;) sleep(1);
	exit(0);
}

char *argv0;

void
usage(void)
{
	fprintf(stderr, "usage: %s [-p port] [-s winsize]\n", argv0);
	exit(1);
}

int
threadmain(int argc, char *argv[])
{
	int port = 3400;
	ARGBEGIN{
	case 'p':
		port = atoi(EARGF(usage()));
		break;
	case 's':
		winsize = atoi(EARGF(usage()));
		break;
	}ARGEND;

	serve(port, startcrt, nil);
	return 0;
}
