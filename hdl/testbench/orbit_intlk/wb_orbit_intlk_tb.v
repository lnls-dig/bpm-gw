//----------------------------------------------------------------------------
// Title      : Testbench for BPM Interlock
//----------------------------------------------------------------------------
// Author     : Lucas Maziero Russo
// Company    : CNPEM LNLS-DIG
// Created    : 2020-06-15
// Platform   : FPGA-generic
//-----------------------------------------------------------------------------
// Description: Simulation of the BPM Interlock
//-----------------------------------------------------------------------------
// Copyright (c) 2020 CNPEM
// Licensed under GNU Lesser General Public License (LGPL) v3.0
//-----------------------------------------------------------------------------
// Revisions  :
// Date        Version  Author          Description
// 2020-06-15  1.0      lucas.russo        Created
//-----------------------------------------------------------------------------

// Simulation timescale
`include "timescale.v"
// Common definitions
`include "defines.v"
// Wishbone Master
`include "wishbone_test_master.v"
// bpm swap Register definitions
`include "regs/wb_orbit_intlk_regs.vh"

module wb_orbit_intlk_tb;

  // Local definitions
  localparam c_ADC_WIDTH        = 16;
  localparam c_DECIM_WIDTH       = 32;
  localparam c_INTLK_LMT_WIDTH  = 32;

  //**************************************************************************
  // Clock generation and reset
  //**************************************************************************
  wire sys_clk;
  wire sys_rstn;
  wire sys_rst;

  clk_rst cmp_clk_rst(
   .clk_sys_o(sys_clk),
   .sys_rstn_o(sys_rstn)
  );

  assign sys_rst = ~sys_rstn;

  //**************************************************************************
  // Wishbone Master
  //**************************************************************************

  WB_TEST_MASTER WB0(
    .wb_clk                                 (sys_clk)
  );

  //**************************************************************************
  // DUT
  //**************************************************************************
  reg intlk_en;
  reg intlk_clr;

  reg intlk_min_sum_en;
  reg [c_INTLK_LMT_WIDTH-1:0] intlk_min_sum;

  reg intlk_trans_en;
  reg intlk_trans_clr;
  reg [c_INTLK_LMT_WIDTH-1:0] intlk_trans_max_x;
  reg [c_INTLK_LMT_WIDTH-1:0] intlk_trans_max_y;

  reg intlk_ang_en;
  reg intlk_ang_clr;
  reg [c_INTLK_LMT_WIDTH-1:0] intlk_ang_max_x;
  reg [c_INTLK_LMT_WIDTH-1:0] intlk_ang_max_y;

  reg [c_ADC_WIDTH-1:0] adc_ds_ch0_swap;
  reg [c_ADC_WIDTH-1:0] adc_ds_ch1_swap;
  reg [c_ADC_WIDTH-1:0] adc_ds_ch2_swap;
  reg [c_ADC_WIDTH-1:0] adc_ds_ch3_swap;
  reg [0:0]             adc_ds_tag;
  reg adc_ds_swap_valid;

  reg [c_DECIM_WIDTH-1:0] decim_ds_pos_x;
  reg [c_DECIM_WIDTH-1:0] decim_ds_pos_y;
  reg [c_DECIM_WIDTH-1:0] decim_ds_pos_q;
  reg [c_DECIM_WIDTH-1:0] decim_ds_pos_sum;
  reg decim_ds_pos_valid;

  reg [c_ADC_WIDTH-1:0] adc_us_ch0_swap;
  reg [c_ADC_WIDTH-1:0] adc_us_ch1_swap;
  reg [c_ADC_WIDTH-1:0] adc_us_ch2_swap;
  reg [c_ADC_WIDTH-1:0] adc_us_ch3_swap;
  reg [0:0] adc_us_tag;
  reg adc_us_swap_valid;

  reg [c_DECIM_WIDTH-1:0] decim_us_pos_x;
  reg [c_DECIM_WIDTH-1:0] decim_us_pos_y;
  reg [c_DECIM_WIDTH-1:0] decim_us_pos_q;
  reg [c_DECIM_WIDTH-1:0] decim_us_pos_sum;
  reg decim_us_pos_valid;

  wire intlk_trans_bigger_x;
  wire intlk_trans_bigger_y;
  wire intlk_trans_bigger_ltc_x;
  wire intlk_trans_bigger_ltc_y;
  wire intlk_trans_bigger;
  wire intlk_trans_ltc;
  wire intlk_trans;
  wire intlk_ang_bigger_x;
  wire intlk_ang_bigger_y;
  wire intlk_ang_bigger_ltc_x;
  wire intlk_ang_bigger_ltc_y;
  wire intlk_ang_bigger;
  wire intlk_ang_ltc;
  wire intlk_ang;
  wire intlk_ltc;
  wire intlk;

  wb_orbit_intlk #(
    .g_ADC_WIDTH         (16),
    .g_DECIM_WIDTH       (32)
  )
  DUT (
    .rst_n_i                     (sys_rstn),
    .clk_i                       (sys_clk),
    .ref_rst_n_i                 (sys_rstn),
    .ref_clk_i                   (sys_clk),

    .wb_adr_i                    (WB0.wb_addr),
    .wb_dat_i                    (WB0.wb_data_o),
    .wb_dat_o                    (WB0.wb_data_i),
    .wb_cyc_i                    (WB0.wb_cyc),
    .wb_sel_i                    (WB0.wb_bwsel),
    .wb_stb_i                    (WB0.wb_stb),
    .wb_we_i                     (WB0.wb_we),
    .wb_ack_o                    (WB0.wb_ack_i),
    .wb_stall_o                  (),

    .fs_clk_ds_i                 (sys_clk),

    .adc_ds_ch0_swap_i           (adc_ds_ch0_swap),
    .adc_ds_ch1_swap_i           (adc_ds_ch1_swap),
    .adc_ds_ch2_swap_i           (adc_ds_ch2_swap),
    .adc_ds_ch3_swap_i           (adc_ds_ch3_swap),
    .adc_ds_tag_i                (adc_ds_tag),
    .adc_ds_swap_valid_i         (adc_ds_swap_valid),

    .decim_ds_pos_x_i            (decim_ds_pos_x),
    .decim_ds_pos_y_i            (decim_ds_pos_y),
    .decim_ds_pos_q_i            (decim_ds_pos_q),
    .decim_ds_pos_sum_i          (decim_ds_pos_sum),
    .decim_ds_pos_valid_i        (decim_ds_pos_valid),

    .fs_clk_us_i                 (sys_clk),

    .adc_us_ch0_swap_i           (adc_us_ch0_swap),
    .adc_us_ch1_swap_i           (adc_us_ch1_swap),
    .adc_us_ch2_swap_i           (adc_us_ch2_swap),
    .adc_us_ch3_swap_i           (adc_us_ch3_swap),
    .adc_us_tag_i                (adc_us_tag),
    .adc_us_swap_valid_i         (adc_us_swap_valid),

    .decim_us_pos_x_i            (decim_us_pos_x),
    .decim_us_pos_y_i            (decim_us_pos_y),
    .decim_us_pos_q_i            (decim_us_pos_q),
    .decim_us_pos_sum_i          (decim_us_pos_sum),
    .decim_us_pos_valid_i        (decim_us_pos_valid),

    .intlk_trans_bigger_x_o      (intlk_trans_bigger_x),
    .intlk_trans_bigger_y_o      (intlk_trans_bigger_y),

    .intlk_trans_bigger_ltc_x_o  (intlk_trans_bigger_ltc_x),
    .intlk_trans_bigger_ltc_y_o  (intlk_trans_bigger_ltc_y),

    .intlk_trans_bigger_o        (intlk_trans_bigger),

    .intlk_trans_ltc_o           (intlk_trans_ltc),
    .intlk_trans_o               (intlk_trans),

    .intlk_ang_bigger_x_o        (intlk_ang_bigger_x),
    .intlk_ang_bigger_y_o        (intlk_ang_bigger_y),

    .intlk_ang_bigger_ltc_x_o    (intlk_ang_bigger_ltc_x),
    .intlk_ang_bigger_ltc_y_o    (intlk_ang_bigger_ltc_y),

    .intlk_ang_bigger_o          (intlk_ang_bigger),

    .intlk_ang_ltc_o             (intlk_ang_ltc),
    .intlk_ang_o                 (intlk_ang),

    .intlk_ltc_o                 (intlk_ltc),
    .intlk_o                     (intlk)
  );

  //**************************************************************************
  // Interlock test signals
  //**************************************************************************

  integer test_id;
  reg test_in_progress;

  reg test_intlk_en;

  reg test_intlk_min_sum_en;
  reg [c_INTLK_LMT_WIDTH-1:0] test_intlk_min_sum;

  reg test_intlk_trans_en;
  reg [c_INTLK_LMT_WIDTH-1:0] test_intlk_trans_max_x;
  reg [c_INTLK_LMT_WIDTH-1:0] test_intlk_trans_max_y;

  reg test_intlk_ang_en;
  reg [c_INTLK_LMT_WIDTH-1:0] test_intlk_ang_max_x;
  reg [c_INTLK_LMT_WIDTH-1:0] test_intlk_ang_max_y;

  reg [c_DECIM_WIDTH-1:0] test_decim_ds_pos_x;
  reg [c_DECIM_WIDTH-1:0] test_decim_ds_pos_y;
  reg [c_DECIM_WIDTH-1:0] test_decim_ds_pos_q;
  reg [c_DECIM_WIDTH-1:0] test_decim_ds_pos_sum;

  reg [c_DECIM_WIDTH-1:0] test_decim_us_pos_x;
  reg [c_DECIM_WIDTH-1:0] test_decim_us_pos_y;
  reg [c_DECIM_WIDTH-1:0] test_decim_us_pos_q;
  reg [c_DECIM_WIDTH-1:0] test_decim_us_pos_sum;

  reg test_intlk_status;

  //**************************************************************************
  // Stimulus to DUT
  //**************************************************************************
  initial begin
    intlk_en = 1'b1;
    intlk_clr = 1'b0;

    intlk_min_sum_en = 1'b0;
    intlk_min_sum = 'h0;

    intlk_trans_en  = 1'b1;
    intlk_trans_clr = 1'b0;

    // 1mm = 1000000 nm = F4240h
    intlk_trans_max_x = 'h10_0000;
    intlk_trans_max_y = 'h10_0000;

    intlk_ang_en  = 1'b1;
    intlk_ang_clr = 1'b0;

    // 200 urad * 7m (distance between BPMs) = 1_400_000 nm = 155CC0h
    intlk_ang_max_x = 'h1_55CC0;
    intlk_ang_max_y = 'h1_55CC0;

    adc_ds_ch0_swap = 'h0;
    adc_ds_ch1_swap = 'h0;
    adc_ds_ch2_swap = 'h0;
    adc_ds_ch3_swap = 'h0;
    adc_ds_tag = 'h0;
    adc_ds_swap_valid = 1'b0;

    decim_ds_pos_x = 'h0;
    decim_ds_pos_y = 'h0;
    decim_ds_pos_q = 'h0;
    decim_ds_pos_sum = 'h0;
    decim_ds_pos_valid = 1'b0;

    adc_us_ch0_swap = 'h0;
    adc_us_ch1_swap = 'h0;
    adc_us_ch2_swap = 'h0;
    adc_us_ch3_swap = 'h0;
    adc_us_tag = 'h0;
    adc_us_swap_valid = 1'b0;

    decim_us_pos_x = 'h0;
    decim_us_pos_y = 'h0;
    decim_us_pos_q = 'h0;
    decim_us_pos_sum = 'h0;
    decim_us_pos_valid = 1'b0;

    $display("-----------------------------------");
    $display("@%0d: Simulation of BPM Interlock starting!", $time);
    $display("-----------------------------------");

    $display("-----------------------------------");
    $display("@%0d: Initialization  Begin", $time);
    $display("-----------------------------------");

    $display("-----------------------------------");
    $display("@%0d: Waiting for all resets...", $time);
    $display("-----------------------------------");

    wait (WB0.ready);
    wait (sys_rstn);

    $display("@%0d: Reset done!", $time);

    @(posedge sys_clk);

    $display("-------------------------------------");
    $display("@%0d: Waiting for interlock clear...", $time);
    $display("-------------------------------------");

    intlk_clr = 1'b0;
    intlk_trans_clr = 1'b0;
    intlk_ang_clr = 1'b0;

    @(posedge sys_clk);

    $display("@%0d: Interlock clear done!", $time);

    $display("-------------------------------------");
    $display("@%0d:  Initialization  Done!", $time);
    $display("-------------------------------------");

    @(posedge sys_clk);

    ////////////////////////
    // TEST #1
    // Translation interlock:
    // smaller than threshold X
    ////////////////////////
    test_id = 1;
    test_intlk_en = 1'b1;

    test_intlk_min_sum_en = 1'b0;
    test_intlk_min_sum = 'h0;

    test_intlk_trans_en  = 1'b1;

    test_intlk_trans_max_x = 'h10_0000;
    test_intlk_trans_max_y = 'h10_0000;

    test_intlk_ang_en  = 1'b0;

    test_intlk_ang_max_x = 'h1_55CC0;
    test_intlk_ang_max_y = 'h1_55CC0;

    test_decim_ds_pos_x = 'h100;
    test_decim_ds_pos_y = 'h0001_0000;
    test_decim_ds_pos_q = 'h0;
    test_decim_ds_pos_sum = 'h0;

    test_decim_us_pos_x = 'h100;
    test_decim_us_pos_y = 'h0001_0000;
    test_decim_us_pos_q = 'h0;
    test_decim_us_pos_sum = 'h0;

    test_intlk_status = 1'b0;

    wb_intlk_transaction(
        test_id,
        test_intlk_en,
        test_intlk_min_sum_en,
        test_intlk_min_sum,
        test_intlk_trans_en ,
        test_intlk_trans_max_x,
        test_intlk_trans_max_y,
        test_intlk_ang_en ,
        test_intlk_ang_max_x,
        test_intlk_ang_max_y,
        test_decim_ds_pos_x,
        test_decim_ds_pos_y,
        test_decim_ds_pos_q,
        test_decim_ds_pos_sum,
        test_decim_us_pos_x,
        test_decim_us_pos_y,
        test_decim_us_pos_q,
        test_decim_us_pos_sum,
        test_intlk_status
    );

    ////////////////////////
    // TEST #2
    // Translation interlock:
    // bigger than threshold X
    ////////////////////////
    test_id = 2;
    test_intlk_en = 1'b1;

    test_intlk_min_sum_en = 1'b0;
    test_intlk_min_sum = 'h0;

    test_intlk_trans_en  = 1'b1;

    test_intlk_trans_max_x = 'h10_0000;
    test_intlk_trans_max_y = 'h10_0000;

    test_intlk_ang_en  = 1'b0;

    test_intlk_ang_max_x = 'h1_55CC0;
    test_intlk_ang_max_y = 'h1_55CC0;

    test_decim_ds_pos_x = 'h0100_0000;
    test_decim_ds_pos_y = 'h0001_0000;
    test_decim_ds_pos_q = 'h0;
    test_decim_ds_pos_sum = 'h0;

    test_decim_us_pos_x = 'h0100_0000;
    test_decim_us_pos_y = 'h0001_0000;
    test_decim_us_pos_q = 'h0;
    test_decim_us_pos_sum = 'h0;

    test_intlk_status = 1'b1;

    wb_intlk_transaction(
        test_id,
        test_intlk_en,
        test_intlk_min_sum_en,
        test_intlk_min_sum,
        test_intlk_trans_en ,
        test_intlk_trans_max_x,
        test_intlk_trans_max_y,
        test_intlk_ang_en ,
        test_intlk_ang_max_x,
        test_intlk_ang_max_y,
        test_decim_ds_pos_x,
        test_decim_ds_pos_y,
        test_decim_ds_pos_q,
        test_decim_ds_pos_sum,
        test_decim_us_pos_x,
        test_decim_us_pos_y,
        test_decim_us_pos_q,
        test_decim_us_pos_sum,
        test_intlk_status
    );

    ////////////////////////
    // TEST #3
    // Translation interlock:
    // equal than threshold X
    ////////////////////////
    test_id = 3;
    test_intlk_en = 1'b1;

    test_intlk_min_sum_en = 1'b0;
    test_intlk_min_sum = 'h0;

    test_intlk_trans_en  = 1'b1;

    test_intlk_trans_max_x = 'h10_0000;
    test_intlk_trans_max_y = 'h10_0000;

    test_intlk_ang_en  = 1'b0;

    test_intlk_ang_max_x = 'h1_55CC0;
    test_intlk_ang_max_y = 'h1_55CC0;

    test_decim_ds_pos_x = 'h0020_0000;
    test_decim_ds_pos_y = 'h0001_0000;
    test_decim_ds_pos_q = 'h0;
    test_decim_ds_pos_sum = 'h0;

    test_decim_us_pos_x = 'h0008_0000;
    test_decim_us_pos_y = 'h0001_0000;
    test_decim_us_pos_q = 'h0;
    test_decim_us_pos_sum = 'h0;

    test_intlk_status = 1'b1;

    wb_intlk_transaction(
        test_id,
        test_intlk_en,
        test_intlk_min_sum_en,
        test_intlk_min_sum,
        test_intlk_trans_en ,
        test_intlk_trans_max_x,
        test_intlk_trans_max_y,
        test_intlk_ang_en ,
        test_intlk_ang_max_x,
        test_intlk_ang_max_y,
        test_decim_ds_pos_x,
        test_decim_ds_pos_y,
        test_decim_ds_pos_q,
        test_decim_ds_pos_sum,
        test_decim_us_pos_x,
        test_decim_us_pos_y,
        test_decim_us_pos_q,
        test_decim_us_pos_sum,
        test_intlk_status
    );

    ////////////////////////
    // TEST #4
    // No translation interlock:
    // X/Y within limits
    ////////////////////////
    test_id = 4;
    test_intlk_en = 1'b1;

    test_intlk_min_sum_en = 1'b0;
    test_intlk_min_sum = 'h0;

    test_intlk_trans_en  = 1'b1;

    test_intlk_trans_max_x = 'h10_0000;
    test_intlk_trans_max_y = 'h10_0000;

    test_intlk_ang_en  = 1'b0;

    test_intlk_ang_max_x = 'h1_55CC0;
    test_intlk_ang_max_y = 'h1_55CC0;

    test_decim_ds_pos_x = 'h0002_0000;
    test_decim_ds_pos_y = 'h0003_0000;
    test_decim_ds_pos_q = 'h0;
    test_decim_ds_pos_sum = 'h0;

    test_decim_us_pos_x = 'h0004_0000;
    test_decim_us_pos_y = 'h0008_0000;
    test_decim_us_pos_q = 'h0;
    test_decim_us_pos_sum = 'h0;

    test_intlk_status = 1'b0;

    wb_intlk_transaction(
        test_id,
        test_intlk_en,
        test_intlk_min_sum_en,
        test_intlk_min_sum,
        test_intlk_trans_en ,
        test_intlk_trans_max_x,
        test_intlk_trans_max_y,
        test_intlk_ang_en ,
        test_intlk_ang_max_x,
        test_intlk_ang_max_y,
        test_decim_ds_pos_x,
        test_decim_ds_pos_y,
        test_decim_ds_pos_q,
        test_decim_ds_pos_sum,
        test_decim_us_pos_x,
        test_decim_us_pos_y,
        test_decim_us_pos_q,
        test_decim_us_pos_sum,
        test_intlk_status
    );

    ////////////////////////
    // TEST #5
    // Minimum sum interlock:
    // X/Y outside limits., but sum too small
    ////////////////////////
    test_id = 5;
    test_intlk_en = 1'b1;

    test_intlk_min_sum_en = 1'b1;
    test_intlk_min_sum = 'h0_1000;

    test_intlk_trans_en  = 1'b1;

    test_intlk_trans_max_x = 'h10_0000;
    test_intlk_trans_max_y = 'h10_0000;

    test_intlk_ang_en  = 1'b0;

    test_intlk_ang_max_x = 'h1_55CC0;
    test_intlk_ang_max_y = 'h1_55CC0;

    test_decim_ds_pos_x = 'h0100_0000;
    test_decim_ds_pos_y = 'h0100_0000;
    test_decim_ds_pos_q = 'h0;
    test_decim_ds_pos_sum = 'h0000_0100;

    test_decim_us_pos_x = 'h0100_0000;
    test_decim_us_pos_y = 'h0100_0000;
    test_decim_us_pos_q = 'h0;
    test_decim_us_pos_sum = 'h0000_0500;

    test_intlk_status = 1'b0;

    wb_intlk_transaction(
        test_id,
        test_intlk_en,
        test_intlk_min_sum_en,
        test_intlk_min_sum,
        test_intlk_trans_en ,
        test_intlk_trans_max_x,
        test_intlk_trans_max_y,
        test_intlk_ang_en ,
        test_intlk_ang_max_x,
        test_intlk_ang_max_y,
        test_decim_ds_pos_x,
        test_decim_ds_pos_y,
        test_decim_ds_pos_q,
        test_decim_ds_pos_sum,
        test_decim_us_pos_x,
        test_decim_us_pos_y,
        test_decim_us_pos_q,
        test_decim_us_pos_sum,
        test_intlk_status
    );

    $display("Simulation Done!");
    $display("All Tests Passed!");
    $display("---------------------------------------------");
    $finish;
  end

  ///////////////////////////////////////////////////////////////////////////
  // Functions
  ///////////////////////////////////////////////////////////////////////////


  /////////////////////////////////////////////////////////////////////////////
  // Tasks
  /////////////////////////////////////////////////////////////////////////////

  task wb_busy_wait;
    input [`WB_ADDRESS_BUS_WIDTH-1:0] addr;
    input [`WB_DATA_BUS_WIDTH-1:0] mask;
    input [`WB_DATA_BUS_WIDTH-1:0] offset;
    input verbose;

    reg [`WB_DATA_BUS_WIDTH-1:0] tmp_reg0;
  begin
    WB0.monitor_bus(1'b0);
    WB0.verbose(1'b0);

    WB0.read32(addr, tmp_reg0);

    while (((tmp_reg0 & mask) >> offset) != 'h1) begin
      if (verbose)
        $write(".");

      @(posedge sys_clk);
      WB0.read32(addr, tmp_reg0);
    end

    WB0.monitor_bus(1'b1);
    WB0.verbose(1'b1);
  end
  endtask

  task wb_intlk_transaction;
    input integer test_id;
    input test_intlk_en;

    input test_intlk_min_sum_en;
    input [c_INTLK_LMT_WIDTH-1:0] test_intlk_min_sum;

    input test_intlk_trans_en;
    input [c_INTLK_LMT_WIDTH-1:0] test_intlk_trans_max_x;
    input [c_INTLK_LMT_WIDTH-1:0] test_intlk_trans_max_y;

    input test_intlk_ang_en;
    input [c_INTLK_LMT_WIDTH-1:0] test_intlk_ang_max_x;
    input [c_INTLK_LMT_WIDTH-1:0] test_intlk_ang_max_y;

    input [c_DECIM_WIDTH-1:0] test_decim_ds_pos_x;
    input [c_DECIM_WIDTH-1:0] test_decim_ds_pos_y;
    input [c_DECIM_WIDTH-1:0] test_decim_ds_pos_q;
    input [c_DECIM_WIDTH-1:0] test_decim_ds_pos_sum;

    input [c_DECIM_WIDTH-1:0] test_decim_us_pos_x;
    input [c_DECIM_WIDTH-1:0] test_decim_us_pos_y;
    input [c_DECIM_WIDTH-1:0] test_decim_us_pos_q;
    input [c_DECIM_WIDTH-1:0] test_decim_us_pos_sum;

    input test_intlk_status;

    reg [`WB_DATA_BUS_WIDTH:0] wb_reg;
    reg [`WB_DATA_BUS_WIDTH:0] intlk_wb;
    integer err;
    integer err_intlk;
    integer err_wb;
  begin
    $display("#############################");
    $display("######## TEST #%03d ######", test_id);
    $display("#############################");
    $display("## Interlock enable = %d", test_intlk_en);
    $display("## Interlock minimum sum enable = %d", test_intlk_min_sum_en);
    $display("## Interlock minimum sum threshold = %03d", test_intlk_min_sum);
    $display("## Interlock translation enable = %d", test_intlk_trans_en);
    $display("## Interlock translation MAX X = %03d", test_intlk_trans_max_x);
    $display("## Interlock translation MAX Y = %03d", test_intlk_trans_max_y);
    $display("## Interlock angular enable = %d", test_intlk_ang_en);
    $display("## Interlock angular MAX X = %03d", test_intlk_ang_max_x);
    $display("## Interlock angular MAX Y = %03d", test_intlk_ang_max_y);

    $display("Setting interlock parameters scenario");

    $display("Setting minimum sum threshold");
    @(posedge sys_clk);
    WB0.write32(`ADDR_ORBIT_INTLK_MIN_SUM >> `WB_WORD_ACC, test_intlk_min_sum);

    $display("Setting minimum sum enable");
    @(posedge sys_clk);
    WB0.read32(`ADDR_ORBIT_INTLK_CTRL, wb_reg);
    WB0.write32(`ADDR_ORBIT_INTLK_CTRL >> `WB_WORD_ACC, wb_reg | (test_intlk_min_sum_en << `ORBIT_INTLK_CTRL_MIN_SUM_EN_OFFSET));

    $display("Setting translation threshold X");
    @(posedge sys_clk);
    WB0.write32(`ADDR_ORBIT_INTLK_TRANS_MAX_X >> `WB_WORD_ACC, test_intlk_trans_max_x);

    $display("Setting translation threshold Y");
    @(posedge sys_clk);
    WB0.write32(`ADDR_ORBIT_INTLK_TRANS_MAX_Y >> `WB_WORD_ACC, test_intlk_trans_max_y);

    $display("Setting translation threshold enable");
    @(posedge sys_clk);
    WB0.read32(`ADDR_ORBIT_INTLK_CTRL, wb_reg);
    WB0.write32(`ADDR_ORBIT_INTLK_CTRL >> `WB_WORD_ACC, wb_reg | (test_intlk_trans_en << `ORBIT_INTLK_CTRL_TRANS_EN_OFFSET));

    $display("Setting angular threshold X");
    @(posedge sys_clk);
    WB0.write32(`ADDR_ORBIT_INTLK_ANG_MAX_X >> `WB_WORD_ACC, test_intlk_ang_max_x);

    $display("Setting angular threshold Y");
    @(posedge sys_clk);
    WB0.write32(`ADDR_ORBIT_INTLK_ANG_MAX_Y >> `WB_WORD_ACC, test_intlk_ang_max_y);

    $display("Setting angular threshold enable");
    @(posedge sys_clk);
    WB0.read32(`ADDR_ORBIT_INTLK_CTRL, wb_reg);
    WB0.write32(`ADDR_ORBIT_INTLK_CTRL >> `WB_WORD_ACC, wb_reg | (test_intlk_ang_en << `ORBIT_INTLK_CTRL_ANG_EN_OFFSET));

    $display("Setting interlock enable");
    @(posedge sys_clk);
    WB0.read32(`ADDR_ORBIT_INTLK_CTRL, wb_reg);
    WB0.write32(`ADDR_ORBIT_INTLK_CTRL >> `WB_WORD_ACC, wb_reg | (test_intlk_en << `ORBIT_INTLK_CTRL_EN_OFFSET));

    test_in_progress = 1'b1;

    $display("Setting DECIM downstream/upstream positions");
    @(posedge sys_clk);

    decim_ds_pos_x      = test_decim_ds_pos_x;
    decim_ds_pos_y      = test_decim_ds_pos_y;
    decim_ds_pos_q      = test_decim_ds_pos_q;
    decim_ds_pos_sum    = test_decim_ds_pos_sum;
    decim_ds_pos_valid  = 1'b1;

    decim_us_pos_x      = test_decim_us_pos_x;
    decim_us_pos_y      = test_decim_us_pos_y;
    decim_us_pos_q      = test_decim_us_pos_q;
    decim_us_pos_sum    = test_decim_us_pos_sum;
    decim_us_pos_valid  = 1'b1;

    $display("Setting DECIM downstream/upstream positions back to zero");
    @(posedge sys_clk);

    decim_ds_pos_x      = 'h0;
    decim_ds_pos_y      = 'h0;
    decim_ds_pos_q      = 'h0;
    decim_ds_pos_sum    = 'h0;
    decim_ds_pos_valid  = 1'b0;

    decim_us_pos_x      = 'h0;
    decim_us_pos_y      = 'h0;
    decim_us_pos_q      = 'h0;
    decim_us_pos_sum    = 'h0;
    decim_us_pos_valid  = 1'b0;

    $display("Waiting 20 clock cycles so we have time to detect the trip");
    @(posedge sys_clk);

    repeat (20) begin
      @(posedge sys_clk);
      $write(".");
    end

    err = 0;
    err_intlk = 0;
    err_wb = 0;

    $display("\n");

    $display("Reading interlock register");
    WB0.read32(`ADDR_ORBIT_INTLK_STS >> `WB_WORD_ACC, wb_reg);
    @(posedge sys_clk);

    if (test_intlk_status == intlk) begin
      $display("Interlock module correctly identified a condition: expected %d/ got %d", test_intlk_status, intlk);
    end else begin
      $display("Interlock module DID NOT correctly identified a condition: expected %d/ got %d", test_intlk_status, intlk);
      err = 1;
      err_intlk = 1;
    end

    intlk_wb = (wb_reg & `ORBIT_INTLK_STS_INTLK_BIGGER) >> `ORBIT_INTLK_STS_INTLK_BIGGER_OFFSET;
    if (test_intlk_status == intlk_wb) begin
      $display("Wishbone register correctly identified a condition: expected %d/ got %d", test_intlk_status, intlk_wb);
    end else begin
      $display("Interlock module DID NOT correctly identified a condition: expected %d/ got %d", test_intlk_status, intlk);
      err = 1;
      err_wb = 1;
    end

    if (err) begin
      $display("TEST #%03d: FAIL!", test_id);
      $finish;
    end else begin
      $display("TEST #%03d: PASS!", test_id);
    end

    @(posedge sys_clk);
    test_in_progress = 1'b0;

    $display("Clearing interlock flags");

    $display("Clearing translation interlock flag");
    @(posedge sys_clk);
    WB0.write32(`ADDR_ORBIT_INTLK_CTRL >> `WB_WORD_ACC, `ORBIT_INTLK_CTRL_TRANS_CLR);

    $display("Clearing angular interlock flag");
    @(posedge sys_clk);
    WB0.write32(`ADDR_ORBIT_INTLK_CTRL >> `WB_WORD_ACC, `ORBIT_INTLK_CTRL_ANG_CLR);

    $display("Clearing interlock flag");
    @(posedge sys_clk);
    WB0.write32(`ADDR_ORBIT_INTLK_CTRL >> `WB_WORD_ACC, `ORBIT_INTLK_CTRL_CLR);

    // give some time for all the modules that need a reset between tests
    repeat (2) begin
      @(posedge sys_clk);
    end

    $display("\n");

  end
  endtask

endmodule
