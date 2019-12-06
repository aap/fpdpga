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
