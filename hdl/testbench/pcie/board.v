//-----------------------------------------------------------------------------
//
// (c) Copyright 2010-2011 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//
//-----------------------------------------------------------------------------
// Project    : Series-7 Integrated Block for PCI Express
// File       : board.v
// Version    : 1.7
// Description:  Top level testbench
//
//------------------------------------------------------------------------------

`timescale 1ps/100fs

`define SIMULATION


module board;

`include "helper_tasks.v"

///////////////////////////////////////////////////////////////////////////////////////////////////
////////////// DDR3 memory & controller parameters
////////////// copied from "sim_tb_top.v"
///////////////////////////////////////////////////////////////////////////////////////////////////
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
parameter DQ_CNT_WIDTH          = 6;
                                 // = ceil(log2(DQ_WIDTH))
parameter DQ_PER_DM             = 8;
parameter DM_WIDTH              = 8;
                                 // # of DM (data mask)
parameter DQ_WIDTH              = 64;
                                 // # of DQ (data)
parameter DQS_WIDTH             = 8;
parameter DQS_CNT_WIDTH         = 3;
                                 // = ceil(log2(DQS_WIDTH))
parameter DRAM_WIDTH            = 8;
                                 // # of DQ per DQS
parameter ECC                   = "OFF";
parameter nBANK_MACHS           = 4;
parameter RANKS                 = 1;
                                 // # of Ranks.
parameter ODT_WIDTH             = 1;
                                 // # of ODT outputs to memory.
parameter ROW_WIDTH             = 14;
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
parameter CL                    = 11;
                                 // in number of clock cycles
                                 // DDR3 SDRAM: CAS Latency (Mode Register 0).
                                 // DDR2 SDRAM: CAS Latency (Mode Register).
parameter CWL                   = 8;
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
parameter CLKFBOUT_MULT         = 8;
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
parameter tRCD                  = 13125;
                                 // memory tRCD paramter in pS.
parameter tREFI                 = 7800000;
                                 // memory tREFI paramter in pS.
parameter tRFC                  = 110000;
                                 // memory tRFC paramter in pS.
parameter tRP                   = 13125;
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
parameter BYTE_LANES_B1         = 4'b0111;
                                 // Byte lanes used in an IO column.
parameter BYTE_LANES_B2         = 4'b1111;
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
parameter DATA_CTL_B2           = 4'b1111;
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
parameter PHY_0_BITLANES        = 48'h3FE3FE3FE2FF;
parameter PHY_1_BITLANES        = 48'h000CB0473FFF;
parameter PHY_2_BITLANES        = 48'h3FE3FE3FE2FF;

// control/address/data pin mapping parameters
parameter CK_BYTE_MAP
 = 144'h000000000000000000000000000000000011;
parameter ADDR_MAP
 = 192'h00000011111010910810710610B10A105104103102101100;
parameter BANK_MAP   = 36'h11A115114;
parameter CAS_MAP    = 12'h12A;
parameter CKE_ODT_BYTE_MAP = 8'h00;
parameter CKE_MAP    = 96'h000000000000000000000116;
parameter ODT_MAP    = 96'h000000000000000000000127;
parameter CS_MAP     = 120'h00000000000000000000000000012B;
parameter PARITY_MAP = 12'h000;
parameter RAS_MAP    = 12'h125;
parameter WE_MAP     = 12'h124;
parameter DQS_BYTE_MAP
 = 144'h000000000000000000000302010023222120;
parameter DATA0_MAP  = 96'h200209206203204205202207;
parameter DATA1_MAP  = 96'h219218214215217212216213;
parameter DATA2_MAP  = 96'h225224229226223222228227;
parameter DATA3_MAP  = 96'h238236234233235237232239;
parameter DATA4_MAP  = 96'h005003000009007006004002;
parameter DATA5_MAP  = 96'h013012018019015014017016;
parameter DATA6_MAP  = 96'h023027022029024025028026;
parameter DATA7_MAP  = 96'h039037033032035034038036;
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
parameter MASK0_MAP  = 108'h000031021011001231221211201;
parameter MASK1_MAP  = 108'h000000000000000000000000000;

parameter SLOT_0_CONFIG         = 8'b00000001;
                                 // Mapping of Ranks.
parameter SLOT_1_CONFIG         = 8'b0000_0000;
                                 // Mapping of Ranks.
parameter MEM_ADDR_ORDER
 = "BANK_ROW_COLUMN";

//***************************************************************************
// IODELAY and PHY related parameters
//***************************************************************************
parameter IODELAY_HP_MODE       = "ON";
                                 // to phy_top
parameter IBUF_LPWR_MODE        = "OFF";
                                 // to phy_top
parameter DATA_IO_IDLE_PWRDWN   = "ON";
                                 // # = "ON", "OFF"
parameter DATA_IO_PRIM_TYPE     = "HP_LP";
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
parameter SYSCLK_TYPE           = "DIFFERENTIAL";
                                 // System clock type DIFFERENTIAL, SINGLE_ENDED,
                                 // NO_BUFFER
parameter REFCLK_TYPE           = "USE_SYSTEM_CLOCK";
                                 // Reference clock type DIFFERENTIAL, SINGLE_ENDED,
                                 // NO_BUFFER, USE_SYSTEM_CLOCK
parameter RST_ACT_LOW           = 0;
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
parameter tCK                   = 1250;
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
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

parameter PCIE_REF_CLK_FREQ = 0;      // 0 - 100 MHz, 1 - 125 MHz,  2 - 250 MHz

localparam PCIE_REF_CLK_HALF_CYCLE = (PCIE_REF_CLK_FREQ == 0) ? 5000 :
                                     (PCIE_REF_CLK_FREQ == 1) ? 4000 :
                                     (PCIE_REF_CLK_FREQ == 2) ? 2000 : 0;
integer i;

// System-level clock and reset
reg                sys_rst_n;

wire               ep_sys_clk;
wire               rp_sys_clk;
//
// PCI-Express Serial Interconnect
//
wire  [3:0]  ep_pci_exp_txn;
wire  [3:0]  ep_pci_exp_txp;
wire  [3:0]  rp_pci_exp_txn;
wire  [3:0]  rp_pci_exp_txp;

//
// DDR signals
//
wire                               ddr3_reset_n;
wire [DQ_WIDTH-1:0]                ddr3_dq_fpga;
wire [DQS_WIDTH-1:0]               ddr3_dqs_p_fpga;
wire [DQS_WIDTH-1:0]               ddr3_dqs_n_fpga;
wire [ROW_WIDTH-1:0]               ddr3_addr_fpga;
wire [BANK_WIDTH-1:0]              ddr3_ba_fpga;
wire                               ddr3_ras_n_fpga;
wire                               ddr3_cas_n_fpga;
wire                               ddr3_we_n_fpga;
wire [CKE_WIDTH-1:0]               ddr3_cke_fpga;
wire [CK_WIDTH-1:0]                ddr3_ck_p_fpga;
wire [CK_WIDTH-1:0]                ddr3_ck_n_fpga;

wire                               init_calib_complete;
wire                               tg_compare_error;
wire [(CS_WIDTH*nCS_PER_RANK)-1:0] ddr3_cs_n_fpga;
wire [DM_WIDTH-1:0]                ddr3_dm_fpga;
wire [ODT_WIDTH-1:0]               ddr3_odt_fpga;

reg [(CS_WIDTH*nCS_PER_RANK)-1:0] ddr3_cs_n_sdram_tmp;
reg [DM_WIDTH-1:0]                 ddr3_dm_sdram_tmp;
reg [ODT_WIDTH-1:0]                ddr3_odt_sdram_tmp;

wire [DQ_WIDTH-1:0]                ddr3_dq_sdram;
reg [ROW_WIDTH-1:0]                ddr3_addr_sdram [0:1];
reg [BANK_WIDTH-1:0]               ddr3_ba_sdram [0:1];
reg                                ddr3_ras_n_sdram;
reg                                ddr3_cas_n_sdram;
reg                                ddr3_we_n_sdram;
wire [(CS_WIDTH*nCS_PER_RANK)-1:0] ddr3_cs_n_sdram;
wire [ODT_WIDTH-1:0]               ddr3_odt_sdram;
reg [CKE_WIDTH-1:0]                ddr3_cke_sdram;
wire [DM_WIDTH-1:0]                ddr3_dm_sdram;
wire [DQS_WIDTH-1:0]               ddr3_dqs_p_sdram;
wire [DQS_WIDTH-1:0]               ddr3_dqs_n_sdram;
reg [CK_WIDTH-1:0]                 ddr3_ck_p_sdram;
reg [CK_WIDTH-1:0]                 ddr3_ck_n_sdram;

reg ddr_sys_clk_i;
reg clk_ref_i;

////////////////////////////////
//// Global registers declarations
//////////////////////////////////
// random seed
reg [127: 0] Op_Random;

// Generated Array
reg [15:00]  ii;

reg [31: 0]  Hdr_Array[3:0];
reg [31: 0]  D_Array[1023:0];
reg [10: 0]  Rx_TLP_Length;
reg [ 7: 0]  Rx_MWr_Tag;
reg [ 4: 0]  Rx_MRd_Tag;
reg [31:00] 	Tx_MRd_Addr;
reg [31:00] 	Tx_MRd_Leng;
reg [10: 0] 	tx_MRd_Length;
reg [ 7: 0] 	tx_MRd_Tag;
reg [ 7: 0] 	tx_MRd_Tag_k;

reg [63:00] 	DMA_PA;
reg [63:00] 	DMA_HA;
reg [63:00] 	DMA_BDA;
reg [31:00] 	DMA_Leng;
reg [31:00] 	DMA_L1;
reg [31:00] 	DMA_L2;
reg [02:00] 	DMA_bar;
reg [31:00] 	CplD_Index;

reg 		Desc_tx_MRd_Valid;
reg [10:00] 	Desc_tx_MRd_Leng;
reg [31:00] 	Desc_tx_MRd_Addr;
reg [07:00] 	Desc_tx_MRd_TAG;

reg [63:00] 	PIO_Addr;
reg [31:00] 	PIO_Leng;
reg [ 3:00] 	PIO_1st_BE;
reg [15:00]   localID;
reg           DMA_ds_is_Last;
reg           DMA_us_is_Last;

//
// PCI-Express Endpoint Instance
//

top # (
  .SIMULATION("TRUE")
)
EP (
  // SYS Inteface
  .pci_sys_clk_n(ep_sys_clk_n),
  .pci_sys_clk_p(ep_sys_clk_p),
  .sys_rst_n(sys_rst_n),
  .ddr_sys_clk_p(ddr_sys_clk_p),
  .ddr_sys_clk_n(ddr_sys_clk_n),

  // PCI-Express Interface
  .pci_exp_txn(ep_pci_exp_txn),
  .pci_exp_txp(ep_pci_exp_txp),
  .pci_exp_rxn(rp_pci_exp_txn),
  .pci_exp_rxp(rp_pci_exp_txp),

  // DDR Memory Interface
  .ddr3_dq              (ddr3_dq_fpga),
  .ddr3_dqs_n           (ddr3_dqs_n_fpga),
  .ddr3_dqs_p           (ddr3_dqs_p_fpga),
  .ddr3_addr            (ddr3_addr_fpga),
  .ddr3_ba              (ddr3_ba_fpga),
  .ddr3_ras_n           (ddr3_ras_n_fpga),
  .ddr3_cas_n           (ddr3_cas_n_fpga),
  .ddr3_we_n            (ddr3_we_n_fpga),
  .ddr3_reset_n         (ddr3_reset_n),
  .ddr3_ck_p            (ddr3_ck_p_fpga),
  .ddr3_ck_n            (ddr3_ck_n_fpga),
  .ddr3_cke             (ddr3_cke_fpga),
  .ddr3_cs_n            (ddr3_cs_n_fpga),
  .ddr3_dm              (ddr3_dm_fpga),
  .ddr3_odt             (ddr3_odt_fpga)
);

//**************************************************************************//
// Memory Models instantiations
//**************************************************************************//
genvar r,j;
generate
  for (r = 0; r < CS_WIDTH; r = r + 1) begin: mem_rnk
    for (j = 0; j < NUM_COMP; j = j + 1) begin: gen_mem
      ddr3_model u_comp_ddr3
        (
         .rst_n   (ddr3_reset_n),
         .ck      (ddr3_ck_p_sdram[(j*MEMORY_WIDTH)/72]),
         .ck_n    (ddr3_ck_n_sdram[(j*MEMORY_WIDTH)/72]),
         .cke     (ddr3_cke_sdram[((j*MEMORY_WIDTH)/72)+(nCS_PER_RANK*r)]),
         .cs_n    (ddr3_cs_n_sdram[((j*MEMORY_WIDTH)/72)+(nCS_PER_RANK*r)]),
         .ras_n   (ddr3_ras_n_sdram),
         .cas_n   (ddr3_cas_n_sdram),
         .we_n    (ddr3_we_n_sdram),
         .dm_tdqs (ddr3_dm_sdram[j]),
         .ba      (ddr3_ba_sdram[r]),
         .addr    (ddr3_addr_sdram[r]),
         .dq      (ddr3_dq_sdram[MEMORY_WIDTH*(j+1)-1:MEMORY_WIDTH*(j)]),
         .dqs     (ddr3_dqs_p_sdram[j]),
         .dqs_n   (ddr3_dqs_n_sdram[j]),
         .tdqs_n  (),
         .odt     (ddr3_odt_sdram[((j*MEMORY_WIDTH)/72)+(nCS_PER_RANK*r)])
         );
    end
  end
endgenerate

//
// PCI-Express Model Root Port Instance
//
xilinx_pcie_2_1_rport_7x # (
  .REF_CLK_FREQ(0),
  .PL_FAST_TRAIN("TRUE"),
  .ALLOW_X8_GEN2("FALSE"),
  .C_DATA_WIDTH(64),
  .LINK_CAP_MAX_LINK_WIDTH(6'h04),
  .DEVICE_ID(16'h7100),
  .LINK_CAP_MAX_LINK_SPEED(4'h1),
  .LINK_CTRL2_TARGET_LINK_SPEED(4'h1),
  .DEV_CAP_MAX_PAYLOAD_SUPPORTED(2),
  .TRN_DW("FALSE"),
  .VC0_TX_LASTPACKET(29),
  .VC0_RX_RAM_LIMIT(13'h7FF),
  .VC0_CPL_INFINITE("TRUE"),
  .VC0_TOTAL_CREDITS_PD(437),
  .VC0_TOTAL_CREDITS_CD(461),
  .USER_CLK_FREQ(2),
  .USER_CLK2_DIV2("FALSE")
)
RP (
  // SYS Inteface
  .sys_clk(rp_sys_clk),
  .sys_rst_n(sys_rst_n),

  // PCI-Express Interface
  .pci_exp_txn(rp_pci_exp_txn),
  .pci_exp_txp(rp_pci_exp_txp),
  .pci_exp_rxn(ep_pci_exp_txn),
  .pci_exp_rxp(ep_pci_exp_txp)
);

//
//PCIE clocking instatiations
//
sys_clk_gen  # (
  .halfcycle(PCIE_REF_CLK_HALF_CYCLE),
  .offset(0)
)
CLK_GEN_RP (
  .sys_clk(rp_sys_clk)
);

sys_clk_gen_ds # (
  .halfcycle(PCIE_REF_CLK_HALF_CYCLE),
  .offset(0)
)
CLK_GEN_EP (
  .sys_clk_p(ep_sys_clk_p),
  .sys_clk_n(ep_sys_clk_n)
);
//


//
//DDR signal interconnect etc.
//

// Clock Generation
initial
  ddr_sys_clk_i = 1'b0;
always
  ddr_sys_clk_i = #(CLKIN_PERIOD/2.0) ~ddr_sys_clk_i;

assign ddr_sys_clk_p = ddr_sys_clk_i;
assign ddr_sys_clk_n = ~ddr_sys_clk_i;

assign init_calib_complete = 1'b1;

initial
  clk_ref_i = 1'b0;
always
  clk_ref_i = #REFCLK_PERIOD ~clk_ref_i;

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
//assign ddr3_cs_n_sdram =  {(CS_WIDTH*nCS_PER_RANK){1'b0}};

always @( * )
  ddr3_dm_sdram_tmp <=  #(TPROP_PCB_DATA) ddr3_dm_fpga;//DM signal generation
assign ddr3_dm_sdram = ddr3_dm_sdram_tmp;

always @( * )
  ddr3_odt_sdram_tmp  <=  #(TPROP_PCB_CTRL) ddr3_odt_fpga;
assign ddr3_odt_sdram =  ddr3_odt_sdram_tmp;

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
//

// Randoms generated for process flow
always @(posedge board.EP.bpm_pcie_i.user_clk) begin
  Op_Random[ 31:00] = $random();
  Op_Random[ 63:32] = $random();
  Op_Random[ 95:64] = $random();
  Op_Random[127:96] = $random();
end

  // Initialization mem in host
initial begin
  for (ii = 0; ii< `C_ARRAY_DIMENSION; ii= ii+1) begin
`ifdef  RANDOM_SEQUENCE
    D_Array[ii]    <= $random ();
`else
    D_Array[ii]    <= Inv_Endian ('H8760_0000 + ii + 1);
`endif
  end
end


initial begin
  $display("[%t] : System Reset Asserted...", $realtime);
  sys_rst_n = 1'b0;

  for (i = 0; i < 500; i = i + 1) begin
    @(posedge ep_sys_clk_p);
  end

  $display("[%t] : System Reset De-asserted...", $realtime);
  sys_rst_n = 1'b1;
end

initial begin
  if ($test$plusargs ("dump_all")) begin

`ifdef NCV // Cadence TRN dump

    $recordsetup("design=board",
                 "compress",
                 "wrapsize=100M",
                 "version=1",
                 "run=1");
    $recordvars();

`elsif VCS //Synopsys VPD dump

    $vcdplusfile("board.vpd");
    $vcdpluson;
    $vcdplusglitchon;
    $vcdplusflush;

`else

    // Verilog VC dump
    $dumpfile("board.vcd");
    $dumpvars(0, board);

`endif

  end
end

endmodule // BOARD
