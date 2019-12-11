initial begin: meminit
	integer i;

	for(i = 0; i < 'o40000; i = i + 1)
		pdp10.mem0.core[i] = 0;
	for(i = 0; i < 'o20; i = i + 1) begin
		pdp10.mem0.core[i] = 0;
		pdp10.ka10.fmem[i] = 0;
	end

	pdp10.ka10.fmem['o0] = 36'o201_400000000;	// 1.0
	pdp10.ka10.fmem['o1] = 36'o202_400000000;	// 2.0
	pdp10.ka10.fmem['o2] = -36'o201_400000000;	// -1.0
	pdp10.ka10.fmem['o3] = -36'o202_400000000;	// -2.0
	pdp10.ka10.fmem['o4] = 36'o203_100000000;	// denorm 1.0
	pdp10.ka10.fmem['o5] = 36'o010_400000000;	// a really small number
	pdp10.ka10.fmem['o6] = 36'o203_400000000;	// 4.0
	for(i = 0; i < 'o20; i = i + 1) begin
		pdp10.mem0.core[i] = pdp10.ka10.fmem[i];
	end

	pdp10.mem0.core['o100] = 36'o001_000000123;
	pdp10.mem0.core['o101] = 36'o001_000000000;


//	pdp10.mem0.core['o20] = Inst(`FSC, 0, 0, 0, 4);
//	pdp10.mem0.core['o20] = Inst(`FSC, 4, 0, 0, 0);
//	pdp10.mem0.core['o20] = Inst(`DFN, 4, 0, 0, 'o100);
//	pdp10.mem0.core['o20] = Inst(`FMP, 0, 0, 0, 1);
//	pdp10.mem0.core['o20] = Inst(`FAD, 0, 0, 0, 6);
//	pdp10.mem0.core['o20] = Inst(`UFA, 0, 0, 0, 6);
//	pdp10.mem0.core['o20] = Inst(`FSB, 6, 0, 0, 0);
//	pdp10.mem0.core['o20] = Inst(`FDV, 0, 0, 0, 6);
//	pdp10.mem0.core['o20] = Inst(`FDVL, 0, 0, 0, 6);
	pdp10.mem0.core['o20] = Inst(`JRST, 4, 0, 0, 0);


	pdp10.mem0.core['o21] = Inst(`JRST, 4, 0, 0, 'o20);
	pdp10.mem0.core['o22] = Inst(`JRST, 4, 0, 0, 'o20);
	pdp10.mem0.core['o200] = Inst(`JRST, 4, 0, 0, 'o20);
end
