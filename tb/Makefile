SRC=../rtl/helpers.v ../rtl/modules_50.v  ../rtl/dly_50.v ../rtl/onchip_ram.v \
	../common/memory_16k.v \
	../pdp6/core161c.v

DEP= diag_ka10.inc test_ka10.inc test_ka10_arith.inc test_ka10_dpy.inc test_ka10_fp.inc


tb_tu56: tb_tu56.v ../ka10/tu56.v $(SRC) $(DEP)
	iverilog -o $@ tb_tu56.v ../ka10/tu56.v $(SRC)

tb_td10: tb_td10.v ../ka10/td10.v ../ka10/tu56.v $(SRC) $(DEP)
	iverilog -o $@ tb_td10.v ../ka10/tu56.v ../ka10/td10.v $(SRC)

tb_ptp_ka: tb_ptp_ka.v ../ka10/ptp.v $(SRC) $(DEP)
	iverilog -o $@ tb_ptp_ka.v ../ka10/ptp.v $(SRC)

tb_ptr_ka: tb_ptr_ka.v ../ka10/ptr.v $(SRC) $(DEP)
	iverilog -o $@ tb_ptr_ka.v ../ka10/ptr.v $(SRC)

tb_tty_ka: tb_tty_ka.v ../ka10/tty.v $(SRC) $(DEP)
	iverilog -o $@ tb_tty_ka.v ../ka10/tty.v $(SRC)

tb_ka10: asm.v tb_ka10.v ../ka10/ka10.v ../ka10/ptr.v $(SRC) $(DEP)
	iverilog -o $@ asm.v tb_ka10.v ../ka10/ka10.v ../ka10/ptr.v $(SRC)

tb_ptp6: tb_ptp6.v ../pdp6/ptp.v $(SRC) $(DEP)
	iverilog -o $@ tb_ptp6.v ../pdp6/ptp.v $(SRC)

