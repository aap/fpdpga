/* 555 characteristics:
	start time < 300ms
	stop time < 150ms
	turn around time < 300ms
	start distance < 9in
	stop distance 9+-2in
   TU56 characteristics:
	start	150+-15ms
	stop	100+-10ms
	turn around	200+-50ms
	backlash < 1in motion after brake
	93+-12in per sec
	66μs between timing pulses considered "up to speed"
	??33300 lines per sec

	at full speed:?
	33μs between time pulses
	1596 lines per block -> ~53ms
	578 blocks -> ~30s for whole tape (data)
 */

module tu56(
	input wire clk,
	input wire reset,

	/* Controller wires */
	input wire con_go,	// negated stop
	input wire con_fwd,
	input wire con_rev,
	input wire con_all_halt,
/**/	input wire con_pwr_up_dly,
	input wire [0:3] con_select,
	output wire con_select_echo,
	output wire con_wrt_echo,
	output wire [0:4] con_read,
	input wire [0:4] con_write,
	input wire con_wr,
	input wire con_wrtm,
	output wire con_wrtm_wait,


	/* FE */
	output wire [0:3] fe_rq,
	input wire fe_address,
	input wire fe_read,
	input wire fe_write,
	output wire [4:0] fe_readdata,
	input wire [7:0] fe_writedata
);
	/* switches */
	reg [0:2] sw1 = 0;	// address select
	reg [0:1] sw2 = 0;	// remote/off/local
	reg [0:1] sw3 = 0;	// fwd/hold/rev
	reg sw4 = 0;	// write enable/lock

	always @(posedge clk) begin
		if(fe_write && fe_address == 1) begin
			sw1 <= fe_writedata[2:0];
			sw2 <= fe_writedata[4:3];
			sw3 <= fe_writedata[6:5];
			sw4 <= fe_writedata[7];
		end
	end

	/* selection */
	wire selcode = {1'b1, sw1} == con_select;
	/* operation mode */
	wire off = ~sw2[1];
	wire remote = sw2 == 2'b01;
	wire local = sw2 == 2'b11;
	/* manual operations */
	wire hold = local & ~sw3[1];
	wire fwd_local = local & (sw3 == 2'b01);
	wire rev_local = local & (sw3 == 2'b11);
	/* wr protect */
	wire wrt_enab = sw4;

	wire select = selcode & remote;

	assign con_select_echo = select;
	assign con_wrt_echo = select & wrt_enab;

	// actually coming from controller
	wire con_stop = ~con_go;

	wire reset_mo = hold | off;

	reg reverse = 0;
	reg motion = 0;
	always @(posedge clk) begin
		if(rev_local | con_rev&select)
			reverse <= 1;
		if(fwd_local | con_fwd&select)
			reverse <= 0;

		if(con_go&select | fwd_local | rev_local)
			motion <= 1;
		if(con_stop&select | reset_mo | con_all_halt&remote)
			motion <= 0;
	end


	reg fe_rd_rq = 0;
	reg fe_wr_rq = 0;
	reg fe_move = 0;

	assign fe_rq[0] = fe_move;
	assign fe_rq[1] = reverse;
	assign fe_rq[2] = fe_rd_rq;
	assign fe_rq[3] = fe_wr_rq;

	reg [4:0] fe_readdata_fwd;
	wire [7:0] fe_writedata_fwd;

	assign fe_readdata = reverse ?
		{fe_readdata_fwd[4], ~fe_readdata_fwd[3:0]} : fe_readdata_fwd;
	assign fe_writedata_fwd = reverse ? ~fe_writedata : fe_writedata;


	assign con_wrtm_wait = select & (fe_rd_rq | fe_wr_rq);

/*
//	assign con_read = {5{select}} & (con_wrtm ? con_write : { tck[0], linebuf }) ;
	assign con_read[0:1] = {2{select}} &
		(con_wrtm ? con_write[0:1] : { tck[0], linebuf[0] });
	assign con_read[2:4] = {3{select}} &
		(con_wr ? con_write[2:4] : linebuf[1:3]);
*/
	assign con_read = {5{select}} & { tck[0], linebuf };


	// simulated time track - not used for WRTM
	reg [0:1] tck = 0;
	reg [0:1] dck = 0;
	wire clk120kc;
	clk120khz clk1(clk, clk120kc);

	always @(posedge clk) begin
		if(motion) begin
			if(clk120kc & ~(fe_rd_rq | fe_wr_rq)) begin
				tck <= tck + 1;
				dck <= dck - 1;
			end
		end else begin
			fe_wr_rq <= 0;
			fe_rd_rq <= 0;
		end
	end

	// simulated read signal
	reg [0:3] linebuf;

	// time clock, 90 deg offset
	wire t = con_wrtm ? con_write[0] : tck[0];
	wire t_rising;
	pa e0(clk, reset, t, t_rising);

	// data clock
	wire d = dck[0];
	wire d_rising, d_falling;
	pa e1(clk, reset, d, d_rising);
	pa e2(clk, reset, ~d, d_falling);

	/* 		wr_rq	rd_rq	move	rev
	 * read/move	1	0	1	R
	 * write	1	0	0	x
	 * 		0	1	1	R
	 * wrtm		0	1	1	R
	 */

	always @(posedge clk) begin
		// read data from tape
		// like tp0
		if(d_rising & ~con_wrtm) begin
			fe_wr_rq <= 1;
			fe_move <= ~con_wr;
		end
		// request answered
		if(fe_write & fe_wr_rq & fe_address == 0) begin
			linebuf <= fe_writedata_fwd;
			fe_wr_rq <= 0;
		end

		// mid of data - write to tape here
		if(t_rising) begin
			if(con_wrtm) begin
				fe_rd_rq <= 1;
				fe_move <= 1;
				fe_readdata_fwd <= { con_wrtm, con_write[1:4] };
			end else if(con_wr) begin
				fe_rd_rq <= 1;
				fe_move <= 1;
				fe_readdata_fwd <= { con_wrtm, con_read[1], con_write[2:4] };
			end
		end
		// request answered
		if(fe_read & fe_rd_rq & fe_address == 0) begin
			fe_rd_rq <= 0;
		end

		// simulate reading complemented data
		// like tp1
		if(d_falling & ~con_wrtm) begin
			linebuf <= ~linebuf;
		end

		// mid of complement data
		// t_falling - theoretically we could write complement here
	end

endmodule
