#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <assert.h>
#include <fcntl.h>
#include <unistd.h>
#include <stropts.h>
#include <sys/mman.h>
#include <linux/i2c-dev.h>

#include "font.inc"

typedef uint8_t u8;
typedef uint32_t u32;
typedef uint64_t u64;

#define nil NULL

// from FE6
#define H2F_BASE (0xC0000000)

#define PERIPH_BASE (0xFC000000)
#define PERIPH_SPAN (0x04000000)
#define PERIPH_MASK (PERIPH_SPAN - 1)

#define LWH2F_BASE (0xFF200000)

/* Memory mapped PDP-6 interface */
enum
{
	/* The more important keys, switches and lights */
	REG6_CTL1_DN = 0,
	REG6_CTL1_UP = 1,
	 MM6_START	= 1,
	 MM6_READIN	= 2,
	 MM6_INSTCONT	= 4,
	 MM6_MEMCONT	= 010,
	 MM6_INSTSTOP	= 020,
	 MM6_MEMSTOP	= 040,
	  MM6_STOP = MM6_INSTSTOP|MM6_MEMSTOP,
	 MM6_RESET	= 0100,
	 MM6_EXEC	= 0200,
	 MM6_ADRSTOP	= 0400,
	 /* lights - read only */
	 MM6_RUN	= 01000,
	 MM6_MCSTOP	= 02000,
	 MM6_PWR	= 04000,

	/* Less important keys and switches */
	REG6_CTL2_DN = 2,
	REG6_CTL2_UP = 3,
	 MM6_THISDEP	= 1,
	 MM6_NEXTDEP	= 2,
	 MM6_THISEX	= 4,
	 MM6_NEXTEX	= 010,
	 MM6_READEROFF	= 020,
	 MM6_READERON	= 040,
	 MM6_FEEDPUNCH	= 0100,
	 MM6_FEEDREAD	= 0200,
	 MM6_REPEAT	= 0400,
	 MM6_MEMDIS	= 01000,

	/* Maintenance switches */
	REG6_MAINT_DN = 4,
	REG6_MAINT_UP = 5,

	/* switches and knobs */
	REG6_DSLT = 6,
	REG6_DSRT = 7,
	REG6_MAS = 010,
	REG6_REPEAT = 011,

	/* lights */
	REG6_IR = 012,
	REG6_MILT = 013,
	REG6_MIRT = 014,
	REG6_PC = 015,
	REG6_MA = 016,
	REG6_PI = 017,

	REG6_MBLT = 020,
	REG6_MBRT = 021,
	REG6_ARLT = 022,
	REG6_ARRT = 023,
	REG6_MQLT = 024,
	REG6_MQRT = 025,
	REG6_FF1 = 026,
	REG6_FF2 = 027,
	REG6_FF3 = 030,
	REG6_FF4 = 031,
	REG6_MMU = 032,

	REG6_TTY = 033,
	REG6_PTP = 034,
	REG6_PTR = 035,
	REG6_PTR_LT = 036,
	REG6_PTR_RT = 037,

	REG6_DIS1 = 040,
	REG6_DIS2 = 041,
	REG6_DIS3 = 042,
	REG6_DIS_STAT = 043,
	REG6_DIS_IBLT = 044,
	REG6_DIS_IBRT = 045,
};

static u64 *h2f_base;
static u32 *virtual_base;
static u32 *getLWH2Faddr(u32 offset)
{
	return (u32*)((u32)virtual_base - PERIPH_BASE + (LWH2F_BASE+offset));
}
static u64 *getH2Faddr(u32 offset)
{
	return (u64*)((u32)h2f_base + offset);
}

static int memfd;
static volatile u32 *h2f_cmemif;
static volatile u32 *h2f_fmemif;
static volatile u32 *h2f_apr;
static volatile u32 *h2f_lw_sw_addr;

int fd;

u8 bitfont[5 * 256];
u8 charbuf[8][21];

enum {
	WIDTH = 128,
	HEIGHT = 64,
	PAGES = HEIGHT/8
};

u8 buffer[WIDTH*PAGES];

enum {
	SSD1306_I2C_ADDRESS = 0x3C,
	SSD1306_SETCONTRAST = 0x81,
	SSD1306_DISPLAYALLON_RESUME = 0xA4,
	SSD1306_DISPLAYALLON = 0xA5,
	SSD1306_NORMALDISPLAY = 0xA6,
	SSD1306_INVERTDISPLAY = 0xA7,
	SSD1306_DISPLAYOFF = 0xAE,
	SSD1306_DISPLAYON = 0xAF,
	SSD1306_SETDISPLAYOFFSET = 0xD3,
	SSD1306_SETCOMPINS = 0xDA,
	SSD1306_SETVCOMDETECT = 0xDB,
	SSD1306_SETDISPLAYCLOCKDIV = 0xD5,
	SSD1306_SETPRECHARGE = 0xD9,
	SSD1306_SETMULTIPLEX = 0xA8,
	SSD1306_SETLOWCOLUMN = 0x00,
	SSD1306_SETHIGHCOLUMN = 0x10,
	SSD1306_SETSTARTLINE = 0x40,
	SSD1306_MEMORYMODE = 0x20,
	SSD1306_COLUMNADDR = 0x21,
	SSD1306_PAGEADDR = 0x22,
	SSD1306_COMSCANINC = 0xC0,
	SSD1306_COMSCANDEC = 0xC8,
	SSD1306_SEGREMAP = 0xA0,
	SSD1306_CHARGEPUMP = 0x8D,
	SSD1306_EXTERNALVCC = 0x1,
	SSD1306_SWITCHCAPVCC = 0x2
};

enum {
	SSD1306_ACTIVATE_SCROLL = 0x2F,
	SSD1306_DEACTIVATE_SCROLL = 0x2E,
	SSD1306_SET_VERTICAL_SCROLL_AREA = 0xA3,
	SSD1306_RIGHT_HORIZONTAL_SCROLL = 0x26,
	SSD1306_LEFT_HORIZONTAL_SCROLL = 0x27,
	SSD1306_VERTICAL_AND_RIGHT_HORIZONTAL_SCROLL = 0x29,
	SSD1306_VERTICAL_AND_LEFT_HORIZONTAL_SCROLL = 0x2A
};

void
cmd(u8 c)
{
	u8 buf[2];
	buf[0] = 0;
	buf[1] = c;
        write(fd, buf, 2);
}

void
initdisp(void)
{
	cmd(SSD1306_DISPLAYOFF);                    // 0xAE
	cmd(SSD1306_SETDISPLAYCLOCKDIV);            // 0xD5
	cmd(0x80);                                  // the suggested ratio 0x80
	cmd(SSD1306_SETMULTIPLEX);                  // 0xA8
	cmd(0x3F);
	cmd(SSD1306_SETDISPLAYOFFSET);              // 0xD3
	cmd(0x0);                                   // no offset
	cmd(SSD1306_SETSTARTLINE | 0x0);            // line #0
	cmd(SSD1306_CHARGEPUMP);                    // 0x8D
//	if self._vccstate == SSD1306_EXTERNALVCC:
//		cmd(0x10);
//	else:
		cmd(0x14);
	cmd(SSD1306_MEMORYMODE);                    // 0x20
	cmd(0x00);                                  // 0x0 act like ks0108
	cmd(SSD1306_SEGREMAP | 0x1);
	cmd(SSD1306_COMSCANDEC);
	cmd(SSD1306_SETCOMPINS);                    // 0xDA
	cmd(0x12);
	cmd(SSD1306_SETCONTRAST);                   // 0x81
//	if self._vccstate == SSD1306_EXTERNALVCC:
//		cmd(0x9F);
//	else:
		cmd(0xCF);
	cmd(SSD1306_SETPRECHARGE);                  // 0xd9
//	if self._vccstate == SSD1306_EXTERNALVCC:
//		cmd(0x22);
//	else:
		cmd(0xF1);
	cmd(SSD1306_SETVCOMDETECT);                 // 0xDB
	cmd(0x40);
	cmd(SSD1306_DISPLAYALLON_RESUME);           // 0xA4
	cmd(SSD1306_NORMALDISPLAY);                 // 0xA6
}

void
display(void)
{
	int i;
	u8 buf[17];

	cmd(SSD1306_COLUMNADDR);
	cmd(0);              // Column start address. (0 = reset)
	cmd(WIDTH-1);   // Column end address.
	cmd(SSD1306_PAGEADDR);
	cmd(0);              // Page start address. (0 = reset)
	cmd(PAGES-1);  // Page end address.

	for(i = 0; i < WIDTH*PAGES; i += 16){
		buf[0] = 0x40;
		memcpy(buf+1, buffer+i, 16);
		write(fd, buf, 17);
	}
}

#include "img_pdp6.inc"

void
imgtobuf(int a)
{
	int i, j;
	int w, h;
	u8 *px;

	w = pdp6_img.width;
	h = pdp6_img.height;
	assert(w == 128);
	assert(h == 64);
	assert(pdp6_img.bytes_per_pixel == 4);

	for(i = 0; i < WIDTH*PAGES; i++)
		buffer[i] = 0x00;

	px = pdp6_img.pixel_data;
	for(j = 0; j < h; j++)
		for(i = 0; i < w; i++){
//			if(px[(j*h + i)*4] == 0)
			if(!!px[0] == a)
				buffer[(j/8)*w + i] |= 1<<(j%8);
			px += 4;
		}
}

void
drawchar(int x, int y, u8 c)
{
	int i;

	for(i = 0; i < 5; i++)
		buffer[y*128 + x*6 + i] = bitfont[c*5 + i];
}

void
wcharbuf(void)
{
	int i, j;
	for(i = 0; i < 8; i++)
		for(j = 0; j < 21; j++)
			drawchar(j, i, charbuf[i][j]);
}

void
initfont(void)
{
	int i, j, k;
	int f;

	for(i = 0; i < 0140; i++)
		for(j = 0; j < 7; j++)
			for(k = 0; k < 5; k++)
				if(font[i][j*5 + k] == '*')
					bitfont[i*5 + k] |= 1<<j;
}

void
clearscreen(void)
{
	memset(charbuf, ' ', sizeof(charbuf));
	memset(buffer, 0, sizeof(buffer));
}

void
screen0(void)
{
	u32 ir = h2f_apr[REG6_IR];
	u32 pc = h2f_apr[REG6_PC];
	u32 ma = h2f_apr[REG6_MA];
	u32 pi = h2f_apr[REG6_PI];
	u32 pih = pi>>15 & 0177;
	u32 pir = pi>>8 & 0177;
	u32 pio = pi>>1 & 0177;
	u64 mi = (u64)h2f_apr[REG6_MILT]<<18 | h2f_apr[REG6_MIRT];
	u64 ds = (u64)h2f_apr[REG6_DSLT]<<18 | h2f_apr[REG6_DSRT];
	u32 mas = h2f_apr[REG6_MAS];
	u32 ctl = h2f_apr[REG6_CTL1_DN];
	sprintf(charbuf[0], "IR %06o", ir);
	sprintf(charbuf[1], "MI %012llo", mi);
	sprintf(charbuf[2], "PC %06o MA %06o", pc, ma);
	sprintf(charbuf[3], "PI H %03o R %03o O %03o", pih, pir, pio);
	sprintf(charbuf[4], "%s  %s  %s",
		(ctl&MM6_RUN) ? "RUN" : "   ",
		(pi&1) ? "PI ON" : "     ",
		(ctl&MM6_MCSTOP) ? "STOP" : "    ");
	sprintf(charbuf[5], "AS %06o", mas);
	sprintf(charbuf[6], "DS %012llo", ds);
}

void
screen1(void)
{
	u64 mb = (u64)h2f_apr[REG6_MBLT]<<18 | h2f_apr[REG6_MBRT];
	u64 ar = (u64)h2f_apr[REG6_ARLT]<<18 | h2f_apr[REG6_ARRT];
	u64 mq = (u64)h2f_apr[REG6_MQLT]<<18 | h2f_apr[REG6_MQRT];
	u32 ff1 = h2f_apr[REG6_FF1];
	u32 ff2 = h2f_apr[REG6_FF2];
	u32 ff3 = h2f_apr[REG6_FF3];
	u32 ff4 = h2f_apr[REG6_FF4];
	sprintf(charbuf[0], "MB %012llo", mb);
	sprintf(charbuf[1], "AR %012llo", ar);
	sprintf(charbuf[2], "MQ %012llo", mq);
	sprintf(charbuf[3], "FE %03o SC %03o",
		ff3>>16 & 0377 | (ff3&1)<<8,
		ff3>>8 & 0377 | (ff3&2)<<7);
		
}

void
screen2(void)
{
	int a;
	u64 w;
	for(a = 0; a < 8; a++){
		h2f_fmemif[0] = a;
		w = h2f_fmemif[2] & 0777777;
		w <<= 18;
		w |= h2f_fmemif[1] & 0777777;
		sprintf(charbuf[a], "%02o %012llo", a, w);
	}
}

void
screen3(void)
{
	int a;
	u64 w;
	for(a = 8; a < 16; a++){
		h2f_fmemif[0] = a;
		w = h2f_fmemif[2] & 0777777;
		w <<= 18;
		w |= h2f_fmemif[1] & 0777777;
		sprintf(charbuf[a-8], "%02o %012llo", a, w);
	}
}

void
screen4(void)
{
	u32 tty = h2f_apr[REG6_TTY];
	u32 ptr = h2f_apr[REG6_PTR];
	u64 ptrb = (u64)h2f_apr[REG6_PTR_LT]<<18 | h2f_apr[REG6_PTR_RT];
	u32 ptp = h2f_apr[REG6_PTP];
	u32 dis = h2f_apr[REG6_DIS_STAT];
	u64 disb = (u64)h2f_apr[REG6_DIS_IBLT]<<18 | h2f_apr[REG6_DIS_IBRT];
	// TTY IB IF OB OF X XXX
	sprintf(charbuf[0], "TTY %s %s %s %s %o %03o",
		(tty & 0100) ? "IB" : "  ", 
		(tty & 040) ? "IF" : "  ", 
		(tty & 020) ? "OB" : "  ", 
		(tty & 010) ? "OF" : "  ", 
		tty & 7,
		tty>>9 & 0377);
	// PTR M B  BSY DN X
	sprintf(charbuf[1], "PTR %s %s  %s %s %o",
		(ptr & 0100) ? "M" : " ",
		(ptr & 040) ? "B" : " ",
		(ptr & 020) ? "BSY" : "   ",
		(ptr & 010) ? "DN" : "  ",
		ptr & 7);
	sprintf(charbuf[2], "    %012llo", ptrb);
	// PTP S B  BSY DN X XXX
	sprintf(charbuf[3], "PTP %s %s  %s %s %o %03o",
		(ptr & 0100) ? "S" : " ",
		(ptr & 040) ? "B" : " ",
		(ptr & 020) ? "BSY" : "   ",
		(ptr & 010) ? "DN" : "  ",
		ptp & 7,
		ptp>>9 & 0377);
	// DIS  xxxxxxxxxxxx x x
	sprintf(charbuf[4], "DIS  %012llo %o %o",
		disb, dis>>3 & 7, dis & 7);
	//      VF HF LP STP DN
	sprintf(charbuf[5], "     %s %s %s %s %s",
		dis & 04000 ? "VF" : "  ",
		dis & 01000 ? "HF" : "  ",
		dis & 02000 ? "LP" : "  ",
		dis & 0400 ? "STP" : "   ",
		dis & 0200 ? "DN" : "  ");
}

void
screen5(void)
{
	u32 ff1 = h2f_apr[REG6_FF1];
	u32 ff2 = h2f_apr[REG6_FF2];
	u32 ff3 = h2f_apr[REG6_FF3];
	u32 ff4 = h2f_apr[REG6_FF4];
	u8 flags[14];
	int i, j;

	flags[0] = ff1>>24;
	flags[1] = ff1>>16;
	flags[2] = ff1>>8;
	flags[3] = ff1;
	flags[4] = ff2>>24;
	flags[5] = ff2>>16;
	flags[6] = ff2>>8;
	flags[7] = ff2;
	flags[8] = ff3>>24;
	flags[9] = ff3>>16;
	flags[10] = ff3>>8;
	flags[11] = ff3;
	flags[12] = ff4>>24;
	flags[13] = ff4>>16;
	for(i = 0; i < 14; i++)
		for(j = 0; j < 8; j++)
			charbuf[j][i] = flags[i] & (0200>>j) ? 037 : ' ';
}

void
screenNOP(void)
{
}

void
init6(void)
{
	if((memfd = open("/dev/mem", (O_RDWR | O_SYNC))) == -1) {
		fprintf(stderr, "ERROR: could not open /dev/mem...\n");
		exit(1);
	}
	virtual_base = (u32*)mmap(nil, PERIPH_SPAN,
		(PROT_READ | PROT_WRITE), MAP_SHARED, memfd, PERIPH_BASE);
	if(virtual_base == MAP_FAILED) {
		fprintf(stderr, "ERROR: mmap() failed...\n");
		close(memfd);
		exit(1);
	}
	h2f_base = (u64*)mmap(nil, 0x100000,
		(PROT_READ | PROT_WRITE), MAP_SHARED, memfd, H2F_BASE);
	if(h2f_base == MAP_FAILED) {
		fprintf(stderr, "ERROR: mmap() failed...\n");
		close(memfd);
		exit(1);
	}

	h2f_cmemif = getLWH2Faddr(0x10000);
	h2f_fmemif = getLWH2Faddr(0x10010);
	h2f_apr = getLWH2Faddr(0x10100);
	h2f_lw_sw_addr = getLWH2Faddr(0x10020);
}

void (*screens[8])(void) = {
	screen0,
	screen1,
	screen2,
	screen3,
	screen4,
	screen5,
	screenNOP,
	screenNOP,
};

int
main(int argc, char **argv)  
{  
	int i, j;

	initfont();

	fd = open("/dev/i2c-2", O_RDWR);
	if(fd < 0){
		perror("can't open i2c-2");
		return 1;
	}
	if(ioctl(fd, I2C_SLAVE, SSD1306_I2C_ADDRESS) < 0){
		perror("can't set address");
		return 1;
	}
	init6();

// TODO?
//	bcm2835_i2c_set_baudrate(1000000);

	for(i = 0; i < WIDTH; i++)
		for(j = 0; j < PAGES; j++)
			buffer[i*PAGES + j] = 0;
	buffer[0] = 0xFF;
	buffer[1] = 0x0F;
	buffer[128] = 0xFF;
	for(i = 0; i < WIDTH*PAGES; i++)
		buffer[i] = 0x00;

	initdisp();
	cmd(SSD1306_DISPLAYON);

	for(i = 0;; i = !i){
//		imgtobuf(i);
//		display();

		clearscreen();
		screens[*h2f_lw_sw_addr>>1]();
		wcharbuf();
		display();

		usleep(1);
	}

	return 0;  
} 
