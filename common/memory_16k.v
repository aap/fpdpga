module memory_16k(
	input wire clk,
	input wire reset,

	// 36 bit Slave
	input wire [17:0] s_address,
	input wire s_write,
	input wire s_read,
	input wire [35:0] s_writedata,
	output wire [35:0] s_readdata,
	output reg s_waitrequest
);
	
	wire addrok = s_address[17:14] == 0;
	wire [13:0] addr = s_address[13:0];
	reg we;

	onchip_ram #(
		.ADDR_WIDTH(14)
	) ram (
		.clk(clk),
		.data(s_writedata),
		.addr(addr),
		.we(we),
		.q(s_readdata));

	/* have to wait one clock for ram address */
	always @(posedge clk) begin
		if(~reset) begin
			we <= 0;
			s_waitrequest <= 0;
		end else begin
			if(s_read | s_write)
				s_waitrequest <= 0;
			else
				s_waitrequest <= 1;

			if(we)
				we <= 0;
			else
				we <= s_write & addrok;
		end
	end
endmodule
