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
//   axisc_decoder
//
//--------------------------------------------------------------------------

`timescale 1ps/1ps
`default_nettype none

module axis_interconnect_v1_1_axisc_decoder #
(
///////////////////////////////////////////////////////////////////////////////
// Parameter Definitions
///////////////////////////////////////////////////////////////////////////////
   parameter         C_FAMILY           = "virtex7",
   parameter integer C_AXIS_TDATA_WIDTH = 32,
   parameter integer C_AXIS_TID_WIDTH   = 1,
   parameter integer C_AXIS_TDEST_WIDTH = 1,
   parameter integer C_AXIS_TUSER_WIDTH = 1,
   parameter [31:0]  C_AXIS_SIGNAL_SET  = 32'hFF,
   // C_AXIS_SIGNAL_SET: each bit if enabled specifies which axis optional signals are present
   //   [0] => TREADY present
   //   [1] => TDATA present
   //   [2] => TSTRB present, TDATA must be present
   //   [3] => TKEEP present, TDATA must be present
   //   [4] => TLAST present
   //   [5] => TID present
   //   [6] => TDEST present
   //   [7] => TUSER present
   parameter integer C_TPAYLOAD_WIDTH  = 44,
   parameter integer C_NUM_MI_SLOTS    = 1,
   parameter integer C_USE_PACKET_MODE = 1,
   // C_USE_PACKET_MODE: Indicates to monitor TLAST to signal ARB_DONE
   parameter integer C_REG_CONFIG      = 1, 
   // C_REG_CONFIG: Registers payload and ARB_REQ signal
   //   0 => BYPASS    = The channel is just wired through the module.
   //   1 => FWD_REV   = Both FWD and REV (fully-registered)
   //   2 => FWD       = The master VALID and payload signals are registrated. 
   //   3 => REV       = The slave ready signal is registrated
   //   4 => RESERVED (all outputs driven to 0).
   //   5 => RESERVED (all outputs driven to 0).
   //   6 => INPUTS    = Slave and Master side inputs are registrated.
   //   7 => LIGHT_WT  = 1-stage pipeline register with bubble cycle, both FWD and REV pipelining
   //   8 => ARB_REQ only = No register on incoming signals.  Only a register
   //   on ARB_REQ output. (Causes bubble cycles) Throughput is halved.
   parameter [C_NUM_MI_SLOTS-1:0] C_CONNECTIVITY = {C_NUM_MI_SLOTS{1'b1}},
   // Specifies connectivity matrix for sparse crossbar configurations
   parameter [C_NUM_MI_SLOTS*C_AXIS_TDEST_WIDTH-1:0] C_BASETDEST = {C_NUM_MI_SLOTS*C_AXIS_TDEST_WIDTH{1'b1}},
   // Array of TDEST base/high pairs for each master interface
   parameter [C_NUM_MI_SLOTS*C_AXIS_TDEST_WIDTH-1:0] C_HIGHTDEST = {C_NUM_MI_SLOTS*C_AXIS_TDEST_WIDTH{1'b0}}
)
(
///////////////////////////////////////////////////////////////////////////////
// Port Declarations
///////////////////////////////////////////////////////////////////////////////
   // System Signals
   input wire ACLK,
   input wire ARESET,
   input wire ACLKEN,

   // Slave side
   input  wire                          S_AXIS_TVALID,
   output wire                          S_AXIS_TREADY,
   input  wire [C_TPAYLOAD_WIDTH-1:0]   S_AXIS_TPAYLOAD,
   input  wire [C_AXIS_TDEST_WIDTH-1:0] S_AXIS_TDEST,

   // Master side
   output wire [C_NUM_MI_SLOTS-1:0]     M_AXIS_TVALID,
   input  wire [C_NUM_MI_SLOTS-1:0]     M_AXIS_TREADY,
   output wire [C_TPAYLOAD_WIDTH-1:0]   M_AXIS_TPAYLOAD,

   // ARBITER Side
   output wire                          ARB_LAST,
   output wire [C_AXIS_TID_WIDTH-1:0]   ARB_ID,
   output wire [C_AXIS_TDEST_WIDTH-1:0] ARB_DEST,
   output wire [C_AXIS_TUSER_WIDTH-1:0] ARB_USER,
   output wire [C_NUM_MI_SLOTS-1:0]     ARB_REQ,
   input  wire [C_NUM_MI_SLOTS-1:0]     ARB_DONE,
   input  wire [C_NUM_MI_SLOTS-1:0]     ARB_GNT,
   output wire [C_NUM_MI_SLOTS-1:0]     ARB_ACTIVE, // Status

   // err signals
   output wire                          DECODE_ERR
);

////////////////////////////////////////////////////////////////////////////////
// Functions
////////////////////////////////////////////////////////////////////////////////
`include "axis_interconnect_v1_1_axis_infrastructure.vh"

////////////////////////////////////////////////////////////////////////////////
// Local parameters
////////////////////////////////////////////////////////////////////////////////
localparam TDW = C_AXIS_TDEST_WIDTH;
localparam P_TDEST_PRESENT = C_AXIS_SIGNAL_SET[`G_INDX_SS_TDEST];

////////////////////////////////////////////////////////////////////////////////
// Wires/Reg declarations
////////////////////////////////////////////////////////////////////////////////
wire [C_NUM_MI_SLOTS-1:0]  busy_ns;
reg  [C_NUM_MI_SLOTS-1:0]  busy_r;
wire [C_NUM_MI_SLOTS-1:0]  dest_compare_match;
wire [C_NUM_MI_SLOTS-1:0]  arb_req_ns;
wire [C_NUM_MI_SLOTS-1:0]  arb_req_i;
wire                       decode_err_ns;
reg                        decode_err_r;
wire                       tready_or_decode_err;
wire                       m_axis_tvalid_payload;
wire                       m_axis_tvalid_req;
wire                       m_tready_from_decoded_slave;
////////////////////////////////////////////////////////////////////////////////
// BEGIN RTL
////////////////////////////////////////////////////////////////////////////////

// This selects only the TREADY of the MI slot we are requesting.
assign m_tready_from_decoded_slave = |(arb_req_i & M_AXIS_TREADY);

/* assign ARB_DONE = (C_USE_PACKET_MODE) ? ARB_LAST & m_tready_from_decoded_slave : m_tready_from_decoded_slave;*/

assign busy_ns =  (ARB_GNT | busy_r) & ~ARB_DONE;

always @(posedge ACLK) begin 
  if (ARESET) begin
    busy_r <= {C_NUM_MI_SLOTS{1'b0}};
  end else if (ACLKEN) begin
    busy_r <= busy_ns;
  end
end

assign ARB_ACTIVE = busy_r;

generate
genvar mi;

  if (P_TDEST_PRESENT) begin : gen_tdest_decoder
    for (mi = 0; mi < C_NUM_MI_SLOTS; mi = mi + 1) begin : gen_decode_loop
      if (C_CONNECTIVITY[mi] && (C_BASETDEST[mi*TDW+:TDW] <= C_HIGHTDEST[mi*TDW+:TDW])) begin : gen_master_connectivity
        assign dest_compare_match[mi] = ((S_AXIS_TDEST >= C_BASETDEST[mi*TDW+:TDW]) && (S_AXIS_TDEST <= C_HIGHTDEST[mi*TDW+:TDW])) 
                            ? 1'b1 : 1'b0;
       
        // Mux in the comparison only when S_AXIS_TVALID to avoid x propogation.
        assign arb_req_ns[mi] = S_AXIS_TVALID ? dest_compare_match[mi] : 1'b0; 
      end
      else begin : no_master_connectivity
        assign arb_req_ns[mi] = 1'b0;
      end
    end

    wire [C_NUM_MI_SLOTS-1:0] arb_req_out;

    axis_interconnect_v1_1_axisc_register_slice #(
      .C_FAMILY     ( C_FAMILY         ) ,
      .C_DATA_WIDTH ( C_TPAYLOAD_WIDTH ) ,
      .C_REG_CONFIG ( C_REG_CONFIG     ) 
    )
    axisc_register_slice_0 (
      .ACLK           ( ACLK                  ) ,
      .ARESET         ( ARESET                ) ,
      .ACLKEN         ( ACLKEN                ) ,
      .S_VALID        ( S_AXIS_TVALID         ) ,
      .S_READY        ( S_AXIS_TREADY         ) ,
      .S_PAYLOAD_DATA ( S_AXIS_TPAYLOAD       ) ,

      .M_VALID        ( m_axis_tvalid_payload ) , // Tvalid ignored, and the tvalid from the reg slice below is used.
      .M_READY        ( tready_or_decode_err  ) ,
      .M_PAYLOAD_DATA ( M_AXIS_TPAYLOAD       ) 
    );

    axis_interconnect_v1_1_axisc_register_slice #(
      .C_FAMILY     ( C_FAMILY       ) ,
      .C_DATA_WIDTH ( C_NUM_MI_SLOTS ) ,
      .C_REG_CONFIG ( C_REG_CONFIG   ) 
    )
    axisc_register_slice_1 (
      .ACLK           ( ACLK                 ) ,
      .ARESET         ( ARESET               ) ,
      .ACLKEN         ( ACLKEN               ) ,
      .S_VALID        ( S_AXIS_TVALID        ) ,
      .S_READY        (                      ) , // Ready output ignored since the Ready from reg_slice_0 is identical.
      .S_PAYLOAD_DATA ( arb_req_ns           ) ,

      .M_VALID        ( m_axis_tvalid_req    ) ,
      .M_READY        ( tready_or_decode_err ) ,
      .M_PAYLOAD_DATA ( arb_req_out          ) 
    );
    
    assign arb_req_i = m_axis_tvalid_req ? arb_req_out : {C_NUM_MI_SLOTS{1'b0}};

  end
  // If no tdest, then no tdest decoding can be performed. If single mi
  // system always decode to mi[0].
  else if (P_TDEST_PRESENT == 0 && C_NUM_MI_SLOTS == 1 && C_CONNECTIVITY[0] == 1'b1) begin : gen_no_tdest_decoder
    assign S_AXIS_TREADY = tready_or_decode_err;

    assign m_axis_tvalid_payload = S_AXIS_TVALID;
    assign M_AXIS_TPAYLOAD = S_AXIS_TPAYLOAD;
    assign m_axis_tvalid_req = S_AXIS_TVALID;
    assign arb_req_i = S_AXIS_TVALID;
  end
  // This case represents P_TDEST_PRESNT == 0 and C_NUM_MI_SLOTS > 1).  Need
  // tdets pins to route to multiple MI slots.
  else begin : gen_invalid_configuration 
    assign arb_req_i = {C_NUM_MI_SLOTS{1'b0}};
    assign S_AXIS_TREADY = 1'b0;
    assign m_axis_tvalid_payload = 1'b0;
    assign m_axis_tvalid_req = 1'b0;
    assign M_AXIS_TPAYLOAD = S_AXIS_TPAYLOAD;
  end
endgenerate

assign M_AXIS_TVALID = arb_req_i;

assign ARB_REQ = ~busy_r & arb_req_i;
// Decode Err: Decode err occurs when M_AXIS_TVALID = 1'b1 but none of the ARB_REQ
// have been asserted
assign decode_err_ns = ~(|arb_req_i) & m_axis_tvalid_req;

// decode_err is registered to minimize timing impact.  Results in a bubble
// cycle when an err occurs
always @(posedge ACLK) begin
  if (ARESET) begin
    decode_err_r <= {C_NUM_MI_SLOTS{1'b0}};
  end
  else if (ACLKEN) begin
    decode_err_r <= decode_err_ns & ~decode_err_r;
  end
end

assign tready_or_decode_err = m_tready_from_decoded_slave | decode_err_r;
assign DECODE_ERR = decode_err_r;

// Output ARBITER decision value from M_AXIS_TPAYLOAD
axis_interconnect_v1_1_util_vector2axis #(
  .C_TDATA_WIDTH    ( C_AXIS_TDATA_WIDTH ) ,
  .C_TID_WIDTH      ( C_AXIS_TID_WIDTH   ) ,
  .C_TDEST_WIDTH    ( C_AXIS_TDEST_WIDTH ) ,
  .C_TUSER_WIDTH    ( C_AXIS_TUSER_WIDTH ) ,
  .C_TPAYLOAD_WIDTH ( C_TPAYLOAD_WIDTH   ) ,
  .C_SIGNAL_SET     ( C_AXIS_SIGNAL_SET  ) 
)
util_vector2axis_0 (
  .TPAYLOAD ( M_AXIS_TPAYLOAD ) ,
  .TDATA    (                 ) ,
  .TSTRB    (                 ) ,
  .TKEEP    (                 ) ,
  .TLAST    ( ARB_LAST        ) ,
  .TID      ( ARB_ID          ) ,
  .TDEST    ( ARB_DEST        ) ,
  .TUSER    ( ARB_USER        ) 
);

endmodule // axisc_decoder

`default_nettype wire
