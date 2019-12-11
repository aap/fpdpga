initial begin: meminit
	integer i;

	for(i = 0; i < 'o40000; i = i + 1)
		pdp10.mem16k.ram.ram[i] = 0;
	for(i = 0; i < 'o20; i = i + 1) begin
		pdp10.mem16k.ram.ram[i] = 0;
		pdp10.ka10.fmem[i] = 0;
	end

	pdp10.ka10.fmem[0] = 36'o777777_777777;
	pdp10.ka10.fmem[1] = 36'o777777_000000;
	pdp10.ka10.fmem[2] = 36'o201400000000;
	pdp10.ka10.fmem[3] = 36'o606327501325;
	pdp10.ka10.fmem[4] = 36'o000003_000111;
	pdp10.ka10.fmem[5] = 36'o777776_000111;
	pdp10.ka10.fmem[6] = 36'o777777_777777;
	pdp10.ka10.fmem['o7] = 36'o777777_777777;
	pdp10.ka10.fmem['o10] = 36'o000000_000001;
	pdp10.ka10.fmem['o11] = 36'o000000_000001;
	pdp10.ka10.fmem['o12] = 36'o000000_000002;
	pdp10.ka10.fmem['o13] = 36'o400000_000000;
	pdp10.ka10.fmem['o14] = 36'o010700_000300;
	pdp10.ka10.fmem['o15] = 36'o300600_000300;
	pdp10.ka10.fmem['o16] = 36'o000001_000400;
	pdp10.ka10.fmem['o17] = 36'o000000_000300;
	for(i = 0; i < 'o20; i = i + 1) begin
		pdp10.mem16k.ram.ram[i] = pdp10.ka10.fmem[i];
	end

	pdp10.mem16k.ram.ram['o42] = IoInst(`DATAO, 0, 0, 0, 0);


	pdp10.mem16k.ram.ram['o141] = 36'o000000000001;
	pdp10.mem16k.ram.ram['o142] = 36'o000000000002;
	pdp10.mem16k.ram.ram['o200] = 36'o777740000100;
	pdp10.mem16k.ram.ram['o201] = 36'o777776_000277;
	pdp10.mem16k.ram.ram['o300] = 36'o123456111222;
	pdp10.mem16k.ram.ram['o002000] = 36'o006000001001;

	pdp10.mem16k.ram.ram['o1000] = 36'o001100000006;
	pdp10.mem16k.ram.ram['o1001] = 36'o111100000006;
	pdp10.mem16k.ram.ram['o1002] = 36'o221100000006;
	pdp10.mem16k.ram.ram['o1003] = 36'o331100000006;


	pdp10.mem16k.ram.ram['o20] = IoInst(`CONO, 'o120, 0, 'o0, 'o1000);



	pdp10.mem16k.ram.ram['o21] = Inst(`JRST, 4, 0, 0, 'o21);
	pdp10.mem16k.ram.ram['o22] = Inst(`JRST, 4, 0, 0, 'o22);
	pdp10.mem16k.ram.ram['o200] = Inst(`JRST, 4, 0, 0, 'o200);
end

