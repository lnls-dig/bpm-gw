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
//   arb_rr
//
//--------------------------------------------------------------------------

`timescale 1ps/1ps
`default_nettype none

module axis_interconnect_v1_1_arb_rr #
(
///////////////////////////////////////////////////////////////////////////////
// Parameter Definitions
///////////////////////////////////////////////////////////////////////////////
   parameter         C_FAMILY        = "virtex7",
   parameter integer C_NUM_SI_SLOTS  = 8,
   parameter integer C_LOG_SI_SLOTS  = 3,
   parameter         C_ARB_ALGORITHM = "ROUND_ROBIN"
)
(
///////////////////////////////////////////////////////////////////////////////
// Port Declarations
///////////////////////////////////////////////////////////////////////////////
   // System Signals
   input wire ACLK,
   input wire ARESET,
   input wire ACLKEN,

   input  wire [C_NUM_SI_SLOTS-1:0] ARB_REQ,
   input  wire                      ARB_DONE, 
   output wire [C_NUM_SI_SLOTS-1:0] ARB_GNT,
   output wire [C_LOG_SI_SLOTS-1:0] ARB_SEL
);

////////////////////////////////////////////////////////////////////////////////
// Functions
////////////////////////////////////////////////////////////////////////////////
function [C_NUM_SI_SLOTS*C_LOG_SI_SLOTS-1:0] f_port_priority_init (
  input integer num_slaves
);
  begin : main
    integer i;
    for (i = 0; i < num_slaves; i = i + 1) begin
      f_port_priority_init[i*C_LOG_SI_SLOTS+:C_LOG_SI_SLOTS] = i[C_LOG_SI_SLOTS-1:0];
    end
  end
endfunction

////////////////////////////////////////////////////////////////////////////////
// Local parameters
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// Wires/Reg declarations
////////////////////////////////////////////////////////////////////////////////
wire                                     arb_busy_ns;
reg                                      arb_busy_r;

wire                                     advance;
wire [C_LOG_SI_SLOTS-1:0]                barrel_cntr_ns;
reg  [C_LOG_SI_SLOTS-1:0]                barrel_cntr;
wire [C_NUM_SI_SLOTS-1:0]                arb_req_rot;
wire [C_NUM_SI_SLOTS-1:0]                arb_req_i;
reg  [C_NUM_SI_SLOTS*C_LOG_SI_SLOTS-1:0] port_priority_r;
wire [C_NUM_SI_SLOTS*C_LOG_SI_SLOTS-1:0] port_priority_ns;
wire [C_LOG_SI_SLOTS-1:0]                sel_i;
wire                                     valid_i; 

wire [C_LOG_SI_SLOTS-1:0]                arb_sel_ns;
reg  [C_LOG_SI_SLOTS-1:0]                arb_sel_r;

wire [C_NUM_SI_SLOTS-1:0]                sel_decode_i;
wire [C_NUM_SI_SLOTS-1:0]                arb_gnt_ns;
reg  [C_NUM_SI_SLOTS-1:0]                arb_gnt_r;
////////////////////////////////////////////////////////////////////////////////
// BEGIN RTL
////////////////////////////////////////////////////////////////////////////////

// Generate busy logic.  When arbiter is busy a new REQ can't be granted and
// priority will not advance.
assign arb_busy_ns = (valid_i) | (arb_busy_r & ~ARB_DONE);

always @(posedge ACLK) begin 
  if (ARESET) begin
    arb_busy_r <= 1'b0;
  end
  else if (ACLKEN) begin
    arb_busy_r <= arb_busy_ns;
  end
end

assign advance = ~arb_busy_r | (|arb_gnt_r);

assign barrel_cntr_ns = (barrel_cntr == C_NUM_SI_SLOTS-1) ? {C_LOG_SI_SLOTS{1'b0}} : barrel_cntr + 1'b1 ; 

always @(posedge ACLK) begin
  if (ARESET) begin
    barrel_cntr <= {C_LOG_SI_SLOTS{1'b0}};
  end
  else if (ACLKEN && C_ARB_ALGORITHM == "ROUND_ROBIN") begin
    barrel_cntr <= advance ? barrel_cntr_ns : barrel_cntr;
  end
end

assign arb_req_i = ARB_REQ & ~arb_gnt_r;
assign arb_req_rot[C_NUM_SI_SLOTS-1:0] = {arb_req_i, arb_req_i} >> barrel_cntr;

// Port Priority implements round robin arbitration
always @(posedge ACLK) begin
  if (ARESET) begin
    port_priority_r <= f_port_priority_init(C_NUM_SI_SLOTS);
  end
  else if (ACLKEN && (C_ARB_ALGORITHM == "ROUND_ROBIN")) begin
    port_priority_r <= advance ? port_priority_ns : port_priority_r;
  end
end

assign port_priority_ns[0+:(C_NUM_SI_SLOTS-1)*C_LOG_SI_SLOTS] = 
         port_priority_r[1*C_LOG_SI_SLOTS+:(C_NUM_SI_SLOTS-1)*C_LOG_SI_SLOTS];
assign port_priority_ns[(C_NUM_SI_SLOTS-1)*C_LOG_SI_SLOTS+:C_LOG_SI_SLOTS] = port_priority_r[0+:C_LOG_SI_SLOTS];

axis_interconnect_v1_1_dynamic_priority_encoder #(
  .C_FAMILY    ( C_FAMILY       ) ,
  .C_REQ_WIDTH ( C_NUM_SI_SLOTS ) ,
  .C_ENC_WIDTH ( C_LOG_SI_SLOTS ) 
)
dynamic_priority_encoder_0
(
  .REQ           ( arb_req_rot     ) ,
  .PORT_PRIORITY ( port_priority_r ) ,
  .SEL           ( sel_i           ) ,
  .VALID         ( valid_i         ) 
);

assign arb_sel_ns = valid_i & (~arb_busy_r | ARB_DONE) ? sel_i : arb_sel_r;

always @(posedge ACLK) begin 
  if (ARESET) begin
    arb_sel_r <= {C_LOG_SI_SLOTS{1'b0}};
  end
  else if (ACLKEN) begin
    arb_sel_r <= arb_sel_ns;
  end
end

assign ARB_SEL = arb_sel_r;

// Decode sel from integer to one-hot
generate
  genvar i;
  for (i = 0; i < C_NUM_SI_SLOTS; i = i + 1) begin : gen_sel_decode_one_hot
    assign sel_decode_i[i] = (i == sel_i); 
  end
endgenerate

assign arb_gnt_ns = valid_i & (~arb_busy_r | ARB_DONE) ? sel_decode_i : {C_LOG_SI_SLOTS{1'b0}};

always @(posedge ACLK) begin 
  if (ARESET) begin
    arb_gnt_r <= {C_LOG_SI_SLOTS{1'b0}};
  end
  else if (ACLKEN) begin
    arb_gnt_r <= arb_gnt_ns;
  end
end

assign ARB_GNT = arb_gnt_r;

endmodule // arb_rr

`default_nettype wire
