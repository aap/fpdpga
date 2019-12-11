`default_nettype none
`timescale 1ns/1ns
`define simulation

module pdp10(
	input wire clk,
	input wire reset
);
	reg sw_power;
	reg key_stop_sw;
	reg key_exa_sw;
	reg key_ex_nxt_sw;
	reg key_dep_sw;
	reg key_dep_nxt_sw;
	reg key_reset_sw;
	reg key_exe_sw;
	reg key_sta_sw;
	reg key_rdi_sw;
	reg key_cont_sw;

	reg key_sing_inst;
	reg key_sing_cycle;
	reg key_adr_inst;
	reg key_adr_rd;
	reg key_adr_wr;
	reg key_adr_stop;
	reg key_adr_brk;
	reg key_par_stop;
	reg key_nxm_stop;
	reg key_repeat_sw;

	reg [0:35] ds;
	reg [18:35] as;

	reg sc_stop_sw;
	reg fm_enable_sw;
	reg key_repeat_bypass_sw;
	reg mi_prog_dis_sw;
	reg [3:9] rdi_sel;


	wire iobus_iob_poweron;
	wire iobus_iob_reset;
	wire iobus_iob_dr_split;// = 0;
	wire [3:9] iobus_ios;
	wire iobus_datao_clear;
	wire iobus_datao_set;
	wire iobus_cono_clear;
	wire iobus_cono_set;
	wire iobus_iob_fm_datai;
	wire iobus_iob_fm_status;
	wire iobus_rdi_pulse;
	wire iobus_rdi_data;
	wire [0:35] iobus_iob_out;
	wire [1:7] iobus_pi_req;// = 0;
	wire [0:35] iobus_iob_in = iobus_iob_out | iob_test | iobus_ptr_out;
	reg [0:35] iob_test = 0;


	/* KA10 */
	wire membus_rd_rq_p0;
	wire membus_wr_rq_p0;
	wire membus_rq_cyc_p0;
	wire membus_wr_rs_p0;
	wire [18:21] membus_sel_p0;
	wire [21:35] membus_ma_p0;
	wire [0:35] membus_mb_out_p0_p;
	wire membus_fmc_select_p0;

	/* memory 0 */
	wire [0:35] membus_mb_out_p0_0;
	wire membus_addr_ack_p0_0;
	wire membus_rd_rs_p0_0;

	wire membus_addr_ack_p0 = membus_addr_ack_p0_0;
	wire membus_rd_rs_p0 = membus_rd_rs_p0_0;
	wire [0:35] membus_mb_in_p0 = membus_mb_out_p0_p | membus_mb_out_p0_0;

	wire [17:0] s_address = 0;
	wire s_write = 0;
	wire s_read = 0;
	wire [35:0] s_writedata = 0;
	wire [35:0] s_readdata;
	wire s_waitrequest;

	ka10 ka10(
		.clk(clk),
		.reset(reset),
		.sw_power(sw_power),
		.key_stop_sw(key_stop_sw),
		.key_exa_sw(key_exa_sw),
		.key_ex_nxt_sw(key_ex_nxt_sw),
		.key_dep_sw(key_dep_sw),
		.key_dep_nxt_sw(key_dep_nxt_sw),
		.key_reset_sw(key_reset_sw),
		.key_exe_sw(key_exe_sw),
		.key_sta_sw(key_sta_sw),
		.key_rdi_sw(key_rdi_sw),
		.key_cont_sw(key_cont_sw),

		.key_sing_inst(key_sing_inst),
		.key_sing_cycle(key_sing_cycle),
		.key_adr_inst(key_adr_inst),
		.key_adr_rd(key_adr_rd),
		.key_adr_wr(key_adr_wr),
		.key_adr_stop(key_adr_stop),
		.key_adr_brk(key_adr_brk),
		.key_par_stop(key_par_stop),
		.key_nxm_stop(key_nxm_stop),
		.key_repeat_sw(key_repeat_sw),

		.ds(ds),
		.as(as),

		.membus_rd_rq(membus_rd_rq_p0),
		.membus_wr_rq(membus_wr_rq_p0),
		.membus_rq_cyc(membus_rq_cyc_p0),
		.membus_addr_ack(membus_addr_ack_p0),
		.membus_rd_rs(membus_rd_rs_p0),
		.membus_wr_rs(membus_wr_rs_p0),
		.membus_sel(membus_sel_p0),
		.membus_ma(membus_ma_p0),
		.membus_mb_out(membus_mb_out_p0_p),
		.membus_mb_in(membus_mb_in_p0),
		.membus_fmc_select(membus_fmc_select_p0),

		.iobus_iob_poweron(iobus_iob_poweron),
		.iobus_iob_reset(iobus_iob_reset),
		.iobus_datao_clear(iobus_datao_clear),
		.iobus_datao_set(iobus_datao_set),
		.iobus_cono_clear(iobus_cono_clear),
		.iobus_cono_set(iobus_cono_set),
		.iobus_iob_fm_datai(iobus_iob_fm_datai),
		.iobus_iob_fm_status(iobus_iob_fm_status),
		.iobus_rdi_pulse(iobus_rdi_pulse),
		.iobus_ios(iobus_ios),
		.iobus_iob_out(iobus_iob_out),
		.iobus_pi_req(iobus_pi_req),
		.iobus_iob_in(iobus_iob_in),
		.iobus_iob_dr_split(iobus_iob_dr_split),
		.iobus_rdi_data(iobus_rdi_data),


		.sc_stop_sw(sc_stop_sw),
		.fm_enable_sw(fm_enable_sw),
		.key_repeat_bypass_sw(key_repeat_bypass_sw),
		.mi_prog_dis_sw(mi_prog_dis_sw),
		.rdi_sel(rdi_sel)
	);

	core161c
	#(.memsel_p0(4'b0), .memsel_p1(4'b0),
	  .memsel_p2(4'b0), .memsel_p3(4'b0))
	mem0(
		.clk(clk),
		.reset(reset),
		.power(sw_power),
		.sw_single_step(1'b0),
		.sw_restart(1'b0),

		.membus_rd_rq_p0(membus_rd_rq_p0),
		.membus_wr_rq_p0(membus_wr_rq_p0),
		.membus_rq_cyc_p0(membus_rq_cyc_p0),
		.membus_addr_ack_p0(membus_addr_ack_p0_0),
		.membus_rd_rs_p0(membus_rd_rs_p0_0),
		.membus_wr_rs_p0(membus_wr_rs_p0),
		.membus_ma_p0(membus_ma_p0),
		.membus_sel_p0(membus_sel_p0),
		.membus_fmc_select_p0(membus_fmc_select_p0),
		.membus_mb_in_p0(membus_mb_in_p0),
		.membus_mb_out_p0(membus_mb_out_p0_0),

		.membus_rq_cyc_p1(1'b0),
		.membus_sel_p1(4'b0),
		.membus_fmc_select_p1(1'b0),

		.membus_rq_cyc_p2(1'b0),
		.membus_sel_p2(4'b0),
		.membus_fmc_select_p2(1'b0),

		.membus_rq_cyc_p3(1'b0),
		.membus_sel_p3(4'b0),
		.membus_fmc_select_p3(1'b0),

		.m_address(av_address),
		.m_write(av_write),
		.m_read(av_read),
		.m_writedata(av_writedata),
		.m_readdata(av_readdata),
		.m_waitrequest(av_waitrequest)
	);

	wire [17:0] av_address;
	wire av_write;
	wire av_read;
	wire [35:0] av_writedata;
	wire [35:0] av_readdata;
	wire av_waitrequest;
	memory_16k mem16k(.clk(clk), .reset(~reset),
		.s_address(av_address),
		.s_write(av_write),
		.s_read(av_read),
		.s_writedata(av_writedata),
		.s_readdata(av_readdata),
		.s_waitrequest(av_waitrequest));

	reg ptr_write = 0;
	reg [31:0] ptr_writedata = 0;
	wire [0:35] iobus_ptr_out;
	wire ptr_req;
	ptr_ka10 ptr(.clk(clk), .reset(reset),
		.iobus_iob_poweron(iobus_iob_poweron),
		.iobus_iob_reset(iobus_iob_reset),
		.iobus_datao_clear(iobus_datao_clear),
		.iobus_datao_set(iobus_datao_set),
		.iobus_cono_clear(iobus_cono_clear),
		.iobus_cono_set(iobus_cono_set),
		.iobus_iob_fm_datai(iobus_iob_fm_datai),
		.iobus_iob_fm_status(iobus_iob_fm_status),
		.iobus_rdi_pulse(iobus_rdi_pulse),
		.iobus_ios(iobus_ios),
		.iobus_iob_in(iobus_iob_out),
		.iobus_pi_req(iobus_pi_req),
		.iobus_iob_out(iobus_ptr_out),
		.iobus_dr_split(iobus_iob_dr_split),
		.iobus_rdi_data(iobus_rdi_data),

		.key_tape_feed(1'b0),

        	.s_write(ptr_write),
        	.s_writedata(ptr_writedata),

        	.fe_data_rq(ptr_req));
endmodule

//`define TESTKEY pdp10.key_exa_sw
//`define TESTKEY pdp10.key_dep_sw
//`define TESTKEY pdp10.key_exe_sw
//`define TESTKEY pdp10.key_sta_sw
`define TESTKEY pdp10.key_rdi_sw
//`define TESTKEY pdp10.key_ex_nxt_sw
//`define TESTKEY pdp10.key_cont_sw
//`define TESTKEY pdp10.key_stop_sw

module test;
	wire clk;
	wire reset_p;
	wire reset = ~reset_p;
	reg stop;

	clock clock(clk, reset_p);
	pdp10 pdp10(.clk(clk), .reset(reset));

	initial begin
		$dumpfile("dump.vcd");
		$dumpvars();

		stop = 0;
		#100000 stop = 1;
		$finish;
	end

	initial begin
		pdp10.key_stop_sw = 0;
		pdp10.key_exa_sw = 0;
		pdp10.key_ex_nxt_sw = 0;
		pdp10.key_dep_sw = 0;
		pdp10.key_dep_nxt_sw = 0;
		pdp10.key_reset_sw = 0;
		pdp10.key_exe_sw = 0;
		pdp10.key_sta_sw = 0;
		pdp10.key_rdi_sw = 0;
		pdp10.key_cont_sw = 0;

		pdp10.key_sing_inst = 0;
		pdp10.key_sing_cycle = 0;
		pdp10.key_adr_inst = 0;
		pdp10.key_adr_rd = 0;
		pdp10.key_adr_wr = 0;
		pdp10.key_adr_stop = 0;
		pdp10.key_adr_brk = 0;
		pdp10.key_par_stop = 0;
		pdp10.key_nxm_stop = 0;
		pdp10.key_repeat_sw = 0;

		pdp10.ds = 0;
		pdp10.as = 0;

		pdp10.sc_stop_sw = 0;
		pdp10.fm_enable_sw = 1;
		pdp10.key_repeat_bypass_sw = 0;
		pdp10.mi_prog_dis_sw = 0;
		pdp10.rdi_sel = 'o104 >> 2;

		pdp10.sw_power = 0;
		#20 pdp10.sw_power = 1;
	end

	function [0:35] Inst;
		input [0:8] op;
		input [9:12] ac;
		input i;
		input [14:17] x;
		input [18:35] y;
		begin
			Inst = { op, ac, i, x, y };
		end
	endfunction

	function [0:35] IoInst;
		input [10:12] op;
		input [3:11] dev;
		input i;
		input [14:17] x;
		input [18:35] y;
		begin
			IoInst = { 3'o7, dev[3:9], op, i, x, y };
		end
	endfunction

`include "diag_ka10.inc"
//`include "test_ka10.inc"
//`include "test_ka10_arith.inc"
//`include "test_ka10_fp.inc"
//`include "test_ka10_dpy.inc"

	initial begin
		pdp10.ka10.ma = 3;
		pdp10.ka10.ar = 1234;
		pdp10.ka10.pc = 22;
//		pdp10.as = 3;
		pdp10.as = 'o20;
//		pdp10.as = 100000;
		pdp10.ds = 36'o201040001234;
//		pdp10.ds = 36'o777777777777;
//		pdp10.key_repeat_sw = 1;
//		pdp10.key_adr_stop = 1;

		#96 `TESTKEY = 1;
//		pdp10.ka10.pi_act = 1;
//		pdp10.ka10.pir = 7'b0000010;

//		pdp10.ka10.pio = 7'b1111111;
//		pdp10.ka10.cpa_clk_en = 1;
//		pdp10.ka10.cpa_clk_flag = 1;
//		pdp10.ka10.cpa_pia = 1;
//		pdp10.ka10.ar_ov_flag = 1;
//		pdp10.ka10.ar_cry0_flag = 1;
//		pdp10.ka10.ar_cry1_flag = 1;
//		pdp10.ka10.ar_fov = 1;

		#1200 `TESTKEY = 0;
	end

	// IR decode test
/*	initial begin: irtest
		integer i;
		#10000;
		pdp10.ka10.ar = 0;
		pdp10.ka10.ir = 0;
		for(i = 0; i < 'o700; i = i+1)
			#10 pdp10.ka10.ir[0:8] = i;
		for(i = 'o700000; i <= 'o700340; i = i + 'o40)
			#10 pdp10.ka10.ir = i;
		#10;
	end
*/



/*
	reg [0:35] rimdata[0:1000];

	initial begin: rimtest
		integer i;

		i <= 0;
		pdp10.iobus_rdi_data <= 0;
        	rimdata[0] <= 36'o777776001000;
        	rimdata[1] <= 36'o123321456654;
        	rimdata[2] <= 36'o254200000123;
		#100;
		@(posedge pdp10.iobus_rdi_pulse);

		while(1) begin
			#2000;
			pdp10.iobus_rdi_data <= 1;
			@(posedge pdp10.iobus_iob_fm_datai);
			pdp10.iob_test <= rimdata[i];
			@(negedge pdp10.iobus_iob_fm_datai);
			pdp10.iobus_rdi_data <= 0;
			pdp10.iob_test <= 0;
			i <= i + 1;
		end
	end
*/


	reg [7:0] holes[0:100];
	initial begin: rimtest
		integer i;

		for(i = 0; i < 100; i = i + 1)
			holes[i] <= 0;

		holes[0] <= 8'hbf;
		holes[1] <= 8'hbf;
		holes[2] <= 8'hbe;
		holes[3] <= 8'h80;
		holes[4] <= 8'h88;
		holes[5] <= 8'h80;
		holes[6] <= 8'h8a;
		holes[7] <= 8'h9a;
		holes[8] <= 8'h91;
		holes[9] <= 8'ha5;
		holes[10] <= 8'hb6;
		holes[11] <= 8'hac;
		holes[12] <= 8'h95;
		holes[13] <= 8'ha2;
		holes[14] <= 8'h80;
		holes[15] <= 8'h80;
		holes[16] <= 8'h81;
		holes[17] <= 8'h93;

		i <= 0;
		while(1) begin
			@(posedge pdp10.ptr_req);
			@(posedge clk);
			pdp10.ptr_writedata <= holes[i];
			pdp10.ptr_write <= 1;
			i <= i + 1;
			@(posedge clk);
			pdp10.ptr_write <= 0;
			@(posedge clk);
			@(posedge clk);
		end
	end
endmodule
