module td10(
	input wire clk,
	input wire reset,

	/* IO bus */
	input  wire iobus_iob_poweron,
	input  wire iobus_iob_reset,
	input  wire iobus_datao_clear,
	input  wire iobus_datao_set,
	input  wire iobus_cono_clear,
	input  wire iobus_cono_set,
	input  wire iobus_iob_fm_datai,
	input  wire iobus_iob_fm_status,
	input  wire iobus_rdi_pulse,	// unused on 6
	input  wire [3:9]  iobus_ios,
	input  wire [0:35] iobus_iob_in,
	output wire [1:7]  iobus_pi_req,
	output wire [0:35] iobus_iob_out,
	output wire iobus_dr_split,
	output wire iobus_rdi_data,	// unused on 6

	output wire con_go,	// negated stop
	output wire con_fwd,
	output wire con_rev,
	output wire con_all_halt,
/**/	output wire con_pwr_up_dly,
	output wire [0:3] con_select,
	input wire [0:7] con_select_echo,
	input wire con_wrt_echo,
	input wire [0:4] con_read,
	output wire [0:4] con_write,
	output wire con_wr,
	output wire con_wrtm,
	input wire con_wrtm_wait
);
	/* units:
	  switches:
		remote/off/local
		fwd/hold/rev
		address select
		write enable/lock

	  ctl -> transport:
		con stop	COM1
		con go		COM1
		con rev		COM1
		con fwd		COM1
		con all halt	ENB
		con pwr up dly	COM1
		select 0-7	COM2
	  transport -> ctl
		select echo	ERR (?)
		wrt echo	ST
	  ctl <-> transport
		tt		RWA
		mt		RWA
		d0, d1, d2	RWA
	 */
	// TODO:
	reg manual_mode_sw = 0;	//IOB2
	reg manual_clr_sw = 0;	//IOB2
	reg manual_tape_sw = 0;	//IOB2
	reg wrtm_sw = 0;	//ST

	wire manual_mode = manual_mode_sw;
	wire manual_clr = manual_mode & manual_clr_sw;
	wire manual_tape = manual_mode & manual_tape_sw;

	wire crobar = 0;


	assign con_go = com_go;
	assign con_fwd = com_go_fwd;
	assign con_rev = com_go_rev;
	assign con_all_halt = enb_stop_all;
	assign con_pwr_up_dly = 0;
	assign con_select = { com_sel, com_unit };
	assign con_write = { tck[0], rwb[0], rwb[0:2] };
	assign con_wr = t_wren;
	assign con_wrtm = tm_enb;

	assign iobus_dr_split = 0;

	// TODO: alternative code
	wire iob_sel_dtc = iobus_ios == 7'b011_010_0 & ~manual_mode;
	wire iob_sel_dts = iobus_ios == 7'b011_010_1 & ~manual_mode;

	wire iob_reset = iobus_iob_reset & ~manual_mode;

	wire iob_pwr_clr;
	wire iob_dtc_data_clr;
	wire iob_dtc_data_set;
	wire iob_dtc_cono_clr;
	wire iob_dtc_cono_set;
	wire iob_dts_cono_clr;
	wire iob_dts_cono_set;
	wire iob_dtc_datai = iob_sel_dtc & ~crobar & iobus_iob_fm_datai;
	wire iob_dtc_status = iob_sel_dtc & ~crobar & iobus_iob_fm_status;
	wire iob_dts_status = iob_sel_dts & ~crobar & iobus_iob_fm_status;
	wire iob_21_cp_on = iobus_iob_in[21] & ~manual_mode;
	wire maint_datao_clr;
	wire maint_datao_set;
	wire maint_datai = iob_sel_dts & iobus_iob_fm_datai & ~crobar;

	// TODO: or CROBAR
	pa iob_pa0(clk, reset, iob_reset | manual_clr, iob_pwr_clr);
	pa iob_pa1(clk, reset, iob_sel_dtc & iobus_datao_clear, iob_dtc_data_clr);
	pa iob_pa2(clk, reset, iob_sel_dtc & iobus_datao_set, iob_dtc_data_set);
	pa iob_pa3(clk, reset, iob_sel_dtc & iobus_cono_clear | iob_pwr_clr, iob_dtc_cono_clr);
	pa iob_pa4(clk, reset, iob_sel_dts & iobus_cono_clear | iob_pwr_clr, iob_dts_cono_clr);
	pa iob_pa5(clk, reset, iob_sel_dtc & iobus_cono_set, iob_dtc_cono_set);
	pa iob_pa6(clk, reset, iob_sel_dts & iobus_cono_set, iob_dts_cono_set);

	pa iob_pa7(clk, reset, iob_sel_dts & iobus_datao_clear, maint_datao_clr);
	pa iob_pa8(clk, reset, iob_sel_dts & iobus_datao_set, maint_datao_set);

	assign iobus_iob_out =
		iob_dtc_datai ? { ba, bb } :
		iob_dtc_status ? {
			~com_go, com_go_fwd, com_go_rev,
			1'b0, com_sel, ~com_sel,
			com_unit, com_fcn, com_dpi, com_fpi
		} :
		iob_dts_status ? {
			enb_par_err, enb_data_miss, enb_job_done,
			enb_ill_op, enb_end_zone, enb_blk_missed,
			t_wait, t_act, tups1,
			tbn[2], t_rev_cks, t_block,
			t_pre_final, t_fwd_cks, t_stop&~tbn[2],
			enb_bnr, 1'b0, enb_fcn_stop,

			st_par_err, dc_data_miss, st_job_done,
			st_ill_op, st_end_zone, st_blk_missed,
			st_write_lock, st_wrtm, st_inc_blk,
			1'b0, err_mk_trk, err_sel,
			3'b0,
			1'b0, com_flags_req, com_data_pi_req
		} :
		maint_datai ? {
			lp, rwb,
			2'b0, ~mk_bn_space,
			~mk_bn_end, ~mk_data_sync, ~mk_rev_data_end,
			~mk_data, ~mk_fwd_data_end, ~mk_bn_sync
		} :
		36'b0;

	wire [0:7] dpi_req;
	wire [0:7] fpi_req;
	decode8 dpi_dec(com_dpi, com_pi_req_enb, dpi_req);
	decode8 fpi_dec(com_fpi, com_flags_req, fpi_req);
	assign iobus_pi_req = dpi_req[1:7] | fpi_req[1:7];

	reg iob_rd_in;
	wire iob_beg_rd_in;
	wire iob_fin_rd_in;
	assign iobus_rdi_data = dc_data_req & iob_sel_dtc;
	pa_dcd2 iob_pa9(clk, reset,
		iob_rd_in, 1'b1,
		st_end_zone & iob_rd_in, ~com_rev_ff,
		iob_beg_rd_in);
	pa_dcd iob_pa10(clk, reset,
		st_end_zone & iob_rd_in, com_rev_ff,
		iob_fin_rd_in);

	always @(posedge clk) begin
		if(iob_dtc_cono_clr | t_data_strobe)
			iob_rd_in <= 0;
		if(iobus_rdi_pulse & iob_sel_dtc |
		   manual_tape)
			iob_rd_in <= 1;
	end

	reg com_go;
	reg com_rev_ff;
	reg com_rev_dlyd;
	reg com_sel;
	reg com_pi_req_enb;
	wire com_go_fwd = com_go & ~com_rev_dlyd;
	wire com_go_rev = com_go & com_rev_dlyd;
	reg [0:2] com_fcn;
	reg [0:2] com_unit;
	reg [0:2] com_dpi;
	reg [0:2] com_fpi;
	wire com_data_pi_req = dc_data_req & ~enb_fcn_stop;
	wire com_pi_req_enb_set;
	wire com_sel_set;
	wire com_ready_n, com_ready, com_ready_pulse;
	wire com_rev_dlyd_jam;
	wire com_rev = com_rev_ff & ~com_bn;
	wire com_fwd = ~com_rev;

	// for the simulation
	initial begin
		com_go <= 0;
		com_rev_ff <= 0;
		com_rev_dlyd <= 0;
		com_sel <= 0;
		tck <= 0;
		st_job_done <= 0;
	end

	pa_dcd com_pa1(clk, reset, iob_dtc_cono_set, iobus_iob_in[22], com_sel_set);
	pa com_pa2(clk, reset, com_data_pi_req, com_pi_req_enb_set);
	ldly1us com_dly0(.clk(clk), .reset(reset),
		.in(iob_dtc_cono_set), .p(com_ready_pulse), .l(com_ready_n));
	assign com_ready = ~com_ready_n;
	pa com_pa3(clk, reset, com_ready & ~turnaround_dly, com_rev_dlyd_jam);

	wire com_rd = ~com_fcn[0];
	wire com_wr = com_fcn[0];
	wire com_all = com_fcn[1:2] == 1;
	wire com_bn = com_fcn[1:2] == 2;
	wire com_data = com_fcn[1:2] == 3;
	wire com_wr_mt = com_fcn == 4;

	wire com_flags_req = enb_data_miss & dc_data_miss |
		enb_job_done & st_job_done |
		enb_ill_op & st_ill_op |
		enb_end_zone & st_end_zone |
		enb_blk_missed & st_blk_missed |
		enb_par_err & st_par_err;

	always @(posedge clk) begin
		if(iob_pwr_clr) begin
			com_go <= 0;
			com_rev_ff <= 0;
			com_sel <= 0;
		end
		if(iob_dtc_cono_set) begin
			if(iobus_iob_in[18] & com_go)
				com_go <= 0;
			if((iobus_iob_in[19] | iobus_iob_in[20]) & ~com_go)
				com_go <= 1;

			if(iobus_iob_in[19] & com_rev_ff)
				com_rev_ff <= 0;
			if(iobus_iob_in[20] & ~com_rev_ff)
				com_rev_ff <= 1;
		end
		if(st_end_zone & ~iob_rd_in)
			com_go <= 0;
		if(iob_beg_rd_in)
			com_go <= 1;
		if(iob_fin_rd_in)
			com_rev_ff <= 0;
		if(iob_beg_rd_in)
			com_rev_ff <= 1;
		if(iob_beg_rd_in |
		   com_sel_set)	// actually trailing edge. TODO: st_write_lock???
			com_sel <= 1;
		if(iob_beg_rd_in)
			com_rev_dlyd <= 0;
		if(com_rev_dlyd_jam)
			com_rev_dlyd <= com_rev_ff;


		if(iob_pwr_clr)
			com_unit <= 0;
		if(iob_dtc_cono_clr) begin
			com_fcn <= 0;
			com_dpi <= 0;
			com_fpi <= 0;
			if(iobus_iob_in[23])
				com_sel <= 0;
			// actually on trailing edge
			if(iobus_iob_in[23])
				com_unit <= 0;
		end
		if(iob_dtc_cono_set) begin
			com_unit <= com_unit | iobus_iob_in[24:26];
			com_fcn <= com_fcn | iobus_iob_in[27:29];
			com_dpi <= com_dpi | iobus_iob_in[30:32];
			com_fpi <= com_fpi | iobus_iob_in[33:35];
		end
		if(iob_fin_rd_in)
			com_fcn[1:2] <= 2'b11;

		if(com_pi_req_enb_set)
			com_pi_req_enb <= 1;
		if(iob_dtc_datai | enb_fcn_stop |
		   iob_dtc_cono_clr | iob_dtc_data_clr)
			com_pi_req_enb <= 0;
	end

	reg [2:0] tdata;
	reg [2:0] tbn;
	wire tp0;
	wire tp1;
	wire tp1_sp;
	wire t_block0, t_block1, t_block2;
	wire t_stop, t_sync, t_rev_cks, t_block, t_pre_final, t_fwd_cks;
	decode8 t_dec(tdata, 1'b1,
		{ t_stop, t_sync, t_rev_cks,
		  t_block0, t_block1, t_block2,
		  t_pre_final, t_fwd_cks });
	assign t_block = t_block0 | t_block1 | t_block2;
	wire t_cks = t_rev_cks | t_fwd_cks;
	wire t_rwb_comp = tct[0] & ~com_rd;
	wire t_rwb_sh_lt = (tct[0] | tct[1]) & ~t_rwb_comp;
	wire t_pause =
		t_sync & mk_data_end |		// before rev cks
		t_pre_final & mk_data_end |	// before fwd cks
		t_rev_cks & ~mk_rev_data_end |	// in rev cks
		t_fwd_cks & ~mk_fwd_data_end |	// in fwd cks
		t_inact_cond;
	wire t_data_strobe;
	pa_dcd2 t_pa9(clk, reset,
		tp0, t_act & ~tct[1] & (com_wr & ~t_pause | com_rd & ~t_cks),
		t_act, com_wr & ~com_data,
		t_data_strobe);

	pa_dcd2_p t_pa0(clk, reset,
		maint_datao_clr,
		~tck[1], ~tck[0],
		~rwa_tm, rwa_tm_enb,
		tp0);
	pa_dcd2_p t_pa1(clk, reset,
		maint_datao_set,
		~tck[1], tck[0],
		rwa_tm, rwa_tm_enb,
		tp1);
	pa_dcd t_pa2(clk, reset, rwa_tm, rwa_tm_enb, tp1_sp);

	// This looks pretty complicated but they're really just counters
	wire tbn_ct = mk_bn_space & tbn[1];
	wire tbn0_clr = tp0 & (mk_data_sync | mk_bn_space);
	wire tbn0_set = tp0 & (tbn_ct | mk_bn_sync);
	wire tdata0_clr = tp0 & (mk_bn_sync | mk_data_end & ~t_stop);
	wire tdata0_set = tp0 & (mk_data_end & ~t_stop | mk_data_sync);
	always @(posedge clk) begin
		if(t_mcl) begin
			tbn[0] <= 0;
			tdata[0] <= 0;
		end
		if(t_cntrs_cl) begin
			tbn[2:1] <= 0;
			tdata[2:1] <= 0;
		end

		if(tbn0_clr & tbn[0]) begin
			tbn[0] <= 0;
			tbn[1] <= ~tbn[1];
			if(tbn[1])
				tbn[2] <= 1;
		end
		if(tbn0_set & ~tbn[0])
			tbn[0] <= 1;
		if(tp0 & mk_bn_end)
			tbn[2] <= 0;

		if(tdata0_clr & tdata[0]) begin
			tdata[0] <= 0;
			tdata[1] <= ~tdata[1];
			if(tdata[1])
				tdata[2] <= ~tdata[2];
		end
		if(tdata0_set & ~tdata[0])
			tdata[0] <= 1;
	end


	reg [0:1] tct;
	reg [0:1] tck;
	reg tups1;
	wire tups0;
	wire tm_enb = com_wr_mt & ~err_sw & ~crobar;
	wire t_mcl;
	wire t_speed;
	wire t_relay;
	wire turnaround_dly;
	wire t_wait = t_speed | t_relay | turnaround_dly;
	wire t_wait_posedge, t_wait_negedge;

	// no TP DLY since we have a clean signal
	wire rwa_tm_enb = tups1 & ~st_wrtm;
	wire ups_pulse = rwa_tp | (iob_21_cp_on & maint_datao_clr);

	pa t_pa3(clk, reset, t_wait, t_wait_posedge);
	pa t_pa10(clk, reset, ~t_wait, t_wait_negedge);
	ldly66us t_dly0(.clk(clk), .reset(reset),
		.in(iob_pwr_clr | ups_pulse), .l(tups0));

	/* WRTM timing */
	wire t_clock;
	clk120khz clk1(clk, t_clock);
	always @(posedge clk) begin
		if(t_clock & tm_enb & ~con_wrtm_wait)
			tck <= tck - 1;

		if(~com_go | t_wait_posedge)
			tups1 <= 0;
		if(ups_pulse & tups0)
			tups1 <= 1;
	end

	/* delays */
	wire select_pulse, speed_pulse;
	pa_dcd_p t_pa4(clk, reset, iob_pwr_clr, com_sel_set, ~com_sel, select_pulse);
	pa t_pa5(clk, reset, select_pulse | com_go_fwd | com_go_rev, speed_pulse);
	pa_dcd_p t_pa6(clk, reset, speed_pulse, tp0, mk_end_zone, t_mcl);
	/**/ gdly2us /*/ gdly120ms /*/
	t_dly1(.clk(clk), .reset(reset),
		.p(speed_pulse), .l(~iob_21_cp_on), .q(t_speed));
	/**/ gdly2us /*/ gdly1ms /*/
	t_dly2(.clk(clk), .reset(reset),
		.p(select_pulse), .l(~t_relay), .q(t_relay));
	wire turnaround_start;
	pa_dcd2_p t_pa7(clk, reset,
		iob_pwr_clr,
		com_rev_ff, com_go,
		~com_rev_ff, com_go,
		turnaround_start);
	/**/ gdly2us /*/ gdly200ms /*/
	t_dly3(.clk(clk), .reset(reset),
		.p(turnaround_start), .l(1'b1), .q(turnaround_dly));

	wire t_rd_fwd = com_rd & com_fwd & tct==0;
	wire t_rd_rev = com_rd & com_rev & tct==0;
	wire t_wr_fwd = com_wr & com_fwd & tct==0 & ~t_pause;
	wire t_wr_rev = com_wr & com_rev & tct==0 & ~t_pause;
	wire t_wr_lp = com_wr & tct==0 & t_pause;

	always @(posedge clk) begin
		if(t_mcl)
			tct <= 0;
		if(tp1) tct[0] <= 0;
		if(tp0) tct[0] <= 1;
		if(tp1) begin
			if(t_act)
				tct[1] = ~tct[1];
			else
				tct[1] = 0;
		end
	end


	reg t_act;
	reg t_wren;
	wire t_act_cond =
		com_bn & tbn[0] & tbn_ct & ~st_job_done |
		com_data & mk_data_end & t_sync & ~st_job_done |
		com_all & mk_bn_sync & ~st_job_done |
		com_wr_mt & ~t_wait;
	wire t_inact_cond = (com_fcn[1] | enb_fcn_stop) &
		(mk_bn_sync | mk_bn_end | com_wr_mt |
		 tbn_ct & tbn[0] |
		 t_sync & mk_data_end |
		 t_fwd_cks & mk_data_end);
	wire t_cntrs_cl;

	pa_dcd_p t_pa8(clk, reset,
		t_mcl,
		tp0, (mk_bn_sync | mk_data_sync),
		t_cntrs_cl);

	always @(posedge clk) begin
		if(iob_dtc_cono_clr) begin
			t_act <= 0;
			t_wren <= 0;
		end
		if(crobar)
			t_wren <= 0;
		if(tp0) begin
			if(t_act_cond & ~t_act) begin
				t_act <= 1;
				if(com_wr & ~err_sw)
					t_wren <= 1;
			end
			if(t_inact_cond & t_act) begin
				t_act <= 0;
				t_wren <= 0;
			end
		end
	end


	reg [0:5] lp;
	reg err_ct2;
	reg err_ct3;
	reg err_ck;
	reg err_mk_trk;
	wire err_mk_time = ~tct[1] & ~err_ct2;
	wire err_sw = st_wrtm != com_wr_mt |
		st_write_lock & com_wr |
		err_sel & com_sel;
	wire err_sel =
		(con_select_echo[0] + con_select_echo[1] +
		con_select_echo[2] + con_select_echo[3] +
		con_select_echo[4] + con_select_echo[5] +
		con_select_echo[6] + con_select_echo[7]) != 1;

	wire tct1_falling;
	wire lp_clr;
	wire lp_comp;
	pa err_pa0(clk, reset, ~tct[1], tct1_falling);
	pa_dcd err_pa1(clk, reset, ~err_ct3, t_rev_cks, lp_clr);
	pa_dcd err_pa2(clk, reset,
		tp0, ~tct[1]&~t_rev_cks | t_rev_cks&mk_data_end,
		lp_comp);

	always @(posedge clk) begin
		if(lp_comp)
			lp <= lp ^ ~rw_data_buf;
		if(lp_clr)
			lp <= 0;
		if(t_sync)
			lp <= 6'o77;

		if(t_cntrs_cl) begin
			err_ct2 <= 0;
			err_ct3 <= 0;
		end
		if(tct1_falling) begin
			if(err_ct3 & err_ct2)
				err_ct2 <= 0;
			if(~err_ct2)
				err_ct2 <= 1;

			if(err_ct3)
				err_ct3 <= 0;
			if(err_ct2 & ~err_ct3)
				err_ct3 <= 1;
		end

		if(t_mcl | tp1 & mk_bn_sync)
			err_ck <= 0;
		if(tp0 & mk_bn_end)
			err_ck <= 1;

		if(iob_dtc_cono_clr)
			err_mk_trk <= 0;
		if(tp1 & err_ck & t_act & mk_pres != err_mk_time)
			err_mk_trk <= 1;
		if(tp0 & (mk_data_sync | mk_bn_sync) & (tbn != 0 & tdata != 0))
			err_mk_trk <= 1;
	end


	reg st_par_err;
	reg st_job_done;
	reg st_ill_op;
	reg st_end_zone;
	reg st_blk_missed;
	reg st_inc_blk;
	wire st_wrtm = wrtm_sw;
	wire st_write_lock = ~con_wrt_echo;

	wire dc_ct_negedge;
	wire enb_fcn_stop_posedge;
	pa st_pa0(clk, reset, ~dc_ct, dc_ct_negedge);
	pa st_pa1(clk, reset, enb_fcn_stop, enb_fcn_stop_posedge);

	always @(posedge clk) begin
		if(iob_dtc_cono_clr) begin
			st_par_err <= 0;
			st_job_done <= 0;
			st_ill_op <= 0;
			st_end_zone <= 0;
			st_blk_missed <= 0;
			st_inc_blk <= 0;
		end

		if(err_mk_trk |
		   tp1 & (t_fwd_cks & err_ct2 & ~err_ct3 & lp != 6'o77))
			st_par_err <= 1;

		if(tp1 & enb_fcn_stop & ~t_act &
		   (~com_fcn[0] | com_wr & dc_data_req))
			st_job_done <= 1;

		if((t_data_strobe | t_wait_negedge) & err_sw)
			st_ill_op <= 1;

		if(iob_fin_rd_in | iob_beg_rd_in)
			st_end_zone <= 0;
		if(tp0 & mk_end_zone)
			st_end_zone <= 1;

		if(com_ready_pulse & ~enb_bnr & com_data)
			st_blk_missed <= 1;

		if(dc_ct_negedge & enb_fcn_stop & com_rd |
		   enb_fcn_stop_posedge & dc_data_req & com_rd |
		   t_data_strobe & enb_fcn_stop & ~err_ct2 & dc_ct & dc_data_req)
			st_inc_blk <= 1;
	end


	reg enb_par_err;
	reg enb_data_miss;
	reg enb_job_done;
	reg enb_ill_op;
	reg enb_end_zone;
	reg enb_blk_missed;
	reg enb_bnr;
	reg enb_fcn_stop;
	wire enb_stop_all;

	wire t_rev_cks_edge, t_act_edge;
	pa enb_pa0(clk, reset, t_rev_cks, t_rev_cks_edge);
	pa enb_pa1(clk, reset, t_act, t_act_edge);
	ldly1us enb_dly0(.clk(clk), .reset(reset),
		.in(iob_pwr_clr | iob_dts_cono_clr&iobus_iob_in[34]),
		.l(enb_stop_all));

	always @(posedge clk) begin
		if(iob_dts_cono_clr) begin
			enb_par_err <= 0;
			enb_data_miss <= 0;
			enb_job_done <= 0;
			enb_ill_op <= 0;
			enb_end_zone <= 0;
			enb_blk_missed <= 0;
		end
		if(iob_dts_cono_set) begin
			if(iobus_iob_in[18]) enb_par_err <= 1;
			if(iobus_iob_in[19]) enb_data_miss <= 1;
			if(iobus_iob_in[20]) enb_job_done <= 1;
			if(iobus_iob_in[21]) enb_ill_op <= 1;
			if(iobus_iob_in[22]) enb_end_zone <= 1;
			if(iobus_iob_in[23]) enb_blk_missed <= 1;
		end

		if(iob_dtc_cono_clr)
			enb_fcn_stop <= 0;
		if(iob_dts_cono_set & iobus_iob_in[35] |
		   dc_data_miss)
			enb_fcn_stop <= 1;

		if(t_mcl | t_rev_cks_edge)
			enb_bnr <= 0;
		if(t_act_edge & com_bn)
			enb_bnr <= 1;
	end


	reg [0:8] mk;
	wire mk_bn_space = mk[0] & mk[3:8] == 6'o25;
	wire mk_bn_end = mk == 9'o526;
	wire mk_data_sync = mk == 9'o632;
	wire mk_rev_data_end = mk[0] & mk[2:8] == 7'o010;
	wire mk_data = mk == 9'o470;
	wire mk_fwd_data_end = mk[0] & mk[1]==mk[2] & mk[3:8] == 6'o73;
	wire mk_bn_sync = mk == 9'o751;
	wire mk_end_zone = mk == 9'o622;
	wire mk_data_end = mk_fwd_data_end | mk_rev_data_end;
	wire mk_pres = mk_bn_end | mk_bn_sync |
		mk_fwd_data_end | mk_rev_data_end |
		mk_data_sync | mk_data;

	always @(posedge clk) begin
		if(t_mcl)
			mk <= 0;
		if(tp1) begin
			mk[0] <= mk[0] | mk[1];
			mk[1:7] <= mk[2:8];
		end
		if(tp1_sp)
			mk[8] <= rwa_mk_trk;
		if(maint_datao_set)
			mk[8] <= iobus_iob_in[35];
	end


	reg dc_swap;
	reg dc_wr_setup = 0;
	reg dc_ct;
	reg dc_data_req;
	reg dc_data_miss;
	reg dc_data_need;
	wire dct1;
	wire dct2;
	wire dct2a;
	wire dct3;
	wire dct3a;
	wire dct4;
	wire dct5;
	wire dct6;
	wire dc_sh_clr;
	wire dc_load_sh;
	wire dc_sh_shift;
	wire dc_shift_rw_data;
	wire dc_end_ard;
	wire dc_write_AND_ct0 = com_wr & ~dc_ct;

	pa_dcd_p dc_pa0(clk, reset,
		t_data_strobe,
		dct6, dc_wr_setup,
		dct1);
	dly1us dc_dly0(clk, reset, dct1, dct2);
	dly1us dc_dly1(clk, reset,
		dct2 & (~err_ct2 & com_rd |	// every third shift (18 bits)
		        err_ct3 & com_wr & ~dc_wr_setup),
		dct2a);
	pa_dcd_p dc_pa1(clk, reset,
		dct2a,
		com_ready, ~com_rd,
		dct3);
	pa_dcd2 dc_pa2(clk, reset,
		dct3, com_rd & com_rev,
		dct2, ~com_fwd,
		dct3a);
	wire start_dct4;
	pa_dcd2_p dc_pa3(clk, reset,
		dct3 & ~dc_write_AND_ct0,
		dct5, dc_swap,
		~com_data_pi_req & dc_data_need, 1'b1,
		start_dct4);
	dly1us dc_dly2(clk, reset, start_dct4, dct4);
	dly1us dc_dly3(clk, reset, dct4, dct5);
	pa dc_pa4(clk, reset, dct5 & ~dc_swap, dct6);

	pa dc_pa5(clk, reset, dct1 | dct3a, dc_sh_shift);
	pa dc_pa6(clk, reset, dct1 & ~dc_wr_setup, dc_shift_rw_data);
	pa dc_pa7(clk, reset, dct1 & dc_wr_setup | dct3a, dc_end_ard);
	pa dc_pa8(clk, reset, dct4 & (~com_rd | dc_swap), dc_load_sh);
	pa dc_pa9(clk, reset, dct3 & ~com_rd | dct5 & dc_swap, dc_sh_clr);

	wire dc_data_rq_clr;
	wire dc_data_rq_set;
	pa dc_pa10(clk, reset, ~iob_dtc_datai, dc_data_rq_clr);
	pa dc_pa11(clk, reset, ~dc_ct, dc_data_rq_set);

	always @(posedge clk) begin
		if(iob_dtc_cono_clr) begin
			dc_swap <= 0;
			dc_wr_setup <= 0;
			dc_ct <= 0;
			dc_data_req <= 0;
			dc_data_miss <= 0;
			dc_data_need <= 0;
		end
		if(dct6)
			dc_ct <= ~dc_ct;

		if(iob_dtc_data_set | dc_data_rq_clr)
			dc_data_req <= 0;
		if(iob_dtc_cono_set & iobus_iob_in[27] | dc_data_rq_set)
			dc_data_req <= 1;

		if(dct3 & com_data_pi_req & com_rd & ~iob_rd_in |
		   t_data_strobe & (dc_data_need | dc_wr_setup))
			dc_data_miss <= 1;

		if(dct5)
			dc_data_need <= 0;
		if(dct3 & dc_write_AND_ct0)
			dc_data_need <= 1;

		if(dct4 & com_rev & (com_wr & ~dc_ct | com_rd & dc_ct))
			dc_swap <= ~dc_swap;

		if(dct2)
			dc_wr_setup <= 0;
		if(dct4 & com_wr & com_rev)
			dc_wr_setup <= 1;
	end


	reg [0:17] sh;
	always @(posedge clk) begin
		if(dc_sh_clr)
			sh <= 0;
		if(dc_sh_shift) begin
			sh[0:5] <= sh[6:11];
			sh[6:11] <= sh[12:17];
		end
		if(dc_shift_rw_data)
			sh[12:17] <= rw_data_buf;
		if(dc_end_ard)
			sh[12:17] <= sh[0:5];
		if(dc_load_sh)
			sh <= sh | ba;
	end


	reg [0:17] ba;
	reg [0:17] bb;

	always @(posedge clk) begin
		if(iob_dtc_data_clr) begin
			ba <= 0;
			bb <= 0;
		end
		if(iob_dtc_data_set) begin
			ba <= iobus_iob_in[0:17];
			bb <= iobus_iob_in[18:35];
		end
		if(dct5) begin
			ba <= bb;
			bb <= sh;
		end
	end


	reg [0:5] rwb;
	wire [0:5] rw_data =
		{6{t_wr_fwd}} & sh[0:5] |
		{6{t_wr_rev}} & {~sh[3:5], ~sh[0:2]} |
		{6{t_rd_fwd}} & rwb[0:5] |
		{6{t_rd_rev}} & {~rwb[3:5], ~rwb[0:2]} |
		{6{t_wr_lp}} & lp |
		{6{t_rwb_sh_lt}} & {rwb[3:5], rwa[0:2]} |
		{6{t_rwb_comp}} & {~rwb[0:2], rwb[3:5]};
	wire rwb_strobe;
	pa_dcd_p rw_pa0(clk, reset,
		tp1,
		tp0, ~com_rd,
		rwb_strobe);

	/* RW DATA is very timing critical and has to hold for a while */
	reg [0:23] rw_data_dly;
	wire [0:5] rw_data_buf = rw_data_dly[0:5];
	always @(posedge clk) begin
		rw_data_dly <= { rw_data_dly[6:23], rw_data };
		if(rwb_strobe)
			rwb <= rw_data_buf;
	end


	wire rwa_tm = tm_enb ? tck[0] : con_read[0];
	wire rwa_mk_trk = tm_enb ? rwb[0] : con_read[1];
	wire [0:2] rwa = t_wren ? rwb[0:2] : con_read[2:4];
	wire rwa_tp;
	pa rwa_pa0(clk, reset, rwa_tm, rwa_tp);
endmodule
