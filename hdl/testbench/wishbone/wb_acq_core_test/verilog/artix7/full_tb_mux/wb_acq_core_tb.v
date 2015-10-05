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
// 2014-28-10  1.0      lucas.russo        Created
//-----------------------------------------------------------------------------

// Simulation timescale
`include "timescale.v"
// Common definitions
`include "defines.v"
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
  localparam c_ddr3_acq1_addr_offset      = 'h01000000;
  localparam c_ddr3_acq1_data_offset      = 'h00006000;

  //// DDR3 Parameters
  parameter SIMULATION                    = "TRUE";
  //***************************************************************************
  // The following parameters refer to width of various ports
  //***************************************************************************
  parameter BANK_WIDTH            = 3;
                                    // # of memory Bank Address bits.
  parameter CK_WIDTH              = 1;
                                    // # of CK/CK# outputs to memory.
  parameter COL_WIDTH             = 10;
                                    // # of memory Column Address bits.
  parameter CS_WIDTH              = 1;
                                    // # of unique CS outputs to memory.
  parameter nCS_PER_RANK          = 1;
                                    // # of unique CS outputs per rank for phy
  parameter CKE_WIDTH             = 1;
                                    // # of CKE outputs to memory.
  parameter DATA_BUF_ADDR_WIDTH   = 5;
  parameter DQ_CNT_WIDTH          = 5;
                                    // = ceil(log2(DQ_WIDTH))
  parameter DQ_PER_DM             = 8;
  parameter DM_WIDTH              = 4;
                                    // # of DM (data mask)
  parameter DQ_WIDTH              = 32;
                                    // # of DQ (data)
  parameter DQS_WIDTH             = 4;
  parameter DQS_CNT_WIDTH         = 2;
                                    // = ceil(log2(DQS_WIDTH))
  parameter DRAM_WIDTH            = 8;
                                    // # of DQ per DQS
  parameter ECC                   = "OFF";
  parameter nBANK_MACHS           = 4;
  parameter RANKS                 = 1;
                                    // # of Ranks.
  parameter ODT_WIDTH             = 1;
                                    // # of ODT outputs to memory.
  parameter ROW_WIDTH             = 16;
                                    // # of memory Row Address bits.
  parameter ADDR_WIDTH            = 30;
                                    // # = RANK_WIDTH + BANK_WIDTH
                                    //     + ROW_WIDTH + COL_WIDTH;
                                    // Chip Select is always tied to low for
                                    // single rank devices
  parameter USE_CS_PORT          = 1;
                                    // # = 1, When CS output is enabled
                                    //   = 0, When CS output is disabled
                                    // If CS_N disabled, user must connect
                                    // DRAM CS_N input(s) to ground
  parameter USE_DM_PORT           = 1;
                                    // # = 1, When Data Mask option is enabled
                                    //   = 0, When Data Mask option is disbaled
                                    // When Data Mask option is disabled in
                                    // MIG Controller Options page, the logic
                                    // related to Data Mask should not get
                                    // synthesized
  parameter USE_ODT_PORT          = 1;
                                    // # = 1, When ODT output is enabled
                                    //   = 0, When ODT output is disabled
                                    // Parameter configuration for Dynamic ODT support:
                                    // USE_ODT_PORT = 0, RTT_NOM = "DISABLED", RTT_WR = "60/120".
                                    // This configuration allows to save ODT pin mapping from FPGA.
                                    // The user can tie the ODT input of DRAM to HIGH.

  //***************************************************************************
  // The following parameters are mode register settings
  //***************************************************************************
  parameter AL                    = "0";
                                    // DDR3 SDRAM:
                                    // Additive Latency (Mode Register 1).
                                    // # = "0", "CL-1", "CL-2".
                                    // DDR2 SDRAM:
                                    // Additive Latency (Extended Mode Register).
  parameter nAL                   = 0;
                                    // # Additive Latency in number of clock
                                    // cycles.
  parameter BURST_MODE            = "8";
                                    // DDR3 SDRAM:
                                    // Burst Length (Mode Register 0).
                                    // # = "8", "4", "OTF".
                                    // DDR2 SDRAM:
                                    // Burst Length (Mode Register).
                                    // # = "8", "4".
  parameter BURST_TYPE            = "SEQ";
                                    // DDR3 SDRAM: Burst Type (Mode Register 0).
                                    // DDR2 SDRAM: Burst Type (Mode Register).
                                    // # = "SEQ" - (Sequential),
                                    //   = "INT" - (Interleaved).
  parameter CL                    = 6;
                                    // in number of clock cycles
                                    // DDR3 SDRAM: CAS Latency (Mode Register 0).
                                    // DDR2 SDRAM: CAS Latency (Mode Register).
  parameter CWL                   = 5;
                                    // in number of clock cycles
                                    // DDR3 SDRAM: CAS Write Latency (Mode Register 2).
                                    // DDR2 SDRAM: Can be ignored
  parameter OUTPUT_DRV            = "HIGH";
                                    // Output Driver Impedance Control (Mode Register 1).
                                    // # = "HIGH" - RZQ/7,
                                    //   = "LOW" - RZQ/6.
  parameter RTT_NOM               = "40";
                                    // RTT_NOM (ODT) (Mode Register 1).
                                    // # = "DISABLED" - RTT_NOM disabled,
                                    //   = "120" - RZQ/2,
                                    //   = "60"  - RZQ/4,
                                    //   = "40"  - RZQ/6.
  parameter RTT_WR                = "OFF";
                                    // RTT_WR (ODT) (Mode Register 2).
                                    // # = "OFF" - Dynamic ODT off,
                                    //   = "120" - RZQ/2,
                                    //   = "60"  - RZQ/4,
  parameter ADDR_CMD_MODE         = "1T" ;
                                    // # = "1T", "2T".
  parameter REG_CTRL              = "OFF";
                                    // # = "ON" - RDIMMs,
                                    //   = "OFF" - Components, SODIMMs, UDIMMs.
  parameter CA_MIRROR             = "OFF";
                                    // C/A mirror opt for DDR3 dual rank

  //***************************************************************************
  // The following parameters are multiplier and divisor factors for PLLE2.
  // Based on the selected design frequency these parameters vary.
  //***************************************************************************
  parameter CLKIN_PERIOD          = 5000;
                                    // Input Clock Period
  parameter CLKFBOUT_MULT         = 4;
                                    // write PLL VCO multiplier
  parameter DIVCLK_DIVIDE         = 1;
                                    // write PLL VCO divisor
  parameter CLKOUT0_DIVIDE        = 2;
                                    // VCO output divisor for PLL output clock (CLKOUT0)
  parameter CLKOUT1_DIVIDE        = 2;
                                    // VCO output divisor for PLL output clock (CLKOUT1)
  parameter CLKOUT2_DIVIDE        = 32;
                                    // VCO output divisor for PLL output clock (CLKOUT2)
  parameter CLKOUT3_DIVIDE        = 8;
                                    // VCO output divisor for PLL output clock (CLKOUT3)

  //***************************************************************************
  // Memory Timing Parameters. These parameters varies based on the selected
  // memory part.
  //***************************************************************************
  parameter tCKE                  = 5000;
                                    // memory tCKE paramter in pS
  parameter tFAW                  = 30000;
                                    // memory tRAW paramter in pS.
  parameter tRAS                  = 35000;
                                    // memory tRAS paramter in pS.
  parameter tRCD                  = 13750;
                                    // memory tRCD paramter in pS.
  parameter tREFI                 = 7800000;
                                    // memory tREFI paramter in pS.
  parameter tRFC                  = 300000;
                                    // memory tRFC paramter in pS.
  parameter tRP                   = 13750;
                                    // memory tRP paramter in pS.
  parameter tRRD                  = 6000;
                                    // memory tRRD paramter in pS.
  parameter tRTP                  = 7500;
                                    // memory tRTP paramter in pS.
  parameter tWTR                  = 7500;
                                    // memory tWTR paramter in pS.
  parameter tZQI                  = 128_000_000;
                                    // memory tZQI paramter in nS.
  parameter tZQCS                 = 64;
                                    // memory tZQCS paramter in clock cycles.

  //***************************************************************************
  // Simulation parameters
  //***************************************************************************
  parameter SIM_BYPASS_INIT_CAL   = "FAST";
                                    // # = "SIM_INIT_CAL_FULL" -  Complete
                                    //              memory init &
                                    //              calibration sequence
                                    // # = "SKIP" - Not supported
                                    // # = "FAST" - Complete memory init & use
                                    //              abbreviated calib sequence

  //***************************************************************************
  // The following parameters varies based on the pin out entered in MIG GUI.
  // Do not change any of these parameters directly by editing the RTL.
  // Any changes required should be done through GUI and the design regenerated.
  //***************************************************************************
  parameter BYTE_LANES_B0         = 4'b1111;
                                    // Byte lanes used in an IO column.
  parameter BYTE_LANES_B1         = 4'b1110;
                                    // Byte lanes used in an IO column.
  parameter BYTE_LANES_B2         = 4'b0000;
                                    // Byte lanes used in an IO column.
  parameter BYTE_LANES_B3         = 4'b0000;
                                    // Byte lanes used in an IO column.
  parameter BYTE_LANES_B4         = 4'b0000;
                                    // Byte lanes used in an IO column.
  parameter DATA_CTL_B0           = 4'b1111;
                                    // Indicates Byte lane is data byte lane
                                    // or control Byte lane. '1' in a bit
                                    // position indicates a data byte lane and
                                    // a '0' indicates a control byte lane
  parameter DATA_CTL_B1           = 4'b0000;
                                    // Indicates Byte lane is data byte lane
                                    // or control Byte lane. '1' in a bit
                                    // position indicates a data byte lane and
                                    // a '0' indicates a control byte lane
  parameter DATA_CTL_B2           = 4'b0000;
                                    // Indicates Byte lane is data byte lane
                                    // or control Byte lane. '1' in a bit
                                    // position indicates a data byte lane and
                                    // a '0' indicates a control byte lane
  parameter DATA_CTL_B3           = 4'b0000;
                                    // Indicates Byte lane is data byte lane
                                    // or control Byte lane. '1' in a bit
                                    // position indicates a data byte lane and
                                    // a '0' indicates a control byte lane
  parameter DATA_CTL_B4           = 4'b0000;
                                    // Indicates Byte lane is data byte lane
                                    // or control Byte lane. '1' in a bit
                                    // position indicates a data byte lane and
                                    // a '0' indicates a control byte lane
  parameter PHY_0_BITLANES        = 48'h3FE3FD2FF2FF;
  parameter PHY_1_BITLANES        = 48'hFFEFF3CC0000;
  parameter PHY_2_BITLANES        = 48'h000000000000;

  // control/address/data pin mapping parameters
  parameter CK_BYTE_MAP
    = 144'h000000000000000000000000000000000012;
  parameter ADDR_MAP
    = 192'h13211A11712A11B13A12512012B126131129116124121128;
  parameter BANK_MAP   = 36'h13613713B;
  parameter CAS_MAP    = 12'h135;
  parameter CKE_ODT_BYTE_MAP = 8'h00;
  parameter CKE_MAP    = 96'h000000000000000000000127;
  parameter ODT_MAP    = 96'h000000000000000000000138;
  parameter CS_MAP     = 120'h000000000000000000000000000133;
  parameter PARITY_MAP = 12'h000;
  parameter RAS_MAP    = 12'h139;
  parameter WE_MAP     = 12'h134;
  parameter DQS_BYTE_MAP
    = 144'h000000000000000000000000000003020100;
  parameter DATA0_MAP  = 96'h009006002004003007000005;
  parameter DATA1_MAP  = 96'h017014010015013011016019;
  parameter DATA2_MAP  = 96'h024026023027022025020029;
  parameter DATA3_MAP  = 96'h034037031035033036032039;
  parameter DATA4_MAP  = 96'h000000000000000000000000;
  parameter DATA5_MAP  = 96'h000000000000000000000000;
  parameter DATA6_MAP  = 96'h000000000000000000000000;
  parameter DATA7_MAP  = 96'h000000000000000000000000;
  parameter DATA8_MAP  = 96'h000000000000000000000000;
  parameter DATA9_MAP  = 96'h000000000000000000000000;
  parameter DATA10_MAP = 96'h000000000000000000000000;
  parameter DATA11_MAP = 96'h000000000000000000000000;
  parameter DATA12_MAP = 96'h000000000000000000000000;
  parameter DATA13_MAP = 96'h000000000000000000000000;
  parameter DATA14_MAP = 96'h000000000000000000000000;
  parameter DATA15_MAP = 96'h000000000000000000000000;
  parameter DATA16_MAP = 96'h000000000000000000000000;
  parameter DATA17_MAP = 96'h000000000000000000000000;
  parameter MASK0_MAP  = 108'h000000000000000038028012001;
  parameter MASK1_MAP  = 108'h000000000000000000000000000;

  parameter SLOT_0_CONFIG         = 8'b00000001;
                                    // Mapping of Ranks.
  parameter SLOT_1_CONFIG         = 8'b0000_0000;
                                    // Mapping of Ranks.
  parameter MEM_ADDR_ORDER
    = "TG_TEST";

  //***************************************************************************
  // IODELAY and PHY related parameters
  //***************************************************************************
  parameter IODELAY_HP_MODE       = "ON";
                                    // to phy_top
  parameter IBUF_LPWR_MODE        = "OFF";
                                    // to phy_top
  parameter DATA_IO_IDLE_PWRDWN   = "OFF";
                                    // # = "ON", "OFF"
  parameter DATA_IO_PRIM_TYPE     = "DEFAULT";
                                    // # = "HP_LP", "HR_LP", "DEFAULT"
  parameter USER_REFRESH          = "OFF";
  parameter WRLVL                 = "ON";
                                    // # = "ON" - DDR3 SDRAM
                                    //   = "OFF" - DDR2 SDRAM.
  parameter ORDERING              = "NORM";
                                    // # = "NORM", "STRICT", "RELAXED".
  parameter CALIB_ROW_ADD         = 16'h0000;
                                    // Calibration row address will be used for
                                    // calibration read and write operations
  parameter CALIB_COL_ADD         = 12'h000;
                                    // Calibration column address will be used for
                                    // calibration read and write operations
  parameter CALIB_BA_ADD          = 3'h0;
                                    // Calibration bank address will be used for
                                    // calibration read and write operations
  parameter TCQ                   = 100;
  //***************************************************************************
  // IODELAY and PHY related parameters
  //***************************************************************************
  parameter IODELAY_GRP           = "IODELAY_MIG";
                                    // It is associated to a set of IODELAYs with
                                    // an IDELAYCTRL that have same IODELAY CONTROLLER
                                    // clock frequency.
  parameter SYSCLK_TYPE           = "NO_BUFFER";
                                    // System clock type DIFFERENTIAL, SINGLE_ENDED,
                                    // NO_BUFFER
  parameter REFCLK_TYPE           = "USE_SYSTEM_CLOCK";
                                    // Reference clock type DIFFERENTIAL, SINGLE_ENDED,
                                    // NO_BUFFER, USE_SYSTEM_CLOCK
  parameter RST_ACT_LOW           = 1;
                                    // =1 for active low reset,
                                    // =0 for active high.
  parameter CAL_WIDTH             = "HALF";
  parameter STARVE_LIMIT          = 2;
                                    // # = 2,3,4.

  //***************************************************************************
  // Referece clock frequency parameters
  //***************************************************************************
  parameter REFCLK_FREQ           = 200.0;
                                    // IODELAYCTRL reference clock frequency
  //***************************************************************************
  // System clock frequency parameters
  //***************************************************************************
  parameter tCK                   = 2500;
                                    // memory tCK paramter.
                    // # = Clock Period in pS.
  parameter nCK_PER_CLK           = 4;
                                    // # of memory CKs per fabric CLK



  //***************************************************************************
  // Debug and Internal parameters
  //***************************************************************************
  parameter DEBUG_PORT            = "OFF";
                                    // # = "ON" Enable debug signals/controls.
                                    //   = "OFF" Disable debug signals/controls.
  //***************************************************************************
  // Debug and Internal parameters
  //***************************************************************************
  parameter DRAM_TYPE             = "DDR3";



  //**************************************************************************//
  // Local parameters Declarations
  //**************************************************************************//

  localparam real TPROP_DQS          = 0.00;
                                       // Delay for DQS signal during Write Operation
  localparam real TPROP_DQS_RD       = 0.00;
                       // Delay for DQS signal during Read Operation
  localparam real TPROP_PCB_CTRL     = 0.00;
                       // Delay for Address and Ctrl signals
  localparam real TPROP_PCB_DATA     = 0.00;
                       // Delay for data signal during Write operation
  localparam real TPROP_PCB_DATA_RD  = 0.00;
                       // Delay for data signal during Read operation

  localparam MEMORY_WIDTH            = 8;
  localparam NUM_COMP                = DQ_WIDTH/MEMORY_WIDTH;

  localparam real REFCLK_PERIOD = (1000000.0/(2*REFCLK_FREQ));
  localparam RESET_PERIOD = 200000; //in pSec
  localparam real SYSCLK_PERIOD = tCK;


  localparam DRAM_DEVICE = "COMPS";
                         // DRAM_TYPE: "UDIMM", "RDIMM", "COMPS"
  localparam DATA_WIDTH            = 32;
  localparam PAYLOAD_WIDTH         = 32;
  localparam BURST_MODE_INTEGER = 8; //BURST_MODE = "8"

  // local test parameters
  localparam c_n_shots_width            = 16;
  localparam c_n_pre_samples_width      = 32;
  localparam c_n_post_samples_width     = 32;
  localparam c_n_chan                   = 5;
  localparam c_n_width64                = 16'd64;
  localparam c_n_width128               = 16'd128;
  //localparam c_min_wait_gnt             = 32;
  //localparam c_max_wait_gnt             = 128;
  localparam c_acq_num_channels         = 5;
  localparam [16-1:0] c_acq_channels[0:c_acq_num_channels-1] =
      '{c_n_width64, c_n_width128, c_n_width128,
      c_n_width128, c_n_width128};

  // bpm acquisition parameters
  // Must be at least the size of the biggest acquisition size
  localparam ACQ_ADDR_WIDTH         = ADDR_WIDTH;
  localparam ACQ_DATA_WIDTH         = 64;
  localparam DATA_CHECK_FIFO_SIZE   = 8192;
  localparam ACQ_FIFO_SIZE          = 4096;

  localparam DDR3_PAYLOAD_WIDTH = (BURST_MODE_INTEGER)*PAYLOAD_WIDTH;
  localparam DDR3_ADDR_INC = DDR3_PAYLOAD_WIDTH/DQ_WIDTH;

  // Tests paramaters
  reg [ACQ_DATA_WIDTH-1:0] data_test_low [c_n_chan-1:0];
  reg [16-1:0] data_test_low_0;
  reg [ACQ_DATA_WIDTH-1:0] data_test_high [c_n_chan-1:0];
  reg data_test_dvalid [c_n_chan-1:0];
  reg data_test_dvalid_t [c_n_chan-1:0];
  reg data_test_trig [c_n_chan-1:0];
  reg data_trig;
  real data_ext_stall_threshold;
  real data_ext_rdy_threshold;
  real data_valid_threshold;

  reg data_gen_start;
  reg stop_on_error;
  reg test_in_progress;
  reg test_in_progress_d0;
  reg test_in_progress_d1;
  wire test_in_progress_p;

  // Test scenario parameters
  integer test_id = 1;
  reg [c_n_shots_width-1:0] n_shots;
  reg [c_n_pre_samples_width-1:0] pre_trig_samples;
  reg [c_n_post_samples_width-1:0] post_trig_samples;
  reg [1:0] hw_trig_sel;
  reg hw_trig_en;
  reg [32-1:0] hw_trig_dly;
  reg [32-1:0] hw_int_trig_thres;
  reg [7:0] hw_int_trig_thres_filt;
  reg sw_trig_en;
  reg [32-1:0] ddr3_start_addr;
  reg [32-1:0] ddr3_end_addr;
  reg [16-1:0] acq_chan;
  reg [32-1:0] lmt_pkt_size;
  reg skip_trig;
  reg wait_finish;
  real data_valid_prob;
  integer min_wait_gnt;
  integer max_wait_gnt;
  integer min_wait_gnt_l;
  integer max_wait_gnt_l;
  integer min_wait_trig;
  integer max_wait_trig;
  integer min_wait_trig_l;
  integer max_wait_trig_l;

  // Core registers
  reg [31:0] acq_core_fsm_ctl_reg = 'h0;
  reg [31:0] acq_core_fsm_sta_reg = 'h0;

  // DDR3 signals
  wire                                      ddr3_reset_n;
  wire [DQ_WIDTH-1:0]                       ddr3_dq_fpga;
  wire [DQS_WIDTH-1:0]                      ddr3_dqs_p_fpga;
  wire [DQS_WIDTH-1:0]                      ddr3_dqs_n_fpga;
  wire [ROW_WIDTH-1:0]                      ddr3_addr_fpga;
  wire [BANK_WIDTH-1:0]                     ddr3_ba_fpga;
  wire                                      ddr3_ras_n_fpga;
  wire                                      ddr3_cas_n_fpga;
  wire                                      ddr3_we_n_fpga;
  wire [CKE_WIDTH-1:0]                      ddr3_cke_fpga;
  wire [CK_WIDTH-1:0]                       ddr3_ck_p_fpga;
  wire [CK_WIDTH-1:0]                       ddr3_ck_n_fpga;


  wire                                      init_calib_complete;
  wire                                      tg_compare_error;
  wire [(CS_WIDTH*nCS_PER_RANK)-1:0]        ddr3_cs_n_fpga;
  wire [DM_WIDTH-1:0]                       ddr3_dm_fpga;
  wire [ODT_WIDTH-1:0]                      ddr3_odt_fpga;

  reg [(CS_WIDTH*nCS_PER_RANK)-1:0]         ddr3_cs_n_sdram_tmp;
  reg [DM_WIDTH-1:0]                        ddr3_dm_sdram_tmp;
  reg [ODT_WIDTH-1:0]                       ddr3_odt_sdram_tmp;

  wire [DQ_WIDTH-1:0]                       ddr3_dq_sdram;
  reg [ROW_WIDTH-1:0]                       ddr3_addr_sdram [0:1];
  reg [BANK_WIDTH-1:0]                      ddr3_ba_sdram [0:1];
  reg                                       ddr3_ras_n_sdram;
  reg                                       ddr3_cas_n_sdram;
  reg                                       ddr3_we_n_sdram;
  wire [(CS_WIDTH*nCS_PER_RANK)-1:0]        ddr3_cs_n_sdram;
  wire [ODT_WIDTH-1:0]                      ddr3_odt_sdram;
  reg [CKE_WIDTH-1:0]                       ddr3_cke_sdram;
  wire [DM_WIDTH-1:0]                       ddr3_dm_sdram;
  wire [DQS_WIDTH-1:0]                      ddr3_dqs_p_sdram;
  wire [DQS_WIDTH-1:0]                      ddr3_dqs_n_sdram;
  reg [CK_WIDTH-1:0]                        ddr3_ck_p_sdram;
  reg [CK_WIDTH-1:0]                        ddr3_ck_n_sdram;

  reg                                       ddr_sys_clk_i;
  reg                                       clk_ref_i;

  // External interface signals
  wire [DDR3_PAYLOAD_WIDTH-1:0]            ext0_dout;
  wire [ADDR_WIDTH-1:0]                    ext0_addr;
  wire                                     ext0_valid;
  wire                                     ext0_sof;
  wire                                     ext0_eof;

  wire [DDR3_PAYLOAD_WIDTH-1:0]            ext0_dout_conv;
  wire [ADDR_WIDTH-1:0]                    ext0_addr_conv;
  wire                                     ext0_valid_conv;

  wire [DDR3_PAYLOAD_WIDTH-1:0]            ext1_dout;
  wire [ADDR_WIDTH-1:0]                    ext1_addr;
  wire                                     ext1_valid;
  wire                                     ext1_sof;
  wire                                     ext1_eof;

  wire [DDR3_PAYLOAD_WIDTH-1:0]            ext1_dout_conv;
  wire [ADDR_WIDTH-1:0]                    ext1_addr_conv;
  wire                                     ext1_valid_conv;

  wire [DDR3_PAYLOAD_WIDTH-1:0]            ext_dout_conv_rb;
  wire [ADDR_WIDTH-1:0]                    ext_addr_conv_rb;
  wire                                     ext_valid_conv;

  // DDR3 Controller UI interface signals

  wire                                      ui_app_wdf_wren;
  wire [DDR3_PAYLOAD_WIDTH-1:0]
                        ui_app_wdf_data;
  wire [DDR3_PAYLOAD_WIDTH/8-1:0]
                        ui_app_wdf_mask;
  wire                                      ui_app_wdf_end;
  wire [ADDR_WIDTH-1:0]                     ui_app_addr;
  wire [2:0]                                ui_app_cmd;
  wire                                      ui_app_en;
  wire                                      ui_app_rdy;
  wire                                      ui_app_wdf_rdy;
  wire                                      ui_app_rdy_ddr;
  wire                                      ui_app_wdf_rdy_ddr;
  wire [DDR3_PAYLOAD_WIDTH-1:0]
                        ui_app_rd_data;
  wire                                      ui_app_rd_data_end;
  wire                                      ui_app_rd_data_valid;
  wire                                      ui_clk_sync_rst;
  wire                                      ui_clk_sync_rst_n;
  wire                                      ui_clk;
  wire                                      ui_phy_init_done;
  wire                                      ui_app_req;
  reg                                       ui_app_gnt;

  // Debug/Readback signals
  wire [(BURST_MODE_INTEGER)*DATA_WIDTH-1:0] dbg_ddr_rb0_data;
  wire [ADDR_WIDTH-1:0]                     dbg_ddr_rb0_addr;
  wire                                      dbg_ddr_rb0_valid;
  wire                                      dbg_ddr_rb0_start_p;
  wire                                      dbg_ddr_rb0_rdy;
  reg                                       dbg_ddr_rb0_rdy_d0;
  reg                                       dbg_ddr_rb0_rdy_d1;
  reg                       dbg_ddr_rb0_in_progress;

  wire [(BURST_MODE_INTEGER)*DATA_WIDTH-1:0] dbg_ddr_rb1_data;
  wire [ADDR_WIDTH-1:0]                     dbg_ddr_rb1_addr;
  wire                                      dbg_ddr_rb1_valid;
  wire                                      dbg_ddr_rb1_start_p;
  wire                                      dbg_ddr_rb1_rdy;
  reg                                       dbg_ddr_rb1_rdy_d0;
  reg                                       dbg_ddr_rb1_rdy_d1;
  reg                                       dbg_ddr_rb1_in_progress;

  wire                                      chk0_data_err;
  wire [16-1:0]                             chk0_data_err_cnt;
  wire                                      chk0_addr_err;
  wire [16-1:0]                             chk0_addr_err_cnt;
  wire                                      chk0_end;
  wire                                      chk0_pass;

  wire                                      chk1_data_err;
  wire [16-1:0]                             chk1_data_err_cnt;
  wire                                      chk1_addr_err;
  wire [16-1:0]                             chk1_addr_err_cnt;
  wire                                      chk1_end;
  wire                                      chk1_pass;

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

  WB_TEST_MASTER WB0(
    .wb_clk                                 (sys_clk)
  );

  WB_TEST_MASTER WB1(
    .wb_clk                                 (sys_clk)
  );

  // DUT
  wb_acq_core_2_to_1_mux_plain #(
    .g_ddr_addr_width(ADDR_WIDTH),
    .g_acq_addr_width(ADDR_WIDTH),
    .g_fifo_fc_size(ACQ_FIFO_SIZE),
    .g_ddr_payload_width(DDR3_PAYLOAD_WIDTH),
    .g_ddr_dq_width(PAYLOAD_WIDTH),
    //.g_acq_num_channels(c_acq_num_channels),
    //.g_acq_channels(c_acq_channels),
    .g_sim_readback(1)
  )
  dut (

    .fs1_clk_i                              (adc_clk),
    .fs1_ce_i                               (1'b1),
    .fs1_rst_n_i                            (adc_rstn),

    .fs2_clk_i                              (adc_clk),
    .fs2_ce_i                               (1'b1),
    .fs2_rst_n_i                            (adc_rstn),

    .sys_clk_i                              (sys_clk),
    .sys_rst_n_i                            (sys_rstn),

    .ext_clk_i                              (ui_clk),
    .ext_rst_n_i                            (ui_clk_sync_rst_n),

    .wb0_adr_i                              (WB0.wb_addr),
    .wb0_dat_i                              (WB0.wb_data_o),
    .wb0_dat_o                              (WB0.wb_data_i),
    .wb0_cyc_i                              (WB0.wb_cyc),
    .wb0_sel_i                              (WB0.wb_bwsel),
    .wb0_stb_i                              (WB0.wb_stb),
    .wb0_we_i                               (WB0.wb_we),
    .wb0_ack_o                              (WB0.wb_ack_i),
    .wb0_err_o                              (),
    .wb0_rty_o                              (),
    .wb0_stall_o                            (),

    .wb1_adr_i                              (WB1.wb_addr),
    .wb1_dat_i                              (WB1.wb_data_o),
    .wb1_dat_o                              (WB1.wb_data_i),
    .wb1_cyc_i                              (WB1.wb_cyc),
    .wb1_sel_i                              (WB1.wb_bwsel),
    .wb1_stb_i                              (WB1.wb_stb),
    .wb1_we_i                               (WB1.wb_we),
    .wb1_ack_o                              (WB1.wb_ack_i),
    .wb1_err_o                              (),
    .wb1_rty_o                              (),
    .wb1_stall_o                            (),

    .acq0_val_low_i                         ({data_test_low[4], data_test_low[3], data_test_low[2],
                                             data_test_low[1], data_test_low[0]}),
    .acq0_val_high_i                        ({data_test_high[4], data_test_high[3], data_test_high[2],
                                             data_test_high[1], data_test_high[0]}),
    .acq0_dvalid_i                          ({data_test_dvalid[4], data_test_dvalid[3], data_test_dvalid[2],
                                             data_test_dvalid[1], data_test_dvalid[0]}),
    .acq0_trig_i                            ({data_test_trig[4], data_test_trig[3], data_test_trig[2],
                                             data_test_trig[1], data_test_trig[0]}),

    .acq1_val_low_i                         ({data_test_low[4] + c_ddr3_acq1_data_offset, data_test_low[3] + c_ddr3_acq1_data_offset,
                                                data_test_low[2] + c_ddr3_acq1_data_offset, data_test_low[1] + c_ddr3_acq1_data_offset,
                                                data_test_low[0] + c_ddr3_acq1_data_offset}),
    .acq1_val_high_i                        ({data_test_high[4] + c_ddr3_acq1_data_offset, data_test_high[3] + c_ddr3_acq1_data_offset,
                                                data_test_high[2] + c_ddr3_acq1_data_offset, data_test_high[1] + c_ddr3_acq1_data_offset,
                                                data_test_high[0] + c_ddr3_acq1_data_offset}),
    .acq1_dvalid_i                          ({data_test_dvalid[4], data_test_dvalid[3], data_test_dvalid[2],
                                             data_test_dvalid[1], data_test_dvalid[0]}),
    .acq1_trig_i                            ({data_test_trig[4], data_test_trig[3], data_test_trig[2],
                                             data_test_trig[1], data_test_trig[0]}),

    .dpram0_dout_o                          (),
    .dpram0_valid_o                         (),

    .dpram1_dout_o                          (),
    .dpram1_valid_o                         (),

    .ext0_dout_o                            (ext0_dout),
    .ext0_valid_o                           (ext0_valid),
    // This is just for debug. It does not epresent the actual address written
    // to DDR3 controller. The later is determined by the "acq_ddr3_iface" module
    // considering only the "ddr3_start_addr" signal
    .ext0_addr_o                            (ext0_addr),
    .ext0_sof_o                             (ext0_sof),
    .ext0_eof_o                             (ext0_eof),
    .ext0_dreq_o                            (ext0_dreq),
    .ext0_stall_o                           (ext0_stall),

    .ext1_dout_o                            (ext1_dout),
    .ext1_valid_o                           (ext1_valid),
    // This is just for debug. It does not epresent the actual address written
    // to DDR3 controller. The later is determined by the "acq_ddr3_iface" module
    // considering only the "ddr3_start_addr" signal
    .ext1_addr_o                            (ext1_addr),
    .ext1_sof_o                             (ext1_sof),
    .ext1_eof_o                             (ext1_eof),
    .ext1_dreq_o                            (ext1_dreq),
    .ext1_stall_o                           (ext1_stall),

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
    .dbg_ddr_rb0_start_p_i                  (dbg_ddr_rb0_start_p),
    .dbg_ddr_rb0_rdy_o                      (dbg_ddr_rb0_rdy),
    .dbg_ddr_rb0_data_o                     (dbg_ddr_rb0_data),
    .dbg_ddr_rb0_addr_o                     (dbg_ddr_rb0_addr),
    .dbg_ddr_rb0_valid_o                    (dbg_ddr_rb0_valid),

    .dbg_ddr_rb1_start_p_i                  (dbg_ddr_rb1_start_p),
    .dbg_ddr_rb1_rdy_o                      (dbg_ddr_rb1_rdy),
    .dbg_ddr_rb1_data_o                     (dbg_ddr_rb1_data),
    .dbg_ddr_rb1_addr_o                     (dbg_ddr_rb1_addr),
    .dbg_ddr_rb1_valid_o                    (dbg_ddr_rb1_valid)
  );

  // Very simple req and gnt driving

  always @(posedge ui_clk) begin
    if (~ui_clk_sync_rst_n) begin
      ui_app_gnt <= 1'b0;
    end else begin
      if (ui_app_req & ~ui_app_gnt) begin
        repeat(f_gen_lmt(min_wait_gnt, max_wait_gnt)) // waits between c_min_wait_gnt and c_max_wait_gnt
          @(posedge ui_clk);

        ui_app_gnt <= 1'b1;
      end else if (~ui_app_req) begin
        ui_app_gnt <= 1'b0;
      end
    end
  end

  // Very simple software trigger driving

  always @(posedge adc_clk) begin
    if (~adc_rstn) begin
      data_trig <= 1'b0;
    end else begin
      // allow for retrigger in the same acquistion
      if (test_in_progress) begin
        if (~data_trig) begin
          repeat(f_gen_lmt(min_wait_trig, max_wait_trig)) // waits between c_min_wait_trig and c_max_wait_trig
            @(posedge adc_clk);

          data_trig = 1'b1;
        end else begin
          data_trig <= 1'b0;
        end
      end
      else begin
        data_trig <= 1'b0;
      end
    end
  end

  // Very simple dbg_ddr_rb_start_p and dbg_ddr_rb_rdy

  // WB acq core 0
  always @(posedge ui_clk) begin
    if (~ui_clk_sync_rst_n) begin
      dbg_ddr_rb0_rdy_d0 <= 1'b0;
      dbg_ddr_rb0_rdy_d1 <= 1'b0;
      dbg_ddr_rb0_in_progress <= 1'b0;
    end else begin
      dbg_ddr_rb0_rdy_d0 <= dbg_ddr_rb0_rdy;
      dbg_ddr_rb0_rdy_d1 <= dbg_ddr_rb0_rdy_d0;

      if (dbg_ddr_rb0_start_p) begin
        dbg_ddr_rb0_in_progress <= 1'b1;
      end
    end
  end

  // Detect level and generate pulse
  assign dbg_ddr_rb0_start_p = dbg_ddr_rb0_rdy_d0 & ~dbg_ddr_rb0_rdy_d1;

  // WB acq core 1
  always @(posedge ui_clk) begin
    if (~ui_clk_sync_rst_n | ~test_in_progress) begin
      dbg_ddr_rb1_rdy_d0 <= 1'b0;
      dbg_ddr_rb1_rdy_d1 <= 1'b0;
      dbg_ddr_rb1_in_progress <= 1'b0;
    end else begin
      dbg_ddr_rb1_rdy_d0 <= dbg_ddr_rb1_rdy & chk0_end;
      dbg_ddr_rb1_rdy_d1 <= dbg_ddr_rb1_rdy_d0;

      if (dbg_ddr_rb1_start_p) begin
        dbg_ddr_rb1_in_progress <= 1'b1;
      end
    end
  end

  // Detect level and generate pulse
  assign dbg_ddr_rb1_start_p = dbg_ddr_rb1_rdy_d0 & ~dbg_ddr_rb1_rdy_d1;

  // In our use case, the lines ui_app_rdy and ui_app_wdf_rdy are only high
  // if the DDR core drives it high AND if the PCIe arbiter grants us. So,
  // we emulate this behavior here
  assign ui_app_rdy = ui_app_rdy_ddr & ui_app_gnt;
  assign ui_app_wdf_rdy = ui_app_wdf_rdy_ddr & ui_app_gnt;

  //// Test in progress pulse
  //always @(posedge adc_clk) begin
  //  if (~adc_rstn) begin
  //    test_in_progress_d0 <= 1'b0;
  //    test_in_progress_d1 <= 1'b0;
  //  end else begin
  //    test_in_progress_d0 <= test_in_progress;
  //    test_in_progress_d1 <= test_in_progress_d0;
  //  end
  //end

  //// Detect level and generate pulse
  //assign test_in_progress_p = test_in_progress_d0 & ~test_in_progress_d1;

  //**************************************************************************//
  // Data readback checker instantiation
  //**************************************************************************//
  data_checker #(.g_addr_width(ADDR_WIDTH),
                        .g_data_width(DDR3_PAYLOAD_WIDTH),
                        .g_fifo_size(DATA_CHECK_FIFO_SIZE)
                    )
  cmp0_data_checker(
    .ext_clk_i                              (ui_clk),
    .ext_rst_n_i                            (ui_clk_sync_rst_n & test_in_progress),

    // Expected data
    .exp_din_i                              (ext0_dout_conv),
     // This is just for debug. It does not epresent the actual address written
     // to DDR3 controller. The later is determined by the "acq_ddr3_iface" module
     // considering only the "ddr3_start_addr" signal
    .exp_addr_i                             (ext0_addr_conv),
    .exp_valid_i                            (ext0_valid & ~ext0_stall),

    // Actual data
    .act_din_i                              (dbg_ddr_rb0_data),
    .act_addr_i                             (dbg_ddr_rb0_addr),
    .act_valid_i                            (dbg_ddr_rb0_valid & dbg_ddr_rb0_in_progress),

    // Size of the transaction in g_fifo_size bytes
    .lmt_pkt_size_i                         (lmt_pkt_size),
    // Number of shots in this acquisition
    .lmt_shots_nb_i                         (n_shots),
    // Acquisition limits valid signal. Qualifies lmt_fifo_pkt_size_i and lmt_shots_nb_i
    .lmt_valid_i                            (test_in_progress),

    .chk_data_err_o                         (chk0_data_err),
    .chk_data_err_cnt_o                     (chk0_data_err_cnt),
    .chk_addr_err_o                         (chk0_addr_err),
    .chk_addr_err_cnt_o                     (chk0_addr_err_cnt),
    .chk_end_o                              (chk0_end),
    .chk_pass_o                             (chk0_pass)
  );

  ////////assign dbg_ddr_rb_data_conv_rb    = dbg_ddr_rb0_data : dbg_ddr_rb1_data;
  ////////assign dbg_ddr_rb_addr_conv_rb    = dbg_ddr_rb0_addr : dbg_ddr_rb1_addr;
  ////////assign dbg_ddr_rb_valid_conv_rb   = dbg_ddr_rb0_valid : dbg_ddr_rb1_valid;

  assign ext0_dout_conv  = ext0_dout;
  assign ext0_valid_conv = ext0_valid;
  assign ext0_addr_conv  = ext0_addr*DDR3_ADDR_INC;

  data_checker #(.g_addr_width(ADDR_WIDTH),
                        .g_data_width(DDR3_PAYLOAD_WIDTH),
                        .g_fifo_size(DATA_CHECK_FIFO_SIZE)
                    )
  cmp1_data_checker(
    .ext_clk_i                              (ui_clk),
    .ext_rst_n_i                            (ui_clk_sync_rst_n & test_in_progress),

    // Expected data
    .exp_din_i                              (ext1_dout_conv),
     // This is just for debug. It does not epresent the actual address written
     // to DDR3 controller. The later is determined by the "acq_ddr3_iface" module
     // considering only the "ddr3_start_addr" signal
    .exp_addr_i                             (ext1_addr_conv),
    .exp_valid_i                            (ext1_valid & ~ext1_stall),

    // Actual data
    .act_din_i                              (dbg_ddr_rb1_data),
    .act_addr_i                             (dbg_ddr_rb1_addr),
    .act_valid_i                            (dbg_ddr_rb1_valid & dbg_ddr_rb1_in_progress),

    // Size of the transaction in g_fifo_size bytes
    .lmt_pkt_size_i                         (lmt_pkt_size),
    // Number of shots in this acquisition
    .lmt_shots_nb_i                         (n_shots),
    // Acquisition limits valid signal. Qualifies lmt_fifo_pkt_size_i and lmt_shots_nb_i
    .lmt_valid_i                            (test_in_progress),

    .chk_data_err_o                         (chk1_data_err),
    .chk_data_err_cnt_o                     (chk1_data_err_cnt),
    .chk_addr_err_o                         (chk1_addr_err),
    .chk_addr_err_cnt_o                     (chk1_addr_err_cnt),
    .chk_end_o                              (chk1_end),
    .chk_pass_o                             (chk1_pass)
  );

  assign ext1_dout_conv  = ext1_dout;
  assign ext1_valid_conv = ext1_valid;
  assign ext1_addr_conv  = ext1_addr*DDR3_ADDR_INC + c_ddr3_acq1_addr_offset;

  ///////assign ext1_dout_conv_rb  = c_ddr3_acq1_addr_offset ? ext0_dout : ext1_dout;
  ///////assign ext1_valid_conv_rb = ext0_valid : ext1_valid;
  ///////assign ext1_addr_conv_rb  = ext0_addr*DDR3_ADDR_INC : ext1_addr*DDR3_ADDR_INC;

  //**************************************************************************//
  // DDR3 ARTIX7 Controller instantiation
  //**************************************************************************//
  ddr_core_wrapper # (
    .SIMULATION                (SIMULATION),

    //.BANK_WIDTH                (BANK_WIDTH),
    //.CK_WIDTH                  (CK_WIDTH),
    //.COL_WIDTH                 (COL_WIDTH),
    //.CS_WIDTH                  (CS_WIDTH),
    //.nCS_PER_RANK              (nCS_PER_RANK),
    //.CKE_WIDTH                 (CKE_WIDTH),
    //.DATA_BUF_ADDR_WIDTH       (DATA_BUF_ADDR_WIDTH),
    //.DQ_CNT_WIDTH              (DQ_CNT_WIDTH),
    //.DQ_PER_DM                 (DQ_PER_DM),
    //.DM_WIDTH                  (DM_WIDTH),

    //.DQ_WIDTH                  (DQ_WIDTH),
    //.DQS_WIDTH                 (DQS_WIDTH),
    //.DQS_CNT_WIDTH             (DQS_CNT_WIDTH),
    //.DRAM_WIDTH                (DRAM_WIDTH),
    //.ECC                       (ECC),
    //.nBANK_MACHS               (nBANK_MACHS),
    //.RANKS                     (RANKS),
    //.ODT_WIDTH                 (ODT_WIDTH),
    //.ROW_WIDTH                 (ROW_WIDTH),
    //.ADDR_WIDTH                (ADDR_WIDTH),
    //.USE_CS_PORT               (USE_CS_PORT),
    //.USE_DM_PORT               (USE_DM_PORT),
    //.USE_ODT_PORT              (USE_ODT_PORT),

    //.AL                        (AL),
    //.nAL                       (nAL),
    //.BURST_MODE                (BURST_MODE),
    //.BURST_TYPE                (BURST_TYPE),
    //.CL                        (CL),
    //.CWL                       (CWL),
    //.OUTPUT_DRV                (OUTPUT_DRV),
    //.RTT_NOM                   (RTT_NOM),
    //.RTT_WR                    (RTT_WR),
    //.ADDR_CMD_MODE             (ADDR_CMD_MODE),
    //.REG_CTRL                  (REG_CTRL),
    //.CA_MIRROR                 (CA_MIRROR),


    //.CLKIN_PERIOD              (CLKIN_PERIOD),
    //.CLKFBOUT_MULT             (CLKFBOUT_MULT),
    //.DIVCLK_DIVIDE             (DIVCLK_DIVIDE),
    //.CLKOUT0_DIVIDE            (CLKOUT0_DIVIDE),
    //.CLKOUT1_DIVIDE            (CLKOUT1_DIVIDE),
    //.CLKOUT2_DIVIDE            (CLKOUT2_DIVIDE),
    //.CLKOUT3_DIVIDE            (CLKOUT3_DIVIDE),


    //.tCKE                      (tCKE),
    //.tFAW                      (tFAW),
    //.tRAS                      (tRAS),
    //.tRCD                      (tRCD),
    //.tREFI                     (tREFI),
    //.tRFC                      (tRFC),
    //.tRP                       (tRP),
    //.tRRD                      (tRRD),
    //.tRTP                      (tRTP),
    //.tWTR                      (tWTR),
    //.tZQI                      (tZQI),
    //.tZQCS                     (tZQCS),

    .SIM_BYPASS_INIT_CAL       (SIM_BYPASS_INIT_CAL),

    //.BYTE_LANES_B0             (BYTE_LANES_B0),
    //.BYTE_LANES_B1             (BYTE_LANES_B1),
    //.BYTE_LANES_B2             (BYTE_LANES_B2),
    //.BYTE_LANES_B3             (BYTE_LANES_B3),
    //.BYTE_LANES_B4             (BYTE_LANES_B4),
    //.DATA_CTL_B0               (DATA_CTL_B0),
    //.DATA_CTL_B1               (DATA_CTL_B1),
    //.DATA_CTL_B2               (DATA_CTL_B2),
    //.DATA_CTL_B3               (DATA_CTL_B3),
    //.DATA_CTL_B4               (DATA_CTL_B4),
    //.PHY_0_BITLANES            (PHY_0_BITLANES),
    //.PHY_1_BITLANES            (PHY_1_BITLANES),
    //.PHY_2_BITLANES            (PHY_2_BITLANES),
    //.CK_BYTE_MAP               (CK_BYTE_MAP),
    //.ADDR_MAP                  (ADDR_MAP),
    //.BANK_MAP                  (BANK_MAP),
    //.CAS_MAP                   (CAS_MAP),
    //.CKE_ODT_BYTE_MAP          (CKE_ODT_BYTE_MAP),
    //.CKE_MAP                   (CKE_MAP),
    //.ODT_MAP                   (ODT_MAP),
    //.CS_MAP                    (CS_MAP),
    //.PARITY_MAP                (PARITY_MAP),
    //.RAS_MAP                   (RAS_MAP),
    //.WE_MAP                    (WE_MAP),
    //.DQS_BYTE_MAP              (DQS_BYTE_MAP),
    //.DATA0_MAP                 (DATA0_MAP),
    //.DATA1_MAP                 (DATA1_MAP),
    //.DATA2_MAP                 (DATA2_MAP),
    //.DATA3_MAP                 (DATA3_MAP),
    //.DATA4_MAP                 (DATA4_MAP),
    //.DATA5_MAP                 (DATA5_MAP),
    //.DATA6_MAP                 (DATA6_MAP),
    //.DATA7_MAP                 (DATA7_MAP),
    //.DATA8_MAP                 (DATA8_MAP),
    //.DATA9_MAP                 (DATA9_MAP),
    //.DATA10_MAP                (DATA10_MAP),
    //.DATA11_MAP                (DATA11_MAP),
    //.DATA12_MAP                (DATA12_MAP),
    //.DATA13_MAP                (DATA13_MAP),
    //.DATA14_MAP                (DATA14_MAP),
    //.DATA15_MAP                (DATA15_MAP),
    //.DATA16_MAP                (DATA16_MAP),
    //.DATA17_MAP                (DATA17_MAP),
    //.MASK0_MAP                 (MASK0_MAP),
    //.MASK1_MAP                 (MASK1_MAP),
    //.SLOT_0_CONFIG             (SLOT_0_CONFIG),
    //.SLOT_1_CONFIG             (SLOT_1_CONFIG),
    //.MEM_ADDR_ORDER            (MEM_ADDR_ORDER),

    //.IODELAY_HP_MODE           (IODELAY_HP_MODE),
    //.IBUF_LPWR_MODE            (IBUF_LPWR_MODE),
    //.DATA_IO_IDLE_PWRDWN       (DATA_IO_IDLE_PWRDWN),
    //.DATA_IO_PRIM_TYPE         (DATA_IO_PRIM_TYPE),
    //.USER_REFRESH              (USER_REFRESH),
    //.WRLVL                     (WRLVL),
    //.ORDERING                  (ORDERING),
    //.CALIB_ROW_ADD             (CALIB_ROW_ADD),
    //.CALIB_COL_ADD             (CALIB_COL_ADD),
    //.CALIB_BA_ADD              (CALIB_BA_ADD),
    //.TCQ                       (TCQ),


    //.IODELAY_GRP               (IODELAY_GRP),
    //.SYSCLK_TYPE               (SYSCLK_TYPE),
    //.REFCLK_TYPE               (REFCLK_TYPE),
    //.DRAM_TYPE                 (DRAM_TYPE),
    //.CAL_WIDTH                 (CAL_WIDTH),
    //.STARVE_LIMIT              (STARVE_LIMIT),


    //.REFCLK_FREQ               (REFCLK_FREQ),


    //.tCK                       (tCK),
    //.nCK_PER_CLK               (nCK_PER_CLK),


    //.DEBUG_PORT                (DEBUG_PORT),

    .RST_ACT_LOW               (RST_ACT_LOW)
  )
  cmp_ddr_core_wrapper (
     // System Clock Ports
    .sys_clk_i                              (ddr3_sys_clk),
    .sys_rst                                (ddr3_sys_rstn), // RST_ACT_LOW = 1

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

    // Application interface ports
    //.app_wdf_wren                           (ui_app_wdf_wren),
    // Only accept transaction if access to the DDR3 controller was granted
    // before
    .app_wdf_wren                           (ui_app_wdf_wren & ui_app_gnt),
    .app_wdf_data                           (ui_app_wdf_data),
    .app_wdf_mask                           (ui_app_wdf_mask),
    .app_wdf_end                            (ui_app_wdf_end),
    .app_addr                               (ui_app_addr),
    .app_cmd                                (ui_app_cmd),
    //.app_en                                 (ui_app_en),
    // Only accept transaction if access to the DDR3 controller was granted
    // before
    .app_en                                 (ui_app_en & ui_app_gnt),
    .app_rdy                                (ui_app_rdy_ddr),
    .app_wdf_rdy                            (ui_app_wdf_rdy_ddr),
    .app_rd_data                            (ui_app_rd_data),
    .app_rd_data_end                        (ui_app_rd_data_end),
    .app_rd_data_valid                      (ui_app_rd_data_valid),
    .app_sr_req                             (1'b0),
    .app_ref_req                            (1'b0),
    .app_zq_req                             (1'b0),
    .ui_clk_sync_rst                        (ui_clk_sync_rst),
    .ui_clk                                 (ui_clk),
    .init_calib_complete                    (ui_phy_init_done)
  );

  assign ui_clk_sync_rst_n = ~ui_clk_sync_rst;

  //**************************************************************************//
  // Memory Models instantiations
  //**************************************************************************//

  genvar r,i;
  generate
    for (r = 0; r < CS_WIDTH; r = r + 1) begin: mem_rnk
      for (i = 0; i < NUM_COMP; i = i + 1) begin: gen_mem
        ddr3_model u_comp_ddr3
          (
           .rst_n   (ddr3_reset_n),
           .ck      (ddr3_ck_p_sdram),
           .ck_n    (ddr3_ck_n_sdram),
           .cke     (ddr3_cke_sdram[r]),
           .cs_n    (ddr3_cs_n_sdram[r]),
           .ras_n   (ddr3_ras_n_sdram),
           .cas_n   (ddr3_cas_n_sdram),
           .we_n    (ddr3_we_n_sdram),
           .dm_tdqs (ddr3_dm_sdram[i]),
           .ba      (ddr3_ba_sdram[r]),
           .addr    (ddr3_addr_sdram[r]),
           .dq      (ddr3_dq_sdram[MEMORY_WIDTH*(i+1)-1:MEMORY_WIDTH*(i)]),
           .dqs     (ddr3_dqs_p_sdram[i]),
           .dqs_n   (ddr3_dqs_n_sdram[i]),
           .tdqs_n  (),
           .odt     (ddr3_odt_sdram[r])
           );
      end
    end
  endgenerate

  //**************************************************************************//
  // DDR controller <--> DDR model Logic
  //**************************************************************************//

  //assign init_calib_complete = 1'b1;
  assign init_calib_complete = ui_phy_init_done;

  always @( * ) begin
    ddr3_ck_p_sdram      <=  #(TPROP_PCB_CTRL) ddr3_ck_p_fpga;
    ddr3_ck_n_sdram      <=  #(TPROP_PCB_CTRL) ddr3_ck_n_fpga;
    ddr3_addr_sdram[0]   <=  #(TPROP_PCB_CTRL) ddr3_addr_fpga;
    ddr3_addr_sdram[1]   <=  #(TPROP_PCB_CTRL) (CA_MIRROR == "ON") ?
                                                 {ddr3_addr_fpga[ROW_WIDTH-1:9],
                                                  ddr3_addr_fpga[7], ddr3_addr_fpga[8],
                                                  ddr3_addr_fpga[5], ddr3_addr_fpga[6],
                                                  ddr3_addr_fpga[3], ddr3_addr_fpga[4],
                                                  ddr3_addr_fpga[2:0]} :
                                                 ddr3_addr_fpga;
    ddr3_ba_sdram[0]     <=  #(TPROP_PCB_CTRL) ddr3_ba_fpga;
    ddr3_ba_sdram[1]     <=  #(TPROP_PCB_CTRL) (CA_MIRROR == "ON") ?
                                                 {ddr3_ba_fpga[BANK_WIDTH-1:2],
                                                  ddr3_ba_fpga[0],
                                                  ddr3_ba_fpga[1]} :
                                                 ddr3_ba_fpga;
    ddr3_ras_n_sdram     <=  #(TPROP_PCB_CTRL) ddr3_ras_n_fpga;
    ddr3_cas_n_sdram     <=  #(TPROP_PCB_CTRL) ddr3_cas_n_fpga;
    ddr3_we_n_sdram      <=  #(TPROP_PCB_CTRL) ddr3_we_n_fpga;
    ddr3_cke_sdram       <=  #(TPROP_PCB_CTRL) ddr3_cke_fpga;
  end


  always @( * )
    ddr3_cs_n_sdram_tmp   <=  #(TPROP_PCB_CTRL) ddr3_cs_n_fpga;
  assign ddr3_cs_n_sdram =  ddr3_cs_n_sdram_tmp;


  always @( * )
    ddr3_dm_sdram_tmp <=  #(TPROP_PCB_DATA) ddr3_dm_fpga;//DM signal generation
  assign ddr3_dm_sdram = ddr3_dm_sdram_tmp;


  always @( * )
    ddr3_odt_sdram_tmp  <=  #(TPROP_PCB_CTRL) ddr3_odt_fpga;
  assign ddr3_odt_sdram =  ddr3_odt_sdram_tmp;


  assign sys_rst_n = sys_rstn;
// Controlling the bi-directional BUS

  genvar dqwd;
  generate
    for (dqwd = 1;dqwd < DQ_WIDTH;dqwd = dqwd+1) begin : dq_delay
      WireDelay #
       (
        .Delay_g    (TPROP_PCB_DATA),
        .Delay_rd   (TPROP_PCB_DATA_RD),
        .ERR_INSERT ("OFF")
       )
      u_delay_dq
       (
        .A             (ddr3_dq_fpga[dqwd]),
        .B             (ddr3_dq_sdram[dqwd]),
        .reset         (sys_rst_n),
        .phy_init_done (init_calib_complete)
       );
    end
    // For ECC ON case error is inserted on LSB bit from DRAM to FPGA
          WireDelay #
       (
        .Delay_g    (TPROP_PCB_DATA),
        .Delay_rd   (TPROP_PCB_DATA_RD),
        .ERR_INSERT (ECC)
       )
      u_delay_dq_0
       (
        .A             (ddr3_dq_fpga[0]),
        .B             (ddr3_dq_sdram[0]),
        .reset         (sys_rst_n),
        .phy_init_done (init_calib_complete)
       );
  endgenerate

  genvar dqswd;
  generate
    for (dqswd = 0;dqswd < DQS_WIDTH;dqswd = dqswd+1) begin : dqs_delay
      WireDelay #
       (
        .Delay_g    (TPROP_DQS),
        .Delay_rd   (TPROP_DQS_RD),
        .ERR_INSERT ("OFF")
       )
      u_delay_dqs_p
       (
        .A             (ddr3_dqs_p_fpga[dqswd]),
        .B             (ddr3_dqs_p_sdram[dqswd]),
        .reset         (sys_rst_n),
        .phy_init_done (init_calib_complete)
       );

      WireDelay #
       (
        .Delay_g    (TPROP_DQS),
        .Delay_rd   (TPROP_DQS_RD),
        .ERR_INSERT ("OFF")
       )
      u_delay_dqs_n
       (
        .A             (ddr3_dqs_n_fpga[dqswd]),
        .B             (ddr3_dqs_n_sdram[dqswd]),
        .reset         (sys_rst_n),
        .phy_init_done (init_calib_complete)
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
    // Default values. No wait
    min_wait_gnt = 0;
    max_wait_gnt = 0;
    // Default values. 200 ADC CLK cycles after star wait
    min_wait_trig = 200;
    max_wait_trig = 200;

    $display("-----------------------------------");
    $display("@%0d: Simulation of BPM ACQ FSM starting!", $time);
    $display("-----------------------------------");

    $display("-----------------------------------");
    $display("@%0d: Initialization  Begin", $time);
    $display("-----------------------------------");

    $display("-----------------------------------");
    $display("@%0d: Waiting for all resets...", $time);
    $display("-----------------------------------");

    wait (WB0.ready);
    wait (WB1.ready);
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
    ddr3_end_addr = 32'h00001000;
    acq_chan = 16'd0;
    lmt_pkt_size = (pre_trig_samples + post_trig_samples)/(DDR3_PAYLOAD_WIDTH/c_acq_channels[acq_chan]);
    skip_trig = 1'b1;
    wait_finish = 1'b1;
    stop_on_error = 1'b1;
    min_wait_gnt_l = 32;
    max_wait_gnt_l = 128;
    data_valid_prob = 1.0;
    min_wait_trig_l = 100;
    max_wait_trig_l = 200;
    hw_trig_sel = 1'b1; // External trigger
    hw_trig_en = 1'b0;
    hw_trig_dly = 'h0;
    hw_int_trig_thres = 32'h000FFFFF;
    hw_int_trig_thres_filt = 8'b00001111;
    sw_trig_en = 1'b0;

    wb_acq(test_id, n_shots,
                pre_trig_samples, post_trig_samples,
                hw_trig_sel, hw_trig_en, hw_trig_dly, hw_int_trig_thres,
                hw_int_trig_thres_filt, sw_trig_en,
                ddr3_start_addr, ddr3_end_addr, acq_chan, skip_trig,
                wait_finish, stop_on_error, min_wait_gnt_l,
                max_wait_gnt_l, min_wait_trig_l,
                max_wait_trig_l, data_valid_prob);

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
    ddr3_end_addr = 32'h00001000;
    acq_chan = 16'd0;
    lmt_pkt_size = (pre_trig_samples + post_trig_samples)/(DDR3_PAYLOAD_WIDTH/c_acq_channels[acq_chan]);
    skip_trig = 1'b1;
    wait_finish = 1'b1;
    min_wait_gnt_l = 32;
    max_wait_gnt_l = 128;
    data_valid_prob = 0.7;
    min_wait_trig_l = 100;
    max_wait_trig_l = 200;
    hw_trig_sel = 1'b1; // External trigger
    hw_trig_en = 1'b0;
    hw_trig_dly = 'h0;
    hw_int_trig_thres = 32'h000FFFFF;
    hw_int_trig_thres_filt = 8'b00001111;
    sw_trig_en = 1'b0;

    wb_acq(test_id, n_shots,
                pre_trig_samples, post_trig_samples,
                hw_trig_sel, hw_trig_en, hw_trig_dly, hw_int_trig_thres,
                hw_int_trig_thres_filt, sw_trig_en,
                ddr3_start_addr, ddr3_end_addr, acq_chan, skip_trig,
                wait_finish, stop_on_error, min_wait_gnt_l,
                max_wait_gnt_l, min_wait_trig_l,
                max_wait_trig_l, data_valid_prob);

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
    ddr3_end_addr = 32'h00001000;
    acq_chan = 16'd0;
    lmt_pkt_size = (pre_trig_samples + post_trig_samples)/(DDR3_PAYLOAD_WIDTH/c_acq_channels[acq_chan]);
    skip_trig = 1'b1;
    wait_finish = 1'b1;
    min_wait_gnt_l = 256;
    max_wait_gnt_l = 512;
    data_valid_prob = 0.7;
    min_wait_trig_l = 100;
    max_wait_trig_l = 200;
    hw_trig_sel = 1'b1; // External trigger
    hw_trig_en = 1'b0;
    hw_trig_dly = 'h0;
    hw_int_trig_thres = 32'h000FFFFF;
    hw_int_trig_thres_filt = 8'b00001111;
    sw_trig_en = 1'b0;

    wb_acq(test_id, n_shots,
                pre_trig_samples, post_trig_samples,
                hw_trig_sel, hw_trig_en, hw_trig_dly, hw_int_trig_thres,
                hw_int_trig_thres_filt, sw_trig_en,
                ddr3_start_addr, ddr3_end_addr, acq_chan, skip_trig,
                wait_finish, stop_on_error, min_wait_gnt_l,
                max_wait_gnt_l, min_wait_trig_l,
                max_wait_trig_l, data_valid_prob);

    ////////////////////////
    // TEST #4
    // Number of shots = 1
    // Pre trigger samples only
    // No trigger
    // Larger channel
    ////////////////////////

    test_id = 4;
    n_shots = 16'h0001;
    pre_trig_samples = 32'h00000100;
    post_trig_samples = 32'h00000000;
    ddr3_start_addr = 32'h00000000; // all zeros for now
    ddr3_end_addr = 32'h00001000;
    acq_chan = 16'd1;
    lmt_pkt_size = (pre_trig_samples + post_trig_samples)/(DDR3_PAYLOAD_WIDTH/c_acq_channels[acq_chan]);
    skip_trig = 1'b1;
    wait_finish = 1'b1;
    min_wait_gnt_l = 256;
    max_wait_gnt_l = 512;
    data_valid_prob = 0.7;
    min_wait_trig_l = 100;
    max_wait_trig_l = 200;
    hw_trig_sel = 1'b1; // External trigger
    hw_trig_en = 1'b0;
    hw_trig_dly = 'h0;
    hw_int_trig_thres = 32'h000FFFFF;
    hw_int_trig_thres_filt = 8'b00001111;
    sw_trig_en = 1'b0;

    wb_acq(test_id, n_shots,
                pre_trig_samples, post_trig_samples,
                hw_trig_sel, hw_trig_en, hw_trig_dly, hw_int_trig_thres,
                hw_int_trig_thres_filt, sw_trig_en,
                ddr3_start_addr, ddr3_end_addr, acq_chan, skip_trig,
                wait_finish, stop_on_error, min_wait_gnt_l,
                max_wait_gnt_l, min_wait_trig_l,
                max_wait_trig_l, data_valid_prob);

    ////////////////////////
    // TEST #5
    // Number of shots = 1
    // Pre trigger samples only
    // No trigger
    ////////////////////////

    test_id = 5;
    n_shots = 16'h0001;
    pre_trig_samples = 32'h00001000;
    post_trig_samples = 32'h00000000;
    ddr3_start_addr = 32'h00000000; // all zeros for now
    ddr3_end_addr = 32'h00002000;
    acq_chan = 16'd0;
    lmt_pkt_size = (pre_trig_samples + post_trig_samples)/(DDR3_PAYLOAD_WIDTH/c_acq_channels[acq_chan]);
    skip_trig = 1'b1;
    wait_finish = 1'b1;
    min_wait_gnt_l = 1024; // watch for errors here!
    max_wait_gnt_l = 2048; // watch for errors here!
    data_valid_prob = 0.5;
    min_wait_trig_l = 100;
    max_wait_trig_l = 200;
    hw_trig_sel = 1'b1; // External trigger
    hw_trig_en = 1'b0;
    hw_trig_dly = 'h0;
    hw_int_trig_thres = 32'h000FFFFF;
    hw_int_trig_thres_filt = 8'b00001111;
    sw_trig_en = 1'b0;

    wb_acq(test_id, n_shots,
                pre_trig_samples, post_trig_samples,
                hw_trig_sel, hw_trig_en, hw_trig_dly, hw_int_trig_thres,
                hw_int_trig_thres_filt, sw_trig_en,
                ddr3_start_addr, ddr3_end_addr, acq_chan, skip_trig,
                wait_finish, stop_on_error, min_wait_gnt_l,
                max_wait_gnt_l, min_wait_trig_l,
                max_wait_trig_l, data_valid_prob);

    ////////////////////////
    // TEST #6
    // Number of shots = 2
    // Pre trigger samples only
    // No trigger
    ////////////////////////

    test_id = 6;
    n_shots = 16'h0002;
    pre_trig_samples = 32'h00000010;
    post_trig_samples = 32'h00000000;
    ddr3_start_addr = 32'h00000000; // all zeros for now
    ddr3_end_addr = 32'h00001000;
    acq_chan = 16'd0;
    lmt_pkt_size = (pre_trig_samples + post_trig_samples)/(DDR3_PAYLOAD_WIDTH/c_acq_channels[acq_chan]);
    skip_trig = 1'b1;
    wait_finish = 1'b1;
    min_wait_gnt_l = 64;
    max_wait_gnt_l = 128;
    data_valid_prob = 0.7;
    min_wait_trig_l = 100;
    max_wait_trig_l = 200;
    hw_trig_sel = 1'b1; // External trigger
    hw_trig_en = 1'b0;
    hw_trig_dly = 'h0;
    hw_int_trig_thres = 32'h000FFFFF;
    hw_int_trig_thres_filt = 8'b00001111;
    sw_trig_en = 1'b0;

    wb_acq(test_id, n_shots,
                pre_trig_samples, post_trig_samples,
                hw_trig_sel, hw_trig_en, hw_trig_dly, hw_int_trig_thres,
                hw_int_trig_thres_filt, sw_trig_en,
                ddr3_start_addr, ddr3_end_addr, acq_chan, skip_trig,
                wait_finish, stop_on_error, min_wait_gnt_l,
                max_wait_gnt_l, min_wait_trig_l,
                max_wait_trig_l, data_valid_prob);

    ////////////////////////
    // TEST #7
    // Number of shots = 16
    // Pre trigger samples only
    // No trigger
    ////////////////////////

    test_id = 7;
    n_shots = 16'h0010;
    pre_trig_samples = 32'h00000010;
    post_trig_samples = 32'h00000000;
    ddr3_start_addr = 32'h00000000; // all zeros for now
    ddr3_end_addr = 32'h00001000;
    acq_chan = 16'd0;
    lmt_pkt_size = (pre_trig_samples + post_trig_samples)/(DDR3_PAYLOAD_WIDTH/c_acq_channels[acq_chan]);
    skip_trig = 1'b1;
    wait_finish = 1'b1;
    min_wait_gnt_l = 64;
    max_wait_gnt_l = 128;
    data_valid_prob = 0.6;
    min_wait_trig_l = 100;
    max_wait_trig_l = 200;
    hw_trig_sel = 1'b1; // External trigger
    hw_trig_en = 1'b0;
    hw_trig_dly = 'h0;
    hw_int_trig_thres = 32'h000FFFFF;
    hw_int_trig_thres_filt = 8'b00001111;
    sw_trig_en = 1'b0;

    wb_acq(test_id, n_shots,
                pre_trig_samples, post_trig_samples,
                hw_trig_sel, hw_trig_en, hw_trig_dly, hw_int_trig_thres,
                hw_int_trig_thres_filt, sw_trig_en,
                ddr3_start_addr, ddr3_end_addr, acq_chan, skip_trig,
                wait_finish, stop_on_error, min_wait_gnt_l,
                max_wait_gnt_l, min_wait_trig_l,
                max_wait_trig_l, data_valid_prob);

    ////////////////////////
    // TEST #8
    // Number of shots = 16
    // Pre trigger samples only
    // No trigger
    ////////////////////////

    test_id = 8;
    n_shots = 16'h0010;
    pre_trig_samples = 32'h00000020;
    post_trig_samples = 32'h00000000;
    ddr3_start_addr = 32'h00000000; // all zeros for now
    ddr3_end_addr = 32'h00001000;
    acq_chan = 16'd0;
    lmt_pkt_size = (pre_trig_samples + post_trig_samples)/(DDR3_PAYLOAD_WIDTH/c_acq_channels[acq_chan]);
    skip_trig = 1'b1;
    wait_finish = 1'b1;
    min_wait_gnt_l = 128;
    max_wait_gnt_l = 512;
    data_valid_prob = 0.6;
    min_wait_trig_l = 100;
    max_wait_trig_l = 200;
    hw_trig_sel = 1'b1; // External trigger
    hw_trig_en = 1'b0;
    hw_trig_dly = 'h0;
    hw_int_trig_thres = 32'h000FFFFF;
    hw_int_trig_thres_filt = 8'b00001111;
    sw_trig_en = 1'b0;

    wb_acq(test_id, n_shots,
                pre_trig_samples, post_trig_samples,
                hw_trig_sel, hw_trig_en, hw_trig_dly, hw_int_trig_thres,
                hw_int_trig_thres_filt, sw_trig_en,
                ddr3_start_addr, ddr3_end_addr, acq_chan, skip_trig,
                wait_finish, stop_on_error, min_wait_gnt_l,
                max_wait_gnt_l, min_wait_trig_l,
                max_wait_trig_l, data_valid_prob);

    ////////////////////////
    // TEST #9
    // Number of shots = 1
    // Pre trigger samples only
    // No trigger
    ////////////////////////

    test_id = 9;
    n_shots = 16'h0010;
    pre_trig_samples = 32'h00000010;
    post_trig_samples = 32'h00000000;
    ddr3_start_addr = 32'h00000000; // all zeros for now
    ddr3_end_addr = 32'h00001000;
    acq_chan = 16'd0;
    lmt_pkt_size = (pre_trig_samples + post_trig_samples)/(DDR3_PAYLOAD_WIDTH/c_acq_channels[acq_chan]);
    skip_trig = 1'b1;
    wait_finish = 1'b1;
    min_wait_gnt_l = 64;
    max_wait_gnt_l = 128;
    data_valid_prob = 0.6;
    min_wait_trig_l = 100;
    max_wait_trig_l = 200;
    hw_trig_sel = 1'b1; // External trigger
    hw_trig_en = 1'b0;
    hw_trig_dly = 'h0;
    hw_int_trig_thres = 32'h000FFFFF;
    hw_int_trig_thres_filt = 8'b00001111;
    sw_trig_en = 1'b0;

    wb_acq(test_id, n_shots,
                pre_trig_samples, post_trig_samples,
                hw_trig_sel, hw_trig_en, hw_trig_dly, hw_int_trig_thres,
                hw_int_trig_thres_filt, sw_trig_en,
                ddr3_start_addr, ddr3_end_addr, acq_chan, skip_trig,
                wait_finish, stop_on_error, min_wait_gnt_l,
                max_wait_gnt_l, min_wait_trig_l,
                max_wait_trig_l, data_valid_prob);

    ////////////////////////
    // TEST #10
    // Number of shots = 16
    // Pre trigger samples only
    // No trigger
    ////////////////////////

    test_id = 10;
    n_shots = 16'h0010;
    pre_trig_samples = 32'h00000020;
    post_trig_samples = 32'h00000000;
    ddr3_start_addr = 32'h00000000; // all zeros for now
    ddr3_end_addr = 32'h00001000;
    acq_chan = 16'd0;
    lmt_pkt_size = (pre_trig_samples + post_trig_samples)/(DDR3_PAYLOAD_WIDTH/c_acq_channels[acq_chan]);
    skip_trig = 1'b1;
    wait_finish = 1'b1;
    min_wait_gnt_l = 128;
    max_wait_gnt_l = 512;
    data_valid_prob = 0.6;
    min_wait_trig_l = 100;
    max_wait_trig_l = 200;
    hw_trig_sel = 1'b1; // External trigger
    hw_trig_en = 1'b0;
    hw_trig_dly = 'h0;
    hw_int_trig_thres = 32'h000FFFFF;
    hw_int_trig_thres_filt = 8'b00001111;
    sw_trig_en = 1'b0;

    wb_acq(test_id, n_shots,
                pre_trig_samples, post_trig_samples,
                hw_trig_sel, hw_trig_en, hw_trig_dly, hw_int_trig_thres,
                hw_int_trig_thres_filt, sw_trig_en,
                ddr3_start_addr, ddr3_end_addr, acq_chan, skip_trig,
                wait_finish, stop_on_error, min_wait_gnt_l,
                max_wait_gnt_l, min_wait_trig_l,
                max_wait_trig_l, data_valid_prob);

    ////////////////////////
    // TEST #11
    // Number of shots = 1
    // Pre trigger samples only, small amount
    // No trigger
    ////////////////////////
    test_id = 11;
    n_shots = 16'h0001;
    pre_trig_samples = 32'h00000004;
    post_trig_samples = 32'h00000000;
    ddr3_start_addr = 32'h00000000; // all zeros for now
    ddr3_end_addr = 32'h00001000;
    acq_chan = 16'd0;
    lmt_pkt_size = (pre_trig_samples + post_trig_samples)/(DDR3_PAYLOAD_WIDTH/c_acq_channels[acq_chan]);
    skip_trig = 1'b1;
    wait_finish = 1'b1;
    stop_on_error = 1'b1;
    min_wait_gnt_l = 32;
    max_wait_gnt_l = 128;
    data_valid_prob = 1.0;
    min_wait_trig_l = 100;
    max_wait_trig_l = 200;
    hw_trig_sel = 1'b1; // External trigger
    hw_trig_en = 1'b0;
    hw_trig_dly = 'h0;
    hw_int_trig_thres = 32'h000FFFFF;
    hw_int_trig_thres_filt = 8'b00001111;
    sw_trig_en = 1'b0;

    wb_acq(test_id, n_shots,
                pre_trig_samples, post_trig_samples,
                hw_trig_sel, hw_trig_en, hw_trig_dly, hw_int_trig_thres,
                hw_int_trig_thres_filt, sw_trig_en,
                ddr3_start_addr, ddr3_end_addr, acq_chan, skip_trig,
                wait_finish, stop_on_error, min_wait_gnt_l,
                max_wait_gnt_l, min_wait_trig_l,
                max_wait_trig_l, data_valid_prob);

    ////////////////////////
    // Trigger Tests
    ////////////////////////

    ////////////////////////
    // TEST #12
    // Number of shots = 1
    // Pre trigger samples
    // Post trigger samples
    // With trigger
    ////////////////////////
    test_id = 12;
    n_shots = 16'h0001;
    pre_trig_samples = 32'h00000010;
    post_trig_samples = 32'h00000010;
    ddr3_start_addr = 32'h00000000; // all zeros for now
    ddr3_end_addr = 32'h00001000;
    acq_chan = 16'd0;
    lmt_pkt_size = (pre_trig_samples + post_trig_samples)/(DDR3_PAYLOAD_WIDTH/c_acq_channels[acq_chan]);
    skip_trig = 1'b0;
    wait_finish = 1'b1;
    stop_on_error = 1'b1;
    min_wait_gnt_l = 128;
    max_wait_gnt_l = 512;
    data_valid_prob = 1.0;
    min_wait_trig_l = 1000;
    max_wait_trig_l = 1200;
    hw_trig_sel = 1'b1; // External trigger
    hw_trig_en = 1'b1;
    hw_trig_dly = 'h0;
    hw_int_trig_thres = 32'h000FFFFF;
    hw_int_trig_thres_filt = 8'b00001111;
    sw_trig_en = 1'b0;

    wb_acq(test_id, n_shots,
                pre_trig_samples, post_trig_samples,
                hw_trig_sel, hw_trig_en, hw_trig_dly, hw_int_trig_thres,
                hw_int_trig_thres_filt, sw_trig_en,
                ddr3_start_addr, ddr3_end_addr, acq_chan, skip_trig,
                wait_finish, stop_on_error, min_wait_gnt_l,
                max_wait_gnt_l, min_wait_trig_l,
                max_wait_trig_l, data_valid_prob);

    ////////////////////////
    // TEST #13
    // Number of shots = 1
    // Pre trigger samples
    // Post trigger samples
    // With trigger
    ////////////////////////
    test_id = 13;
    n_shots = 16'h0001;
    pre_trig_samples = 32'h00000100;
    post_trig_samples = 32'h00000010;
    ddr3_start_addr = 32'h00000000; // all zeros for now
    ddr3_end_addr = 32'h00001000;
    acq_chan = 16'd0;
    lmt_pkt_size = (pre_trig_samples + post_trig_samples)/(DDR3_PAYLOAD_WIDTH/c_acq_channels[acq_chan]);
    skip_trig = 1'b0;
    wait_finish = 1'b1;
    stop_on_error = 1'b1;
    min_wait_gnt_l = 128;
    max_wait_gnt_l = 512;
    data_valid_prob = 1.0;
    min_wait_trig_l = 1000;
    max_wait_trig_l = 1200;
    hw_trig_sel = 1'b1; // External trigger
    hw_trig_en = 1'b1;
    hw_trig_dly = 'h0;
    hw_int_trig_thres = 32'h000FFFFF;
    hw_int_trig_thres_filt = 8'b00001111;
    sw_trig_en = 1'b0;

    wb_acq(test_id, n_shots,
                pre_trig_samples, post_trig_samples,
                hw_trig_sel, hw_trig_en, hw_trig_dly, hw_int_trig_thres,
                hw_int_trig_thres_filt, sw_trig_en,
                ddr3_start_addr, ddr3_end_addr, acq_chan, skip_trig,
                wait_finish, stop_on_error, min_wait_gnt_l,
                max_wait_gnt_l, min_wait_trig_l,
                max_wait_trig_l, data_valid_prob);

    ////////////////////////
    // TEST #14
    // Number of shots = 1
    // Pre trigger samples
    // Post trigger samples
    // With trigger
    ////////////////////////
    test_id = 14;
    n_shots = 16'h0001;
    pre_trig_samples = 32'h00000010;
    post_trig_samples = 32'h00000100;
    ddr3_start_addr = 32'h00000000; // all zeros for now
    ddr3_end_addr = 32'h00001000;
    acq_chan = 16'd0;
    lmt_pkt_size = (pre_trig_samples + post_trig_samples)/(DDR3_PAYLOAD_WIDTH/c_acq_channels[acq_chan]);
    skip_trig = 1'b0;
    wait_finish = 1'b1;
    stop_on_error = 1'b1;
    min_wait_gnt_l = 128;
    max_wait_gnt_l = 512;
    data_valid_prob = 0.6;
    min_wait_trig_l = 1000;
    max_wait_trig_l = 1200;
    hw_trig_sel = 1'b1; // External trigger
    hw_trig_en = 1'b1;
    hw_trig_dly = 'h0;
    hw_int_trig_thres = 32'h000FFFFF;
    hw_int_trig_thres_filt = 8'b00001111;
    sw_trig_en = 1'b0;

    wb_acq(test_id, n_shots,
                pre_trig_samples, post_trig_samples,
                hw_trig_sel, hw_trig_en, hw_trig_dly, hw_int_trig_thres,
                hw_int_trig_thres_filt, sw_trig_en,
                ddr3_start_addr, ddr3_end_addr, acq_chan, skip_trig,
                wait_finish, stop_on_error, min_wait_gnt_l,
                max_wait_gnt_l, min_wait_trig_l,
                max_wait_trig_l, data_valid_prob);

    ////////////////////////
    // TEST #15
    // Number of shots = 1
    // Pre trigger samples
    // Post trigger samples
    // With trigger
    ////////////////////////
    test_id = 15;
    n_shots = 16'h0001;
    pre_trig_samples = 32'h00000100;
    post_trig_samples = 32'h00001000;
    ddr3_start_addr = 32'h00000000; // all zeros for now
    ddr3_end_addr = 32'h00010000;
    acq_chan = 16'd0;
    lmt_pkt_size = (pre_trig_samples + post_trig_samples)/(DDR3_PAYLOAD_WIDTH/c_acq_channels[acq_chan]);
    skip_trig = 1'b0;
    wait_finish = 1'b1;
    stop_on_error = 1'b1;
    min_wait_gnt_l = 128;
    max_wait_gnt_l = 512;
    data_valid_prob = 0.8;
    min_wait_trig_l = 1000;
    max_wait_trig_l = 1500;
    hw_trig_sel = 1'b1; // External trigger
    hw_trig_en = 1'b1;
    hw_trig_dly = 'h0;
    hw_int_trig_thres = 32'h000FFFFF;
    hw_int_trig_thres_filt = 8'b00001111;
    sw_trig_en = 1'b0;

    wb_acq(test_id, n_shots,
                pre_trig_samples, post_trig_samples,
                hw_trig_sel, hw_trig_en, hw_trig_dly, hw_int_trig_thres,
                hw_int_trig_thres_filt, sw_trig_en,
                ddr3_start_addr, ddr3_end_addr, acq_chan, skip_trig,
                wait_finish, stop_on_error, min_wait_gnt_l,
                max_wait_gnt_l, min_wait_trig_l,
                max_wait_trig_l, data_valid_prob);

    ////////////////////////
    // TEST #16
    // Number of shots = 16
    // Pre trigger samples
    // Post trigger samples
    // With trigger
    ////////////////////////
    test_id = 16;
    n_shots = 16'h0010;
    pre_trig_samples = 32'h00000100;
    post_trig_samples = 32'h00000100;
    ddr3_start_addr = 32'h00000000; // all zeros for now
    ddr3_end_addr = 32'h00010000;
    acq_chan = 16'd0;
    lmt_pkt_size = (pre_trig_samples + post_trig_samples)/(DDR3_PAYLOAD_WIDTH/c_acq_channels[acq_chan]);
    skip_trig = 1'b0;
    wait_finish = 1'b1;
    stop_on_error = 1'b1;
    min_wait_gnt_l = 128;
    max_wait_gnt_l = 512;
    data_valid_prob = 0.7;
    min_wait_trig_l = 1000;
    max_wait_trig_l = 2000;
    hw_trig_sel = 1'b1; // External trigger
    hw_trig_en = 1'b1;
    hw_trig_dly = 'h0;
    hw_int_trig_thres = 32'h000FFFFF;
    hw_int_trig_thres_filt = 8'b00001111;
    sw_trig_en = 1'b0;

    wb_acq(test_id, n_shots,
                pre_trig_samples, post_trig_samples,
                hw_trig_sel, hw_trig_en, hw_trig_dly, hw_int_trig_thres,
                hw_int_trig_thres_filt, sw_trig_en,
                ddr3_start_addr, ddr3_end_addr, acq_chan, skip_trig,
                wait_finish, stop_on_error, min_wait_gnt_l,
                max_wait_gnt_l, min_wait_trig_l,
                max_wait_trig_l, data_valid_prob);

    ////////////////////////
    // TEST #17
    // Number of shots = 1
    // Pre trigger samples only
    // No trigger
    ////////////////////////

    test_id = 17;
    n_shots = 16'h0001;
    pre_trig_samples = 32'h00000040;
    post_trig_samples = 32'h00000040;
    ddr3_start_addr = 32'h00000000; // all zeros for now
    ddr3_end_addr = 32'h00010000;
    acq_chan = 16'd0;
    lmt_pkt_size = (pre_trig_samples + post_trig_samples)/(DDR3_PAYLOAD_WIDTH/c_acq_channels[acq_chan]);
    skip_trig = 1'b0;
    wait_finish = 1'b1;
    min_wait_gnt_l = 256;
    max_wait_gnt_l = 512;
    data_valid_prob = 0.7;
    min_wait_trig_l = 100;
    max_wait_trig_l = 200;
    hw_trig_sel = 1'b0; // Data-driven trigger
    hw_trig_en = 1'b1;
    hw_trig_dly = 'h0;
    hw_int_trig_thres = 32'h00000010;
    hw_int_trig_thres_filt = 8'b00000001;
    sw_trig_en = 1'b0;

    wb_acq(test_id, n_shots,
                pre_trig_samples, post_trig_samples,
                hw_trig_sel, hw_trig_en, hw_trig_dly, hw_int_trig_thres,
                hw_int_trig_thres_filt, sw_trig_en,
                ddr3_start_addr, ddr3_end_addr, acq_chan, skip_trig,
                wait_finish, stop_on_error, min_wait_gnt_l,
                max_wait_gnt_l, min_wait_trig_l,
                max_wait_trig_l, data_valid_prob);

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
      if (data_test_dvalid_t[0]) begin
        data_test_low[0] <= {data_test_low_0 + 16'h30, data_test_low_0 + 16'h20,
                                        data_test_low_0 + 16'h10, data_test_low_0 + 16'h00};
        data_test_high[0] <= {64'h0};
        data_test_low_0 <= data_test_low_0 + 1;
      end

      data_test_dvalid_t[0] <= f_gen_data_rdy_gen(data_valid_threshold);
      data_test_dvalid[0] <= data_test_dvalid_t[0];
      data_test_trig[0] <= data_trig;
    end else begin
      data_test_low_0 <= 'h0;
      data_test_low[0] <= 'h0;
      data_test_high[0] <= 'h0;
      data_test_dvalid[0] <= 1'b0;
      data_test_dvalid_t[0] <= 1'b0;
      data_test_trig[0] <= 1'b0;
    end
  end

  genvar ch;

  generate
    for (ch = 1; ch < c_n_chan; ch = ch + 1) begin: gen_chan
      initial begin
        data_test_trig[ch] = 0;
        data_test_low[ch] = 0;
        data_test_high[ch] = 100;
      end

      always @(posedge adc_clk)
      begin
        if (data_gen_start) begin
          //data_test <= f_data_gen(c_data_max);
          if (data_test_dvalid_t[ch]) begin
            data_test_low[ch] <= data_test_low[ch] + ch + 1;
            data_test_high[ch] <=  data_test_high[ch] + ch + 1;
          end

          data_test_dvalid_t[ch] <= f_gen_data_rdy_gen(data_valid_threshold);
          data_test_dvalid[ch] <= data_test_dvalid_t[ch];
          data_test_trig[ch] <= data_trig;
        end else begin
          data_test_low[ch] <= 'h0;
          data_test_high[ch] <= 'h0;
          data_test_dvalid[ch] <= 1'b0;
          data_test_dvalid_t[ch] <= 1'b0;
          data_test_trig[ch] <= 1'b0;
        end
      end
    end
  endgenerate

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

  task wb_busy_wait0;
    input [`WB_ADDRESS_BUS_WIDTH-1:0] addr;
    input [`WB_DATA_BUS_WIDTH-1:0] mask;
    input [`WB_DATA_BUS_WIDTH-1:0] offset;
    input verbose;

    reg [`WB_DATA_BUS_WIDTH-1:0] tmp_reg0;
    reg [`WB_DATA_BUS_WIDTH-1:0] tmp_reg1;
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

  task wb_busy_wait1;
    input [`WB_ADDRESS_BUS_WIDTH-1:0] addr;
    input [`WB_DATA_BUS_WIDTH-1:0] mask;
    input [`WB_DATA_BUS_WIDTH-1:0] offset;
    input verbose;

    reg [`WB_DATA_BUS_WIDTH-1:0] tmp_reg0;
    reg [`WB_DATA_BUS_WIDTH-1:0] tmp_reg1;
  begin
    WB1.monitor_bus(1'b0);
    WB1.verbose(1'b0);

    WB1.read32(addr, tmp_reg1);

    while (((tmp_reg1 & mask) >> offset) != 'h1) begin
      if (verbose)
        $write(".");

      @(posedge sys_clk);
      WB1.read32(addr, tmp_reg1);
    end

    WB1.monitor_bus(1'b1);
    WB1.verbose(1'b1);
  end
  endtask

  task wb_acq;
    input integer test_id;
    input [15:0] n_shots;
    input [31:0] pre_trig_samples;
    input [31:0] post_trig_samples;
    input hw_trig_sel; // 0 is Data-driven trigger, 1 is External trigger
    input hw_trig_en; // Data-driven trigger enable
    input [31:0] hw_trig_dly;
    input [31:0] hw_int_trig_thres;
    input [7:0] hw_int_trig_thres_filt;
    input sw_trig_en; // Software trigger enable
    input [31:0] ddr3_start_addr;
    input [31:0] ddr3_end_addr;
    input [15:0] acq_chan;
    input skip_trig;
    input wait_finish;
    input stop_on_error;
    input integer min_wait_gnt_l;
    input integer max_wait_gnt_l;
    input integer min_wait_trig_l;
    input integer max_wait_trig_l;
    //input real ext_stall_prob;
    input real data_valid_prob;

    reg [31:0] acq_core_fsm_ctl_reg;
    reg [31:0] acq_core_trig_cfg_reg;
    reg [31:0] acq_core_trig_data_cfg;
  begin
    $display("#############################");
    $display("######## TEST #%03d ######", test_id);
    $display("#############################");
    $display("## Number of shots = %03d", n_shots);
    $display("## Number of pre samples = %03d", pre_trig_samples);
    $display("## Skip trigger = %d", skip_trig);
    $display("## Number of post samples = %03d", post_trig_samples);
    $display("## Minimum number of wait cycles DDR3 access = %03d", min_wait_gnt_l);
    $display("## Maximum number of wait cycles DDR3 access = %03d", max_wait_gnt_l);
    $display("## Minimum number of wait cycles SW Trigger= %03d", min_wait_trig_l);
    $display("## Maximum number of wait cycles SW Trigger= %03d", max_wait_trig_l);

    $display("Setting throttling parameters scenario");
    //$display("Setting sink stall probability = %.2f%%", ext_stall_prob*100);
    //$display("Setting sink rdy probability = %.2f%%", (1-ext_stall_prob)*100);
    $display("Setting source data valid input probability = %.2f%%", data_valid_prob*100);

    //@(posedge sys_clk);
    //test_in_progress = 1'b0;

    @(posedge sys_clk);
    //data_ext_stall_threshold = 0.3;
    //data_ext_rdy_threshold = 0.7;
    //data_valid_threshold = 0.7;
    data_valid_threshold = data_valid_prob; // modify external register! FIXME?
    min_wait_gnt = min_wait_gnt_l; // modify external register! FIXME?
    max_wait_gnt = max_wait_gnt_l; // modify external register! FIXME?

    // Wait for some time and then trigger the acquisition
    min_wait_trig = min_wait_trig_l; // modify external register! FIXME?
    max_wait_trig = max_wait_trig_l; // modify external register! FIXME?

    test_in_progress = 1'b1;

    $display("Setting # of shots to %03d", n_shots);
    @(posedge sys_clk);
    WB0.write32(`ADDR_ACQ_CORE_SHOTS >> `WB_WORD_ACC, (n_shots << `ACQ_CORE_SHOTS_NB_OFFSET));
    WB1.write32(`ADDR_ACQ_CORE_SHOTS >> `WB_WORD_ACC, (n_shots << `ACQ_CORE_SHOTS_NB_OFFSET));

    $display("Setting # of pre-trigger to %03d", pre_trig_samples);
    @(posedge sys_clk);
    WB0.write32(`ADDR_ACQ_CORE_PRE_SAMPLES >> `WB_WORD_ACC, (pre_trig_samples));
    WB1.write32(`ADDR_ACQ_CORE_PRE_SAMPLES >> `WB_WORD_ACC, (pre_trig_samples));

    $display("Setting # of pos-trigger to %03d", post_trig_samples);
    @(posedge sys_clk);
    WB0.write32(`ADDR_ACQ_CORE_POST_SAMPLES >> `WB_WORD_ACC, (post_trig_samples));
    WB1.write32(`ADDR_ACQ_CORE_POST_SAMPLES >> `WB_WORD_ACC, (post_trig_samples));

    // Prepare CFG trigger register
    acq_core_trig_cfg_reg = (hw_trig_sel) << `ACQ_CORE_TRIG_CFG_HW_TRIG_SEL_OFFSET;

    $display("Selecting external HW trigger: %d", hw_trig_sel);
    @(posedge sys_clk);
    WB0.write32(`ADDR_ACQ_CORE_TRIG_CFG >> `WB_WORD_ACC, acq_core_trig_cfg_reg);
    WB1.write32(`ADDR_ACQ_CORE_TRIG_CFG >> `WB_WORD_ACC, acq_core_trig_cfg_reg);

    acq_core_trig_cfg_reg = (acq_core_trig_cfg_reg) | ((hw_trig_en) << `ACQ_CORE_TRIG_CFG_HW_TRIG_EN_OFFSET);

    $display("Enabling HW trigger: %d", hw_trig_en);
    @(posedge sys_clk);
    WB0.write32(`ADDR_ACQ_CORE_TRIG_CFG >> `WB_WORD_ACC, acq_core_trig_cfg_reg);
    WB1.write32(`ADDR_ACQ_CORE_TRIG_CFG >> `WB_WORD_ACC, acq_core_trig_cfg_reg);

    // Prepare CFG trigger register
    acq_core_trig_cfg_reg = (acq_core_trig_cfg_reg) | ((sw_trig_en) << `ACQ_CORE_TRIG_CFG_SW_TRIG_EN_OFFSET);

    $display("Enabling SW trigger: %d", sw_trig_en);
    @(posedge sys_clk);
    WB0.write32(`ADDR_ACQ_CORE_TRIG_CFG >> `WB_WORD_ACC, acq_core_trig_cfg_reg);
    WB1.write32(`ADDR_ACQ_CORE_TRIG_CFG >> `WB_WORD_ACC, acq_core_trig_cfg_reg);

    // Prepare trigger delay register
    $display("Setting trigger delay to %d", hw_trig_dly);
    @(posedge sys_clk);
    WB0.write32(`ADDR_ACQ_CORE_TRIG_DLY >> `WB_WORD_ACC, hw_trig_dly);
    WB1.write32(`ADDR_ACQ_CORE_TRIG_DLY >> `WB_WORD_ACC, hw_trig_dly);

    // Prepare HW trigger threshold
    $display("Setting HW data threshold to %d", hw_int_trig_thres);
    @(posedge sys_clk);
    WB0.write32(`ADDR_ACQ_CORE_TRIG_DATA_THRES >> `WB_WORD_ACC, hw_int_trig_thres);
    WB1.write32(`ADDR_ACQ_CORE_TRIG_DATA_THRES >> `WB_WORD_ACC, hw_int_trig_thres);

    // Prepare HW trigger filter
    acq_core_trig_data_cfg = (hw_int_trig_thres_filt << `ACQ_CORE_TRIG_DATA_CFG_THRES_FILT_OFFSET);

    $display("Setting HW data filter to %d", hw_int_trig_thres_filt);
    @(posedge sys_clk);
    WB0.write32(`ADDR_ACQ_CORE_TRIG_DATA_CFG >> `WB_WORD_ACC, acq_core_trig_data_cfg);
    WB1.write32(`ADDR_ACQ_CORE_TRIG_DATA_CFG >> `WB_WORD_ACC, acq_core_trig_data_cfg);

    // Prepare core_ctl register
    acq_core_fsm_ctl_reg = (skip_trig) << `ACQ_CORE_CTL_FSM_ACQ_NOW_OFFSET;

    $display("Setting skip trigger parameter to %d", skip_trig);
    @(posedge sys_clk);
    WB0.write32(`ADDR_ACQ_CORE_CTL >> `WB_WORD_ACC, acq_core_fsm_ctl_reg);
    WB1.write32(`ADDR_ACQ_CORE_CTL >> `WB_WORD_ACC, acq_core_fsm_ctl_reg);

    $display("Setting DDR3 start address for the next acquistion \
        WB0:0x%08X,WB1:0x%08X", ddr3_start_addr,
        ddr3_start_addr + c_ddr3_acq1_addr_offset);
    @(posedge sys_clk);
    WB0.write32(`ADDR_ACQ_CORE_DDR3_START_ADDR >> `WB_WORD_ACC, ddr3_start_addr);
    WB1.write32(`ADDR_ACQ_CORE_DDR3_START_ADDR >> `WB_WORD_ACC, ddr3_start_addr + c_ddr3_acq1_addr_offset);

    $display("Setting DDR3 end address for the next acquistion \
        WB0:0x%08X,WB1:0x%08X", ddr3_end_addr,
        ddr3_end_addr + c_ddr3_acq1_addr_offset);
    @(posedge sys_clk);
    WB0.write32(`ADDR_ACQ_CORE_DDR3_END_ADDR >> `WB_WORD_ACC, ddr3_end_addr);
    WB1.write32(`ADDR_ACQ_CORE_DDR3_END_ADDR >> `WB_WORD_ACC, ddr3_end_addr + c_ddr3_acq1_addr_offset);

    $display("Setting acquisition channel for the next acquistion %d", acq_chan);
    @(posedge sys_clk);
    WB0.write32(`ADDR_ACQ_CORE_ACQ_CHAN_CTL >> `WB_WORD_ACC,
              (acq_chan << `ACQ_CORE_ACQ_CHAN_CTL_WHICH_OFFSET) & `ACQ_CORE_ACQ_CHAN_CTL_WHICH);
    WB1.write32(`ADDR_ACQ_CORE_ACQ_CHAN_CTL >> `WB_WORD_ACC,
              (acq_chan << `ACQ_CORE_ACQ_CHAN_CTL_WHICH_OFFSET) & `ACQ_CORE_ACQ_CHAN_CTL_WHICH);

    // Prepare core_ctl register
    acq_core_fsm_ctl_reg = (acq_core_fsm_ctl_reg) | (`ACQ_CORE_CTL_FSM_START_ACQ);

    $display("Starting acquisition... ");
    @(posedge sys_clk);
    WB0.write32(`ADDR_ACQ_CORE_CTL >> `WB_WORD_ACC, acq_core_fsm_ctl_reg);
    WB1.write32(`ADDR_ACQ_CORE_CTL >> `WB_WORD_ACC, acq_core_fsm_ctl_reg);

    // ACQ Core 0
    if (wait_finish) begin
      $display("Waiting until all data have been acquired...\n");
      @(posedge sys_clk);
      wb_busy_wait0(`ADDR_ACQ_CORE_STA >> `WB_WORD_ACC, `ACQ_CORE_STA_DDR3_TRANS_DONE,
                      `ACQ_CORE_STA_DDR3_TRANS_DONE_OFFSET, 1'b1);
    end

    $display("Done!");
    //$display("Waiting data check...");

    wait (chk0_end); // data checker ended

    $display("Data checker detected a total of %03d data mismatch errors", chk0_data_err_cnt);
    $display("Data checker detected a total of %03d addr mismatch errors", chk0_addr_err_cnt);

    if (stop_on_error & (chk0_data_err | chk0_addr_err)) begin
      $display("Acq core 0, TEST #%03d NOT PASS!", test_id);
      $finish;
    end

    $display("\n");

    // ACQ Core 1
    if (wait_finish) begin
      $display("Waiting until all data have been acquired...\n");
      @(posedge sys_clk);
      //wb_busy_wait(`ADDR_ACQ_CORE_STA >> `WB_WORD_ACC, `ACQ_CORE_STA_FC_TRANS_DONE,
      //                `ACQ_CORE_STA_FC_TRANS_DONE_OFFSET, 1'b1);
      wb_busy_wait1(`ADDR_ACQ_CORE_STA >> `WB_WORD_ACC, `ACQ_CORE_STA_DDR3_TRANS_DONE,
                      `ACQ_CORE_STA_DDR3_TRANS_DONE_OFFSET, 1'b1);
    end

    $display("Done!");
    //$display("Waiting data check...");

    wait (chk1_end); // data checker ended

    $display("Data checker detected a total of %03d data mismatch errors", chk1_data_err_cnt);
    $display("Data checker detected a total of %03d addr mismatch errors", chk1_addr_err_cnt);

    if (stop_on_error & (chk1_data_err | chk1_addr_err)) begin
      $display("Acq core 1, TEST #%03d NOT PASS!", test_id);
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
