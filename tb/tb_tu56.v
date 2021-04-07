`default_nettype none
`timescale 1ns/1ns
`define simulation

/* 551 delays:
	20 35 ms	reselection delay, tape is moving
			but another unit was selected
	160 225 ms	turn-around delay
	300 ms		start delay
   Tu56 delays:
	1 ms		reselection (?)
	120 ms		speed
	200 ms		turn-around delay
 */

module tb_tu56();

	wire clk, reset;
	wire clk120kc;
	clock clock(clk, reset);
	clk120khz clk1(clk, clk120kc);

	reg con_go = 0;
	reg con_rev = 0;
	reg con_all_halt = 0;
	reg con_pwr_up_dly = 0;
	reg [0:3] con_select = 4'o0;
	wire [0:4] con_write = { tck[0], rwb[0], rwb };
	wire [0:4] con_read;
	reg con_wr = 0;
	reg con_wrtm = 0;
	wire con_wrtm_wait;

	wire fe_rd_rq = fe_rq[2];
	wire fe_wr_rq = fe_rq[3];
	wire [0:3] fe_rq;
	reg fe_address = 0;
	reg fe_read = 0;
	reg fe_write = 0;
	wire [31:0] fe_readdata;
	reg [31:0] fe_writedata;

	reg [0:2] rwb;// = 3'b101;

	tu56 tu(.clk(clk), .reset(~reset),
		.con_go(con_go),
		.con_fwd(~con_rev),
		.con_rev(con_rev),
		.con_all_halt(con_all_halt),
		.con_pwr_up_dly(con_pwr_up_dly),
		.con_select(con_select),
		.con_write(con_write),
		.con_read(con_read),
		.con_wr(con_wr),
		.con_wrtm(con_wrtm),
		.con_wrtm_wait(con_wrtm_wait),
		.fe_rq(fe_rq),
		.fe_address(fe_address),
		.fe_read(fe_read),
		.fe_write(fe_write),
		.fe_readdata(fe_readdata),
		.fe_writedata(fe_writedata)
	);

	// WRTM timing
	// TCK0 is written as timing track
	// it is offset 90deg from the other tracks
	reg [0:1] tck = 0;
	wire tck1_falling;
	// pulse when TCK0 flux crosses 0
	pa e0(clk, ~reset, ~tck[1], tck1_falling);
	always @(posedge clk)
		if(clk120kc & ~con_wrtm_wait)
			tck <= tck - 1;

	// RWA timing
	wire rwa_tm = con_read[0];
	wire tm_rising, tm_falling;
	pa e1(clk, ~reset, rwa_tm, tm_rising);
	pa e2(clk, ~reset, ~rwa_tm, tm_falling);


	// TP1 = flux reversal = complement, strobe
	// TP0 = between flux reversal = load
	wire tp0 = con_wrtm ? (tck1_falling & ~tck[0]) : tm_falling;
	wire tp1 = con_wrtm ? (tck1_falling & tck[0]) : tm_rising;

	always @(posedge clk) begin
		if(con_wr) begin
			if(tp0) begin
				rwb <= wrdata[i];
				i <= i + 1;
			end
			if(tp1) begin
				rwb <= ~rwb;
			end
		end else begin
			if(tp1) begin
				buffer <= con_read[1:4];
			end
		end
	end

	integer dly;

	// Getting data from transport (write)
	always @(posedge clk) begin
		@(posedge fe_rd_rq);
		for(dly = 0; dly < 300; dly = dly+1) begin
			@(posedge clk);
		end
		fe_address <= 0;
		fe_read <= 1;
		@(posedge clk);
		buffer <= fe_readdata[3:0];
		if(fe_readdata[4])
			$display("wrtm %d %o", fe_rq[0:1],
				fe_readdata[3:0]);
		else
			$display("write %d %o", fe_rq[0:1],
				fe_readdata[3:0]);
		fe_read <= 0;
	end

	// Giving data to transport (read)
	always @(posedge clk) begin
		@(posedge fe_wr_rq);
		for(dly = 0; dly < 300; dly = dly+1) begin
			@(posedge clk);
		end
		fe_address <= 0;
		fe_write <= 1;
		fe_writedata <= rddata[j];	// send data from tape
		@(posedge clk);
		$display("read  %d %o", fe_rq[0:1],
			fe_writedata[4:0]);
		fe_write <= 0;
		j <= j + 1;
	end



	initial begin
		#10;
		con_go = 1;
		tu.sw2 = 3;	// 3: local
		tu.sw3 = 1;	// 1: fwd, 3: rev

		con_wrtm = 0;
		con_wr = 1;

		#500000;
		$finish;
	end

// some data


	reg [0:2] wrdata[0:1000];
	reg [1:4] buffer;
	integer i;

task lineWR;
	input [0:2] l;
begin
	wrdata[i] = l;
	i = i + 1;
end
endtask

	initial begin
		$dumpfile("dump.vcd");
		$dumpvars();

		// data to be written
//		for(i = 0; i < 1000; i = i + 1)
//			wrdata[i] = 3'b101;
		i = 0;
		lineWR(3'b110);
		lineWR(3'b010);
		lineWR(3'b010);
		lineWR(3'b110);
		lineWR(3'b010);
		lineWR(3'b110);
		lineWR(3'b110);
		lineWR(3'b010);
		lineWR(3'b110);
		lineWR(3'b010);
		lineWR(3'b010);
		lineWR(3'b110);
		i = 0;
		#10;
		// get first word ready
		rwb <= wrdata[i];
		i <= i + 1;
	end

task lineRD;
	input [0:3] l;
begin
	rddata[j] = l;
	j = j + 1;
end
endtask

	reg [0:3] rddata[0:1000];
	reg [0:3] linebuf;// = 4'b0101;
	integer j;

	initial begin
		// data on tape to be read
//		for(j = 0; j < 1000; j = j + 1)
//			rddata[j] = 4'b0101;
		j = 0;
		lineRD(4'b1111);
		lineRD(4'b1001);
		lineRD(4'b0001);
		lineRD(4'b0111);
		lineRD(4'b1001);
		lineRD(4'b1111);
		lineRD(4'b0111);
		lineRD(4'b0001);
		lineRD(4'b1111);
		lineRD(4'b1001);
		lineRD(4'b0001);
		lineRD(4'b0111);
		j = 0;
	end
endmodule
