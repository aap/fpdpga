`default_nettype none
`timescale 1ns/1ns
`define simulation

module tb_tty();

	wire clk, reset;
	clock clock(clk, reset);

	reg read = 0;
	wire [31:0] readdata;
	reg [31:0] data;

	reg iobus_iob_poweron = 1;
	reg iobus_iob_reset = 0;
	reg iobus_datao_clear = 0;
	reg iobus_datao_set = 0;
	reg iobus_cono_clear = 0;
	reg iobus_cono_set = 0;
	reg iobus_iob_fm_datai = 0;
	reg iobus_iob_fm_status = 0;
	reg [3:9]  iobus_ios = 0;
	reg [0:35] iobus_iob_in = 0;
	wire [1:7]  iobus_pi_req;
	wire [0:35] iobus_iob_out;

	reg key_tape_feed = 0;

	wire data_rq;

	tty_ka10 tty(.clk(clk), .reset(~reset),

		.iobus_iob_poweron(iobus_iob_poweron),
		.iobus_iob_reset(iobus_iob_reset),
		.iobus_datao_clear(iobus_datao_clear),
		.iobus_datao_set(iobus_datao_set),
		.iobus_cono_clear(iobus_cono_clear),
		.iobus_cono_set(iobus_cono_set),
		.iobus_iob_fm_datai(iobus_iob_fm_datai),
		.iobus_iob_fm_status(iobus_iob_fm_status),
		.iobus_ios(iobus_ios),
		.iobus_iob_in(iobus_iob_in),
		.iobus_pi_req(iobus_pi_req),
		.iobus_iob_out(iobus_iob_out),

		.rx(rx),
		.tx(tx));

	wire rx = 1;
	wire tx;

	initial begin
		$dumpfile("dump.vcd");
		$dumpvars();

		#100;
		iobus_iob_reset <= 1;
		#100;
		iobus_iob_reset <= 0;
		#100;
		iobus_ios <= 7'b001_010_0;


		tty.tty_test <= 1;

		#200;
		iobus_datao_clear <= 1;
		iobus_iob_in <= 'o134;
		@(posedge clk);
		iobus_datao_clear <= 0;
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		iobus_datao_set <= 1;
		@(posedge clk);
		iobus_datao_set <= 0;

		@(posedge tty.tto_flag);
		@(posedge clk);
		iobus_datao_clear <= 1;
		iobus_iob_in <= 'o222;
		@(posedge clk);
		iobus_datao_clear <= 0;
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		iobus_datao_set <= 1;
		@(posedge clk);
		iobus_datao_set <= 0;
	end

	initial begin
		#50000;
		$finish;
	end
endmodule
