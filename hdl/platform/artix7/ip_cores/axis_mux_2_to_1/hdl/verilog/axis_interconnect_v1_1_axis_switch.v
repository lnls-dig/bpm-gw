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
//   axis_switch
//
//--------------------------------------------------------------------------

`timescale 1ps/1ps
`default_nettype none

module axis_interconnect_v1_1_axis_switch #
(
///////////////////////////////////////////////////////////////////////////////
// Parameter Definitions
///////////////////////////////////////////////////////////////////////////////
   parameter         C_FAMILY            = "virtex7",
   parameter integer C_AXIS_TDATA_WIDTH  = 32,
   parameter integer C_AXIS_TID_WIDTH    = 1,
   parameter integer C_AXIS_TDEST_WIDTH  = 2,
   parameter integer C_AXIS_TUSER_WIDTH  = 1,
   parameter [31:0]  C_AXIS_SIGNAL_SET   = 32'hFF,
   // C_AXIS_SIGNAL_SET: each bit if enabled specifies which axis optional signals are present
   //   [0] => TREADY present
   //   [1] => TDATA present
   //   [2] => TSTRB present, TDATA must be present
   //   [3] => TKEEP present, TDATA must be present
   //   [4] => TLAST present
   //   [5] => TID present
   //   [6] => TDEST present
   //   [7] => TUSER present
   parameter integer C_MI_REG_CONFIG     = 0,
   parameter integer C_SI_REG_CONFIG     = 1,
   parameter integer C_NUM_SI_SLOTS      = 4,
   parameter integer C_LOG_SI_SLOTS      = 2,
   parameter integer C_NUM_MI_SLOTS      = 4,
   // 0 - External Arbiter
   // 1 - Internal Arbiter: Round Robin
   // 2 - Internal Arbiter: Fixed
   // 3-31 - Internal Arbiter: Reserved
   // 32 - External Arbiter: Packet Mode
   // 33 - Internal Arbiter: Round Robin: Packet Mode
   // 34 - Internal Arbiter: Fixed: Packet Mode
   // 35 - Internal Arbiter: Reserved: Packet Mode
   parameter integer C_SWITCH_MODE       = 33,
   parameter integer C_MAX_XFERS_PER_ARB = 0,
   // C_MAX_XFERS_PER_ARB: 
   //  0 => Ignore number of transfers to signal DONE
   //  1+ => Signal ARB_DONE after x TRANSFERS
   parameter integer C_NUM_CYCLES_TIMEOUT = 0,
   // C_NUM_CYCLE_TIMEOUT: 
   //  0 => Ignore TIMEOUT parameter
   //  1+ => Signal ARB_DONE after x cylces of TVALID low
   parameter [C_NUM_MI_SLOTS*C_NUM_SI_SLOTS-1:0] C_M_AXIS_CONNECTIVITY_ARRAY = {C_NUM_MI_SLOTS*C_NUM_SI_SLOTS{1'b1}},
   parameter [C_NUM_MI_SLOTS*C_AXIS_TDEST_WIDTH-1:0] C_M_AXIS_BASETDEST_ARRAY = {C_NUM_MI_SLOTS*C_AXIS_TDEST_WIDTH{1'b1}},
   parameter [C_NUM_MI_SLOTS*C_AXIS_TDEST_WIDTH-1:0] C_M_AXIS_HIGHTDEST_ARRAY = {C_NUM_MI_SLOTS*C_AXIS_TDEST_WIDTH{1'b0}}

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
   input  wire [C_NUM_SI_SLOTS-1:0]                                   S_AXIS_TVALID,
   output wire [C_NUM_SI_SLOTS-1:0]                                   S_AXIS_TREADY,
   input  wire [C_NUM_SI_SLOTS*C_AXIS_TDATA_WIDTH-1:0]                S_AXIS_TDATA,
   input  wire [C_NUM_SI_SLOTS*C_AXIS_TDATA_WIDTH/8-1:0]              S_AXIS_TSTRB,
   input  wire [C_NUM_SI_SLOTS*C_AXIS_TDATA_WIDTH/8-1:0]              S_AXIS_TKEEP,
   input  wire [C_NUM_SI_SLOTS-1:0]                                   S_AXIS_TLAST,
   input  wire [C_NUM_SI_SLOTS*C_AXIS_TID_WIDTH-1:0]                  S_AXIS_TID,
   input  wire [C_NUM_SI_SLOTS*C_AXIS_TDEST_WIDTH-1:0]                S_AXIS_TDEST,
   input  wire [C_NUM_SI_SLOTS*C_AXIS_TUSER_WIDTH-1:0]                S_AXIS_TUSER,

   // Master side
   output wire [C_NUM_MI_SLOTS-1:0]                                   M_AXIS_TVALID,
   input  wire [C_NUM_MI_SLOTS-1:0]                                   M_AXIS_TREADY,
   output wire [C_NUM_MI_SLOTS*C_AXIS_TDATA_WIDTH-1:0]                M_AXIS_TDATA,
   output wire [C_NUM_MI_SLOTS*C_AXIS_TDATA_WIDTH/8-1:0]              M_AXIS_TSTRB,
   output wire [C_NUM_MI_SLOTS*C_AXIS_TDATA_WIDTH/8-1:0]              M_AXIS_TKEEP,
   output wire [C_NUM_MI_SLOTS-1:0]                                   M_AXIS_TLAST,
   output wire [C_NUM_MI_SLOTS*C_AXIS_TID_WIDTH-1:0]                  M_AXIS_TID,
   output wire [C_NUM_MI_SLOTS*C_AXIS_TDEST_WIDTH-1:0]                M_AXIS_TDEST,
   output wire [C_NUM_MI_SLOTS*C_AXIS_TUSER_WIDTH-1:0]                M_AXIS_TUSER ,
   
   // Arbiter interface
   output wire [C_NUM_MI_SLOTS*C_NUM_SI_SLOTS-1:0]                    ARB_REQ,
   input  wire [C_NUM_MI_SLOTS*C_NUM_SI_SLOTS-1:0]                    ARB_GNT,
   input  wire [C_NUM_MI_SLOTS-1:0]                                   ARB_BUSY,
   output wire [C_NUM_MI_SLOTS*C_NUM_SI_SLOTS-1:0]                    ARB_LAST,
   output wire [C_NUM_MI_SLOTS*C_NUM_SI_SLOTS*C_AXIS_TID_WIDTH-1:0]   ARB_ID,
   output wire [C_NUM_MI_SLOTS*C_NUM_SI_SLOTS*C_AXIS_TDEST_WIDTH-1:0] ARB_DEST,
   output wire [C_NUM_MI_SLOTS*C_NUM_SI_SLOTS*C_AXIS_TUSER_WIDTH-1:0] ARB_USER,
   input wire  [C_NUM_SI_SLOTS-1:0]                                   ARB_REQ_SUPPRESS,

   // Err output
   output wire [C_NUM_SI_SLOTS-1:0]                                   S_DECODE_ERR
   );

////////////////////////////////////////////////////////////////////////////////
// Functions
////////////////////////////////////////////////////////////////////////////////
function [C_NUM_MI_SLOTS*C_NUM_SI_SLOTS-1:0] f_transform_mxn_to_nxm (
  input integer                                    m_width,
  input integer                                    n_width,
  input [C_NUM_SI_SLOTS*C_NUM_MI_SLOTS-1:0] x
);
begin : main
  integer i;
  integer j;
  for (j = 0; j < n_width; j = j+1) begin
    for (i = 0; i < m_width; i = i+1) begin
      f_transform_mxn_to_nxm[j*m_width+i] = x[j+n_width*i];
    end
  end
end
endfunction

function [C_NUM_MI_SLOTS-1:0] f_calc_single_slave_connectivity_array (
  input integer                                    num_masters,
  input [C_NUM_SI_SLOTS*C_NUM_MI_SLOTS-1:0] x
);
begin : main
  integer i;
  integer j;
  for (j = 0; j < num_masters; j = j+1) begin
    f_calc_single_slave_connectivity_array[j] = (x[j*C_NUM_SI_SLOTS+:C_NUM_SI_SLOTS] & (x[j*C_NUM_SI_SLOTS+:C_NUM_SI_SLOTS]-1)) ? 1'b0 : 1'b1;
  end
end
endfunction

`include "axis_interconnect_v1_1_axis_infrastructure.vh"


////////////////////////////////////////////////////////////////////////////////
// Local parameters
////////////////////////////////////////////////////////////////////////////////
localparam P_DECODER_CONNECTIVITY_ARRAY = f_transform_mxn_to_nxm(C_NUM_MI_SLOTS, C_NUM_SI_SLOTS,C_M_AXIS_CONNECTIVITY_ARRAY);
localparam P_TPAYLOAD_WIDTH = f_payload_width(C_AXIS_TDATA_WIDTH, C_AXIS_TID_WIDTH, C_AXIS_TDEST_WIDTH, 
                                              C_AXIS_TUSER_WIDTH, C_AXIS_SIGNAL_SET);
localparam P_USE_PACKET_MODE  = (C_SWITCH_MODE >= 32 && C_NUM_SI_SLOTS > 1) ? 1 : 0; // Packet mode not enabled if only one SI slot.
   // PACKET_MODE: 
   //   0 => Ignore TLAST
   //   1 => Signal ARB_DONE on TLAST
localparam P_INTERNAL_ARBITER = ((C_SWITCH_MODE % 32) != 0) ? 1 : 0;
localparam P_ARB_ALGORITHM    = ((C_SWITCH_MODE % 32) == 1) ? "ROUND_ROBIN" : "FIXED";
localparam [C_NUM_MI_SLOTS-1:0] P_SINGLE_SLAVE_CONNECTIVITY_ARRAY = f_calc_single_slave_connectivity_array(C_NUM_MI_SLOTS, C_M_AXIS_CONNECTIVITY_ARRAY);

////////////////////////////////////////////////////////////////////////////////
// Wires/Reg declarations
////////////////////////////////////////////////////////////////////////////////
reg areset_r;

wire [C_NUM_SI_SLOTS*P_TPAYLOAD_WIDTH-1:0]     s_axis_tpayload;

// Wires between arbiter/decoder/transfer_mux
wire [ C_NUM_SI_SLOTS*C_NUM_MI_SLOTS-1:0                  ] dec_tvalid;
wire [ C_NUM_SI_SLOTS*C_NUM_MI_SLOTS-1:0                  ] dec_tready;
wire [ C_NUM_SI_SLOTS*P_TPAYLOAD_WIDTH-1:0                ] dec_tpayload;
wire [ C_NUM_SI_SLOTS*1-1:0                               ] dec_tlast;
wire [ C_NUM_SI_SLOTS*C_AXIS_TID_WIDTH-1:0                ] dec_tid;
wire [ C_NUM_SI_SLOTS*C_AXIS_TDEST_WIDTH-1:0              ] dec_tdest;
wire [ C_NUM_SI_SLOTS*C_AXIS_TUSER_WIDTH-1:0              ] dec_tuser;
wire [ C_NUM_SI_SLOTS*C_NUM_MI_SLOTS-1:0                  ] dec_arb_gnt;
wire [ C_NUM_SI_SLOTS*C_NUM_MI_SLOTS-1:0                  ] dec_arb_req;
wire [ C_NUM_SI_SLOTS*C_NUM_MI_SLOTS-1:0                  ] dec_arb_done;
wire [ C_NUM_SI_SLOTS*C_NUM_MI_SLOTS-1:0                  ] dec_arb_active;

wire [ C_NUM_MI_SLOTS*C_NUM_SI_SLOTS-1:0                  ] mux_tvalid;
wire [ C_NUM_MI_SLOTS*C_NUM_SI_SLOTS-1:0                  ] mux_tready;
wire [ C_NUM_MI_SLOTS*C_AXIS_TDATA_WIDTH-1:0              ] mux_tdata;
wire [ C_NUM_MI_SLOTS*C_NUM_SI_SLOTS*P_TPAYLOAD_WIDTH-1:0 ] mux_tpayload;
wire [ C_NUM_MI_SLOTS*C_NUM_SI_SLOTS-1:0                  ] arb_req_i;
wire [ C_NUM_MI_SLOTS-1:0                                 ] arb_done_i;
wire [ C_NUM_MI_SLOTS*C_NUM_SI_SLOTS-1:0                  ] arb_gnt_i;
wire [ C_NUM_MI_SLOTS*C_LOG_SI_SLOTS-1:0                  ] arb_sel_i;
wire [ C_NUM_MI_SLOTS*P_TPAYLOAD_WIDTH-1:0                ] tmo_tpayload;
        

////////////////////////////////////////////////////////////////////////////////
// BEGIN RTL
////////////////////////////////////////////////////////////////////////////////
always @(posedge ACLK) begin 
  areset_r <= ~ARESETN;
end

generate
  genvar si;
  genvar mi;
  for (si = 0; si < C_NUM_SI_SLOTS; si = si + 1) begin : gen_decoder
    axis_interconnect_v1_1_util_axis2vector #(
      .C_TDATA_WIDTH    ( C_AXIS_TDATA_WIDTH ) ,
      .C_TID_WIDTH      ( C_AXIS_TID_WIDTH   ) ,
      .C_TDEST_WIDTH    ( C_AXIS_TDEST_WIDTH ) ,
      .C_TUSER_WIDTH    ( C_AXIS_TUSER_WIDTH ) ,
      .C_TPAYLOAD_WIDTH ( P_TPAYLOAD_WIDTH   ) ,
      .C_SIGNAL_SET     ( C_AXIS_SIGNAL_SET  ) 
    )
    util_axis2vector_0 (
      .TDATA    ( S_AXIS_TDATA    [ si*C_AXIS_TDATA_WIDTH   +: C_AXIS_TDATA_WIDTH   ] ) ,
      .TSTRB    ( S_AXIS_TSTRB    [ si*C_AXIS_TDATA_WIDTH/8 +: C_AXIS_TDATA_WIDTH/8 ] ) ,
      .TKEEP    ( S_AXIS_TKEEP    [ si*C_AXIS_TDATA_WIDTH/8 +: C_AXIS_TDATA_WIDTH/8 ] ) ,
      .TLAST    ( S_AXIS_TLAST    [ si                      +: 1                    ] ) ,
      .TID      ( S_AXIS_TID      [ si*C_AXIS_TID_WIDTH     +: C_AXIS_TID_WIDTH     ] ) ,
      .TDEST    ( S_AXIS_TDEST    [ si*C_AXIS_TDEST_WIDTH   +: C_AXIS_TDEST_WIDTH   ] ) ,
      .TUSER    ( S_AXIS_TUSER    [ si*C_AXIS_TUSER_WIDTH   +: C_AXIS_TUSER_WIDTH   ] ) ,
      .TPAYLOAD ( s_axis_tpayload [ si*P_TPAYLOAD_WIDTH     +: P_TPAYLOAD_WIDTH     ] ) 
    );

    axis_interconnect_v1_1_axisc_decoder #(
      .C_FAMILY           ( C_FAMILY                                                        ) ,
      .C_AXIS_TDATA_WIDTH ( C_AXIS_TDATA_WIDTH                                              ) ,
      .C_AXIS_TID_WIDTH   ( C_AXIS_TID_WIDTH                                                ) ,
      .C_AXIS_TDEST_WIDTH ( C_AXIS_TDEST_WIDTH                                              ) ,
      .C_AXIS_TUSER_WIDTH ( C_AXIS_TUSER_WIDTH                                              ) ,
      .C_AXIS_SIGNAL_SET  ( C_AXIS_SIGNAL_SET                                               ) ,
      .C_TPAYLOAD_WIDTH   ( P_TPAYLOAD_WIDTH                                                ) ,
      .C_NUM_MI_SLOTS     ( C_NUM_MI_SLOTS                                                  ) ,
      .C_USE_PACKET_MODE  ( P_USE_PACKET_MODE                                               ) ,
      .C_REG_CONFIG       ( C_SI_REG_CONFIG                                                    ) ,
      .C_CONNECTIVITY     ( P_DECODER_CONNECTIVITY_ARRAY[si*C_NUM_MI_SLOTS+:C_NUM_MI_SLOTS] ) ,
      .C_BASETDEST        ( C_M_AXIS_BASETDEST_ARRAY[0+:C_NUM_MI_SLOTS*C_AXIS_TDEST_WIDTH]  ) ,
      .C_HIGHTDEST        ( C_M_AXIS_HIGHTDEST_ARRAY[0+:C_NUM_MI_SLOTS*C_AXIS_TDEST_WIDTH]  ) 
    )
    axisc_decoder_0
    (
      .ACLK            ( ACLK                                                            ) ,
      .ACLKEN          ( ACLKEN                                                          ) ,
      .ARESET          ( areset_r                                                        ) ,
      .S_AXIS_TVALID   ( S_AXIS_TVALID   [ si                    +: 1                  ] ) ,
      .S_AXIS_TREADY   ( S_AXIS_TREADY   [ si                    +: 1                  ] ) ,
      .S_AXIS_TPAYLOAD ( s_axis_tpayload [ si*P_TPAYLOAD_WIDTH   +: P_TPAYLOAD_WIDTH   ] ) ,
      .S_AXIS_TDEST    ( S_AXIS_TDEST    [ si*C_AXIS_TDEST_WIDTH +: C_AXIS_TDEST_WIDTH ] ) ,
      .M_AXIS_TVALID   ( dec_tvalid      [ si*C_NUM_MI_SLOTS     +: C_NUM_MI_SLOTS     ] ) ,
      .M_AXIS_TREADY   ( dec_tready      [ si*C_NUM_MI_SLOTS     +: C_NUM_MI_SLOTS     ] ) ,
      .M_AXIS_TPAYLOAD ( dec_tpayload    [ si*P_TPAYLOAD_WIDTH   +: P_TPAYLOAD_WIDTH   ] ) ,
      .ARB_LAST        ( dec_tlast       [ si                    +: 1                  ] ) ,
      .ARB_ID          ( dec_tid         [ si*C_AXIS_TID_WIDTH   +: C_AXIS_TID_WIDTH   ] ) ,
      .ARB_DEST        ( dec_tdest       [ si*C_AXIS_TDEST_WIDTH +: C_AXIS_TDEST_WIDTH ] ) ,
      .ARB_USER        ( dec_tuser       [ si*C_AXIS_TUSER_WIDTH +: C_AXIS_TUSER_WIDTH ] ) ,
      .ARB_REQ         ( dec_arb_req     [ si*C_NUM_MI_SLOTS     +: C_NUM_MI_SLOTS     ] ) ,
      .ARB_GNT         ( dec_arb_gnt     [ si*C_NUM_MI_SLOTS     +: C_NUM_MI_SLOTS     ] ) ,
      .ARB_DONE        ( dec_arb_done    [ si*C_NUM_MI_SLOTS     +: C_NUM_MI_SLOTS     ] ) ,
      .ARB_ACTIVE      ( dec_arb_active  [ si*C_NUM_MI_SLOTS     +: C_NUM_MI_SLOTS     ] ) ,
      .DECODE_ERR      ( S_DECODE_ERR    [ si                    +: 1                  ] )
    );
  end
  // These loops transform the output of the SI Decoders signals to arrange them into ARB
  // interface order
  for (mi = 0; mi < C_NUM_MI_SLOTS; mi = mi + 1) begin : gen_si2mi_master_transform
    for (si = 0; si < C_NUM_SI_SLOTS; si = si + 1) begin : gen_si2mi_slave_transform
      // These signals map 1:N from 1 per SI to multiple MI
      assign mux_tvalid   [ (mi*C_NUM_SI_SLOTS+si)                                        ] = dec_tvalid   [ si*C_NUM_MI_SLOTS+mi                      ] ;
      assign mux_tpayload [ (mi*C_NUM_SI_SLOTS+si)*P_TPAYLOAD_WIDTH+:P_TPAYLOAD_WIDTH     ] = dec_tpayload [ si*P_TPAYLOAD_WIDTH+:P_TPAYLOAD_WIDTH     ] ;
      assign ARB_LAST     [ (mi*C_NUM_SI_SLOTS+si)                                        ] = dec_tlast    [ si                                        ] ;
      assign ARB_ID       [ (mi*C_NUM_SI_SLOTS+si)*C_AXIS_TID_WIDTH+:C_AXIS_TID_WIDTH     ] = dec_tid      [ si*C_AXIS_TID_WIDTH+:C_AXIS_TID_WIDTH     ] ;
      assign ARB_DEST     [ (mi*C_NUM_SI_SLOTS+si)*C_AXIS_TDEST_WIDTH+:C_AXIS_TDEST_WIDTH ] = dec_tdest    [ si*C_AXIS_TDEST_WIDTH+:C_AXIS_TDEST_WIDTH ] ;
      assign ARB_USER     [ (mi*C_NUM_SI_SLOTS+si)*C_AXIS_TUSER_WIDTH+:C_AXIS_TUSER_WIDTH ] = dec_tuser    [ si*C_AXIS_TUSER_WIDTH+:C_AXIS_TUSER_WIDTH ] ;
      // These signals map 1:1 from multiple per SI to multiple per MI
      assign ARB_REQ      [ (mi*C_NUM_SI_SLOTS+si)                                        ] = dec_arb_req  [ si*C_NUM_MI_SLOTS+mi                   ] & ~ARB_REQ_SUPPRESS[si];
      assign arb_req_i    [ (mi*C_NUM_SI_SLOTS+si)                                        ] = dec_arb_req  [ si*C_NUM_MI_SLOTS+mi                   ] & ~ARB_REQ_SUPPRESS[si];
    end
  end
  // These loops transform the input to the Decoders signals to arrange them into 
  // slave interface order
  for (si = 0; si < C_NUM_SI_SLOTS; si = si + 1) begin : gen_mi2si_slave_transform
    for (mi = 0; mi < C_NUM_MI_SLOTS; mi = mi + 1) begin : gen_mi2si_master_transform
      assign dec_tready [ si*C_NUM_MI_SLOTS+mi ] = mux_tready[ mi*C_NUM_SI_SLOTS+si ];
      assign dec_arb_gnt[ si*C_NUM_MI_SLOTS+mi ] = arb_gnt_i [ mi*C_NUM_SI_SLOTS+si ];
      assign dec_arb_done[si*C_NUM_MI_SLOTS+mi ] = arb_done_i [ mi ];
    end
  end
  for (mi = 0; mi < C_NUM_MI_SLOTS; mi = mi + 1) begin : gen_transfer_mux
    axis_interconnect_v1_1_axisc_transfer_mux #(
      .C_FAMILY           ( C_FAMILY                                                ) ,
      .C_TPAYLOAD_WIDTH   ( P_TPAYLOAD_WIDTH                                        ) ,
      .C_AXIS_TDATA_WIDTH ( C_AXIS_TDATA_WIDTH                                      ) ,
      .C_AXIS_TID_WIDTH   ( C_AXIS_TID_WIDTH                                        ) ,
      .C_AXIS_TDEST_WIDTH ( C_AXIS_TDEST_WIDTH                                      ) ,
      .C_AXIS_TUSER_WIDTH ( C_AXIS_TUSER_WIDTH                                      ) ,
      .C_AXIS_SIGNAL_SET  ( C_AXIS_SIGNAL_SET                                       ) ,
      .C_USE_PACKET_MODE  ( P_USE_PACKET_MODE                                       ) ,
      .C_MAX_XFERS_PER_ARB( C_MAX_XFERS_PER_ARB                                     ) ,
      .C_NUM_CYCLES_TIMEOUT ( C_NUM_CYCLES_TIMEOUT                                  ) ,
      .C_NUM_SI_SLOTS     ( C_NUM_SI_SLOTS                                          ) ,
      .C_LOG_SI_SLOTS     ( C_LOG_SI_SLOTS                                          ) ,
      .C_REG_CONFIG       ( C_MI_REG_CONFIG                                         ) ,
      .C_CONNECTIVITY     ( C_M_AXIS_CONNECTIVITY_ARRAY[mi*C_NUM_SI_SLOTS+:C_NUM_SI_SLOTS] ) ,
      .C_SINGLE_SLAVE_CONNECTIVITY ( P_SINGLE_SLAVE_CONNECTIVITY_ARRAY[mi] )
    )
    axisc_transfer_mux_0
    (
      .ACLK            ( ACLK                                                                               ) ,
      .ACLKEN          ( ACLKEN                                                                             ) ,
      .ARESET          ( areset_r                                                                           ) ,
      .S_AXIS_TVALID   ( mux_tvalid   [mi*C_NUM_SI_SLOTS+:C_NUM_SI_SLOTS]                                   ) ,
      .S_AXIS_TREADY   ( mux_tready   [mi*C_NUM_SI_SLOTS+:C_NUM_SI_SLOTS]                                   ) ,
      .S_AXIS_TPAYLOAD ( mux_tpayload [mi*C_NUM_SI_SLOTS*P_TPAYLOAD_WIDTH+:C_NUM_SI_SLOTS*P_TPAYLOAD_WIDTH] ) ,
      .M_AXIS_TVALID   ( M_AXIS_TVALID[mi+:1]                                                               ) ,
      .M_AXIS_TREADY   ( M_AXIS_TREADY[mi+:1]                                                               ) ,
      .M_AXIS_TPAYLOAD ( tmo_tpayload [mi*P_TPAYLOAD_WIDTH+:P_TPAYLOAD_WIDTH]                               ) ,
      .ARB_GNT         ( arb_gnt_i    [mi*C_NUM_SI_SLOTS+:C_NUM_SI_SLOTS]                                   ) ,
      .ARB_DONE        ( arb_done_i   [mi+:1]                                                               ) ,
      .ARB_SEL         ( arb_sel_i    [mi*C_LOG_SI_SLOTS+:C_LOG_SI_SLOTS]                                   ) 
    );

    axis_interconnect_v1_1_util_vector2axis #(
      .C_TDATA_WIDTH    ( C_AXIS_TDATA_WIDTH ) ,
      .C_TID_WIDTH      ( C_AXIS_TID_WIDTH   ) ,
      .C_TDEST_WIDTH    ( C_AXIS_TDEST_WIDTH ) ,
      .C_TUSER_WIDTH    ( C_AXIS_TUSER_WIDTH ) ,
      .C_TPAYLOAD_WIDTH ( P_TPAYLOAD_WIDTH   ) ,
      .C_SIGNAL_SET     ( C_AXIS_SIGNAL_SET  ) 
    )
    util_vector2axis_0 (
      .TPAYLOAD ( tmo_tpayload[mi*P_TPAYLOAD_WIDTH+:P_TPAYLOAD_WIDTH]         ) ,
      .TDATA    ( M_AXIS_TDATA[mi*C_AXIS_TDATA_WIDTH+:C_AXIS_TDATA_WIDTH]     ) ,
      .TSTRB    ( M_AXIS_TSTRB[mi*C_AXIS_TDATA_WIDTH/8+:C_AXIS_TDATA_WIDTH/8] ) ,
      .TKEEP    ( M_AXIS_TKEEP[mi*C_AXIS_TDATA_WIDTH/8+:C_AXIS_TDATA_WIDTH/8] ) ,
      .TLAST    ( M_AXIS_TLAST[mi+:1]                                         ) ,
      .TID      ( M_AXIS_TID  [mi*C_AXIS_TID_WIDTH+:C_AXIS_TID_WIDTH]         ) ,
      .TDEST    ( M_AXIS_TDEST[mi*C_AXIS_TDEST_WIDTH+:C_AXIS_TDEST_WIDTH]     ) ,
      .TUSER    ( M_AXIS_TUSER[mi*C_AXIS_TUSER_WIDTH+:C_AXIS_TUSER_WIDTH]     ) 
    );
  end
  if (C_NUM_SI_SLOTS > 1) begin : gen_arbiter
    if (P_INTERNAL_ARBITER) begin : gen_int_arbiter
      axis_interconnect_v1_1_axis_switch_arbiter #(
        .C_FAMILY        ( C_FAMILY            ) ,
        .C_NUM_SI_SLOTS  ( C_NUM_SI_SLOTS      ) ,
        .C_LOG_SI_SLOTS  ( C_LOG_SI_SLOTS      ) ,
        .C_NUM_MI_SLOTS  ( C_NUM_MI_SLOTS      ) ,
        .C_ARB_ALGORITHM ( P_ARB_ALGORITHM     ) ,
        .C_SINGLE_SLAVE_CONNECTIVITY_ARRAY ( P_SINGLE_SLAVE_CONNECTIVITY_ARRAY )
      )
      axis_interconnect_v1_1_axis_switch_arbiter (
        .ACLK     ( ACLK       ) ,
        .ARESETN  ( ARESETN    ) ,
        .ACLKEN   ( ACLKEN     ) ,
        .ARB_REQ  ( arb_req_i  ) ,
        .ARB_DONE ( arb_done_i ) ,
        .ARB_SEL  ( arb_sel_i  ) ,
        .ARB_GNT  ( arb_gnt_i  ) 
      );
    end
    else begin : gen_ext_arbiter
      assign ARB_REQ = arb_req_i;
    /*    assign ARB_DONE = arb_done_i;*/
    /*    assign arb_sel_i = ARB_SEL;*/
      assign arb_gnt_i = ARB_GNT;
    end
  end else begin : gen_all_arb_tieoffs
    assign arb_gnt_i = arb_req_i;
    assign arb_sel_i = {C_NUM_MI_SLOTS{1'b0}};
  end


endgenerate

endmodule // axis_switch

`default_nettype wire
