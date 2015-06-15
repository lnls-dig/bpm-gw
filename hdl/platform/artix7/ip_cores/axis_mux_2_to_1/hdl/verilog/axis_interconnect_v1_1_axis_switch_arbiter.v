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
//
// Verilog-standard:  Verilog 2001
//--------------------------------------------------------------------------
//
// Structure:
//   axis_switch_arbiter
//
//--------------------------------------------------------------------------

`timescale 1ps/1ps
`default_nettype none

module axis_interconnect_v1_1_axis_switch_arbiter #
(
///////////////////////////////////////////////////////////////////////////////
// Parameter Definitions
///////////////////////////////////////////////////////////////////////////////
   parameter         C_FAMILY        = "virtex7",
   parameter integer C_NUM_SI_SLOTS  = 8,
   parameter integer C_LOG_SI_SLOTS  = 3,
   parameter integer C_NUM_MI_SLOTS  = 2,
   parameter         C_ARB_ALGORITHM = "ROUND_ROBIN",
   parameter         C_SINGLE_SLAVE_CONNECTIVITY_ARRAY = {C_NUM_MI_SLOTS{1'b0}} 
)
(
///////////////////////////////////////////////////////////////////////////////
// Port Declarations
///////////////////////////////////////////////////////////////////////////////
   // System Signals
   input wire ACLK,
   input wire ARESETN,
   input wire ACLKEN,

   input  wire  [C_NUM_MI_SLOTS*C_NUM_SI_SLOTS-1:0] ARB_REQ,
   input  wire  [C_NUM_MI_SLOTS-1:0]                ARB_DONE,
   output wire  [C_NUM_MI_SLOTS*C_NUM_SI_SLOTS-1:0] ARB_GNT,
   output wire  [C_NUM_MI_SLOTS*C_LOG_SI_SLOTS-1:0] ARB_SEL
);

////////////////////////////////////////////////////////////////////////////////
// Functions
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// Local parameters
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// Wires/Reg declarations
////////////////////////////////////////////////////////////////////////////////
reg areset;

////////////////////////////////////////////////////////////////////////////////
// BEGIN RTL
////////////////////////////////////////////////////////////////////////////////

always @(posedge ACLK) begin
  areset <= ~ARESETN;
end

generate
  genvar i;
  for (i = 0; i < C_NUM_MI_SLOTS; i = i + 1) begin : gen_mi_arb
    if (C_SINGLE_SLAVE_CONNECTIVITY_ARRAY[i]) begin : gen_arb_tie_off
      assign ARB_GNT [i*C_NUM_SI_SLOTS+:C_NUM_SI_SLOTS] = ARB_REQ[i*C_NUM_SI_SLOTS+:C_NUM_SI_SLOTS];
      assign ARB_SEL [i*C_LOG_SI_SLOTS+:C_LOG_SI_SLOTS] = {C_LOG_SI_SLOTS{1'b0}};
    end else if (C_ARB_ALGORITHM == "ROUND_ROBIN" || C_ARB_ALGORITHM == "FIXED") begin : gen_rr
      axis_interconnect_v1_1_arb_rr #(
        .C_FAMILY        ( C_FAMILY        ) ,
        .C_NUM_SI_SLOTS  ( C_NUM_SI_SLOTS  ) ,
        .C_LOG_SI_SLOTS  ( C_LOG_SI_SLOTS  ) ,
        .C_ARB_ALGORITHM ( C_ARB_ALGORITHM ) 
      )
      arb_rr_0
      (
        .ACLK     ( ACLK                                       ) ,
        .ARESET   ( areset                                     ) ,
        .ACLKEN   ( ACLKEN                                     ) ,
        .ARB_REQ  ( ARB_REQ [i*C_NUM_SI_SLOTS+:C_NUM_SI_SLOTS] ) ,
        .ARB_DONE ( ARB_DONE[i]                                ) ,
        .ARB_SEL  ( ARB_SEL [i*C_LOG_SI_SLOTS+:C_LOG_SI_SLOTS] ) ,
        .ARB_GNT  ( ARB_GNT [i*C_NUM_SI_SLOTS+:C_NUM_SI_SLOTS] ) 
      );
    end
  end
endgenerate

endmodule // axis_switch_arbiter

`default_nettype wire
