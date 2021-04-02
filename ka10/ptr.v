module ptr_ka10(
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
	output wire [35:0] ptr_ind,
	output wire [11:0] status_ind,

	/* Avalon slave */
	input wire s_write,
	input wire [31:0] s_writedata,

	output wire fe_data_rq
);
	assign iobus_dr_split = 0;
	assign iobus_rdi_data = ptr_sel & ptr_done;

	wire ptr_sel = iobus_ios == 7'b001_000_1;

	wire ptr_reset;
	wire ptr_datao_clr;
	wire ptr_datao_set;
	wire ptr_cono_clr;
	wire ptr_cono_set;
	wire ptr_datai = ptr_sel & iobus_iob_fm_datai;
	wire ptr_status = ptr_sel & iobus_iob_fm_status;

	pa ptr_pa0(clk, reset, iobus_iob_reset, ptr_reset);
	pa ptr_pa1(clk, reset, ptr_sel & iobus_datao_clear, ptr_datao_clr);
	pa ptr_pa2(clk, reset, ptr_sel & iobus_datao_set, ptr_datao_set);
	pa ptr_pa3(clk, reset, ptr_sel & iobus_cono_clear | ptr_reset, ptr_cono_clr);
	pa ptr_pa4(clk, reset, ptr_sel & iobus_cono_set, ptr_cono_set);

	assign iobus_iob_out =
		ptr_datai ? ptr :
		ptr_status ? { ptr_tape, 2'b0, ptr_bin, ptr_busy, ptr_done, ptr_pia } :
		36'b0;

	assign ptr_ind = ptr;
	assign status_ind = { ptr_enable, ptr_power, ptr_tape,
		ptr_bin, ptr_busy, ptr_done,
		ptr_cnt, ptr_pia };

	wire [1:7] ptr_req = { ptr_done, 7'b0 } >> ptr_pia;
	assign iobus_pi_req = ptr_req;

	wire ptr_datai_posedge;
	wire ptr_datai_negedge;
	pa ptr_pa5(clk, reset, ptr_datai, ptr_datai_posedge);
	pa ptr_pa6(clk, reset, ~ptr_datai, ptr_datai_negedge);

	reg [33:35] ptr_pia;
	reg ptr_bin;
	reg ptr_busy;
	reg ptr_done;
	reg ptr_tape;
	reg ptr_tape_sync;
	wire ptr_tape_posedge;

	pa ptr_pa11(clk, reset, ptr_tape, ptr_tape_posedge);

	// A and B control a stepper motor, moving when ptr_enable
	reg ptr_a;
	reg ptr_b;
	reg ptr_power;
	reg ptr_enable;
	reg [0:2] ptr_cnt;

	wire ptr_run_posedge;
	wire ptr_enable_negedge;
	pa ptr_pa9(clk, reset, ptr_run, ptr_run_posedge);
	pa ptr_pa10(clk, reset, ~ptr_enable, ptr_enable_negedge);

	wire ptr_run = key_tape_feed | ptr_busy;
	wire ptr_shutdown;
	wire ptr_shutdown_pulse;

	wire ptr_clk;
	wire ptr_clk_dly;
`ifdef simulation
	clk500khz ptr_clk0(clk, ptr_enable, ptr_clk);
	ldly2us ptr_dly1(clk, reset, ptr_enable_negedge, ptr_shutdown_pulse, ptr_shutdown);
`else
	clk600hz ptr_clk0(clk, ptr_enable, ptr_clk);
	ldly40ms ptr_dly1(clk, reset, ptr_enable_negedge, ptr_shutdown_pulse, ptr_shutdown);
`endif
	dly1us ptr_dly0(clk, reset, ptr_clk, ptr_clk_dly);
	wire ptr_strobe = ptr_clk_dly & ptr_strobe_en & fe_rs;
	wire ptr_motor_shift = ptr_clk_dly & ptr_enable;

	wire ptr_enable_set;
	pa ptr_pa7(clk, reset, ptr_run & ~ptr_shutdown, ptr_enable_set);

	wire ptr_data_phase = ptr_a == ptr_b;
	wire ptr_strobe_en = ptr_data_phase & (hole[8] | ~ptr_bin) & ptr_busy;
	wire ptr_last = ~ptr_bin | ptr_cnt == 5;

	wire ptr_clr;
	pa ptr_pa8(clk, reset, ptr_busy, ptr_clr);


	reg [0:35] ptr;

`ifdef simulation
	initial begin
		ptr_a <= 0;
		ptr_b <= 0;
		ptr_tape_sync <= 0;

		// TODO: check this
		hole <= 0;
	end
`endif

	always @(posedge clk) begin
		if(ptr_reset) begin
			ptr_tape <= 0;

			ptr_enable <= 0;
		end
		if(ptr_cono_clr) begin
			ptr_bin <= 0;
			ptr_busy <= 0;
			ptr_done <= 0;
			ptr_pia <= 0;

			ptr_power <= 0;
		end

		if(ptr_cono_set) begin
			if(iobus_iob_in[12]) ptr_bin <= 1;
			if(iobus_iob_in[13]) ptr_busy <= 1;
			if(iobus_iob_in[14]) ptr_done <= 1;
			ptr_pia <= ptr_pia | iobus_iob_in[15:17];
		end

		if(iobus_rdi_pulse & ptr_sel) begin
			ptr_bin <= 1;
			ptr_busy <= 1;
		end
		if(ptr_datai_negedge)
			ptr_busy <= 1;
		if(ptr_datai_posedge)
			ptr_done <= 0;
		if(ptr_strobe & ptr_last) begin
			ptr_busy <= 0;
			ptr_done <= 1;
		end
		if(ptr_tape_posedge & ~ptr_busy)
			ptr_done <= 1;

		if(ptr_motor_shift) begin
			ptr_power <= 1;

			ptr_tape <= ~ptr_tape_sync;
			ptr_tape_sync <= hole[9];	// get end of tape from FE

			if(ptr_a & ptr_b) ptr_a <= 0;
			if(~ptr_a & ~ptr_b) ptr_a <= 1;
			if(ptr_b & ~ptr_a) ptr_b <= 0;
			if(~ptr_b & ptr_a) ptr_b <= 1;
		end
		if(ptr_shutdown_pulse & ~ptr_run)
			ptr_power <= 0;

		if(ptr_clk & ~ptr_run)
			ptr_enable <= 0;
		if(ptr_enable_set)
			ptr_enable <= 1;

		if(ptr_clr)
			ptr_cnt <= 0;
		if(ptr_strobe)
			ptr_cnt <= ptr_cnt + 1;


		if(ptr_clr)
			ptr <= 0;
		if(ptr_strobe) begin
			if(ptr_bin)
				ptr <= { ptr[6:35], hole[6:1] };
			else
				ptr <= { ptr[6:35], 6'b0 } | hole[8:1];
		end
	end


	// front end interface
	assign fe_data_rq = fe_req;
	reg fe_req;     // requesting data from FE
	reg fe_rs;      // FE responded with data
	reg [9:1] hole; // FE data

	// request when we turn on the motor
	// and after each line that wasn't a last one.
	// we use run's edge because enable will stay on after last.
	wire fe_set_req = ptr_run_posedge |
		ptr_motor_shift & ptr_data_phase & fe_rs & (~ptr_last | ~ptr_busy);

	always @(posedge clk) begin
		if(~ptr_enable) begin
			fe_req <= 0;
			fe_rs <= 0;
		end
		// start FE request
		if(fe_set_req) begin
			fe_req <= 1;
			fe_rs <= 0;
		end
		// got response from FE
		if(s_write & fe_req) begin
			hole <= s_writedata[8:0];
			fe_req <= 0;
			fe_rs <= 1;
		end
	end
endmodule
