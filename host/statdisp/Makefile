XX=/u/aap/de0-nano-soc/gcc-linaro-6.5.0-2018.12-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-
CFLAGS=-DTEST -I..
LDFLAGS=-lpthread

stat6: stat6.c font.inc img_pdp6.inc
	$(XX)gcc $(CFLAGS) $(LDFLAGS) -o $@ stat6.c
