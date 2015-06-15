// (c) Copyright 2012 Xilinx, Inc. All rights reserved.
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
// axis_subset_converter
//   Converts signal sets and id/dest dwidth based on default tie off rules.
//
// Verilog-standard:  Verilog 2001
//--------------------------------------------------------------------------
//
// Structure:
//   axis_subset_converter
//
//--------------------------------------------------------------------------

`timescale 1ps/1ps
`default_nettype none

module axis_interconnect_v1_1_axis_subset_converter #
(
///////////////////////////////////////////////////////////////////////////////
// Parameter Definitions
///////////////////////////////////////////////////////////////////////////////
   parameter         C_FAMILY           = "virtex7",
   parameter integer C_AXIS_TDATA_WIDTH = 32,
   parameter integer C_S_AXIS_TID_WIDTH   = 1,
   parameter integer C_S_AXIS_TDEST_WIDTH = 1,
   parameter integer C_AXIS_TUSER_WIDTH = 1,
   parameter [31:0]  C_S_AXIS_SIGNAL_SET  = 32'hFF, 
   // C_AXIS_SIGNAL_SET: each bit if enabled specifies which axis optional signals are present
   //   [0] => TREADY present (Required)
   //   [1] => TDATA present (Required, used to calculate ratios)
   //   [2] => TSTRB present, TDATA must be present
   //   [3] => TKEEP present, TDATA must be present (Required if TLAST, TID,
   //            TDEST present
   //   [4] => TLAST present
   //   [5] => TID present
   //   [6] => TDEST present
   //   [7] => TUSER present
   parameter integer C_M_AXIS_TID_WIDTH   = 1,
   parameter integer C_M_AXIS_TDEST_WIDTH = 1,
   parameter [31:0]  C_M_AXIS_SIGNAL_SET  = 32'hFF,
   parameter integer C_DEFAULT_TLAST = 0
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
   input  wire                              S_AXIS_TVALID,
   output wire                              S_AXIS_TREADY,
   input  wire [C_AXIS_TDATA_WIDTH-1:0]     S_AXIS_TDATA,
   input  wire [C_AXIS_TDATA_WIDTH/8-1:0]   S_AXIS_TSTRB,
   input  wire [C_AXIS_TDATA_WIDTH/8-1:0]   S_AXIS_TKEEP,
   input  wire                              S_AXIS_TLAST,
   input  wire [C_S_AXIS_TID_WIDTH-1:0]     S_AXIS_TID,
   input  wire [C_S_AXIS_TDEST_WIDTH-1:0]   S_AXIS_TDEST,
   input  wire [C_AXIS_TUSER_WIDTH-1:0]     S_AXIS_TUSER,

   // Master side
   output wire                              M_AXIS_TVALID,
   input  wire                              M_AXIS_TREADY,
   output wire [C_AXIS_TDATA_WIDTH-1:0]     M_AXIS_TDATA,
   output wire [C_AXIS_TDATA_WIDTH/8-1:0]   M_AXIS_TSTRB,
   output wire [C_AXIS_TDATA_WIDTH/8-1:0]   M_AXIS_TKEEP,
   output wire                              M_AXIS_TLAST,
   output wire [C_M_AXIS_TID_WIDTH-1:0]     M_AXIS_TID,
   output wire [C_M_AXIS_TDEST_WIDTH-1:0]   M_AXIS_TDEST,
   output wire [C_AXIS_TUSER_WIDTH-1:0]     M_AXIS_TUSER,

   // Status Signals
   output wire                              SPARSE_TKEEP_REMOVED
   // SPARSE_TKEEP_REMOVED outputs a 1 if TKEEP is being removed and 
   // a conversion process detects a TKEEP that is not all HIGH
   );

////////////////////////////////////////////////////////////////////////////////
// Functions
////////////////////////////////////////////////////////////////////////////////
`include "axis_interconnect_v1_1_axis_infrastructure.vh"

////////////////////////////////////////////////////////////////////////////////
// Local parameters
////////////////////////////////////////////////////////////////////////////////

// Calculate if signal is added or removed. tready is in opposite direction,
// it's meaning is reversed.
localparam [31:0] P_SIGNAL_SET_ADD = (C_S_AXIS_SIGNAL_SET ^ C_M_AXIS_SIGNAL_SET) & {C_M_AXIS_SIGNAL_SET[31:1], C_S_AXIS_SIGNAL_SET[0]};
localparam [31:0] P_SIGNAL_SET_REM = (C_S_AXIS_SIGNAL_SET ^ C_M_AXIS_SIGNAL_SET) & {C_S_AXIS_SIGNAL_SET[31:1], C_M_AXIS_SIGNAL_SET[0]};
// TODO: possible optimization calculate for C_DEFAULT_TLAST-1
localparam integer P_TLAST_CNTR_WIDTH = (C_DEFAULT_TLAST > 1) ? f_clogb2(C_DEFAULT_TLAST) : 1;
////////////////////////////////////////////////////////////////////////////////
// DRCs
////////////////////////////////////////////////////////////////////////////////
// synthesis translate_off
// synthesis translate_on
////////////////////////////////////////////////////////////////////////////////
// Wires/Reg declarations
////////////////////////////////////////////////////////////////////////////////
wire                            default_tready;
wire [C_AXIS_TDATA_WIDTH-1:0]   default_tdata;
wire [C_AXIS_TDATA_WIDTH/8-1:0] default_tstrb;
wire [C_AXIS_TDATA_WIDTH/8-1:0] default_tkeep;
wire                            default_tlast;
wire [C_M_AXIS_TID_WIDTH-1:0]   default_tid;
wire [C_M_AXIS_TDEST_WIDTH-1:0] default_tdest;
wire [C_AXIS_TUSER_WIDTH-1:0]   default_tuser;

wire                            pulsed_tlast_i;
wire                            sparse_tkeep;
////////////////////////////////////////////////////////////////////////////////
// BEGIN RTL
////////////////////////////////////////////////////////////////////////////////
// Assign default values based on AMBA 4 AXI4-Stream Protocol Specification v1.0

// 3.1.1 Optional TREADY
assign default_tready = 1'b1;

// 3.1.5 Optional TDATA (No default value specified, assign 0)
assign default_tdata = {C_AXIS_TDATA_WIDTH{1'b0}};

// 3.1.2 Optional TKEEP and TSTRB
// assign TSTRB from M_AXIS_TKEEP if defined, else assign from S_AXIS_TKEEP if
// assigned, else assign all bits HIGH.

assign default_tstrb = C_M_AXIS_SIGNAL_SET[`G_INDX_SS_TKEEP] ? M_AXIS_TKEEP :
                       C_S_AXIS_SIGNAL_SET[`G_INDX_SS_TKEEP] ? S_AXIS_TKEEP :
                       {C_AXIS_TDATA_WIDTH/8{1'b1}};
// Default value of tkeep is always all bits HIGH.
assign default_tkeep = {C_AXIS_TDATA_WIDTH/8{1'b1}};

// 3.1.3 Optional TLAST 
assign default_tlast = (C_DEFAULT_TLAST == 0) ? 1'b0 : 
                       (C_DEFAULT_TLAST == 1) ? 1'b1 : 
                       pulsed_tlast_i;
generate
if (C_DEFAULT_TLAST > 1) begin : gen_pulsed_tlast_cntr
//  reg                             pulsed_tlast_r;
  wire                            pulsed_tlast_ns;
  reg  [P_TLAST_CNTR_WIDTH-1:0]   pulsed_tlast_cntr;
  wire [P_TLAST_CNTR_WIDTH-1:0]   pulsed_tlast_cntr_ns;
 
  assign pulsed_tlast_cntr_ns = pulsed_tlast_i ? {P_TLAST_CNTR_WIDTH{1'b0}} : pulsed_tlast_cntr + 1'b1;

  always @(posedge ACLK) begin
    if (~ARESETN) begin
      pulsed_tlast_cntr <= {P_TLAST_CNTR_WIDTH{1'b0}};
    end
    else if (ACLKEN) begin
      pulsed_tlast_cntr <= S_AXIS_TVALID & S_AXIS_TREADY ? pulsed_tlast_cntr_ns : pulsed_tlast_cntr;
    end
  end

  assign pulsed_tlast_i = (pulsed_tlast_cntr == (C_DEFAULT_TLAST - 1)) ? 1'b1 : 1'b0;

//  always @(posedge ACLK) begin
//    if (~ARESETN) begin
//      pulsed_tlast_r <= 1'b0;
//    end
//    else if (ACLKEN) begin
//      pulsed_tlast_r <= S_AXIS_TVALID & S_AXIS_TREADY ? pulsed_tlast_i : pulsed_tlast_r;
//    end
//  end

//  assign pulsed_tlast_i = pulsed_tlast_r;
end else begin : gen_no_pulsed_tlast_cntr
  assign pulsed_tlast_i = 1'b0;
end
endgenerate

// 3.1.4 Optional TID, TDEST, and TUSER
// * A slave with additional TID, TDEST, and TUSER inputs must have all bits
// fixed LOW.
assign default_tid = {C_M_AXIS_TID_WIDTH{1'b0}};
assign default_tdest = {C_M_AXIS_TDEST_WIDTH{1'b0}};
assign default_tuser = {C_AXIS_TUSER_WIDTH{1'b0}};

assign sparse_tkeep = M_AXIS_TVALID & M_AXIS_TREADY ? ~(&M_AXIS_TKEEP) : 1'b0;
// TVALID required and always passed through.
assign M_AXIS_TVALID = S_AXIS_TVALID; 
assign S_AXIS_TREADY = P_SIGNAL_SET_ADD[`G_INDX_SS_TREADY] ? default_tready : M_AXIS_TREADY;
assign M_AXIS_TDATA  = P_SIGNAL_SET_ADD[`G_INDX_SS_TDATA] ? default_tdata : S_AXIS_TDATA;
assign M_AXIS_TSTRB  = P_SIGNAL_SET_ADD[`G_INDX_SS_TSTRB] ? default_tstrb : S_AXIS_TSTRB;
assign M_AXIS_TKEEP  = P_SIGNAL_SET_ADD[`G_INDX_SS_TKEEP] ? default_tkeep : S_AXIS_TKEEP;
assign M_AXIS_TLAST  = P_SIGNAL_SET_ADD[`G_INDX_SS_TLAST] ? default_tlast : S_AXIS_TLAST;
assign M_AXIS_TID    = P_SIGNAL_SET_ADD[`G_INDX_SS_TID]   ? default_tid   : S_AXIS_TID | default_tid;
assign M_AXIS_TDEST  = P_SIGNAL_SET_ADD[`G_INDX_SS_TDEST] ? default_tdest : S_AXIS_TDEST | default_tdest;
assign M_AXIS_TUSER  = P_SIGNAL_SET_ADD[`G_INDX_SS_TUSER] ? default_tuser : S_AXIS_TUSER;
assign SPARSE_TKEEP_REMOVED = P_SIGNAL_SET_REM[`G_INDX_SS_TKEEP] ? sparse_tkeep : 1'b0;

endmodule // axis_subset_converter

`default_nettype wire
