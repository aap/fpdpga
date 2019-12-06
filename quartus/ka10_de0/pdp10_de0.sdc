create_clock -name "FPGA_CLK1_50" -period 20.000ns [get_ports {FPGA_CLK1_50}]
derive_pll_clocks
derive_clock_uncertainty
