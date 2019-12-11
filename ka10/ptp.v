module ptp_ka10(
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

	/* Console panel */
	input wire key_tape_feed,
	output wire [7:0] ptp_ind,
	output wire [6:0] status_ind,

	/* Avalon slave */
	input wire s_read,
	input wire s_write,
	output wire [31:0] s_readdata,
	input wire [31:0] s_writedata,

	output wire fe_data_rq
);
	assign iobus_dr_split = 0;
	assign iobus_rdi_data = 0;

	assign ptp_ind = ptp;
	assign status_ind = { ptp_no_tape, ptp_bin, ptp_busy, ptp_done, ptp_pia };


	wire ptp_sel = iobus_ios == 7'b001_000_0;

	wire ptp_datao_clr;
	wire ptp_datao_set;
	wire ptp_cono_clr;
	wire ptp_cono_set;
	wire iob_reset;
	wire ptp_datai = ptp_sel & iobus_iob_fm_datai;
	wire ptp_status = ptp_sel & iobus_iob_fm_status;
	wire ptp_start_clr, ptp_stop_clr;
	wire ptp_busy_set;
	pa ptp_pa0(clk, reset, ptp_sel & iobus_datao_clear, ptp_datao_clr);
	pa ptp_pa1(clk, reset, ptp_sel & iobus_datao_set, ptp_datao_set);
	pa ptp_pa2(clk, reset, ptp_sel & iobus_cono_clear | iob_reset, ptp_cono_clr);
	pa ptp_pa3(clk, reset, ptp_sel & iobus_cono_set, ptp_cono_set);
	pa ptp_pa4(clk, reset, iobus_iob_reset, iob_reset);

	reg ptp_no_tape;
	reg [8:1] ptp_hole;
	wire [8:1] ptp;
	assign ptp[8] = (ptp_hole[8] | ptp_bin) & ptp_busy;
	assign ptp[7] = ptp_hole[7] & ~ptp_bin;
	assign ptp[6:1] = ptp_hole[6:1];

	assign iobus_iob_out =
		ptp_status ? { 29'b0, ptp_no_tape, ptp_bin, ptp_busy, ptp_done, ptp_pia } :
		36'b0;

	wire [1:7] ptp_req = { ptp_done, 7'b0 } >> ptp_pia;
	assign iobus_pi_req = ptp_req;

	reg [33:35] ptp_pia;
	reg ptp_busy;
	reg ptp_done;
	reg ptp_bin;

`ifdef simulation
	initial begin
		ptp_busy <= 0;
		ptp_done <= 0;
		ptp_bin <= 0;
	end
`endif

	always @(posedge clk) begin
		if(ptp_cono_clr) begin
			ptp_pia <= 0;
			ptp_busy <= 0;
			ptp_done <= 0;
			ptp_bin <= 0;
		end
		if(ptp_cono_set) begin
			ptp_pia <= iobus_iob_in[15:17];
			if(iobus_iob_in[14])
				ptp_done <= 1;
			if(iobus_iob_in[13])
				ptp_busy <= 1;
			if(iobus_iob_in[12])
				ptp_bin <= 1;
		end

		if(ptp_datao_clr) begin
			ptp_busy <= 1;
			ptp_done <= 0;
		end
		if(ptp_done_pulse) begin
			ptp_busy <= 0;
			ptp_done <= 1;
		end

		if(ptp_datao_clr |
		   key_tape_feed & ~ptp_busy)	// Actually a pulse
			ptp_hole <= 0;
		if(ptp_datao_set)
			ptp_hole <= ptp_hole | iobus_iob_in[28:35];
	end


	wire ptp_go = ptp_busy | key_tape_feed;

	wire start_dly;
	wire motor_on, on_pulse;
	wire scr_driver = motor_on;	// TODO: PWR CLR

	wire ptp_done_pulse;
	wire ptp_speed = ~start_dly & motor_on_dly[1];
`ifdef simulation
	ldly2us ptp_dly0(.clk(clk), .reset(reset), .in(ptp_go), .l(motor_on));
	ldly1us ptp_dly1(.clk(clk), .reset(reset), .in(on_pulse & ptp_go), .l(start_dly));
`else
	ldly5s ptp_dly0(.clk(clk), .reset(reset), .in(ptp_go), .l(motor_on));
	ldly1s ptp_dly1(.clk(clk), .reset(reset), .in(on_pulse & ptp_go), .l(start_dly));
`endif

	pa ptp_pa5(clk, reset, motor_on, on_pulse);

	/* Have to delay the signal a bit so we don't get a glitch in ptp_speed */
	reg [1:0] motor_on_dly;
	always @(posedge clk)
		if(reset)
			motor_on_dly <= 0;
		else
			motor_on_dly <= { motor_on_dly[0], motor_on };


	// front end interface
	assign fe_data_rq = fe_req;
	assign s_readdata = ptp_write_sync ? ptp_hole : 0;
	reg fe_req;
	reg fe_rs;
	wire ptp_sync;
	// gates buffer to solenoid drivers, sync_end when done
	wire ptp_sync_del;
	wire ptp_sync_end;
	// want to synchronize with the FE, so we'll actually use these two
	reg ptp_write_sync;
	reg ptp_done_sync;

	wire ptp_ready = ptp_speed & (ptp_busy | key_tape_feed);
`ifdef simulation
	clk50khz ptp_clk0(clk, ptp_sync);
	ldly2us ptp_dly2(clk, reset, ptp_sync & ptp_ready, ptp_sync_end, ptp_sync_del);
`else
	clk63_3hz ptp_clk0(clk, ptp_sync);
	ldly10ms ptp_dly2(clk, reset, ptp_sync & ptp_ready, ptp_sync_end, ptp_sync_del);
`endif
	pa ptp_pa6(clk, reset, fe_rs & ptp_done_sync, ptp_done_pulse);

	always @(posedge clk) begin
		if(reset) begin
			ptp_no_tape <= 1;
			ptp_write_sync <= 0;
			ptp_done_sync <= 0;
			fe_req <= 0;
			fe_rs <= 0;
		end else begin
			if(ptp_sync & ptp_ready) begin
				fe_req <= 1;
				fe_rs <= 0;
			end
			if(s_read) begin
				fe_req <= 0;
				fe_rs <= 1;
			end

			if(ptp_sync_end)
				ptp_done_sync <= 1;
			if(ptp_done_pulse) begin
				ptp_write_sync <= 0;
				ptp_done_sync <= 0;
			end
			if(ptp_sync_del)
				ptp_write_sync <= 1;

			if(s_write)
				ptp_no_tape <= s_writedata;
		end
	end

endmodule
