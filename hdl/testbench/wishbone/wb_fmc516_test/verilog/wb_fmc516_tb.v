//----------------------------------------------------------------------------
// Title      : Wishbone FMC516 Testbench Interface
//----------------------------------------------------------------------------
// Author     : Lucas Maziero Russo
// Company    : CNPEM LNLS-DIG
// Created    : 2012-14-11
// Platform   : FPGA-generic
//-----------------------------------------------------------------------------
// Description: Testbench for the FMC516 ADC Interface.
//-----------------------------------------------------------------------------
// Copyright (c) 2012 CNPEM
// Licensed under GNU Lesser General Public License (LGPL) v3.0
//-----------------------------------------------------------------------------
// Revisions  :
// Date        Version  Author          Description
// 2012-14-11  1.0      lucas.russo        Created
//-----------------------------------------------------------------------------

// Common definitions
`include "defines.v"
// Simulation timescale
`include "timescale.v"
// Wishbone Master
`include "wishbone_test_master.v"
//`include "wishbone_bfm.v"
// fmc150 Register definitions
`include "xfmc516_regs.vh"

module wb_fmc516_tb;

  // Clocks
  wire clk_sys, clk_adc;
  wire clk_100mhz, clk_200mhz;
  // Reset
  wire rstn;

  // Data generation
  reg [`ADC_DATA_WIDTH/2-1:0] adc_ch0_data_p;
  reg [`ADC_DATA_WIDTH/2-1:0] adc_ch1_data_p;
  reg [`ADC_DATA_WIDTH/2-1:0] adc_ch2_data_p;
  reg [`ADC_DATA_WIDTH/2-1:0] adc_ch3_data_p;
  reg [`ADC_DATA_WIDTH/2-1:0] adc_ch0_data_n;
  reg [`ADC_DATA_WIDTH/2-1:0] adc_ch1_data_n;
  reg [`ADC_DATA_WIDTH/2-1:0] adc_ch2_data_n;
  reg [`ADC_DATA_WIDTH/2-1:0] adc_ch3_data_n;
  reg adc_data_valid;

  // Wishbone signals

  // Local definitions
  //real g_adc_clk_period_values[3:0] =
  localparam adc_data_max = (2**`ADC_DATA_WIDTH)-1;
  localparam adc_gen_threshold = 0.5;
  // Word (32-bit) granularity
  localparam g_granularity = 4;
  // After reset delay
  localparam g_after_reset_delay = 16;

  localparam CLASSIC = 0;
  localparam PIPELINED = 1;
  localparam BYTE = 0;
  localparam WORD = 1;

  // Internal registers
  reg zero_bit = 1'b0;
  reg one_bit = 1'b1;
  reg spi_busy = 1'b0;
  reg [`WB_ADDRESS_BUS_WIDTH-1:0] data_out;

  // SPI ADC Signals
  reg sys_spi_data_reg = 1'b0;
  reg sys_spi_data_en = 1'b0;
  wire sys_spi_data;
  wire sys_spi_cs_0;
  wire sys_spi_cs_1;
  wire sys_spi_cs_2;
  wire sys_spi_cs_3;

  // Clock and Reset
  clk_rst cmp_rst(
    .clk_sys_o(clk_sys),
    .clk_adc_o(clk_adc),
    .clk_100mhz_o(clk_100mhz),
    .clk_200mhz_o(clk_200mhz),
    .rstn_o(rstn)
  );

  // Acessible register from WB_TEST_MASTER
  //reg [`WB_ADDRESS_BUS_WIDTH - 1 : 0] wb_addr = 0;
  //reg [`WB_DATA_BUS_WIDTH - 1 : 0]    wb_data_o = 0;
  //reg [`WB_BWSEL_WIDTH - 1 : 0]       wb_bwsel = 0;
  //wire [`WB_DATA_BUS_WIDTH -1 : 0]    wb_data_i;
  //wire                                wb_ack_i;
  //reg 	                              wb_cyc = 0;
  //reg 	                              wb_stb = 0;
  //reg 	                              wb_we = 0;
  //reg 	                              wb_rst = 0;
  //reg 	                              wb_clk = 1;

  // Wiswhbone Master
  WB_TEST_MASTER cmp_wishbone_bfm(.wb_clk(clk_100mhz));
  //wishbone_bfm cmp_wishbone_bfm(.wb_clk(clk_100mhz));

  // model tristate buffer
  assign sys_spi_data = sys_spi_data_en ? sys_spi_data_reg : 1'bz;

  initial begin
    // Enable cmp_wb_master verbosity and bus monitoring
    // Enable verbose mode
    wb_fmc516_tb.cmp_wishbone_bfm.verbose(1);
    // Enable monitor bus
    wb_fmc516_tb.cmp_wishbone_bfm.monitor_bus(1);

    // Initial values for ADC data signals
    adc_ch0_data_p <= 'h0;
    adc_ch1_data_p <= 'h0;
    adc_ch2_data_p <= 'h0;
    adc_ch3_data_p <= 'h0;
    adc_data_valid <= 'h0;

    // Wait next clock cycle
    @(posedge clk_sys);

    // Wait until reset is done
    while (!rstn) begin
      $display("@%0d: Waiting for reset completion...", $time);
      @(posedge clk_sys);
    end

    $display("@%0d: Reset and MMCM done!", $time);

    // wait a few cycles before stimulus. Synchronizer chains needs to
    // update...
    while (!fmc_mmcm_lock) begin
      $display("@%0d: Waiting for MMCM lock...", $time);
      @(posedge clk_sys);
    end

    $display("@%0d: MMCM locked!", $time);

    // Testing SPI 3-wire communication
    @(posedge clk_sys);
    $display("----------------------------------------");
    $display("@%0d: Writing data: FPGA -> external...", $time);
    $display("----------------------------------------");
    // RX/TX Register
    //cmp_wishbone_bfm.write32(32'h00000200 << 2, 32'hAAAAAAAA);
    cmp_wishbone_bfm.write32(32'h00000300 << 2, 32'hAAAAAAAA);
    @(posedge clk_sys);
    // Control register set. Direction reg is 1. Write to external chip
    //cmp_wishbone_bfm.write32(32'h00000204 << 2, 32'h00006420);
    cmp_wishbone_bfm.write32(32'h00000304 << 2, 32'h00006420);
    @(posedge clk_sys);
    // SS register set. Select slave #0
    //cmp_wishbone_bfm.write32(32'h00000206 << 2, 32'h00000001);
    cmp_wishbone_bfm.write32(32'h00000306 << 2, 32'h00000001);
    @(posedge clk_sys);
    // Control register set = set the go bit
    //cmp_wishbone_bfm.write32(32'h00000204 << 2, 32'h00006520);
    cmp_wishbone_bfm.write32(32'h00000304 << 2, 32'h00006520);
    @(posedge clk_sys);

    wait_spi_busy();

    // wait a few cycles
    repeat (8)
      @(posedge clk_sys);

    @(posedge clk_sys);
    $display("----------------------------------------");
    $display("@%0d: Reading data: external -> FPGA...", $time);
    $display("----------------------------------------");

    // 2 parallel tasks.
    // 1: device write data to spi bus as soon as sys_spi_cs_0
    // 2: fpga core read data from spi bus
    fork
      // Write 1010... pattern to data input SPI bus and read its data
      begin
        // The SPI core has clock idle = 0 and cs = 1 -> 0
        @(negedge sys_spi_cs_0)
        $display("@%0d: External will start writing to SPI bus...", $time);
        sys_spi_data_en = 1'b1;
        sys_spi_data_reg = #1 1'b1;

        repeat (32) begin
          // Data is sampled by the master on the negedge sys_spi_clk
          // we have to start a new transcation
          @(negedge sys_spi_clk)
          $display("@%0d: External is writing to SPI bus...", $time);
          sys_spi_data_reg = #1 ~sys_spi_data_reg;
        end

        $display("@%0d: External will stop writing to SPI bus...", $time);
        sys_spi_data_en = 1'b0;
      end

      begin
        // Control register set. Direction reg is 0. Read from external chip
        //cmp_wishbone_bfm.write32(32'h00000204 << 2, 32'h00002420);
        cmp_wishbone_bfm.write32(32'h00000304 << 2, 32'h00002420);
        @(posedge clk_sys);
        // Control register set = set the go bit
        //cmp_wishbone_bfm.write32(32'h00000204 << 2, 32'h00002520);
        cmp_wishbone_bfm.write32(32'h00000304 << 2, 32'h00002520);
        @(posedge clk_sys);

        wait_spi_busy();
      end
    join

    // SPI data should be available by now
    //cmp_wishbone_bfm.read32(32'h00000200 << 2, data_out);
    cmp_wishbone_bfm.read32(32'h00000300 << 2, data_out);
    $display("@%0d: SPI data: %08x", $time, data_out);
  end //initial

  // FMC516 device under test. Classic wishbone interface as the Wishbone Master
  // Interface does not talk PIPELINED cycles yet.
  wb_fmc516  #( .g_interface_mode(PIPELINED), .g_address_granularity(WORD),
                .g_packet_size(32), .g_sim(1), .g_use_clk_chains(4'b0010),
                .g_use_data_chains(4'b1111))
  cmp_wb_fmc516
  (
    .sys_clk_i                                (clk_sys),
    .sys_rst_n_i                              (rstn),
    .sys_clk_200Mhz_i                         (clk_200mhz),

    //-----------------------------
    //-- Wishbone signals
    //-----------------------------

    .wb_adr_i                                 (cmp_wishbone_bfm.wb_addr),
    .wb_dat_i                                 (cmp_wishbone_bfm.wb_data_o),
    .wb_dat_o                                 (cmp_wishbone_bfm.wb_data_i),
    .wb_sel_i                                 (cmp_wishbone_bfm.wb_bwsel),
    .wb_we_i                                  (cmp_wishbone_bfm.wb_we),
    .wb_cyc_i                                 (cmp_wishbone_bfm.wb_cyc),
    .wb_stb_i                                 (cmp_wishbone_bfm.wb_stb),
    .wb_ack_o                                 (cmp_wishbone_bfm.wb_ack_i),
    .wb_err_o                                 (),
    .wb_rty_o                                 (),
    .wb_stall_o                               (),

    //-----------------------------
    //-- External ports
    //-----------------------------
    // System I2C Bus. Slaves: Atmel AT24C512B Serial EEPROM,
    // AD7417 temperature diodes and AD7417 supply rails
    .sys_i2c_scl_b                            (),
    .sys_i2c_sda_b                            (),

    // ADC clocks. One clock per ADC channel.
    // Only ch1 clock is used as all data chains
    // are sampled at the same frequency
    .adc_clk0_p_i                             (clk_adc),
    .adc_clk0_n_i                             (~clk_adc),
    .adc_clk1_p_i                             (clk_adc),
    .adc_clk1_n_i                             (~clk_adc),
    .adc_clk2_p_i                             (clk_adc),
    .adc_clk2_n_i                             (~clk_adc),
    .adc_clk3_p_i                             (clk_adc),
    .adc_clk3_n_i                             (~clk_adc),

    // DDR ADC data channels.
    .adc_data_ch0_p_i                         (adc_ch0_data_p),
    .adc_data_ch0_n_i                         (toggle_adc_data(adc_ch0_data_n)),
    .adc_data_ch1_p_i                         (adc_ch1_data_p),
    .adc_data_ch1_n_i                         (toggle_adc_data(adc_ch1_data_n)),
    .adc_data_ch2_p_i                         (adc_ch2_data_p),
    .adc_data_ch2_n_i                         (toggle_adc_data(adc_ch2_data_n)),
    .adc_data_ch3_p_i                         (adc_ch3_data_p),
    .adc_data_ch3_n_i                         (toggle_adc_data(adc_ch3_data_n)),

    // ADC clock (half of the sampling frequency) divider reset
    .adc_clk_div_rst_p_o                      (),
    .adc_clk_div_rst_n_o                      (),

    // FMC Front leds. Typical uses: Over Range or Full Scale
    // condition.
    .fmc_leds_o                               (),

    // ADC SPI control interface. Three-wire mode. Tri-stated data pin
    .sys_spi_clk_o                            (sys_spi_clk),
    .sys_spi_data_b                           (sys_spi_data),
    .sys_spi_cs_adc0_n_o                      (sys_spi_cs_0),  // SPI ADC CS channel 0
    .sys_spi_cs_adc1_n_o                      (sys_spi_cs_1),  // SPI ADC CS channel 1
    .sys_spi_cs_adc2_n_o                      (sys_spi_cs_2),  // SPI ADC CS channel 2
    .sys_spi_cs_adc3_n_o                      (sys_spi_cs_3),  // SPI ADC CS channel 3

    // External Trigger To/From FMC
    .m2c_trig_p_i                             (zero_bit),
    .m2c_trig_n_i                             (zero_bit),
    .c2m_trig_p_o                             (),
    .c2m_trig_n_o                             (),

    // LMK (National Semiconductor) is the clock and distribution IC.
    // SPI interface?
    .lmk_lock_i                               (one_bit),
    .lmk_sync_o                               (),
    .lmk_uwire_latch_en_o                     (),
    .lmk_uwire_data_o                         (),
    .lmk_uwire_clock_o                        (),

    // Programable VCXO via I2C?
    .vcxo_i2c_sda_b                           (),
    .vcxo_i2c_scl_o                           (),
    .vcxo_pd_l_o                              (),

    // One-wire To/From DS2431 (VMETRO Data)
    .fmc_id_dq_b                              (),
    // One-wire To/From DS2432 SHA-1 (SP-Devices key)
    .fmc_key_dq_b                             (),

    // General board pins
    .fmc_pwr_good_i                           (zero_bit),
    // Internal/External clock distribution selection
    .fmc_clk_sel_o                            (),
    // Reset ADCs
    .fmc_reset_adcs_n_o                       (),
    //FMC Present status
    .fmc_prsnt_m2c_l_i                        (zero_bit),

    //-----------------------------
    //-- ADC output signals. Continuous flow.
    //-----------------------------
    .adc_clk_o                                (),
    .adc_data_ch0_o                           (),
    .adc_data_ch1_o                           (),
    .adc_data_ch2_o                           (),
    .adc_data_ch3_o                           (),
    .adc_data_valid_o                         (),

    //-----------------------------
    //-- General ADC output signals
    //-----------------------------
    // Trigger to other FPGA logic
    .trig_hw_o                                (),
    .trig_hw_i                                (zero_bit),
    // General board status
    .fmc_mmcm_lock_o                          (fmc_mmcm_lock),
    .fmc_lmk_lock_o                           (),

    //-----------------------------
    //-- Wishbone Streaming Interface Source
    //-----------------------------

    .wbs_adr_o                                (),
    .wbs_dat_o                                (),
    .wbs_cyc_o                                (),
    .wbs_stb_o                                (),
    .wbs_we_o                                 (),
    .wbs_sel_o                                (),
    .wbs_ack_i                                (zero_bit),
    .wbs_stall_i                              (zero_bit),
    .wbs_err_i                                (zero_bit),
    .wbs_rty_i                                (zero_bit)
  );

  // Generate data and valid signals on positive edge of ADC clock
  always @(posedge clk_adc)
  begin
    adc_ch0_data_p <= adc_data_gen(adc_data_max);
    adc_ch1_data_p <= adc_data_gen(adc_data_max);
    adc_ch2_data_p <= adc_data_gen(adc_data_max);
    adc_ch3_data_p <= adc_data_gen(adc_data_max);
    adc_ch0_data_n <= toggle_adc_data(adc_ch0_data_p);
    adc_ch1_data_n <= toggle_adc_data(adc_ch1_data_p);
    adc_ch2_data_n <= toggle_adc_data(adc_ch2_data_p);
    adc_ch3_data_n <= toggle_adc_data(adc_ch3_data_p);
    adc_data_valid <= adc_data_valid_gen(adc_gen_threshold);
  end

  // Functions
  function [`ADC_DATA_WIDTH/2-1:0] adc_data_gen;
    input integer max_size;
  begin
    // $random is surronded by the concat operator in order
    // to provide us with only unsigned (bit vector) data
    adc_data_gen = {$random} % max_size;
  end
  endfunction

  function [`ADC_DATA_WIDTH/2 - 1 : 0] toggle_adc_data;
    input [`ADC_DATA_WIDTH/2 -1  : 0] data;
    integer i;
  begin
    for (i = 0; i < `ADC_DATA_WIDTH/2; i = i+1) begin
      toggle_adc_data[i] = ~data[i];
    end
  end
  endfunction

  function adc_data_valid_gen;
    input real prob;
    real temp;
  begin
    // $random is surronded by the concat operator in order
    // to provide us with only unsigned (bit vector) data.
    // Generates value in a 0..1 range
    temp = ({$random} % 100 + 1)/100.00;//threshold;

    if (temp > prob)
      adc_data_valid_gen = 1'b1;
    else
      adc_data_valid_gen = 1'b0;
  end
  endfunction

  // Tasks
  task wait_spi_busy();
  begin
    // Wait for transfer
    //cmp_wishbone_bfm.read32(32'h00000204 << 2, data_out);
    cmp_wishbone_bfm.read32(32'h00000304 << 2, data_out);
    @(posedge clk_sys);
    $display("@%0d: Waiting for SPI...", $time);

    while (data_out & (1 << 8)) begin
      //cmp_wishbone_bfm.read32(32'h00000204 << 2, data_out);
      cmp_wishbone_bfm.read32(32'h00000304 << 2, data_out);
      repeat (16)
        @(posedge clk_sys);
      $display("@%0d: Waiting for SPI...", $time);
    end

    $display("@%0d: SPI completed its transcation", $time);
  end
  endtask

endmodule

