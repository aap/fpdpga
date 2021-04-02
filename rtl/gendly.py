#!/usr/bin/python3
from math import *

# delays are rounded down
clock=20	# cycle time of clock in ns


dly="""
module dly{type}(input clk, input reset, input in, output p);
	reg [{width}-1:0] r;
	always @(posedge clk or posedge reset) begin
		if(reset)
			r <= 0;
		else begin
			if(r)
				r <= r + {width}'b1;
			if(in)
				r <= 1;
		end
	end
	assign p = r == {n};
endmodule
"""

ldly="""
module ldly{type}(input clk, input reset, input in, output p, output reg l);
	reg [{width}-1:0] r;
	always @(posedge clk or posedge reset) begin
		if(reset) begin
			r <= 0;
			l <= 0;
		end else begin
			if(r)
				r <= r + {width}'b1;
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
	assign p = r == {n};
endmodule
"""

gdly="""
module gdly{type}(input clk, input reset, input p, input l, output q, output ql);
	reg [{width}-1:0] r;
	wire t;
	dcd dcd(.clk(clk), .reset(reset), .p(p), .l(l), .q(t));
	always @(posedge clk or posedge reset) begin
		if(reset) begin
			r <= 0;
		end else begin
			if(ql)
				r <= r + 1;
			if(t)
				r <= -{n};
		end
	end
	assign ql = r != 0 | t;
	assign q = (r != -{width}'b1) & (r != 0) | t;
endmodule
"""

def gendlyns(ns):
	t = str(ns).replace('.', '_')
	n = int(ns//clock)
	nb = ceil(log(n+1,2))
	print(dly.format(type='%sns' % t, width=nb, n=n))

def genldlyns(ns):
	t = str(ns).replace('.', '_')
	n = int(ns//clock)
	nb = ceil(log(n+1,2))
	print(ldly.format(type='%sns' % t, width=nb, n=n))

def gendlyus(us):
	t = str(us).replace('.', '_')
	n = int(us*1000//clock)
	nb = ceil(log(n+1,2))
	print(dly.format(type='%sus' % t, width=nb, n=n))

def genldlyus(us):
	t = str(us).replace('.', '_')
	n = int(us*1000//clock)
	nb = ceil(log(n+1,2))
	print(ldly.format(type='%sus' % t, width=nb, n=n))

def gengdlyus(us):
	t = str(us).replace('.', '_')
	n = int(us*1000//clock)
	nb = ceil(log(n+1,2))
	print(gdly.format(type='%sus' % t, width=nb, n=n))

def gendlyms(ms):
	t = str(ms).replace('.', '_')
	n = int(ms*1000*1000//clock)
	nb = ceil(log(n+1,2))
	print(dly.format(type='%sms' % t, width=nb, n=n))

def genldlyms(ms):
	t = str(ms).replace('.', '_')
	n = int(ms*1000*1000//clock)
	nb = ceil(log(n+1,2))
	print(ldly.format(type='%sms' % t, width=nb, n=n))

def gengdlyms(ms):
	t = str(ms).replace('.', '_')
	n = int(ms*1000*1000//clock)
	nb = ceil(log(n+1,2))
	print(gdly.format(type='%sms' % t, width=nb, n=n))

def genldlys(s):
	t = str(s).replace('.', '_')
	n = int(s*1000*1000*1000//clock)
	nb = ceil(log(n+1,2))
	print(ldly.format(type='%ss' % t, width=nb, n=n))



gendlyns(30)
gendlyns(45)
gendlyns(50)
gendlyns(65)
gendlyns(70)
gendlyns(75)
gendlyns(90)
gendlyns(100)
gendlyns(115)
gendlyns(140)
gendlyns(150)
gendlyns(165)
gendlyns(170)
gendlyns(190)
gendlyns(200)
gendlyns(215)
gendlyns(240)
gendlyns(250)
gendlyns(265)
gendlyns(280)
gendlyns(300)
gendlyns(335)
gendlyns(400)
gendlyns(450)
genldlyns(500)
gendlyns(500)
gendlyns(550)
gendlyns(750)
gendlyns(800)


gengdlyus(0.2)	# only for testing
gendlyus(1)
genldlyus(1)
gengdlyus(1)
genldlyus(1.5)
gengdlyus(1.5)
genldlyus(2)
gengdlyus(2)
gengdlyus(2.5)
gendlyus(2.8)
gendlyus(35)
genldlyus(35)
genldlyus(66)
gendlyus(100)
genldlyus(100)
gengdlyus(100)


gengdlyms(1)
gendlyms(2.1)
gendlyms(2.5)
gendlyms(5)
genldlyms(5)
genldlyms(10)
genldlyms(40)
gengdlyms(120)
gengdlyms(200)


genldlys(1)
genldlys(5)
