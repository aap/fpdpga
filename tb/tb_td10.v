`default_nettype none
`timescale 1ns/1ns
`define simulation

module tb_td10();

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

	td10 td10(.clk(clk), .reset(~reset),

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

		.con_go(con_go),
		.con_fwd(con_fwd),
		.con_rev(con_rev),
		.con_all_halt(con_all_halt),
		.con_pwr_up_dly(con_pwr_up_dly),
		.con_select(con_select),
		.con_select_echo(con_select_echo),
		.con_wrt_echo(con_wrt_echo),
		.con_write(con_write),
		.con_read(con_read),
		.con_wr(con_wr),
		.con_wrtm(con_wrtm),
		.con_wrtm_wait(con_wrtm_wait)

	);

	wire con_go;
	wire con_fwd;
	wire con_rev;
	wire con_all_halt;
	wire con_pwr_up_dly;
	wire [0:3] con_select;
	wire [0:7] con_select_echo;
	wire con_wrt_echo;
	wire [0:4] con_write;
	wire [0:4] con_read;
	wire con_wr;
	wire con_wrtm;
	wire con_wrtm_wait;	// for FE

	wire fe_rd_rq = fe_rq[2];
	wire fe_wr_rq = fe_rq[3];
	wire [0:3] fe_rq;
	reg fe_address = 0;
	reg fe_read = 0;
	reg fe_write = 0;
	wire [4:0] fe_readdata;
	reg [7:0] fe_writedata;

	tu56 tu(.clk(clk), .reset(~reset),
		.con_go(con_go),
		.con_fwd(con_fwd),
		.con_rev(con_rev),
		.con_all_halt(con_all_halt),
		.con_pwr_up_dly(con_pwr_up_dly),
		.con_select(con_select),
		.con_select_echo(con_select_echo[0]),
		.con_wrt_echo(con_wrt_echo),
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

	assign con_select_echo[1:7] = 0;

task cono;
	input [18:35] data;
begin
	iobus_iob_in <= data;
	iobus_cono_clear <= 1;
	#20;
	@(posedge clk);
	iobus_cono_clear <= 0;
	#1000;
	@(posedge clk);
	iobus_cono_set <= 1;
	#20;
	iobus_cono_set <= 0;
	#1200;
	@(posedge clk);
end
endtask

task datao;
	input [0:35] data;
begin
	iobus_iob_in <= data;
	iobus_datao_clear <= 1;
	#20;
	@(posedge clk);
	iobus_datao_clear <= 0;
	#1000;
	@(posedge clk);
	iobus_datao_set <= 1;
	#20;
	iobus_datao_set <= 0;
	#1200;
	@(posedge clk);
end
endtask

	initial begin
		$dumpfile("dump.vcd");
		$dumpvars();

		#10;

		tu.sw1 <= 4;	// address
		tu.sw2 <= 1;	// remote
		tu.sw4 <= 1;	// write enable
		td10.wrtm_sw <= 0;

		@(posedge reset);

		#100;
		iobus_iob_reset <= 1;
		#100;
		iobus_iob_reset <= 0;
		#100;
		iobus_ios <= 7'b011_010_0;
		#100;

		/*
		   DTC
			400000	18 stop
			200000	19 go fwd
			100000	20 go rev
			040000	21 delay inhibit
			020000	22 select
			010000	23 deselect
			007000  24-26 transport num
			000700	27-29 function
			000070	30-32 data channel
			000007	33-35 flag channel
		   DTS
			400000	18 parity error enable
			200000	19 data miss enable
			100000	20 job done enable
			040000	21 illop enable
			020000	22 end zone enable
			010000	23 block missed enable
			000002	34 stop all
			000001	35 function stop
		   func
			0	nothing
			1	read all
			2	read block num
			3	read data
			4	write tm
			5	write all
			6	write block num
			7	write data
		 */

		cono(18'o7234);
		cono(18'o114000);
		cono(18'o300000);
		cono(18'o600000);

		cono(18'o220200);	// fwd
	//	cono(18'o120700);	// rev
	end

	initial begin
		#3000000;
		$finish;
	end

	initial begin
		#435000;
/*/
		@(posedge td10.mk_data);
//		td10.t_act <= 0;
		td10.tdata <= 5;	// hack for reading the end of a block
		// when writing
		td10.t_act <= 1;
		td10.t_wren <= 1;
		td10.lp <= 'o12;
/*/
	end



	/* CPU interface simulation */
	initial begin
		@(posedge td10.com_data_pi_req);
		#3000;
		datao(36'o001123445567);
		@(posedge td10.com_data_pi_req);
		#3000;
		datao(36'o123456112233);
		@(posedge td10.com_data_pi_req);
		#3000;
		datao(36'o654321665544);
	end

	/* FE tape simulation */
	reg [0:3] tape_data[0:922511];
	integer tape_pos =
		//0;
		//1596 - 50;	// before end of first block
		1596 - 15;	// before first rev block mark
		//1596*'o75;	// before loader
		//1596*'o76 + 15;	// after loader
		//1596*'o76 + 70;	// after loader
	initial $readmemh("sys6_tape.mem", tape_data);
	integer dly;

	// Getting data from transport (write)
	always begin
		@(posedge fe_rd_rq);
/*
		for(dly = 0; dly < 300; dly = dly+1) begin
			@(posedge clk);
		end
*/
		fe_address <= 0;
		fe_read <= 1;
		@(posedge clk);
		if(fe_readdata[4]) begin
			$display("wrtm %d %o %d", fe_rq[0:1],
				fe_readdata[3:0], tape_pos);
			tape_data[tape_pos] <= fe_readdata[3:0];
		end else begin
			$display("write %d %o %d", fe_rq[0:1],
				fe_readdata[3:0], tape_pos);
			tape_data[tape_pos][1:3] <= fe_readdata[2:0];
		end
		if(fe_rq[0:1] == 2)
			tape_pos <= tape_pos + 1;
		if(fe_rq[0:1] == 3)
			tape_pos <= tape_pos - 1;
		fe_read <= 0;
	end

	// Giving data to transport (read)
	always begin
		@(posedge fe_wr_rq);
/*
		for(dly = 0; dly < 300; dly = dly+1) begin
			@(posedge clk);
		end
*/
		fe_address <= 0;
		fe_write <= 1;
		fe_writedata <= tape_data[tape_pos];
		if(fe_rq[0:1] == 2)
			tape_pos <= tape_pos + 1;
		if(fe_rq[0:1] == 3)
			tape_pos <= tape_pos - 1;
		if(fe_rq[0] & ((tape_pos+fe_rq[1]) % 6) == 0)
			$display("");
		$display("read  %d %o %d", fe_rq[0:1],
			tape_data[tape_pos], tape_pos);
		@(posedge clk);
/*
		if(fe_rq[0] & ((tape_pos+fe_rq[1]) % 6) == 0)
			$display("");
*/
		fe_write <= 0;
	end

endmodule
