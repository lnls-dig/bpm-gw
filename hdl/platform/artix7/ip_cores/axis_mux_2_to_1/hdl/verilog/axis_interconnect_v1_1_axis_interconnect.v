// (c) Copyright 2011-2012 Xilinx, Inc. All rights reserved.
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
//-----------------------------------------------------------------------------
//
// Verilog-standard:  Verilog 2001
//--------------------------------------------------------------------------
//
// Structure:
//   axis_interconnect
//
//--------------------------------------------------------------------------

`timescale 1ps/1ps
`default_nettype none

module axis_interconnect_v1_1_axis_interconnect #
(
///////////////////////////////////////////////////////////////////////////////
// Parameter Definitions
///////////////////////////////////////////////////////////////////////////////
   // C_AXIS_SIGNAL_SET: each bit if enabled specifies which axis optional signals are present
   //   [0] => TREADY present
   //   [1] => TDATA present
   //   [2] => TSTRB present, TDATA must be present
   //   [3] => TKEEP present, TDATA must be present
   //   [4] => TLAST present
   //   [5] => TID present
   //   [6] => TDEST present
   //   [7] => TUSER present
   // Generate Parameters
   parameter         C_FAMILY               = "virtex7",
                                                     
   parameter integer C_NUM_MI_SLOTS         = 1,
   parameter integer C_NUM_SI_SLOTS         = 1,
                                                     
   parameter integer C_AXIS_TDATA_MAX_WIDTH = 8,
   parameter integer C_AXIS_TUSER_MAX_WIDTH = 1,

   parameter integer C_SWITCH_MI_REG_CONFIG = 0,
   parameter integer C_SWITCH_SI_REG_CONFIG = 1,
   parameter integer C_SWITCH_MODE          = 33,
   // C_SWITCH_MODE
   // 0 - External Arbiter
   // 1 - Internal Arbiter: Round Robin
   // 2 - Internal Arbiter: Fixed
   // 3-31 - Internal Arbiter: Reserved
   // 32 - External Arbiter: Packet Mode
   // 33 - Internal Arbiter: Round Robin: Packet Mode
   // 34 - Internal Arbiter: Fixed: Packet Mode
   // 35 - Internal Arbiter: Reserved: Packet Mode
   parameter integer C_SWITCH_MAX_XFERS_PER_ARB = 0,
   // C_MAX_XFERS_PER_ARB: 
   //  0 => Ignore number of transfers to signal DONE
   //  1+ => Signal ARB_DONE after x TRANSFERS
   parameter integer C_SWITCH_NUM_CYCLES_TIMEOUT = 0,
   // C_NUM_CYCLE_TIMEOUT: 
   //  0 => Ignore TIMEOUT parameter
   //  1+ => Signal ARB_DONE after x cylces of TVALID low

   // Switch Parameters
   parameter integer C_SWITCH_TDATA_WIDTH     = 32,
   parameter integer C_SWITCH_TID_WIDTH       = 1,
   parameter integer C_SWITCH_TDEST_WIDTH     = 1,
   parameter integer C_SWITCH_TUSER_WIDTH     = 1,
   parameter [31:0]  C_SWITCH_SIGNAL_SET      = 32'h7F,
   parameter integer C_SWITCH_ACLK_RATIO      = 1,
   parameter integer C_SWITCH_USE_ACLKEN      = 0,
   parameter [C_NUM_MI_SLOTS*C_NUM_SI_SLOTS-1:0] C_M_AXIS_CONNECTIVITY_ARRAY = {C_NUM_MI_SLOTS*C_NUM_SI_SLOTS{1'b1}},
   parameter [C_NUM_MI_SLOTS*C_SWITCH_TDEST_WIDTH-1:0] C_M_AXIS_BASETDEST_ARRAY = {2'b11,2'b10,2'b01,2'b00},
   parameter [C_NUM_MI_SLOTS*C_SWITCH_TDEST_WIDTH-1:0] C_M_AXIS_HIGHTDEST_ARRAY = {2'b11,2'b10,2'b01,2'b00},


   // Datapath parameters
   parameter [C_NUM_SI_SLOTS*32-1:0] C_S_AXIS_TDATA_WIDTH_ARRAY    = {C_NUM_SI_SLOTS{32'd8}},
   parameter [C_NUM_SI_SLOTS*32-1:0] C_S_AXIS_TUSER_WIDTH_ARRAY    = {C_NUM_SI_SLOTS{32'd1}},
   parameter [C_NUM_SI_SLOTS*32-1:0] C_S_AXIS_IS_ACLK_ASYNC_ARRAY  = {C_NUM_SI_SLOTS{32'd0}},
   parameter [C_NUM_SI_SLOTS*32-1:0] C_S_AXIS_ACLK_RATIO_ARRAY     = {C_NUM_SI_SLOTS{32'd1}},
   parameter [C_NUM_SI_SLOTS*32-1:0] C_S_AXIS_REG_CONFIG_ARRAY     = {C_NUM_SI_SLOTS{32'd1}},
   parameter [C_NUM_SI_SLOTS*32-1:0] C_S_AXIS_FIFO_DEPTH_ARRAY     = {C_NUM_SI_SLOTS{32'd32}},
   parameter [C_NUM_SI_SLOTS*32-1:0] C_S_AXIS_FIFO_MODE_ARRAY      = {C_NUM_SI_SLOTS{32'd0}},

   parameter [C_NUM_MI_SLOTS*32-1:0] C_M_AXIS_TDATA_WIDTH_ARRAY    = {C_NUM_MI_SLOTS{32'd8}},
   parameter [C_NUM_MI_SLOTS*32-1:0] C_M_AXIS_TUSER_WIDTH_ARRAY    = {C_NUM_MI_SLOTS{32'd1}},
   parameter [C_NUM_MI_SLOTS*32-1:0] C_M_AXIS_ACLK_RATIO_ARRAY     = {C_NUM_MI_SLOTS{32'd1}},
   parameter [C_NUM_MI_SLOTS*32-1:0] C_M_AXIS_REG_CONFIG_ARRAY     = {C_NUM_MI_SLOTS{32'd1}},
   parameter [C_NUM_MI_SLOTS*32-1:0] C_M_AXIS_IS_ACLK_ASYNC_ARRAY  = {C_NUM_MI_SLOTS{32'd0}},
   parameter [C_NUM_MI_SLOTS*32-1:0] C_M_AXIS_FIFO_DEPTH_ARRAY     = {C_NUM_MI_SLOTS{32'd32}},
   parameter [C_NUM_MI_SLOTS*32-1:0] C_M_AXIS_FIFO_MODE_ARRAY      = {C_NUM_MI_SLOTS{32'd0}}

   )
  (
///////////////////////////////////////////////////////////////////////////////
// Port Declarations
///////////////////////////////////////////////////////////////////////////////
   // System Signals
   input wire ACLK,
   input wire ARESETN,
   input wire ACLKEN,

   // Slave side
   input wire  [C_NUM_SI_SLOTS*1-1:0]                        S_AXIS_ACLK,
   input wire  [C_NUM_SI_SLOTS*1-1:0]                        S_AXIS_ARESETN,
   input wire  [C_NUM_SI_SLOTS*1-1:0]                        S_AXIS_ACLKEN,
   input  wire [C_NUM_SI_SLOTS*1-1:0]                        S_AXIS_TVALID,
   output wire [C_NUM_SI_SLOTS*1-1:0]                        S_AXIS_TREADY,
   input  wire [C_NUM_SI_SLOTS*C_AXIS_TDATA_MAX_WIDTH-1:0]   S_AXIS_TDATA,
   input  wire [C_NUM_SI_SLOTS*C_AXIS_TDATA_MAX_WIDTH/8-1:0] S_AXIS_TSTRB,
   input  wire [C_NUM_SI_SLOTS*C_AXIS_TDATA_MAX_WIDTH/8-1:0] S_AXIS_TKEEP,
   input  wire [C_NUM_SI_SLOTS*1-1:0]                        S_AXIS_TLAST,
   input  wire [C_NUM_SI_SLOTS*C_SWITCH_TID_WIDTH-1:0]       S_AXIS_TID,
   input  wire [C_NUM_SI_SLOTS*C_SWITCH_TDEST_WIDTH-1:0]     S_AXIS_TDEST,
   input  wire [C_NUM_SI_SLOTS*C_AXIS_TUSER_MAX_WIDTH-1:0]   S_AXIS_TUSER,

   // Master side
   input wire  [C_NUM_MI_SLOTS*1-1:0]                        M_AXIS_ACLK,
   input wire  [C_NUM_MI_SLOTS*1-1:0]                        M_AXIS_ARESETN,
   input wire  [C_NUM_MI_SLOTS*1-1:0]                        M_AXIS_ACLKEN,
   output wire [C_NUM_MI_SLOTS*1-1:0]                        M_AXIS_TVALID,
   input  wire [C_NUM_MI_SLOTS*1-1:0]                        M_AXIS_TREADY,
   output wire [C_NUM_MI_SLOTS*C_AXIS_TDATA_MAX_WIDTH-1:0]   M_AXIS_TDATA,
   output wire [C_NUM_MI_SLOTS*C_AXIS_TDATA_MAX_WIDTH/8-1:0] M_AXIS_TSTRB,
   output wire [C_NUM_MI_SLOTS*C_AXIS_TDATA_MAX_WIDTH/8-1:0] M_AXIS_TKEEP,
   output wire [C_NUM_MI_SLOTS*1-1:0]                        M_AXIS_TLAST,
   output wire [C_NUM_MI_SLOTS*C_SWITCH_TID_WIDTH-1:0]       M_AXIS_TID,
   output wire [C_NUM_MI_SLOTS*C_SWITCH_TDEST_WIDTH-1:0]     M_AXIS_TDEST,
   output wire [C_NUM_MI_SLOTS*C_AXIS_TUSER_MAX_WIDTH-1:0]   M_AXIS_TUSER,

   // Control/Status signals
   input wire  [C_NUM_SI_SLOTS*1-1:0]                        S_ARB_REQ_SUPPRESS,
   output wire [C_NUM_SI_SLOTS*1-1:0]                        S_DECODE_ERR,
   output wire [C_NUM_SI_SLOTS*1-1:0]                        S_SPARSE_TKEEP_REMOVED,
   output wire [C_NUM_SI_SLOTS*1-1:0]                        S_PACKER_ERR,
   output wire [C_NUM_SI_SLOTS*32-1:0]                       S_FIFO_DATA_COUNT,
   output wire [C_NUM_MI_SLOTS*1-1:0]                        M_SPARSE_TKEEP_REMOVED,
   output wire [C_NUM_MI_SLOTS*1-1:0]                        M_PACKER_ERR,
   output wire [C_NUM_MI_SLOTS*32-1:0]                       M_FIFO_DATA_COUNT
   );

////////////////////////////////////////////////////////////////////////////////
// Functions
////////////////////////////////////////////////////////////////////////////////
 `include "axis_interconnect_v1_1_axis_infrastructure.vh"

////////////////////////////////////////////////////////////////////////////////
// Local parameters
////////////////////////////////////////////////////////////////////////////////
// Dynamic Datapath index values
localparam integer P_INDX_DP_PASS_THRU = 32'd0;
localparam integer P_INDX_DP_REG_SLICE = 32'd1;
localparam integer P_INDX_DP_SS_CONV   = 32'd2;
localparam integer P_INDX_DP_DW_CONV   = 32'd3;
localparam integer P_INDX_DP_DW_CONV_U = 32'd4;
localparam integer P_INDX_DP_DW_CONV_D = 32'd5;
localparam integer P_INDX_DP_CK_CONV   = 32'd6;
localparam integer P_INDX_DP_DATA_FIFO = 32'd7;
localparam integer P_INDX_DP_PACKER    = 32'd8;

localparam P_LOG_SI_SLOTS = f_clogb2(C_NUM_SI_SLOTS);
localparam P_GEN_SWITCH = (C_NUM_MI_SLOTS == 1) && (C_NUM_SI_SLOTS == 1) ? 0 : 1;

localparam [31:0]  P_SS_TKEEP_REQUIRED = (C_SWITCH_SIGNAL_SET & (`G_MASK_SS_TID | `G_MASK_SS_TDEST | `G_MASK_SS_TLAST)) 
                                          ? `G_MASK_SS_TKEEP : 32'h0;
// TREADY/TDATA must always be present
localparam [31:0]  P_SWITCH_SIGNAL_SET  = C_SWITCH_SIGNAL_SET | P_SS_TKEEP_REQUIRED;
localparam [31:0]  P_SI_SIGNAL_SET = C_SWITCH_SIGNAL_SET;
localparam [31:0]  P_MI_SIGNAL_SET = C_SWITCH_SIGNAL_SET;
localparam [31:0]  P_ACLKEN_CONV_MODE = C_SWITCH_USE_ACLKEN ? 3 : 0;


// Define the order of the modules in the dynamic datapath.  Instantied from
// left to right.
localparam P_SI_MODULE_ORDER = { 
                                 P_INDX_DP_SS_CONV,
                                 P_INDX_DP_REG_SLICE,
                                 P_INDX_DP_DW_CONV_U,
                                 P_INDX_DP_CK_CONV,
                                 P_INDX_DP_DW_CONV_D,
                                 P_INDX_DP_PACKER,
                                 P_INDX_DP_DATA_FIFO
                               };

localparam P_MI_MODULE_ORDER = { 
                                 P_INDX_DP_DATA_FIFO,
                                 P_INDX_DP_DW_CONV_U,
                                 P_INDX_DP_CK_CONV,
                                 P_INDX_DP_DW_CONV_D,
                                 P_INDX_DP_PACKER,
                                 P_INDX_DP_SS_CONV,
                                 P_INDX_DP_REG_SLICE
                               };
                               
////////////////////////////////////////////////////////////////////////////////
// Wires/Reg declarations
////////////////////////////////////////////////////////////////////////////////

wire [C_NUM_SI_SLOTS-1:0]                        si_tvalid;
wire [C_NUM_SI_SLOTS-1:0]                        si_tready;
wire [C_NUM_SI_SLOTS*C_SWITCH_TDATA_WIDTH-1:0]   si_tdata;
wire [C_NUM_SI_SLOTS*C_SWITCH_TDATA_WIDTH/8-1:0] si_tstrb;
wire [C_NUM_SI_SLOTS*C_SWITCH_TDATA_WIDTH/8-1:0] si_tkeep;
wire [C_NUM_SI_SLOTS-1:0]                        si_tlast;
wire [C_NUM_SI_SLOTS*C_SWITCH_TID_WIDTH-1:0]     si_tid;
wire [C_NUM_SI_SLOTS*C_SWITCH_TDEST_WIDTH-1:0]   si_tdest;
wire [C_NUM_SI_SLOTS*C_SWITCH_TUSER_WIDTH-1:0]   si_tuser;

wire [C_NUM_MI_SLOTS-1:0]                        mi_tvalid;
wire [C_NUM_MI_SLOTS-1:0]                        mi_tready;
wire [C_NUM_MI_SLOTS*C_SWITCH_TDATA_WIDTH-1:0]   mi_tdata;
wire [C_NUM_MI_SLOTS*C_SWITCH_TDATA_WIDTH/8-1:0] mi_tstrb;
wire [C_NUM_MI_SLOTS*C_SWITCH_TDATA_WIDTH/8-1:0] mi_tkeep;
wire [C_NUM_MI_SLOTS-1:0]                        mi_tlast;
wire [C_NUM_MI_SLOTS*C_SWITCH_TID_WIDTH-1:0]     mi_tid;
wire [C_NUM_MI_SLOTS*C_SWITCH_TDEST_WIDTH-1:0]   mi_tdest;
wire [C_NUM_MI_SLOTS*C_SWITCH_TUSER_WIDTH-1:0]   mi_tuser;

// BEGIN RTL
////////////////////////////////////////////////////////////////////////////////

// Instantiate switch
generate
  genvar si; 
  genvar mi;
  if (P_GEN_SWITCH) begin : gen_switch
    axis_interconnect_v1_1_axis_switch #(
      .C_FAMILY                    ( C_FAMILY                    ) ,
      .C_AXIS_TDATA_WIDTH          ( C_SWITCH_TDATA_WIDTH        ) ,
      .C_AXIS_TID_WIDTH            ( C_SWITCH_TID_WIDTH          ) ,
      .C_AXIS_TDEST_WIDTH          ( C_SWITCH_TDEST_WIDTH        ) ,
      .C_AXIS_TUSER_WIDTH          ( C_SWITCH_TUSER_WIDTH        ) ,
      .C_AXIS_SIGNAL_SET           ( P_SWITCH_SIGNAL_SET         ) ,
      .C_SI_REG_CONFIG             ( C_SWITCH_SI_REG_CONFIG      ) ,
      .C_MI_REG_CONFIG             ( C_SWITCH_MI_REG_CONFIG      ) ,
      .C_NUM_SI_SLOTS              ( C_NUM_SI_SLOTS              ) ,
      .C_LOG_SI_SLOTS              ( P_LOG_SI_SLOTS              ) ,
      .C_NUM_MI_SLOTS              ( C_NUM_MI_SLOTS              ) ,
      .C_SWITCH_MODE               ( C_SWITCH_MODE               ) ,
      .C_MAX_XFERS_PER_ARB         ( C_SWITCH_MAX_XFERS_PER_ARB  ) ,
      .C_NUM_CYCLES_TIMEOUT        ( C_SWITCH_NUM_CYCLES_TIMEOUT ) ,
      .C_M_AXIS_CONNECTIVITY_ARRAY ( C_M_AXIS_CONNECTIVITY_ARRAY ) ,
      .C_M_AXIS_BASETDEST_ARRAY    ( C_M_AXIS_BASETDEST_ARRAY    ) ,
      .C_M_AXIS_HIGHTDEST_ARRAY    ( C_M_AXIS_HIGHTDEST_ARRAY    ) 
    )
    axis_switch_0 ( 
      .ACLK          ( ACLK            ) ,
      .ARESETN       ( ARESETN         ) ,
      .ACLKEN        ( C_SWITCH_USE_ACLKEN ? ACLKEN : 1'b1 ) ,
      .S_AXIS_TVALID ( si_tvalid       ) ,
      .S_AXIS_TREADY ( si_tready       ) ,
      .S_AXIS_TDATA  ( si_tdata        ) ,
      .S_AXIS_TSTRB  ( si_tstrb        ) ,
      .S_AXIS_TKEEP  ( si_tkeep        ) ,
      .S_AXIS_TLAST  ( si_tlast        ) ,
      .S_AXIS_TID    ( si_tid          ) ,
      .S_AXIS_TDEST  ( si_tdest        ) ,
      .S_AXIS_TUSER  ( si_tuser        ) ,
      .M_AXIS_TVALID ( mi_tvalid       ) ,
      .M_AXIS_TREADY ( mi_tready       ) ,
      .M_AXIS_TDATA  ( mi_tdata        ) ,
      .M_AXIS_TSTRB  ( mi_tstrb        ) ,
      .M_AXIS_TKEEP  ( mi_tkeep        ) ,
      .M_AXIS_TLAST  ( mi_tlast        ) ,
      .M_AXIS_TID    ( mi_tid          ) ,
      .M_AXIS_TDEST  ( mi_tdest        ) ,
      .M_AXIS_TUSER  ( mi_tuser        ) ,
      .ARB_REQ       (                 ) ,
      .ARB_GNT       (                 ) ,
      .ARB_BUSY      (                 ) ,
      .ARB_LAST      (                 ) ,
      .ARB_ID        (                 ) ,
      .ARB_DEST      (                 ) ,
      .ARB_USER      (                 ) ,
      .ARB_REQ_SUPPRESS ( S_ARB_REQ_SUPPRESS ) ,
      .S_DECODE_ERR  ( S_DECODE_ERR    ) 
    );
  end
  else begin : gen_no_switch
    assign si_tready = mi_tready;
    assign mi_tvalid = si_tvalid;
    assign mi_tdata  = si_tdata;
    assign mi_tstrb  = si_tstrb;
    assign mi_tkeep  = si_tkeep;
    assign mi_tlast  = si_tlast;
    assign mi_tid    = si_tid;
    assign mi_tdest  = si_tdest;
    assign mi_tuser  = si_tuser;
    assign S_DECODE_ERR = 1'b0;
  end

  for (si = 0 ; si < C_NUM_SI_SLOTS; si = si + 1) begin : inst_si_datapath
    axis_interconnect_v1_1_dynamic_datapath # ( 
      .C_FAMILY             ( C_FAMILY                                   ) ,
      .C_S_AXIS_TDATA_WIDTH ( C_S_AXIS_TDATA_WIDTH_ARRAY [ si*32+:32 ]   ) ,
      .C_S_AXIS_TID_WIDTH   ( C_SWITCH_TID_WIDTH                         ) ,
      .C_S_AXIS_TDEST_WIDTH ( C_SWITCH_TDEST_WIDTH                       ) ,
      .C_S_AXIS_TUSER_WIDTH ( C_S_AXIS_TUSER_WIDTH_ARRAY [ si*32+:32 ]   ) ,
      .C_S_AXIS_SIGNAL_SET  ( P_SI_SIGNAL_SET                            ) ,
      .C_S_AXIS_ACLK_RATIO  ( C_S_AXIS_ACLK_RATIO_ARRAY  [ si*32+:32 ]   ) ,
      .C_M_AXIS_TDATA_WIDTH ( C_SWITCH_TDATA_WIDTH                       ) ,
      .C_M_AXIS_TID_WIDTH   ( C_SWITCH_TID_WIDTH                         ) ,
      .C_M_AXIS_TDEST_WIDTH ( C_SWITCH_TDEST_WIDTH                       ) ,
      .C_M_AXIS_TUSER_WIDTH ( C_SWITCH_TUSER_WIDTH                       ) ,
      .C_M_AXIS_SIGNAL_SET  ( P_SWITCH_SIGNAL_SET                        ) ,
      .C_M_AXIS_ACLK_RATIO  ( C_SWITCH_ACLK_RATIO                        ) ,
      .C_ACLKEN_CONV_MODE   ( P_ACLKEN_CONV_MODE                         ) ,
      .C_REG_CONFIG         ( C_S_AXIS_REG_CONFIG_ARRAY    [ si*32+:32 ] ) ,
      .C_IS_ACLK_ASYNC      ( C_S_AXIS_IS_ACLK_ASYNC_ARRAY [ si*32+:32 ] ) ,
      .C_FIFO_DEPTH         ( C_S_AXIS_FIFO_DEPTH_ARRAY    [ si*32+:32 ] ) ,
      .C_FIFO_MODE          ( C_S_AXIS_FIFO_MODE_ARRAY     [ si*32+:32 ] ) ,
      .C_MODULE_ORDER       ( P_SI_MODULE_ORDER                          )
    )
    dynamic_datapath_si ( 
      .S_AXIS_ACLK       ( S_AXIS_ACLK       [ si                                                               ] ) ,
      .S_AXIS_ARESETN    ( S_AXIS_ARESETN    [ si                                                               ] ) ,
      .S_AXIS_ACLKEN     ( C_SWITCH_USE_ACLKEN ? S_AXIS_ACLKEN [ si ] : 1'b1                                      ) ,
      .S_AXIS_TVALID     ( S_AXIS_TVALID     [ si                                                               ] ) ,
      .S_AXIS_TREADY     ( S_AXIS_TREADY     [ si                                                               ] ) ,
      .S_AXIS_TDATA      ( S_AXIS_TDATA      [ si*C_AXIS_TDATA_MAX_WIDTH+:C_S_AXIS_TDATA_WIDTH_ARRAY[si*32+:32] ] ) ,
      .S_AXIS_TSTRB      ( S_AXIS_TSTRB      [ si*C_AXIS_TDATA_MAX_WIDTH/8+:C_S_AXIS_TDATA_WIDTH_ARRAY[si*32+:32]/8 ] ) ,
      .S_AXIS_TKEEP      ( S_AXIS_TKEEP      [ si*C_AXIS_TDATA_MAX_WIDTH/8+:C_S_AXIS_TDATA_WIDTH_ARRAY[si*32+:32]/8 ] ) ,
      .S_AXIS_TLAST      ( S_AXIS_TLAST      [ si                                                               ] ) ,
      .S_AXIS_TID        ( S_AXIS_TID        [ si*C_SWITCH_TID_WIDTH+:C_SWITCH_TID_WIDTH                      ] ) ,
      .S_AXIS_TDEST      ( S_AXIS_TDEST      [ si*C_SWITCH_TDEST_WIDTH+:C_SWITCH_TDEST_WIDTH                  ] ) ,
      .S_AXIS_TUSER      ( S_AXIS_TUSER      [ si*C_AXIS_TUSER_MAX_WIDTH+:C_S_AXIS_TUSER_WIDTH_ARRAY[si*32+:32] ] ) ,
      .M_AXIS_ACLK       ( ACLK                                                                         ) ,
      .M_AXIS_ARESETN    ( ARESETN                                                                      ) ,
      .M_AXIS_ACLKEN     ( C_SWITCH_USE_ACLKEN ? ACLKEN : 1'b1                                      ) ,
      .M_AXIS_TVALID     ( si_tvalid         [ si                                                ]  ) ,
      .M_AXIS_TREADY     ( si_tready         [ si                                                ]  ) ,
      .M_AXIS_TDATA      ( si_tdata          [ si*C_SWITCH_TDATA_WIDTH+:  C_SWITCH_TDATA_WIDTH   ]  ) ,
      .M_AXIS_TSTRB      ( si_tstrb          [ si*C_SWITCH_TDATA_WIDTH/8+:C_SWITCH_TDATA_WIDTH/8 ]  ) ,
      .M_AXIS_TKEEP      ( si_tkeep          [ si*C_SWITCH_TDATA_WIDTH/8+:C_SWITCH_TDATA_WIDTH/8 ]  ) ,
      .M_AXIS_TLAST      ( si_tlast          [ si                                                ]  ) ,
      .M_AXIS_TID        ( si_tid            [ si*C_SWITCH_TID_WIDTH+:C_SWITCH_TID_WIDTH         ]  ) ,
      .M_AXIS_TDEST      ( si_tdest          [ si*C_SWITCH_TDEST_WIDTH+:C_SWITCH_TDEST_WIDTH     ]  ) ,
      .M_AXIS_TUSER      ( si_tuser          [ si*C_SWITCH_TUSER_WIDTH+:C_SWITCH_TUSER_WIDTH     ]  ) ,
      .SPARSE_TKEEP_REMOVED ( S_SPARSE_TKEEP_REMOVED [ si ]                                         ) ,
      .PACKER_ERR        ( S_PACKER_ERR      [ si                                                ]  ) ,
      .M_FIFO_DATA_COUNT (                                                                          ) ,
      .S_FIFO_DATA_COUNT ( S_FIFO_DATA_COUNT [ si*32+:32                                         ]  )
    );
  end
  for (mi = 0 ; mi < C_NUM_MI_SLOTS; mi = mi + 1) begin : inst_mi_datapath
    axis_interconnect_v1_1_dynamic_datapath # ( 
      .C_FAMILY             ( C_FAMILY                                    ) ,
      .C_S_AXIS_TDATA_WIDTH ( C_SWITCH_TDATA_WIDTH                        ) ,
      .C_S_AXIS_TID_WIDTH   ( C_SWITCH_TID_WIDTH                          ) ,
      .C_S_AXIS_TDEST_WIDTH ( C_SWITCH_TDEST_WIDTH                        ) ,
      .C_S_AXIS_TUSER_WIDTH ( C_SWITCH_TUSER_WIDTH                        ) ,
      .C_S_AXIS_SIGNAL_SET  ( P_SWITCH_SIGNAL_SET                         ) ,
      .C_S_AXIS_ACLK_RATIO  ( C_SWITCH_ACLK_RATIO                         ) ,
      .C_ACLKEN_CONV_MODE   ( P_ACLKEN_CONV_MODE                          ) ,
      .C_M_AXIS_TDATA_WIDTH ( C_M_AXIS_TDATA_WIDTH_ARRAY   [ mi*32+:32 ]  ) ,
      .C_M_AXIS_TID_WIDTH   ( C_SWITCH_TID_WIDTH                          ) ,
      .C_M_AXIS_TDEST_WIDTH ( C_SWITCH_TDEST_WIDTH                        ) ,
      .C_M_AXIS_TUSER_WIDTH ( C_M_AXIS_TUSER_WIDTH_ARRAY   [ mi*32+:32 ]  ) ,
      .C_M_AXIS_SIGNAL_SET  ( P_MI_SIGNAL_SET                             ) ,
      .C_M_AXIS_ACLK_RATIO  ( C_M_AXIS_ACLK_RATIO_ARRAY    [ mi*32+:32 ]  ) ,
      .C_REG_CONFIG         ( C_M_AXIS_REG_CONFIG_ARRAY    [ mi*32+:32 ]  ) ,
      .C_IS_ACLK_ASYNC      ( C_M_AXIS_IS_ACLK_ASYNC_ARRAY [ mi*32+:32 ]  ) ,
      .C_FIFO_DEPTH         ( C_M_AXIS_FIFO_DEPTH_ARRAY    [ mi*32+:32 ]  ) ,
      .C_FIFO_MODE          ( C_M_AXIS_FIFO_MODE_ARRAY     [ mi*32+:32 ]  ) ,
      .C_MODULE_ORDER       ( P_MI_MODULE_ORDER                           )
    )
    dynamic_datapath_mi ( 
      .S_AXIS_ACLK       ( ACLK                                                                                          ) ,
      .S_AXIS_ARESETN    ( ARESETN                                                                                       ) ,
      .S_AXIS_ACLKEN     ( C_SWITCH_USE_ACLKEN ? ACLKEN : 1'b1                                                           ) ,
      .S_AXIS_TVALID     ( mi_tvalid            [ mi                                                                   ] ) ,
      .S_AXIS_TREADY     ( mi_tready            [ mi                                                                   ] ) ,
      .S_AXIS_TDATA      ( mi_tdata             [ mi*C_SWITCH_TDATA_WIDTH+:C_SWITCH_TDATA_WIDTH                        ] ) ,
      .S_AXIS_TSTRB      ( mi_tstrb             [ mi*C_SWITCH_TDATA_WIDTH/8+:C_SWITCH_TDATA_WIDTH/8                    ] ) ,
      .S_AXIS_TKEEP      ( mi_tkeep             [ mi*C_SWITCH_TDATA_WIDTH/8+:C_SWITCH_TDATA_WIDTH/8                    ] ) ,
      .S_AXIS_TLAST      ( mi_tlast             [ mi                                                                   ] ) ,
      .S_AXIS_TID        ( mi_tid               [ mi*C_SWITCH_TID_WIDTH+:C_SWITCH_TID_WIDTH                            ] ) ,
      .S_AXIS_TDEST      ( mi_tdest             [ mi*C_SWITCH_TDEST_WIDTH+:C_SWITCH_TDEST_WIDTH                        ] ) ,
      .S_AXIS_TUSER      ( mi_tuser             [ mi*C_SWITCH_TUSER_WIDTH+:C_SWITCH_TUSER_WIDTH                        ] ) ,
      .M_AXIS_ACLK       ( M_AXIS_ACLK          [ mi                                                                   ] ) ,
      .M_AXIS_ARESETN    ( M_AXIS_ARESETN       [ mi                                                                   ] ) ,
      .M_AXIS_ACLKEN     ( C_SWITCH_USE_ACLKEN ? M_AXIS_ACLKEN [ mi ]  : 1'b1                                            ) ,
      .M_AXIS_TVALID     ( M_AXIS_TVALID        [ mi                                                                   ] ) ,
      .M_AXIS_TREADY     ( M_AXIS_TREADY        [ mi                                                                   ] ) ,
      .M_AXIS_TDATA      ( M_AXIS_TDATA         [ mi*C_AXIS_TDATA_MAX_WIDTH+:C_M_AXIS_TDATA_WIDTH_ARRAY[mi*32+:32]     ] ) ,
      .M_AXIS_TSTRB      ( M_AXIS_TSTRB         [ mi*C_AXIS_TDATA_MAX_WIDTH/8+:C_M_AXIS_TDATA_WIDTH_ARRAY[mi*32+:32]/8 ] ) ,
      .M_AXIS_TKEEP      ( M_AXIS_TKEEP         [ mi*C_AXIS_TDATA_MAX_WIDTH/8+:C_M_AXIS_TDATA_WIDTH_ARRAY[mi*32+:32]/8 ] ) ,
      .M_AXIS_TLAST      ( M_AXIS_TLAST         [ mi                                                                   ] ) ,
      .M_AXIS_TID        ( M_AXIS_TID           [ mi*C_SWITCH_TID_WIDTH+:C_SWITCH_TID_WIDTH                              ] ) ,
      .M_AXIS_TDEST      ( M_AXIS_TDEST         [ mi*C_SWITCH_TDEST_WIDTH+:C_SWITCH_TDEST_WIDTH                          ] ) ,
      .M_AXIS_TUSER      ( M_AXIS_TUSER         [ mi*C_AXIS_TUSER_MAX_WIDTH+:C_M_AXIS_TUSER_WIDTH_ARRAY[mi*32+:32]     ] ) ,
      .SPARSE_TKEEP_REMOVED ( M_SPARSE_TKEEP_REMOVED [ mi                                                              ] ) ,
      .PACKER_ERR        ( M_PACKER_ERR         [ mi                                                                   ] ) ,
      .S_FIFO_DATA_COUNT (                                                                                               ) ,
      .M_FIFO_DATA_COUNT   ( M_FIFO_DATA_COUNT  [ mi*32+:32                                                            ] ) 
    );
  end
endgenerate

endmodule // axis_interconnect

`default_nettype wire
