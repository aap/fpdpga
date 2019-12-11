`default_nettype none
`timescale 1ns/1ns
`define simulation

module tb_ptr();

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

	reg av_write = 0;
	reg [31:0] av_writedata = 'o372;

	reg key_tape_feed = 0;

	wire data_rq;

	ptr_ka10 ptr(.clk(clk), .reset(~reset),

		.iobus_iob_poweron(iobus_iob_poweron),
		.iobus_iob_reset(iobus_iob_reset),
		.iobus_datao_clear(iobus_datao_clear),
		.iobus_datao_set(iobus_datao_set),
		.iobus_cono_clear(iobus_cono_clear),
		.iobus_cono_set(iobus_cono_set),
		.iobus_iob_fm_datai(iobus_iob_fm_datai),
		.iobus_iob_fm_status(iobus_iob_fm_status),
		.iobus_rdi_pulse(1'b0),
		.iobus_ios(iobus_ios),
		.iobus_iob_in(iobus_iob_in),
		.iobus_pi_req(iobus_pi_req),
		.iobus_iob_out(iobus_iob_out),

		.key_tape_feed(key_tape_feed),

		.s_write(av_write),
		.s_writedata(av_writedata));

	initial begin: av
		integer i;
		while(1) begin
			@(posedge ptr.fe_req);
//			for(i = 0; i < 320; i = i + 1)
				@(posedge clk);

			av_write <= 1;
			@(posedge clk);
			av_write <= 0;
			av_writedata <= av_writedata + 1;
		end
	end

	initial begin
		$dumpfile("dump.vcd");
		$dumpvars();

		#100;
		iobus_iob_reset <= 1;
		#100;
		iobus_iob_reset <= 0;
		#100;
		iobus_ios <= 7'b001_000_1;


/*/
		#200;
		key_tape_feed <= 1;
/*/		
		#200;
		iobus_cono_clear <= 1;
		iobus_iob_in <= { 18'o60, 18'o60 };
		@(posedge clk);
		iobus_cono_clear <= 0;
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		iobus_cono_set <= 1;
		@(posedge clk);
		iobus_cono_set <= 0;
/**/

/*
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
*/
	end

	initial begin
//		#1000000;
		#80000;
		$finish;
	end
endmodule
