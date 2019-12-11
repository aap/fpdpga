initial begin: meminit
	integer i;

	for(i = 0; i < 'o40000; i = i + 1)
		pdp10.mem0.core[i] = 0;
	for(i = 0; i < 'o20; i = i + 1) begin
		pdp10.mem0.core[i] = 0;
		pdp10.ka10.fmem[i] = 0;
	end

	pdp10.ka10.fmem[1] = 36'o123000_000321;
	pdp10.ka10.fmem[2] = 36'o456000_000654;
	pdp10.ka10.fmem[3] = 36'o056000_000654;
	pdp10.ka10.fmem[4] = 36'o000003_000111;
	pdp10.ka10.fmem[5] = 36'o777776_000111;
	pdp10.ka10.fmem['o7] = 36'o777777_777777;
	pdp10.ka10.fmem['o10] = 36'o000000_000000;
	pdp10.ka10.fmem['o11] = 36'o000000_000001;
	pdp10.ka10.fmem['o14] = 36'o010700_000300;
	pdp10.ka10.fmem['o15] = 36'o300600_000300;
	pdp10.ka10.fmem['o16] = 36'o000001_000400;
	pdp10.ka10.fmem['o17] = 36'o000000_000300;
	for(i = 0; i < 'o20; i = i + 1) begin
		pdp10.mem0.core[i] = pdp10.ka10.fmem[i];
	end

	pdp10.mem0.core['o141] = 36'o000000000001;
	pdp10.mem0.core['o142] = 36'o000000000002;
	pdp10.mem0.core['o200] = 36'o777740000100;
	pdp10.mem0.core['o201] = 36'o777776_000277;
	pdp10.mem0.core['o300] = 36'o123456111222;
	pdp10.mem0.core['o002000] = 36'o006000001001;

	// IO tests
//	pdp10.mem0.core['o20] = IoInst(`DATAO, 0, 0, 0, 'o002000);
//	pdp10.mem0.core['o20] = IoInst(`DATAO, 0, 0, 0, 'o200);
//	pdp10.mem0.core['o20] = IoInst(`DATAI, 0, 0, 0, 'o200);
//	pdp10.mem0.core['o20] = IoInst(`CONO, 0, 0, 0, 'o777777);
//	pdp10.mem0.core['o20] = IoInst(`CONI, 0, 0, 0, 'o200);
//	pdp10.mem0.core['o20] = IoInst(`CONO, 4, 0, 0, 'o777777);
//	pdp10.mem0.core['o20] = IoInst(`CONO, 4, 0, 0, 'o004177); // set PIR
//	pdp10.mem0.core['o20] = IoInst(`CONO, 4, 0, 0, 'o002177); // set PIO
//	pdp10.mem0.core['o20] = IoInst(`CONO, 4, 0, 0, 'o001177); // clr PIO
//	pdp10.mem0.core['o20] = IoInst(`CONO, 4, 0, 0, 'o003107); // cmpl PIO
//	pdp10.mem0.core['o20] = IoInst(`CONO, 4, 0, 0, 'o000400); // clr ACT
//	pdp10.mem0.core['o20] = IoInst(`CONO, 4, 0, 0, 'o000200); // set ACT
//	pdp10.mem0.core['o20] = IoInst(`CONO, 4, 0, 0, 'o000600); // cmpl ACT
//	pdp10.mem0.core['o20] = IoInst(`CONO, 4, 0, 0, 'o740000); // CPA stuff
//	pdp10.mem0.core['o20] = IoInst(`CONI, 4, 0, 0, 'o200);
//	pdp10.mem0.core['o20] = IoInst(`CONSO, 0, 0, 0, 'o777);
//	pdp10.mem0.core['o20] = IoInst(`CONSZ, 0, 0, 0, 'o777);
//	pdp10.mem0.core['o20] = IoInst(`CONSO, 0, 0, 0, 0);
//	pdp10.mem0.core['o20] = IoInst(`CONSZ, 0, 0, 0, 0);
//	pdp10.mem0.core['o20] = IoInst(`DATAO, 4, 0, 0, 'o300);
//	pdp10.mem0.core['o20] = IoInst(`BLKO, 4, 0, 0, 'o201);

//	pdp10.mem0.core['o20] = Inst(`BLT, 'o16, 0, 0, 'o403);
//	pdp10.mem0.core['o20] = Inst(`JFFO, 0, 0, 0, 'o200);
//	pdp10.mem0.core['o20] = Inst(`JFFO, 'o3, 0, 0, 'o200);
//	pdp10.mem0.core['o20] = Inst(`JFFO, 'o11 , 0, 0, 'o200);

	// Byte tests
//	pdp10.mem0.core['o20] = Inst(`IBP, 0, 0, 0, 'o14);
//	pdp10.mem0.core['o20] = Inst(`IBP, 0, 0, 0, 'o15);
//	pdp10.mem0.core['o20] = Inst(`LDB, 0, 0, 0, 'o15);
//	pdp10.mem0.core['o20] = Inst(`ILDB, 0, 0, 0, 'o15);
//	pdp10.mem0.core['o20] = Inst(`IDPB, 'o1, 0, 0, 'o15);

	// Shift tests
//	pdp10.mem0.core['o20] = Inst(`ASH, 2, 0, 0, 'o3);
//	pdp10.mem0.core['o20] = Inst(`ASH, 2, 0, 0, -'o3);
//	pdp10.mem0.core['o20] = Inst(`LSH, 2, 0, 0, 'o3);
//	pdp10.mem0.core['o20] = Inst(`LSH, 2, 0, 0, -'o3);
//	pdp10.mem0.core['o20] = Inst(`ROT, 2, 0, 0, 'o3);
//	pdp10.mem0.core['o20] = Inst(`ROT, 2, 0, 0, -'o3);
//	pdp10.mem0.core['o20] = Inst(`ASHC, 2, 0, 0, 'o3);
//	pdp10.mem0.core['o20] = Inst(`ASHC, 2, 0, 0, -'o3);
//	pdp10.mem0.core['o20] = Inst(`LSHC, 2, 0, 0, 'o3);
//	pdp10.mem0.core['o20] = Inst(`LSHC, 2, 0, 0, -'o3);
//	pdp10.mem0.core['o20] = Inst(`ROTC, 2, 0, 0, 'o3);
//	pdp10.mem0.core['o20] = Inst(`ROTC, 2, 0, 0, -'o3);

	// FWT tests
//	pdp10.mem0.core['o20] = Inst(`MOVE, 2, 0, 0, 1);
//	pdp10.mem0.core['o20] = Inst(`MOVS, 2, 0, 0, 1);
//	pdp10.mem0.core['o20] = Inst(`MOVSS, 0, 0, 0, 1);
//	pdp10.mem0.core['o20] = Inst(`MOVN, 2, 0, 0, 1);
//	pdp10.mem0.core['o20] = Inst(`MOVN, 2, 0, 0, 0);
//	pdp10.mem0.core['o20] = Inst(`MOVM, 2, 0, 0, 1);
//	pdp10.mem0.core['o20] = Inst(`MOVM, 1, 0, 0, 2);
	pdp10.mem0.core['o20] = Inst(`MOVEM, 2, 0, 0, 'o100);

	// HWT tests
//	pdp10.mem0.core['o20] = Inst(`HLL, 2, 0, 0, 1);
//	pdp10.mem0.core['o20] = Inst(`HLLI, 2, 0, 0, 1);
//	pdp10.mem0.core['o20] = Inst(`HRR, 2, 0, 0, 1);
//	pdp10.mem0.core['o20] = Inst(`HRRI, 2, 0, 0, 1);
//	pdp10.mem0.core['o20] = Inst(`HRL, 2, 0, 0, 1);
//	pdp10.mem0.core['o20] = Inst(`HRLI, 2, 0, 0, 1);
//	pdp10.mem0.core['o20] = Inst(`HLR, 2, 0, 0, 1);
//	pdp10.mem0.core['o20] = Inst(`HLRI, 2, 0, 0, 1);
//	pdp10.mem0.core['o20] = Inst(`HLLO, 2, 0, 0, 1);
//	pdp10.mem0.core['o20] = Inst(`HLLE, 2, 0, 0, 1);
//	pdp10.mem0.core['o20] = Inst(`HLLZ, 2, 0, 0, 1);
//	pdp10.mem0.core['o20] = Inst(`HLLO, 2, 0, 0, 1);
//	pdp10.mem0.core['o20] = Inst(`HLLE, 2, 0, 0, 1);
//	pdp10.mem0.core['o20] = Inst(`HLLE, 2, 0, 0, 2);

	// Misc tests
//	pdp10.mem0.core['o20] = Inst('o034, 2, 0, 0, 1);
//	pdp10.mem0.core['o20] = Inst(`EXCH, 2, 0, 0, 'o200);
//	pdp10.mem0.core['o20] = Inst(`AOBJP, 4, 0, 0, 'o100);
//	pdp10.mem0.core['o20] = Inst(`AOBJP, 5, 0, 0, 'o100);
//	pdp10.mem0.core['o20] = Inst(`AOBJN, 4, 0, 0, 'o100);
//	pdp10.mem0.core['o20] = Inst(`AOBJN, 5, 0, 0, 'o100);
//	pdp10.mem0.core['o20] = Inst(`XCT, 0, 0, 0, 'o100);
//	pdp10.mem0.core['o20] = Inst(`PUSHJ, 'o17, 0, 0, 'o100);
//	pdp10.mem0.core['o20] = Inst(`PUSH, 'o17, 0, 0, 'o200);
//	pdp10.mem0.core['o20] = Inst(`POP, 'o17, 0, 0, 'o200);
//	pdp10.mem0.core['o20] = Inst(`POPJ, 'o17, 0, 0, 'o200);

	// Add/Sub tests
//	pdp10.mem0.core['o20] = Inst(`ADD, 2, 0, 0, 1);
//	pdp10.mem0.core['o20] = Inst(`ADDM, 2, 0, 0, 1);
//	pdp10.mem0.core['o20] = Inst(`SUB, 2, 0, 0, 1);

	// Boole tests
//	pdp10.mem0.core['o20] = Inst(`SETZ, 2, 0, 0, 1);
//	pdp10.mem0.core['o20] = Inst(`SETZB, 2, 0, 0, 1);
//	pdp10.mem0.core['o20] = Inst(`AND, 2, 0, 0, 1);
//	pdp10.mem0.core['o20] = Inst(`ANDCA, 2, 0, 0, 1);
//	pdp10.mem0.core['o20] = Inst(`SETM, 2, 0, 0, 1);
//	pdp10.mem0.core['o20] = Inst(`ANDCM, 2, 0, 0, 1);
//	pdp10.mem0.core['o20] = Inst(`SETA, 2, 0, 0, 1);
//	pdp10.mem0.core['o20] = Inst(`XOR, 2, 0, 0, 1);
//	pdp10.mem0.core['o20] = Inst(`IOR, 2, 0, 0, 1);
//	pdp10.mem0.core['o20] = Inst(`ANDCB, 2, 0, 0, 1);
//	pdp10.mem0.core['o20] = Inst(`EQV, 2, 0, 0, 1);
//	pdp10.mem0.core['o20] = Inst(`SETCA, 2, 0, 0, 1);
//	pdp10.mem0.core['o20] = Inst(`ORCA, 2, 0, 0, 1);
//	pdp10.mem0.core['o20] = Inst(`SETCM, 2, 0, 0, 1);
//	pdp10.mem0.core['o20] = Inst(`ORCM, 2, 0, 0, 1);
//	pdp10.mem0.core['o20] = Inst(`ORCB, 2, 0, 0, 1);
//	pdp10.mem0.core['o20] = Inst(`SETO, 2, 0, 0, 1);

	// Jump tests
//	pdp10.mem0.core['o20] = Inst(`JSR, 2, 0, 0, 1);
//	pdp10.mem0.core['o20] = Inst(`JSP, 2, 0, 0, 1);
//	pdp10.mem0.core['o20] = Inst(`JSA, 2, 0, 0, 1);
//	pdp10.mem0.core['o20] = Inst(`JRA, 4, 0, 0, 'o100);
//	pdp10.mem0.core['o20] = Inst(`JFCL, 4, 0, 0, 'o100);
//	pdp10.mem0.core['o20] = Inst(`JFCL, 'o17, 0, 0, 'o100);
//	pdp10.mem0.core['o20] = Inst(`JRST, 0, 0, 0, 'o100);
//	pdp10.mem0.core['o20] = Inst(`JRST, 'o10, 0, 0, 'o100);
//	pdp10.mem0.core['o20] = Inst(`JRST, 4, 0, 0, 'o100);
//	pdp10.mem0.core['o20] = Inst(`JRST, 2, 1, 0, 'o200);
//	pdp10.mem0.core['o20] = Inst(`JRST, 1, 0, 0, 'o100);

	// Boolean Test tests
//	pdp10.mem0.core['o20] = Inst(`TRN, 1, 0, 0, 0);
//	pdp10.mem0.core['o20] = Inst(`TRNE, 1, 0, 0, 1);
//	pdp10.mem0.core['o20] = Inst(`TRNA, 1, 0, 0, 0);
//	pdp10.mem0.core['o20] = Inst(`TRNN, 1, 0, 0, 2);
//	pdp10.mem0.core['o20] = Inst(`TLN, 1, 0, 0, 0);
//	pdp10.mem0.core['o20] = Inst(`TLNE, 1, 0, 0, 'o200000);
//	pdp10.mem0.core['o20] = Inst(`TLNA, 1, 0, 0, 0);
//	pdp10.mem0.core['o20] = Inst(`TLNN, 1, 0, 0, 'o200000);
//	pdp10.mem0.core['o20] = Inst(`TDNE, 1, 0, 0, 'o142);
//	pdp10.mem0.core['o20] = Inst(`TRZN, 1, 0, 0, 'o777);
//	pdp10.mem0.core['o20] = Inst(`TRON, 1, 0, 0, 'o777);
//	pdp10.mem0.core['o20] = Inst(`TRCN, 1, 0, 0, 'o777);
//	pdp10.mem0.core['o20] = Inst(`TLCN, 1, 0, 0, 'o777000);

	// Arithmetic Test tests
//	pdp10.mem0.core['o20] = Inst(`CAI, 'o11, 0, 0, 0);
//	pdp10.mem0.core['o20] = Inst(`CAIL, 'o11, 0, 0, 0);
//	pdp10.mem0.core['o20] = Inst(`CAIE, 'o11, 0, 0, 0);
//	pdp10.mem0.core['o20] = Inst(`CAILE, 'o11, 0, 0, 0);
//	pdp10.mem0.core['o20] = Inst(`CAIA, 'o11, 0, 0, 0);
//	pdp10.mem0.core['o20] = Inst(`CAIGE, 'o11, 0, 0, 0);
//	pdp10.mem0.core['o20] = Inst(`CAIN, 'o11, 0, 0, 0);
//	pdp10.mem0.core['o20] = Inst(`CAIG, 'o11, 0, 0, 0);
//	pdp10.mem0.core['o20] = Inst(`JUMP, 'o7, 0, 0, 'o100);
//	pdp10.mem0.core['o20] = Inst(`JUMPL, 'o7, 0, 0, 'o100);
//	pdp10.mem0.core['o20] = Inst(`JUMPE, 'o7, 0, 0, 'o100);
//	pdp10.mem0.core['o20] = Inst(`JUMPLE, 'o7, 0, 0, 'o100);
//	pdp10.mem0.core['o20] = Inst(`JUMPA, 'o7, 0, 0, 'o100);
//	pdp10.mem0.core['o20] = Inst(`JUMPGE, 'o7, 0, 0, 'o100);
//	pdp10.mem0.core['o20] = Inst(`JUMPN, 'o7, 0, 0, 'o100);
//	pdp10.mem0.core['o20] = Inst(`JUMPG, 'o7, 0, 0, 'o100);
//	pdp10.mem0.core['o20] = Inst(`AOJA, 'o7, 0, 0, 'o100);
//	pdp10.mem0.core['o20] = Inst(`SOJA, 'o7, 0, 0, 'o100);
//	pdp10.mem0.core['o20] = Inst(`SKIPA, 0, 0, 0, 'o7);
//	pdp10.mem0.core['o20] = Inst(`AOSA, 0, 0, 0, 'o7);
//	pdp10.mem0.core['o20] = Inst(`SOSA, 0, 0, 0, 'o7);


//	pdp10.mem0.core['o20] = Inst(`MOVE, 2, 0, 0, 'o777777);

	pdp10.mem0.core['o21] = Inst(`JRST, 4, 0, 0, 'o20);
	pdp10.mem0.core['o22] = Inst(`JRST, 4, 0, 0, 'o20);
	pdp10.mem0.core['o200] = Inst(`JRST, 4, 0, 0, 'o20);
end
