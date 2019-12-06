module ka10(
	input wire clk,
	input wire reset,

	// keys
	input wire key_stop_sw,
	input wire key_exa_sw,
	input wire key_ex_nxt_sw,
	input wire key_dep_sw,
	input wire key_dep_nxt_sw,
	input wire key_reset_sw,
	input wire key_exe_sw,
	input wire key_sta_sw,
	input wire key_rdi_sw,
	input wire key_cont_sw,

	input wire key_sing_inst,
	input wire key_sing_cycle,
	input wire key_adr_inst,
	input wire key_adr_rd,
	input wire key_adr_wr,
	input wire key_adr_stop,
	input wire key_adr_brk,
	input wire key_par_stop,
	input wire key_nxm_stop,
	input wire key_repeat_sw,

	input wire [0:35] ds,
	input wire [18:35] as,

	// Membus
	output wire membus_rd_rq,
	output wire membus_wr_rq,
	output wire membus_rq_cyc,
	output wire membus_wr_rs,	// pulse
	output wire [21:35] membus_ma,
	output wire [18:21] membus_sel,
	output wire membus_fmc_select,
	output wire [0:35] membus_mb_out,
	input  wire membus_addr_ack,	// pulse
	input  wire membus_rd_rs,	// pulse
	input  wire [0:35] membus_mb_in,
	// not implemented:
	// ouput wire parity,	// pulse
	// input wire ign_parity,	// pulse

	// IO bus
	output wire iobus_iob_poweron,	// actually unused on 10
	output wire iobus_iob_reset,	// pulse
	output wire iobus_datao_clear,	// pulse
	output wire iobus_datao_set,	// pulse
	output wire iobus_cono_clear,	// pulse
	output wire iobus_cono_set,	// pulse
	output wire iobus_iob_fm_datai,
	output wire iobus_iob_fm_status,
	output wire iobus_rdi_pulse,	// pulse, unused on 6
	output wire [3:9]  iobus_ios,
	output wire [0:35] iobus_iob_out,
	input  wire [1:7]  iobus_pi_req,
	input  wire [0:35] iobus_iob_in,
	input  wire iobus_iob_dr_split,
	input  wire iobus_rdi_data,	// unused on 6

	// operator panel
	output wire ind_run,
	output wire ind_pi_on,
	output wire pwr_on_ind,
	output wire ind_prog_stop,
	output wire ind_user,
	output wire ind_mem_stop,
	output wire [1:7] ind_pih,
	output wire [1:7] ind_pir,
	output wire [1:7] ind_pio,
	output wire [1:7] ind_iob_req,
	output wire [18:35] ind_pc_reg,
	output wire [0:17] ind_ir_reg,
	output wire [18:35] ind_ma_reg,
	output wire [0:35] ind_mi_reg,
	output wire ind_mi_prog,

	// indicators
	output wire [6:0] ind_ar,
	output wire [0:35] ind_ar_reg,
	output wire [0:35] ind_br_reg,
	output wire [0:35] ind_mq_reg,
	output wire [10:0] ind_ad,
	output wire [0:35] ind_ad_reg,
	output wire ind_sc,
	output wire [0:8] ind_sc_reg,
	output wire [0:8] ind_fe_reg,
	output wire [7:0] ind_scad,
	output wire [0:8] ind_scad_reg,
	output wire [2:0] ind_ir,
	output wire [11:0] ind_key,
	output wire [11:0] ind_opr,
	output wire [5:0] ind_fetch,
	output wire [4:0] ind_store,
	output wire [32:35] ind_fma,
	// { [18:25], [18:25] }
	output wire [15:0] ind_pr_reg,
	output wire [15:0] ind_rl_reg,
	output wire [15:0] ind_rla_reg,
	output wire [9:0] ind_mem,
	output wire [4:0] ind_ex,
	output wire [1:0] ind_pi,
	output wire [1:0] ind_byte,
	output wire [13:0] ind_cpa,
	output wire [15:0] ind_misc,
	output wire [2:0] ind_nr,
	output wire [1:0] ind_as,

	// maintenance panel:
	input wire sw_power,
	// TODO: repeat
	input wire sc_stop_sw,
	input wire fm_enable_sw,
	input wire key_repeat_bypass_sw,
	input wire mi_prog_dis_sw,
	input wire [3:9] rdi_sel,


	// 36 bit Avalon Slave for fast mem
	input wire [17:0] s_address,
	input wire s_write,
	input wire s_read,
	input wire [35:0] s_writedata,
	output wire [35:0] s_readdata,
	output wire s_waitrequest
);

	assign ind_run = run;
	assign ind_pi_on = pi_act;
	assign ind_prog_stop = key_prog_stop;
	assign ind_user = ex_user;
	assign ind_mem_stop = mc_stop;
	assign ind_pih = pih;
	assign ind_pir = pir;
	assign ind_pio = pio;
	assign ind_iob_req = iobus_pi_req;
	assign ind_pc_reg = pc;
	assign ind_ir_reg = ir;
	assign ind_ma_reg = ma;
	assign ind_mi_reg = mi;
	assign ind_mi_prog = mi_prog;


	assign ind_ar = {
		ar_ov_flag,
		ar_cry0_flag, ar_cry1_flag, ar_fov,
		ar_fxu, ar_dck, ar_ov_cond };
	assign ind_ar_reg = ar;
	assign ind_br_reg = br;
	assign ind_mq_reg = mq;
	assign ind_ad = {
		ad_ar_p_en, ad_ar_m_en,
		ad_br_p_en, ad_br_m_en, ad_cry_36,
		ad_cry_ins, ad_p1_lh, ad_m1_lh,
		ad_md_p, ad_md_m, ad_cond };
	assign ind_ad_reg = ad;
	assign ind_sc = sc_stop;
	assign ind_sc_reg = sc;
	assign ind_fe_reg = fe;
	assign ind_scad = {
		scad_data0, scad_data1,
		scad_sc_comp, scad_inc_en, scad_br_en,
		scad_ar6_11_en, scad_200_en, scad_33_en };
	assign ind_scad_reg = scad;
	assign ind_ir = { ir_uuo, ir_lt_en, ir_rt_en };
	assign ind_key = {
		key_f1, key_sync_rq, key_sync,
		key_reset, key_examine, key_ex_nxt,
		key_deposit, key_dep_nxt, key_rdi,
		key_start, key_execute, key_cont };
	assign ind_opr = {
		if0, af2, ff1,
		ff2, ff4, e_uuof,
		e_xctf, e_long, ef0_long,
		sf1, sf6, sf8 };
	assign ind_fetch = {
		fce, fce_pse, fac_inh,
		fac2, fcc_aclt, fcc_acrt };
	assign ind_store = {
		sce, st_inh,
		sac2, sac_inh, sac_eq_0 };	// TODO? invert SAC=0?
	assign ind_fma = fma;
	assign ind_pr_reg = { prb, pr };
	assign ind_rl_reg = { rlb, rl };
	assign ind_rla_reg = { rlc, rla };
	assign ind_mem = {
		mc_rq,
		mc_rd, mc_wr, mc_req_cyc,
		mc_split_cyc_sync, mc_fm_en, mai_fma_sel,
		fma_ac, fma_ac2, fma_xr };
	assign ind_ex = {
		ex_ill_op, ex_pi_sync,
		ex_mode_sync, ex_iot_user, ex_rel };
	assign ind_pi = { pi_ov, pi_cyc };
	assign ind_byte = { lb_byte_load, db_byte_dep };
	assign ind_cpa = {
		cpa_pwr_fail, cpa_adr_break,
		cpa_par_err, cpa_par_enb, cpa_pdl_ov,
		cpa_mem_prot_flag, cpa_non_ex_mem, cpa_clk_en,
		cpa_clk_flag, cpa_fov_en, cpa_ar_ov_en,
		cpa_pia };
	assign ind_misc = {
		bltf1, mpf1, mpf2,
		msf1, byf4, byf5,
		byf6, dsf1, dsf7,
		faf1, fdf1, fdf3,
		key_rim, iot_f1, iot_go };
	assign ind_nr = { nr_sh_rt_cond, nr_normal, nr_round };
	assign ind_as = { as_eq_rla, as_eq_fma };



	// TODO: This is used for a second processor with the same memory
	wire ma_trap_offset = 0;
	// Trap floating point and byte ops
	wire ir_fp_trap_sw = 0;

	// ignore parity checks
	wire pn_par_even = 0;

	/* Membus */
	assign membus_rd_rq = mc_rd;
	assign membus_wr_rq = mc_wr;
	assign membus_rq_cyc = mc_req_cyc;
	assign membus_wr_rs = mc_wr_rs;
	assign membus_sel = mai[18:21];
	assign membus_ma = mai[21:35];
	assign membus_fmc_select = 0;
	assign membus_mb_out =
		mc_membus_fm_ar1 ? ar :
		0;

	/* IObus */
	assign iobus_iob_poweron = sw_power;	// ???
	assign iobus_iob_reset = iot_reset;	// pulse
	wire iob_dr_split = iobus_iob_dr_split;
	assign iobus_ios = ir[3:9];
	assign iobus_datao_clear = iot_datao_clr;	// pulse
	assign iobus_datao_set = iot_datao_set;	// pulse
	assign iobus_cono_clear = iot_cono_clr;	// pulse
	assign iobus_cono_set = iot_cono_set;	// pulse
	assign iobus_iob_fm_datai = iob_datai;
	assign iobus_iob_fm_status = iob_status;
	assign iobus_rdi_pulse = iot_rdi_pulse;	// pulse
//	input wire iobus_rdi_data,
	assign iobus_iob_out = iob_fm_ar ? ar :
		cpa_status ? cpa_iob :
		pi_status ? pi_iob :
		0;

	wire [1:7] iob_pi = iobus_pi_req | {7{ cpa_req_enable}}&cpa_req;
	wire [0:35] iob = iobus_iob_in | iobus_iob_out;
	wire iob_status = iot_data_xfer & (iot_consx | iot_coni);
	wire iob_datai = iot_datai & iot_data_xfer;
	wire iob_fm_ar = iot_out_going & iot_data_xfer;

	wire bio_cpa_sel = ir[3:9] == 0;
	wire bio_pi_sel = ir[3:9] == 1;
	wire bio_ptp_sel = ir[3:9] == 'o20;
	wire bio_ptr_sel = ir[3:9] == 'o21;
	wire bio_tty_sel = ir[3:9] == 'o24;


	/* MR */
	// TODO: do this properly
	// mr_pwr_clr_enb;
	// wire pwr_on_ind = ~mr_pwr_clr_enb;
	assign pwr_on_ind = sw_power;

	wire mr_pwr_clr;
	wire mr_start;
	wire mr_clr;

	pg mr_pg1(.clk(clk), .reset(reset), .in(sw_power), .p(mr_pwr_clr));
	pa mr_pa1(.clk(clk), .reset(reset),
		.in(mr_pwr_clr |
		    kt0a & key_rdi & ~run |
		    kst2),
		.p(mr_start));
	pa mr_pa2(.clk(clk), .reset(reset),
		.in(mr_start |
		    kt1 & ~key_cont |
		    it0),
		.p(mr_clr));


	/*
	 * KEY
	 */
	reg key_examine, key_ex_nxt;
	reg key_deposit, key_dep_nxt;
	reg key_reset;
	reg key_execute;
	reg key_start;
	reg key_rdi;
	reg key_cont;
	reg key_rept_sync;
	reg key_pi_inh;
	reg key_sync;
	reg key_sync_rq;
	reg run;
	reg key_rim;
	reg key_f1;
	reg key_rdi_part2;
	wire key_manual = key_rdi_sw | key_sta_sw |
		key_cont_sw | key_reset_sw |
		key_exe_sw | key_exa_sw |
		key_dep_sw | key_ex_nxt_sw |
		key_dep_nxt_sw;
	wire key_next = key_dep_nxt | key_ex_nxt;
	wire key_mem_ref = key_dep_nxt | key_ex_nxt | key_examine | key_deposit;
	wire key_ex_OR_ex_nxt = key_examine | key_ex_nxt;
	wire key_dep_OR_dep_nxt = key_deposit | key_dep_nxt;
	wire key_dep_OR_dep_nxt_OR_exe = key_deposit | key_dep_nxt | key_execute;
	wire key_as_strobe_en = key_examine | key_deposit | key_start;
	wire kt1_en = ~run &
		(key_start | key_rdi | key_examine | key_deposit | key_execute);
	wire key_sync_ops = key_examine | key_deposit | key_execute;
	wire key_mid_inst_stop = mc_stop | sc_stop;
	wire key_prog_stop = ir_jrst & ir[10];
	wire key_fcn_strobe;
	wire key_fcn_clr;
	wire key_rept_dly;
	wire key_clr = mr_clr;
	wire key_run_clr = kst1 |
		et0 & (key_prog_stop | key_sing_inst);
	wire key_it0_en = run & ~pi_ov & (e_xctf | ~key_sync);
	wire key_at_inh;
	wire kt0;
	wire kt0a;
	wire kt1;
	wire kt2;
	wire kt3;
	wire kt3a;
	wire kt4;
	wire knt1;
	wire knt2;
	wire knt3;
	wire kct0;
	wire kst1;
	wire kst2;
	wire key_rdi_dly;
	wire key_rdi_done = st1 & key_rim & pi_ov;
	wire key_done;

	wire key_rept_in, key_at_inh_in;
	pa_dcd4 key_pa1(.clk(clk), .reset(reset),
		.p1(mr_pwr_clr), .l1(1'b1),
		.p2(kt0), .l2(run & (key_ex_nxt | key_dep_nxt | key_start | key_rdi)),
		.p3(key_done), .l3(~key_rept_sync),
		.p4(~key_rept_dly), .l4(~key_rept_sync),
		.q(key_fcn_clr));
	pa_dcd key_pa2(.clk(clk), .reset(reset),
		.p(~key_manual_D),
		.l(~key_rept_sync),
		.q(key_fcn_strobe));
	pa_dcd2 key_pa3(.clk(clk), .reset(reset),
		.p1(~key_fcn_strobe_D), .l1(1'b1),
		.p2(~key_rept_dly), .l2(key_rept_sync),
		.q(kt0));
	pa key_pa4(.clk(clk), .reset(reset), .in(kt0), .p(kt0a));
	pa key_pa5(.clk(clk), .reset(reset),
		// TODO
		.in(kt0a_D & kt1_en |
		    knt3_D |
		    st9 & key_sync & ~e_xctf),
		.p(kt1));
	pa key_pa6(.clk(clk), .reset(reset), .in(kt1_D), .p(kt2));
	pa key_pa7(.clk(clk), .reset(reset), .in(kt2_D), .p(kt3));
	pa key_pa8(.clk(clk), .reset(reset), .in(kt3_D), .p(kt3a));
	pa key_pa9(.clk(clk), .reset(reset),
		.in(kt3_D & key_start |
		    mc_rst1 & key_f1 |
		    kct0_D),
		.p(kt4));
	pa key_pa10(.clk(clk), .reset(reset),
		.in(kt0a & (key_cont & key_mid_inst_stop |
		            run & key_cont & ~key_mid_inst_stop) |
		    kt3a & key_execute |
		    kt4 |
		    kst2 |
		    key_run_clr & key_cont |
		    key_rdi_done),
		.p(key_done));
	pa key_pa11(.clk(clk), .reset(reset),
		.in(kt0a & key_next & ~run),
		.p(knt1));
	pa key_pa12(.clk(clk), .reset(reset),
		.in(knt1_D),
		.p(knt2));
	pa key_pa13(.clk(clk), .reset(reset),
		.in(knt2_D),
		.p(knt3));
	pa_dcd2 key_pa14(.clk(clk), .reset(reset),
		.p1(key_done), .l1(key_rept_sync),
		.p2(kt0), .l2(key_repeat_bypass_sw),
		.q(key_rept_in));
	pa key_pa15(.clk(clk), .reset(reset),
		.in(kt0a & ~run & key_cont & ~key_mid_inst_stop),
		.p(kct0));
	pa_dcd2 key_pa16(.clk(clk), .reset(reset),
		.p1(key_stop_sw), .l1(1'b1),
		.p2(kt0), .l2(key_reset & run),
		.q(kst1));
	pa_dcd key_pa17(.clk(clk), .reset(reset),
		.p(~key_at_inh), .l(key_reset),
		.q(kst2));

	wire key_manual_D;
	wire key_fcn_strobe_D;
	wire kt0a_D, kt1_D, kt2_D, kt3_D;
	wire knt1_D, knt2_D, knt3_D;
	wire kct0_D;
	wire kst1_D;
	// SIM: this delay is 30ms really, to debounce the keys
	gdly0_2us key_dly1(.clk(clk), .reset(reset),
		.p(key_manual), .l(1'b1),
		.q(key_manual_D));
	gdly1us key_dly2(.clk(clk), .reset(reset),
		.p(key_fcn_strobe), .l(1'b1),
		.q(key_fcn_strobe_D));
	dly165ns key_dly3(.clk(clk), .reset(reset), .in(kt0a), .p(kt0a_D));
	dly90ns key_dly4(.clk(clk), .reset(reset), .in(kt1), .p(kt1_D));
	dly90ns key_dly5(.clk(clk), .reset(reset), .in(kt2), .p(kt2_D));
	dly265ns key_dly6(.clk(clk), .reset(reset), .in(kt3), .p(kt3_D));
	dly90ns key_dly7(.clk(clk), .reset(reset), .in(knt1), .p(knt1_D));
	dly90ns key_dly8(.clk(clk), .reset(reset), .in(knt2), .p(knt2_D));
	dly90ns key_dly9(.clk(clk), .reset(reset), .in(knt3), .p(knt3_D));
	dly165ns key_dly10(.clk(clk), .reset(reset), .in(kct0), .p(kct0_D));
	// TODO: this delay has to be adjustable!
	gdly1us key_dly11(.clk(clk), .reset(reset),
		.p(key_rept_in), .l(1'b1),
		.q(key_rept_dly));
	gdly100us key_dly12(.clk(clk), .reset(reset),
		.p(kst1), .l(1'b1),
		.q(kst1_D));
	gdly100us key_dly13(.clk(clk), .reset(reset),
		.p(key_at_inh_in), .l(1'b1),
		.q(key_at_inh));
	gdly1_5us key_dly14(.clk(clk), .reset(reset),
		.p(kt0), .l(key_rdi & ~run),
		.q(key_rdi_dly));

	wire key_rept_sync_clr, key_rept_sync_set;
	pa_dcd2 key_dcd1(.clk(clk), .reset(reset),
		.p1(key_done), .l1(~key_repeat_sw),
		.p2(key_reset_sw), .l2(1'b1),
		.q(key_rept_sync_clr));
	pa_dcd2 key_dcd2(.clk(clk), .reset(reset),
		.p1(kt0), .l1(key_reset & ~run),
		.p2(~kst1_D), .l2(1'b1),
		.q(key_at_inh_in));

	always @(posedge clk) begin
		if(mr_pwr_clr)
			key_rept_sync <= 0;
		if(key_fcn_clr) begin
			key_examine <= 0;
			key_ex_nxt <= 0;
			key_deposit <= 0;
			key_dep_nxt <= 0;
			key_reset <= 0;
			key_execute <= 0;
			key_start <= 0;
			key_rdi <= 0;
			key_cont <= 0;
		end
		if(mr_start) begin
			key_sync <= 0;
			key_sync_rq <= 0;
			run <= 0;
			key_rim <= 0;
		end
		if(key_clr) begin
			key_f1 <= 0;
			key_pi_inh <= 0;
		end
		if(ex_clr)
			key_rdi_part2 <= 0;
		if(key_run_clr)
			run <= 0;
		if(key_fcn_strobe) begin
			key_examine <= key_exa_sw;
			key_ex_nxt <= key_ex_nxt_sw;
			key_deposit <= key_dep_sw;
			key_dep_nxt <= key_dep_nxt_sw;
			key_reset <= key_reset_sw;
			key_execute <= key_exe_sw;
			key_start <= key_sta_sw;
			key_rdi <= key_rdi_sw;
			key_cont <= key_cont_sw;
		end
		if((key_fcn_strobe | kt0) & key_repeat_sw)
			key_rept_sync <= 1;
		if(key_rept_sync_clr)
			key_rept_sync <= 0;
		if(key_rept_sync_set)
			key_rept_sync <= 1;
		if(key_rdi_done) begin
			key_rim <= 0;
			if(~key_sing_inst)
				run <= 1;
		end
		if(kt0a & key_cont & ~key_mid_inst_stop)
			run <= 1;
		if(kt0a & run & key_sync_ops)
			key_sync_rq <= 1;
		if(kt2 & key_execute)
			key_pi_inh <= 1;
		if(kt3) begin
			if(key_start)
				run <= 1;
			if(key_mem_ref)
				key_f1 <= 1;
			key_sync <= 0;
			key_sync_rq <= 0;
		end
		if(kt3a & key_rdi)
			key_rim <= 1;
		if(kt4)
			key_f1 <= 0;
		if(ft9 & key_sync_rq)
			key_sync <= 1;
	end




	/* I */
	reg if0;
	wire it0;
	wire it1;

	pa i_pa1(.clk(clk), .reset(reset),
		.in(kt4 & run |
		    pi_t0_D |
		    st9 & key_it0_en),
		.p(it0));
	pa i_pa2(.clk(clk), .reset(reset),
		.in(kt3a & (key_execute | key_rim) |
		    mc_rst1 & if0 |
		    mc_illeg_adr_del & if0 |
		    byt7a_D),
		.p(it1));

	always @(posedge clk) begin
		if(mr_start | it1 | key_at_inh)
			if0 <= 0;
		if(it0 | at4)
			if0 <= 1;
	end

	/* A */
	reg af2;
	wire at1;
	wire at2;
	wire at3;
	wire at4;
	wire at6;

	pa a_pa1(.clk(clk), .reset(reset),
		.in(it1 & ~pi_rq & ir[14:17] != 0),
		.p(at1));
	pa a_pa2(.clk(clk), .reset(reset),
		.in(at1_D & mc_fm_en |
		    mc_rst1 & af2),
		.p(at2));
	pa a_pa3(.clk(clk), .reset(reset),
		.in(at2_D |
		    it1 & ~pi_rq & ir[14:17] == 0 |
		    iot_t1),
		.p(at3));
	pa a_pa4(.clk(clk), .reset(reset),
		.in(at3_D & ir[13]),
		.p(at4));
	pa a_pa6(.clk(clk), .reset(reset),
		.in(at3_D & ~ir[13]),
		.p(at6));

	wire at1_D, at2_D, at3_D, at6_D;
	dly90ns a_dly1(.clk(clk), .reset(reset),
		.in(at1), .p(at1_D));
	dly90ns a_dly2(.clk(clk), .reset(reset),
		.in(at2), .p(at2_D));
	dly90ns a_dly3(.clk(clk), .reset(reset),
		.in(at3), .p(at3_D));
	dly90ns a_dly4(.clk(clk), .reset(reset),
		.in(at6), .p(at6_D));

	always @(posedge clk) begin
		if(mr_clr | at3)
			af2 <= 0;
		if(at1)
			af2 <= 1;
	end


	/* F */
	reg ff1;
	reg ff2;
	reg ff4;
	wire ft0;
	wire ft1;
	wire ft1a;
	wire ft2;
	wire ft3;
	wire ft4;
	wire ft4a;
	wire ft5;
	wire ft6;
	wire ft7;
	wire ft8;
	wire ft9;

	wire fce = ir_as_dir | ir_fwt_dir | hwt_dir |
		ir_skipx | ir_camx | ir_test_fce |
		ir_push | ir_fp_NOT_imm | ir_md_fce |
		byte_ptr_not_inc | lb_byte_load | iot_datao |
		ir_boole_dir & ~ir_boole_0 & ~ir_boole_5 & ~ir_boole_12 & ~ir_boole_17 |
		ir_ufa | db_byte_dep;
	wire fce_pse = ir_as_mem | ir_as_both | ir_fwt_self | hwt_self |
		ir_dfn | ir_exch | ir_xosx |
		byte_ptr_inc | iot_blk |
		ir_boole & ir[7] & ~ir_boole_0 & ~ir_boole_5 & ~ir_boole_12 & ~ir_boole_17 |
		hwt_3_let & hwt_mem;
	wire fac_inh = ir_fwt_dir | ir_fwt_imm | ir_fwt_self | hwt_self |
		ir_boole_0 | ir_boole_3 | ir_boole_14 | ir_boole_17 |
		ir_skips | byte_ptr_inc | byte_ptr_not_inc | lb_byte_load |
		ir_xct | ir_uuo | ir_iot | ir_254_7 | ir_jsr | ir_jsp |
		ir_hwt & ~hwt_3_let & ~hwt_mem;
	wire fac2 = ir_ashc | ir_rotc | ir_lshc | ir_div | ir_fdvl;
	wire fcc_aclt = ir_jra | ir_blt;
	wire fcc_acrt = ir_pop | ir_popj;

	pa f_pa1(.clk(clk), .reset(reset),
		.in(at6 & fce),
		.p(ft0));
	pa f_pa2(.clk(clk), .reset(reset),
		.in(at6_D & fce_pse),
		.p(ft1));
	pa f_pa3(.clk(clk), .reset(reset),
		.in(at6 & ~ir_fp_imm & ~fce_pse & ~fce |
		    mc_rst1 & ff1 |
		    ft8_D),
		.p(ft1a));
	pa f_pa4(.clk(clk), .reset(reset),
		.in(ft1a & ~fac_inh),
		.p(ft2));
	pa f_pa5(.clk(clk), .reset(reset),
		.in(ft2_D & mc_fm_en |
		    mc_rst1 & ff2),
		.p(ft3));
	pa f_pa6(.clk(clk), .reset(reset),
		.in(ft3_D & fac2),
		.p(ft4));
	pa f_pa7(.clk(clk), .reset(reset),
		.in(ft4_D & mc_fm_en),
		.p(ft5));
	pa f_pa8(.clk(clk), .reset(reset),
		.in(ft5_D |
		    mc_rst1 & ff4),
		.p(ft4a));
	pa f_pa9(.clk(clk), .reset(reset),
		.in(ft3_D & fcc_aclt |
		    blt_t3_D & ~pi_rq),
		.p(ft6));
	pa f_pa10(.clk(clk), .reset(reset),
		.in(ft3_D & fcc_acrt |
		    ft6_D),
		.p(ft7));
	pa f_pa11(.clk(clk), .reset(reset),
		.in(at6 & ir_fp_imm),
		.p(ft8));
	pa f_pa12(.clk(clk), .reset(reset),
		.in(ft1a & fac_inh |
		    ft3 & ~fac2 & ~fcc_aclt & ~fcc_acrt |
		    ft4a),
		.p(ft9));

	wire ft2_D, ft3_D, ft4_D, ft5_D, ft6_D, ft8_D;
	wire ft9_D1, ft9_D2;
	dly100ns f_dly1(.clk(clk), .reset(reset), .in(ft2), .p(ft2_D));
	dly90ns f_dly2(.clk(clk), .reset(reset), .in(ft3), .p(ft3_D));
	dly90ns f_dly3(.clk(clk), .reset(reset), .in(ft4), .p(ft4_D));
	dly90ns f_dly4(.clk(clk), .reset(reset), .in(ft5), .p(ft5_D));
	dly115ns f_dly5(.clk(clk), .reset(reset), .in(ft6), .p(ft6_D));
	dly65ns f_dly6(.clk(clk), .reset(reset), .in(ft8), .p(ft8_D));
	dly90ns f_dly7(.clk(clk), .reset(reset), .in(ft9), .p(ft9_D1));
	dly265ns f_dly8(.clk(clk), .reset(reset), .in(ft9), .p(ft9_D2));

	always @(posedge clk) begin
		if(mr_clr) begin
			ff1 <= 0;
			ff2 <= 0;
			ff4 <= 0;
		end
		if(ft0 | ft1)
			ff1 <= 1;
		if(ft1a)
			ff1 <= 0;
		if(ft2)
			ff2 <= 1;
		if(ft3)
			ff2 <= 0;
		if(ft4 | ft7)
			ff4 <= 1;
		if(ft4a)
			ff4 <= 0;
	end


	/* E */
	reg e_uuof;
	reg e_xctf;
	wire e_long = ir_boole_2 | ir_boole_10 | ir_boole_13 | ir_boole_16 |
		hwt_e_long | ir_test |
		ir_26x_e_long | key_prog_stop | ir_dfn | ir_idiv | ir_fsc | ir_blt |
		ir_div_OR_fdvl | ir_jffo;
	wire ef0_long = ir_as | ir_21x | ir_3xx |
		ir_aobjp | ir_aobjn | ir_260_3 |
		ir_idiv | ir_fsb | iot_blk |
		ir_dfn | ir_fdv_NOT_l | ir_jffo;
	wire e_long_OR_st_inh = e_long | st_inh;
	wire et0;
	wire et0_del, et0_dela;
	wire et1;
	wire et2;
	wire et2b_del;

	pa e_pa1(.clk(clk), .reset(reset),
		.in(ft9_D1 & ~ef0_long |
		    ft9_D2 & ef0_long),
		.p(et0));
	pa e_pa2(.clk(clk), .reset(reset),
		.in(et0_del & e_long),
		.p(et1));
	pa e_pa3(.clk(clk), .reset(reset),
		.in(et1_D),
		.p(et2));

	wire et1_D;
	dly140ns e_dly1(.clk(clk), .reset(reset), .in(et0), .p(et0_del));
	dly165ns e_dly2(.clk(clk), .reset(reset), .in(et0), .p(et0_dela));
	dly215ns e_dly3(.clk(clk), .reset(reset), .in(et1), .p(et1_D));
	dly90ns e_dly4(.clk(clk), .reset(reset), .in(et2), .p(et2b_del));

	always @(posedge clk) begin
		if(mr_start | it1) begin
			e_uuof <= 0;
			e_xctf <= 0;
		end
		if(et0 & ir_uuo)
			e_uuof <= 1;
		if(et0 & (ir_uuo | ir_xct) | key_rdi_done)
			e_xctf <= 1;
	end


	/* S */
	// The exact flow is a bit hard to understand from the prints
	// A fast store cycle does not go through ST2 and can
	//     write AR to a fast AC
	//     (read/)write AR to memory (FCE PSE, SCE)
	// control has to go through ST2 to
	//     write AR to AC memory
	//     write MQ to a second AC (SAC2)
	//     write BR to memory (SAR != BR)
	// From ST2:
	//          FCE PSE -> ST5 (complete memory read/write)
	//     else SAR != BR || SCE -> ST6 (write to memory)
	//     else SAC2 -> ST7 (write second AC)
	//     else -> ST9 (ST2 only because no fast ACs)
	reg sf1;
	reg sf6;
	reg sf8;
	wire sce = ir_jsr | ir_uuo | ir_fwt_mem |
		ir_fp_mem | ir_fp_both | ir_md_sce |
		iot_datai | iot_coni | hwt_sce |
		ir_boole & ir[7] & ~fce_pse |
		db_byte_dep;
	wire sar_ne_br = ir_push | ir_pushj | ir_pop |
		ir_jsa | ir_exch | ir_dfn;
	wire sac2 = ir_ashc | ir_fp_long | ir_md_sac2 |
		ir_lshc | ir_rotc;
	wire sac_eq_0 = ir[9:12] == 0;
	wire sac_inh = ir_md_sac_inh | db_byte_dep |
		ir_fp_mem | ir_boole_mem | ir_fwt_mem | hwt_mem |
		ir_cax | ir_jumpx | ir_txnx | ir_jsr | ir_254_7 | ir_uuo |
		ir_iot | ir_as_mem | ir_ibp |
		(ir_fwt_self | hwt_self | ir_skips) & sac_eq_0;
	wire st_inh =
		sr_op | ir_md | ir_fp | ir_blt | ir_iot | ir_fsc |
		ir_ufa | byte_ptr_inc | byte_ptr_not_inc |
		lb_byte_load | db_byte_dep | ir_jffo;
	wire sar_ne_br_OR_sac2 = sar_ne_br | sac2;
	wire sac_inh_OR_fm_en = sac_inh | mc_fm_en;
	wire sce_OR_fce_pse = sce | fce_pse;
	wire st0;
	wire st1;
	wire st1a;
	wire st2;
	wire st5;
	wire st6;
	wire st6a;
	wire st7;
	wire st8;
	wire st9;

	pa s_pa1(.clk(clk), .reset(reset),
		.in(iot_t4 & ~iot_consx |
		    iot_t5 |
		    blt_t3 & pi_rq |
		    et2 & ir_jffo & ~jffo_cycle |
		    jffo_t1_del & ~jffo_cycle |
		    sct4 & sr_op |
		    lbt1 | dbt5 |
		    mpt2 & ir[6] | mpt4 |
		    div_t5 |
		    nrt99 |
		    fdt8_del & ir_fdv_NOT_l |
		    fdt14),
		.p(st0));
	pa s_pa2(.clk(clk), .reset(reset),
		.in(et2b_del & ~st_inh |
		    et0_del & ~e_long_OR_st_inh |
		    st0_D),
		.p(st1));
	pa s_pa3(.clk(clk), .reset(reset),
		.in(st1 & ex_pi_sync & sac_inh_OR_fm_en &
		          ~sce_OR_fce_pse & ~sar_ne_br_OR_sac2 |
		    blt_t2 |
		    mc_rst1 & byf4 & ir_ibp),
		.p(st1a));
	pa s_pa4(.clk(clk), .reset(reset),
		.in(mc_rst1 & sf1 |
		    st1 & sac_inh_OR_fm_en & sar_ne_br_OR_sac2),
		.p(st2));
	pa s_pa5(.clk(clk), .reset(reset),
		.in(st1 & sac_inh_OR_fm_en & fce_pse & ~sar_ne_br_OR_sac2 |
		    st2 & fce_pse),
		.p(st5));
	pa s_pa6(.clk(clk), .reset(reset),
		.in(st1 & sac_inh_OR_fm_en & sce & ~sar_ne_br_OR_sac2 |
		    st2 & ~fce_pse & sar_ne_br |
		    st2 & sce & ~sar_ne_br),	// SCE implies ~FCE PSE
		.p(st6));
	pa s_pa7(.clk(clk), .reset(reset),
		.in(mc_rst1 & sf6),
		.p(st6a));
	pa s_pa8(.clk(clk), .reset(reset),
		.in(st6a & sac2 |
		    st2 & ~sce_OR_fce_pse & ~sar_ne_br & sac2),
		.p(st7));
	pa s_pa9(.clk(clk), .reset(reset), .in(st7_D), .p(st8));
	pa s_pa10(.clk(clk), .reset(reset),
		.in(st1 & ~ex_pi_sync & sac_inh_OR_fm_en &
		          ~sce_OR_fce_pse & ~sar_ne_br_OR_sac2 |
		    st1a |
		    st2 & ~sce_OR_fce_pse & ~sar_ne_br_OR_sac2 |
		    st6a & ~sac2 |
		    st8 & mc_fm_en |
		    mc_rst1 & sf8 |
		    mc_illeg_adr_del & ~if0 |
		    dst7),
		.p(st9));

	wire st0_D, st1_D, st7_D;
	dly90ns s_dly1(.clk(clk), .reset(reset), .in(st0), .p(st0_D));
	dly90ns s_dly2(.clk(clk), .reset(reset), .in(st1), .p(st1_D));
	dly115ns s_dly3(.clk(clk), .reset(reset), .in(st7), .p(st7_D));

	always @(posedge clk) begin
		if(mr_clr) begin
			sf1 <= 0;
			sf6 <= 0;
			sf8 <= 0;
		end
		if(st1 & ~sac_inh_OR_fm_en)
			sf1 <= 1;
		if(st2)
			sf1 <= 0;
		if(st5 | st6)
			sf6 <= 1;
		if(st6a)
			sf6 <= 0;
		if(st8 & ~mc_fm_en)
			sf8 <= 1;
		if(st9)
			sf8 <= 0;
	end


	/* PI */
	reg pi_act;
	reg pi_ov;
	reg pi_cyc;
	reg [1:7] pih;
	reg [1:7] pir;
	reg [1:7] pio;
	wire [1:7] pi_req = pir & ~pih & pi_ok;
	wire [1:7] pi_ok = { pi_act, ~pir[1:6] & ~pih[1:6] & pi_ok[1:6] };
	wire [32:34] pi_enc;
	wire pi_rq = (pi_req != 0) & ~pi_cyc & ~key_pi_inh;
	wire pi_data_io = iot_datao | iot_datai;
	wire pi_sel = bio_pi_sel;
	wire pi_status = pi_sel & iob_status;
	// Accept (hold) PI request by any non-IO instruction or
	// a DATA/BLK instruction in the first slot.
	// If we don't but are in a PI cycle, we'll stay in there!
	wire pi_hold = pi_cyc & (~ir_iot | ~pi_ov & pi_data_io);
	// Dismiss PI request with a JRST 10,
	// or if we do IO in the first slot.
	// This means a DATA/BLK in the first slot will hold AND dismiss a PI request
	wire pi_restore = ir_jrst & ir[9] |
		 pi_cyc & ~pi_ov & pi_data_io;
	wire pi_ov_en = pi_cyc | key_rim;

	wire pi_reset =
		mr_start |
		iot_cono_clr & pi_sel & iob[23];
	wire pi_cono_set = iot_cono_set & pi_sel;
	wire pio_set = pi_cono_set & iob[25];
	wire pio_clr = pi_cono_set & iob[26];
	wire pir_fm_iob1 = pi_cono_set & iob[24];
	wire pir_stb = mc_rq_pulse & ~pi_cyc;
	wire pih_fm_pi_chrq = ft9 & pi_hold;
	wire pi_ok_clrs_pih = et0 & pi_restore;
	wire pi_t0;

	assign pi_enc[32] = pi_req[4] | pi_req[5] | pi_req[6] | pi_req[7];
	assign pi_enc[33] = pi_req[2] | pi_req[3] | pi_req[6] | pi_req[7];
	assign pi_enc[34] = pi_req[1] | pi_req[3] | pi_req[5] | pi_req[7];

	wire [18:35] pi_iob = {
		cpa_pwr_fail, cpa_par_err, cpa_par_enb,
		pih, pi_act, pio };

	pa pi_pa0(.clk(clk), .reset(reset),
		.in(it1 & pi_rq |
		    st9 & pi_ov),
		.p(pi_t0));
	wire pi_t0_D;
	dly90ns pi_dly0(.clk(clk), .reset(reset), .in(pi_t0), .p(pi_t0_D));

	always @(posedge clk) begin
		if(mr_start) begin
			pi_ov <= 0;
			pi_cyc <= 0;
		end
		if(st1 & pi_hold)
			pi_cyc <= 0;
		if(pi_t0)
			pi_cyc <= 1;
		if(st1 & pi_hold | key_rdi_done)
			pi_ov <= 0;
		if(et0 & iot_blk & pi_ov_en & ad_cry[0])
			pi_ov <= 1;
		if(pi_reset) begin
			pih <= 0;
			pir <= 0;
			pio <= 0;
			pi_act <= 0;
		end else if(pir_stb)
			pir <= pir | iob_pi & pio;
		else if(pir_fm_iob1)
			pir <= pir | iob[29:35];
		else
if(pih)
			pir <= pir & ~pih;
		if(pih_fm_pi_chrq)
			pih <= pih | pi_req;
		if(pi_ok_clrs_pih)
			pih <= pih & ~pi_ok;
		if(pi_cono_set) begin
			if(iob[27] &  pi_act) pi_act <= 0;
			if(iob[28] & ~pi_act) pi_act <= 1;
		end
		if(pio_clr & ~pio_set)
			pio <= pio & ~iob[29:35];
		if(~pio_clr & pio_set)
			pio <= pio | iob[29:35];
		if(pio_clr & pio_set)
			pio <= pio ^ iob[29:35];
	end


	/* EX */
	reg ex_user;
	reg ex_ill_op;
	reg ex_pi_sync;
	reg ex_mode_sync;
	reg ex_iot_user;
	wire ex_clr = mr_start | iot_datao_clr & bio_cpa_sel;
	wire ex_set = iot_datao_set & bio_cpa_sel;
	wire ex_allow_iots = ex_iot_user | ~ex_user;
	wire ex_trap_cond = ex_pi_sync | ex_ill_op;
	wire ex_rel = ex_user & ~ex_trap_cond &
		~ma18_31_eq_0 & ~mai_fma_sel &
		~key_f1;
	wire ex_non_rel_uuo = ir_uuo &
		(~ex_user | ir[2] | ir[3] | ir[4:8] == 0);

	always @(posedge clk) begin
		if(mr_start) begin
			ex_user <= 0;
			ex_ill_op <= 0;
			ex_iot_user <= 0;
		end
		if(mr_clr) begin
			if(~pi_cyc)	// REV
				ex_pi_sync <= 0;
			ex_mode_sync <= 0;
		end else if(pi_cyc)
			ex_pi_sync <= 1;

		if(et0_del & ex_trap_cond & ar_fm_pcJ_et0)
			ex_user <= 0;
		if(mr_clr & ex_mode_sync)
			ex_user <= 1;

		if(et0 & ex_non_rel_uuo)
			ex_ill_op <= 1;
		if(et0_del & ar_fm_pcJ_et0 |
		   et0 & iot_blk)
			ex_ill_op <= 0;

		if(arf_flags_fm_brJ) begin
			if(~br[6])
				ex_iot_user <= 0;
			else if(br[6] & ~ex_user)
				ex_iot_user <= 1;
		end
		if(arf_flags_fm_brJ & br[5] |
		   et0 & ir_jrst & ir[12])
			ex_mode_sync <= 1;
	end

	/* PR RL */
	reg [18:25] pr;
	reg [18:25] prb;
	reg [18:25] rl;
	reg [18:25] rlb;
	reg pr_wr_prot;
	wire [18:25] rla = rl + ma[18:25];
	wire [18:25] rlc = rlb + ma[18:25];

	wire pr1_ill_adr = ma[18:25] > pr;
	wire pr2_ill_adr = ma[18:25] > prb;
	// Addresses in the upper half of memory can
	// be protected and relocated by a second pair
	// of registers, PRB/RLB.
	// Both PR and PRB count words starting at location 0.
	wire pra_ill_adr =
		ex_rel &
		pr1_ill_adr &
		(pr2_ill_adr | ~ma[18] | pr_wr_prot) &
		(pr2_ill_adr | ~ma[18] | mc_wr);

	always @(posedge clk) begin
		if(ex_clr) begin
			pr <= 0;
			prb <= 0;
			pr_wr_prot <= 0;
			rl <= 0;
			rlb <= 0;
		end
		if(ex_set) begin
			pr <= iob[0:7];
			prb <= iob[9:16];
			pr_wr_prot <= iob[17];
			rl <= iob[18:25];
			rlb <= iob[27:34];
		end
	end


	/* CPA */
	reg cpa_pwr_fail;
	reg cpa_adr_break;
	reg cpa_par_err;
	reg cpa_par_enb;
	reg cpa_pdl_ov;
	reg cpa_mem_prot_flag;
	reg cpa_non_ex_mem;
	reg cpa_clk_en;
	reg cpa_clk_flag;
	reg cpa_fov_en;
	reg cpa_ar_ov_en;
	reg [33:35] cpa_pia;

	wire cpa_req_enable =	// not named
		cpa_pwr_fail |
		cpa_adr_break |
		cpa_par_enb & cpa_par_err |
		cpa_pdl_ov |
		cpa_mem_prot_flag |
		cpa_non_ex_mem |
		cpa_clk_en & cpa_clk_flag |
		cpa_fov_en & ar_fov |
		cpa_ar_ov_en & ar_ov_flag;
	wire [1:7] cpa_req = { cpa_req_enable, 7'b0 } >> cpa_pia;
	wire cpa_status = bio_cpa_sel & iob_status;

	wire cpa_pdl_ov_set =
		et0 & (ir_push | ir_pushj) & ad_cry[0] |
		et0 & ir_pops & ~ad_cry[0];
	wire cpa_cono_set = iot_cono_set & bio_cpa_sel;

	wire [18:35] cpa_iob = {
		1'b0, cpa_pdl_ov, ex_iot_user,
		cpa_adr_break, cpa_mem_prot_flag, cpa_non_ex_mem,
		1'b0, cpa_clk_en, cpa_clk_flag,
		1'b0, cpa_fov_en, ar_fov,
		ma_trap_offset, cpa_ar_ov_en, ar_ov_flag,
		cpa_pia };

	wire cpa_adr_break_set;
	dcd cpa_dcd(.clk(clk), .reset(reset),
		.p(mc_adr_break_set), .l(1'b1),
		.q(cpa_adr_break_set));

	wire cpa_pwr_clk;
	clk60hz cpa_clk(.clk(clk), .outclk(cpa_pwr_clk));

	always @(posedge clk) begin
		if(mr_start) begin
			cpa_pwr_fail <= 0;
			cpa_adr_break <= 0;
			cpa_par_err <= 0;
			cpa_par_enb <= 0;
			cpa_pdl_ov <= 0;
			cpa_mem_prot_flag <= 0;
			cpa_non_ex_mem <= 0;
			cpa_clk_en <= 0;
			cpa_clk_flag <= 0;
			cpa_fov_en <= 0;
			cpa_ar_ov_en <= 0;
			cpa_pia <= 0;
		end
		if(cpa_pdl_ov_set)
			cpa_pdl_ov <= 1;
		if(mc_non_ex_mem)
			cpa_non_ex_mem <= 1;
		if(mc_illeg_adr)
			cpa_mem_prot_flag <= 1;
		if(cpa_adr_break_set)
			cpa_adr_break <= 1;
		if(cpa_cono_set) begin
			if(iob[18]) cpa_pdl_ov <= 0;
			if(iob[21]) cpa_adr_break <= 0;
			if(iob[22]) cpa_mem_prot_flag <= 0;
			if(iob[23]) cpa_non_ex_mem <= 0;
			if(iob[24] &  cpa_clk_en) cpa_clk_en <= 0;
			if(iob[25] & ~cpa_clk_en) cpa_clk_en <= 1;
			if(iob[26]) cpa_clk_flag <= 0;
			if(iob[27] &  cpa_fov_en) cpa_fov_en <= 0;
			if(iob[28] & ~cpa_fov_en) cpa_fov_en <= 1;
			// AR FOV cleared in ARF
			if(iob[30] &  cpa_ar_ov_en) cpa_ar_ov_en <= 0;
			if(iob[31] & ~cpa_ar_ov_en) cpa_ar_ov_en <= 1;
			// AR OV cleared in ARF
			cpa_pia <= iob[33:35];
		end
		if(pi_cono_set) begin
			if(iob[18]) cpa_pwr_fail <= 0;
			if(iob[19]) cpa_par_err <= 0;
			if(iob[20] &  cpa_par_enb) cpa_par_enb <= 0;
			if(iob[21] & ~cpa_par_enb) cpa_par_enb <= 1;
		end

		if(~key_sing_inst & cpa_pwr_clk)
			cpa_clk_flag <= 1;
	end


	/* MQ */
	reg [0:35] mq;
	wire mq_clr = mr_clr | ft6 | nrt7;
	wire mq_fm_adJ =
		et0 & mq_fm_adJ_et0 |
		et1 & (ir_idiv | jffo_f1) |
		et2 & ir_blt |
		ft4 | ft7 | ft4a |
		dbt2 |
		mst0 |
		div_t0 & ar[0] |
		div_t1 |
		dst5 |
		nlt1 | nlt4 |
		fdt13;
	wire mq_sh_lt =
		et2 & ir_idiv |
		jffo_t1 |
		sct3 & (sr_go_left | db_byte_dep | dsf1 | byf4) |
		div_t4 |
		dst3 |
		nrt2 & ~ir_fdvx;
	wire mq_sh_rt =
		sct3 & (sr_go_right | msf1 | faf1) |
		mpt2 |
		nrt10 & ~ir_fdvx |
		fdt3;

	wire mq_fm_adJ_et0 = ir_pops | ir_pushj;

	always @(posedge clk) begin
		if(mq_clr)
			mq <= 0;
		if(mq_fm_adJ)
			mq <= ad;
		if(et0 & jffo_swap) begin
			mq[31] <= 1;
			mq[34] <= 1;
		end
		if(mq_sh_lt)
			mq <= { mq0_sh_lt_inp, mq[2:7],
				mq7_sh_lt_inp, mq[9:35],
				mq35_sh_lt_inp };
		if(mq_sh_rt)
			mq <= { mq0_sh_rt_inp,
				mq1_sh_rt_inp, mq[1:6],
				mq8_sh_rt_inp, mq[8:34] };
		if(fmt3)
			mq[35] <= 0;
	end

	/* AR-MQ shift connections */
	wire armq_fp_sh_en = ir_fp | ir_ufa | ir_fsc;
	wire armq_byte_mask = byte_ptr_inc | byte_ptr_not_inc;
	wire armq_preserve_sign = (ir_ash | ir_ashc | armq_fp_sh_en) & ~dsf1;
	wire armq_mul_OR_ashx_OR_fp = armq_preserve_sign | msf1;
	wire armq_ar35_fm_mq0_en = ir_lshc | ir_rotc | ir_xdiv;
	wire armq_fdv_norm = ir_fdvx & ~dsf1;
	wire armq_lrc_OR_mul = ir_lshc | ir_rotc | msf1;
	wire armq_ashc_OR_mul_last = ir_ashc | ir_xmul & ~msf1;

	wire ar0_sh_lt_inp = armq_preserve_sign & ad[0] | ~armq_preserve_sign & ad[1];
	wire ar35_sh_lt_inp =
		ir_rot & ad[0] |
		armq_ar35_fm_mq0_en & mq[0] |
		ir_ashc & mq[1] |
		armq_fp_sh_en & ~armq_fdv_norm & mq[8];
	wire ar0_sh_rt_inp =
		armq_mul_OR_ashx_OR_fp & ad[0] |
		ir_rot & ad[35] |
		ir_rotc & mq[35];

	wire mq0_sh_lt_inp = mq[1] & ~ir_ashc | ad[0] & ir_ashc;
	wire mq7_sh_lt_inp = mq[8] & ~armq_fp_sh_en;
	wire mq35_sh_lt_inp = armq_byte_mask | ad[0] & ir_rotc | ~ad[0] & dsf1;
	wire mq0_sh_rt_inp =
		armq_lrc_OR_mul & ~armq_fp_sh_en & ad[35] |
		armq_ashc_OR_mul_last & ~armq_fp_sh_en & ad[0];
	wire mq1_sh_rt_inp = ir_ashc & ad[35] | ~ir_ashc & mq[0];
	wire mq8_sh_rt_inp = armq_fp_sh_en & ad[35] | ~armq_fp_sh_en & mq[7];


	/* AR */
	reg [0:35] ar;
	wire ar_clr =	// this signal isn't explicitly named
		et0 & (iot_datai | iot_coni | iot_consx) |
		mc_rd_rq_pulse |
		mc_rdwr_rq_pulse |
		kt1 | at1 |
		ft2 | ft4 |
		mst1 |
		nlt1 & scad[0] |
		fat4 |
		fdt9 |
		fdt12 & ~ar0_eq_scad0;
	wire arlt_clr =
		ar_clr |
		et0 & hwt_arlt_clr_et0 |
		et1 & ir_idiv |
		at3 |
		blt_t1;
	wire arrt_clr =
		ar_clr |
		et1 & ir_idiv |
		et0 & hwt_arrt_clr_et0;
	wire ar_sh_lt =
		sct3 & (db_byte_dep | sr_go_left | dsf1) |
		nrt2 |
		et2 & ir_idiv;	// later addition
	wire ar_sh_rt =
		sct3 & (lb_byte_load | sr_go_right | msf1 | faf1) |
		nrt10 | nlt2 |
		fdt3 |
		fdt6 & ir[6];
	wire ar_fm_ds1 =
		kt2 & key_dep_OR_dep_nxt_OR_exe |
		iot_t3 & bio_cpa_sel & iob_datai;
	wire ar_fm_pcJ =
		et0 & ar_fm_pcJ_et0 |
		et1 & ir_jsa |
		knt1 |
		knt3;
	wire arrt_fm_pcJ = ar_fm_pcJ;
	wire arlt_fm_ir1 = et0 & ir_uuo;
	wire arlt_fm_flagsJ = et0 & ar_fm_flags_et0;
	wire ar_fm_fm1 =
		at2 & mc_fm_en |
		ft3 & mc_fm_en |
		ft5 |
		fmat1 & mc_rd |
		fdt10;
	wire ar_fm_iob1 = iot_t3;
	wire ar_swap = ft6 | ft8;
	wire arlt_fm_arrtJ =
		ar_swap |
		et0 & arlt_fm_arrt_et0 |
		et1 & arlt_fm_arrt_et1 |
		et2 & ar_swap_et2;
	wire arrt_fm_arltJ =
		ar_swap |
		et0 & arrt_fm_arlt_et0 |
		et1 & arrt_fm_arlt_et1 |
		et2 & ar_swap_et2;
	wire ar_fm_adJ =
		st2 & sar_ne_br |
		byt2 |
		dbt3 |
		mpt2 |
		div_t3 |
		dst3 |
		dst4 & ~mq[35] |
		div_t5 & dsf7_XOR_br0 |
		nrt7 |
		fmt3 |
		fat3a | fat8 |
		fdt8 & (dsf7 ^ br[0]) |
		fdt14;
	wire arlt_fm_adJ =
		ar_fm_adJ |
		et0 & arlt_fm_adJ_et0 |
		et1 & arlt_fm_adJ_et1;
	wire arrt_fm_adJ =
		ar_fm_adJ |
		et0 & arrt_fm_adJ_et0 |
		et1 & arrt_fm_adJ_et1 |
		at3 & af2 |
		jffo_t1;
	wire ar_fm_ad0 =
		et0 & ar_fm_ad0_et0 |
		et1 & ar_fm_ad0_et1 |
		et2 & ar_fm_adJ_et2;
	wire ar_fm_ad1 =
		et0 & ar_fm_ad1_et0 |
		et1 & ar_fm_ad1_et1 |
		et2 & ar_fm_adJ_et2 |
		dbt5;
	wire arlt_fm_ad0 = arlt_fm_adJ | ar_fm_ad0;
	wire arlt_fm_ad1 = arlt_fm_adJ | ar_fm_ad1;
	wire arrt_fm_ad0 = arrt_fm_adJ | ar_fm_ad0;
	wire arrt_fm_ad1 = arrt_fm_adJ | ar_fm_ad1;
	wire ar_fm_mqJ =
		st7 |
		blt_t3 |
		ft4a |
		dbt2 |
		mpt4 |
		div_t0 & ar[0] |
		div_t1 |
		dst5 |
		nlt1 & ~scad[0] |
		nlt4 |
		fdt11;
	wire ar_fm_mq0 =
		ar_fm_mqJ |
		et0 & ir_pops |
		et1 & ar_fm_mqJ_et1 |
		et2 & ar_fm_mqJ_et2 |
		lbt1 |
		dbt4;
	wire ar_fm_mq1 =
		ar_fm_mqJ |
		et0 & ir_pops |
		et1 & ar_fm_mqJ_et1 |
		et2 & ar_fm_mqJ_et2;
	wire arlt_fm_mq0 = ar_fm_mq0;
	wire arlt_fm_mq1 = ar_fm_mq1;
	wire arrt_fm_mq0 = ar_fm_mq0 | blt_t1;
	wire arrt_fm_mq1 = ar_fm_mq1 | blt_t1;
	wire ar0_5_fm_scad3_8J = byt4;
	wire ar1_8_fm_scad1_8J =
		et1 & ir_dfn |
		nrt5 |
		nlt3 & ad[9:35] != 0 |
		fdt12 & ar0_eq_scad0 & ~ad_eq_0;
	wire ar1_8_fm_ar0J =
		et1 & ir_fsc |
		fpt3 |
		fat5;
	wire ari_dfn_clr = ir_dfn & ~scad[0];
	wire ari_dfn_set = ir_dfn & scad[0];

	wire ar_fm_adJ_et0 =
		ir_as | ir_exch | ir_3xx | ir_aobjp | ir_aobjn | ir_push |
		iot_blk | ir_jra | ir_movnx |
		ar[0] & (ir_movmx | ir_idiv | ir_fdv_NOT_l) |
		ir_dfn | ir_boole_0 | ir_boole_6 |
		ir_boole_11 | ir_boole_12 | ir_boole_14;
	wire ar_fm_ad0_et0 =
		ar_fm_adJ_et0 |
		ir_boole_1 | ir_boole_4 | ir_boole_13 | ir_boole_16;
	wire ar_fm_ad1_et0 =
		ar_fm_adJ_et0 |
		ir_boole_2 | ir_boole_7 | ir_boole_10 | ir_boole_15 | ir_boole_17;
	wire arlt_fm_arrt_et0 =
		ir_movsx | ir_test_swap |
		hwt_lt_fm_rt_et0 | iot_cono |
		ir_blt | jffo_swap;
	wire arrt_fm_arlt_et0 =
		ir_movsx | ir_test_swap |
		hwt_rt_fm_lt_et0 |
		ir_blt | jffo_swap;
	wire arlt_fm_adJ_et0 = hwt_arlt_fm_adJ_et0 | ir_fsb;
	wire arrt_fm_adJ_et0 = hwt_arrt_fm_adJ_et0 | ir_fsb;
	wire ar_fm_pcJ_et0 = ir_pushj | ir_jsa | ir_jsp | ir_jsr | ir_jrst;
	wire ar_fm_flags_et0 = ir_jsr | ir_jsp | ir_pushj;

	wire arlt_fm_arrt_et1 = hwt_lt_fm_rt_et1 | ir_jsa;
	wire arrt_fm_arlt_et1 = hwt_rt_fm_lt_et1;
	wire arlt_fm_adJ_et1 = hwt_e_long & ir[3];
	wire arrt_fm_adJ_et1 = hwt_e_long & ~ir[3];
	wire ar_fm_ad0_et1 = ir_pop | ir_txzx | ir_txcx;
	wire ar_fm_ad1_et1 = ir_pop | ir_txcx | ir_txox;
	wire ar_fm_mqJ_et1 = ir_popj | ir_jra | ir_pushj | jffo_f1;

	wire ar_fm_adJ_et2 = ir_boole | ir_dfn;
	wire ar_swap_et2 = ir_test_swap | ir_jsa;
	wire ar_fm_mqJ_et2 = ir_pop | ir_blt;

	wire ar0_eq_br0 = ar[0] == br[0];
	wire ar0_eq_scad0 = ar[0] == scad[0];

	always @(posedge clk) begin: arctl
		integer i;
		if(arlt_fm_ir1)
			ar[0:12] <= ar[0:12] | ir[0:12];
		if(ar_fm_iob1)
			ar <= ar | iob;
		if(ar_fm_ds1)
			ar <= ar | ds;
		if(arlt_clr)
			ar[0:17] <= 0;
		if(arrt_clr)
			ar[18:35] <= 0;
		if(arlt_fm_arrtJ)
			ar[0:17] <= ar[18:35];
		if(arrt_fm_arltJ)
			ar[18:35] <= ar[0:17];
		if(ar_sh_lt)
			ar <= { ar0_sh_lt_inp, ad[2:35], ar35_sh_lt_inp };
		if(ar_sh_rt)
			ar <= { ar0_sh_rt_inp, ad[0:34] };
		if(arlt_fm_flagsJ) begin
			ar[0:6] <= { ar_ov_flag, ar_cry0_flag, ar_cry1_flag, ar_fov,
				byf6, ex_user, ex_iot_user };
			ar[11:12] <= { ar_fxu, ar_dck };
		end
		if(arrt_fm_pcJ)
			ar[18:35] <= pc;
		for(i = 0; i < 18; i = i+1) begin
			if(arlt_fm_ad0 & ~ad[i])
				ar[i] <= 0;
			if(arlt_fm_ad1 & ad[i])
				ar[i] <= 1;
			if(arrt_fm_ad0 & ~ad[i+18])
				ar[i+18] <= 0;
			if(arrt_fm_ad1 & ad[i+18])
				ar[i+18] <= 1;
			if(arlt_fm_mq0 & ~mq[i])
				ar[i] <= 0;
			if(arlt_fm_mq1 & mq[i])
				ar[i] <= 1;
			if(arrt_fm_mq0 & ~mq[i+18])
				ar[i+18] <= 0;
			if(arrt_fm_mq1 & mq[i+18])
				ar[i+18] <= 1;
		end

		if(ar0_5_fm_scad3_8J)
			ar[0:5] <= scad[3:8];
		if(ar1_8_fm_scad1_8J) begin
			ar[1:8] <= scad[1:8];
			if(ari_dfn_clr)
				ar[0] <= 0;
			if(ari_dfn_set)
				ar[0] <= 1;
		end
		if(ar1_8_fm_ar0J)
			ar[1:8] <= {8{ar[0]}};

		// ORDER important
		if(mc_rd)
			ar <= ar | membus_mb_in;
		if(ar_fm_fm1)
			ar <= ar | fm;
	end

	/* ARF */
	reg ar_ov_flag;
	reg ar_cry0_flag;
	reg ar_cry1_flag;
	reg ar_fov;
	reg ar_fxu;
	reg ar_dck;
	reg ar_fxu_hold;	// later addition
	wire ar_ov_cond = ad_cry[0] ^ ad_cry[1];
	wire ar0_XOR_ar1 = ar[0] ^ ar[1];
	wire arf_flags_fm_brJ = et0 & ir_jrst & ir[11];
	wire ar_jfcl_clr = et0 & ir_jfcl;
	wire arf_cry_stb =
		et0 & (ir_as | ir_3xx & ir[3] | ar_fm_adJ_et0 & ir_21x);
	wire ar_ov_set =
		mpt2 & ad[0] & mpf2 |
		mpt4 & ~ad_eq_0 |
		sct3 & ar0_XOR_ar1 & sr_go_left & ir_24x & ir[7:8] == 0 |
		dst7 |
		nrt4 & ~sc[0];

	always @(posedge clk) begin
		if(mr_start) begin
			ar_ov_flag = 0;
			ar_cry0_flag = 0;
			ar_cry1_flag = 0;
			ar_fov = 0;
			ar_fxu = 0;
			ar_dck = 0;
		end
		if(arf_cry_stb & ar_ov_cond | ar_ov_set)
			ar_ov_flag <= 1;
		if(arf_cry_stb & ad_cry[0])
			ar_cry0_flag <= 1;
		if(arf_cry_stb & ad_cry[1])
			ar_cry1_flag <= 1;
		if(ar_jfcl_clr & ir[9])
			ar_ov_flag <= 0;
		if(ar_jfcl_clr & ir[10])
			ar_cry0_flag <= 0;
		if(ar_jfcl_clr & ir[11])
			ar_cry1_flag <= 0;
		if(ar_jfcl_clr & ir[12])
			ar_fov <= 0;
		if(ar_ov_set & (ir_fp | ir_13x))
			ar_fov <= 1;
		if(dst7)
			ar_dck <= 1;
		// REV: no AR FXU HOLD in earlier revisions
		if(mr_clr)
			ar_fxu_hold <= 0;
		if(nrt1 & ~nrf1 & sc_sc0_XOR_sc1 |
		   fdt4 & sc_sc0_XOR_sc1)
			ar_fxu_hold <= 1;
		if(nrt4 & ~sc[0] & ~ar_fxu_hold)
			ar_fxu <= 1;
		if(arf_flags_fm_brJ) begin
			ar_ov_flag <= br[0];
			ar_cry0_flag <= br[1];
			ar_cry1_flag <= br[2];
			ar_fov <= br[3];
			ar_fxu <= br[11];
			ar_dck <= br[12];
		end
		if(cpa_cono_set) begin
			if(iob[29]) ar_fov <= 0;
			if(iob[32]) ar_ov_flag <= 0;
		end
	end


	/* BR */
	reg [0:35] br;
	wire br_fm_ar0 =
		br_fm_arJ |
		et1 & ir_test |
		iot_t4 & iot_consx |
		dbt3;
	wire br_fm_ar1 = br_fm_arJ;
	wire br_fm_arJ =
		et0 & br_fm_arJ_et0 |
		et1 & br_fm_arJ_et1 |
		et2 & ir_dfn |
		at1 | at3 |
		ft1a & ~ir_jrst |
		dbt2 |
		mst0 |
		fat3a |
		fdt9;
	wire br1_8_clr = (fpt3 | fat7) & ~br[0];
	wire br1_8_set = (fpt3 | fat7) & br[0];

	wire br_fm_arJ_et0 = ir_jsa | ir_exch | ir_fsb |
		hwt_e_long | ir_dfn | ir_fsc;
	wire br_fm_arJ_et1 = ir_pushj | ir_pop;

	always @(posedge clk) begin: brctl
		integer i;
		for(i = 0; i < 36; i = i+1) begin
			if(br_fm_ar0 & ~ar[i])
				br[i] <= 0;
			if(br_fm_ar1 & ar[i])
				br[i] <= 1;
		end
		if(br1_8_clr)
			br[1:8] <= 0;
		if(br1_8_set)
			br[1:8] <= 8'o377;
	end


	/* AD */
	reg ad_ar_p_en;
	reg ad_ar_m_en;
	reg ad_br_p_en;
	reg ad_br_m_en;
	reg ad_cry_ins;
	reg ad_p1_lh;
	reg ad_m1_lh;
	reg ad_cry_36;

	wire ad_cry_allow =
		ad_ar_p_en & ad_br_p_en |
		ad_ar_p_en & ad_br_m_en |
		ad_ar_m_en & ad_br_p_en |
		ad_ar_m_en & ad_br_m_en |
		ad_cry_36;
	wire ad_cond = ad[0] ^ (ad_cry[0] ^ ad_cry[1]);
	wire ad_md_p =
		msf1 & mq[35] & ~mq[34] |
		dsf1 & (ad[0] ^ br[0]);
	wire ad_md_m =
		msf1 & ~mq[35] & mq[34] |
		dsf1 & (ad[0] == br[0]);

	wire ad_ar_p_en_clr =
		ft9 & ~ad_ar_p_en_ft9 |
		et0 & ad_br_p_only_en_et0 |
		et1 & ir_test |
		et2 & ~st_inh |
		st0 |
		dbt1 |
		dst4 & dsf7 |
		dst5 & ir[1] |
		fdt7 | fdt13;
	wire ad_ar_p_en_set =
		mr_clr |
		et0 & ir_idiv |
		sct0 |
		div_t1 |
		dst1 |
		dst5 & ~ir[1] |
		nrt0 |
		fat4 |
		fdt1 | fdt8;
	wire ad_ar_m_en_clr =
		et0 & ad_br_p_only_en_et0 |
		et0 & ir_idiv |
		et2 & ~st_inh |
		st0 |
		sct0 |
		dbt3 |
		div_t1 |
		dst5 & ~ir[1] |
		fpt3 |
		fdt8;
	wire ad_ar_m_en_set =
		ft9 & ad_ar_m_en_ft9 |
		et1 & ir_boole |
		dbt2 |
		dst4 & dsf7 |
		dst5 & ir[1] |
		fdt7;

	wire ad_br_p_en_clr =
		at3 |
		et1 & ir_boole |
		sct3 & ~ad_md_p |
		dbt2 |
		mst1 |
		mpt3 |
		dst3 & ~ad_md_p |
		dst4 |
		nrt0 |
		fat5 |
		fdt2;
	wire ad_br_p_en_set =
		mr_clr | at4 |
		ft9 & ad_br_p_en_ft9 |
		et0 & ad_br_p_only_en_et0 |
		et1 & ir_test |
		et2 & ~st_inh |
		st0 |
		iot_t3 |
		sct3 & ad_md_p |
		byt7a |
		dbt1 | dbt3 |
		dst1 & br[0] |
		dst3 & ad_md_p |
		fmt1 |
		fat1 | fat6 |
		fdt1 & br[0] |
		fdt13;
	wire ad_br_m_en_clr =
		mr_clr |
		et0 & ad_br_p_only_en_et0 |
		et1 & (ir_boole | ir_test) |
		et2 & ~st_inh |
		st0 |
		blt_t3 |
		sct3 & ~ad_md_m |
		mst1 & ~mq[35] |
		mpt3 |
		dst3 & ~ad_md_m |
		dst4 |
		nrt0 |
		fat1 |
		fdt2;
	wire ad_br_m_en_set =
		ft9 & ad_br_m_en_ft9 |
		blt_t1 |
		sct3 & ad_md_m |
		mst1 & mq[35] |
		dst1 & ~br[0] |
		dst3 & ad_md_m |
		fdt1 & ~br[0];

	wire ad_clr = mr_clr | dst1;
	wire ad_cry_ins_clr = et1 | st0;
	wire ad_cry_ins_set =
		ft9 & ad_cry_ins_ft9 |
		mpt3 & ar[0];
	wire ad_cry36_clr =
		et0 & (ir_idiv | ad_br_p_only_en_et0) |
		et0 & ir_dfn & ad[9:35] != 0 |
		et2 & ~st_inh |
		st0 |
		blt_t1 |
		sct3 & ~ad_md_m |
		byt7a |
		mst1 & ~mq[35] |
		mpt3 |
		div_t1 & ~div_low_zero_cond |
		dst3 & ~ad_md_m |
		dst4 & ~dsf7 |
		nrt0 |
		fpt3 |
		fat1 |
		fdt2 | fdt8;
	wire ad_cry36_set =
		ft9 & ad_cry36_ft9 |
		et1 & jffo_f1 |
		sct3 & ad_md_m |
		mst1 & mq[35] |
		div_t0 & ar[0] |
		dst1 & ~br[0] |
		dst3 & ad_md_m |
		dst4 & dsf7 |
		dst5 |
		nrt6 |
		fdt1 & ~br[0] |
		fdt7;

	wire [0:35] ad_cry_kill = {
		5'b0, ~ad_cry_allow,
		8'b0, ~ad_cry_allow,
		8'b0, ~ad_cry_allow,
		8'b0, ~ad_cry_allow,
		3'b0 };
	wire [0:35] ad_ar_inp = {36{ad_ar_p_en}} & ar | {36{ad_ar_m_en}} & ~ar;
	wire [0:35] ad_br_inp =
		({36{ad_br_p_en}} & br | {36{ad_br_m_en}} & ~br) &
		 ~{ 17'b0, ad_m1_lh, 18'b0 } |
		{ 17'b0, ad_p1_lh, 18'b0 };

	wire [0:35] ad;
	wire [0:36] ad_cry;
	assign ad_cry[36] = ad_cry_36;
	genvar i;
	generate
		for(i = 0; i < 36; i = i + 1) begin : adgen
			adr ad_adr(ad_ar_inp[i], ad_br_inp[i],
				ad_cry[i+1], ad_cry_ins, ad_cry_kill[i],
				ad[i], ad_cry[i]);
		end
	endgenerate

	wire ad_eq_0 = ad == 0;

	/* All crazy levels for FT9 */
	wire ad_inc_both_ft9 = ir_aobjp | ir_aobjn |
		ir_push | ir_pushj |
		iot_blk | ir_blt;
	wire ad_ar_negate_ft9 = ir_21x | ir_idiv | ir_fdv_NOT_l;
	wire ad_minus_br_ft9 = ir_sub | ir_fsb | ir_cax | ir_dfn;
	wire ad_br_pm_ft9 = ir_soxx | ir_pops | hwt_br_pm_en_ft9;
	wire ad_ar_p_en_ft9 = ad_inc_both_ft9 |
		ir_as | ir_3xx | ir_pops | ir_txcx |
		byte_ptr_inc | ir_jffo;
	wire ad_ar_m_en_ft9 = ad_ar_negate_ft9 |
		ir_boole_6 | ir_boole_11 | ir_boole_12 | ir_boole_17 |
		ir_div_OR_fdvl;
	wire ad_br_p_en_ft9 = ad_br_pm_ft9 |
		ir_add | ir_exch | ir_jsa | ir_jra | ir_txox | ir_hwt |
		ir_xmul | ir_boole_1 | ir_boole_6 | ir_boole_7 | ir_boole_10 | ir_boole_16;
	wire ad_br_m_en_ft9 = ad_br_pm_ft9 | ad_minus_br_ft9 |
		ir_txcx | ir_txzx | ir_boole_2 | ir_boole_4 |
		ir_boole_11 | ir_boole_13 | ir_boole_14 | ir_boole_15;
	wire ad_cry_ins_ft9 = ir_boole_6 | ir_boole_11 | ir_txcx;
	wire ad_cry36_ft9 = ad_inc_both_ft9 | ad_minus_br_ft9 |
		ad_ar_negate_ft9 | ir_aoxx | byte_ptr_inc;

	/* ET0 */
	wire ad_br_p_only_en_et0 = hwt_e_long | ir_pops |
		~e_long_OR_st_inh;


	always @(posedge clk) begin
		if(ad_clr) begin
			ad_cry_ins <= 0;
			ad_p1_lh <= 0;
			ad_m1_lh <= 0;
			if(~ad_cry36_set)	// happens at DST1
				ad_cry_36 <= 0;
		end
		if(ad_cry_ins_clr)
			ad_cry_ins <= 0;
		if(ad_cry_ins_set)
			ad_cry_ins <= 1;
		if(ad_cry36_clr)
			ad_cry_36 <= 0;
		if(ad_cry36_set)
			ad_cry_36 <= 1;
		if(et0 & ~ir_blt | et2)
			ad_p1_lh <= 0;
		if(ft9 & ad_inc_both_ft9)
			ad_p1_lh <= 1;
		if(et0)
			ad_m1_lh <= 0;
		if(ft9 & ir_pops)
			ad_m1_lh <= 1;
		if(ad_ar_p_en_clr) ad_ar_p_en <= 0;
		if(ad_ar_m_en_clr | ad_clr) ad_ar_m_en <= 0;
		if(ad_ar_p_en_set) ad_ar_p_en <= 1;
		if(ad_ar_m_en_set) ad_ar_m_en <= 1;
		if(ad_br_p_en_clr) ad_br_p_en <= 0;
		if(ad_br_m_en_clr) ad_br_m_en <= 0;
		if(ad_br_p_en_set) ad_br_p_en <= 1;
		if(ad_br_m_en_set) ad_br_m_en <= 1;
	end


	/* PC */
	reg [18:35] pc;
	wire pc_inc_inh =
		ir_xct | ir_uuo | iot_blk |
		ir_blt | pi_cyc | key_pi_inh |
		ir_134_7 & ~byf5;
	wire pc_cond_p =
		ir[6:8] == 4 |			// A
		~ir[6] & ir[7] & ad_eq_0 |	// E, LE; == 0
		ir[6] & ~ir[8] & ~ad_eq_0;	// A, N; != 0
	wire pc_cond_r =
		~ir[6] & ir[8] & ad[0] |	// L, LE; < 0
		ir[6] & ~ir[7] & ~ad[0] |	// A, GE; >= 0
		ir[6] & ~ad_eq_0 & ~ad[0];	// A, GE, N, G; > 0
	wire pc_cond_q =
		~ir[6] & ir[8] & ad_cond |	// L, LE; signed <
		ir[6] & ~ir[7] & ~ad_cond |	// A, GE; signed >=
		ir[6] & ~ad_eq_0 & ~ad_cond;	// A, GE, N, G; signed >

	wire pc_fm_ma =
		et0 & (pc_set_et0 | ir_jumps & (pc_cond_r | pc_cond_p)) |
		et2 & (ir_popj | ir_jra) |
		knt1 |
		knt3 |
		kt3 & key_start;
	wire pc_inc =
		et0 & ir_skips & (pc_cond_p | pc_cond_r) |
		et0 & ir_cax & (pc_cond_p | pc_cond_q) |
		et0 & iot_blk & ~pi_cyc & ~ad_cry[0] |
		et2 & pc_inc_et2 |
		ft9 & ~pc_inc_inh |
		knt2 |
		iot_t5 & (iot_conso & ~ad_eq_0 |
		          iot_consz & ad_eq_0) |
		blt_t2;

	wire pc_set_et0 =
		ir_aobjp & ~ad[0] |
		ir_aobjn & ad[0] |
		ir_jffo & ~ad_eq_0 |
		ar_fm_pcJ_et0 |
		ir_jfcl &
			(ir[9] & ar_ov_flag |
			 ir[10] & ar_cry0_flag |
			 ir[11] & ar_cry1_flag |
			 ir[12] & ar_fov);
	wire pc_inc_et2 =
		ir_test & (ir[6:7] == 1 & ad_eq_0 |
		           ir[6:7] == 2 |
		           ir[6:7] == 3 & ~ad_eq_0) |
		ir_jsr | ir_jsa;

	always @(posedge clk) begin
		if(pc_fm_ma)
			pc <= ma;
		if(pc_inc)
			pc <= pc + 1;
	end


	/* IR */
	reg [0:17] ir;
	reg ir_lt_en;
	reg ir_rt_en;
	wire ir_rdi_setup = kt3 & key_rdi;
	wire ir_lt_clr = mr_clr;
	wire ir_rt_clr = mr_clr | at4 | at6 & ir_134_7;

	wire ir_uuo = ir[0:1] == 0 &
			(ir_fp_trap_sw |
			 ir[2] == 0 |
			 ir[3] == 0 & (ir[4] == 0 | ir[5] == 0)) |
		ir_jrsta & ~ex_allow_iots & (ir[9] | ir[10]) |
		ir_iota & ~ex_allow_iots & ~ex_pi_sync;

	wire ir_0xx = ir[0:2] == 0;
	wire ir_1xx = ir[0:2] == 1;
	wire ir_2xx = ir[0:2] == 2;
	wire ir_3xx = ir[0:2] == 3;
	wire ir_boole = ir[0:2] == 4;
	wire ir_hwt = ir[0:2] == 5;
	wire ir_test = ir[0:2] == 6;
	wire ir_iota = ir[0:2] == 7;
	wire ir_iot = ir_iota & ~ir_uuo;

	wire ir_20x = ir_2xx & ir[3:5] == 0;
	wire ir_21x = ir_2xx & ir[3:5] == 1;
	wire ir_xmul = ir_2xx & ir[3:5] == 2;
	wire ir_xdiv = ir_2xx & ir[3:5] == 3;
	wire ir_24x = ir_2xx & ir[3:5] == 4;
	wire ir_25x = ir_2xx & ir[3:5] == 5;
	wire ir_26x = ir_2xx & ir[3:5] == 6;
	wire ir_as = ir_2xx & ir[3:5] == 7;

	wire ir_13x = ir[0:5] == 6'o13 & ~ir_uuo;
	wire ir_134_7 = ir_13x & ir[6];
	wire ir_ufa = ir_13x & ir[6:8] == 0;
	wire ir_dfn = ir_13x & ir[6:8] == 1;
	wire ir_fsc = ir_13x & ir[6:8] == 2;
	wire ir_ibp = ir_13x & ir[6:8] == 3;
	wire ir_ildb = ir_13x & ir[6:8] == 4;
	wire ir_ldb = ir_13x & ir[6:8] == 5;
	wire ir_idpb = ir_13x & ir[6:8] == 6;
	wire ir_dpb = ir_13x & ir[6:8] == 7;

	wire ir_fp = ir_1xx & ir[3] & ~ir_uuo;
	wire ir_fad = ir_fp & ir[4:5] == 0;
	wire ir_fsb = ir_fp & ir[4:5] == 1;
	wire ir_fmp = ir_fp & ir[4:5] == 2;
	wire ir_fdvx = ir_fp & ir[4:5] == 3;
	wire ir_fp_dir = ir_fp & ir[7:8] == 0;
	wire ir_fp_l_i = ir_fp & ir[7:8] == 1;
	wire ir_fp_mem = ir_fp & ir[7:8] == 2;
	wire ir_fp_both = ir_fp & ir[7:8] == 3;
	wire ir_fp_long = ir_fp_l_i & ~ir[6];
	wire ir_fp_imm = ir_fp_l_i & ir[6];
	wire ir_fp_NOT_imm = ir_fp & (~ir[6] | ir[7] | ~ir[8]);
	wire ir_fdvl = ir_fdvx & ir_fp_long;
	wire ir_fdv_NOT_l = ir_fdvx & ~ir_fp_long;

	wire ir_fwt = ir_20x | ir_21x;
	wire ir_movex = ir_fwt & ir[5:6] == 0;
	wire ir_movsx = ir_fwt & ir[5:6] == 1;
	wire ir_movnx = ir_fwt & ir[5:6] == 2;
	wire ir_movmx = ir_fwt & ir[5:6] == 3;
	wire ir_fwt_dir = ir_fwt & ir[7:8] == 0;
	wire ir_fwt_imm = ir_fwt & ir[7:8] == 1;
	wire ir_fwt_mem = ir_fwt & ir[7:8] == 2;
	wire ir_fwt_self = ir_fwt & ir[7:8] == 3;

	wire ir_idiv = ir_xdiv & ~ir[6];
	wire ir_div = ir_xdiv & ir[6];
	wire ir_md = ir_2xx & ~ir[3] & ir[4];
	wire ir_md_sce = ir_md & ir[7];
	wire ir_md_fce = ir_md & (ir[7] | ~ir[8]);
	wire ir_md_sac_inh = ir_md & ir[7] & ~ir[8];
	wire ir_md_sac2 = ~ir_md_sac_inh & (ir_xdiv | ir_xmul & ir[6]);

	wire ir_ash = ir_24x & ir[6:8] == 0;
	wire ir_rot = ir_24x & ir[6:8] == 1;
	wire ir_lsh = ir_24x & ir[6:8] == 2;
	wire ir_jffo = ir_24x & ir[6:8] == 3;
	wire ir_ashc = ir_24x & ir[6:8] == 4;
	wire ir_rotc = ir_24x & ir[6:8] == 5;
	wire ir_lshc = ir_24x & ir[6:8] == 6;
	wire ir_247 = ir_24x & ir[6:8] == 7;

	wire ir_254_7 = ir_25x & ir[6];
	wire ir_exch = ir_25x & ir[6:8] == 0;
	wire ir_blt = ir_25x & ir[6:8] == 1;
	wire ir_aobjp = ir_25x & ir[6:8] == 2;
	wire ir_aobjn = ir_25x & ir[6:8] == 3;
	wire ir_jrsta = ir_25x & ir[6:8] == 4;
	wire ir_jfcl = ir_25x & ir[6:8] == 5;
	wire ir_xct = ir_25x & ir[6:8] == 6;
	wire ir_257 = ir_25x & ir[6:8] == 7;
	wire ir_jrst = ir_jrsta & ~ir_uuo;

	wire ir_26x_e_long = ir_26x & ~ir_jsp;
	wire ir_260_3 = ir_26x & ~ir[6];
	wire ir_pushj = ir_26x & ir[6:8] == 0;
	wire ir_push = ir_26x & ir[6:8] == 1;
	wire ir_pop = ir_26x & ir[6:8] == 2;
	wire ir_popj = ir_26x & ir[6:8] == 3;
	wire ir_jsr = ir_26x & ir[6:8] == 4;
	wire ir_jsp = ir_26x & ir[6:8] == 5;
	wire ir_jsa = ir_26x & ir[6:8] == 6;
	wire ir_jra = ir_26x & ir[6:8] == 7;
	wire ir_pops = ir_pop | ir_popj;

	wire ir_add = ir_as & ~ir[6];
	wire ir_sub = ir_as & ir[6];
	wire ir_as_dir = ir_as & ir[7:8] == 0;
	wire ir_as_imm = ir_as & ir[7:8] == 1;
	wire ir_as_mem = ir_as & ir[7:8] == 2;
	wire ir_as_both = ir_as & ir[7:8] == 3;

	wire ir_caix = ir_3xx & ir[3:5] == 0;
	wire ir_camx = ir_3xx & ir[3:5] == 1;
	wire ir_jumpx = ir_3xx & ir[3:5] == 2;
	wire ir_skipx = ir_3xx & ir[3:5] == 3;
	wire ir_aojx = ir_3xx & ir[3:5] == 4;
	wire ir_aosx = ir_3xx & ir[3:5] == 5;
	wire ir_sojx = ir_3xx & ir[3:5] == 6;
	wire ir_sosx = ir_3xx & ir[3:5] == 7;
	wire ir_cax = ir_caix | ir_camx;
	wire ir_jumps = ir_jumpx | ir_aojx | ir_sojx;
	wire ir_aoxx = ir_aojx | ir_aosx;
	wire ir_soxx = ir_sojx | ir_sosx;
	wire ir_xosx = ir_3xx & ir[3] & ir[5];
	wire ir_skips = ir_3xx & ir[5] & ~ir_camx;

	wire ir_boole_0 = ir_boole & ir[3:6] == 0;
	wire ir_boole_1 = ir_boole & ir[3:6] == 1;
	wire ir_boole_2 = ir_boole & ir[3:6] == 2;
	wire ir_boole_3 = ir_boole & ir[3:6] == 3;
	wire ir_boole_4 = ir_boole & ir[3:6] == 4;
	wire ir_boole_5 = ir_boole & ir[3:6] == 5;
	wire ir_boole_6 = ir_boole & ir[3:6] == 6;
	wire ir_boole_7 = ir_boole & ir[3:6] == 7;
	wire ir_boole_10 = ir_boole & ir[3:6] == 8;
	wire ir_boole_11 = ir_boole & ir[3:6] == 9;
	wire ir_boole_12 = ir_boole & ir[3:6] == 10;
	wire ir_boole_13 = ir_boole & ir[3:6] == 11;
	wire ir_boole_14 = ir_boole & ir[3:6] == 12;
	wire ir_boole_15 = ir_boole & ir[3:6] == 13;
	wire ir_boole_16 = ir_boole & ir[3:6] == 14;
	wire ir_boole_17 = ir_boole & ir[3:6] == 15;
	wire ir_boole_dir = ir_boole & ir[7:8] == 0;
	wire ir_boole_mem = ir_boole & ir[7:8] == 2;

	wire ir_txnx = ir_test & ir[3:4] == 0;
	wire ir_txzx = ir_test & ir[3:4] == 1;
	wire ir_txcx = ir_test & ir[3:4] == 2;
	wire ir_txox = ir_test & ir[3:4] == 3;
	wire ir_test_fce = ir_test & ir[5];
	wire ir_test_swap = ir_test & ir[8];

	wire ir_div_OR_fdvl = ir_div | ir_fdvl;

	always @(posedge clk) begin
		// ORDER important
		if(ir_lt_en)
			ir[0:12] <= ir[0:12] | membus_mb_in[0:12];
		if(ir_rt_en)
			ir[13:17] <= ir[13:17] | membus_mb_in[13:17];

		if(ir_lt_clr)
			ir[0:12] <= 0;
		if(ir_rt_clr)
			ir[13:17] <= 0;

		if(it1) begin
			ir_lt_en <= 0;
			ir_rt_en <= 0;
		end
		if(ft1a)
			ir_rt_en <= 0;
		if(at4 | at6 & ir_134_7)
			ir_rt_en <= 1;
		if(kt2 & key_execute | it0) begin
			ir_lt_en <= 1;
			ir_rt_en <= 1;
		end
		if(st1 & key_rim)
			ir[12] <= 0;
		if(et0 & iot_blk)
			ir[12] <= 1;
		if(ir_rdi_setup) begin
			ir[0:2] <= 3'o7;
			ir[3:9] <= rdi_sel;
			ir[12] <= ~key_rdi_part2;
		end
	end


	/* HWT */
	wire hwt_3_let = ir_hwt & ir[4:5] == 0;
	wire hwt_z = ir_hwt & ir[4:5] == 1;
	wire hwt_o = ir_hwt & ir[4:5] == 2;
	wire hwt_e = ir_hwt & ir[4:5] == 3;
	wire hwt_dir = ir_hwt & ir[7:8] == 0;
	wire hwt_imm = ir_hwt & ir[7:8] == 1;
	wire hwt_mem = ir_hwt & ir[7:8] == 2;
	wire hwt_self = ir_hwt & ir[7:8] == 3;
	wire hwt_e_long = hwt_3_let & ir[6] & ~ir[7];
	wire hwt_sce = hwt_mem & ~hwt_3_let;

	wire hwt_e_test =
		(ir[3]^ir[6]) & ar[18] |
		~(ir[3]^ir[6]) & ar[0];

	wire hwt_br_pm_en_ft9 = ir_hwt & ir[4];

	wire hwt_lt_fm_rt_et0 = ir_hwt & ir[6] & ~hwt_e_long & ~ir[3];
	wire hwt_rt_fm_lt_et0 = ir_hwt & ir[6] & ~hwt_e_long & ir[3];
	wire hwt_lt_fm_rt_et1 = ir_hwt & ir[6] & hwt_e_long & ~ir[3];
	wire hwt_rt_fm_lt_et1 = ir_hwt & ir[6] & hwt_e_long & ir[3];

	wire hwt_arrt_clr_et0 = hwt_e & ~hwt_e_test & ~ir[3] |
		hwt_z & ~ir[3];
	wire hwt_arlt_clr_et0 = hwt_e & ~hwt_e_test & ir[3] |
		hwt_z & ir[3];
	wire hwt_arrt_fm_adJ_et0 = hwt_e & hwt_e_test & ~ir[3] |
		hwt_e_long |
		hwt_3_let & hwt_mem & ~ir[3] |
		hwt_3_let & ~ir[7] & ir[3] |
		hwt_o & ~ir[3];
	wire hwt_arlt_fm_adJ_et0 = hwt_e & hwt_e_test & ir[3] |
		hwt_e_long |
		hwt_3_let & hwt_mem & ir[3] |
		hwt_3_let & ~ir[7] & ~ir[3] |
		hwt_o & ir[3];


	/* JFFO */
	reg jffo_f1;
	wire jffo_swap = ir_jffo & ad[0:17] == 0;
	wire jffo_t1;
	wire jffo_t1_del;
	wire jffo_cycle = jffo_f1 & ~mq[0];

	pa jffo_pa1(.clk(clk), .reset(reset),
		.in((et2b_del | jffo_t1_del) & jffo_cycle),
		.p(jffo_t1));

	dly170ns jffo_dly1(.clk(clk), .reset(reset), .in(jffo_t1), .p(jffo_t1_del));

	always @(posedge clk) begin
		if(mr_clr)
			jffo_f1 <= 0;
		if(et0 & ir_jffo & ~ad_eq_0)
			jffo_f1 <= 1;
	end


	/* BLT */
	reg bltf1;
	wire blt_t1;
	wire blt_t2;
	wire blt_t3;

	pa blt_pa1(.clk(clk), .reset(reset),
		.in(mc_rst1 & bltf1),
		.p(blt_t1));
	pa blt_pa2(.clk(clk), .reset(reset),
		.in(blt_t1_D & ~ad[17]),
		.p(blt_t2));
	pa blt_pa3(.clk(clk), .reset(reset),
		.in(blt_t1_D & ad[17]),
		.p(blt_t3));

	wire blt_t1_D, blt_t3_D;
	dly265ns blt_dly1(.clk(clk), .reset(reset), .in(blt_t1), .p(blt_t1_D));
	dly90ns blt_dly3(.clk(clk), .reset(reset), .in(blt_t3), .p(blt_t3_D));

	always @(posedge clk) begin
		if(mr_clr | blt_t1)
			bltf1 <= 0;
		if(et2 & ir_blt)
			bltf1 <= 1;
	end

	/* BYTE */
	reg byf4;
	reg byf5;
	reg byf6;
	wire byte_ptr_inc = (ir_ildb | ir_idpb | ir_ibp) & ~byf5 & ~byf6;
	wire byte_ptr_not_inc = (ir_ldb | ir_dpb | byf6) & ir_134_7 & ~byf5;
	wire lb_byte_load = (ir_ildb | ir_ldb) & byf5;
	wire db_byte_dep = (ir_idpb | ir_dpb) & byf5;
	wire byt1;
	wire byt2;
	wire byt3;
	wire byt4;
	wire byt6;
	wire byt7;
	wire byt7a;
	wire lbt1;
	wire dbt1;
	wire dbt2;
	wire dbt3;
	wire dbt4;
	wire dbt5;

	pa by_pa1(.clk(clk), .reset(reset),
		.in(et0 & byte_ptr_inc),
		.p(byt1));
	pa by_pa2(.clk(clk), .reset(reset),
		.in(byt1_D & scad[0]),
		.p(byt2));
	pa by_pa3(.clk(clk), .reset(reset), .in(byt2_D), .p(byt3));
	pa by_pa4(.clk(clk), .reset(reset),
		.in(byt1_D & ~scad[0] |
		    byt3_D),
		.p(byt4));
	pa by_pa5(.clk(clk), .reset(reset),
		.in(et0 & byte_ptr_not_inc),
		.p(byt6));
	pa by_pa6(.clk(clk), .reset(reset),
		.in(byt6_D | mc_rst1 & byf4 & ~ir_ibp),
		.p(byt7));
	pa by_pa7(.clk(clk), .reset(reset),
		.in(sct4 & byf4),
		.p(byt7a));
	pa by_pa8(.clk(clk), .reset(reset), .in(sct4 & lb_byte_load), .p(lbt1));
	pa by_pa9(.clk(clk), .reset(reset), .in(sct4 & db_byte_dep), .p(dbt1));
	pa by_pa10(.clk(clk), .reset(reset), .in(dbt1_D), .p(dbt2));
	pa by_pa11(.clk(clk), .reset(reset), .in(dbt2_D), .p(dbt3));
	pa by_pa12(.clk(clk), .reset(reset), .in(dbt3_D), .p(dbt4));
	pa by_pa13(.clk(clk), .reset(reset), .in(dbt4_D), .p(dbt5));

	wire byt1_D, byt2_D, byt3_D, byt6_D, byt7a_D;
	wire dbt1_D, dbt2_D, dbt3_D, dbt4_D;
	dly215ns by_dly1(.clk(clk), .reset(reset), .in(byt1), .p(byt1_D));
	dly90ns by_dly2(.clk(clk), .reset(reset), .in(byt2), .p(byt2_D));
	dly115ns by_dly3(.clk(clk), .reset(reset), .in(byt3), .p(byt3_D));
	dly190ns by_dly4(.clk(clk), .reset(reset), .in(byt6), .p(byt6_D));
	dly65ns by_dly5(.clk(clk), .reset(reset), .in(byt7a), .p(byt7a_D));
	dly115ns by_dly6(.clk(clk), .reset(reset), .in(dbt1), .p(dbt1_D));
	dly115ns by_dly7(.clk(clk), .reset(reset), .in(dbt2), .p(dbt2_D));
	dly90ns by_dly8(.clk(clk), .reset(reset), .in(dbt3), .p(dbt3_D));
	dly90ns by_dly9(.clk(clk), .reset(reset), .in(dbt4), .p(dbt4_D));

	always @(posedge clk) begin
		if(mr_clr | st1a | byt7a)
			byf4 <= 0;
		if(byt4 | byt6)
			byf4 <= 1;
		if(mr_clr)
			byf5 <= 0;
		if(byt7a)
			byf5 <= 1;
		if(mr_start |
		   arlt_fm_flagsJ |
		   arf_flags_fm_brJ & ~br[4] |
		   lbt1 | dbt1)
			byf6 <= 0;
		if(arf_flags_fm_brJ & br[4] | byt7a)
			byf6 <= 1;
	end


	/* IOT */
	reg iot_f1;
	reg iot_go;
	wire iot_blki = ir_iot & ir[10:12] == 0;
	wire iot_datai = ir_iot & ir[10:12] == 1;
	wire iot_blko = ir_iot & ir[10:12] == 2;
	wire iot_datao = ir_iot & ir[10:12] == 3;
	wire iot_cono = ir_iot & ir[10:12] == 4;
	wire iot_coni = ir_iot & ir[10:12] == 5;
	wire iot_consz = ir_iot & ir[10:12] == 6;
	wire iot_conso = ir_iot & ir[10:12] == 7;
	wire iot_consx = iot_conso | iot_consz;
	wire iot_blk = iot_blki | iot_blko;
	wire iot_out_going = iot_cono | iot_datao;
	wire iot_t0;
	wire iot_t1;
	wire iot_t2;
	wire iot_t3;
	wire iot_t4;
	wire iot_t5;
	wire iot_rdi_pulse;
	wire iot_initial_setup_dly;
	wire iot_restart_dly;
	wire iot_data_dly;
	wire iot_reset_dly;
	wire iot_data_xfer = iot_restart_dly | iot_data_dly;
	// TODO: figure out what this does exactly
	wire iob_bus_reset = iot_reset_dly & ~iot_data_dly;

	wire iot_datao_clr;
	wire iot_datao_set;
	wire iot_cono_clr;
	wire iot_cono_set;
	wire iot_reset;

	dcd iot_dcd1(.clk(clk), .reset(reset),
		.p(iot_go & ~iot_reset_dly), .l(1'b1),
		.q(iot_t0));
	dcd iot_dcd2(.clk(clk), .reset(reset),
		.p(~iot_initial_setup_dly), .l(1'b1),
		.q(iot_t2));
	dcd iot_dcd3(.clk(clk), .reset(reset),
		.p(~iot_restart_dly), .l(1'b1),
		.q(iot_t3));
	dcd iot_dcd4(.clk(clk), .reset(reset),
		.p(~iot_data_dly), .l(1'b1),
		.q(iot_t4));
	dcd iot_dcd5(.clk(clk), .reset(reset),
		.p(~key_rdi_dly), .l(1'b1),
		.q(iot_rdi_pulse));
	pa iot_pa1(.clk(clk), .reset(reset),
		.in(iot_t4_D & iot_consx),
		.p(iot_t5));
	pa iot_pa2(.clk(clk), .reset(reset),
		.in(mc_rst1 & iot_f1),
		.p(iot_t1));

	pa iot_pa3(.clk(clk), .reset(reset),
		.in(iot_t2 & iot_datao),
		.p(iot_datao_clr));
	pa iot_pa4(.clk(clk), .reset(reset),
		.in(iot_t2 & iot_cono),
		.p(iot_cono_clr));
	pa iot_pa5(.clk(clk), .reset(reset),
		.in(iot_t3 & iot_datao),
		.p(iot_datao_set));
	pa iot_pa6(.clk(clk), .reset(reset),
		.in(iot_t3 & iot_cono),
		.p(iot_cono_set));
	pa iot_pa7(.clk(clk), .reset(reset),
		.in(mr_start |
		    cpa_cono_set & iob[19]),
		.p(iot_reset));

	wire iot_t4_D;
	gdly1us iot_dly1(.clk(clk), .reset(reset),
		.p(iot_t0), .l(1'b1),
		.q(iot_initial_setup_dly));
	gdly2us iot_dly2(.clk(clk), .reset(reset),
		.p(iot_t0), .l(1'b1),
		.q(iot_restart_dly));
	gdly1_5us iot_dly3(.clk(clk), .reset(reset),
		.p(iot_t2), .l(1'b1),
		.q(iot_data_dly));
	gdly2_5us iot_dly4(.clk(clk), .reset(reset),
		.p(iot_t3), .l(1'b1),
		.q(iot_reset_dly));
	dly190ns iot_dly5(.clk(clk), .reset(reset),
		.in(iot_t4),
		.p(iot_t4_D));

	always @(posedge clk) begin
		if(mr_clr | iot_t1)
			iot_f1 <= 0;
		if(et0 & iot_blk)
			iot_f1 <= 1;
		if(mr_start | iot_t2)
			iot_go <= 0;
		if(et0 & ir_iot & ~iot_blk)
			iot_go <= 1;
	end


	/* SC SCAD */
	reg [0:8] sc;
	wire [0:8] scad = scad_inp_a + scad_inp_b + scad_inc_en;
	wire [0:8] scad_inp_a = scad_sc_comp ? ~sc : sc;
	wire [0:8] scad_inp_b = {9{scad_data1}} & sc_data | {9{scad_data0}} & ~sc_data;
	wire [0:8] sc_data =
		{9{scad_br_en}} & br[0:8] |
		{6{scad_ar6_11_en}} & ar[6:11] |
		{5{scad_33_en}} & (5'o33 & ~fdf3) |
		(scad_200_en << 7);

	always @(posedge clk) begin
		if(sc_clr)
			sc <= 0;
		if(sc_fm_scadJ)
			sc <= scad;
		if(sc_fm_ar0_5_1)
			sc[3:8] <= sc[3:8] | ar[0:5];
		if(sc_fm_ar0_8_1)
			sc <= sc | ar[0:8];
		if(sc_fm_br1)
			sc <= sc | { br[18], br[28:35] };
		if(sc_inc)
			sc <= sc + 1;
		if(sc_md_setup)
			sc <= sc | 9'o735;
		if(sc_fp_setup) begin
			sc[0:7] <= sc[0:7] | 9'o744>>1;
			if(~ir[5])
				sc[8] <= 1;
		end
		if(sc_fm_fe1)
			sc <= sc | fe;
		if(byt3)
			sc <= sc | 'o44;
		if(fdt5 & ~ir[6])
			sc[8] <= 1;
	end


	/* SC SCAD control */
	reg scad_data0;
	reg scad_data1;
	reg scad_sc_comp;
	reg scad_inc_en;
	reg scad_br_en;
	reg scad_ar6_11_en;
	reg scad_200_en;
	reg scad_33_en;
	wire sc_sc0_XOR_sc1 = sc[0] ^ sc[1];
	wire sc0_eq_ar0 = sc[0] == ar[0];
	wire sc_clr =
		mr_clr |
		byt2 | byt4 |
		fpt3 & ~ir[5] |
		fat4 |
		fdt4 | fdt9;
	wire sc_inc = sct1;
	wire sc_fm_scadJ =
		srt1 |
		byt7 |
		et0 & (byf5 | ir_dfn) |
		et2 & ir_fsc |
		nrt2 | nrt3 | nrt4 | nrt6 | nrt10 | nlt1 |
		fpt1 | fpt2 |
		fpt3 & ir[5] |
		fat2 | fat3 | fat7 |
		fat8 & br[0];
	wire sc_fm_fe1 = fmt3 | fdt6;
	wire sc_fm_ar0_5_1 = byt1 | byt7a;
	wire sc_fm_br1 = et0 & (ir_fsc | sr_op);
	wire sc_fm_ar0_8_1 = fpt0 | fat1 | fdt11;

	wire sc_negate_setup =
		et0 & sr_go_left |
		byt7a |
		fat2 & ~scad[0] & ar0_eq_br0;
	wire scad_sc_inc_setup =
		sct0 |
		nrt0 | nrt2 |
		fpt3 |
		fat2 & scad[0] & ~ar0_eq_br0;
	wire scad_sc_comp_setup =
		nrt1 | nrt3 |
		fpt0 & ar[0] |
		fat2 & ~scad[0] & ~ar0_eq_br0 |
		fat7;
	wire scad_sc_p_br_setup =
		ft9 & ir_dfn |
		et0 & ir_fsc & ~ar[0] |
		fat1 & ~ar0_eq_br0 |
		fat6;
	wire scad_sc_m_br_setup =
		et0 & ir_fsc & ar[0] |
		fat1 & ar0_eq_br0;
	wire sc_md_setup = et0 & ir_md;
	wire sc_fp_setup = fmt1 | fdt5;
	wire scad_all_dis =
		mr_clr |
		et0 & ir_dfn |
		nrt4 & ~ar[0] |
		nlt2 |
		fat2 & scad[0] & ar0_eq_br0;
	wire scad_misc_clr =
		scad_all_dis |
		scad_sc_inc_setup |
		scad_sc_p_br_setup |
		scad_sc_m_br_setup;
	wire sc_p_en =
		scad_sc_p_br_setup |
		fpt2 & ir[5] |
		fdt11 & ar[0];
	wire sc_m_en =
		byt1 | byt6 |
		nlt0 |
		scad_sc_m_br_setup |
		fpt2 & ~ir[5] |
		fdt11 & ~ar[0];

	always @(posedge clk) begin
		if(scad_all_dis) begin
			scad_data0 <= 0;
			scad_data1 <= 0;
			scad_sc_comp <= 0;
			scad_inc_en <= 0;
			scad_br_en <= 0;
			scad_ar6_11_en <= 0;
		end
		if(scad_misc_clr) begin
			scad_200_en <= 0;
			scad_33_en <= 0;
		end
		if(scad_sc_comp_setup) begin
			scad_data0 <= 0;
			scad_data1 <= 0;
			scad_sc_comp <= 1;
			scad_inc_en <= 0;
		end
		if(sc_negate_setup) begin
			scad_data0 <= 0;
			scad_data1 <= 0;
			scad_sc_comp <= 1;
			scad_inc_en <= 1;
		end
		if(scad_sc_inc_setup) begin
			scad_data0 <= 0;
			scad_data1 <= 0;
			scad_sc_comp <= 0;
			scad_inc_en <= 1;
			scad_br_en <= 0;
		end
		if(sc_p_en) begin
			scad_data0 <= 0;
			scad_data1 <= 1;
			scad_sc_comp <= 0;
			scad_inc_en <= 0;
		end
		if(sc_m_en) begin
			scad_data0 <= 1;
			scad_data1 <= 0;
			scad_sc_comp <= 0;
			if(~ir_fsc)
				scad_inc_en <= 1;
		end
		if(fpt1) begin
			if(fp_exp_add)
				scad_data0 <= 1;
			else
				scad_data1 <= 1;
			scad_sc_comp <= 0;
			if(ir[5])
				scad_inc_en <= 1;
		end
		if(fpt2)
			scad_br_en <= 0;
		if(scad_sc_p_br_setup | scad_sc_m_br_setup | fpt1)
			scad_br_en <= 1;
		if(byt1 | byt6)
			scad_ar6_11_en <= 1;
		if(byt7a)
			scad_ar6_11_en <= 0;
		if(nlt0 | fdt11)
			scad_33_en <= 1;
		if(fpt2)
			scad_200_en <= 1;
	end


	/* SC SR subroutines */
	reg sc_stop;
	wire sr_op = ~ir_jffo & ~ir_247 & ir_24x;
	wire sr_go_left = sr_op & ~br[18];
	wire sr_go_right = sr_op & br[18];
	wire sc_sbr_et0 = db_byte_dep | lb_byte_load | sr_go_right;
	wire srt1;
	wire sct0;
	wire sct1;
	wire sct2;
	wire sct3;
	wire sct4;
	wire sct4_del;

	pa sr_pa1(.clk(clk), .reset(reset), .in(et0_D & sr_go_left), .p(srt1));
	pa sc_pa2(.clk(clk), .reset(reset),
		.in(et0_D & sc_sbr_et0 |
		    srt1 |
		    byt7 |
		    mst1 |
		    dst2 |
		    fat5),
		.p(sct0));
	pa sc_pa3(.clk(clk), .reset(reset),
		.in((sct0_D | sct3_D) & ~sc_stop & sc[0] |
		    kt0a & sc_stop),
		.p(sct1));
	pa sc_pa4(.clk(clk), .reset(reset),
		.in(sct1 & (ad_br_p_en | ad_br_m_en)),
		.p(sct2));
	pa sc_pa5(.clk(clk), .reset(reset),
		.in(sct1 & ~ad_br_p_en & ~ad_br_m_en |
		    sct2_D),
		.p(sct3));
	pa sc_pa6(.clk(clk), .reset(reset),
		.in((sct0_D | sct3_D) & ~sc[0]),
		.p(sct4));

	wire et0_D;
	wire sct0_D, sct2_D, sct3_D;
	dly140ns sr_dly1(.clk(clk), .reset(reset), .in(et0), .p(et0_D));
	dly165ns sc_dly1(.clk(clk), .reset(reset), .in(sct0), .p(sct0_D));
	// TODO: adjust these two correctly
	dly280ns sc_dly2(.clk(clk), .reset(reset), .in(sct2), .p(sct2_D));
	dly150ns sc_dly3(.clk(clk), .reset(reset), .in(sct3), .p(sct3_D));
	dly165ns sc_dly4(.clk(clk), .reset(reset), .in(sct4), .p(sct4_del));

	always @(posedge clk) begin
		if(mr_clr | sct4)
			sc_stop <= 0;
		if(sct0 & sc_stop_sw)
			sc_stop <= 1;
	end


	/* MS MP */
	reg mpf1;
	reg mpf2;
	reg msf1;
	wire mpt2;
	wire mpt3;
	wire mpt4;
	wire mst0;
	wire mst1;

	pa ms_pa1(.clk(clk), .reset(reset),
		.in(et0 & ir_xmul |
		    fmt1_D),
		.p(mst0));
	pa ms_pa2(.clk(clk), .reset(reset), .in(mst0_D), .p(mst1));
	pa ms_pa3(.clk(clk), .reset(reset),
		.in(sct4_del & mpf1),
		.p(mpt2));
	pa ms_pa4(.clk(clk), .reset(reset), .in(mpt2_D & ~ir[6]), .p(mpt3));
	pa ms_pa5(.clk(clk), .reset(reset), .in(mpt3_D), .p(mpt4));

	wire mst0_D, mpt2_D, mpt3_D;
	dly115ns ms_dly1(.clk(clk), .reset(reset), .in(mst0), .p(mst0_D));
	dly115ns ms_dly2(.clk(clk), .reset(reset), .in(mpt2), .p(mpt2_D));
	dly165ns ms_dly3(.clk(clk), .reset(reset), .in(mpt3), .p(mpt3_D));

	always @(posedge clk) begin
		if(mr_clr) begin
			mpf1 <= 0;
			mpf2 <= 0;
			msf1 <= 0;
		end
		if(mpt2)
			mpf1 <= 0;
		if(et0 & ir_xmul)
			mpf1 <= 1;
		if(mst0 & ar[0] & br[0])
			mpf2 <= 1;
		if(sct4)
			msf1 <= 0;
		if(mst1)
			msf1 <= 1;
	end


	/* DS DV */
	reg dsf1;
	reg dsf7;
	wire div_t0;
	wire div_t1;
	wire div_t3;
	wire div_t4;
	wire div_t4_del;
	wire div_t5;
	wire dst1;
	wire dst2;
	wire dst3;
	wire dst4;
	wire dst5;
	wire dst5_del;
	wire dst7;

	wire div_low_zero_cond = ir[1] & ad_cry[1] | ~ir[0] & ad[8:35] == 0;
	wire dsf7_XOR_br0 = dsf7 ^ br[0];

	pa div_pa1(.clk(clk), .reset(reset),
		.in(et0 & ir_div_OR_fdvl),
		.p(div_t0));
	pa div_pa2(.clk(clk), .reset(reset),
		.in(et2 & ir_idiv |
		    div_t4_del & ~ir_fdvl |
		    fdt5),
		.p(dst1));
	pa div_pa3(.clk(clk), .reset(reset),
		.in(et2 & ir_div_OR_fdvl & dsf7),
		.p(div_t1));
	pa div_pa4(.clk(clk), .reset(reset),
		.in(div_t1_D),
		.p(div_t3));
	pa div_pa5(.clk(clk), .reset(reset),
		.in(div_t3 | et2 & ir_div_OR_fdvl & ~dsf7),
		.p(div_t4));
	pa div_pa6(.clk(clk), .reset(reset),
		.in(dst1_D & ad[0]),
		.p(dst2));
	pa div_pa7(.clk(clk), .reset(reset),
		.in(dst1_D & ~ad[0]),
		.p(dst7));
	pa div_pa8(.clk(clk), .reset(reset),
		.in(sct4_del & dsf1),
		.p(dst3));
	pa div_pa9(.clk(clk), .reset(reset),
		.in(dst3_D),
		.p(dst4));
	pa div_pa10(.clk(clk), .reset(reset),
		.in(dst4_D),
		.p(dst5));
	pa div_pa11(.clk(clk), .reset(reset),
		.in(dst5_del & ir[1]),
		.p(div_t5));

	wire div_t1_D, dst1_D, dst3_D, dst4_D;
	dly240ns div_dly1(.clk(clk), .reset(reset), .in(div_t1), .p(div_t1_D));
	dly115ns div_dly2(.clk(clk), .reset(reset), .in(div_t4), .p(div_t4_del));
	dly280ns div_dly3(.clk(clk), .reset(reset), .in(dst1), .p(dst1_D));
	dly240ns div_dly4(.clk(clk), .reset(reset), .in(dst3), .p(dst3_D));
	dly240ns div_dly5(.clk(clk), .reset(reset), .in(dst4), .p(dst4_D));
	dly240ns div_dly6(.clk(clk), .reset(reset), .in(dst5), .p(dst5_del));

	always @(posedge clk) begin
		if(mr_clr) begin
			dsf1 <= 0;
			dsf7 <= 0;
		end
		if(dst4)
			dsf1 <= 0;
		if(dst1)
			dsf1 <= 1;
		if(div_t0 & ar[0] |
		   et0 & ar[0] & (ir_idiv | ir_fdv_NOT_l))
			dsf7 <= 1;
	end


	/* NR */
	reg nrf1;
	wire nr_all_zero = ad_eq_0 & (mq[8:35] == 0 | ir_fdvx);
	wire nr_normal = (ar[0] ^ ar[9]) | ad[9] & ad[10:35] == 0 | ir_ufa;
	wire nr_sh_rt_cond = (ar[0] ^ ar[8]) | ad[9:35] == 0;
	wire nr_round = ~nrf1 & ir[6] & mq[8] & (mq[9:35] != 0 & ~ar[0]);
	wire nrt0;
	wire nrt0_del;
	wire nrt10;
	wire nrt1;
	wire nrt2;
	wire nrt3;
	wire nrt4;
	wire nrt5;
	wire nrt6;
	wire nrt7;
	wire nrt99;
	wire nlt0;
	wire nlt1;
	wire nlt2;
	wire nlt3;
	wire nlt4;

	pa pa_nrt1(.clk(clk), .reset(reset),
		.in(et2 & ir_fsc |
		    nrt7 |
		    fmt3 |
		    fat8 |
		    fdt6),
		.p(nrt0));
	pa pa_nrt2(.clk(clk), .reset(reset),
		.in(nrt0_del & nr_sh_rt_cond),
		.p(nrt10));
	pa pa_nrt3(.clk(clk), .reset(reset),
		.in(nrt0_del & ~nr_all_zero),
		.p(nrt1));
	pa pa_nrt4(.clk(clk), .reset(reset),
		.in((nrt1_D | nrt2_D) & ~nr_normal),
		.p(nrt2));
	pa pa_nrt5(.clk(clk), .reset(reset),
		.in((nrt1_D | nrt2_D) & nr_normal),
		.p(nrt3));
	pa pa_nrt6(.clk(clk), .reset(reset),
		.in(nrt3_D & ~nr_round),
		.p(nrt4));
	pa pa_nrt7(.clk(clk), .reset(reset), .in(nrt4_D), .p(nrt5));
	pa pa_nrt8(.clk(clk), .reset(reset),
		.in(nrt3_D & nr_round),
		.p(nrt6));
	pa pa_nrt9(.clk(clk), .reset(reset), .in(nrt6_D), .p(nrt7));
	pa pa_nrt10(.clk(clk), .reset(reset),
		.in(nrt5 & ~ir_fdvx & ir_fp_long),
		.p(nlt0));
	pa pa_nrt11(.clk(clk), .reset(reset), .in(nlt0_D), .p(nlt1));
	pa pa_nrt12(.clk(clk), .reset(reset), .in(nlt1_D), .p(nlt2));
	pa pa_nrt13(.clk(clk), .reset(reset), .in(nlt2_D), .p(nlt3));
	pa pa_nrt14(.clk(clk), .reset(reset), .in(nlt3_D), .p(nlt4));
	pa pa_nrt15(.clk(clk), .reset(reset),
		.in(nlt4 |
		    nrt0_del & nr_all_zero |
		    nrt5 & ~ir_fdvx & ~ir_fp_long),
		.p(nrt99));

	wire nrt1_D, nrt2_D, nrt3_D, nrt4_D, nrt6_D;
	wire nlt0_D, nlt1_D, nlt2_D, nlt3_D;
	dly215ns pa_dly1(.clk(clk), .reset(reset), .in(nrt0), .p(nrt0_del));
	dly215ns pa_dly2(.clk(clk), .reset(reset), .in(nrt1), .p(nrt1_D));
	dly215ns pa_dly3(.clk(clk), .reset(reset), .in(nrt2), .p(nrt2_D));
	dly165ns pa_dly4(.clk(clk), .reset(reset), .in(nrt3), .p(nrt3_D));
	dly140ns pa_dly5(.clk(clk), .reset(reset), .in(nrt4), .p(nrt4_D));
	dly240ns pa_dly6(.clk(clk), .reset(reset), .in(nrt6), .p(nrt6_D));
	dly190ns pa_dly7(.clk(clk), .reset(reset), .in(nlt0), .p(nlt0_D));
	dly115ns pa_dly8(.clk(clk), .reset(reset), .in(nlt1), .p(nlt1_D));
	dly190ns pa_dly9(.clk(clk), .reset(reset), .in(nlt2), .p(nlt2_D));
	dly65ns pa_dly10(.clk(clk), .reset(reset), .in(nlt3), .p(nlt3_D));

	always @(posedge clk) begin
		if(mr_clr)
			nrf1 <= 0;
		if(nrt6 | fdt6)
			nrf1 <= 1;
	end


	/* FE */
	reg [0:8] fe;
	wire fe_clr = mr_clr | fdt2;
	wire fe_fm_scad1 = fpt3 | fdt3;

	always @(posedge clk) begin
		if(fe_clr)
			fe <= 0;
		if(fe_fm_scad1)
			fe <= fe | scad;
	end


	/* FP FM */
	wire fp_exp_add = ir[5] ^ br[0];
	wire fpt0;
	wire fpt1;
	wire fpt2;
	wire fpt3;
	wire fpt3_del;
	wire fmt1;
	wire fmt3;

	pa fp_pa1(.clk(clk), .reset(reset),
		.in(et0_del & ir_fdv_NOT_l |
		    et0 & ir_fmp |
		    div_t4_del & ir_fdvl),
		.p(fpt0));
	pa fp_pa2(.clk(clk), .reset(reset), .in(fpt0_D), .p(fpt1));
	pa fp_pa3(.clk(clk), .reset(reset), .in(fpt1_D), .p(fpt2));
	pa fp_pa4(.clk(clk), .reset(reset), .in(fpt2_D), .p(fpt3));
	pa fm_pa1(.clk(clk), .reset(reset), .in(fpt3_del & ~ir[5]), .p(fmt1));
	pa fm_pa2(.clk(clk), .reset(reset), .in(sct4_del & ir_fmp), .p(fmt3));

	wire fpt0_D, fpt1_D, fpt2_D;
	wire fmt1_D;
	dly140ns fp_dly1(.clk(clk), .reset(reset), .in(fpt0), .p(fpt0_D));
	dly140ns fp_dly2(.clk(clk), .reset(reset), .in(fpt1), .p(fpt1_D));
	dly140ns fp_dly3(.clk(clk), .reset(reset), .in(fpt2), .p(fpt2_D));
	dly65ns fp_dly4(.clk(clk), .reset(reset), .in(fpt3), .p(fpt3_del));
	dly90ns fm_dly1(.clk(clk), .reset(reset), .in(fmt1), .p(fmt1_D));


	/* FA */
	reg faf1;
	wire fat1;
	wire fat2;
	wire fat3;
	wire fat3a;
	wire fat4;
	wire fat5;
	wire fat6;
	wire fat7;
	wire fat8;

	pa fa_pa1(.clk(clk), .reset(reset),
		.in(et0_del & (ir_fad | ir_fsb | ir_ufa)),
		.p(fat1));
	pa fa_pa2(.clk(clk), .reset(reset), .in(fat1_D), .p(fat2));
	pa fa_pa3(.clk(clk), .reset(reset), .in(fat2_D), .p(fat3));
	pa fa_pa4(.clk(clk), .reset(reset), .in(fat3 & sc0_eq_ar0), .p(fat3a));
	pa fa_pa5(.clk(clk), .reset(reset),
		.in(fat3_D & sc[0] & (~sc[1] | ~sc[2])),	// negative 4XX-6XX
		.p(fat4));
	pa fa_pa6(.clk(clk), .reset(reset),
		.in(fat3_D & (~sc[0] | sc[1] & sc[2])),		// negative 7XX or positive (= 0)
		.p(fat5));
	pa fa_pa7(.clk(clk), .reset(reset),
		.in(sct4 & faf1 | fat4),
		.p(fat6));
	pa fa_pa8(.clk(clk), .reset(reset), .in(fat6_D), .p(fat7));
	pa fa_pa9(.clk(clk), .reset(reset), .in(fat7_D), .p(fat8));

	wire fat1_D, fat2_D, fat3_D, fat6_D, fat7_D;
	dly190ns fa_dly1(.clk(clk), .reset(reset), .in(fat1), .p(fat1_D));
	dly165ns fa_dly2(.clk(clk), .reset(reset), .in(fat2), .p(fat2_D));
	dly140ns fa_dly3(.clk(clk), .reset(reset), .in(fat3), .p(fat3_D));
	dly165ns fa_dly4(.clk(clk), .reset(reset), .in(fat6), .p(fat6_D));
	dly140ns fa_dly5(.clk(clk), .reset(reset), .in(fat7), .p(fat7_D));

	always @(posedge clk) begin
		if(mr_clr | fat6)
			faf1 <= 0;
		if(fat5)
			faf1 <= 1;
	end

	/* FDV */
	reg fdf1;
	reg fdf3;
	wire fdt1;
	wire fdt2;
	wire fdt3;
	wire fdt4;
	wire fdt5;
	wire fdt6;
	wire fdt7;
	wire fdt8;
	wire fdt8_del;
	wire fdt9;
	wire fdt10;
	wire fdt11;
	wire fdt12;
	wire fdt13;
	wire fdt14;

	pa fd_pa1(.clk(clk), .reset(reset),
		.in(fpt3_del & ir[5]),
		.p(fdt1));
	pa fd_pa2(.clk(clk), .reset(reset),
		.in(fdt1_D & ~ar[0]),
		.p(fdt2));
	pa fd_pa3(.clk(clk), .reset(reset), .in(fdt2_D), .p(fdt3));
	pa fd_pa4(.clk(clk), .reset(reset),
		.in(fdt1_D & ar[0] |
		    fdt3),
		.p(fdt4));
	pa fd_pa5(.clk(clk), .reset(reset), .in(fdt4_D), .p(fdt5));
	pa fd_pa6(.clk(clk), .reset(reset), .in(dst5_del & ~ir[1]), .p(fdt6));
	pa fd_pa7(.clk(clk), .reset(reset), .in(nrt5 & ir_fdvx), .p(fdt7));
	pa fd_pa8(.clk(clk), .reset(reset), .in(fdt7_D), .p(fdt8));
	pa fd_pa9(.clk(clk), .reset(reset), .in(fdt8_del & ir_fdvl), .p(fdt9));
	pa fd_pa10(.clk(clk), .reset(reset), .in(fdt9_D & mc_fm_en), .p(fdt10));
	pa fd_pa11(.clk(clk), .reset(reset),
		.in(fdt10_D |
		    mc_rst1 & fdf1),
		.p(fdt11));
	pa fd_pa12(.clk(clk), .reset(reset), .in(fdt11_D), .p(fdt12));
	pa fd_pa13(.clk(clk), .reset(reset), .in(fdt12_D), .p(fdt13));
	pa fd_pa14(.clk(clk), .reset(reset), .in(fdt13_D), .p(fdt14));

	wire fdt1_D, fdt2_D, fdt4_D, fdt7_D, fdt9_D;
	wire fdt10_D, fdt11_D, fdt12_D, fdt13_D;
	dly280ns fd_dly1(.clk(clk), .reset(reset), .in(fdt1), .p(fdt1_D));
	dly115ns fd_dly2(.clk(clk), .reset(reset), .in(fdt2), .p(fdt2_D));
	dly90ns fd_dly3(.clk(clk), .reset(reset), .in(fdt4), .p(fdt4_D));
	dly190ns fd_dly4(.clk(clk), .reset(reset), .in(fdt7), .p(fdt7_D));
	dly90ns fd_dly5(.clk(clk), .reset(reset), .in(fdt8), .p(fdt8_del));
	dly115ns fd_dly6(.clk(clk), .reset(reset), .in(fdt9), .p(fdt9_D));
	dly65ns fd_dly7(.clk(clk), .reset(reset), .in(fdt10), .p(fdt10_D));
	dly215ns fd_dly8(.clk(clk), .reset(reset), .in(fdt11), .p(fdt11_D));
	dly140ns fd_dly9(.clk(clk), .reset(reset), .in(fdt12), .p(fdt12_D));
	dly90ns fd_dly10(.clk(clk), .reset(reset), .in(fdt13), .p(fdt13_D));

	always @(posedge clk) begin
		if(mr_clr | fdt11)
			fdf1 <= 0;
		if(fdt9)
			fdf1 <= 1;
		if(mr_clr)
			fdf3 <= 0;
		if(fdt3)
			fdf3 <= 1;
	end


	/* MI */
	reg [0:35] mi;
	reg mi_prog;
	wire mi_prog_en = bio_pi_sel & ~mi_prog_dis_sw;
	wire mi_load;
	wire mit0;
	wire mit1;

	pa mi_pa1(.clk(clk), .reset(reset),
		.in(mc_rst1 & key_f1 |
		    iot_datao_set & mi_prog_en |
		    mit1 & ~mi_prog),
		.p(mi_load));
	pa mi_pa2(.clk(clk), .reset(reset),
		.in(mc_rst0 & as_cond & mc_rd |
		    ar_fm_fm1 & as_eq_fma),
		.p(mit0));
	pa mi_pa3(.clk(clk), .reset(reset),
		.in(mit0_D |
		    st1 & as_eq_fma & ~sac_inh |
		    st8 & as_eq_fma |
		    mc_rst0 & as_cond & ~mc_rd),
		.p(mit1));

	wire mit0_D;
	pa mi_dly1(.clk(clk), .reset(reset), .in(mit0), .p(mit0_D));

	always @(posedge clk) begin
		if(mr_pwr_clr)
			mi <= 0;
		if(mi_load)
			mi <= ar;
		// TODO: figure out what the level inputs do exactly
		if(mr_start | key_f1 | mi_prog_dis_sw)
			mi_prog <= 0;
		if(iot_datao_set & mi_prog_en)
			mi_prog <= 1;
	end

	/* AS */
	wire as_eq_fma = as == { 14'b0, fma };
	wire as_eq_rla = as[18:25] == mai[18:25] & as[26:35] == ma[26:35];
	wire as_cond = as_eq_rla & ~mai_fma_sel | as_eq_fma & mai_fma_sel;

	/* MA */
	reg [18:35] ma;
	wire ma18_31_eq_0 = ma[18:31] == 0;
	wire ma_fm_arJ =
		ft7 |
		et1 & (ir_blt | ir_jra | ir_push | ir_popj | ir_jrst) |
		et2 & br_fm_arJ_et1 |
		knt2 |
		kt1 & key_next |
		at4 |
		at6 & ~ir_uuo;
	wire ma_fm_asJ = kt2 & key_as_strobe_en;
	wire ma_fm_pcJ = it0 & ~pi_cyc & ~e_xctf;
	wire ma_fm_pich1 = it0 & pi_cyc;
	wire ma_clr = it1 | pi_t0 & pi_ov;

	always @(posedge clk) begin
		if(ma_clr)
			ma <= 0;
		if(ma_fm_arJ)
			ma <= ar[18:35];
		if(ma_fm_asJ)
			ma <= as;
		if(ma_fm_pcJ)
			ma <= pc;
		if(ma_fm_pich1) begin
			ma[30] <= 1;
			ma[32:34] <= ma[32:34] | pi_enc;
		end
		if(ma_fm_pich1 & ma_trap_offset |
		   et0 & ma_trap_offset & ex_non_rel_uuo)
			ma[29] <= 1;
		if(it0 & (pi_ov | e_uuof))
			ma[35] <= 1;
		if(et0) begin
			if(ir_uuo)
				ma[30] <= 1;
			if(ir_uuo & ir_1xx)
				ma[31] <= 1;
		end
	end


	/* MAI */
	reg mai_fma_sel;
	wire [18:35] mai;
	assign mai[32:35] = mai_fma_sel ? fma : ma[32:35];
	assign mai[26:31] = mai_fma_sel ? 0 : ma[26:31];
	assign mai[18:25] =
		{8{ex_rel & ~pr1_ill_adr}} & rla |
		{8{ex_rel & pr1_ill_adr}} & rlc |
		{8{~ex_rel & ~mai_fma_sel}} & ma[18:25];
	wire mai_cmc_adr_ack = membus_addr_ack;
	wire mai_cmc_rd_rs = membus_rd_rs;

	always @(posedge clk) begin
		if(mr_start | mc_rst0)
			mai_fma_sel <= 0;
		if(mc_fm_rd_rq | mc_fm_wr_rq)
			mai_fma_sel <= 1;
	end


	/* MC */
	reg mc_rd;
	reg mc_wr;
	reg mc_rq;
	reg mc_stop;
	reg mc_split_cyc_sync;
	reg mc_par_stop;
	reg mc_ignore_parity;
	wire mc_req_cyc = (mc_rd | mc_wr) & mc_rq &
		(~ma18_31_eq_0 | ~mc_fm_en);
	wire mc_sw_cond =
		key_adr_inst & if0 |
		key_adr_rd & ~if0 & mc_rd |
		key_adr_wr & ~mc_rd & mc_wr;
	wire mc_stop_en =
		key_sing_cycle |
		as_cond & key_adr_stop & mc_sw_cond;
	wire mc_adr_break_set = mc_rq & mc_sw_cond & as_cond & key_adr_brk;
	wire mc_split_cyc_en =
		key_adr_stop | key_sing_cycle |
		~mc_fm_en | iob_dr_split;
	wire mc_fm_en = fm_enable_sw;
	wire mc_fm_rd_rq;
	wire mc_fm_wr_rq;
	wire mc_rdwr_rs;
	wire mc_rd_rq_pulse;
	wire mc_wr_rq_pulse;
	wire mc_rdwr_rq_pulse;
	wire mc_rq_pulse;
	wire mc_rq_set;
	wire mc_illeg_adr;
	wire mc_illeg_adr_del;
	wire mc_adr_ack;
	wire mc_rd_rs;
	wire mc_wr_rs;
	wire mc_membus_fm_ar1;
	wire mc_bus_wr_rs;
	wire mc_rst0;
	wire mc_rst1;
	wire mc_non_ex_mem;
	wire mc_nxm_rst;
	wire mc_nxm_rd;
	wire mc_stop_set;

	pa mc_pa1(.clk(clk), .reset(reset),
		.in(mc_fm_rd_rq |
		    kt3 & key_ex_OR_ex_nxt |
		    it0 |
		    at4 |
		    ft0 |
		    ft1 & (mc_split_cyc_sync | ma18_31_eq_0) |
		    ft7),
		.p(mc_rd_rq_pulse));
	pa mc_pa2(.clk(clk), .reset(reset),
		.in(mc_fm_wr_rq |
		    mc_rdwr_rs & mc_split_cyc_sync |
		    kt3 & key_dep_OR_dep_nxt |
		    et2 & ir_blt |
		    st6),
		.p(mc_wr_rq_pulse));
	pa mc_pa3(.clk(clk), .reset(reset),
		.in(ft1 & ~mc_split_cyc_sync & ~ma18_31_eq_0),
		.p(mc_rdwr_rq_pulse));
	pa mc_pa4(.clk(clk), .reset(reset),
		.in(et0 & iot_blk |
		    st5 |
		    byt4),
		.p(mc_rdwr_rs));
	pa mc_pa5(.clk(clk), .reset(reset),
		.in((at1 | ft2 | ft4 | fdt9) & ~mc_fm_en),
		.p(mc_fm_rd_rq));
	pa mc_pa6(.clk(clk), .reset(reset),
		.in(st1 & ~sac_inh_OR_fm_en |
		    st8 & ~mc_fm_en),
		.p(mc_fm_wr_rq));
	pa mc_pa7(.clk(clk), .reset(reset),
		.in(mc_rd_rq_pulse | mc_wr_rq_pulse | mc_rdwr_rq_pulse),
		.p(mc_rq_pulse));
	pa mc_pa8(.clk(clk), .reset(reset),
		.in(mc_rq_pulse_D2 & ex_user & pra_ill_adr),
		.p(mc_illeg_adr));
	pa mc_pa9(.clk(clk), .reset(reset),
		.in(mc_rq_pulse_D2 & ex_user & ~pra_ill_adr & ~ma18_31_eq_0 |
		    mc_rq_pulse_D1 & (~ex_user | ma18_31_eq_0)),
		.p(mc_rq_set));
	pa mc_pa10(.clk(clk), .reset(reset),
		.in(fmat2 | mai_cmc_adr_ack | mc_nxm_rst),
		.p(mc_adr_ack));
	pa mc_pa11(.clk(clk), .reset(reset),
		.in(mai_cmc_rd_rs),
		.p(mc_rd_rs));
	pa mc_pa12(.clk(clk), .reset(reset),
		.in(kt3 & key_execute |
		    mc_rdwr_rs_D & ~mc_split_cyc_sync |
		    mc_adr_ack & (fma_ma_en | mc_wr & ~mc_rd)),
		.p(mc_wr_rs));
	pa mc_pa13(.clk(clk), .reset(reset),
		.in(mc_wr_rs),
		.p(mc_membus_fm_ar1));
	pa mc_pa14(.clk(clk), .reset(reset),
		.in(mc_wr_rs_D),
		.p(mc_bus_wr_rs));
	pa mc_pa15(.clk(clk), .reset(reset),
		.in(mc_rd_rs_D & (~pn_par_even | mc_ignore_parity) & ~mc_stop & mc_par_stop |
		    mai_cmc_rd_rs & ~mc_stop & ~mc_par_stop |
		    mc_wr_rs & ~mc_stop |
		    mc_nxm_rd & ~mc_stop |
		    kt0a & mc_stop & key_cont
		),
		.p(mc_rst0));
	pa mc_pa16(.clk(clk), .reset(reset),
		.in(mc_rst0_D),
		.p(mc_rst1));
	pa_dcd mc_pa17(.clk(clk), .reset(reset),
		.p(~mc_rq_pulse_D3), .l(mc_rq & ~mc_stop),
		.q(mc_non_ex_mem));
	pa mc_pa18(.clk(clk), .reset(reset),
		.in(mc_non_ex_mem & ~key_nxm_stop),
		.p(mc_nxm_rst));
	pa mc_pa19(.clk(clk), .reset(reset),
		.in(mc_nxm_rst & mc_rd),
		.p(mc_nxm_rd));

	wire mc_rq_pulse_D1, mc_rq_pulse_D2, mc_rq_pulse_D3;
	wire mc_wr_rs_D, mc_rd_rs_D, mc_rdwr_rs_D;
	wire mc_rst0_D;
	dly45ns mc_dly1(.clk(clk), .reset(reset), .in(mc_rq_pulse), .p(mc_rq_pulse_D1));
	dly140ns mc_dly2(.clk(clk), .reset(reset), .in(mc_rq_pulse), .p(mc_rq_pulse_D2));
	dly215ns mc_dly3(.clk(clk), .reset(reset), .in(mc_rq_pulse), .p(mc_stop_set));
	dly190ns mc_dly4(.clk(clk), .reset(reset), .in(mc_wr_rs), .p(mc_wr_rs_D));
	dly140ns mc_dly5(.clk(clk), .reset(reset), .in(mc_rd_rs), .p(mc_rd_rs_D));
	dly65ns mc_dly6(.clk(clk), .reset(reset), .in(mc_rdwr_rs), .p(mc_rdwr_rs_D));
	dly65ns mc_dly7(.clk(clk), .reset(reset), .in(mc_rst0), .p(mc_rst0_D));
	dly265ns mc_dly8(.clk(clk), .reset(reset), .in(mc_illeg_adr), .p(mc_illeg_adr_del));
	gdly100us mc_dly9(.clk(clk), .reset(reset),
		.p(mc_rq_pulse), .l(1'b1),
		.q(mc_rq_pulse_D3));

	always @(posedge clk) begin
		if(mr_start) begin
			mc_rd <= 0;
			mc_wr <= 0;
			mc_rq <= 0;
			mc_stop <= 0;
			mc_ignore_parity <= 0;
		end
		if(mr_clr) begin
			mc_split_cyc_sync <= 0;
			mc_par_stop <= 0;
		end
		if(mc_stop_set) begin
			if(key_par_stop)
				mc_par_stop <= 1;
			if(mc_stop_en |
			   mc_non_ex_mem & key_nxm_stop)
				mc_stop <= 1;
		end
		if(mc_wr_rq_pulse | mc_rst1)
			mc_rd <= 0;
		if(mc_rd_rq_pulse | mc_rdwr_rq_pulse)
			mc_rd <= 1;
		if(mc_rd_rq_pulse)
			mc_wr <= 0;
		if(mc_wr_rq_pulse | mc_rdwr_rq_pulse)
			mc_wr <= 1;
		if(mc_rq_pulse) begin
			mc_stop <= 0;
			mc_par_stop <= 0;
			mc_ignore_parity <= 0;
		end
		if(mc_rq_set)
			mc_rq <= 1;
		if(mc_adr_ack)
			mc_rq <= 0;
		if(kt0a & ~key_cont | mc_rst1)
			mc_stop <= 0;
		if(it1 & mc_split_cyc_en |
		   ft1 & ma18_31_eq_0)
			mc_split_cyc_sync <= 1;
	end

	/* FM */
	reg [0:35] fmem[0:15];
	reg fma_xr;
	reg fma_ac;
	reg fma_ac2;
	wire fma_ma_en = mc_rq & ma18_31_eq_0 & mc_fm_en;
	wire fma_xr_en = fma_xr & ~fma_ma_en;
	wire fma_ac_en = fma_ac & ~fma_ma_en;
	wire fma_ac2_en = fma_ac2 & ~fma_ma_en;
	wire [32:35] fma =
		{4{fma_ma_en}} & ma[32:35] |
		{4{fma_xr_en}} & ir[14:17] |
		{4{fma_ac_en}} & ir[9:12] |
		{4{fma_ac2_en}} & (ir[9:12]+1);
	wire [0:35] fm = fmem[fma];
	wire fmat1;
	wire fmat2;
	wire fma_fm_arJ =
		fmat1 & mc_wr |
		st1 & mc_fm_en & ~sac_inh |
		st8 & mc_fm_en;

	pa fma_pa1(.clk(clk), .reset(reset),
		.in(mc_rq_set_D & fma_ma_en),
		.p(fmat1));
	pa fma_pa2(.clk(clk), .reset(reset),
		.in(fmat1_D),
		.p(fmat2));

	wire mc_rq_set_D, fmat1_D;
	dly115ns fma_dly1(.clk(clk), .reset(reset), .in(mc_rq_set), .p(mc_rq_set_D));
	dly65ns fma_dly2(.clk(clk), .reset(reset), .in(fmat1), .p(fmat1_D));

	always @(posedge clk) begin
		if(mr_clr | at4 | byt7a) begin
			fma_xr <= 1;
			fma_ac <= 0;
			fma_ac2 <= 0;
		end
		if(at3) begin
			fma_xr <= 0;
			fma_ac <= 1;
		end
		if(ft3 & fac2) begin
			fma_ac <= 0;
			fma_ac2 <= 1;
		end
		if(ft4a) begin
			fma_ac <= 1;
			fma_ac2 <= 0;
		end
		if(fma_fm_arJ)
			fmem[fma] <= ar;
		if(et0 & (ir_ufa | ir_jffo) |
		   st2) begin
			fma_ac <= 0;
			fma_ac2 <= 1;
		end

		if(s_write)
			fmem[s_address[3:0]] <= s_writedata;
	end

	assign s_readdata = fmem[s_address[3:0]];
	assign s_waitrequest = 0;

endmodule
