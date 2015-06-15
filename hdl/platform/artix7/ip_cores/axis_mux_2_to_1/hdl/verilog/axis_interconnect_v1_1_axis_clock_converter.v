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
// axis_clock_converter
//
// Verilog-standard:  Verilog 2001
//--------------------------------------------------------------------------
//
// Structure:
//   axis_clock_converter
//     util_aclken_converter (optional)
//     fifo_generator
//       or
//     axisc_sync_clock_converter
//     util_aclken_converter (optional)
//--------------------------------------------------------------------------

`timescale 1ps/1ps
`default_nettype none

module axis_interconnect_v1_1_axis_clock_converter #
(
///////////////////////////////////////////////////////////////////////////////
// Parameter Definitions
///////////////////////////////////////////////////////////////////////////////
  parameter         C_FAMILY           = "virtex6",
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
  parameter         C_IS_ACLK_ASYNC     = 1'b1,
  parameter integer C_S_AXIS_ACLK_RATIO = 1,
  parameter integer C_M_AXIS_ACLK_RATIO = 1,
  parameter integer C_ACLKEN_CONV_MODE  = 0
  // C_ACLKEN_CONV_MODE: Determines how to handle the clock enable pins during
  // clock conversion
  // 0 -- Clock enables not converted
  // 1 -- S_AXIS_ACLKEN can toggle,  M_AXIS_ACLKEN always high.
  // 2 -- S_AXIS_ACLKEN always high, M_AXIS_ACLKEN can toggle.
  // 3 -- S_AXIS_ACLKEN can toggle,  M_AXIS_ACLKEN can toggle.
  )
  (
///////////////////////////////////////////////////////////////////////////////
// Port Declarations
///////////////////////////////////////////////////////////////////////////////
   // System Signals
   input wire                             S_AXIS_ARESETN,
   input wire                             M_AXIS_ARESETN,
   input wire                             S_AXIS_ACLKEN,
   input wire                             M_AXIS_ACLKEN,

   // Slave side
   input  wire                            S_AXIS_ACLK,
   input  wire                            S_AXIS_TVALID,
   output wire                            S_AXIS_TREADY,
   input  wire [C_AXIS_TDATA_WIDTH-1:0]   S_AXIS_TDATA,
   input  wire [C_AXIS_TDATA_WIDTH/8-1:0] S_AXIS_TSTRB,
   input  wire [C_AXIS_TDATA_WIDTH/8-1:0] S_AXIS_TKEEP,
   input  wire                            S_AXIS_TLAST,
   input  wire [C_AXIS_TID_WIDTH-1:0]     S_AXIS_TID,
   input  wire [C_AXIS_TDEST_WIDTH-1:0]   S_AXIS_TDEST,
   input  wire [C_AXIS_TUSER_WIDTH-1:0]   S_AXIS_TUSER,

   // Master side
   input  wire                            M_AXIS_ACLK,
   output wire                            M_AXIS_TVALID,
   input  wire                            M_AXIS_TREADY,
   output wire [C_AXIS_TDATA_WIDTH-1:0]   M_AXIS_TDATA,
   output wire [C_AXIS_TDATA_WIDTH/8-1:0] M_AXIS_TSTRB,
   output wire [C_AXIS_TDATA_WIDTH/8-1:0] M_AXIS_TKEEP,
   output wire                            M_AXIS_TLAST,
   output wire [C_AXIS_TID_WIDTH-1:0]     M_AXIS_TID,
   output wire [C_AXIS_TDEST_WIDTH-1:0]   M_AXIS_TDEST,
   output wire [C_AXIS_TUSER_WIDTH-1:0]   M_AXIS_TUSER

   );

////////////////////////////////////////////////////////////////////////////////
// Functions
////////////////////////////////////////////////////////////////////////////////
`include "axis_interconnect_v1_1_axis_infrastructure.vh"

////////////////////////////////////////////////////////////////////////////////
// Local parameters
////////////////////////////////////////////////////////////////////////////////
localparam integer LP_S_ACLKEN_CAN_TOGGLE = (C_ACLKEN_CONV_MODE == 1) || (C_ACLKEN_CONV_MODE == 3);
localparam integer LP_M_ACLKEN_CAN_TOGGLE = (C_ACLKEN_CONV_MODE == 2) || (C_ACLKEN_CONV_MODE == 3);
localparam integer P_FIFO_MODE            = 1;  // clock converter use of fifo_gen will not 
                                                // use packet mode.                                           
localparam integer P_FIFO_DEPTH           = 32; // clock converter use of fifo_gen be fixed 
                                                // at 32 deep fifo.
                                          
localparam integer P_S_AXIS_ACLK_RATIO    = f_lcm(C_S_AXIS_ACLK_RATIO, C_M_AXIS_ACLK_RATIO) / C_M_AXIS_ACLK_RATIO;
localparam integer P_M_AXIS_ACLK_RATIO    = f_lcm(C_S_AXIS_ACLK_RATIO, C_M_AXIS_ACLK_RATIO) / C_S_AXIS_ACLK_RATIO;
                                          
localparam integer P_INST_FIFO_GEN        =  C_IS_ACLK_ASYNC || (P_S_AXIS_ACLK_RATIO != 1 && P_M_AXIS_ACLK_RATIO != 1);
                                          
localparam integer P_TPAYLOAD_WIDTH       = f_payload_width(C_AXIS_TDATA_WIDTH, C_AXIS_TID_WIDTH, 
                                                 C_AXIS_TDEST_WIDTH, C_AXIS_TUSER_WIDTH, 
                                                 C_AXIS_SIGNAL_SET);
localparam integer P_SAMPLE_CYCLE_RATIO   = (C_S_AXIS_ACLK_RATIO > C_M_AXIS_ACLK_RATIO) 
                                            ? C_S_AXIS_ACLK_RATIO : C_M_AXIS_ACLK_RATIO;


////////////////////////////////////////////////////////////////////////////////
// Wires/Reg declarations
////////////////////////////////////////////////////////////////////////////////
wire [P_TPAYLOAD_WIDTH-1:0] s_axis_tpayload;

wire [P_TPAYLOAD_WIDTH-1:0] d1_tpayload;
wire                        d1_tvalid;
wire                        d1_tready;

wire [P_TPAYLOAD_WIDTH-1:0] d2_tpayload;
wire                        d2_tvalid;
wire                        d2_tready;

wire [P_TPAYLOAD_WIDTH-1:0] m_axis_tpayload;


////////////////////////////////////////////////////////////////////////////////
// BEGIN RTL
////////////////////////////////////////////////////////////////////////////////



generate
  if (P_INST_FIFO_GEN) begin : gen_fifo_gen_ck_conv
    // Asynchronous and default is to use fifo_gen for clock conversion
    axis_interconnect_v1_1_axis_data_fifo #(
      .C_FAMILY           ( C_FAMILY           ) ,
      .C_AXIS_TDATA_WIDTH ( C_AXIS_TDATA_WIDTH ) ,
      .C_AXIS_TID_WIDTH   ( C_AXIS_TID_WIDTH   ) ,
      .C_AXIS_TDEST_WIDTH ( C_AXIS_TDEST_WIDTH ) ,
      .C_AXIS_TUSER_WIDTH ( C_AXIS_TUSER_WIDTH ) ,
      .C_AXIS_SIGNAL_SET  ( C_AXIS_SIGNAL_SET  ) ,
      .C_FIFO_DEPTH       ( P_FIFO_DEPTH       ) ,
      .C_FIFO_MODE        ( P_FIFO_MODE        ) ,
      .C_IS_ACLK_ASYNC    ( 1                  ) , // enables clock cross when 1
      .C_ACLKEN_CONV_MODE ( C_ACLKEN_CONV_MODE )
    )
    axis_data_fifo_0
    (
      .S_AXIS_ARESETN ( S_AXIS_ARESETN ) ,
      .M_AXIS_ARESETN ( M_AXIS_ARESETN ) ,
      .S_AXIS_ACLK    ( S_AXIS_ACLK    ) ,
      .S_AXIS_ACLKEN  ( S_AXIS_ACLKEN  ) ,
      .S_AXIS_TVALID  ( S_AXIS_TVALID  ) ,
      .S_AXIS_TREADY  ( S_AXIS_TREADY  ) ,
      .S_AXIS_TDATA   ( S_AXIS_TDATA   ) ,
      .S_AXIS_TSTRB   ( S_AXIS_TSTRB   ) ,
      .S_AXIS_TKEEP   ( S_AXIS_TKEEP   ) ,
      .S_AXIS_TLAST   ( S_AXIS_TLAST   ) ,
      .S_AXIS_TID     ( S_AXIS_TID     ) ,
      .S_AXIS_TDEST   ( S_AXIS_TDEST   ) ,
      .S_AXIS_TUSER   ( S_AXIS_TUSER   ) ,
      .M_AXIS_ACLK    ( M_AXIS_ACLK    ) ,
      .M_AXIS_ACLKEN  ( M_AXIS_ACLKEN  ) ,
      .M_AXIS_TVALID  ( M_AXIS_TVALID  ) ,
      .M_AXIS_TREADY  ( M_AXIS_TREADY  ) ,
      .M_AXIS_TDATA   ( M_AXIS_TDATA   ) ,
      .M_AXIS_TSTRB   ( M_AXIS_TSTRB   ) ,
      .M_AXIS_TKEEP   ( M_AXIS_TKEEP   ) ,
      .M_AXIS_TLAST   ( M_AXIS_TLAST   ) ,
      .M_AXIS_TID     ( M_AXIS_TID     ) ,
      .M_AXIS_TDEST   ( M_AXIS_TDEST   ) ,
      .M_AXIS_TUSER   ( M_AXIS_TUSER   ) ,
      .AXIS_DATA_COUNT    (            ) ,
      .AXIS_WR_DATA_COUNT (            ) ,
      .AXIS_RD_DATA_COUNT (            ) 
    );
  end
  else begin : gen_sync_ck_conv

    wire                        slow_aclk;
    wire                        fast_aclk;
    wire                        sample_cycle_early;
    wire                        sample_cycle;

    axis_interconnect_v1_1_util_axis2vector #(
      .C_TDATA_WIDTH    ( C_AXIS_TDATA_WIDTH ) ,
      .C_TID_WIDTH      ( C_AXIS_TID_WIDTH   ) ,
      .C_TDEST_WIDTH    ( C_AXIS_TDEST_WIDTH ) ,
      .C_TUSER_WIDTH    ( C_AXIS_TUSER_WIDTH ) ,
      .C_TPAYLOAD_WIDTH ( P_TPAYLOAD_WIDTH   ) ,
      .C_SIGNAL_SET     ( C_AXIS_SIGNAL_SET  ) 
    )
    util_axis2vector_0 (
      .TDATA    ( S_AXIS_TDATA    ) ,
      .TSTRB    ( S_AXIS_TSTRB    ) ,
      .TKEEP    ( S_AXIS_TKEEP    ) ,
      .TLAST    ( S_AXIS_TLAST    ) ,
      .TID      ( S_AXIS_TID      ) ,
      .TDEST    ( S_AXIS_TDEST    ) ,
      .TUSER    ( S_AXIS_TUSER    ) ,
      .TPAYLOAD ( s_axis_tpayload )
    );

    if (LP_S_ACLKEN_CAN_TOGGLE) begin : gen_s_aclken_converter
      axis_interconnect_v1_1_util_aclken_converter #( 
        .C_PAYLOAD_WIDTH       ( P_TPAYLOAD_WIDTH       ) ,
        .C_S_ACLKEN_CAN_TOGGLE ( LP_S_ACLKEN_CAN_TOGGLE ) ,
        .C_M_ACLKEN_CAN_TOGGLE ( 0                      ) 
      )
      s_util_aclken_converter_0 ( 
        .ACLK      ( S_AXIS_ACLK     ) ,
        .ARESETN   ( S_AXIS_ARESETN  ) ,
        .S_ACLKEN  ( S_AXIS_ACLKEN   ) ,
        .S_PAYLOAD ( s_axis_tpayload ) ,
        .S_VALID   ( S_AXIS_TVALID   ) ,
        .S_READY   ( S_AXIS_TREADY   ) ,
        .M_ACLKEN  ( 1'b1            ) ,
        .M_PAYLOAD ( d1_tpayload     ) ,
        .M_VALID   ( d1_tvalid       ) ,
        .M_READY   ( d1_tready       )
      );
    end
    else begin : gen_s_aclken_passthru
      assign d1_tpayload = s_axis_tpayload;
      assign d1_tvalid   = S_AXIS_TVALID;
      assign S_AXIS_TREADY = d1_tready;
    end

    // Sample cycle used to determine when to assert a signal on a fast clock
    // to be flopped onto a slow clock.
    assign slow_aclk   = (C_S_AXIS_ACLK_RATIO > C_M_AXIS_ACLK_RATIO) ? M_AXIS_ACLK   : S_AXIS_ACLK;
    assign fast_aclk   = (C_S_AXIS_ACLK_RATIO < C_M_AXIS_ACLK_RATIO) ? M_AXIS_ACLK   : S_AXIS_ACLK;

    axis_interconnect_v1_1_axisc_sample_cycle_ratio #(
      .C_RATIO ( P_SAMPLE_CYCLE_RATIO )
    ) 
    axisc_sample_cycle_ratio_m (
      .SLOW_ACLK          ( slow_aclk          ) ,
      .FAST_ACLK          ( fast_aclk          ) ,
      .SAMPLE_CYCLE_EARLY ( sample_cycle_early ) ,
      .SAMPLE_CYCLE       ( sample_cycle       ) 
    );

    axis_interconnect_v1_1_axisc_sync_clock_converter #( 
      .C_FAMILY        ( C_FAMILY            ) ,
      .C_PAYLOAD_WIDTH ( P_TPAYLOAD_WIDTH    ) ,
      .C_S_ACLK_RATIO  ( P_S_AXIS_ACLK_RATIO ) ,
      .C_M_ACLK_RATIO  ( P_M_AXIS_ACLK_RATIO ) ,
      .C_MODE          ( 1 )
    )
    axisc_sync_clock_converter_0 (
      .SAMPLE_CYCLE_EARLY ( sample_cycle_early ) ,
      .SAMPLE_CYCLE       ( sample_cycle       ) ,
      .S_ACLK             ( S_AXIS_ACLK        ) ,
      .S_ARESETN          ( S_AXIS_ARESETN     ) ,
      .S_PAYLOAD          ( d1_tpayload        ) ,
      .S_VALID            ( d1_tvalid          ) ,
      .S_READY            ( d1_tready          ) ,
      .M_ACLK             ( M_AXIS_ACLK        ) ,
      .M_ARESETN          ( M_AXIS_ARESETN     ) ,
      .M_PAYLOAD          ( d2_tpayload        ) ,
      .M_VALID            ( d2_tvalid          ) ,
      .M_READY            ( d2_tready          ) 
    );

    if (LP_M_ACLKEN_CAN_TOGGLE) begin : gen_m_aclken_converter
      axis_interconnect_v1_1_util_aclken_converter #( 
        .C_PAYLOAD_WIDTH       ( P_TPAYLOAD_WIDTH       ) ,
        .C_S_ACLKEN_CAN_TOGGLE ( 0                      ) ,
        .C_M_ACLKEN_CAN_TOGGLE ( LP_M_ACLKEN_CAN_TOGGLE ) 
      )
      m_util_aclken_converter_0 ( 
        .ACLK      ( M_AXIS_ACLK     ) ,
        .ARESETN   ( M_AXIS_ARESETN  ) ,
        .S_ACLKEN  ( 1'b1            ) ,
        .S_PAYLOAD ( d2_tpayload     ) ,
        .S_VALID   ( d2_tvalid       ) ,
        .S_READY   ( d2_tready       ) ,
        .M_ACLKEN  ( M_AXIS_ACLKEN   ) ,
        .M_PAYLOAD ( m_axis_tpayload ) ,
        .M_VALID   ( M_AXIS_TVALID   ) ,
        .M_READY   ( M_AXIS_TREADY   ) 
      );
    end
    else begin : gen_m_aclken_passthru
      assign m_axis_tpayload = d2_tpayload;
      assign M_AXIS_TVALID = d2_tvalid;
      assign d2_tready = M_AXIS_TREADY;
    end

    axis_interconnect_v1_1_util_vector2axis #(
      .C_TDATA_WIDTH    ( C_AXIS_TDATA_WIDTH ) ,
      .C_TID_WIDTH      ( C_AXIS_TID_WIDTH   ) ,
      .C_TDEST_WIDTH    ( C_AXIS_TDEST_WIDTH ) ,
      .C_TUSER_WIDTH    ( C_AXIS_TUSER_WIDTH ) ,
      .C_TPAYLOAD_WIDTH ( P_TPAYLOAD_WIDTH   ) ,
      .C_SIGNAL_SET     ( C_AXIS_SIGNAL_SET  ) 
    )
    util_vector2axis_0 (
      .TPAYLOAD ( m_axis_tpayload ) ,
      .TDATA    ( M_AXIS_TDATA    ) ,
      .TSTRB    ( M_AXIS_TSTRB    ) ,
      .TKEEP    ( M_AXIS_TKEEP    ) ,
      .TLAST    ( M_AXIS_TLAST    ) ,
      .TID      ( M_AXIS_TID      ) ,
      .TDEST    ( M_AXIS_TDEST    ) ,
      .TUSER    ( M_AXIS_TUSER    ) 
    );
  end

endgenerate



endmodule // axis_clock_converter

`default_nettype wire
