//----------------------------------------------------------------------------
// Title      : Testbench for BPM FSM Acq
//----------------------------------------------------------------------------
// Author     : Lucas Maziero Russo
// Company    : CNPEM LNLS-DIG
// Created    : 2013-22-10
// Platform   : FPGA-generic
//-----------------------------------------------------------------------------
// Description: Simulation of the BPM FSM ACQ module
//-----------------------------------------------------------------------------
// Copyright (c) 2013 CNPEM
// Licensed under GNU Lesser General Public License (LGPL) v3.0
//-----------------------------------------------------------------------------
// Revisions  :
// Date        Version  Author          Description
// 2013-22-10  1.0      lucas.russo        Created
//-----------------------------------------------------------------------------

// Common definitions
`include "defines.v"
// Simulation timescale
`include "timescale.v"
// Wishbone Master
`include "wishbone_test_master.v"
// bpm swap Register definitions
`include "regs/wb_acq_core_regs.vh"

module wb_acq_core_tb;

  // Local definitions
  localparam c_data_max = (2**`ADC_DATA_WIDTH)-1;
  //localparam c_data_valid_gen_threshold = 0.6;
  //localparam c_data_ext_stall_threshold = 0.6;
  //localparam c_data_valid_gen_threshold = 0.3;
  //localparam c_data_ext_stall_threshold = 0.3;
  localparam c_wait_acquisition_done = 128;

  //// DDR3 Parameters
  parameter REFCLK_FREQ           = 200;
                                    // # = 200 when design frequency < 533 MHz,
                                    //   = 300 when design frequency >= 533 MHz.
  parameter SIM_BYPASS_INIT_CAL   = "FAST";
                                    // # = "OFF" -  Complete memory init &
                                    //              calibration sequence
                                    // # = "SKIP" - Skip memory init &
                                    //              calibration sequence
                                    // # = "FAST" - Skip memory init & use
                                    //              abbreviated calib sequence
  parameter RST_ACT_LOW           = 1;
                                    // =1 for active low reset,
                                    // =0 for active high.
  parameter IODELAY_GRP           = "IODELAY_MIG";
                                    //to phy_top
  parameter nCK_PER_CLK           = 2;
                                    // # of memory CKs per fabric clock.
                                    // # = 2, 1.
  parameter nCS_PER_RANK          = 1;
                                    // # of unique CS outputs per Rank for
                                    // phy.
  parameter DQS_CNT_WIDTH         = 3;
                                    // # = ceil(log2(DQS_WIDTH)).
  parameter RANK_WIDTH            = 1;
                                    // # = ceil(log2(RANKS)).
  parameter BANK_WIDTH            = 3;
                                    // # of memory Bank Address bits.
  parameter CK_WIDTH              = 1;
                                    // # of CK/CK# outputs to memory.
  parameter CKE_WIDTH             = 1;
                                    // # of CKE outputs to memory.
  parameter COL_WIDTH             = 10;
                                    // # of memory Column Address bits.
  parameter CS_WIDTH              = 1;
                                    // # of unique CS outputs to memory.
  parameter DM_WIDTH              = 8;
                                    // # of Data Mask bits.
  parameter DQ_WIDTH              = 64;
                                    // # of Data (DQ) bits.
  parameter DQS_WIDTH             = 8;
                                    // # of DQS/DQS# bits.
  parameter ROW_WIDTH             = 14;
                                    // # of memory Row Address bits.
  parameter BURST_MODE            = "4";
                                    // Burst Length (Mode Register 0).
                                    // # = "8", "4", "OTF".
  parameter INPUT_CLK_TYPE        = "SINGLE_ENDED";
                                    // input clock type DIFFERENTIAL or SINGLE_ENDED
  parameter BM_CNT_WIDTH          = 2;
                                    // # = ceil(log2(nBANK_MACHS)).
  parameter ADDR_CMD_MODE         = "1T" ;
                                    // # = "2T", "1T".
  parameter ORDERING              = "STRICT";
                                    // # = "NORM", "STRICT".
  parameter RTT_NOM               = "60";
                                    // RTT_NOM (ODT) (Mode Register 1).
                                    // # = "DISABLED" - RTT_NOM disabled,
                                    //   = "120" - RZQ/2,
                                    //   = "60" - RZQ/4,
                                    //   = "40" - RZQ/6.
   parameter RTT_WR               = "OFF";
                                       // RTT_WR (ODT) (Mode Register 2).
                                       // # = "OFF" - Dynamic ODT off,
                                       //   = "120" - RZQ/2,
                                       //   = "60" - RZQ/4,
  parameter OUTPUT_DRV            = "HIGH";
                                    // Output Driver Impedance Control (Mode Register 1).
                                    // # = "HIGH" - RZQ/7,
                                    //   = "LOW" - RZQ/6.
  parameter REG_CTRL              = "OFF";
                                    // # = "ON" - RDIMMs,
                                    //   = "OFF" - Components, SODIMMs, UDIMMs.
  parameter CLKFBOUT_MULT_F       = 6;
                                    // write PLL VCO multiplier.
  parameter DIVCLK_DIVIDE         = 2;
  //parameter DIVCLK_DIVIDE         = 1;
                                    // write PLL VCO divisor.
  parameter CLKOUT_DIVIDE         = 3;
                                    // VCO output divisor for fast (memory) clocks.
  parameter tCK                   = 2500;
                                    // memory tCK paramter.
                                    // # = Clock Period.
  parameter DEBUG_PORT            = "OFF";
  //parameter DEBUG_PORT            = "ON";
                                    // # = "ON" Enable debug signals/controls.
                                    //   = "OFF" Disable debug signals/controls.
  parameter tPRDI                   = 1_000_000;
                                    // memory tPRDI paramter.
  parameter tREFI                   = 7800000;
                                    // memory tREFI paramter.
  parameter tZQI                    = 128_000_000;
                                    // memory tZQI paramter.
  parameter ADDR_WIDTH              = 28;
                                    // # = RANK_WIDTH + BANK_WIDTH
                                    //     + ROW_WIDTH + COL_WIDTH;
  parameter STARVE_LIMIT            = 2;
                                    // # = 2,3,4.
  parameter TCQ                     = 100;
  parameter ECC                     = "OFF";
  parameter ECC_TEST                = "OFF";

  //**************************************************************************//
  // Custom Parameters Declarations
  //**************************************************************************//

  //parameter DEBUG                   = 1;

  //**************************************************************************//
  // Local parameters Declarations
  //**************************************************************************//
  localparam real TPROP_DQS          = 0.00;  // Delay for DQS signal during Write Operation
  localparam real TPROP_DQS_RD       = 0.00;  // Delay for DQS signal during Read Operation
  localparam real TPROP_PCB_CTRL     = 0.00;  // Delay for Address and Ctrl signals
  localparam real TPROP_PCB_DATA     = 0.00;  // Delay for data signal during Write operation
  localparam real TPROP_PCB_DATA_RD  = 0.00;  // Delay for data signal during Read operation

  localparam MEMORY_WIDTH = 16;
  localparam NUM_COMP = DQ_WIDTH/MEMORY_WIDTH;
  localparam real CLK_PERIOD = tCK;
  localparam real REFCLK_HALF_PERIOD = (1000000.0/(2*REFCLK_FREQ)); // 5000/2 ps -> 200 MHz
  localparam DRAM_DEVICE = "SODIMM";
                         // DRAM_TYPE: "UDIMM", "RDIMM", "COMPS"

   // VT delay change options/settings
  localparam VT_ENABLE                  = "OFF";
                                        // Enable VT delay var's
  localparam VT_RATE                    = CLK_PERIOD/500;
                                        // Size of each VT step
  localparam VT_UPDATE_INTERVAL         = CLK_PERIOD*50;
                                        // Update interval
  localparam VT_MAX                     = CLK_PERIOD/40;
                                        // Maximum VT shift

  localparam SYSCLK_PERIOD              = tCK * nCK_PER_CLK;

  localparam DATA_WIDTH                 = 64;
  localparam PAYLOAD_WIDTH              = (ECC_TEST == "OFF") ? DATA_WIDTH : DQ_WIDTH;
  // Must be at least the size of the biggest acquisition size
  localparam DATA_CHECK_FIFO_SIZE       = 8192;

  // local test parameters
  localparam c_n_shots_width            = 16;
  localparam c_n_pre_samples_width      = 32;
  localparam c_n_post_samples_width     = 32;
  //localparam c_min_wait_gnt             = 32;
  //localparam c_max_wait_gnt             = 128;

  // Tests paramaters
  reg [DATA_WIDTH-1:0] data_test;
  reg data_test_valid;
  reg data_test_valid_t;
  reg trigger_test;
  //wire ext_dreq;
  //reg ext_stall;
  real data_ext_stall_threshold;
  real data_ext_rdy_threshold;
  real data_valid_threshold;

  reg data_gen_start;
  reg test_in_progress;
  reg stop_on_error;

  // Test scenario parameters
  integer test_id = 1;
  reg [c_n_shots_width-1:0] n_shots;
  reg [c_n_pre_samples_width-1:0] pre_trig_samples;
  reg [c_n_post_samples_width-1:0] post_trig_samples;
  reg [32-1:0] ddr3_start_addr;
  reg [32-1:0] lmt_pkt_size;
  reg skip_trig;
  reg wait_finish;
  real data_valid_prob;
  integer min_wait_gnt;
  integer max_wait_gnt;

  // Core registers
  reg [31:0] acq_core_fsm_ctl_reg = 'h0;
  reg [31:0] acq_core_fsm_sta_reg = 'h0;

  // DDR3 signals
  wire                                      error;
  wire                                      phy_init_done;
  wire                                      ddr3_parity;
  wire                                      ddr3_reset_n;
//  wire                                      sda;
//  wire                                      scl;

  wire [DQ_WIDTH-1:0]                       ddr3_dq_fpga;
  wire [ROW_WIDTH-1:0]                      ddr3_addr_fpga;
  wire [BANK_WIDTH-1:0]                     ddr3_ba_fpga;
  wire                                      ddr3_ras_n_fpga;
  wire                                      ddr3_cas_n_fpga;
  wire                                      ddr3_we_n_fpga;
  wire [(CS_WIDTH*nCS_PER_RANK)-1:0]        ddr3_cs_n_fpga;
  wire [(CS_WIDTH*nCS_PER_RANK)-1:0]        ddr3_odt_fpga;
  wire [CKE_WIDTH-1:0]                      ddr3_cke_fpga;
  wire [DM_WIDTH-1:0]                       ddr3_dm_fpga;
  wire [DQS_WIDTH-1:0]                      ddr3_dqs_p_fpga;
  wire [DQS_WIDTH-1:0]                      ddr3_dqs_n_fpga;
  wire [CK_WIDTH-1:0]                       ddr3_ck_p_fpga;
  wire [CK_WIDTH-1:0]                       ddr3_ck_n_fpga;

  wire [DQ_WIDTH-1:0]                       ddr3_dq_sdram;
  reg [ROW_WIDTH-1:0]                       ddr3_addr_sdram;
  reg [BANK_WIDTH-1:0]                      ddr3_ba_sdram;
  reg                                       ddr3_ras_n_sdram;
  reg                                       ddr3_cas_n_sdram;
  reg                                       ddr3_we_n_sdram;
  reg [(CS_WIDTH*nCS_PER_RANK)-1:0]         ddr3_cs_n_sdram;
  //wire [(CS_WIDTH*nCS_PER_RANK)-1:0]        ddr3_cs_n_sdram;
  reg [(CS_WIDTH*nCS_PER_RANK)-1:0]         ddr3_odt_sdram;
  reg [CKE_WIDTH-1:0]                       ddr3_cke_sdram;
  wire [DM_WIDTH-1:0]                       ddr3_dm_sdram;
  reg [DM_WIDTH-1:0]                        ddr3_dm_sdram_tmp;
  wire [DQS_WIDTH-1:0]                      ddr3_dqs_p_sdram;
  wire [DQS_WIDTH-1:0]                      ddr3_dqs_n_sdram;
  reg [CK_WIDTH-1:0]                        ddr3_ck_p_sdram;
  reg [CK_WIDTH-1:0]                        ddr3_ck_n_sdram;

  wire                                      init_calib_complete;
  wire                                      tg_compare_error;

  reg                                       ddr_sys_clk_i;
  reg                                       clk_ref_i;

  // External interface signals
  wire [DATA_WIDTH-1:0]                    ext_dout;
  wire [ADDR_WIDTH-1:0]                    ext_addr;
  wire                                     ext_valid;
  wire                                     ext_sof;
  wire                                     ext_eof;

  // DDR3 Controller UI interface signals

  wire                                      ui_app_wdf_wren;
  wire [4*PAYLOAD_WIDTH-1:0]                ui_app_wdf_data;
  wire [4*PAYLOAD_WIDTH/8-1:0]              ui_app_wdf_mask;
  wire                                      ui_app_wdf_end;
  wire [ADDR_WIDTH-1:0]                     ui_app_addr;
  wire [2:0]                                ui_app_cmd;
  wire                                      ui_app_en;
  wire                                      ui_app_rdy;
  //reg                                       ui_app_rdy;
  wire                                      ui_app_wdf_rdy;
  //reg                                       ui_app_wdf_rdy;
  wire [4*PAYLOAD_WIDTH-1:0]                ui_app_rd_data;
  wire                                      ui_app_rd_data_end;
  wire                                      ui_app_rd_data_valid;
  wire                                      ui_clk_sync_rst;
  wire                                      ui_clk_sync_rst_n;
  wire                                      ui_clk;
  wire                                      ui_phy_init_done;
  wire                                      ui_app_req;
  //reg                                       ui_app_gnt;
  wire                                       ui_app_gnt;

  // Debug/Readback signals
  wire [DATA_WIDTH-1:0]                     dbg_ddr_rb_data;
  wire [ADDR_WIDTH-1:0]                     dbg_ddr_rb_addr;
  wire                                      dbg_ddr_rb_valid;

  wire                                      chk_data_err;
  wire [16-1:0]                             chk_data_err_cnt;
  wire                                      chk_addr_err;
  wire [16-1:0]                             chk_addr_err_cnt;
  wire                                      chk_end;
  wire                                      chk_pass;

  // Clock and resets
  wire                                      sys_clk;
  wire                                      sys_rstn;
  wire                                      sys_rst;
  wire                                      adc_clk;
  wire                                      adc_rstn;
  wire                                      clk_200mhz;
  wire                                      clk200mhz_rstn;
  wire                                      ddr3_sys_clk;
  wire                                      ddr3_sys_rstn;
  wire                                      clk_ref;

  wire                                      sda;
  wire                                      scl;

  clk_rst cmp_clk_rst(
   .clk_sys_o(sys_clk),
   .clk_adc_o(adc_clk),
   .clk_100mhz_o(),
   .clk_200mhz_o(clk_200mhz),
   .sys_rstn_o(sys_rstn),
   .adc_rstn_o(adc_rstn),
   .clk100mhz_rstn_o(),
   .clk200mhz_rstn_o(clk200mhz_rstn)
  );

  assign sys_rst = ~sys_rstn;

  // DDR3 Clocks
  assign clk_ref = clk_200mhz;
  assign ddr3_sys_clk = clk_200mhz;
  assign ddr3_sys_rstn = clk200mhz_rstn;

   //**************************************************************************//
  // Clock generation and reset
  //**************************************************************************//

  //initial begin
  //  sys_clk   = 1'b0;
  //  clk_ref   = 1'b1;
  //  sys_rst_n = 1'b0;
  //
  //  #120000
  //    sys_rst_n = 1'b1;
  //end
  //
  // assign sys_rst = RST_ACT_LOW ? sys_rst_n : ~sys_rst_n;
  //
  //// Generate system clock = twice rate of CLK
  //always
  //  sys_clk = #(CLK_PERIOD/2.0) ~sys_clk; // 400 MHz
  //
  //// Generate IDELAYCTRL reference clock (200MHz)
  //always
  //  clk_ref = #REFCLK_HALF_PERIOD ~clk_ref;

  WB_TEST_MASTER WB(
    .wb_clk                                 (sys_clk)
  );

  // DUT
  wb_acq_core #(.g_ddr_addr_width(ADDR_WIDTH),
                    .g_addr_width(ADDR_WIDTH),
                    .g_sim_readback(1)
                    )
  dut(

    .fs_clk_i                               (adc_clk),
    .fs_ce_i                                (1'b1),
    .fs_rst_n_i                             (adc_rstn),

    .sys_clk_i                              (sys_clk),
    .sys_rst_n_i                            (sys_rstn),

    //.ext_clk_i                              (adc_clk),
    //.ext_rst_n_i                            (adc_rstn),
    .ext_clk_i                              (ui_clk),
    .ext_rst_n_i                            (ui_clk_sync_rst_n),

    .wb_adr_i                               (WB.wb_addr),
    .wb_dat_i                               (WB.wb_data_o),
    .wb_dat_o                               (WB.wb_data_i),
    .wb_cyc_i                               (WB.wb_cyc),
    .wb_sel_i                               (WB.wb_bwsel),
    .wb_stb_i                               (WB.wb_stb),
    .wb_we_i                                (WB.wb_we),
    .wb_ack_o                               (WB.wb_ack_i),
    .wb_err_o                               (),
    .wb_rty_o                               (),
    .wb_stall_o                             (),

    .data_i                                 (data_test), //std_logic_vector(63 downto 0);
    .dvalid_i                               (data_test_valid), //std_logic := '0';
    .ext_trig_i                             (trigger_test), //std_logic := '0';

    .dpram_dout_o                           (),
    .dpram_valid_o                          (),

    .ext_dout_o                             (ext_dout),
    .ext_valid_o                            (ext_valid),
    .ext_addr_o                             (ext_addr),
    .ext_sof_o                              (ext_sof),
    .ext_eof_o                              (ext_eof),
    .ext_dreq_o                             (ext_dreq),
    .ext_stall_o                            (ext_stall),

    .ui_app_addr_o                          (ui_app_addr),
    .ui_app_cmd_o                           (ui_app_cmd),
    .ui_app_en_o                            (ui_app_en),
    .ui_app_rdy_i                           (ui_app_rdy),

    .ui_app_wdf_data_o                      (ui_app_wdf_data),
    .ui_app_wdf_end_o                       (ui_app_wdf_end),
    .ui_app_wdf_mask_o                      (ui_app_wdf_mask),
    .ui_app_wdf_wren_o                      (ui_app_wdf_wren),
    .ui_app_wdf_rdy_i                       (ui_app_wdf_rdy),

    .ui_app_rd_data_i                       (ui_app_rd_data),
    .ui_app_rd_data_end_i                   (ui_app_rd_data_end),
    .ui_app_rd_data_valid_i                 (ui_app_rd_data_valid),

    .ui_app_req_o                           (ui_app_req),
    .ui_app_gnt_i                           (ui_app_gnt),

     // Debug interface
    .dbg_ddr_rb_data_o                      (dbg_ddr_rb_data),
    .dbg_ddr_rb_addr_o                      (dbg_ddr_rb_addr),
    .dbg_ddr_rb_valid_o                     (dbg_ddr_rb_valid)
  );

  // Very simple req and gnt driving

  //always @(posedge ui_clk) begin
  //  if (ui_clk_sync_rst_n == 1'b0) begin
  //    ui_app_gnt <= 1'b0;
  //  end else begin
  //    if (ui_app_req & ~ui_app_gnt) begin
  //      repeat(f_gen_lmt(min_wait_gnt, max_wait_gnt)) // waits between c_min_wait_gnt and c_max_wait_gnt
  //        @(posedge ui_clk);
  //
  //      ui_app_gnt <= 1'b1;
  //    end else if (~ui_app_req) begin
  //      ui_app_gnt <= 1'b0;
  //    end
  //  end
  //end

  assign ui_app_gnt = 1'b1;

  //**************************************************************************//
  // Data readback checker instantiation
  //**************************************************************************//
  data_checker #(.g_addr_width(ADDR_WIDTH),
                        .g_data_width(DATA_WIDTH),
                        .g_fifo_size(DATA_CHECK_FIFO_SIZE)
                    )
  cmp_data_checker(
    .ext_clk_i                              (ui_clk),
    .ext_rst_n_i                            (ui_clk_sync_rst_n & test_in_progress),

    // Expected data
    .exp_din_i                              (ext_dout),
    .exp_addr_i                             (ext_addr),
    .exp_valid_i                            (ext_valid & ~ext_stall),

    // Actual data
    .act_din_i                              (dbg_ddr_rb_data),
    .act_addr_i                             (dbg_ddr_rb_addr),
    .act_valid_i                            (dbg_ddr_rb_valid),

    // Size of the transaction in g_fifo_size bytes
    .lmt_pkt_size_i                         (lmt_pkt_size),
    // Number of shots in this acquisition
    .lmt_shots_nb_i                         (n_shots),
    // Acquisition limits valid signal. Qualifies lmt_fifo_pkt_size_i and lmt_shots_nb_i
    .lmt_valid_i                            (test_in_progress),

    .chk_data_err_o                         (chk_data_err),
    .chk_data_err_cnt_o                     (chk_data_err_cnt),
    .chk_addr_err_o                         (chk_addr_err),
    .chk_addr_err_cnt_o                     (chk_addr_err_cnt),
    .chk_end_o                              (chk_end),
    .chk_pass_o                             (chk_pass)
  );

  //**************************************************************************//
  // DDR3_v6 Controller instantiation
  //**************************************************************************//
  //ddr3_v6 #(
  ddr_v6 #(
    .SIM_BYPASS_INIT_CAL                    (SIM_BYPASS_INIT_CAL),
    .RST_ACT_LOW                            (RST_ACT_LOW)
  )
  cmp_ddr_v6(
     // System Clock Ports
    .sys_clk                                (ddr3_sys_clk),
    .sys_rst                                (ddr3_sys_rstn), // RST_ACT_LOW = 1
    .clk_ref                                (clk_ref),

    // Memory interface ports
    .ddr3_dq                                (ddr3_dq_fpga),
    .ddr3_dm                                (ddr3_dm_fpga),
    .ddr3_addr                              (ddr3_addr_fpga),
    .ddr3_ba                                (ddr3_ba_fpga),
    .ddr3_ras_n                             (ddr3_ras_n_fpga),
    .ddr3_cas_n                             (ddr3_cas_n_fpga),
    .ddr3_we_n                              (ddr3_we_n_fpga),
    .ddr3_reset_n                           (ddr3_reset_n),
    .ddr3_cs_n                              (ddr3_cs_n_fpga),
    .ddr3_odt                               (ddr3_odt_fpga),
    .ddr3_cke                               (ddr3_cke_fpga),
    .ddr3_dqs_p                             (ddr3_dqs_p_fpga),
    .ddr3_dqs_n                             (ddr3_dqs_n_fpga),
    .ddr3_ck_p                              (ddr3_ck_p_fpga),
    .ddr3_ck_n                              (ddr3_ck_n_fpga),
    //.sda                                    (sda_fpga),
    //.scl                                    (scl_fpga),

    // Application interface ports
    .app_wdf_wren                           (ui_app_wdf_wren),
    .app_wdf_data                           (ui_app_wdf_data),
    .app_wdf_mask                           (ui_app_wdf_mask),
    .app_wdf_end                            (ui_app_wdf_end),
    .app_addr                               (ui_app_addr),
    .app_cmd                                (ui_app_cmd),
    .app_en                                 (ui_app_en),
    .app_rdy                                (ui_app_rdy),
    .app_wdf_rdy                            (ui_app_wdf_rdy),
    .app_rd_data                            (ui_app_rd_data),
    .app_rd_data_end                        (ui_app_rd_data_end),
    .app_rd_data_valid                      (ui_app_rd_data_valid),
    .ui_clk_sync_rst                        (ui_clk_sync_rst),
    .ui_clk                                 (ui_clk),
    .phy_init_done                          (ui_phy_init_done)
  );

  assign ui_clk_sync_rst_n = ~ui_clk_sync_rst;

  //**************************************************************************//
  // Memory Models instantiations
  //**************************************************************************//
  genvar r,i,dqs_x;

  generate
    for (r = 0; r < CS_WIDTH; r = r+1) begin: mem_rnk
      if(MEMORY_WIDTH == 16) begin: mem_16
        if(DQ_WIDTH/16) begin: gen_mem
          for (i = 0; i < NUM_COMP; i = i + 1) begin: gen_mem
            ddr3_model u_comp_ddr3
              (
                .rst_n   (ddr3_reset_n),
                .ck      (ddr3_ck_p_sdram[(i*MEMORY_WIDTH)/72]),
                .ck_n    (ddr3_ck_n_sdram[(i*MEMORY_WIDTH)/72]),
                .cke     (ddr3_cke_sdram[((i*MEMORY_WIDTH)/72)+(nCS_PER_RANK*r)]),
                .cs_n    (ddr3_cs_n_sdram[((i*MEMORY_WIDTH)/72)+(nCS_PER_RANK*r)]),
                .ras_n   (ddr3_ras_n_sdram),
                .cas_n   (ddr3_cas_n_sdram),
                .we_n    (ddr3_we_n_sdram),
                .dm_tdqs (ddr3_dm_sdram[(2*(i+1)-1):(2*i)]),
                .ba      (ddr3_ba_sdram),
                .addr    (ddr3_addr_sdram),
                .dq      (ddr3_dq_sdram[MEMORY_WIDTH*(i+1)-1:MEMORY_WIDTH*(i)]),
                .dqs     (ddr3_dqs_p_sdram[(2*(i+1)-1):(2*i)]),
                .dqs_n   (ddr3_dqs_n_sdram[(2*(i+1)-1):(2*i)]),
                .tdqs_n  (),
                .odt     (ddr3_odt_sdram[((i*MEMORY_WIDTH)/72)+(nCS_PER_RANK*r)])
                );
          end
        end
        if (DQ_WIDTH%16) begin: gen_mem_extrabits
          ddr3_model u_comp_ddr3
            (
              .rst_n   (ddr3_reset_n),
              .ck      (ddr3_ck_p_sdram[(DQ_WIDTH-1)/72]),
              .ck_n    (ddr3_ck_n_sdram[(DQ_WIDTH-1)/72]),
              .cke     (ddr3_cke_sdram[((DQ_WIDTH-1)/72)+(nCS_PER_RANK*r)]),
              .cs_n    (ddr3_cs_n_sdram[((DQ_WIDTH-1)/72)+(nCS_PER_RANK*r)]),
              .ras_n   (ddr3_ras_n_sdram),
              .cas_n   (ddr3_cas_n_sdram),
              .we_n    (ddr3_we_n_sdram),
              .dm_tdqs ({ddr3_dm_sdram[DM_WIDTH-1],ddr3_dm_sdram[DM_WIDTH-1]}),
              .ba      (ddr3_ba_sdram),
              .addr    (ddr3_addr_sdram),
              .dq      ({ddr3_dq_sdram[DQ_WIDTH-1:(DQ_WIDTH-8)],
                        ddr3_dq_sdram[DQ_WIDTH-1:(DQ_WIDTH-8)]}),
              .dqs     ({ddr3_dqs_p_sdram[DQS_WIDTH-1],
                        ddr3_dqs_p_sdram[DQS_WIDTH-1]}),
              .dqs_n   ({ddr3_dqs_n_sdram[DQS_WIDTH-1],
                        ddr3_dqs_n_sdram[DQS_WIDTH-1]}),
              .tdqs_n  (),
              .odt     (ddr3_odt_sdram[((DQ_WIDTH-1)/72)+(nCS_PER_RANK*r)])
              );
        end
      end
      if((MEMORY_WIDTH == 8) || (MEMORY_WIDTH == 4)) begin: mem_8_4
        for (i = 0; i < NUM_COMP; i = i + 1) begin: gen_mem
          ddr3_model u_comp_ddr3
            (
              .rst_n   (ddr3_reset_n),
              .ck      (ddr3_ck_p_sdram[(i*MEMORY_WIDTH)/72]),
              .ck_n    (ddr3_ck_n_sdram[(i*MEMORY_WIDTH)/72]),
              .cke     (ddr3_cke_sdram[((i*MEMORY_WIDTH)/72)+(nCS_PER_RANK*r)]),
              .cs_n    (ddr3_cs_n_sdram[((i*MEMORY_WIDTH)/72)+(nCS_PER_RANK*r)]),
              .ras_n   (ddr3_ras_n_sdram),
              .cas_n   (ddr3_cas_n_sdram),
              .we_n    (ddr3_we_n_sdram),
              .dm_tdqs (ddr3_dm_sdram[i]),
              .ba      (ddr3_ba_sdram),
              .addr    (ddr3_addr_sdram),
              .dq      (ddr3_dq_sdram[MEMORY_WIDTH*(i+1)-1:MEMORY_WIDTH*(i)]),
              .dqs     (ddr3_dqs_p_sdram[i]),
              .dqs_n   (ddr3_dqs_n_sdram[i]),
              .tdqs_n  (),
              .odt     (ddr3_odt_sdram[((i*MEMORY_WIDTH)/72)+(nCS_PER_RANK*r)])
              );
        end
      end
    end
  endgenerate

  //**************************************************************************//
  // DDR controller <--> DDR model Logic
  //**************************************************************************//
  always @( * ) begin
    ddr3_ck_p_sdram   <=  #(TPROP_PCB_CTRL) ddr3_ck_p_fpga;
    ddr3_ck_n_sdram   <=  #(TPROP_PCB_CTRL) ddr3_ck_n_fpga;
    ddr3_addr_sdram   <=  #(TPROP_PCB_CTRL) ddr3_addr_fpga;
    ddr3_ba_sdram     <=  #(TPROP_PCB_CTRL) ddr3_ba_fpga;
    ddr3_ras_n_sdram  <=  #(TPROP_PCB_CTRL) ddr3_ras_n_fpga;
    ddr3_cas_n_sdram  <=  #(TPROP_PCB_CTRL) ddr3_cas_n_fpga;
    ddr3_we_n_sdram   <=  #(TPROP_PCB_CTRL) ddr3_we_n_fpga;
    ddr3_cs_n_sdram   <=  #(TPROP_PCB_CTRL) ddr3_cs_n_fpga;
    ddr3_cke_sdram    <=  #(TPROP_PCB_CTRL) ddr3_cke_fpga;
    ddr3_odt_sdram    <=  #(TPROP_PCB_CTRL) ddr3_odt_fpga;
    ddr3_dm_sdram_tmp <=  #(TPROP_PCB_DATA) ddr3_dm_fpga;//DM signal generation
  end

  assign ddr3_dm_sdram = ddr3_dm_sdram_tmp;

  //assign init_calib_complete = 1'b1;
  assign init_calib_complete = ui_phy_init_done;

// Controlling the bi-directional BUS
  genvar dqwd;
  generate
    for (dqwd = 1;dqwd < DQ_WIDTH;dqwd = dqwd+1) begin : dq_delay
      WireDelay #
       (
        .Delay_g  (TPROP_PCB_DATA),
        .Delay_rd (TPROP_PCB_DATA_RD),
        .ERR_INSERT ("OFF")
       )
      u_delay_dq
       (
        .A     (ddr3_dq_fpga[dqwd]),
        .B     (ddr3_dq_sdram[dqwd]),
        .reset (sys_rst_n),
	      .phy_init_done (ui_phy_init_done)
       );
     end
      WireDelay #
       (
        .Delay_g  (TPROP_PCB_DATA),
        .Delay_rd (TPROP_PCB_DATA_RD),
        .ERR_INSERT (ECC)
       )
      u_delay_dq_0
       (
        .A     (ddr3_dq_fpga[0]),
        .B     (ddr3_dq_sdram[0]),
        .reset (sys_rst_n),
        .phy_init_done (ui_phy_init_done)
       );

  endgenerate

  genvar dqswd;
  generate
    for (dqswd = 0;dqswd < DQS_WIDTH;dqswd = dqswd+1) begin : dqs_delay
      WireDelay #
       (
        .Delay_g  (TPROP_DQS),
        .Delay_rd (TPROP_DQS_RD),
        .ERR_INSERT ("OFF")
       )
      u_delay_dqs_p
       (
        .A     (ddr3_dqs_p_fpga[dqswd]),
        .B     (ddr3_dqs_p_sdram[dqswd]),
        .reset (sys_rst_n),
	      .phy_init_done (ui_phy_init_done)
       );

      WireDelay #
       (
        .Delay_g  (TPROP_DQS),
        .Delay_rd (TPROP_DQS_RD),
	      .ERR_INSERT ("OFF")
       )
      u_delay_dqs_n
       (
        .A     (ddr3_dqs_n_fpga[dqswd]),
        .B     (ddr3_dqs_n_sdram[dqswd]),
        .reset (sys_rst_n),
	      .phy_init_done (ui_phy_init_done)
       );
    end
  endgenerate

  //**************************************************************************//
  // Stimulus to DUT
  //**************************************************************************//
  initial begin

    // Initial values for ADC data signals
    data_gen_start = 1'b0;
    test_in_progress = 1'b0;
    trigger_test = 1'b0;
    // Default values. No wait
    min_wait_gnt = 0;
    max_wait_gnt = 0;

    $display("-----------------------------------");
    $display("@%0d: Simulation of BPM ACQ FSM starting!", $time);
    $display("-----------------------------------");

    $display("-----------------------------------");
    $display("@%0d: Initialization  Begin", $time);
    $display("-----------------------------------");

    $display("-----------------------------------");
    $display("@%0d: Waiting for all resets...", $time);
    $display("-----------------------------------");

    wait (WB.ready);
    wait (sys_rstn);
    wait (adc_rstn);

    $display("@%0d: Reset done!", $time);

    $display("-----------------------------------");
    $display("@%0d: Waiting for Memory initilization/calibration...", $time);
    $display("-----------------------------------");

    wait (init_calib_complete);

    $display("@%0d: Memory initialization/calibration done!", $time);

    data_gen_start = 1'b1;

    @(posedge sys_clk);

    $display("-------------------------------------");
    $display("@%0d:  Initialization  Done!", $time);
    $display("-------------------------------------");

    ////////////////////////
    // TEST #1
    // Number of shots = 1
    // Pre trigger samples only
    // No trigger
    ////////////////////////
    test_id = 1;
    n_shots = 16'h0001;
    pre_trig_samples = 32'h00000010;
    post_trig_samples = 32'h00000000;
    ddr3_start_addr = 32'h00000000; // all zeros for now
    lmt_pkt_size = pre_trig_samples + post_trig_samples;
    skip_trig = 1'b1;
    wait_finish = 1'b1;
    stop_on_error = 1'b1;
    data_valid_prob = 1.0;
    min_wait_gnt = 32;
    max_wait_gnt = 128;

    wb_acq(test_id, n_shots,
                pre_trig_samples, post_trig_samples,
                ddr3_start_addr, skip_trig, wait_finish,
                stop_on_error, data_valid_prob);

    ////////////////////////
    // TEST #2
    // Number of shots = 1
    // Pre trigger samples only
    // No trigger
    ////////////////////////
    test_id = 2;
    n_shots = 16'h0001;
    pre_trig_samples = 32'h00000010;
    post_trig_samples = 32'h00000000;
    ddr3_start_addr = 32'h00000000; // all zeros for now
    lmt_pkt_size = pre_trig_samples + post_trig_samples;
    skip_trig = 1'b1;
    wait_finish = 1'b1;
    data_valid_prob = 0.7;

    wb_acq(test_id, n_shots,
                pre_trig_samples, post_trig_samples,
                ddr3_start_addr, skip_trig, wait_finish,
                stop_on_error, data_valid_prob);

    ////////////////////////
    // TEST #3
    // Number of shots = 1
    // Pre trigger samples only
    // No trigger
    ////////////////////////

    test_id = 3;
    n_shots = 16'h0001;
    pre_trig_samples = 32'h00000100;
    post_trig_samples = 32'h00000000;
    ddr3_start_addr = 32'h00000000; // all zeros for now
    lmt_pkt_size = pre_trig_samples + post_trig_samples;
    skip_trig = 1'b1;
    wait_finish = 1'b1;
    data_valid_prob = 0.7;

    wb_acq(test_id, n_shots,
                pre_trig_samples, post_trig_samples,
                ddr3_start_addr, skip_trig, wait_finish,
                stop_on_error, data_valid_prob);

    ////////////////////////
    // TEST #4
    // Number of shots = 1
    // Pre trigger samples only
    // No trigger
    ////////////////////////

    test_id = 4;
    n_shots = 16'h0001;
    pre_trig_samples = 32'h00001000;
    post_trig_samples = 32'h00000000;
    ddr3_start_addr = 32'h00000000; // all zeros for now
    lmt_pkt_size = pre_trig_samples + post_trig_samples;
    skip_trig = 1'b1;
    wait_finish = 1'b1;
    data_valid_prob = 0.5;

    wb_acq(test_id, n_shots,
                pre_trig_samples, post_trig_samples,
                ddr3_start_addr, skip_trig, wait_finish,
                stop_on_error, data_valid_prob);

    ////////////////////////
    // TEST #5
    // Number of shots = 2
    // Pre trigger samples only
    // No trigger
    ////////////////////////

    test_id = 5;
    n_shots = 16'h0002;
    pre_trig_samples = 32'h00000010;
    post_trig_samples = 32'h00000000;
    ddr3_start_addr = 32'h00000000; // all zeros for now
    lmt_pkt_size = pre_trig_samples + post_trig_samples;
    skip_trig = 1'b1;
    wait_finish = 1'b1;
    data_valid_prob = 0.7;

    wb_acq(test_id, n_shots,
                pre_trig_samples, post_trig_samples,
                ddr3_start_addr, skip_trig, wait_finish,
                stop_on_error, data_valid_prob);

    ////////////////////////
    // TEST #6
    // Number of shots = 16
    // Pre trigger samples only
    // No trigger
    ////////////////////////

    test_id = 6;
    n_shots = 16'h0010;
    pre_trig_samples = 32'h00000010;
    post_trig_samples = 32'h00000000;
    ddr3_start_addr = 32'h00000000; // all zeros for now
    lmt_pkt_size = pre_trig_samples + post_trig_samples;
    skip_trig = 1'b1;
    wait_finish = 1'b1;
    data_valid_prob = 0.6;
    min_wait_gnt = 64;
    max_wait_gnt = 128;

    wb_acq(test_id, n_shots,
                pre_trig_samples, post_trig_samples,
                ddr3_start_addr, skip_trig, wait_finish,
                stop_on_error, data_valid_prob);

    ////////////////////////
    // TEST #7
    // Number of shots = 16
    // Pre trigger samples only
    // No trigger
    ////////////////////////

    test_id = 7;
    n_shots = 16'h0010;
    pre_trig_samples = 32'h00000020;
    post_trig_samples = 32'h00000000;
    ddr3_start_addr = 32'h00000000; // all zeros for now
    lmt_pkt_size = pre_trig_samples + post_trig_samples;
    skip_trig = 1'b1;
    wait_finish = 1'b1;
    data_valid_prob = 0.6;
    min_wait_gnt = 128;
    max_wait_gnt = 512;

    wb_acq(test_id, n_shots,
                pre_trig_samples, post_trig_samples,
                ddr3_start_addr, skip_trig, wait_finish,
                stop_on_error, data_valid_prob);

    $display("Simulation Done!");
    $display("All Tests Passed!");
    $display("---------------------------------------------");
    $finish;
  end

  // Generate data and valid signals on positive edge of clock
  always @(posedge adc_clk)
  begin
    if (data_gen_start) begin
      //data_test <= f_data_gen(c_data_max);
      if (data_test_valid_t)
        data_test <= data_test + 1;

      data_test_valid_t <= f_gen_data_rdy_gen(data_valid_threshold);
      data_test_valid <= data_test_valid_t;
    end else begin
      data_test <= 'h0;
      data_test_valid <= 1'b0;
      data_test_valid_t <= 1'b0;
    end
  end

  //assign ext_dreq = 1'b1;

  /////////////////////////////////////////////////////////////////////////////
  // Functions
  /////////////////////////////////////////////////////////////////////////////
  function [`DATA_TEST_WIDTH-1:0] f_data_gen;
    input integer max_size;
  begin
    // $random is surronded by the concat operator in order
    // to provide us with only unsigned (bit vector) data
    f_data_gen = {$random} % max_size;
  end
  endfunction

  function f_gen_data_rdy_gen;
    input real prob;
    real temp;
  begin
    f_gen_data_rdy_gen = f_gen_bit_one(prob);
  end
  endfunction

  function f_gen_data_stall;
    input real prob;
    real temp;
  begin
    f_gen_data_stall = f_gen_bit_one(1.0-prob);
  end
  endfunction

  function f_gen_bit_one;
    input real prob;
    real temp;
  begin
    // $random is surronded by the concat operator in order
    // to provide us with only unsigned (bit vector) data.
    // Generates valud in a 0..1 range
    temp = ({$random} % 100 + 1)/100.00;//threshold;

    if (temp <= prob)
     f_gen_bit_one = 1'b1;
    else
      f_gen_bit_one = 1'b0;
  end
  endfunction

  function integer f_gen_lmt;
    input integer min;
    input integer max;
    real temp;
  begin
    // $random is surronded by the concat operator in order
    // to provide us with only unsigned (bit vector) data.
    f_gen_lmt = ({$random} % (max-min) + min);

  end
  endfunction

  /////////////////////////////////////////////////////////////////////////////
  // Tasks
  /////////////////////////////////////////////////////////////////////////////

  task wb_busy_wait;
    input [`WB_ADDRESS_BUS_WIDTH-1:0] addr;
    input [`WB_DATA_BUS_WIDTH-1:0] mask;
    input [`WB_DATA_BUS_WIDTH-1:0] offset;
    input verbose;

    reg [`WB_DATA_BUS_WIDTH-1:0] tmp_reg;
  begin
    WB.monitor_bus(1'b0);
    WB.verbose(1'b0);

    WB.read32(addr, tmp_reg);

    while (((tmp_reg & mask) >> offset) != 'h1) begin
      if (verbose)
        $write(".");

      @(posedge sys_clk);
      WB.read32(addr, tmp_reg);
    end

    WB.monitor_bus(1'b1);
    WB.verbose(1'b1);
  end
  endtask

  task wb_acq;
    input integer test_id;
    input [15:0] n_shots;
    input [31:0] pre_trig_samples;
    input [31:0] post_trig_samples;
    input [31:0] ddr3_start_addr;
    input skip_trig;
    input wait_finish;
    input stop_on_error;
    //input real ext_stall_prob;
    input real data_valid_prob;

    reg [31:0] acq_core_fsm_ctl_reg;
  begin
    $display("#############################");
    $display("######## TEST #%03d ######", test_id);
    $display("#############################");
    $display("## Number of shots = %03d", n_shots);
    $display("## Number of pre samples = %03d", pre_trig_samples);
    $display("## Skip trigger = %d", skip_trig);
    $display("## Number of post samples = %03d", post_trig_samples);

    $display("Setting throttling parameters scenario");
    //$display("Setting sink stall probability = %.2f%%", ext_stall_prob*100);
    //$display("Setting sink rdy probability = %.2f%%", (1-ext_stall_prob)*100);
    $display("Setting source data valid input probability = %.2f%%", data_valid_prob*100);

    test_in_progress = 1'b1;
    //@(posedge sys_clk);
    //test_in_progress = 1'b0;

    @(posedge sys_clk);
    //data_ext_stall_threshold = 0.3;
    //data_ext_rdy_threshold = 0.7;
    //data_valid_threshold = 0.7;
    data_valid_threshold = data_valid_prob; // modify external register! FIXME?

    $display("Setting # of shots to %03d", n_shots);
    @(posedge sys_clk);
    WB.write32(`ADDR_ACQ_CORE_SHOTS >> `WB_WORD_ACC, (n_shots << `ACQ_CORE_SHOTS_NB_OFFSET));

    $display("Setting # of pre-trigger to %03d", pre_trig_samples);
    @(posedge sys_clk);
    WB.write32(`ADDR_ACQ_CORE_PRE_SAMPLES >> `WB_WORD_ACC, (pre_trig_samples));

    $display("Setting # of pos-trigger to %03d", post_trig_samples);
    @(posedge sys_clk);
    WB.write32(`ADDR_ACQ_CORE_POST_SAMPLES >> `WB_WORD_ACC, (post_trig_samples));

    // Prepare core_ctl register
    acq_core_fsm_ctl_reg = (skip_trig) << `ACQ_CORE_CTL_FSM_ACQ_NOW_OFFSET;

    $display("Setting skip trigger parameter to %d", skip_trig);
    @(posedge sys_clk);
    WB.write32(`ADDR_ACQ_CORE_CTL >> `WB_WORD_ACC, acq_core_fsm_ctl_reg);

    $display("Setting DDR3 start address for the next acquistion %d", skip_trig);
    @(posedge sys_clk);
    WB.write32(`ADDR_ACQ_CORE_DDR3_START_ADDR >> `WB_WORD_ACC, ddr3_start_addr);

   // Prepare core_ctl register
    acq_core_fsm_ctl_reg = acq_core_fsm_ctl_reg |
                          (32'h00000001) << `ACQ_CORE_CTL_FSM_START_ACQ_OFFSET;

    $display("Starting acquisition... ");
    @(posedge sys_clk);
    WB.write32(`ADDR_ACQ_CORE_CTL >> `WB_WORD_ACC, acq_core_fsm_ctl_reg);

    if (wait_finish) begin
      $display("Waiting until all data have been acquired...\n");
      @(posedge sys_clk);
      //wb_busy_wait(`ADDR_ACQ_CORE_STA >> `WB_WORD_ACC, `ACQ_CORE_STA_FC_TRANS_DONE,
      //                `ACQ_CORE_STA_FC_TRANS_DONE_OFFSET, 1'b1);
      wb_busy_wait(`ADDR_ACQ_CORE_STA >> `WB_WORD_ACC, `ACQ_CORE_STA_DDR3_TRANS_DONE,
                      `ACQ_CORE_STA_DDR3_TRANS_DONE_OFFSET, 1'b1);
    end

    $display("Done!");
    //$display("Waiting data check...");

    wait (chk_end); // data checker ended

    $display("Data checker detected a total of %03d data mismatch errors", chk_data_err_cnt);
    $display("Data checker detected a total of %03d addr mismatch errors", chk_addr_err_cnt);

    if (stop_on_error & (chk_data_err | chk_addr_err)) begin
      $display("TEST #%03d NOT PASS!", test_id);
      $finish;
    end

    $display("\n");

    @(posedge sys_clk);
    test_in_progress = 1'b0;

    // give some time for all the modules that ned a reset between tests
    repeat (2) begin
      @(posedge sys_clk);
    end

  end
  endtask

endmodule
