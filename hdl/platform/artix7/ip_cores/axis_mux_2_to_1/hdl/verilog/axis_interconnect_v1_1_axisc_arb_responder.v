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
//
// Verilog-standard:  Verilog 2001
//--------------------------------------------------------------------------
//
// Structure:
//   axisc_arb_responder
//
//--------------------------------------------------------------------------

`timescale 1ps/1ps
`default_nettype none

module axis_interconnect_v1_1_axisc_arb_responder #
(
///////////////////////////////////////////////////////////////////////////////
// Parameter Definitions
///////////////////////////////////////////////////////////////////////////////
   parameter         C_FAMILY           = "virtex7",
   parameter integer C_ARB_GNT_WIDTH    = 1,
   parameter integer C_USE_PACKET_MODE  = 1,
   // C_USE_PACKET_MODE: 
   //   0 => Ignore TLAST
   //   1 => Signal ARB_DONE on TLAST
   parameter integer C_MAX_XFERS_PER_ARB = 0,
   // C_MAX_XFERS_PER_ARB: 
   //  0 => Ignore number of transfers to signal DONE
   //  1+ => Signal ARB_DONE after x TRANSFERS
   parameter integer C_NUM_CYCLES_TIMEOUT = 0,
   // C_NUM_CYCLE_TIMEOUT: 
   //  0 => Ignore TIMEOUT parameter
   //  1+ => Signal ARB_DONE after x cylces of TVALID low
   parameter integer C_SINGLE_SLAVE_CONNECTIVITY = 0
   // C_SINGLE_SLAVE_CONNECTIVITY:
   // Indicates there is no need for arbiter, assert arb_done on every
   // VALID/READY.
)
(
///////////////////////////////////////////////////////////////////////////////
// Port Declarations
///////////////////////////////////////////////////////////////////////////////
   // System Signals
   input wire ACLK,
   input wire ARESET,
   input wire ACLKEN,

   // AXIS monitored signals
   input wire                           AXIS_TVALID,
   input wire                           AXIS_TREADY,
   input wire                           AXIS_TLAST,

   // Arbiter side
   input  wire [C_ARB_GNT_WIDTH-1:0]    ARB_GNT,
   output wire                          ARB_DONE,

   // Status Signals
   output wire [C_ARB_GNT_WIDTH-1:0]    ARB_BUSY
);

////////////////////////////////////////////////////////////////////////////////
// Functions
////////////////////////////////////////////////////////////////////////////////
`include "axis_interconnect_v1_1_axis_infrastructure.vh"

////////////////////////////////////////////////////////////////////////////////
// Local parameters
////////////////////////////////////////////////////////////////////////////////
localparam integer P_XFER_CNT_WIDTH = f_clogb2(C_MAX_XFERS_PER_ARB);
localparam integer P_TIMEOUT_CNT_WIDTH = f_clogb2(C_NUM_CYCLES_TIMEOUT+1);
localparam integer P_FORCE_MAX_XFERS_PER_ARB_ONE = (C_USE_PACKET_MODE == 0 
                                                    && C_MAX_XFERS_PER_ARB == 0 
                                                    && C_NUM_CYCLES_TIMEOUT == 0) ? 1 : 0;



////////////////////////////////////////////////////////////////////////////////
// Wires/Reg declarations
////////////////////////////////////////////////////////////////////////////////
wire [C_ARB_GNT_WIDTH-1:0]   busy_ns;
reg  [C_ARB_GNT_WIDTH-1:0]   busy_r;

wire tlast_done;
wire xfer_done;
wire timeout_done;
wire timeout_done_ns;
////////////////////////////////////////////////////////////////////////////////
// BEGIN RTL
////////////////////////////////////////////////////////////////////////////////
assign busy_ns = timeout_done_ns | ARB_DONE ? {C_ARB_GNT_WIDTH{1'b0}} : ARB_GNT | busy_r;

always @(posedge ACLK) begin 
  if (ARESET) begin
    busy_r <= {C_ARB_GNT_WIDTH{1'b0}};
  end else if (ACLKEN) begin
    busy_r <= busy_ns;
  end
end

assign ARB_BUSY = busy_r;

assign ARB_DONE = tlast_done | xfer_done | timeout_done;

generate 
  if (C_SINGLE_SLAVE_CONNECTIVITY | P_FORCE_MAX_XFERS_PER_ARB_ONE) begin : gen_default_response
    assign tlast_done = 1'b0;
    assign xfer_done = AXIS_TVALID & AXIS_TREADY;
    assign timeout_done = 1'b0;
    assign timeout_done_ns = 1'b0;
  end
  else begin : gen_configurable_response
    // Generate TLAST DONE block
    assign tlast_done = C_USE_PACKET_MODE & (AXIS_TVALID & AXIS_TREADY) ? AXIS_TLAST : 1'b0;

    // Generate XFER_DONE block
    if (C_MAX_XFERS_PER_ARB == 0) begin : gen_max_xfer_per_arb_cnt_disabled
      assign xfer_done = 1'b0;
    end
    else if (C_MAX_XFERS_PER_ARB == 1) begin : gen_max_xfers_per_arb_cnt_one
      assign xfer_done = AXIS_TVALID & AXIS_TREADY;
    end
    else begin : gen_max_xfer_per_arb_cntr
      reg [P_XFER_CNT_WIDTH-1:0] xfer_cnt;
      reg                        xfer_done_r;
      wire                       xfer_cnt_ns;


      always @(posedge ACLK) begin 
        if (ARESET) begin
          xfer_cnt <= {P_XFER_CNT_WIDTH{1'b0}};
        end else if (ACLKEN) begin
          xfer_cnt <= ARB_DONE ? {P_XFER_CNT_WIDTH{1'b0}} : 
                    (AXIS_TVALID & AXIS_TREADY) ? xfer_cnt + 1'b1 : xfer_cnt;
        end
        else begin 
          xfer_cnt <= xfer_cnt;
        end
      end

      always @(posedge ACLK) begin
        if (ARESET) begin
          xfer_done_r <= 1'b0;
        end else if (ACLKEN) begin
          xfer_done_r <= ARB_DONE ? 1'b0 : 
                         (AXIS_TVALID & AXIS_TREADY) ? (xfer_cnt == C_MAX_XFERS_PER_ARB-2) : xfer_done_r;
        end
        else begin
          xfer_done_r <= xfer_done_r;
        end
      end
      assign xfer_done = xfer_done_r & AXIS_TVALID & AXIS_TREADY;
    end

    // Generate TIMEOUT DONE block
    if (C_NUM_CYCLES_TIMEOUT == 0) begin : gen_num_cycles_timeout_disabled
      assign timeout_done = 1'b0;
      assign timeout_done_ns = 1'b0;
    end
    else begin : gen_num_cycles_timeout_cntr
      reg [P_TIMEOUT_CNT_WIDTH-1:0] timeout_cnt;
      reg                           timeout_done_r;
      always @(posedge ACLK) begin 
        if (ARESET) begin
          timeout_cnt <= {P_TIMEOUT_CNT_WIDTH{1'b0}};
        end else if (ACLKEN) begin
          timeout_cnt <= AXIS_TVALID ? {P_TIMEOUT_CNT_WIDTH{1'b0}} : timeout_cnt + 1'b1;
        end else begin
          timeout_cnt <= timeout_cnt;
        end
      end

      assign timeout_done_ns = (|busy_r) ? (timeout_cnt == C_NUM_CYCLES_TIMEOUT) & ~AXIS_TVALID : 1'b0;

      always @(posedge ACLK) begin
        if (ARESET) begin
          timeout_done_r <= 1'b0;
        end else if (ACLKEN) begin
          timeout_done_r <= timeout_done_ns;
        end
      end
      assign timeout_done = timeout_done_r;
    end
  end
endgenerate

endmodule // axisc_transfer_mux

`default_nettype wire
