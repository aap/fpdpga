module clock(clk, reset);
	output reg clk;
	output reg reset;

	initial begin
		clk = 0;
		reset = 0;
		#500 reset = 1;
	end

	always
//		#5 clk = ~clk;
		#10 clk = ~clk;
endmodule

module edgedet(clk, reset, signal, p);
	input wire clk;
	input wire reset;
	input wire signal;
	output wire p;

	reg last;
	always @(posedge clk or negedge reset) begin
		if(~reset)
			last <= 0;
		else
			last <= signal;
	end

	assign p = signal & ~last;
endmodule

module decode8(
	input wire [0:2] in,
	input wire enb,
	output reg [0:7] out
);

	always @(*) begin
		if(enb)
			case(in)
			3'b000: out = 8'b10000000;
			3'b001: out = 8'b01000000;
			3'b010: out = 8'b00100000;
			3'b011: out = 8'b00010000;
			3'b100: out = 8'b00001000;
			3'b101: out = 8'b00000100;
			3'b110: out = 8'b00000010;
			3'b111: out = 8'b00000001;
			endcase
		else
			out = 0;
	end

endmodule
