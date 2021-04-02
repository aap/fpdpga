module tty_ka10(
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
	input  wire iobus_rdi_pulse,    // unused on 6
	input  wire [3:9]  iobus_ios,
	input  wire [0:35] iobus_iob_in,
	output wire [1:7]  iobus_pi_req,
	output wire [0:35] iobus_iob_out,
	output wire iobus_dr_split,
	output wire iobus_rdi_data,     // unused on 6

	/* UART pins */
	input wire rx,
	output wire tx,

	/* Panel */
	output wire [7:0] tti_ind,
	output wire [9:0] status_ind
);
	assign iobus_dr_split = 0;
	assign iobus_rdi_data = 0;

	wire tty_sel = iobus_ios == 7'b001_010_0;

	wire tty_reset;
	wire tty_datao_clr;
	wire tty_datao_set;
	wire tty_cono_clr;
	wire tty_cono_set;
	wire tty_datai = tty_sel & iobus_iob_fm_datai;
	wire tty_status = tty_sel & iobus_iob_fm_status;

	pa tty_pa0(clk, reset, iobus_iob_reset, tty_reset);
	// actually a DCD gate
	pa tty_pa1(clk, reset, tty_sel & iobus_datao_clear, tty_datao_clr);
	pa tty_pa2(clk, reset, tty_sel & iobus_datao_set, tty_datao_set);
	pa tty_pa3(clk, reset, tty_sel & iobus_cono_clear | tty_reset, tty_cono_clr);
	pa tty_pa4(clk, reset, tty_sel & iobus_cono_set, tty_cono_set);

	assign tti_ind = ~tti;
	assign iobus_iob_out =
		tty_datai ? { 28'b0, tti_ind } :
		tty_status ? { 24'b0, tty_test, 4'b0,
			tti_busy, tti_flag, tto_busy, tto_flag, tty_pia } :
		36'b0;

	assign status_ind = { tty_test, tti_active, tto_active,
		tti_busy, tti_flag, tto_busy, tto_flag, tty_pia };

	wire [1:7] tty_req = { tti_flag | tto_flag, 7'b0 } >> tty_pia;
	assign iobus_pi_req = tty_req;

	wire tty_datai_posedge;
	pa tty_pa5(clk, reset, tty_datai, tty_datai_posedge);

	reg [33:35] tty_pia;
	reg tti_busy;
	reg tti_flag;
	reg tto_busy;
	reg tto_flag;
	reg tty_test;

	reg [8:1] tti;
	reg tti_stop;
	wire tti_stop_posedge;
	reg tti_active;
	wire tti_active_posedge;
	// actually not exclusive
	wire tti_input = tty_test ? tto_line : ~rx;
	wire tti_input_posedge;
	wire tti_clr;
	wire tti_shift;

	wire tto_clk_110, tto_clk_150;
	clk110hz clk0(clk, 1'b1, tto_clk_110);
	clk150hz clk1(clk, 1'b1, tto_clk_150);
	wire tti_clk_110, tti_clk_150;
	clk110hz clk2(clk, tti_active, tti_clk_110);
	clk150hz clk3(clk, tti_active, tti_clk_150);

`ifdef simulation
	wire tti_clk = tto_clk & tti_active;
`else
	wire tti_clk = tti_clk_110;
`endif
	pa tti_pa0(clk, reset, tti_clk, tti_shift);

//	pa tti_pa1(clk, reset, tty_reset | tti_active_posedge, tti_clr);
	assign tti_clr = tty_reset | tti_active_posedge;
	pa tti_pa2(clk, reset, tti_active, tti_active_posedge);

	pa tti_pa4(clk, reset, tti_stop, tti_stop_posedge);
	pa tti_pa5(clk, reset, tti_input, tti_input_posedge);

	reg [8:1] tto;
	reg tto_enb;
	reg tto_stop;
	reg tto_line;
	reg tto_active;
	wire tto_active_posedge;
	wire tto_active_negedge;
	wire tto_empty = ~tto_stop & tto[8:3] == 0 & (~tto[2] | tty_10_unit_sw);
	wire tto_shift;
	assign tx = ~tto_line;

`ifdef simulation
	reg tto_clk_x = 0;
	always #200 tto_clk_x <= ~tto_clk_x;
	wire tto_clk;
	pa tto_pa0(clk, reset, tto_clk_x, tto_clk);
`else
	wire tto_clk = tto_clk_110;
`endif

	pa tto_pa1(clk, reset, tto_clk & tto_active, tto_shift);
	pa tto_pa2(clk, reset, tto_active, tto_active_posedge);
	pa tto_pa3(clk, reset, ~tto_active, tto_active_negedge);

	reg tty_10_unit_sw = 0;

	always @(posedge clk) begin
		if(tty_reset) begin
			tti_busy <= 0;
			tti_flag <= 0;
			tto_busy <= 0;
			tto_flag <= 0;

			tti_active <= 0;

			tto_enb <= 0;
			tto_stop <= 0;
			tto <= 0;
			tto_active <= 0;
		end
		if(tty_datao_clr) begin
			tto_busy <= 1;
			tto_flag <= 0;
			tto[1] <= 0;
		end
		if(tty_cono_clr) begin
			tty_test <= 0;
			tty_pia <= 0;
		end
		if(tty_cono_set) begin
			if(iobus_iob_in[10] &  tto_flag) tto_flag <= 0;
			if(iobus_iob_in[14] & ~tto_flag) tto_flag <= 1;
			if(iobus_iob_in[9]  &  tto_busy) tto_busy <= 0;
			if(iobus_iob_in[13] & ~tto_busy) tto_busy <= 1;
			if(iobus_iob_in[8]  &  tti_flag) tti_flag <= 0;
			if(iobus_iob_in[12] & ~tti_flag) tti_flag <= 1;
			if(iobus_iob_in[7]  &  tti_busy) tti_busy <= 0;
			if(iobus_iob_in[11] & ~tti_busy) tti_busy <= 1;
			if(iobus_iob_in[6]) tty_test <= 1;
			tty_pia <= tty_pia | iobus_iob_in[15:17];
		end

		if(tti_clr) begin
			tti <= 0;
			tti_stop <= 0;
		end
		if(tti_input_posedge)
			tti_active <= 1;
		if(tti_stop_posedge)
			tti_active <= 0;
		if(tti_shift) begin
			tti_stop <= tti[1];
			tti <= { tti_input, tti[8:2] };
			if(tti == 0 & ~tti_stop & ~tti_input)
				tti_active <= 0;
		end
		if(tti_stop_posedge) begin
			tti_busy <= 0;
			tti_flag <= 1;
		end
		if(tti_active_posedge)
			tti_busy <= 1;
		if(tty_datai_posedge)
			tti_flag <= 0;

		if(tty_datao_set) begin
			tto_enb <= 1;
			tto_stop <= 1;
			tto <= tto | iobus_iob_in[28:35];
		end
		if(tto_clk) begin
			if(tto_empty) tto_active <= 0;
			if(tto_enb) tto_active <= 1;
		end
		if(tto_shift) begin
			tto_enb <= 0;
			tto_stop <= tto_enb;
			tto <= { tto_stop, tto[8:2] };
			tto_line <= ~tto[1];
		end
		if(~tto_active)
			tto_line <= 0;
		if(tto_active_posedge)
			tto_line <= 1;
		if(tto_active_negedge) begin
			tto_busy <= 0;
			tto_flag <= 1;
		end
	end

endmodule
