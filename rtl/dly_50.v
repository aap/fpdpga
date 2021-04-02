
module dly30ns(input clk, input reset, input in, output p);
	reg [1-1:0] r;
	always @(posedge clk or posedge reset) begin
		if(reset)
			r <= 0;
		else begin
			if(r)
				r <= r + 1'b1;
			if(in)
				r <= 1;
		end
	end
	assign p = r == 1;
endmodule


module dly45ns(input clk, input reset, input in, output p);
	reg [2-1:0] r;
	always @(posedge clk or posedge reset) begin
		if(reset)
			r <= 0;
		else begin
			if(r)
				r <= r + 2'b1;
			if(in)
				r <= 1;
		end
	end
	assign p = r == 2;
endmodule


module dly50ns(input clk, input reset, input in, output p);
	reg [2-1:0] r;
	always @(posedge clk or posedge reset) begin
		if(reset)
			r <= 0;
		else begin
			if(r)
				r <= r + 2'b1;
			if(in)
				r <= 1;
		end
	end
	assign p = r == 2;
endmodule


module dly65ns(input clk, input reset, input in, output p);
	reg [2-1:0] r;
	always @(posedge clk or posedge reset) begin
		if(reset)
			r <= 0;
		else begin
			if(r)
				r <= r + 2'b1;
			if(in)
				r <= 1;
		end
	end
	assign p = r == 3;
endmodule


module dly70ns(input clk, input reset, input in, output p);
	reg [2-1:0] r;
	always @(posedge clk or posedge reset) begin
		if(reset)
			r <= 0;
		else begin
			if(r)
				r <= r + 2'b1;
			if(in)
				r <= 1;
		end
	end
	assign p = r == 3;
endmodule


module dly75ns(input clk, input reset, input in, output p);
	reg [2-1:0] r;
	always @(posedge clk or posedge reset) begin
		if(reset)
			r <= 0;
		else begin
			if(r)
				r <= r + 2'b1;
			if(in)
				r <= 1;
		end
	end
	assign p = r == 3;
endmodule


module dly90ns(input clk, input reset, input in, output p);
	reg [3-1:0] r;
	always @(posedge clk or posedge reset) begin
		if(reset)
			r <= 0;
		else begin
			if(r)
				r <= r + 3'b1;
			if(in)
				r <= 1;
		end
	end
	assign p = r == 4;
endmodule


module dly100ns(input clk, input reset, input in, output p);
	reg [3-1:0] r;
	always @(posedge clk or posedge reset) begin
		if(reset)
			r <= 0;
		else begin
			if(r)
				r <= r + 3'b1;
			if(in)
				r <= 1;
		end
	end
	assign p = r == 5;
endmodule


module dly115ns(input clk, input reset, input in, output p);
	reg [3-1:0] r;
	always @(posedge clk or posedge reset) begin
		if(reset)
			r <= 0;
		else begin
			if(r)
				r <= r + 3'b1;
			if(in)
				r <= 1;
		end
	end
	assign p = r == 5;
endmodule


module dly140ns(input clk, input reset, input in, output p);
	reg [3-1:0] r;
	always @(posedge clk or posedge reset) begin
		if(reset)
			r <= 0;
		else begin
			if(r)
				r <= r + 3'b1;
			if(in)
				r <= 1;
		end
	end
	assign p = r == 7;
endmodule


module dly150ns(input clk, input reset, input in, output p);
	reg [3-1:0] r;
	always @(posedge clk or posedge reset) begin
		if(reset)
			r <= 0;
		else begin
			if(r)
				r <= r + 3'b1;
			if(in)
				r <= 1;
		end
	end
	assign p = r == 7;
endmodule


module dly165ns(input clk, input reset, input in, output p);
	reg [4-1:0] r;
	always @(posedge clk or posedge reset) begin
		if(reset)
			r <= 0;
		else begin
			if(r)
				r <= r + 4'b1;
			if(in)
				r <= 1;
		end
	end
	assign p = r == 8;
endmodule


module dly170ns(input clk, input reset, input in, output p);
	reg [4-1:0] r;
	always @(posedge clk or posedge reset) begin
		if(reset)
			r <= 0;
		else begin
			if(r)
				r <= r + 4'b1;
			if(in)
				r <= 1;
		end
	end
	assign p = r == 8;
endmodule


module dly190ns(input clk, input reset, input in, output p);
	reg [4-1:0] r;
	always @(posedge clk or posedge reset) begin
		if(reset)
			r <= 0;
		else begin
			if(r)
				r <= r + 4'b1;
			if(in)
				r <= 1;
		end
	end
	assign p = r == 9;
endmodule


module dly200ns(input clk, input reset, input in, output p);
	reg [4-1:0] r;
	always @(posedge clk or posedge reset) begin
		if(reset)
			r <= 0;
		else begin
			if(r)
				r <= r + 4'b1;
			if(in)
				r <= 1;
		end
	end
	assign p = r == 10;
endmodule


module dly215ns(input clk, input reset, input in, output p);
	reg [4-1:0] r;
	always @(posedge clk or posedge reset) begin
		if(reset)
			r <= 0;
		else begin
			if(r)
				r <= r + 4'b1;
			if(in)
				r <= 1;
		end
	end
	assign p = r == 10;
endmodule


module dly240ns(input clk, input reset, input in, output p);
	reg [4-1:0] r;
	always @(posedge clk or posedge reset) begin
		if(reset)
			r <= 0;
		else begin
			if(r)
				r <= r + 4'b1;
			if(in)
				r <= 1;
		end
	end
	assign p = r == 12;
endmodule


module dly250ns(input clk, input reset, input in, output p);
	reg [4-1:0] r;
	always @(posedge clk or posedge reset) begin
		if(reset)
			r <= 0;
		else begin
			if(r)
				r <= r + 4'b1;
			if(in)
				r <= 1;
		end
	end
	assign p = r == 12;
endmodule


module dly265ns(input clk, input reset, input in, output p);
	reg [4-1:0] r;
	always @(posedge clk or posedge reset) begin
		if(reset)
			r <= 0;
		else begin
			if(r)
				r <= r + 4'b1;
			if(in)
				r <= 1;
		end
	end
	assign p = r == 13;
endmodule


module dly280ns(input clk, input reset, input in, output p);
	reg [4-1:0] r;
	always @(posedge clk or posedge reset) begin
		if(reset)
			r <= 0;
		else begin
			if(r)
				r <= r + 4'b1;
			if(in)
				r <= 1;
		end
	end
	assign p = r == 14;
endmodule


module dly300ns(input clk, input reset, input in, output p);
	reg [4-1:0] r;
	always @(posedge clk or posedge reset) begin
		if(reset)
			r <= 0;
		else begin
			if(r)
				r <= r + 4'b1;
			if(in)
				r <= 1;
		end
	end
	assign p = r == 15;
endmodule


module dly335ns(input clk, input reset, input in, output p);
	reg [5-1:0] r;
	always @(posedge clk or posedge reset) begin
		if(reset)
			r <= 0;
		else begin
			if(r)
				r <= r + 5'b1;
			if(in)
				r <= 1;
		end
	end
	assign p = r == 16;
endmodule


module dly400ns(input clk, input reset, input in, output p);
	reg [5-1:0] r;
	always @(posedge clk or posedge reset) begin
		if(reset)
			r <= 0;
		else begin
			if(r)
				r <= r + 5'b1;
			if(in)
				r <= 1;
		end
	end
	assign p = r == 20;
endmodule


module dly450ns(input clk, input reset, input in, output p);
	reg [5-1:0] r;
	always @(posedge clk or posedge reset) begin
		if(reset)
			r <= 0;
		else begin
			if(r)
				r <= r + 5'b1;
			if(in)
				r <= 1;
		end
	end
	assign p = r == 22;
endmodule


module ldly500ns(input clk, input reset, input in, output p, output reg l);
	reg [5-1:0] r;
	always @(posedge clk or posedge reset) begin
		if(reset) begin
			r <= 0;
			l <= 0;
		end else begin
			if(r)
				r <= r + 5'b1;
			if(in) begin
				r <= 1;
				l <= 1;
			end
			if(p) begin
				r <= 0;
				l <= 0;
			end
		end
	end
	assign p = r == 25;
endmodule


module dly500ns(input clk, input reset, input in, output p);
	reg [5-1:0] r;
	always @(posedge clk or posedge reset) begin
		if(reset)
			r <= 0;
		else begin
			if(r)
				r <= r + 5'b1;
			if(in)
				r <= 1;
		end
	end
	assign p = r == 25;
endmodule


module dly550ns(input clk, input reset, input in, output p);
	reg [5-1:0] r;
	always @(posedge clk or posedge reset) begin
		if(reset)
			r <= 0;
		else begin
			if(r)
				r <= r + 5'b1;
			if(in)
				r <= 1;
		end
	end
	assign p = r == 27;
endmodule


module dly750ns(input clk, input reset, input in, output p);
	reg [6-1:0] r;
	always @(posedge clk or posedge reset) begin
		if(reset)
			r <= 0;
		else begin
			if(r)
				r <= r + 6'b1;
			if(in)
				r <= 1;
		end
	end
	assign p = r == 37;
endmodule


module dly800ns(input clk, input reset, input in, output p);
	reg [6-1:0] r;
	always @(posedge clk or posedge reset) begin
		if(reset)
			r <= 0;
		else begin
			if(r)
				r <= r + 6'b1;
			if(in)
				r <= 1;
		end
	end
	assign p = r == 40;
endmodule


module gdly0_2us(input clk, input reset, input p, input l, output q, output ql);
	reg [4-1:0] r;
	wire t;
	dcd dcd(.clk(clk), .reset(reset), .p(p), .l(l), .q(t));
	always @(posedge clk or posedge reset) begin
		if(reset) begin
			r <= 0;
		end else begin
			if(ql)
				r <= r + 1;
			if(t)
				r <= -10;
		end
	end
	assign ql = r != 0 | t;
	assign q = (r != -4'b1) & (r != 0) | t;
endmodule


module dly1us(input clk, input reset, input in, output p);
	reg [6-1:0] r;
	always @(posedge clk or posedge reset) begin
		if(reset)
			r <= 0;
		else begin
			if(r)
				r <= r + 6'b1;
			if(in)
				r <= 1;
		end
	end
	assign p = r == 50;
endmodule


module ldly1us(input clk, input reset, input in, output p, output reg l);
	reg [6-1:0] r;
	always @(posedge clk or posedge reset) begin
		if(reset) begin
			r <= 0;
			l <= 0;
		end else begin
			if(r)
				r <= r + 6'b1;
			if(in) begin
				r <= 1;
				l <= 1;
			end
			if(p) begin
				r <= 0;
				l <= 0;
			end
		end
	end
	assign p = r == 50;
endmodule


module gdly1us(input clk, input reset, input p, input l, output q, output ql);
	reg [6-1:0] r;
	wire t;
	dcd dcd(.clk(clk), .reset(reset), .p(p), .l(l), .q(t));
	always @(posedge clk or posedge reset) begin
		if(reset) begin
			r <= 0;
		end else begin
			if(ql)
				r <= r + 1;
			if(t)
				r <= -50;
		end
	end
	assign ql = r != 0 | t;
	assign q = (r != -6'b1) & (r != 0) | t;
endmodule


module ldly1_5us(input clk, input reset, input in, output p, output reg l);
	reg [7-1:0] r;
	always @(posedge clk or posedge reset) begin
		if(reset) begin
			r <= 0;
			l <= 0;
		end else begin
			if(r)
				r <= r + 7'b1;
			if(in) begin
				r <= 1;
				l <= 1;
			end
			if(p) begin
				r <= 0;
				l <= 0;
			end
		end
	end
	assign p = r == 75;
endmodule


module gdly1_5us(input clk, input reset, input p, input l, output q, output ql);
	reg [7-1:0] r;
	wire t;
	dcd dcd(.clk(clk), .reset(reset), .p(p), .l(l), .q(t));
	always @(posedge clk or posedge reset) begin
		if(reset) begin
			r <= 0;
		end else begin
			if(ql)
				r <= r + 1;
			if(t)
				r <= -75;
		end
	end
	assign ql = r != 0 | t;
	assign q = (r != -7'b1) & (r != 0) | t;
endmodule


module ldly2us(input clk, input reset, input in, output p, output reg l);
	reg [7-1:0] r;
	always @(posedge clk or posedge reset) begin
		if(reset) begin
			r <= 0;
			l <= 0;
		end else begin
			if(r)
				r <= r + 7'b1;
			if(in) begin
				r <= 1;
				l <= 1;
			end
			if(p) begin
				r <= 0;
				l <= 0;
			end
		end
	end
	assign p = r == 100;
endmodule


module gdly2us(input clk, input reset, input p, input l, output q, output ql);
	reg [7-1:0] r;
	wire t;
	dcd dcd(.clk(clk), .reset(reset), .p(p), .l(l), .q(t));
	always @(posedge clk or posedge reset) begin
		if(reset) begin
			r <= 0;
		end else begin
			if(ql)
				r <= r + 1;
			if(t)
				r <= -100;
		end
	end
	assign ql = r != 0 | t;
	assign q = (r != -7'b1) & (r != 0) | t;
endmodule


module gdly2_5us(input clk, input reset, input p, input l, output q, output ql);
	reg [7-1:0] r;
	wire t;
	dcd dcd(.clk(clk), .reset(reset), .p(p), .l(l), .q(t));
	always @(posedge clk or posedge reset) begin
		if(reset) begin
			r <= 0;
		end else begin
			if(ql)
				r <= r + 1;
			if(t)
				r <= -125;
		end
	end
	assign ql = r != 0 | t;
	assign q = (r != -7'b1) & (r != 0) | t;
endmodule


module dly2_8us(input clk, input reset, input in, output p);
	reg [8-1:0] r;
	always @(posedge clk or posedge reset) begin
		if(reset)
			r <= 0;
		else begin
			if(r)
				r <= r + 8'b1;
			if(in)
				r <= 1;
		end
	end
	assign p = r == 140;
endmodule


module dly35us(input clk, input reset, input in, output p);
	reg [11-1:0] r;
	always @(posedge clk or posedge reset) begin
		if(reset)
			r <= 0;
		else begin
			if(r)
				r <= r + 11'b1;
			if(in)
				r <= 1;
		end
	end
	assign p = r == 1750;
endmodule


module ldly35us(input clk, input reset, input in, output p, output reg l);
	reg [11-1:0] r;
	always @(posedge clk or posedge reset) begin
		if(reset) begin
			r <= 0;
			l <= 0;
		end else begin
			if(r)
				r <= r + 11'b1;
			if(in) begin
				r <= 1;
				l <= 1;
			end
			if(p) begin
				r <= 0;
				l <= 0;
			end
		end
	end
	assign p = r == 1750;
endmodule


module ldly66us(input clk, input reset, input in, output p, output reg l);
	reg [12-1:0] r;
	always @(posedge clk or posedge reset) begin
		if(reset) begin
			r <= 0;
			l <= 0;
		end else begin
			if(r)
				r <= r + 12'b1;
			if(in) begin
				r <= 1;
				l <= 1;
			end
			if(p) begin
				r <= 0;
				l <= 0;
			end
		end
	end
	assign p = r == 3300;
endmodule


module dly100us(input clk, input reset, input in, output p);
	reg [13-1:0] r;
	always @(posedge clk or posedge reset) begin
		if(reset)
			r <= 0;
		else begin
			if(r)
				r <= r + 13'b1;
			if(in)
				r <= 1;
		end
	end
	assign p = r == 5000;
endmodule


module ldly100us(input clk, input reset, input in, output p, output reg l);
	reg [13-1:0] r;
	always @(posedge clk or posedge reset) begin
		if(reset) begin
			r <= 0;
			l <= 0;
		end else begin
			if(r)
				r <= r + 13'b1;
			if(in) begin
				r <= 1;
				l <= 1;
			end
			if(p) begin
				r <= 0;
				l <= 0;
			end
		end
	end
	assign p = r == 5000;
endmodule


module gdly100us(input clk, input reset, input p, input l, output q, output ql);
	reg [13-1:0] r;
	wire t;
	dcd dcd(.clk(clk), .reset(reset), .p(p), .l(l), .q(t));
	always @(posedge clk or posedge reset) begin
		if(reset) begin
			r <= 0;
		end else begin
			if(ql)
				r <= r + 1;
			if(t)
				r <= -5000;
		end
	end
	assign ql = r != 0 | t;
	assign q = (r != -13'b1) & (r != 0) | t;
endmodule


module gdly1ms(input clk, input reset, input p, input l, output q, output ql);
	reg [16-1:0] r;
	wire t;
	dcd dcd(.clk(clk), .reset(reset), .p(p), .l(l), .q(t));
	always @(posedge clk or posedge reset) begin
		if(reset) begin
			r <= 0;
		end else begin
			if(ql)
				r <= r + 1;
			if(t)
				r <= -50000;
		end
	end
	assign ql = r != 0 | t;
	assign q = (r != -16'b1) & (r != 0) | t;
endmodule


module dly2_1ms(input clk, input reset, input in, output p);
	reg [17-1:0] r;
	always @(posedge clk or posedge reset) begin
		if(reset)
			r <= 0;
		else begin
			if(r)
				r <= r + 17'b1;
			if(in)
				r <= 1;
		end
	end
	assign p = r == 105000;
endmodule


module dly2_5ms(input clk, input reset, input in, output p);
	reg [17-1:0] r;
	always @(posedge clk or posedge reset) begin
		if(reset)
			r <= 0;
		else begin
			if(r)
				r <= r + 17'b1;
			if(in)
				r <= 1;
		end
	end
	assign p = r == 125000;
endmodule


module dly5ms(input clk, input reset, input in, output p);
	reg [18-1:0] r;
	always @(posedge clk or posedge reset) begin
		if(reset)
			r <= 0;
		else begin
			if(r)
				r <= r + 18'b1;
			if(in)
				r <= 1;
		end
	end
	assign p = r == 250000;
endmodule


module ldly5ms(input clk, input reset, input in, output p, output reg l);
	reg [18-1:0] r;
	always @(posedge clk or posedge reset) begin
		if(reset) begin
			r <= 0;
			l <= 0;
		end else begin
			if(r)
				r <= r + 18'b1;
			if(in) begin
				r <= 1;
				l <= 1;
			end
			if(p) begin
				r <= 0;
				l <= 0;
			end
		end
	end
	assign p = r == 250000;
endmodule


module ldly10ms(input clk, input reset, input in, output p, output reg l);
	reg [19-1:0] r;
	always @(posedge clk or posedge reset) begin
		if(reset) begin
			r <= 0;
			l <= 0;
		end else begin
			if(r)
				r <= r + 19'b1;
			if(in) begin
				r <= 1;
				l <= 1;
			end
			if(p) begin
				r <= 0;
				l <= 0;
			end
		end
	end
	assign p = r == 500000;
endmodule


module ldly40ms(input clk, input reset, input in, output p, output reg l);
	reg [21-1:0] r;
	always @(posedge clk or posedge reset) begin
		if(reset) begin
			r <= 0;
			l <= 0;
		end else begin
			if(r)
				r <= r + 21'b1;
			if(in) begin
				r <= 1;
				l <= 1;
			end
			if(p) begin
				r <= 0;
				l <= 0;
			end
		end
	end
	assign p = r == 2000000;
endmodule


module gdly120ms(input clk, input reset, input p, input l, output q, output ql);
	reg [23-1:0] r;
	wire t;
	dcd dcd(.clk(clk), .reset(reset), .p(p), .l(l), .q(t));
	always @(posedge clk or posedge reset) begin
		if(reset) begin
			r <= 0;
		end else begin
			if(ql)
				r <= r + 1;
			if(t)
				r <= -6000000;
		end
	end
	assign ql = r != 0 | t;
	assign q = (r != -23'b1) & (r != 0) | t;
endmodule


module gdly200ms(input clk, input reset, input p, input l, output q, output ql);
	reg [24-1:0] r;
	wire t;
	dcd dcd(.clk(clk), .reset(reset), .p(p), .l(l), .q(t));
	always @(posedge clk or posedge reset) begin
		if(reset) begin
			r <= 0;
		end else begin
			if(ql)
				r <= r + 1;
			if(t)
				r <= -10000000;
		end
	end
	assign ql = r != 0 | t;
	assign q = (r != -24'b1) & (r != 0) | t;
endmodule


module ldly1s(input clk, input reset, input in, output p, output reg l);
	reg [26-1:0] r;
	always @(posedge clk or posedge reset) begin
		if(reset) begin
			r <= 0;
			l <= 0;
		end else begin
			if(r)
				r <= r + 26'b1;
			if(in) begin
				r <= 1;
				l <= 1;
			end
			if(p) begin
				r <= 0;
				l <= 0;
			end
		end
	end
	assign p = r == 50000000;
endmodule


module ldly5s(input clk, input reset, input in, output p, output reg l);
	reg [28-1:0] r;
	always @(posedge clk or posedge reset) begin
		if(reset) begin
			r <= 0;
			l <= 0;
		end else begin
			if(r)
				r <= r + 28'b1;
			if(in) begin
				r <= 1;
				l <= 1;
			end
			if(p) begin
				r <= 0;
				l <= 0;
			end
		end
	end
	assign p = r == 250000000;
endmodule

