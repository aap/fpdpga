initial begin: meminit
	integer i;

	for(i = 0; i < 'o40000; i = i + 1)
		pdp10.mem0.core[i] = 0;
	for(i = 0; i < 'o20; i = i + 1) begin
		pdp10.mem0.core[i] = 0;
		pdp10.ka10.fmem[i] = 0;
	end

//	pdp10.ka10.fmem['o0] = 36'o000000123321;
//	pdp10.ka10.fmem['o0] = 36'o400000123321;
//	pdp10.ka10.fmem['o1] = 36'o777777777754;
//	pdp10.ka10.fmem['o1] = 36'o01234;
//	pdp10.ka10.fmem['o10] = 36'o000007030000;
//	pdp10.ka10.fmem['o0] = 36'o5;
//	pdp10.ka10.fmem['o10] = 36'o13;
//	pdp10.ka10.fmem['o11] = 36'o400000000000;

//	pdp10.ka10.fmem['o0] = -36'o1;
//	pdp10.ka10.fmem['o1] = 36'o44;
//	pdp10.ka10.fmem['o10] = 36'o5;
	pdp10.ka10.fmem['o1] = 36'o56;
	pdp10.ka10.fmem['o10] = 36'o23;

	for(i = 0; i < 'o20; i = i + 1) begin
		pdp10.mem0.core[i] = pdp10.ka10.fmem[i];
	end

//	pdp10.mem0.core['o20] = Inst(`MUL, 0, 0, 0, 'o10);
//	pdp10.mem0.core['o20] = Inst(`MUL, 'o11, 0, 0, 'o11);
//	pdp10.mem0.core['o20] = Inst(`IMUL, 'o10, 0, 0, 'o0);
	pdp10.mem0.core['o20] = Inst(`DIV, 'o0, 0, 0, 'o10);
//	pdp10.mem0.core['o20] = Inst(`IDIV, 'o0, 0, 0, 'o10);


	pdp10.mem0.core['o21] = Inst(`JRST, 4, 0, 0, 'o20);
	pdp10.mem0.core['o22] = Inst(`JRST, 4, 0, 0, 'o20);
	pdp10.mem0.core['o200] = Inst(`JRST, 4, 0, 0, 'o20);
end
