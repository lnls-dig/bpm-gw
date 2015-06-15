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
//   dynamic_priority_encoder
//
//--------------------------------------------------------------------------

`timescale 1ps/1ps
`default_nettype none

module axis_interconnect_v1_1_dynamic_priority_encoder #
(
///////////////////////////////////////////////////////////////////////////////
// Parameter Definitions
///////////////////////////////////////////////////////////////////////////////
   parameter         C_FAMILY    = "virtex7",
   parameter integer C_REQ_WIDTH = 8,
   parameter integer C_ENC_WIDTH = 3
)
(
///////////////////////////////////////////////////////////////////////////////
// Port Declarations
///////////////////////////////////////////////////////////////////////////////
   input  wire  [C_REQ_WIDTH-1:0]             REQ,
   input  wire  [C_REQ_WIDTH*C_ENC_WIDTH-1:0] PORT_PRIORITY,
   output wire  [C_ENC_WIDTH-1:0]             SEL,
   output wire                                VALID
);

////////////////////////////////////////////////////////////////////////////////
// Functions
////////////////////////////////////////////////////////////////////////////////
// `include "axis_interconnect_v1_1_axis_infrastructure.vh"

////////////////////////////////////////////////////////////////////////////////
// Local parameters
////////////////////////////////////////////////////////////////////////////////
localparam P_NATIVE = 4; // Encoder defined for 4 inputs

////////////////////////////////////////////////////////////////////////////////
// Wires/Reg declarations
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// BEGIN RTL
////////////////////////////////////////////////////////////////////////////////

// Priority encoder specified completed for up to 8 inputs and is configurable 
// with the localparam P_NATIVE.  If less than P_NATIVE inputs instantiate a 
// P_NATIVE input priority encoder and tie off upper bits.  Allow synthesis tool 
// to prune.  If more than P_NATIVE bits, then halve the numeber of inputs and
// recursively call two encoder instances for lsb and msb.  MUX output of lsb
// and msb with valid_lsb to get final result.
generate
if (C_REQ_WIDTH < P_NATIVE) begin : pri_encoder_padded

  wire [P_NATIVE-1:0]               req_i;
  wire [P_NATIVE*C_ENC_WIDTH-1:0]   port_priority_i;

  // Pad MSB of req with 0s.
  assign req_i = {{P_NATIVE-C_REQ_WIDTH{1'b0}}, REQ};
  assign port_priority_i = {{(P_NATIVE-C_REQ_WIDTH)*C_ENC_WIDTH{1'b0}}, PORT_PRIORITY};

  axis_interconnect_v1_1_dynamic_priority_encoder #(
    .C_FAMILY    ( C_FAMILY    ) ,
    .C_REQ_WIDTH ( P_NATIVE    ) ,
    .C_ENC_WIDTH ( C_ENC_WIDTH ) 
  )
  dynamic_priority_encoder_padded_0
  (
    .REQ           ( req_i           ) ,
    .PORT_PRIORITY ( port_priority_i ) ,
    .SEL           ( SEL             ) ,
    .VALID         ( VALID           ) 
  );
end
else if (C_REQ_WIDTH == P_NATIVE) begin : pri_encoder_4bit

  reg [C_ENC_WIDTH-1:0] sel_i;
  reg                   valid_i;

  // Select based on priority of 0 highest P_NATIVE lowest
  // The mod value with constant is used to avoid compilation warnings when
  // P_NATIVE < 8.
  always @* begin
    if ( REQ[0] ) begin 
      sel_i = PORT_PRIORITY[0*C_ENC_WIDTH+:C_ENC_WIDTH];
    end else if ( REQ[1%P_NATIVE] && P_NATIVE > 2) begin 
      sel_i = PORT_PRIORITY[1%P_NATIVE*C_ENC_WIDTH+:C_ENC_WIDTH];
    end else if ( REQ[2%P_NATIVE] && P_NATIVE > 3) begin 
      sel_i = PORT_PRIORITY[2%P_NATIVE*C_ENC_WIDTH+:C_ENC_WIDTH];
    end else if ( REQ[3%P_NATIVE] && P_NATIVE > 4) begin 
      sel_i = PORT_PRIORITY[3%P_NATIVE*C_ENC_WIDTH+:C_ENC_WIDTH];
    end else if ( REQ[4%P_NATIVE] && P_NATIVE > 5) begin 
      sel_i = PORT_PRIORITY[4%P_NATIVE*C_ENC_WIDTH+:C_ENC_WIDTH];
    end else if ( REQ[5%P_NATIVE] && P_NATIVE > 6) begin 
      sel_i = PORT_PRIORITY[5%P_NATIVE*C_ENC_WIDTH+:C_ENC_WIDTH];
    end else if ( REQ[6%P_NATIVE] && P_NATIVE > 7) begin 
      sel_i = PORT_PRIORITY[6%P_NATIVE*C_ENC_WIDTH+:C_ENC_WIDTH];
    end else begin
      sel_i = PORT_PRIORITY[(P_NATIVE-1)*C_ENC_WIDTH+:C_ENC_WIDTH];
    end
  end

  // Valid when any input value is 1
  always @* begin
    valid_i = |REQ;
  end

  assign SEL = sel_i;
  assign VALID = valid_i;
end
else if (C_REQ_WIDTH > P_NATIVE) begin : recursive_dynamic_priority_encoder

  wire [C_REQ_WIDTH/2-1:0]                             req_lsb;
  wire [C_REQ_WIDTH-(C_REQ_WIDTH/2)-1:0]               req_msb;
  wire [(C_REQ_WIDTH/2)*C_ENC_WIDTH-1:0]               port_priority_lsb;
  wire [(C_REQ_WIDTH-(C_REQ_WIDTH/2))*C_ENC_WIDTH-1:0] port_priority_msb;
  wire [C_ENC_WIDTH-1:0]                               sel_lsb;
  wire [C_ENC_WIDTH-1:0]                               sel_msb;
  wire                                                 valid_lsb;
  wire                                                 valid_msb;

  assign req_lsb = REQ[C_REQ_WIDTH/2-1:0];
  assign req_msb = REQ[C_REQ_WIDTH-1:C_REQ_WIDTH/2];
  assign port_priority_lsb = PORT_PRIORITY[(C_REQ_WIDTH/2)*C_ENC_WIDTH-1:0];
  assign port_priority_msb = PORT_PRIORITY[C_REQ_WIDTH*C_ENC_WIDTH-1:(C_REQ_WIDTH/2)*C_ENC_WIDTH];

  axis_interconnect_v1_1_dynamic_priority_encoder #(
    .C_FAMILY    ( C_FAMILY      ) ,
    .C_REQ_WIDTH ( C_REQ_WIDTH/2 ) ,
    .C_ENC_WIDTH ( C_ENC_WIDTH   ) 
  )
  dynamic_priority_encoder_lsb_0
  (
    .REQ           ( req_lsb           ) ,
    .PORT_PRIORITY ( port_priority_lsb ) ,
    .SEL           ( sel_lsb           ) ,
    .VALID         ( valid_lsb         ) 
  );

  axis_interconnect_v1_1_dynamic_priority_encoder #(
    .C_FAMILY    ( C_FAMILY                      ) ,
    .C_REQ_WIDTH ( C_REQ_WIDTH - (C_REQ_WIDTH/2) ) ,
    .C_ENC_WIDTH ( C_ENC_WIDTH                   ) 
  )
  dynamic_priority_encoder_msb_0
  (
    .REQ           ( req_msb           ) ,
    .PORT_PRIORITY ( port_priority_msb ) ,
    .SEL           ( sel_msb           ) ,
    .VALID         ( valid_msb         ) 
  );

  assign SEL = valid_lsb ? sel_lsb : sel_msb;
  assign VALID = valid_lsb | valid_msb;  
end
endgenerate

endmodule // dynamic_priority_encoder

`default_nettype wire
