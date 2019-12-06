
`define ENABLE_HPS
//`define ENABLE_CLK

module pdp6(

      ///////// ADC /////////
      output             ADC_CONVST,
      output             ADC_SCK,
      output             ADC_SDI,
      input              ADC_SDO,

      ///////// ARDUINO /////////
      inout       [15:0] ARDUINO_IO,
      inout              ARDUINO_RESET_N,

`ifdef ENABLE_CLK
      ///////// CLK /////////
      output             CLK_I2C_SCL,
      inout              CLK_I2C_SDA,
`endif /*ENABLE_CLK*/

      ///////// FPGA /////////
      input              FPGA_CLK1_50,
      input              FPGA_CLK2_50,
      input              FPGA_CLK3_50,

      ///////// GPIO /////////
      inout       [35:0] GPIO_0,
      inout       [35:0] GPIO_1,

`ifdef ENABLE_HPS
      ///////// HPS /////////
      inout              HPS_CONV_USB_N,
      output      [14:0] HPS_DDR3_ADDR,
      output      [2:0]  HPS_DDR3_BA,
      output             HPS_DDR3_CAS_N,
      output             HPS_DDR3_CKE,
      output             HPS_DDR3_CK_N,
      output             HPS_DDR3_CK_P,
      output             HPS_DDR3_CS_N,
      output      [3:0]  HPS_DDR3_DM,
      inout       [31:0] HPS_DDR3_DQ,
      inout       [3:0]  HPS_DDR3_DQS_N,
      inout       [3:0]  HPS_DDR3_DQS_P,
      output             HPS_DDR3_ODT,
      output             HPS_DDR3_RAS_N,
      output             HPS_DDR3_RESET_N,
      input              HPS_DDR3_RZQ,
      output             HPS_DDR3_WE_N,
      output             HPS_ENET_GTX_CLK,
      inout              HPS_ENET_INT_N,
      output             HPS_ENET_MDC,
      inout              HPS_ENET_MDIO,
      input              HPS_ENET_RX_CLK,
      input       [3:0]  HPS_ENET_RX_DATA,
      input              HPS_ENET_RX_DV,
      output      [3:0]  HPS_ENET_TX_DATA,
      output             HPS_ENET_TX_EN,
      inout              HPS_GSENSOR_INT,
      inout              HPS_I2C0_SCLK,
      inout              HPS_I2C0_SDAT,
      inout              HPS_I2C1_SCLK,
      inout              HPS_I2C1_SDAT,
      inout              HPS_KEY,
      inout              HPS_LED,
      inout              HPS_LTC_GPIO,
      output             HPS_SD_CLK,
      inout              HPS_SD_CMD,
      inout       [3:0]  HPS_SD_DATA,
      output             HPS_SPIM_CLK,
      input              HPS_SPIM_MISO,
      output             HPS_SPIM_MOSI,
      inout              HPS_SPIM_SS,
      input              HPS_UART_RX,
      output             HPS_UART_TX,
      input              HPS_USB_CLKOUT,
      inout       [7:0]  HPS_USB_DATA,
      input              HPS_USB_DIR,
      input              HPS_USB_NXT,
      output             HPS_USB_STP,
`endif /*ENABLE_HPS*/

      ///////// KEY /////////
      input       [1:0]  KEY,

      ///////// LED /////////
      output      [7:0]  LED,

      ///////// SW /////////
      input       [3:0]  SW
);


//=======================================================
//  REG/WIRE declarations
//=======================================================
wire  hps_fpga_reset_n;




//=======================================================
//  Structural coding
//=======================================================

 soc_system u0 (
	  //Clock&Reset
	  .clk_clk                               (FPGA_CLK1_50 ),                               //                            clk.clk
	  .reset_reset_n                         (1'b1         ),                         //                          reset.reset_n
	  //HPS ddr3
	  .memory_mem_a                          ( HPS_DDR3_ADDR),                       //                memory.mem_a
	  .memory_mem_ba                         ( HPS_DDR3_BA),                         //                .mem_ba
	  .memory_mem_ck                         ( HPS_DDR3_CK_P),                       //                .mem_ck
	  .memory_mem_ck_n                       ( HPS_DDR3_CK_N),                       //                .mem_ck_n
	  .memory_mem_cke                        ( HPS_DDR3_CKE),                        //                .mem_cke
	  .memory_mem_cs_n                       ( HPS_DDR3_CS_N),                       //                .mem_cs_n
	  .memory_mem_ras_n                      ( HPS_DDR3_RAS_N),                      //                .mem_ras_n
	  .memory_mem_cas_n                      ( HPS_DDR3_CAS_N),                      //                .mem_cas_n
	  .memory_mem_we_n                       ( HPS_DDR3_WE_N),                       //                .mem_we_n
	  .memory_mem_reset_n                    ( HPS_DDR3_RESET_N),                    //                .mem_reset_n
	  .memory_mem_dq                         ( HPS_DDR3_DQ),                         //                .mem_dq
	  .memory_mem_dqs                        ( HPS_DDR3_DQS_P),                      //                .mem_dqs
	  .memory_mem_dqs_n                      ( HPS_DDR3_DQS_N),                      //                .mem_dqs_n
	  .memory_mem_odt                        ( HPS_DDR3_ODT),                        //                .mem_odt
	  .memory_mem_dm                         ( HPS_DDR3_DM),                         //                .mem_dm
	  .memory_oct_rzqin                      ( HPS_DDR3_RZQ),                        //                .oct_rzqin                                  
	  //HPS ethernet		
	  .hps_0_hps_io_hps_io_emac1_inst_TX_CLK ( HPS_ENET_GTX_CLK),       //                             hps_0_hps_io.hps_io_emac1_inst_TX_CLK
	  .hps_0_hps_io_hps_io_emac1_inst_TXD0   ( HPS_ENET_TX_DATA[0] ),   //                             .hps_io_emac1_inst_TXD0
	  .hps_0_hps_io_hps_io_emac1_inst_TXD1   ( HPS_ENET_TX_DATA[1] ),   //                             .hps_io_emac1_inst_TXD1
	  .hps_0_hps_io_hps_io_emac1_inst_TXD2   ( HPS_ENET_TX_DATA[2] ),   //                             .hps_io_emac1_inst_TXD2
	  .hps_0_hps_io_hps_io_emac1_inst_TXD3   ( HPS_ENET_TX_DATA[3] ),   //                             .hps_io_emac1_inst_TXD3
	  .hps_0_hps_io_hps_io_emac1_inst_RXD0   ( HPS_ENET_RX_DATA[0] ),   //                             .hps_io_emac1_inst_RXD0
	  .hps_0_hps_io_hps_io_emac1_inst_MDIO   ( HPS_ENET_MDIO ),         //                             .hps_io_emac1_inst_MDIO
	  .hps_0_hps_io_hps_io_emac1_inst_MDC    ( HPS_ENET_MDC  ),         //                             .hps_io_emac1_inst_MDC
	  .hps_0_hps_io_hps_io_emac1_inst_RX_CTL ( HPS_ENET_RX_DV),         //                             .hps_io_emac1_inst_RX_CTL
	  .hps_0_hps_io_hps_io_emac1_inst_TX_CTL ( HPS_ENET_TX_EN),         //                             .hps_io_emac1_inst_TX_CTL
	  .hps_0_hps_io_hps_io_emac1_inst_RX_CLK ( HPS_ENET_RX_CLK),        //                             .hps_io_emac1_inst_RX_CLK
	  .hps_0_hps_io_hps_io_emac1_inst_RXD1   ( HPS_ENET_RX_DATA[1] ),   //                             .hps_io_emac1_inst_RXD1
	  .hps_0_hps_io_hps_io_emac1_inst_RXD2   ( HPS_ENET_RX_DATA[2] ),   //                             .hps_io_emac1_inst_RXD2
	  .hps_0_hps_io_hps_io_emac1_inst_RXD3   ( HPS_ENET_RX_DATA[3] ),   //                             .hps_io_emac1_inst_RXD3		  
	  //HPS SD card 
	  .hps_0_hps_io_hps_io_sdio_inst_CMD     ( HPS_SD_CMD    ),           //                               .hps_io_sdio_inst_CMD
	  .hps_0_hps_io_hps_io_sdio_inst_D0      ( HPS_SD_DATA[0]     ),      //                               .hps_io_sdio_inst_D0
	  .hps_0_hps_io_hps_io_sdio_inst_D1      ( HPS_SD_DATA[1]     ),      //                               .hps_io_sdio_inst_D1
	  .hps_0_hps_io_hps_io_sdio_inst_CLK     ( HPS_SD_CLK   ),            //                               .hps_io_sdio_inst_CLK
	  .hps_0_hps_io_hps_io_sdio_inst_D2      ( HPS_SD_DATA[2]     ),      //                               .hps_io_sdio_inst_D2
	  .hps_0_hps_io_hps_io_sdio_inst_D3      ( HPS_SD_DATA[3]     ),      //                               .hps_io_sdio_inst_D3
	  //HPS USB 		  
	  .hps_0_hps_io_hps_io_usb1_inst_D0      ( HPS_USB_DATA[0]    ),      //                               .hps_io_usb1_inst_D0
	  .hps_0_hps_io_hps_io_usb1_inst_D1      ( HPS_USB_DATA[1]    ),      //                               .hps_io_usb1_inst_D1
	  .hps_0_hps_io_hps_io_usb1_inst_D2      ( HPS_USB_DATA[2]    ),      //                               .hps_io_usb1_inst_D2
	  .hps_0_hps_io_hps_io_usb1_inst_D3      ( HPS_USB_DATA[3]    ),      //                               .hps_io_usb1_inst_D3
	  .hps_0_hps_io_hps_io_usb1_inst_D4      ( HPS_USB_DATA[4]    ),      //                               .hps_io_usb1_inst_D4
	  .hps_0_hps_io_hps_io_usb1_inst_D5      ( HPS_USB_DATA[5]    ),      //                               .hps_io_usb1_inst_D5
	  .hps_0_hps_io_hps_io_usb1_inst_D6      ( HPS_USB_DATA[6]    ),      //                               .hps_io_usb1_inst_D6
	  .hps_0_hps_io_hps_io_usb1_inst_D7      ( HPS_USB_DATA[7]    ),      //                               .hps_io_usb1_inst_D7
	  .hps_0_hps_io_hps_io_usb1_inst_CLK     ( HPS_USB_CLKOUT    ),       //                               .hps_io_usb1_inst_CLK
	  .hps_0_hps_io_hps_io_usb1_inst_STP     ( HPS_USB_STP    ),          //                               .hps_io_usb1_inst_STP
	  .hps_0_hps_io_hps_io_usb1_inst_DIR     ( HPS_USB_DIR    ),          //                               .hps_io_usb1_inst_DIR
	  .hps_0_hps_io_hps_io_usb1_inst_NXT     ( HPS_USB_NXT    ),          //                               .hps_io_usb1_inst_NXT
		//HPS SPI 		  
	  .hps_0_hps_io_hps_io_spim1_inst_CLK    ( HPS_SPIM_CLK  ),           //                               .hps_io_spim1_inst_CLK
	  .hps_0_hps_io_hps_io_spim1_inst_MOSI   ( HPS_SPIM_MOSI ),           //                               .hps_io_spim1_inst_MOSI
	  .hps_0_hps_io_hps_io_spim1_inst_MISO   ( HPS_SPIM_MISO ),           //                               .hps_io_spim1_inst_MISO
	  .hps_0_hps_io_hps_io_spim1_inst_SS0    ( HPS_SPIM_SS   ),             //                               .hps_io_spim1_inst_SS0
		//HPS UART		
	  .hps_0_hps_io_hps_io_uart0_inst_RX     ( HPS_UART_RX   ),          //                               .hps_io_uart0_inst_RX
	  .hps_0_hps_io_hps_io_uart0_inst_TX     ( HPS_UART_TX   ),          //                               .hps_io_uart0_inst_TX
		//HPS I2C1
	  .hps_0_hps_io_hps_io_i2c0_inst_SDA     ( HPS_I2C0_SDAT  ),        //                               .hps_io_i2c0_inst_SDA
	  .hps_0_hps_io_hps_io_i2c0_inst_SCL     ( HPS_I2C0_SCLK  ),        //                               .hps_io_i2c0_inst_SCL
		//HPS I2C2
	  .hps_0_hps_io_hps_io_i2c1_inst_SDA     ( HPS_I2C1_SDAT  ),        //                               .hps_io_i2c1_inst_SDA
	  .hps_0_hps_io_hps_io_i2c1_inst_SCL     ( HPS_I2C1_SCLK  ),        //                               .hps_io_i2c1_inst_SCL
		//GPIO 
	  .hps_0_hps_io_hps_io_gpio_inst_GPIO09  ( HPS_CONV_USB_N ),  //                               .hps_io_gpio_inst_GPIO09
	  .hps_0_hps_io_hps_io_gpio_inst_GPIO35  ( HPS_ENET_INT_N ),  //                               .hps_io_gpio_inst_GPIO35
	  .hps_0_hps_io_hps_io_gpio_inst_GPIO40  ( HPS_LTC_GPIO   ),  //                               .hps_io_gpio_inst_GPIO40
	  .hps_0_hps_io_hps_io_gpio_inst_GPIO53  ( HPS_LED   ),  //                               .hps_io_gpio_inst_GPIO53
	  .hps_0_hps_io_hps_io_gpio_inst_GPIO54  ( HPS_KEY   ),  //                               .hps_io_gpio_inst_GPIO54
	  .hps_0_hps_io_hps_io_gpio_inst_GPIO61  ( HPS_GSENSOR_INT ),  //                               .hps_io_gpio_inst_GPIO61
		//FPGA Partion
	  .switch_pio_external_connection_export (SW),
	  .button_pio_external_connection_export (KEY),
	  .hps_0_h2f_reset_reset_n               (hps_fpga_reset_n)
	  
		,
		.cmem_externals_power(1'b1),
		.cmem_externals_restart(1'b0),
		.cmem_externals_single_step(1'b0),
		.cmem_slave_1_fmc_select(1'b0),
		.cmem_slave_1_ma(15'b0),
		.cmem_slave_1_mb_write(36'b0),
		.cmem_slave_1_rd_rq(1'b0),
		.cmem_slave_1_rq_cyc(1'b0),
		.cmem_slave_1_sel(4'b0),
		.cmem_slave_1_wr_rq(1'b0),
		.cmem_slave_1_wr_rs(1'b0),
		.cmem_slave_2_fmc_select(1'b0),
		.cmem_slave_2_ma(15'b0),
		.cmem_slave_2_mb_write(36'b0),
		.cmem_slave_2_rd_rq(1'b0),
		.cmem_slave_2_rq_cyc(1'b0),
		.cmem_slave_2_sel(4'b0),
		.cmem_slave_2_wr_rq(1'b0),
		.cmem_slave_2_wr_rs(1'b0),
		.cmem_slave_3_fmc_select(1'b0),
		.cmem_slave_3_ma(15'b0),
		.cmem_slave_3_mb_write(36'b0),
		.cmem_slave_3_rd_rq(1'b0),
		.cmem_slave_3_rq_cyc(1'b0),
		.cmem_slave_3_sel(4'b0),
		.cmem_slave_3_wr_rq(1'b0),
		.cmem_slave_3_wr_rs(1'b0),
		
		.fmem_externals_power(1'b1),
		.fmem_externals_single_step(1'b0),
		.fmem_externals_restart(1'b0),
		.fmem_slave_1_fmc_select(1'b0),
		.fmem_slave_1_ma(15'b0),
		.fmem_slave_1_mb_write(36'b0),
		.fmem_slave_1_rd_rq(1'b0),
		.fmem_slave_1_rq_cyc(1'b0),
		.fmem_slave_1_sel(4'b0),
		.fmem_slave_1_wr_rq(1'b0),
		.fmem_slave_1_wr_rs(1'b0),
		.fmem_slave_2_fmc_select(1'b0),
		.fmem_slave_2_ma(15'b0),
		.fmem_slave_2_mb_write(36'b0),
		.fmem_slave_2_rd_rq(1'b0),
		.fmem_slave_2_rq_cyc(1'b0),
		.fmem_slave_2_sel(4'b0),
		.fmem_slave_2_wr_rq(1'b0),
		.fmem_slave_2_wr_rs(1'b0),
		.fmem_slave_3_fmc_select(1'b0),
		.fmem_slave_3_ma(15'b0),
		.fmem_slave_3_mb_write(36'b0),
		.fmem_slave_3_rd_rq(1'b0),
		.fmem_slave_3_rq_cyc(1'b0),
		.fmem_slave_3_sel(4'b0),
		.fmem_slave_3_wr_rq(1'b0),
		.fmem_slave_3_wr_rs(1'b0),

		.panel_leds(LED),
		.panel_switches(sw_sync),
		.panel_ext(panel_ext),
		
		.tty_rx(rx),
		.tty_tx(tx),
		
		.ptr_fe_data_rq(fe_ptr_rq),
		.ptp_fe_data_rq(fe_ptp_rq),
		.dis340_fe_data_rq(fe_dis_rq),
		.fe_req_req(fe_req),
		
		.wcsl_av_externals_ctl1(ctl1),
		.wcsl_av_externals_ctl2(ctl2),
		.wcsl_av_externals_ctl3(ctl3),
		.wcsl_av_externals_ctl4(ctl4),
		.wcsl724_externals_ctl1(ctl1),
		.wcsl724_externals_ctl2(ctl2),
		.wcsl420_externals_ctl1(ctl1),
		.wcsl420_externals_ctl2(ctl2),
		.wcsl420_externals_ctl3(ctl3),
		.wcsl420_externals_ctl4(ctl4),
	);
	
	wire clk = FPGA_CLK1_50;
	wire reset = 1'b0;

	/* Synchronize/debounce switches */
	wire clk1;
	clk50khz clk50khz_1(clk, clk1);	
	reg [3:0] sw_sync;
	always @(posedge clk) begin
		if(clk1)
			sw_sync <= SW;
	end

	/* UART */
	wire rx, tx;
	assign rx = GPIO_0[0];
	assign GPIO_0[1] = tx;

	/* FE request */
	wire fe_ptr_rq;
	wire fe_ptp_rq;
	wire fe_dis_rq;
	wire [31:0] fe_req;
	assign fe_req[0] = fe_ptr_rq;
	assign fe_req[1] = fe_ptp_rq;
	assign fe_req[2] = fe_dis_rq;
	assign fe_req[31:3] = 0;

	/* LEDs */
	wire [7:0] panel_ext;
	assign panel_ext[0] = fe_ptr_rq;
	assign panel_ext[1] = fe_ptp_rq;
	assign panel_ext[2] = fe_dis_rq;
	assign panel_ext[7:3] = 0;
	
	/* Controllers */
	wire [0:17] ctl1;
	wire [0:17] ctl2;
	wire [0:17] ctl3;
	wire [0:17] ctl4;
endmodule
