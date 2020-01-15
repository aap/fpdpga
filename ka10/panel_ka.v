/*
	0	SW DN
	1	SW UP
	2	MAINT DN
	3	MAINT UP
	4	DS LT
	5	DS RT
	6	AS
	7	RPT	TODO
	10	IR	+
	11	MI LT
	12	MI RT
	13	PC
	14	MA
	15	PI

	16	AR LT	+
	17	AR RT
	20	BR LT
	21	BR RT
	22	MQ LT
	23	MQ RT
	24	AD LT	+
	25	AD RT
	26	SC+FE	+
	27	SCAD	+
	30	KEY,OPR
	31	FETCH,STORE,FMA
	32	PR,RL
	33	RLA,MEM
	34	CPA,MISC
	35	REST

	40	TTY
	41	PTP
	42	PTR
	43	PTR B LT
	44	PTR B RT


	XX	IO STATUS

 */

module panel_ka(
	input wire clk,
	input wire reset,

	// Avalon Slave
	input wire [5:0] s_address,
	input wire s_write,
	input wire s_read,
	input wire [31:0] s_writedata,
	output reg [31:0] s_readdata,
	output wire s_waitrequest,

	/* Processor */
	// operator panel keys
	output reg key_sing_inst,
	output reg key_sing_cycle,
	output reg key_par_stop,
	output reg key_nxm_stop,
	output reg key_repeat_sw,
	output reg key_adr_inst,
	output reg key_adr_rd,
	output reg key_adr_wr,
	output reg key_adr_stop,
	output reg key_adr_brk,

	output reg key_rdi_sw,
	output reg key_sta_sw,
	output reg key_cont_sw,
	output reg key_stop_sw,
	output reg key_reset_sw,
	output reg key_exe_sw,
	output reg key_exa_sw,
	output reg key_ex_nxt_sw,
	output reg key_dep_sw,
	output reg key_dep_nxt_sw,

	output reg [0:35] ds,
	output reg [18:35] as,

	// operator panel lights
	input wire ind_run,
	input wire ind_pi_on,
	input wire pwr_on_ind,
	input wire ind_prog_stop,
	input wire ind_user,
	input wire ind_mem_stop,
	input wire [1:7] ind_pih,
	input wire [1:7] ind_pir,
	input wire [1:7] ind_pio,
	input wire [1:7] ind_iob_req,
	input wire [18:35] ind_pc_reg,
	input wire [0:17] ind_ir_reg,
	input wire [18:35] ind_ma_reg,
	input wire [0:35] ind_mi_reg,
	input wire ind_mi_prog,

	// indicators
	input wire [6:0] ind_ar,
	input wire [0:35] ind_ar_reg,
	input wire [0:35] ind_br_reg,
	input wire [0:35] ind_mq_reg,
	input wire [10:0] ind_ad,
	input wire [0:35] ind_ad_reg,
	input wire ind_sc,
	input wire [0:8] ind_sc_reg,
	input wire [0:8] ind_fe_reg,
	input wire [7:0] ind_scad,
	input wire [0:8] ind_scad_reg,
	input wire [2:0] ind_ir,
	input wire [11:0] ind_key,
	input wire [11:0] ind_opr,
	input wire [5:0] ind_fetch,
	input wire [4:0] ind_store,
	input wire [32:35] ind_fma,
	// { [18:25], [18:25] }
	input wire [15:0] ind_pr_reg,
	input wire [15:0] ind_rl_reg,
	input wire [15:0] ind_rla_reg,
	input wire [9:0] ind_mem,
	input wire [4:0] ind_ex,
	input wire [1:0] ind_pi,
	input wire [1:0] ind_byte,
	input wire [13:0] ind_cpa,
	input wire [15:0] ind_misc,
	input wire [2:0] ind_nr,
	input wire [1:0] ind_as,

	// maintenance panel
	output reg sw_power,
	// TODO: repeat
	output reg sc_stop_sw,
	output reg fm_enable_sw,
	output reg key_repeat_bypass_sw,
	output reg mi_prog_dis_sw,
	output reg [3:9] rdi_sel,

	/* TTY */
	input wire [7:0] tty_tti,
	input wire [9:0] tty_status,

	/* PTR */
	output wire ptr_key_tape_feed,
	input wire [35:0] ptr,
	input wire [11:0] ptr_status,

	/* PTP */
	output wire ptp_key_tape_feed,
	input wire [7:0] ptp,
	input wire [6:0] ptp_status,	// also includes motor on

	/*
	 * 340 display
	 */
	input wire [0:13] dis_status,
	input wire [0:35] dis_ib,
	input wire [0:17] dis_br,
	input wire [0:6] dis_brm,
	input wire [0:9] dis_x,
	input wire [0:9] dis_y,
	input wire [1:4] dis_s,
	input wire [0:2] dis_i,
	input wire [0:2] dis_mode,
	input wire [0:1] dis_sz,
	input wire [0:8] dis_flags,
	input wire [0:4] dis_fe,

	/*
	 * External panel
	 */
	input wire [3:0] switches,
	input wire [7:0] ext,
	output reg [7:0] leds
);

	wire ext_sw_power = switches[0];

	// TODO
	assign ptr_key_tape_feed = 0;
	assign ptp_key_tape_feed = 0;

	always @(*) begin
		case(switches[3:1])
		3'b000: leds <= { ind_user, ind_pi_on, ind_prog_stop,
			ind_mem_stop, ind_run, pwr_on_ind };
		3'b001: leds <= tty_tti;
		3'b010: leds <= tty_status;
		3'b100: leds <= ptr_status[5:0];
		3'b101: leds <= ptr_status[11:6];
		3'b111: leds <= ext;
		default: leds <= 0;
		endcase
	end

	always @(*) begin
		case(s_address)
		6'o00: s_readdata <= {
			ind_run,
			pwr_on_ind, ind_prog_stop, ind_user,
			ind_mem_stop, key_sing_inst, key_sing_cycle,
			key_par_stop, key_nxm_stop, key_repeat_sw,
			key_adr_inst, key_adr_rd, key_adr_wr,
			key_adr_stop, key_adr_brk, key_rdi_sw,
			key_sta_sw, key_cont_sw, key_stop_sw,
			key_reset_sw, key_exe_sw, key_exa_sw,
			key_ex_nxt_sw, key_dep_sw, key_dep_nxt_sw
		};
		6'o01: s_readdata <= 0;
		6'o02: s_readdata <= {
			sc_stop_sw, fm_enable_sw,
			key_repeat_bypass_sw, mi_prog_dis_sw,
			rdi_sel
		};
		6'o03: s_readdata <= 0;
		6'o04: s_readdata <= ds[0:17];
		6'o05: s_readdata <= ds[18:35];
		6'o06: s_readdata <= as;
		6'o07: s_readdata <= 0;		// TODO repeat
		6'o10: s_readdata <= { ind_ir, ind_ir_reg };
		6'o11: s_readdata <= { ind_mi_prog, ind_mi_reg[0:17] };
		6'o12: s_readdata <= ind_mi_reg[18:35];
		6'o13: s_readdata <= ind_pc_reg;
		6'o14: s_readdata <= ind_ma_reg;
		6'o15: s_readdata <= {
			ind_iob_req, ind_pih, ind_pir, ind_pio, ind_pi_on
		};
		6'o16: s_readdata <= { ind_ar, ind_ar_reg[0:17] };
		6'o17: s_readdata <= ind_ar_reg[18:35];
		6'o20: s_readdata <= ind_br_reg[0:17];
		6'o21: s_readdata <= ind_br_reg[18:35];
		6'o22: s_readdata <= ind_mq_reg[0:17];
		6'o23: s_readdata <= ind_mq_reg[18:35];
		6'o24: s_readdata <= { ind_ad, ind_ad_reg[0:17] };
		6'o25: s_readdata <= ind_ad_reg[18:35];
		6'o26: s_readdata <= { ind_sc, ind_sc_reg, ind_fe_reg };
		6'o27: s_readdata <= { ind_scad, ind_scad_reg };
		6'o30: s_readdata <= { ind_key, ind_opr };
		6'o31: s_readdata <= { ind_fetch, ind_store, ind_fma };
		6'o32: s_readdata <= { ind_pr_reg, ind_rl_reg };
		6'o33: s_readdata <= { ind_mem, ind_rla_reg };
		6'o34: s_readdata <= { ind_misc, ind_cpa };
		6'o35: s_readdata <= {
			ind_ex, ind_pi, ind_byte, ind_nr, ind_as
		};

		6'o40: s_readdata <= { tty_status, 1'b0, tty_tti };
		6'o41: s_readdata <= { ptp, 2'b0, ptp_status };
		6'o42: s_readdata <= ptr_status;
		6'o43: s_readdata <= ptr[35:18];
		6'o44: s_readdata <= ptr[17:0];
		6'o45: s_readdata <= dis_br;
		6'o46: s_readdata <= { dis_brm, dis_y, dis_x };
		6'o47: s_readdata <= { dis_flags, dis_s, dis_i,
			dis_sz, dis_mode };
		6'o50: s_readdata <= dis_status;
		6'o51: s_readdata <= dis_ib[0:17];
		6'o52: s_readdata <= dis_ib[18:35];
		default: s_readdata <= 0;
		endcase
	end

	assign s_waitrequest = 0;

	always @(posedge clk or negedge reset) begin
		if(~reset) begin
			key_stop_sw <= 0;
			key_exa_sw <= 0;
			key_ex_nxt_sw <= 0;
			key_dep_sw <= 0;
			key_dep_nxt_sw <= 0;
			key_reset_sw <= 0;
			key_exe_sw <= 0;
			key_sta_sw <= 0;
			key_rdi_sw <= 0;
			key_cont_sw <= 0;

			key_sing_inst <= 0;
			key_sing_cycle <= 0;
			key_adr_inst <= 0;
			key_adr_rd <= 0;
			key_adr_wr <= 0;
			key_adr_stop <= 0;
			key_adr_brk <= 0;
			key_par_stop <= 0;
			key_nxm_stop <= 0;
			key_repeat_sw <= 0;

			ds <= 0;
			as <= 0;

			sw_power <= 0;
			sc_stop_sw <= 0;
			fm_enable_sw <= 1;
			key_repeat_bypass_sw <= 0;
			mi_prog_dis_sw <= 0;
			rdi_sel <= 0;
		end else begin
			sw_power <= ext_sw_power;

			if(s_write) case(s_address)
			6'o00: begin
				if(s_writedata[0]) key_dep_nxt_sw <= 1;
				if(s_writedata[1]) key_dep_sw <= 1;
				if(s_writedata[2]) key_ex_nxt_sw <= 1;
				if(s_writedata[3]) key_exa_sw <= 1;
				if(s_writedata[4]) key_exe_sw <= 1;
				if(s_writedata[5]) key_reset_sw <= 1;
				if(s_writedata[6]) key_stop_sw <= 1;
				if(s_writedata[7]) key_cont_sw <= 1;
				if(s_writedata[8]) key_sta_sw <= 1;
				if(s_writedata[9]) key_rdi_sw <= 1;
				if(s_writedata[10]) key_adr_brk <= 1;
				if(s_writedata[11]) key_adr_stop <= 1;
				if(s_writedata[12]) key_adr_wr <= 1;
				if(s_writedata[13]) key_adr_rd <= 1;
				if(s_writedata[14]) key_adr_inst <= 1;
				if(s_writedata[15]) key_repeat_sw <= 1;
				if(s_writedata[16]) key_nxm_stop <= 1;
				if(s_writedata[17]) key_par_stop <= 1;
				if(s_writedata[18]) key_sing_cycle <= 1;
				if(s_writedata[19]) key_sing_inst <= 1;
			end
			6'o01: begin
				if(s_writedata[0]) key_dep_nxt_sw <= 0;
				if(s_writedata[1]) key_dep_sw <= 0;
				if(s_writedata[2]) key_ex_nxt_sw <= 0;
				if(s_writedata[3]) key_exa_sw <= 0;
				if(s_writedata[4]) key_exe_sw <= 0;
				if(s_writedata[5]) key_reset_sw <= 0;
				if(s_writedata[6]) key_stop_sw <= 0;
				if(s_writedata[7]) key_cont_sw <= 0;
				if(s_writedata[8]) key_sta_sw <= 0;
				if(s_writedata[9]) key_rdi_sw <= 0;
				if(s_writedata[10]) key_adr_brk <= 0;
				if(s_writedata[11]) key_adr_stop <= 0;
				if(s_writedata[12]) key_adr_wr <= 0;
				if(s_writedata[13]) key_adr_rd <= 0;
				if(s_writedata[14]) key_adr_inst <= 0;
				if(s_writedata[15]) key_repeat_sw <= 0;
				if(s_writedata[16]) key_nxm_stop <= 0;
				if(s_writedata[17]) key_par_stop <= 0;
				if(s_writedata[18]) key_sing_cycle <= 0;
				if(s_writedata[19]) key_sing_inst <= 0;
			end
			6'o02: begin
				rdi_sel <= rdi_sel | s_writedata[6:0];
				if(s_writedata[7]) mi_prog_dis_sw <= 1;
				if(s_writedata[8]) key_repeat_bypass_sw <= 1;
				if(s_writedata[9]) fm_enable_sw <= 1;
				if(s_writedata[10]) sc_stop_sw <= 1;
			end
			6'o03: begin
				rdi_sel <= rdi_sel & ~s_writedata[6:0];
				if(s_writedata[7]) mi_prog_dis_sw <= 0;
				if(s_writedata[8]) key_repeat_bypass_sw <= 0;
				if(s_writedata[9]) fm_enable_sw <= 0;
				if(s_writedata[10]) sc_stop_sw <= 0;
			end
			6'o04: ds[0:17] <= s_writedata;
			6'o05: ds[18:35] <= s_writedata;
			6'o06: as <= s_writedata;
			// TODO: 07 REPEAT
			endcase
		end
	end

endmodule
