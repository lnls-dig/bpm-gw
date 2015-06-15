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
//   dynamic_datapath
//     subset_converter
//     register_slice
//     dwidth_converter(up)
//     clock_converter
//     dwidth_converter(down)
//     packer
//     FIFO   
//  
//--------------------------------------------------------------------------

`timescale 1ps/1ps
`default_nettype none

module axis_interconnect_v1_1_dynamic_datapath #
(
///////////////////////////////////////////////////////////////////////////////
// Parameter Definitions
///////////////////////////////////////////////////////////////////////////////
   parameter         C_FAMILY             = "virtex6",
   parameter [31:0]  C_S_AXIS_TDATA_WIDTH = 32'd32,
   parameter [31:0]  C_S_AXIS_TID_WIDTH   = 32'd1,
   parameter [31:0]  C_S_AXIS_TDEST_WIDTH = 32'd1,
   parameter [31:0]  C_S_AXIS_TUSER_WIDTH = 32'd1,
   parameter [31:0]  C_S_AXIS_SIGNAL_SET  = 32'hFF ,
   parameter [31:0]  C_S_AXIS_ACLK_RATIO  = 32'd0,
   parameter [31:0]  C_M_AXIS_TDATA_WIDTH = 32'd32,
   parameter [31:0]  C_M_AXIS_TID_WIDTH   = 32'd1,
   parameter [31:0]  C_M_AXIS_TDEST_WIDTH = 32'd1,
   parameter [31:0]  C_M_AXIS_TUSER_WIDTH = 32'd2,
   parameter [31:0]  C_M_AXIS_SIGNAL_SET  = 32'hFF ,
   // C_AXIS_SIGNAL_SET: each bit if enabled specifies which axis optional signals are present
   //   [0] => TREADY present
   //   [1] => TDATA present
   //   [2] => TSTRB present, TDATA must be present
   //   [3] => TKEEP present, TDATA must be present
   //   [4] => TLAST present
   //   [5] => TID present
   //   [6] => TDEST present
   //   [7] => TUSER present
   parameter [31:0]  C_M_AXIS_ACLK_RATIO = 32'd0,
   parameter [31:0]  C_REG_CONFIG        = 32'd1,
   parameter [31:0]  C_IS_ACLK_ASYNC     = 32'd0,
   parameter [31:0]  C_ACLKEN_CONV_MODE  = 32'd0,
   parameter [31:0]  C_FIFO_DEPTH        = 32'd1024,
   parameter [31:0]  C_FIFO_MODE         = 1,
   parameter [8*32-1:0] C_MODULE_ORDER = {32'h0, 32'h1, 32'h2, 32'h4, 32'h6, 32'h5, 32'h8, 32'h7} 
   // C_MODULE_ORDER is an array of modules to be instantiated from left (SI) to
   // right (MI). 
   // Available Modules:
   // 0 = Pass through (just wires)
   // 1 = Register Slice
   // 2 = Subset Converter
   // 3 = Data Width Converter (any)
   // 4 = Data Width Converter (up only)
   // 5 = Data Width Converter (down only)
   // 6 = Clock Converter
   // 7 = Data FIFO
   // 8 = Packer
   )
  (
///////////////////////////////////////////////////////////////////////////////
// Port Declarations
///////////////////////////////////////////////////////////////////////////////

   // Slave side
   input wire                               S_AXIS_ACLK,
   input wire                               S_AXIS_ARESETN,
   input wire                               S_AXIS_ACLKEN,
   input  wire                              S_AXIS_TVALID,
   output wire                              S_AXIS_TREADY,
   input  wire [C_S_AXIS_TDATA_WIDTH-1:0]   S_AXIS_TDATA,
   input  wire [C_S_AXIS_TDATA_WIDTH/8-1:0] S_AXIS_TSTRB,
   input  wire [C_S_AXIS_TDATA_WIDTH/8-1:0] S_AXIS_TKEEP,
   input  wire                              S_AXIS_TLAST,
   input  wire [C_S_AXIS_TID_WIDTH-1:0]     S_AXIS_TID,
   input  wire [C_S_AXIS_TDEST_WIDTH-1:0]   S_AXIS_TDEST,
   input  wire [C_S_AXIS_TUSER_WIDTH-1:0]   S_AXIS_TUSER,

   // Master side
   input wire                               M_AXIS_ACLK,
   input wire                               M_AXIS_ARESETN,
   input wire                               M_AXIS_ACLKEN,
   output wire                              M_AXIS_TVALID,
   input  wire                              M_AXIS_TREADY,
   output wire [C_M_AXIS_TDATA_WIDTH-1:0]   M_AXIS_TDATA,
   output wire [C_M_AXIS_TDATA_WIDTH/8-1:0] M_AXIS_TSTRB,
   output wire [C_M_AXIS_TDATA_WIDTH/8-1:0] M_AXIS_TKEEP,
   output wire                              M_AXIS_TLAST,
   output wire [C_M_AXIS_TID_WIDTH-1:0]     M_AXIS_TID,
   output wire [C_M_AXIS_TDEST_WIDTH-1:0]   M_AXIS_TDEST,
   output wire [C_M_AXIS_TUSER_WIDTH-1:0]   M_AXIS_TUSER,

   // Status signals
   output wire                              SPARSE_TKEEP_REMOVED,
   output wire                              PACKER_ERR,
   output wire [31:0]                       S_FIFO_DATA_COUNT,
   output wire [31:0]                       M_FIFO_DATA_COUNT 

   );

////////////////////////////////////////////////////////////////////////////////
// Functions
////////////////////////////////////////////////////////////////////////////////
// `include "axis_interconnect_v1_1_axis_infrastructure.vh"

////////////////////////////////////////////////////////////////////////////////
// Local parameters
////////////////////////////////////////////////////////////////////////////////
// Special rule, if doing async clock conversion and using a fifo, then merge
// clock conversion into data fifo
localparam P_CK_CONV_IN_DATA_FIFO = (C_IS_ACLK_ASYNC == 32'd1) && (C_FIFO_MODE == 32'd1) && (C_FIFO_DEPTH > 32'd0);
localparam P_DEFAULT_TLAST = 0; // Set TLAST LOW.

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

// Determine which generates instantiate modules
localparam P_GEN_PASS_THRU = (C_MODULE_ORDER[31:0] == P_INDX_DP_PASS_THRU);
localparam P_GEN_REG_SLICE = (C_MODULE_ORDER[31:0] == P_INDX_DP_REG_SLICE) && (C_REG_CONFIG > 0);
 // TODO: Add cases other than signal subset conversion
localparam P_GEN_SS_CONV   = (C_MODULE_ORDER[31:0] == P_INDX_DP_SS_CONV  ) && (C_S_AXIS_SIGNAL_SET != C_M_AXIS_SIGNAL_SET);
localparam P_GEN_DW_CONV   = (C_MODULE_ORDER[31:0] == P_INDX_DP_DW_CONV  ) && (C_S_AXIS_TDATA_WIDTH != C_M_AXIS_TDATA_WIDTH);
localparam P_GEN_DW_CONV_U = (C_MODULE_ORDER[31:0] == P_INDX_DP_DW_CONV_U) && (C_S_AXIS_TDATA_WIDTH < C_M_AXIS_TDATA_WIDTH);
localparam P_GEN_DW_CONV_D = (C_MODULE_ORDER[31:0] == P_INDX_DP_DW_CONV_D) && (C_S_AXIS_TDATA_WIDTH > C_M_AXIS_TDATA_WIDTH);
localparam P_GEN_CK_CONV   = (C_MODULE_ORDER[31:0] == P_INDX_DP_CK_CONV  ) 
                              && (!P_CK_CONV_IN_DATA_FIFO) 
                              && (C_IS_ACLK_ASYNC == 1 || C_S_AXIS_ACLK_RATIO != C_M_AXIS_ACLK_RATIO);
localparam P_GEN_DATA_FIFO = (C_MODULE_ORDER[31:0] == P_INDX_DP_DATA_FIFO) && (C_FIFO_DEPTH > 0) && (C_FIFO_MODE > 0);
localparam P_GEN_PACKER    = (C_MODULE_ORDER[31:0] == P_INDX_DP_PACKER   ) && 0; // TODO: implmement

localparam P_INT_TDATA_WIDTH   = (P_GEN_DW_CONV || P_GEN_DW_CONV_U || P_GEN_DW_CONV_D) ? C_S_AXIS_TDATA_WIDTH : C_M_AXIS_TDATA_WIDTH;
localparam P_INT_TUSER_WIDTH   = (P_GEN_DW_CONV || P_GEN_DW_CONV_U || P_GEN_DW_CONV_D) ? C_S_AXIS_TUSER_WIDTH : C_M_AXIS_TUSER_WIDTH;
localparam P_INT_TID_WIDTH     = (P_GEN_SS_CONV) ? C_S_AXIS_TID_WIDTH : C_M_AXIS_TID_WIDTH;
localparam P_INT_TDEST_WIDTH   = (P_GEN_SS_CONV) ? C_S_AXIS_TDEST_WIDTH : C_M_AXIS_TDEST_WIDTH;
localparam P_INT_SIGNAL_SET    = (P_GEN_SS_CONV) ? C_S_AXIS_SIGNAL_SET : C_M_AXIS_SIGNAL_SET;
localparam P_INT_IS_ACLK_ASYNC = (P_GEN_CK_CONV || (P_GEN_DATA_FIFO && P_CK_CONV_IN_DATA_FIFO)) ? 0 : C_IS_ACLK_ASYNC;
localparam P_DF_IS_ACLK_ASYNC  = (P_CK_CONV_IN_DATA_FIFO) ? 1 : 0;
localparam P_INT_ACLK_RATIO    = (P_GEN_CK_CONV || (P_GEN_DATA_FIFO && P_CK_CONV_IN_DATA_FIFO)) ? C_S_AXIS_ACLK_RATIO : C_M_AXIS_ACLK_RATIO;
localparam P_INT_FIFO_DEPTH    = (P_GEN_DATA_FIFO) ? 0 : C_FIFO_DEPTH;
localparam P_INT_FIFO_MODE     = (P_GEN_DATA_FIFO) ? 0 : C_FIFO_MODE ;



////////////////////////////////////////////////////////////////////////////////
// Wires/Reg declarations
////////////////////////////////////////////////////////////////////////////////
// Slave interface input  
wire                              int_aclk;
wire                              int_aclken;
wire                              int_aresetn;
wire                              int_tvalid;
wire                              int_tready;
wire [P_INT_TDATA_WIDTH-1:0]      int_tdata;
wire [P_INT_TDATA_WIDTH/8-1:0]    int_tstrb;
wire [P_INT_TDATA_WIDTH/8-1:0]    int_tkeep;
wire                              int_tlast;
wire [P_INT_TID_WIDTH-1:0]        int_tid;
wire [P_INT_TDEST_WIDTH-1:0]      int_tdest;
wire [P_INT_TUSER_WIDTH-1:0]      int_tuser;
wire                              int_sparse_tkeep_removed;
wire                              int_packer_err;
wire [31:0]                       int_s_fifo_data_count;
wire [31:0]                       int_m_fifo_data_count;
wire [31:0]                       int_fifo_data_count; // Unused, but provided for monitoring
wire                              nested_sparse_tkeep_removed;
wire                              nested_packer_err;
wire [31:0]                       nested_s_fifo_data_count;
wire [31:0]                       nested_m_fifo_data_count;

////////////////////////////////////////////////////////////////////////////////
// BEGIN RTL
////////////////////////////////////////////////////////////////////////////////

assign int_aclk    = (P_GEN_CK_CONV || (P_GEN_DATA_FIFO && P_CK_CONV_IN_DATA_FIFO)) ? S_AXIS_ACLK : M_AXIS_ACLK;
assign int_aclken  = (P_GEN_CK_CONV || (P_GEN_DATA_FIFO && P_CK_CONV_IN_DATA_FIFO)) ? S_AXIS_ACLKEN : M_AXIS_ACLKEN;
assign int_aresetn = (P_GEN_CK_CONV || (P_GEN_DATA_FIFO && P_CK_CONV_IN_DATA_FIFO)) ? S_AXIS_ARESETN : M_AXIS_ARESETN;

assign S_FIFO_DATA_COUNT    = (P_GEN_DATA_FIFO) ? int_s_fifo_data_count : nested_s_fifo_data_count;
assign M_FIFO_DATA_COUNT    = (P_GEN_DATA_FIFO || (P_GEN_CK_CONV && (C_FIFO_MODE > 0) && (C_FIFO_DEPTH > 0))) 
                              ? int_m_fifo_data_count : nested_m_fifo_data_count;
assign PACKER_ERR           = (P_GEN_PACKER   ) ? int_packer_err      : nested_packer_err     ;
assign SPARSE_TKEEP_REMOVED = (P_GEN_SS_CONV  ) ? int_sparse_tkeep_removed : nested_sparse_tkeep_removed;

generate 
  if (P_GEN_REG_SLICE) begin : gen_register_slice
    axis_interconnect_v1_1_axis_register_slice #(
      .C_FAMILY           ( C_FAMILY               ) ,
      .C_AXIS_TDATA_WIDTH ( C_M_AXIS_TDATA_WIDTH   ) ,
      .C_AXIS_TID_WIDTH   ( C_M_AXIS_TID_WIDTH     ) ,
      .C_AXIS_TDEST_WIDTH ( C_M_AXIS_TDEST_WIDTH   ) ,
      .C_AXIS_TUSER_WIDTH ( C_M_AXIS_TUSER_WIDTH   ) ,
      .C_AXIS_SIGNAL_SET  ( C_M_AXIS_SIGNAL_SET    ) ,
      .C_REG_CONFIG       ( C_REG_CONFIG           )
    )
    axis_register_slice_0
    (
      .ACLK          ( M_AXIS_ACLK    ) ,
      .ACLKEN        ( M_AXIS_ACLKEN  ) ,
      .ARESETN       ( M_AXIS_ARESETN ) ,
      .S_AXIS_TVALID ( int_tvalid     ) ,
      .S_AXIS_TREADY ( int_tready     ) ,
      .S_AXIS_TDATA  ( int_tdata      ) ,
      .S_AXIS_TSTRB  ( int_tstrb      ) ,
      .S_AXIS_TKEEP  ( int_tkeep      ) ,
      .S_AXIS_TLAST  ( int_tlast      ) ,
      .S_AXIS_TID    ( int_tid        ) ,
      .S_AXIS_TDEST  ( int_tdest      ) ,
      .S_AXIS_TUSER  ( int_tuser      ) ,
      .M_AXIS_TVALID ( M_AXIS_TVALID  ) ,
      .M_AXIS_TREADY ( M_AXIS_TREADY  ) ,
      .M_AXIS_TDATA  ( M_AXIS_TDATA   ) ,
      .M_AXIS_TSTRB  ( M_AXIS_TSTRB   ) ,
      .M_AXIS_TKEEP  ( M_AXIS_TKEEP   ) ,
      .M_AXIS_TLAST  ( M_AXIS_TLAST   ) ,
      .M_AXIS_TID    ( M_AXIS_TID     ) ,
      .M_AXIS_TDEST  ( M_AXIS_TDEST   ) ,
      .M_AXIS_TUSER  ( M_AXIS_TUSER   ) 
    );

  end
  else if (P_GEN_SS_CONV) begin : gen_subset_converter
    axis_interconnect_v1_1_axis_subset_converter #(
      .C_FAMILY             ( C_FAMILY               ) ,
      .C_AXIS_TDATA_WIDTH   ( C_M_AXIS_TDATA_WIDTH   ) ,
      .C_AXIS_TUSER_WIDTH   ( C_M_AXIS_TUSER_WIDTH   ) ,
      .C_M_AXIS_TID_WIDTH   ( C_M_AXIS_TID_WIDTH     ) ,
      .C_M_AXIS_TDEST_WIDTH ( C_M_AXIS_TDEST_WIDTH   ) ,
      .C_M_AXIS_SIGNAL_SET  ( C_M_AXIS_SIGNAL_SET    ) , 
      .C_S_AXIS_TID_WIDTH   ( C_S_AXIS_TID_WIDTH     ) ,
      .C_S_AXIS_TDEST_WIDTH ( C_S_AXIS_TDEST_WIDTH   ) ,
      .C_S_AXIS_SIGNAL_SET  ( C_S_AXIS_SIGNAL_SET    ) , 
      .C_DEFAULT_TLAST      ( P_DEFAULT_TLAST        )
    )
    axis_subset_converter_0
    (
      .ACLK              ( M_AXIS_ACLK       ) ,
      .ACLKEN            ( M_AXIS_ACLKEN     ) ,
      .ARESETN           ( M_AXIS_ARESETN    ) ,
      .S_AXIS_TVALID     ( int_tvalid        ) ,
      .S_AXIS_TREADY     ( int_tready        ) ,
      .S_AXIS_TDATA      ( int_tdata         ) ,
      .S_AXIS_TSTRB      ( int_tstrb         ) ,
      .S_AXIS_TKEEP      ( int_tkeep         ) ,
      .S_AXIS_TLAST      ( int_tlast         ) ,
      .S_AXIS_TID        ( int_tid           ) ,
      .S_AXIS_TDEST      ( int_tdest         ) ,
      .S_AXIS_TUSER      ( int_tuser         ) ,
      .M_AXIS_TVALID     ( M_AXIS_TVALID     ) ,
      .M_AXIS_TREADY     ( M_AXIS_TREADY     ) ,
      .M_AXIS_TDATA      ( M_AXIS_TDATA      ) ,
      .M_AXIS_TSTRB      ( M_AXIS_TSTRB      ) ,
      .M_AXIS_TKEEP      ( M_AXIS_TKEEP      ) ,
      .M_AXIS_TLAST      ( M_AXIS_TLAST      ) ,
      .M_AXIS_TID        ( M_AXIS_TID        ) ,
      .M_AXIS_TDEST      ( M_AXIS_TDEST      ) ,
      .M_AXIS_TUSER      ( M_AXIS_TUSER      ) ,
      .SPARSE_TKEEP_REMOVED ( int_sparse_tkeep_removed )
    );
  end
  else if (P_GEN_DW_CONV || P_GEN_DW_CONV_U || P_GEN_DW_CONV_D) begin : gen_dwidth_converter
    axis_interconnect_v1_1_axis_dwidth_converter #(
      .C_FAMILY             ( C_FAMILY               ) ,
      .C_S_AXIS_TDATA_WIDTH ( P_INT_TDATA_WIDTH      ) ,
      .C_S_AXIS_TUSER_WIDTH ( P_INT_TUSER_WIDTH      ) ,
      .C_M_AXIS_TDATA_WIDTH ( C_M_AXIS_TDATA_WIDTH   ) ,
      .C_M_AXIS_TUSER_WIDTH ( C_M_AXIS_TUSER_WIDTH   ) ,
      .C_AXIS_TID_WIDTH     ( C_M_AXIS_TID_WIDTH     ) ,
      .C_AXIS_TDEST_WIDTH   ( C_M_AXIS_TDEST_WIDTH   ) ,
      .C_AXIS_SIGNAL_SET    ( C_M_AXIS_SIGNAL_SET    )
    )
    axis_dwidth_converter_0
    (
      .ACLK          ( M_AXIS_ACLK    ) ,
      .ACLKEN        ( M_AXIS_ACLKEN  ) ,
      .ARESETN       ( M_AXIS_ARESETN ) ,
      .S_AXIS_TVALID ( int_tvalid     ) ,
      .S_AXIS_TREADY ( int_tready     ) ,
      .S_AXIS_TDATA  ( int_tdata      ) ,
      .S_AXIS_TSTRB  ( int_tstrb      ) ,
      .S_AXIS_TKEEP  ( int_tkeep      ) ,
      .S_AXIS_TLAST  ( int_tlast      ) ,
      .S_AXIS_TID    ( int_tid        ) ,
      .S_AXIS_TDEST  ( int_tdest      ) ,
      .S_AXIS_TUSER  ( int_tuser      ) ,
      .M_AXIS_TVALID ( M_AXIS_TVALID  ) ,
      .M_AXIS_TREADY ( M_AXIS_TREADY  ) ,
      .M_AXIS_TDATA  ( M_AXIS_TDATA   ) ,
      .M_AXIS_TSTRB  ( M_AXIS_TSTRB   ) ,
      .M_AXIS_TKEEP  ( M_AXIS_TKEEP   ) ,
      .M_AXIS_TLAST  ( M_AXIS_TLAST   ) ,
      .M_AXIS_TID    ( M_AXIS_TID     ) ,
      .M_AXIS_TDEST  ( M_AXIS_TDEST   ) ,
      .M_AXIS_TUSER  ( M_AXIS_TUSER   ) 
    );
  end
  else if (P_GEN_CK_CONV) begin : gen_clock_converter
    axis_interconnect_v1_1_axis_clock_converter #(
      .C_FAMILY            ( C_FAMILY             ) ,
      .C_AXIS_TDATA_WIDTH  ( C_M_AXIS_TDATA_WIDTH ) ,
      .C_AXIS_TID_WIDTH    ( C_M_AXIS_TID_WIDTH   ) ,
      .C_AXIS_TDEST_WIDTH  ( C_M_AXIS_TDEST_WIDTH ) ,
      .C_AXIS_TUSER_WIDTH  ( C_M_AXIS_TUSER_WIDTH ) ,
      .C_AXIS_SIGNAL_SET   ( C_M_AXIS_SIGNAL_SET  ) ,
      .C_IS_ACLK_ASYNC     ( C_IS_ACLK_ASYNC      ) ,
      .C_S_AXIS_ACLK_RATIO ( C_S_AXIS_ACLK_RATIO  ) ,
      .C_M_AXIS_ACLK_RATIO ( C_M_AXIS_ACLK_RATIO  ) ,
      .C_ACLKEN_CONV_MODE  ( C_ACLKEN_CONV_MODE   )
    )
    axis_clock_converter_0
    (
      .S_AXIS_ACLK    ( S_AXIS_ACLK    ) ,
      .S_AXIS_ACLKEN  ( S_AXIS_ACLKEN  ) ,
      .S_AXIS_ARESETN ( S_AXIS_ARESETN ) ,
      .S_AXIS_TVALID  ( int_tvalid     ) ,
      .S_AXIS_TREADY  ( int_tready     ) ,
      .S_AXIS_TDATA   ( int_tdata      ) ,
      .S_AXIS_TSTRB   ( int_tstrb      ) ,
      .S_AXIS_TKEEP   ( int_tkeep      ) ,
      .S_AXIS_TLAST   ( int_tlast      ) ,
      .S_AXIS_TID     ( int_tid        ) ,
      .S_AXIS_TDEST   ( int_tdest      ) ,
      .S_AXIS_TUSER   ( int_tuser      ) ,
      .M_AXIS_ACLK    ( M_AXIS_ACLK    ) ,
      .M_AXIS_ARESETN ( M_AXIS_ARESETN ) ,
      .M_AXIS_ACLKEN  ( M_AXIS_ACLKEN  ) ,
      .M_AXIS_TVALID  ( M_AXIS_TVALID  ) ,
      .M_AXIS_TREADY  ( M_AXIS_TREADY  ) ,
      .M_AXIS_TDATA   ( M_AXIS_TDATA   ) ,
      .M_AXIS_TSTRB   ( M_AXIS_TSTRB   ) ,
      .M_AXIS_TKEEP   ( M_AXIS_TKEEP   ) ,
      .M_AXIS_TLAST   ( M_AXIS_TLAST   ) ,
      .M_AXIS_TID     ( M_AXIS_TID     ) ,
      .M_AXIS_TDEST   ( M_AXIS_TDEST   ) ,
      .M_AXIS_TUSER   ( M_AXIS_TUSER   ) 
    );

    if (C_FIFO_MODE > 0 && C_FIFO_DEPTH > 0) begin : gen_rd_fifo_data_count_synchronizer
      reg [31:0] int_rd_fifo_data_count_d1;
      reg [31:0] int_rd_fifo_data_count_d2;

      always @(posedge M_AXIS_ACLK) begin
        if (M_AXIS_ACLKEN) begin 
          int_rd_fifo_data_count_d1 <= nested_m_fifo_data_count;
          int_rd_fifo_data_count_d2 <= int_rd_fifo_data_count_d1;
        end
      end
    
      assign int_m_fifo_data_count = int_rd_fifo_data_count_d2;
    end

  end
  else if (P_GEN_DATA_FIFO) begin : gen_data_fifo
    wire [31:0] int_wr_fifo_data_count;
    axis_interconnect_v1_1_axis_data_fifo #(
      .C_FAMILY            ( C_FAMILY             ) ,
      .C_AXIS_TDATA_WIDTH  ( C_M_AXIS_TDATA_WIDTH ) ,
      .C_AXIS_TID_WIDTH    ( C_M_AXIS_TID_WIDTH   ) ,
      .C_AXIS_TDEST_WIDTH  ( C_M_AXIS_TDEST_WIDTH ) ,
      .C_AXIS_TUSER_WIDTH  ( C_M_AXIS_TUSER_WIDTH ) ,
      .C_AXIS_SIGNAL_SET   ( C_M_AXIS_SIGNAL_SET  ) ,
      .C_FIFO_DEPTH        ( C_FIFO_DEPTH         ) ,
      .C_FIFO_MODE         ( C_FIFO_MODE          ) ,
      .C_IS_ACLK_ASYNC     ( P_DF_IS_ACLK_ASYNC   ) ,
      .C_ACLKEN_CONV_MODE  ( C_ACLKEN_CONV_MODE   )
    )
    axis_data_fifo_0
    (
      .S_AXIS_ARESETN ( int_aresetn    ) ,
      .S_AXIS_ACLK    ( int_aclk       ) ,
      .S_AXIS_ACLKEN  ( int_aclken     ) ,
      .S_AXIS_TVALID  ( int_tvalid     ) ,
      .S_AXIS_TREADY  ( int_tready     ) ,
      .S_AXIS_TDATA   ( int_tdata      ) ,
      .S_AXIS_TSTRB   ( int_tstrb      ) ,
      .S_AXIS_TKEEP   ( int_tkeep      ) ,
      .S_AXIS_TLAST   ( int_tlast      ) ,
      .S_AXIS_TID     ( int_tid        ) ,
      .S_AXIS_TDEST   ( int_tdest      ) ,
      .S_AXIS_TUSER   ( int_tuser      ) ,
      .M_AXIS_ACLK    ( M_AXIS_ACLK    ) ,
      .M_AXIS_ACLKEN  ( M_AXIS_ACLKEN  ) ,
      .M_AXIS_ARESETN ( M_AXIS_ARESETN ) ,
      .M_AXIS_TVALID  ( M_AXIS_TVALID  ) ,
      .M_AXIS_TREADY  ( M_AXIS_TREADY  ) ,
      .M_AXIS_TDATA   ( M_AXIS_TDATA   ) ,
      .M_AXIS_TSTRB   ( M_AXIS_TSTRB   ) ,
      .M_AXIS_TKEEP   ( M_AXIS_TKEEP   ) ,
      .M_AXIS_TLAST   ( M_AXIS_TLAST   ) ,
      .M_AXIS_TID     ( M_AXIS_TID     ) ,
      .M_AXIS_TDEST   ( M_AXIS_TDEST   ) ,
      .M_AXIS_TUSER   ( M_AXIS_TUSER   ) ,
      .AXIS_RD_DATA_COUNT ( int_m_fifo_data_count ) ,
      .AXIS_WR_DATA_COUNT ( int_wr_fifo_data_count ) ,
      .AXIS_DATA_COUNT ( int_fifo_data_count ) 
    );

    // If doing clock conversion in data fifo then axis_wr_data_count already 
    // clocked on S_AXIS_ACLK, otherwise we need to synchronize.
    if (!P_CK_CONV_IN_DATA_FIFO || (C_S_AXIS_ACLK_RATIO == C_M_AXIS_ACLK_RATIO) || C_IS_ACLK_ASYNC) begin : gen_wr_fifo_data_count_passthru
      assign int_s_fifo_data_count = int_wr_fifo_data_count;
    end
    else begin : gen_wr_fifo_data_count_synchronizer
      reg [31:0] int_wr_fifo_data_count_d1;
      reg [31:0] int_wr_fifo_data_count_d2;
      always @(posedge S_AXIS_ACLK) begin
        if (S_AXIS_ACLKEN) begin 
          int_wr_fifo_data_count_d1 <= int_wr_fifo_data_count;
          int_wr_fifo_data_count_d2 <= int_wr_fifo_data_count_d1;
        end
      end

      assign int_s_fifo_data_count = int_wr_fifo_data_count_d2;
    end
  end
  else begin : gen_passthru //  if (C_MODULE_ORDER[31:0] == G_DP_PASS_THRU) begin : gen_passthru
    assign int_tready      = M_AXIS_TREADY;
    assign M_AXIS_TVALID   = int_tvalid;
    assign M_AXIS_TDATA    = int_tdata;
    assign M_AXIS_TSTRB    = int_tstrb;
    assign M_AXIS_TKEEP    = int_tkeep;
    assign M_AXIS_TLAST    = int_tlast;
    assign M_AXIS_TID      = int_tid;
    assign M_AXIS_TDEST    = int_tdest;
    assign M_AXIS_TUSER    = int_tuser;
  end

  // Gens the nesting loop if modulesd still exist
  if ((C_MODULE_ORDER >> 32)) begin : gen_nested
    axis_interconnect_v1_1_dynamic_datapath #(
      .C_FAMILY             ( C_FAMILY             ) ,
      .C_S_AXIS_TDATA_WIDTH ( C_S_AXIS_TDATA_WIDTH ) ,
      .C_S_AXIS_TID_WIDTH   ( C_S_AXIS_TID_WIDTH   ) ,
      .C_S_AXIS_TDEST_WIDTH ( C_S_AXIS_TDEST_WIDTH ) ,
      .C_S_AXIS_TUSER_WIDTH ( C_S_AXIS_TUSER_WIDTH ) ,
      .C_S_AXIS_SIGNAL_SET  ( C_S_AXIS_SIGNAL_SET  ) ,
      .C_S_AXIS_ACLK_RATIO  ( C_S_AXIS_ACLK_RATIO  ) ,
      .C_M_AXIS_TDATA_WIDTH ( P_INT_TDATA_WIDTH    ) ,
      .C_M_AXIS_TID_WIDTH   ( P_INT_TID_WIDTH      ) ,
      .C_M_AXIS_TDEST_WIDTH ( P_INT_TDEST_WIDTH    ) ,
      .C_M_AXIS_TUSER_WIDTH ( P_INT_TUSER_WIDTH    ) ,
      .C_M_AXIS_SIGNAL_SET  ( P_INT_SIGNAL_SET     ) ,
      .C_M_AXIS_ACLK_RATIO  ( P_INT_ACLK_RATIO     ) ,
      .C_REG_CONFIG         ( C_REG_CONFIG         ) ,
      .C_IS_ACLK_ASYNC      ( P_INT_IS_ACLK_ASYNC  ) ,
      .C_ACLKEN_CONV_MODE   ( C_ACLKEN_CONV_MODE   ) ,
      .C_FIFO_DEPTH         ( P_INT_FIFO_DEPTH     ) ,
      .C_FIFO_MODE          ( P_INT_FIFO_MODE      ) ,
      .C_MODULE_ORDER       ( C_MODULE_ORDER >> 32 ) 
    )
    dynamic_datapath_0
    (
      .S_AXIS_ACLK        ( S_AXIS_ACLK           ) ,
      .S_AXIS_ACLKEN      ( S_AXIS_ACLKEN         ) ,
      .S_AXIS_ARESETN     ( S_AXIS_ARESETN        ) ,
      .S_AXIS_TVALID      ( S_AXIS_TVALID         ) ,
      .S_AXIS_TREADY      ( S_AXIS_TREADY         ) ,
      .S_AXIS_TDATA       ( S_AXIS_TDATA          ) ,
      .S_AXIS_TSTRB       ( S_AXIS_TSTRB          ) ,
      .S_AXIS_TKEEP       ( S_AXIS_TKEEP          ) ,
      .S_AXIS_TLAST       ( S_AXIS_TLAST          ) ,
      .S_AXIS_TID         ( S_AXIS_TID            ) ,
      .S_AXIS_TDEST       ( S_AXIS_TDEST          ) ,
      .S_AXIS_TUSER       ( S_AXIS_TUSER          ) ,
      .M_AXIS_ACLK        ( int_aclk              ) ,
      .M_AXIS_ACLKEN      ( int_aclken            ) ,
      .M_AXIS_ARESETN     ( int_aresetn           ) ,
      .M_AXIS_TVALID      ( int_tvalid            ) ,
      .M_AXIS_TREADY      ( int_tready            ) ,
      .M_AXIS_TDATA       ( int_tdata             ) ,
      .M_AXIS_TSTRB       ( int_tstrb             ) ,
      .M_AXIS_TKEEP       ( int_tkeep             ) ,
      .M_AXIS_TLAST       ( int_tlast             ) ,
      .M_AXIS_TID         ( int_tid               ) ,
      .M_AXIS_TDEST       ( int_tdest             ) ,
      .M_AXIS_TUSER       ( int_tuser             ) ,
      .SPARSE_TKEEP_REMOVED ( nested_sparse_tkeep_removed   ) ,
      .PACKER_ERR         ( nested_packer_err        ) ,
      .S_FIFO_DATA_COUNT    ( nested_s_fifo_data_count   ),
      .M_FIFO_DATA_COUNT    ( nested_m_fifo_data_count   ) 

    );
  end else begin : no_next
    assign S_AXIS_TREADY = int_tready;
    assign int_tvalid = S_AXIS_TVALID;
    assign int_tdata  = S_AXIS_TDATA;
    assign int_tstrb  = S_AXIS_TSTRB;
    assign int_tkeep  = S_AXIS_TKEEP;
    assign int_tlast  = S_AXIS_TLAST;
    assign int_tid    = S_AXIS_TID;
    assign int_tdest  = S_AXIS_TDEST;
    assign int_tuser  = S_AXIS_TUSER;
    assign nested_sparse_tkeep_removed = 1'b0;
    assign nested_packer_err = 1'b0;
    assign nested_s_fifo_data_count = 32'h0;
    assign nested_m_fifo_data_count = 32'h0;
  end
endgenerate

endmodule // dynamic_datapath

`default_nettype wire
