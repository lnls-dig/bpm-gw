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
// This is a computer generated file.
//-----------------------------------------------------------------------------

`timescale 1ps/1ps
`default_nettype none

module axis_interconnect_v1_1_axis_interconnect_16x16_top #(

///////////////////////////////////////////////////////////////////////////////
// Parameter Declarations
///////////////////////////////////////////////////////////////////////////////
  parameter  C_FAMILY = "virtex7",
  parameter integer C_NUM_MI_SLOTS = 1,
  parameter integer C_NUM_SI_SLOTS = 1,
  parameter integer C_SWITCH_MI_REG_CONFIG = 0,
  parameter integer C_SWITCH_SI_REG_CONFIG = 1,
  parameter integer C_SWITCH_MODE = 33,
  parameter integer C_SWITCH_MAX_XFERS_PER_ARB = 0,
  parameter integer C_SWITCH_NUM_CYCLES_TIMEOUT = 0,
  parameter integer C_SWITCH_TDATA_WIDTH = 32,
  parameter integer C_SWITCH_TID_WIDTH = 1,
  parameter integer C_SWITCH_TDEST_WIDTH = 1,
  parameter integer C_SWITCH_TUSER_WIDTH = 1,
  parameter [31:0] C_SWITCH_SIGNAL_SET = 32'h7F,
  parameter integer C_SWITCH_ACLK_RATIO = 1,
  parameter integer C_SWITCH_USE_ACLKEN = 0,
  parameter [16-1:0] C_M00_AXIS_CONNECTIVITY = 16'b0,
  parameter [16-1:0] C_M01_AXIS_CONNECTIVITY = 16'b0,
  parameter [16-1:0] C_M02_AXIS_CONNECTIVITY = 16'b0,
  parameter [16-1:0] C_M03_AXIS_CONNECTIVITY = 16'b0,
  parameter [16-1:0] C_M04_AXIS_CONNECTIVITY = 16'b0,
  parameter [16-1:0] C_M05_AXIS_CONNECTIVITY = 16'b0,
  parameter [16-1:0] C_M06_AXIS_CONNECTIVITY = 16'b0,
  parameter [16-1:0] C_M07_AXIS_CONNECTIVITY = 16'b0,
  parameter [16-1:0] C_M08_AXIS_CONNECTIVITY = 16'b0,
  parameter [16-1:0] C_M09_AXIS_CONNECTIVITY = 16'b0,
  parameter [16-1:0] C_M10_AXIS_CONNECTIVITY = 16'b0,
  parameter [16-1:0] C_M11_AXIS_CONNECTIVITY = 16'b0,
  parameter [16-1:0] C_M12_AXIS_CONNECTIVITY = 16'b0,
  parameter [16-1:0] C_M13_AXIS_CONNECTIVITY = 16'b0,
  parameter [16-1:0] C_M14_AXIS_CONNECTIVITY = 16'b0,
  parameter [16-1:0] C_M15_AXIS_CONNECTIVITY = 16'b0,
  parameter integer C_M00_AXIS_BASETDEST = 32'b0,
  parameter integer C_M01_AXIS_BASETDEST = 32'b0,
  parameter integer C_M02_AXIS_BASETDEST = 32'b0,
  parameter integer C_M03_AXIS_BASETDEST = 32'b0,
  parameter integer C_M04_AXIS_BASETDEST = 32'b0,
  parameter integer C_M05_AXIS_BASETDEST = 32'b0,
  parameter integer C_M06_AXIS_BASETDEST = 32'b0,
  parameter integer C_M07_AXIS_BASETDEST = 32'b0,
  parameter integer C_M08_AXIS_BASETDEST = 32'b0,
  parameter integer C_M09_AXIS_BASETDEST = 32'b0,
  parameter integer C_M10_AXIS_BASETDEST = 32'b0,
  parameter integer C_M11_AXIS_BASETDEST = 32'b0,
  parameter integer C_M12_AXIS_BASETDEST = 32'b0,
  parameter integer C_M13_AXIS_BASETDEST = 32'b0,
  parameter integer C_M14_AXIS_BASETDEST = 32'b0,
  parameter integer C_M15_AXIS_BASETDEST = 32'b0,
  parameter integer C_M00_AXIS_HIGHTDEST = 32'b0,
  parameter integer C_M01_AXIS_HIGHTDEST = 32'b0,
  parameter integer C_M02_AXIS_HIGHTDEST = 32'b0,
  parameter integer C_M03_AXIS_HIGHTDEST = 32'b0,
  parameter integer C_M04_AXIS_HIGHTDEST = 32'b0,
  parameter integer C_M05_AXIS_HIGHTDEST = 32'b0,
  parameter integer C_M06_AXIS_HIGHTDEST = 32'b0,
  parameter integer C_M07_AXIS_HIGHTDEST = 32'b0,
  parameter integer C_M08_AXIS_HIGHTDEST = 32'b0,
  parameter integer C_M09_AXIS_HIGHTDEST = 32'b0,
  parameter integer C_M10_AXIS_HIGHTDEST = 32'b0,
  parameter integer C_M11_AXIS_HIGHTDEST = 32'b0,
  parameter integer C_M12_AXIS_HIGHTDEST = 32'b0,
  parameter integer C_M13_AXIS_HIGHTDEST = 32'b0,
  parameter integer C_M14_AXIS_HIGHTDEST = 32'b0,
  parameter integer C_M15_AXIS_HIGHTDEST = 32'b0,
  parameter integer C_S00_AXIS_TDATA_WIDTH = 8,
  parameter integer C_S01_AXIS_TDATA_WIDTH = 8,
  parameter integer C_S02_AXIS_TDATA_WIDTH = 8,
  parameter integer C_S03_AXIS_TDATA_WIDTH = 8,
  parameter integer C_S04_AXIS_TDATA_WIDTH = 8,
  parameter integer C_S05_AXIS_TDATA_WIDTH = 8,
  parameter integer C_S06_AXIS_TDATA_WIDTH = 8,
  parameter integer C_S07_AXIS_TDATA_WIDTH = 8,
  parameter integer C_S08_AXIS_TDATA_WIDTH = 8,
  parameter integer C_S09_AXIS_TDATA_WIDTH = 8,
  parameter integer C_S10_AXIS_TDATA_WIDTH = 8,
  parameter integer C_S11_AXIS_TDATA_WIDTH = 8,
  parameter integer C_S12_AXIS_TDATA_WIDTH = 8,
  parameter integer C_S13_AXIS_TDATA_WIDTH = 8,
  parameter integer C_S14_AXIS_TDATA_WIDTH = 8,
  parameter integer C_S15_AXIS_TDATA_WIDTH = 8,
  parameter integer C_S00_AXIS_TUSER_WIDTH = 1,
  parameter integer C_S01_AXIS_TUSER_WIDTH = 1,
  parameter integer C_S02_AXIS_TUSER_WIDTH = 1,
  parameter integer C_S03_AXIS_TUSER_WIDTH = 1,
  parameter integer C_S04_AXIS_TUSER_WIDTH = 1,
  parameter integer C_S05_AXIS_TUSER_WIDTH = 1,
  parameter integer C_S06_AXIS_TUSER_WIDTH = 1,
  parameter integer C_S07_AXIS_TUSER_WIDTH = 1,
  parameter integer C_S08_AXIS_TUSER_WIDTH = 1,
  parameter integer C_S09_AXIS_TUSER_WIDTH = 1,
  parameter integer C_S10_AXIS_TUSER_WIDTH = 1,
  parameter integer C_S11_AXIS_TUSER_WIDTH = 1,
  parameter integer C_S12_AXIS_TUSER_WIDTH = 1,
  parameter integer C_S13_AXIS_TUSER_WIDTH = 1,
  parameter integer C_S14_AXIS_TUSER_WIDTH = 1,
  parameter integer C_S15_AXIS_TUSER_WIDTH = 1,
  parameter integer C_S00_AXIS_IS_ACLK_ASYNC = 0,
  parameter integer C_S01_AXIS_IS_ACLK_ASYNC = 0,
  parameter integer C_S02_AXIS_IS_ACLK_ASYNC = 0,
  parameter integer C_S03_AXIS_IS_ACLK_ASYNC = 0,
  parameter integer C_S04_AXIS_IS_ACLK_ASYNC = 0,
  parameter integer C_S05_AXIS_IS_ACLK_ASYNC = 0,
  parameter integer C_S06_AXIS_IS_ACLK_ASYNC = 0,
  parameter integer C_S07_AXIS_IS_ACLK_ASYNC = 0,
  parameter integer C_S08_AXIS_IS_ACLK_ASYNC = 0,
  parameter integer C_S09_AXIS_IS_ACLK_ASYNC = 0,
  parameter integer C_S10_AXIS_IS_ACLK_ASYNC = 0,
  parameter integer C_S11_AXIS_IS_ACLK_ASYNC = 0,
  parameter integer C_S12_AXIS_IS_ACLK_ASYNC = 0,
  parameter integer C_S13_AXIS_IS_ACLK_ASYNC = 0,
  parameter integer C_S14_AXIS_IS_ACLK_ASYNC = 0,
  parameter integer C_S15_AXIS_IS_ACLK_ASYNC = 0,
  parameter integer C_S00_AXIS_ACLK_RATIO = 1,
  parameter integer C_S01_AXIS_ACLK_RATIO = 1,
  parameter integer C_S02_AXIS_ACLK_RATIO = 1,
  parameter integer C_S03_AXIS_ACLK_RATIO = 1,
  parameter integer C_S04_AXIS_ACLK_RATIO = 1,
  parameter integer C_S05_AXIS_ACLK_RATIO = 1,
  parameter integer C_S06_AXIS_ACLK_RATIO = 1,
  parameter integer C_S07_AXIS_ACLK_RATIO = 1,
  parameter integer C_S08_AXIS_ACLK_RATIO = 1,
  parameter integer C_S09_AXIS_ACLK_RATIO = 1,
  parameter integer C_S10_AXIS_ACLK_RATIO = 1,
  parameter integer C_S11_AXIS_ACLK_RATIO = 1,
  parameter integer C_S12_AXIS_ACLK_RATIO = 1,
  parameter integer C_S13_AXIS_ACLK_RATIO = 1,
  parameter integer C_S14_AXIS_ACLK_RATIO = 1,
  parameter integer C_S15_AXIS_ACLK_RATIO = 1,
  parameter integer C_S00_AXIS_REG_CONFIG = 1,
  parameter integer C_S01_AXIS_REG_CONFIG = 1,
  parameter integer C_S02_AXIS_REG_CONFIG = 1,
  parameter integer C_S03_AXIS_REG_CONFIG = 1,
  parameter integer C_S04_AXIS_REG_CONFIG = 1,
  parameter integer C_S05_AXIS_REG_CONFIG = 1,
  parameter integer C_S06_AXIS_REG_CONFIG = 1,
  parameter integer C_S07_AXIS_REG_CONFIG = 1,
  parameter integer C_S08_AXIS_REG_CONFIG = 1,
  parameter integer C_S09_AXIS_REG_CONFIG = 1,
  parameter integer C_S10_AXIS_REG_CONFIG = 1,
  parameter integer C_S11_AXIS_REG_CONFIG = 1,
  parameter integer C_S12_AXIS_REG_CONFIG = 1,
  parameter integer C_S13_AXIS_REG_CONFIG = 1,
  parameter integer C_S14_AXIS_REG_CONFIG = 1,
  parameter integer C_S15_AXIS_REG_CONFIG = 1,
  parameter integer C_S00_AXIS_FIFO_DEPTH = 32,
  parameter integer C_S01_AXIS_FIFO_DEPTH = 32,
  parameter integer C_S02_AXIS_FIFO_DEPTH = 32,
  parameter integer C_S03_AXIS_FIFO_DEPTH = 32,
  parameter integer C_S04_AXIS_FIFO_DEPTH = 32,
  parameter integer C_S05_AXIS_FIFO_DEPTH = 32,
  parameter integer C_S06_AXIS_FIFO_DEPTH = 32,
  parameter integer C_S07_AXIS_FIFO_DEPTH = 32,
  parameter integer C_S08_AXIS_FIFO_DEPTH = 32,
  parameter integer C_S09_AXIS_FIFO_DEPTH = 32,
  parameter integer C_S10_AXIS_FIFO_DEPTH = 32,
  parameter integer C_S11_AXIS_FIFO_DEPTH = 32,
  parameter integer C_S12_AXIS_FIFO_DEPTH = 32,
  parameter integer C_S13_AXIS_FIFO_DEPTH = 32,
  parameter integer C_S14_AXIS_FIFO_DEPTH = 32,
  parameter integer C_S15_AXIS_FIFO_DEPTH = 32,
  parameter integer C_S00_AXIS_FIFO_MODE = 0,
  parameter integer C_S01_AXIS_FIFO_MODE = 0,
  parameter integer C_S02_AXIS_FIFO_MODE = 0,
  parameter integer C_S03_AXIS_FIFO_MODE = 0,
  parameter integer C_S04_AXIS_FIFO_MODE = 0,
  parameter integer C_S05_AXIS_FIFO_MODE = 0,
  parameter integer C_S06_AXIS_FIFO_MODE = 0,
  parameter integer C_S07_AXIS_FIFO_MODE = 0,
  parameter integer C_S08_AXIS_FIFO_MODE = 0,
  parameter integer C_S09_AXIS_FIFO_MODE = 0,
  parameter integer C_S10_AXIS_FIFO_MODE = 0,
  parameter integer C_S11_AXIS_FIFO_MODE = 0,
  parameter integer C_S12_AXIS_FIFO_MODE = 0,
  parameter integer C_S13_AXIS_FIFO_MODE = 0,
  parameter integer C_S14_AXIS_FIFO_MODE = 0,
  parameter integer C_S15_AXIS_FIFO_MODE = 0,
  parameter integer C_M00_AXIS_TDATA_WIDTH = 8,
  parameter integer C_M01_AXIS_TDATA_WIDTH = 8,
  parameter integer C_M02_AXIS_TDATA_WIDTH = 8,
  parameter integer C_M03_AXIS_TDATA_WIDTH = 8,
  parameter integer C_M04_AXIS_TDATA_WIDTH = 8,
  parameter integer C_M05_AXIS_TDATA_WIDTH = 8,
  parameter integer C_M06_AXIS_TDATA_WIDTH = 8,
  parameter integer C_M07_AXIS_TDATA_WIDTH = 8,
  parameter integer C_M08_AXIS_TDATA_WIDTH = 8,
  parameter integer C_M09_AXIS_TDATA_WIDTH = 8,
  parameter integer C_M10_AXIS_TDATA_WIDTH = 8,
  parameter integer C_M11_AXIS_TDATA_WIDTH = 8,
  parameter integer C_M12_AXIS_TDATA_WIDTH = 8,
  parameter integer C_M13_AXIS_TDATA_WIDTH = 8,
  parameter integer C_M14_AXIS_TDATA_WIDTH = 8,
  parameter integer C_M15_AXIS_TDATA_WIDTH = 8,
  parameter integer C_M00_AXIS_TUSER_WIDTH = 1,
  parameter integer C_M01_AXIS_TUSER_WIDTH = 1,
  parameter integer C_M02_AXIS_TUSER_WIDTH = 1,
  parameter integer C_M03_AXIS_TUSER_WIDTH = 1,
  parameter integer C_M04_AXIS_TUSER_WIDTH = 1,
  parameter integer C_M05_AXIS_TUSER_WIDTH = 1,
  parameter integer C_M06_AXIS_TUSER_WIDTH = 1,
  parameter integer C_M07_AXIS_TUSER_WIDTH = 1,
  parameter integer C_M08_AXIS_TUSER_WIDTH = 1,
  parameter integer C_M09_AXIS_TUSER_WIDTH = 1,
  parameter integer C_M10_AXIS_TUSER_WIDTH = 1,
  parameter integer C_M11_AXIS_TUSER_WIDTH = 1,
  parameter integer C_M12_AXIS_TUSER_WIDTH = 1,
  parameter integer C_M13_AXIS_TUSER_WIDTH = 1,
  parameter integer C_M14_AXIS_TUSER_WIDTH = 1,
  parameter integer C_M15_AXIS_TUSER_WIDTH = 1,
  parameter integer C_M00_AXIS_ACLK_RATIO = 1,
  parameter integer C_M01_AXIS_ACLK_RATIO = 1,
  parameter integer C_M02_AXIS_ACLK_RATIO = 1,
  parameter integer C_M03_AXIS_ACLK_RATIO = 1,
  parameter integer C_M04_AXIS_ACLK_RATIO = 1,
  parameter integer C_M05_AXIS_ACLK_RATIO = 1,
  parameter integer C_M06_AXIS_ACLK_RATIO = 1,
  parameter integer C_M07_AXIS_ACLK_RATIO = 1,
  parameter integer C_M08_AXIS_ACLK_RATIO = 1,
  parameter integer C_M09_AXIS_ACLK_RATIO = 1,
  parameter integer C_M10_AXIS_ACLK_RATIO = 1,
  parameter integer C_M11_AXIS_ACLK_RATIO = 1,
  parameter integer C_M12_AXIS_ACLK_RATIO = 1,
  parameter integer C_M13_AXIS_ACLK_RATIO = 1,
  parameter integer C_M14_AXIS_ACLK_RATIO = 1,
  parameter integer C_M15_AXIS_ACLK_RATIO = 1,
  parameter integer C_M00_AXIS_REG_CONFIG = 1,
  parameter integer C_M01_AXIS_REG_CONFIG = 1,
  parameter integer C_M02_AXIS_REG_CONFIG = 1,
  parameter integer C_M03_AXIS_REG_CONFIG = 1,
  parameter integer C_M04_AXIS_REG_CONFIG = 1,
  parameter integer C_M05_AXIS_REG_CONFIG = 1,
  parameter integer C_M06_AXIS_REG_CONFIG = 1,
  parameter integer C_M07_AXIS_REG_CONFIG = 1,
  parameter integer C_M08_AXIS_REG_CONFIG = 1,
  parameter integer C_M09_AXIS_REG_CONFIG = 1,
  parameter integer C_M10_AXIS_REG_CONFIG = 1,
  parameter integer C_M11_AXIS_REG_CONFIG = 1,
  parameter integer C_M12_AXIS_REG_CONFIG = 1,
  parameter integer C_M13_AXIS_REG_CONFIG = 1,
  parameter integer C_M14_AXIS_REG_CONFIG = 1,
  parameter integer C_M15_AXIS_REG_CONFIG = 1,
  parameter integer C_M00_AXIS_IS_ACLK_ASYNC = 0,
  parameter integer C_M01_AXIS_IS_ACLK_ASYNC = 0,
  parameter integer C_M02_AXIS_IS_ACLK_ASYNC = 0,
  parameter integer C_M03_AXIS_IS_ACLK_ASYNC = 0,
  parameter integer C_M04_AXIS_IS_ACLK_ASYNC = 0,
  parameter integer C_M05_AXIS_IS_ACLK_ASYNC = 0,
  parameter integer C_M06_AXIS_IS_ACLK_ASYNC = 0,
  parameter integer C_M07_AXIS_IS_ACLK_ASYNC = 0,
  parameter integer C_M08_AXIS_IS_ACLK_ASYNC = 0,
  parameter integer C_M09_AXIS_IS_ACLK_ASYNC = 0,
  parameter integer C_M10_AXIS_IS_ACLK_ASYNC = 0,
  parameter integer C_M11_AXIS_IS_ACLK_ASYNC = 0,
  parameter integer C_M12_AXIS_IS_ACLK_ASYNC = 0,
  parameter integer C_M13_AXIS_IS_ACLK_ASYNC = 0,
  parameter integer C_M14_AXIS_IS_ACLK_ASYNC = 0,
  parameter integer C_M15_AXIS_IS_ACLK_ASYNC = 0,
  parameter integer C_M00_AXIS_FIFO_DEPTH = 32,
  parameter integer C_M01_AXIS_FIFO_DEPTH = 32,
  parameter integer C_M02_AXIS_FIFO_DEPTH = 32,
  parameter integer C_M03_AXIS_FIFO_DEPTH = 32,
  parameter integer C_M04_AXIS_FIFO_DEPTH = 32,
  parameter integer C_M05_AXIS_FIFO_DEPTH = 32,
  parameter integer C_M06_AXIS_FIFO_DEPTH = 32,
  parameter integer C_M07_AXIS_FIFO_DEPTH = 32,
  parameter integer C_M08_AXIS_FIFO_DEPTH = 32,
  parameter integer C_M09_AXIS_FIFO_DEPTH = 32,
  parameter integer C_M10_AXIS_FIFO_DEPTH = 32,
  parameter integer C_M11_AXIS_FIFO_DEPTH = 32,
  parameter integer C_M12_AXIS_FIFO_DEPTH = 32,
  parameter integer C_M13_AXIS_FIFO_DEPTH = 32,
  parameter integer C_M14_AXIS_FIFO_DEPTH = 32,
  parameter integer C_M15_AXIS_FIFO_DEPTH = 32,
  parameter integer C_M00_AXIS_FIFO_MODE = 0,
  parameter integer C_M01_AXIS_FIFO_MODE = 0,
  parameter integer C_M02_AXIS_FIFO_MODE = 0,
  parameter integer C_M03_AXIS_FIFO_MODE = 0,
  parameter integer C_M04_AXIS_FIFO_MODE = 0,
  parameter integer C_M05_AXIS_FIFO_MODE = 0,
  parameter integer C_M06_AXIS_FIFO_MODE = 0,
  parameter integer C_M07_AXIS_FIFO_MODE = 0,
  parameter integer C_M08_AXIS_FIFO_MODE = 0,
  parameter integer C_M09_AXIS_FIFO_MODE = 0,
  parameter integer C_M10_AXIS_FIFO_MODE = 0,
  parameter integer C_M11_AXIS_FIFO_MODE = 0,
  parameter integer C_M12_AXIS_FIFO_MODE = 0,
  parameter integer C_M13_AXIS_FIFO_MODE = 0,
  parameter integer C_M14_AXIS_FIFO_MODE = 0,
  parameter integer C_M15_AXIS_FIFO_MODE = 0
)
(

///////////////////////////////////////////////////////////////////////////////
// Port Declarations
///////////////////////////////////////////////////////////////////////////////
  input wire  ACLK,
  input wire  ARESETN,
  input wire  ACLKEN,
  input wire  S00_AXIS_ACLK,
  input wire  S01_AXIS_ACLK,
  input wire  S02_AXIS_ACLK,
  input wire  S03_AXIS_ACLK,
  input wire  S04_AXIS_ACLK,
  input wire  S05_AXIS_ACLK,
  input wire  S06_AXIS_ACLK,
  input wire  S07_AXIS_ACLK,
  input wire  S08_AXIS_ACLK,
  input wire  S09_AXIS_ACLK,
  input wire  S10_AXIS_ACLK,
  input wire  S11_AXIS_ACLK,
  input wire  S12_AXIS_ACLK,
  input wire  S13_AXIS_ACLK,
  input wire  S14_AXIS_ACLK,
  input wire  S15_AXIS_ACLK,
  input wire  S00_AXIS_ARESETN,
  input wire  S01_AXIS_ARESETN,
  input wire  S02_AXIS_ARESETN,
  input wire  S03_AXIS_ARESETN,
  input wire  S04_AXIS_ARESETN,
  input wire  S05_AXIS_ARESETN,
  input wire  S06_AXIS_ARESETN,
  input wire  S07_AXIS_ARESETN,
  input wire  S08_AXIS_ARESETN,
  input wire  S09_AXIS_ARESETN,
  input wire  S10_AXIS_ARESETN,
  input wire  S11_AXIS_ARESETN,
  input wire  S12_AXIS_ARESETN,
  input wire  S13_AXIS_ARESETN,
  input wire  S14_AXIS_ARESETN,
  input wire  S15_AXIS_ARESETN,
  input wire  S00_AXIS_ACLKEN,
  input wire  S01_AXIS_ACLKEN,
  input wire  S02_AXIS_ACLKEN,
  input wire  S03_AXIS_ACLKEN,
  input wire  S04_AXIS_ACLKEN,
  input wire  S05_AXIS_ACLKEN,
  input wire  S06_AXIS_ACLKEN,
  input wire  S07_AXIS_ACLKEN,
  input wire  S08_AXIS_ACLKEN,
  input wire  S09_AXIS_ACLKEN,
  input wire  S10_AXIS_ACLKEN,
  input wire  S11_AXIS_ACLKEN,
  input wire  S12_AXIS_ACLKEN,
  input wire  S13_AXIS_ACLKEN,
  input wire  S14_AXIS_ACLKEN,
  input wire  S15_AXIS_ACLKEN,
  input wire  S00_AXIS_TVALID,
  input wire  S01_AXIS_TVALID,
  input wire  S02_AXIS_TVALID,
  input wire  S03_AXIS_TVALID,
  input wire  S04_AXIS_TVALID,
  input wire  S05_AXIS_TVALID,
  input wire  S06_AXIS_TVALID,
  input wire  S07_AXIS_TVALID,
  input wire  S08_AXIS_TVALID,
  input wire  S09_AXIS_TVALID,
  input wire  S10_AXIS_TVALID,
  input wire  S11_AXIS_TVALID,
  input wire  S12_AXIS_TVALID,
  input wire  S13_AXIS_TVALID,
  input wire  S14_AXIS_TVALID,
  input wire  S15_AXIS_TVALID,
  output wire  S00_AXIS_TREADY,
  output wire  S01_AXIS_TREADY,
  output wire  S02_AXIS_TREADY,
  output wire  S03_AXIS_TREADY,
  output wire  S04_AXIS_TREADY,
  output wire  S05_AXIS_TREADY,
  output wire  S06_AXIS_TREADY,
  output wire  S07_AXIS_TREADY,
  output wire  S08_AXIS_TREADY,
  output wire  S09_AXIS_TREADY,
  output wire  S10_AXIS_TREADY,
  output wire  S11_AXIS_TREADY,
  output wire  S12_AXIS_TREADY,
  output wire  S13_AXIS_TREADY,
  output wire  S14_AXIS_TREADY,
  output wire  S15_AXIS_TREADY,
  input wire [C_S00_AXIS_TDATA_WIDTH-1:0] S00_AXIS_TDATA,
  input wire [C_S01_AXIS_TDATA_WIDTH-1:0] S01_AXIS_TDATA,
  input wire [C_S02_AXIS_TDATA_WIDTH-1:0] S02_AXIS_TDATA,
  input wire [C_S03_AXIS_TDATA_WIDTH-1:0] S03_AXIS_TDATA,
  input wire [C_S04_AXIS_TDATA_WIDTH-1:0] S04_AXIS_TDATA,
  input wire [C_S05_AXIS_TDATA_WIDTH-1:0] S05_AXIS_TDATA,
  input wire [C_S06_AXIS_TDATA_WIDTH-1:0] S06_AXIS_TDATA,
  input wire [C_S07_AXIS_TDATA_WIDTH-1:0] S07_AXIS_TDATA,
  input wire [C_S08_AXIS_TDATA_WIDTH-1:0] S08_AXIS_TDATA,
  input wire [C_S09_AXIS_TDATA_WIDTH-1:0] S09_AXIS_TDATA,
  input wire [C_S10_AXIS_TDATA_WIDTH-1:0] S10_AXIS_TDATA,
  input wire [C_S11_AXIS_TDATA_WIDTH-1:0] S11_AXIS_TDATA,
  input wire [C_S12_AXIS_TDATA_WIDTH-1:0] S12_AXIS_TDATA,
  input wire [C_S13_AXIS_TDATA_WIDTH-1:0] S13_AXIS_TDATA,
  input wire [C_S14_AXIS_TDATA_WIDTH-1:0] S14_AXIS_TDATA,
  input wire [C_S15_AXIS_TDATA_WIDTH-1:0] S15_AXIS_TDATA,
  input wire [C_S00_AXIS_TDATA_WIDTH/8-1:0] S00_AXIS_TSTRB,
  input wire [C_S01_AXIS_TDATA_WIDTH/8-1:0] S01_AXIS_TSTRB,
  input wire [C_S02_AXIS_TDATA_WIDTH/8-1:0] S02_AXIS_TSTRB,
  input wire [C_S03_AXIS_TDATA_WIDTH/8-1:0] S03_AXIS_TSTRB,
  input wire [C_S04_AXIS_TDATA_WIDTH/8-1:0] S04_AXIS_TSTRB,
  input wire [C_S05_AXIS_TDATA_WIDTH/8-1:0] S05_AXIS_TSTRB,
  input wire [C_S06_AXIS_TDATA_WIDTH/8-1:0] S06_AXIS_TSTRB,
  input wire [C_S07_AXIS_TDATA_WIDTH/8-1:0] S07_AXIS_TSTRB,
  input wire [C_S08_AXIS_TDATA_WIDTH/8-1:0] S08_AXIS_TSTRB,
  input wire [C_S09_AXIS_TDATA_WIDTH/8-1:0] S09_AXIS_TSTRB,
  input wire [C_S10_AXIS_TDATA_WIDTH/8-1:0] S10_AXIS_TSTRB,
  input wire [C_S11_AXIS_TDATA_WIDTH/8-1:0] S11_AXIS_TSTRB,
  input wire [C_S12_AXIS_TDATA_WIDTH/8-1:0] S12_AXIS_TSTRB,
  input wire [C_S13_AXIS_TDATA_WIDTH/8-1:0] S13_AXIS_TSTRB,
  input wire [C_S14_AXIS_TDATA_WIDTH/8-1:0] S14_AXIS_TSTRB,
  input wire [C_S15_AXIS_TDATA_WIDTH/8-1:0] S15_AXIS_TSTRB,
  input wire [C_S00_AXIS_TDATA_WIDTH/8-1:0] S00_AXIS_TKEEP,
  input wire [C_S01_AXIS_TDATA_WIDTH/8-1:0] S01_AXIS_TKEEP,
  input wire [C_S02_AXIS_TDATA_WIDTH/8-1:0] S02_AXIS_TKEEP,
  input wire [C_S03_AXIS_TDATA_WIDTH/8-1:0] S03_AXIS_TKEEP,
  input wire [C_S04_AXIS_TDATA_WIDTH/8-1:0] S04_AXIS_TKEEP,
  input wire [C_S05_AXIS_TDATA_WIDTH/8-1:0] S05_AXIS_TKEEP,
  input wire [C_S06_AXIS_TDATA_WIDTH/8-1:0] S06_AXIS_TKEEP,
  input wire [C_S07_AXIS_TDATA_WIDTH/8-1:0] S07_AXIS_TKEEP,
  input wire [C_S08_AXIS_TDATA_WIDTH/8-1:0] S08_AXIS_TKEEP,
  input wire [C_S09_AXIS_TDATA_WIDTH/8-1:0] S09_AXIS_TKEEP,
  input wire [C_S10_AXIS_TDATA_WIDTH/8-1:0] S10_AXIS_TKEEP,
  input wire [C_S11_AXIS_TDATA_WIDTH/8-1:0] S11_AXIS_TKEEP,
  input wire [C_S12_AXIS_TDATA_WIDTH/8-1:0] S12_AXIS_TKEEP,
  input wire [C_S13_AXIS_TDATA_WIDTH/8-1:0] S13_AXIS_TKEEP,
  input wire [C_S14_AXIS_TDATA_WIDTH/8-1:0] S14_AXIS_TKEEP,
  input wire [C_S15_AXIS_TDATA_WIDTH/8-1:0] S15_AXIS_TKEEP,
  input wire  S00_AXIS_TLAST,
  input wire  S01_AXIS_TLAST,
  input wire  S02_AXIS_TLAST,
  input wire  S03_AXIS_TLAST,
  input wire  S04_AXIS_TLAST,
  input wire  S05_AXIS_TLAST,
  input wire  S06_AXIS_TLAST,
  input wire  S07_AXIS_TLAST,
  input wire  S08_AXIS_TLAST,
  input wire  S09_AXIS_TLAST,
  input wire  S10_AXIS_TLAST,
  input wire  S11_AXIS_TLAST,
  input wire  S12_AXIS_TLAST,
  input wire  S13_AXIS_TLAST,
  input wire  S14_AXIS_TLAST,
  input wire  S15_AXIS_TLAST,
  input wire [C_SWITCH_TID_WIDTH-1:0] S00_AXIS_TID,
  input wire [C_SWITCH_TID_WIDTH-1:0] S01_AXIS_TID,
  input wire [C_SWITCH_TID_WIDTH-1:0] S02_AXIS_TID,
  input wire [C_SWITCH_TID_WIDTH-1:0] S03_AXIS_TID,
  input wire [C_SWITCH_TID_WIDTH-1:0] S04_AXIS_TID,
  input wire [C_SWITCH_TID_WIDTH-1:0] S05_AXIS_TID,
  input wire [C_SWITCH_TID_WIDTH-1:0] S06_AXIS_TID,
  input wire [C_SWITCH_TID_WIDTH-1:0] S07_AXIS_TID,
  input wire [C_SWITCH_TID_WIDTH-1:0] S08_AXIS_TID,
  input wire [C_SWITCH_TID_WIDTH-1:0] S09_AXIS_TID,
  input wire [C_SWITCH_TID_WIDTH-1:0] S10_AXIS_TID,
  input wire [C_SWITCH_TID_WIDTH-1:0] S11_AXIS_TID,
  input wire [C_SWITCH_TID_WIDTH-1:0] S12_AXIS_TID,
  input wire [C_SWITCH_TID_WIDTH-1:0] S13_AXIS_TID,
  input wire [C_SWITCH_TID_WIDTH-1:0] S14_AXIS_TID,
  input wire [C_SWITCH_TID_WIDTH-1:0] S15_AXIS_TID,
  input wire [C_SWITCH_TDEST_WIDTH-1:0] S00_AXIS_TDEST,
  input wire [C_SWITCH_TDEST_WIDTH-1:0] S01_AXIS_TDEST,
  input wire [C_SWITCH_TDEST_WIDTH-1:0] S02_AXIS_TDEST,
  input wire [C_SWITCH_TDEST_WIDTH-1:0] S03_AXIS_TDEST,
  input wire [C_SWITCH_TDEST_WIDTH-1:0] S04_AXIS_TDEST,
  input wire [C_SWITCH_TDEST_WIDTH-1:0] S05_AXIS_TDEST,
  input wire [C_SWITCH_TDEST_WIDTH-1:0] S06_AXIS_TDEST,
  input wire [C_SWITCH_TDEST_WIDTH-1:0] S07_AXIS_TDEST,
  input wire [C_SWITCH_TDEST_WIDTH-1:0] S08_AXIS_TDEST,
  input wire [C_SWITCH_TDEST_WIDTH-1:0] S09_AXIS_TDEST,
  input wire [C_SWITCH_TDEST_WIDTH-1:0] S10_AXIS_TDEST,
  input wire [C_SWITCH_TDEST_WIDTH-1:0] S11_AXIS_TDEST,
  input wire [C_SWITCH_TDEST_WIDTH-1:0] S12_AXIS_TDEST,
  input wire [C_SWITCH_TDEST_WIDTH-1:0] S13_AXIS_TDEST,
  input wire [C_SWITCH_TDEST_WIDTH-1:0] S14_AXIS_TDEST,
  input wire [C_SWITCH_TDEST_WIDTH-1:0] S15_AXIS_TDEST,
  input wire [C_S00_AXIS_TUSER_WIDTH-1:0] S00_AXIS_TUSER,
  input wire [C_S01_AXIS_TUSER_WIDTH-1:0] S01_AXIS_TUSER,
  input wire [C_S02_AXIS_TUSER_WIDTH-1:0] S02_AXIS_TUSER,
  input wire [C_S03_AXIS_TUSER_WIDTH-1:0] S03_AXIS_TUSER,
  input wire [C_S04_AXIS_TUSER_WIDTH-1:0] S04_AXIS_TUSER,
  input wire [C_S05_AXIS_TUSER_WIDTH-1:0] S05_AXIS_TUSER,
  input wire [C_S06_AXIS_TUSER_WIDTH-1:0] S06_AXIS_TUSER,
  input wire [C_S07_AXIS_TUSER_WIDTH-1:0] S07_AXIS_TUSER,
  input wire [C_S08_AXIS_TUSER_WIDTH-1:0] S08_AXIS_TUSER,
  input wire [C_S09_AXIS_TUSER_WIDTH-1:0] S09_AXIS_TUSER,
  input wire [C_S10_AXIS_TUSER_WIDTH-1:0] S10_AXIS_TUSER,
  input wire [C_S11_AXIS_TUSER_WIDTH-1:0] S11_AXIS_TUSER,
  input wire [C_S12_AXIS_TUSER_WIDTH-1:0] S12_AXIS_TUSER,
  input wire [C_S13_AXIS_TUSER_WIDTH-1:0] S13_AXIS_TUSER,
  input wire [C_S14_AXIS_TUSER_WIDTH-1:0] S14_AXIS_TUSER,
  input wire [C_S15_AXIS_TUSER_WIDTH-1:0] S15_AXIS_TUSER,
  input wire  M00_AXIS_ACLK,
  input wire  M01_AXIS_ACLK,
  input wire  M02_AXIS_ACLK,
  input wire  M03_AXIS_ACLK,
  input wire  M04_AXIS_ACLK,
  input wire  M05_AXIS_ACLK,
  input wire  M06_AXIS_ACLK,
  input wire  M07_AXIS_ACLK,
  input wire  M08_AXIS_ACLK,
  input wire  M09_AXIS_ACLK,
  input wire  M10_AXIS_ACLK,
  input wire  M11_AXIS_ACLK,
  input wire  M12_AXIS_ACLK,
  input wire  M13_AXIS_ACLK,
  input wire  M14_AXIS_ACLK,
  input wire  M15_AXIS_ACLK,
  input wire  M00_AXIS_ARESETN,
  input wire  M01_AXIS_ARESETN,
  input wire  M02_AXIS_ARESETN,
  input wire  M03_AXIS_ARESETN,
  input wire  M04_AXIS_ARESETN,
  input wire  M05_AXIS_ARESETN,
  input wire  M06_AXIS_ARESETN,
  input wire  M07_AXIS_ARESETN,
  input wire  M08_AXIS_ARESETN,
  input wire  M09_AXIS_ARESETN,
  input wire  M10_AXIS_ARESETN,
  input wire  M11_AXIS_ARESETN,
  input wire  M12_AXIS_ARESETN,
  input wire  M13_AXIS_ARESETN,
  input wire  M14_AXIS_ARESETN,
  input wire  M15_AXIS_ARESETN,
  input wire  M00_AXIS_ACLKEN,
  input wire  M01_AXIS_ACLKEN,
  input wire  M02_AXIS_ACLKEN,
  input wire  M03_AXIS_ACLKEN,
  input wire  M04_AXIS_ACLKEN,
  input wire  M05_AXIS_ACLKEN,
  input wire  M06_AXIS_ACLKEN,
  input wire  M07_AXIS_ACLKEN,
  input wire  M08_AXIS_ACLKEN,
  input wire  M09_AXIS_ACLKEN,
  input wire  M10_AXIS_ACLKEN,
  input wire  M11_AXIS_ACLKEN,
  input wire  M12_AXIS_ACLKEN,
  input wire  M13_AXIS_ACLKEN,
  input wire  M14_AXIS_ACLKEN,
  input wire  M15_AXIS_ACLKEN,
  output wire  M00_AXIS_TVALID,
  output wire  M01_AXIS_TVALID,
  output wire  M02_AXIS_TVALID,
  output wire  M03_AXIS_TVALID,
  output wire  M04_AXIS_TVALID,
  output wire  M05_AXIS_TVALID,
  output wire  M06_AXIS_TVALID,
  output wire  M07_AXIS_TVALID,
  output wire  M08_AXIS_TVALID,
  output wire  M09_AXIS_TVALID,
  output wire  M10_AXIS_TVALID,
  output wire  M11_AXIS_TVALID,
  output wire  M12_AXIS_TVALID,
  output wire  M13_AXIS_TVALID,
  output wire  M14_AXIS_TVALID,
  output wire  M15_AXIS_TVALID,
  input wire  M00_AXIS_TREADY,
  input wire  M01_AXIS_TREADY,
  input wire  M02_AXIS_TREADY,
  input wire  M03_AXIS_TREADY,
  input wire  M04_AXIS_TREADY,
  input wire  M05_AXIS_TREADY,
  input wire  M06_AXIS_TREADY,
  input wire  M07_AXIS_TREADY,
  input wire  M08_AXIS_TREADY,
  input wire  M09_AXIS_TREADY,
  input wire  M10_AXIS_TREADY,
  input wire  M11_AXIS_TREADY,
  input wire  M12_AXIS_TREADY,
  input wire  M13_AXIS_TREADY,
  input wire  M14_AXIS_TREADY,
  input wire  M15_AXIS_TREADY,
  output wire [C_M00_AXIS_TDATA_WIDTH-1:0] M00_AXIS_TDATA,
  output wire [C_M01_AXIS_TDATA_WIDTH-1:0] M01_AXIS_TDATA,
  output wire [C_M02_AXIS_TDATA_WIDTH-1:0] M02_AXIS_TDATA,
  output wire [C_M03_AXIS_TDATA_WIDTH-1:0] M03_AXIS_TDATA,
  output wire [C_M04_AXIS_TDATA_WIDTH-1:0] M04_AXIS_TDATA,
  output wire [C_M05_AXIS_TDATA_WIDTH-1:0] M05_AXIS_TDATA,
  output wire [C_M06_AXIS_TDATA_WIDTH-1:0] M06_AXIS_TDATA,
  output wire [C_M07_AXIS_TDATA_WIDTH-1:0] M07_AXIS_TDATA,
  output wire [C_M08_AXIS_TDATA_WIDTH-1:0] M08_AXIS_TDATA,
  output wire [C_M09_AXIS_TDATA_WIDTH-1:0] M09_AXIS_TDATA,
  output wire [C_M10_AXIS_TDATA_WIDTH-1:0] M10_AXIS_TDATA,
  output wire [C_M11_AXIS_TDATA_WIDTH-1:0] M11_AXIS_TDATA,
  output wire [C_M12_AXIS_TDATA_WIDTH-1:0] M12_AXIS_TDATA,
  output wire [C_M13_AXIS_TDATA_WIDTH-1:0] M13_AXIS_TDATA,
  output wire [C_M14_AXIS_TDATA_WIDTH-1:0] M14_AXIS_TDATA,
  output wire [C_M15_AXIS_TDATA_WIDTH-1:0] M15_AXIS_TDATA,
  output wire [C_M00_AXIS_TDATA_WIDTH/8-1:0] M00_AXIS_TSTRB,
  output wire [C_M01_AXIS_TDATA_WIDTH/8-1:0] M01_AXIS_TSTRB,
  output wire [C_M02_AXIS_TDATA_WIDTH/8-1:0] M02_AXIS_TSTRB,
  output wire [C_M03_AXIS_TDATA_WIDTH/8-1:0] M03_AXIS_TSTRB,
  output wire [C_M04_AXIS_TDATA_WIDTH/8-1:0] M04_AXIS_TSTRB,
  output wire [C_M05_AXIS_TDATA_WIDTH/8-1:0] M05_AXIS_TSTRB,
  output wire [C_M06_AXIS_TDATA_WIDTH/8-1:0] M06_AXIS_TSTRB,
  output wire [C_M07_AXIS_TDATA_WIDTH/8-1:0] M07_AXIS_TSTRB,
  output wire [C_M08_AXIS_TDATA_WIDTH/8-1:0] M08_AXIS_TSTRB,
  output wire [C_M09_AXIS_TDATA_WIDTH/8-1:0] M09_AXIS_TSTRB,
  output wire [C_M10_AXIS_TDATA_WIDTH/8-1:0] M10_AXIS_TSTRB,
  output wire [C_M11_AXIS_TDATA_WIDTH/8-1:0] M11_AXIS_TSTRB,
  output wire [C_M12_AXIS_TDATA_WIDTH/8-1:0] M12_AXIS_TSTRB,
  output wire [C_M13_AXIS_TDATA_WIDTH/8-1:0] M13_AXIS_TSTRB,
  output wire [C_M14_AXIS_TDATA_WIDTH/8-1:0] M14_AXIS_TSTRB,
  output wire [C_M15_AXIS_TDATA_WIDTH/8-1:0] M15_AXIS_TSTRB,
  output wire [C_M00_AXIS_TDATA_WIDTH/8-1:0] M00_AXIS_TKEEP,
  output wire [C_M01_AXIS_TDATA_WIDTH/8-1:0] M01_AXIS_TKEEP,
  output wire [C_M02_AXIS_TDATA_WIDTH/8-1:0] M02_AXIS_TKEEP,
  output wire [C_M03_AXIS_TDATA_WIDTH/8-1:0] M03_AXIS_TKEEP,
  output wire [C_M04_AXIS_TDATA_WIDTH/8-1:0] M04_AXIS_TKEEP,
  output wire [C_M05_AXIS_TDATA_WIDTH/8-1:0] M05_AXIS_TKEEP,
  output wire [C_M06_AXIS_TDATA_WIDTH/8-1:0] M06_AXIS_TKEEP,
  output wire [C_M07_AXIS_TDATA_WIDTH/8-1:0] M07_AXIS_TKEEP,
  output wire [C_M08_AXIS_TDATA_WIDTH/8-1:0] M08_AXIS_TKEEP,
  output wire [C_M09_AXIS_TDATA_WIDTH/8-1:0] M09_AXIS_TKEEP,
  output wire [C_M10_AXIS_TDATA_WIDTH/8-1:0] M10_AXIS_TKEEP,
  output wire [C_M11_AXIS_TDATA_WIDTH/8-1:0] M11_AXIS_TKEEP,
  output wire [C_M12_AXIS_TDATA_WIDTH/8-1:0] M12_AXIS_TKEEP,
  output wire [C_M13_AXIS_TDATA_WIDTH/8-1:0] M13_AXIS_TKEEP,
  output wire [C_M14_AXIS_TDATA_WIDTH/8-1:0] M14_AXIS_TKEEP,
  output wire [C_M15_AXIS_TDATA_WIDTH/8-1:0] M15_AXIS_TKEEP,
  output wire  M00_AXIS_TLAST,
  output wire  M01_AXIS_TLAST,
  output wire  M02_AXIS_TLAST,
  output wire  M03_AXIS_TLAST,
  output wire  M04_AXIS_TLAST,
  output wire  M05_AXIS_TLAST,
  output wire  M06_AXIS_TLAST,
  output wire  M07_AXIS_TLAST,
  output wire  M08_AXIS_TLAST,
  output wire  M09_AXIS_TLAST,
  output wire  M10_AXIS_TLAST,
  output wire  M11_AXIS_TLAST,
  output wire  M12_AXIS_TLAST,
  output wire  M13_AXIS_TLAST,
  output wire  M14_AXIS_TLAST,
  output wire  M15_AXIS_TLAST,
  output wire [C_SWITCH_TID_WIDTH-1:0] M00_AXIS_TID,
  output wire [C_SWITCH_TID_WIDTH-1:0] M01_AXIS_TID,
  output wire [C_SWITCH_TID_WIDTH-1:0] M02_AXIS_TID,
  output wire [C_SWITCH_TID_WIDTH-1:0] M03_AXIS_TID,
  output wire [C_SWITCH_TID_WIDTH-1:0] M04_AXIS_TID,
  output wire [C_SWITCH_TID_WIDTH-1:0] M05_AXIS_TID,
  output wire [C_SWITCH_TID_WIDTH-1:0] M06_AXIS_TID,
  output wire [C_SWITCH_TID_WIDTH-1:0] M07_AXIS_TID,
  output wire [C_SWITCH_TID_WIDTH-1:0] M08_AXIS_TID,
  output wire [C_SWITCH_TID_WIDTH-1:0] M09_AXIS_TID,
  output wire [C_SWITCH_TID_WIDTH-1:0] M10_AXIS_TID,
  output wire [C_SWITCH_TID_WIDTH-1:0] M11_AXIS_TID,
  output wire [C_SWITCH_TID_WIDTH-1:0] M12_AXIS_TID,
  output wire [C_SWITCH_TID_WIDTH-1:0] M13_AXIS_TID,
  output wire [C_SWITCH_TID_WIDTH-1:0] M14_AXIS_TID,
  output wire [C_SWITCH_TID_WIDTH-1:0] M15_AXIS_TID,
  output wire [C_SWITCH_TDEST_WIDTH-1:0] M00_AXIS_TDEST,
  output wire [C_SWITCH_TDEST_WIDTH-1:0] M01_AXIS_TDEST,
  output wire [C_SWITCH_TDEST_WIDTH-1:0] M02_AXIS_TDEST,
  output wire [C_SWITCH_TDEST_WIDTH-1:0] M03_AXIS_TDEST,
  output wire [C_SWITCH_TDEST_WIDTH-1:0] M04_AXIS_TDEST,
  output wire [C_SWITCH_TDEST_WIDTH-1:0] M05_AXIS_TDEST,
  output wire [C_SWITCH_TDEST_WIDTH-1:0] M06_AXIS_TDEST,
  output wire [C_SWITCH_TDEST_WIDTH-1:0] M07_AXIS_TDEST,
  output wire [C_SWITCH_TDEST_WIDTH-1:0] M08_AXIS_TDEST,
  output wire [C_SWITCH_TDEST_WIDTH-1:0] M09_AXIS_TDEST,
  output wire [C_SWITCH_TDEST_WIDTH-1:0] M10_AXIS_TDEST,
  output wire [C_SWITCH_TDEST_WIDTH-1:0] M11_AXIS_TDEST,
  output wire [C_SWITCH_TDEST_WIDTH-1:0] M12_AXIS_TDEST,
  output wire [C_SWITCH_TDEST_WIDTH-1:0] M13_AXIS_TDEST,
  output wire [C_SWITCH_TDEST_WIDTH-1:0] M14_AXIS_TDEST,
  output wire [C_SWITCH_TDEST_WIDTH-1:0] M15_AXIS_TDEST,
  output wire [C_M00_AXIS_TUSER_WIDTH-1:0] M00_AXIS_TUSER,
  output wire [C_M01_AXIS_TUSER_WIDTH-1:0] M01_AXIS_TUSER,
  output wire [C_M02_AXIS_TUSER_WIDTH-1:0] M02_AXIS_TUSER,
  output wire [C_M03_AXIS_TUSER_WIDTH-1:0] M03_AXIS_TUSER,
  output wire [C_M04_AXIS_TUSER_WIDTH-1:0] M04_AXIS_TUSER,
  output wire [C_M05_AXIS_TUSER_WIDTH-1:0] M05_AXIS_TUSER,
  output wire [C_M06_AXIS_TUSER_WIDTH-1:0] M06_AXIS_TUSER,
  output wire [C_M07_AXIS_TUSER_WIDTH-1:0] M07_AXIS_TUSER,
  output wire [C_M08_AXIS_TUSER_WIDTH-1:0] M08_AXIS_TUSER,
  output wire [C_M09_AXIS_TUSER_WIDTH-1:0] M09_AXIS_TUSER,
  output wire [C_M10_AXIS_TUSER_WIDTH-1:0] M10_AXIS_TUSER,
  output wire [C_M11_AXIS_TUSER_WIDTH-1:0] M11_AXIS_TUSER,
  output wire [C_M12_AXIS_TUSER_WIDTH-1:0] M12_AXIS_TUSER,
  output wire [C_M13_AXIS_TUSER_WIDTH-1:0] M13_AXIS_TUSER,
  output wire [C_M14_AXIS_TUSER_WIDTH-1:0] M14_AXIS_TUSER,
  output wire [C_M15_AXIS_TUSER_WIDTH-1:0] M15_AXIS_TUSER,
  input wire  S00_ARB_REQ_SUPPRESS,
  input wire  S01_ARB_REQ_SUPPRESS,
  input wire  S02_ARB_REQ_SUPPRESS,
  input wire  S03_ARB_REQ_SUPPRESS,
  input wire  S04_ARB_REQ_SUPPRESS,
  input wire  S05_ARB_REQ_SUPPRESS,
  input wire  S06_ARB_REQ_SUPPRESS,
  input wire  S07_ARB_REQ_SUPPRESS,
  input wire  S08_ARB_REQ_SUPPRESS,
  input wire  S09_ARB_REQ_SUPPRESS,
  input wire  S10_ARB_REQ_SUPPRESS,
  input wire  S11_ARB_REQ_SUPPRESS,
  input wire  S12_ARB_REQ_SUPPRESS,
  input wire  S13_ARB_REQ_SUPPRESS,
  input wire  S14_ARB_REQ_SUPPRESS,
  input wire  S15_ARB_REQ_SUPPRESS,
  output wire  S00_DECODE_ERR,
  output wire  S01_DECODE_ERR,
  output wire  S02_DECODE_ERR,
  output wire  S03_DECODE_ERR,
  output wire  S04_DECODE_ERR,
  output wire  S05_DECODE_ERR,
  output wire  S06_DECODE_ERR,
  output wire  S07_DECODE_ERR,
  output wire  S08_DECODE_ERR,
  output wire  S09_DECODE_ERR,
  output wire  S10_DECODE_ERR,
  output wire  S11_DECODE_ERR,
  output wire  S12_DECODE_ERR,
  output wire  S13_DECODE_ERR,
  output wire  S14_DECODE_ERR,
  output wire  S15_DECODE_ERR,
  output wire  S00_SPARSE_TKEEP_REMOVED,
  output wire  S01_SPARSE_TKEEP_REMOVED,
  output wire  S02_SPARSE_TKEEP_REMOVED,
  output wire  S03_SPARSE_TKEEP_REMOVED,
  output wire  S04_SPARSE_TKEEP_REMOVED,
  output wire  S05_SPARSE_TKEEP_REMOVED,
  output wire  S06_SPARSE_TKEEP_REMOVED,
  output wire  S07_SPARSE_TKEEP_REMOVED,
  output wire  S08_SPARSE_TKEEP_REMOVED,
  output wire  S09_SPARSE_TKEEP_REMOVED,
  output wire  S10_SPARSE_TKEEP_REMOVED,
  output wire  S11_SPARSE_TKEEP_REMOVED,
  output wire  S12_SPARSE_TKEEP_REMOVED,
  output wire  S13_SPARSE_TKEEP_REMOVED,
  output wire  S14_SPARSE_TKEEP_REMOVED,
  output wire  S15_SPARSE_TKEEP_REMOVED,
  output wire  S00_PACKER_ERR,
  output wire  S01_PACKER_ERR,
  output wire  S02_PACKER_ERR,
  output wire  S03_PACKER_ERR,
  output wire  S04_PACKER_ERR,
  output wire  S05_PACKER_ERR,
  output wire  S06_PACKER_ERR,
  output wire  S07_PACKER_ERR,
  output wire  S08_PACKER_ERR,
  output wire  S09_PACKER_ERR,
  output wire  S10_PACKER_ERR,
  output wire  S11_PACKER_ERR,
  output wire  S12_PACKER_ERR,
  output wire  S13_PACKER_ERR,
  output wire  S14_PACKER_ERR,
  output wire  S15_PACKER_ERR,
  output wire [32-1:0] S00_FIFO_DATA_COUNT,
  output wire [32-1:0] S01_FIFO_DATA_COUNT,
  output wire [32-1:0] S02_FIFO_DATA_COUNT,
  output wire [32-1:0] S03_FIFO_DATA_COUNT,
  output wire [32-1:0] S04_FIFO_DATA_COUNT,
  output wire [32-1:0] S05_FIFO_DATA_COUNT,
  output wire [32-1:0] S06_FIFO_DATA_COUNT,
  output wire [32-1:0] S07_FIFO_DATA_COUNT,
  output wire [32-1:0] S08_FIFO_DATA_COUNT,
  output wire [32-1:0] S09_FIFO_DATA_COUNT,
  output wire [32-1:0] S10_FIFO_DATA_COUNT,
  output wire [32-1:0] S11_FIFO_DATA_COUNT,
  output wire [32-1:0] S12_FIFO_DATA_COUNT,
  output wire [32-1:0] S13_FIFO_DATA_COUNT,
  output wire [32-1:0] S14_FIFO_DATA_COUNT,
  output wire [32-1:0] S15_FIFO_DATA_COUNT,
  output wire  M00_SPARSE_TKEEP_REMOVED,
  output wire  M01_SPARSE_TKEEP_REMOVED,
  output wire  M02_SPARSE_TKEEP_REMOVED,
  output wire  M03_SPARSE_TKEEP_REMOVED,
  output wire  M04_SPARSE_TKEEP_REMOVED,
  output wire  M05_SPARSE_TKEEP_REMOVED,
  output wire  M06_SPARSE_TKEEP_REMOVED,
  output wire  M07_SPARSE_TKEEP_REMOVED,
  output wire  M08_SPARSE_TKEEP_REMOVED,
  output wire  M09_SPARSE_TKEEP_REMOVED,
  output wire  M10_SPARSE_TKEEP_REMOVED,
  output wire  M11_SPARSE_TKEEP_REMOVED,
  output wire  M12_SPARSE_TKEEP_REMOVED,
  output wire  M13_SPARSE_TKEEP_REMOVED,
  output wire  M14_SPARSE_TKEEP_REMOVED,
  output wire  M15_SPARSE_TKEEP_REMOVED,
  output wire  M00_PACKER_ERR,
  output wire  M01_PACKER_ERR,
  output wire  M02_PACKER_ERR,
  output wire  M03_PACKER_ERR,
  output wire  M04_PACKER_ERR,
  output wire  M05_PACKER_ERR,
  output wire  M06_PACKER_ERR,
  output wire  M07_PACKER_ERR,
  output wire  M08_PACKER_ERR,
  output wire  M09_PACKER_ERR,
  output wire  M10_PACKER_ERR,
  output wire  M11_PACKER_ERR,
  output wire  M12_PACKER_ERR,
  output wire  M13_PACKER_ERR,
  output wire  M14_PACKER_ERR,
  output wire  M15_PACKER_ERR,
  output wire [32-1:0] M00_FIFO_DATA_COUNT,
  output wire [32-1:0] M01_FIFO_DATA_COUNT,
  output wire [32-1:0] M02_FIFO_DATA_COUNT,
  output wire [32-1:0] M03_FIFO_DATA_COUNT,
  output wire [32-1:0] M04_FIFO_DATA_COUNT,
  output wire [32-1:0] M05_FIFO_DATA_COUNT,
  output wire [32-1:0] M06_FIFO_DATA_COUNT,
  output wire [32-1:0] M07_FIFO_DATA_COUNT,
  output wire [32-1:0] M08_FIFO_DATA_COUNT,
  output wire [32-1:0] M09_FIFO_DATA_COUNT,
  output wire [32-1:0] M10_FIFO_DATA_COUNT,
  output wire [32-1:0] M11_FIFO_DATA_COUNT,
  output wire [32-1:0] M12_FIFO_DATA_COUNT,
  output wire [32-1:0] M13_FIFO_DATA_COUNT,
  output wire [32-1:0] M14_FIFO_DATA_COUNT,
  output wire [32-1:0] M15_FIFO_DATA_COUNT
);

///////////////////////////////////////////////////////////////////////////////
// Function Declarations
///////////////////////////////////////////////////////////////////////////////

// Function to calculate max widths
function integer f_calc_max_width (
  input integer switch_width,
  input [(16)*32-1:0] mi_width_array,
  input [(16)*32-1:0] si_width_array,
  input integer num_mi,
  input integer num_si
  );
  begin : main
    integer si;
    integer mi;
    f_calc_max_width = switch_width;

    for (mi = 0; mi < num_mi; mi = mi + 1) begin 
      if (mi_width_array[mi*32+:32] > f_calc_max_width) begin
        f_calc_max_width = mi_width_array[mi*32+:32];
      end
    end
    for (si = 0; si < num_si; si = si + 1) begin 
      if (si_width_array[si*32+:32] > f_calc_max_width) begin
        f_calc_max_width = si_width_array[si*32+:32];
      end
    end
  end
endfunction

///////////////////////////////////////////////////////////////////////////////
// Local Parameter Declarations
///////////////////////////////////////////////////////////////////////////////
  localparam integer C_AXIS_TDATA_MAX_WIDTH = f_calc_max_width(C_SWITCH_TDATA_WIDTH[0+:32],{C_M15_AXIS_TDATA_WIDTH[0+:32],C_M14_AXIS_TDATA_WIDTH[0+:32],C_M13_AXIS_TDATA_WIDTH[0+:32],C_M12_AXIS_TDATA_WIDTH[0+:32],C_M11_AXIS_TDATA_WIDTH[0+:32],C_M10_AXIS_TDATA_WIDTH[0+:32],C_M09_AXIS_TDATA_WIDTH[0+:32],C_M08_AXIS_TDATA_WIDTH[0+:32],C_M07_AXIS_TDATA_WIDTH[0+:32],C_M06_AXIS_TDATA_WIDTH[0+:32],C_M05_AXIS_TDATA_WIDTH[0+:32],C_M04_AXIS_TDATA_WIDTH[0+:32],C_M03_AXIS_TDATA_WIDTH[0+:32],C_M02_AXIS_TDATA_WIDTH[0+:32],C_M01_AXIS_TDATA_WIDTH[0+:32],C_M00_AXIS_TDATA_WIDTH[0+:32]},{C_S15_AXIS_TDATA_WIDTH[0+:32],C_S14_AXIS_TDATA_WIDTH[0+:32],C_S13_AXIS_TDATA_WIDTH[0+:32],C_S12_AXIS_TDATA_WIDTH[0+:32],C_S11_AXIS_TDATA_WIDTH[0+:32],C_S10_AXIS_TDATA_WIDTH[0+:32],C_S09_AXIS_TDATA_WIDTH[0+:32],C_S08_AXIS_TDATA_WIDTH[0+:32],C_S07_AXIS_TDATA_WIDTH[0+:32],C_S06_AXIS_TDATA_WIDTH[0+:32],C_S05_AXIS_TDATA_WIDTH[0+:32],C_S04_AXIS_TDATA_WIDTH[0+:32],C_S03_AXIS_TDATA_WIDTH[0+:32],C_S02_AXIS_TDATA_WIDTH[0+:32],C_S01_AXIS_TDATA_WIDTH[0+:32],C_S00_AXIS_TDATA_WIDTH[0+:32]},C_NUM_MI_SLOTS,C_NUM_SI_SLOTS);
  localparam integer C_AXIS_TUSER_MAX_WIDTH = f_calc_max_width(C_SWITCH_TUSER_WIDTH[0+:32],{C_M15_AXIS_TUSER_WIDTH[0+:32],C_M14_AXIS_TUSER_WIDTH[0+:32],C_M13_AXIS_TUSER_WIDTH[0+:32],C_M12_AXIS_TUSER_WIDTH[0+:32],C_M11_AXIS_TUSER_WIDTH[0+:32],C_M10_AXIS_TUSER_WIDTH[0+:32],C_M09_AXIS_TUSER_WIDTH[0+:32],C_M08_AXIS_TUSER_WIDTH[0+:32],C_M07_AXIS_TUSER_WIDTH[0+:32],C_M06_AXIS_TUSER_WIDTH[0+:32],C_M05_AXIS_TUSER_WIDTH[0+:32],C_M04_AXIS_TUSER_WIDTH[0+:32],C_M03_AXIS_TUSER_WIDTH[0+:32],C_M02_AXIS_TUSER_WIDTH[0+:32],C_M01_AXIS_TUSER_WIDTH[0+:32],C_M00_AXIS_TUSER_WIDTH[0+:32]},{C_S15_AXIS_TUSER_WIDTH[0+:32],C_S14_AXIS_TUSER_WIDTH[0+:32],C_S13_AXIS_TUSER_WIDTH[0+:32],C_S12_AXIS_TUSER_WIDTH[0+:32],C_S11_AXIS_TUSER_WIDTH[0+:32],C_S10_AXIS_TUSER_WIDTH[0+:32],C_S09_AXIS_TUSER_WIDTH[0+:32],C_S08_AXIS_TUSER_WIDTH[0+:32],C_S07_AXIS_TUSER_WIDTH[0+:32],C_S06_AXIS_TUSER_WIDTH[0+:32],C_S05_AXIS_TUSER_WIDTH[0+:32],C_S04_AXIS_TUSER_WIDTH[0+:32],C_S03_AXIS_TUSER_WIDTH[0+:32],C_S02_AXIS_TUSER_WIDTH[0+:32],C_S01_AXIS_TUSER_WIDTH[0+:32],C_S00_AXIS_TUSER_WIDTH[0+:32]},C_NUM_MI_SLOTS,C_NUM_SI_SLOTS);
  localparam [16*C_NUM_SI_SLOTS-1:0] P_M_AXIS_CONNECTIVITY_ARRAY = {C_M15_AXIS_CONNECTIVITY[C_NUM_SI_SLOTS-1:0],C_M14_AXIS_CONNECTIVITY[C_NUM_SI_SLOTS-1:0],C_M13_AXIS_CONNECTIVITY[C_NUM_SI_SLOTS-1:0],C_M12_AXIS_CONNECTIVITY[C_NUM_SI_SLOTS-1:0],C_M11_AXIS_CONNECTIVITY[C_NUM_SI_SLOTS-1:0],C_M10_AXIS_CONNECTIVITY[C_NUM_SI_SLOTS-1:0],C_M09_AXIS_CONNECTIVITY[C_NUM_SI_SLOTS-1:0],C_M08_AXIS_CONNECTIVITY[C_NUM_SI_SLOTS-1:0],C_M07_AXIS_CONNECTIVITY[C_NUM_SI_SLOTS-1:0],C_M06_AXIS_CONNECTIVITY[C_NUM_SI_SLOTS-1:0],C_M05_AXIS_CONNECTIVITY[C_NUM_SI_SLOTS-1:0],C_M04_AXIS_CONNECTIVITY[C_NUM_SI_SLOTS-1:0],C_M03_AXIS_CONNECTIVITY[C_NUM_SI_SLOTS-1:0],C_M02_AXIS_CONNECTIVITY[C_NUM_SI_SLOTS-1:0],C_M01_AXIS_CONNECTIVITY[C_NUM_SI_SLOTS-1:0],C_M00_AXIS_CONNECTIVITY[C_NUM_SI_SLOTS-1:0]};
  localparam [16*C_SWITCH_TDEST_WIDTH-1:0] P_M_AXIS_BASETDEST_ARRAY = {C_M15_AXIS_BASETDEST[C_SWITCH_TDEST_WIDTH-1:0],C_M14_AXIS_BASETDEST[C_SWITCH_TDEST_WIDTH-1:0],C_M13_AXIS_BASETDEST[C_SWITCH_TDEST_WIDTH-1:0],C_M12_AXIS_BASETDEST[C_SWITCH_TDEST_WIDTH-1:0],C_M11_AXIS_BASETDEST[C_SWITCH_TDEST_WIDTH-1:0],C_M10_AXIS_BASETDEST[C_SWITCH_TDEST_WIDTH-1:0],C_M09_AXIS_BASETDEST[C_SWITCH_TDEST_WIDTH-1:0],C_M08_AXIS_BASETDEST[C_SWITCH_TDEST_WIDTH-1:0],C_M07_AXIS_BASETDEST[C_SWITCH_TDEST_WIDTH-1:0],C_M06_AXIS_BASETDEST[C_SWITCH_TDEST_WIDTH-1:0],C_M05_AXIS_BASETDEST[C_SWITCH_TDEST_WIDTH-1:0],C_M04_AXIS_BASETDEST[C_SWITCH_TDEST_WIDTH-1:0],C_M03_AXIS_BASETDEST[C_SWITCH_TDEST_WIDTH-1:0],C_M02_AXIS_BASETDEST[C_SWITCH_TDEST_WIDTH-1:0],C_M01_AXIS_BASETDEST[C_SWITCH_TDEST_WIDTH-1:0],C_M00_AXIS_BASETDEST[C_SWITCH_TDEST_WIDTH-1:0]};
  localparam [16*C_SWITCH_TDEST_WIDTH-1:0] P_M_AXIS_HIGHTDEST_ARRAY = {C_M15_AXIS_HIGHTDEST[C_SWITCH_TDEST_WIDTH-1:0],C_M14_AXIS_HIGHTDEST[C_SWITCH_TDEST_WIDTH-1:0],C_M13_AXIS_HIGHTDEST[C_SWITCH_TDEST_WIDTH-1:0],C_M12_AXIS_HIGHTDEST[C_SWITCH_TDEST_WIDTH-1:0],C_M11_AXIS_HIGHTDEST[C_SWITCH_TDEST_WIDTH-1:0],C_M10_AXIS_HIGHTDEST[C_SWITCH_TDEST_WIDTH-1:0],C_M09_AXIS_HIGHTDEST[C_SWITCH_TDEST_WIDTH-1:0],C_M08_AXIS_HIGHTDEST[C_SWITCH_TDEST_WIDTH-1:0],C_M07_AXIS_HIGHTDEST[C_SWITCH_TDEST_WIDTH-1:0],C_M06_AXIS_HIGHTDEST[C_SWITCH_TDEST_WIDTH-1:0],C_M05_AXIS_HIGHTDEST[C_SWITCH_TDEST_WIDTH-1:0],C_M04_AXIS_HIGHTDEST[C_SWITCH_TDEST_WIDTH-1:0],C_M03_AXIS_HIGHTDEST[C_SWITCH_TDEST_WIDTH-1:0],C_M02_AXIS_HIGHTDEST[C_SWITCH_TDEST_WIDTH-1:0],C_M01_AXIS_HIGHTDEST[C_SWITCH_TDEST_WIDTH-1:0],C_M00_AXIS_HIGHTDEST[C_SWITCH_TDEST_WIDTH-1:0]};
  localparam [16*32-1:0] P_S_AXIS_TDATA_WIDTH_ARRAY = {C_S15_AXIS_TDATA_WIDTH[32-1:0],C_S14_AXIS_TDATA_WIDTH[32-1:0],C_S13_AXIS_TDATA_WIDTH[32-1:0],C_S12_AXIS_TDATA_WIDTH[32-1:0],C_S11_AXIS_TDATA_WIDTH[32-1:0],C_S10_AXIS_TDATA_WIDTH[32-1:0],C_S09_AXIS_TDATA_WIDTH[32-1:0],C_S08_AXIS_TDATA_WIDTH[32-1:0],C_S07_AXIS_TDATA_WIDTH[32-1:0],C_S06_AXIS_TDATA_WIDTH[32-1:0],C_S05_AXIS_TDATA_WIDTH[32-1:0],C_S04_AXIS_TDATA_WIDTH[32-1:0],C_S03_AXIS_TDATA_WIDTH[32-1:0],C_S02_AXIS_TDATA_WIDTH[32-1:0],C_S01_AXIS_TDATA_WIDTH[32-1:0],C_S00_AXIS_TDATA_WIDTH[32-1:0]};
  localparam [16*32-1:0] P_S_AXIS_TUSER_WIDTH_ARRAY = {C_S15_AXIS_TUSER_WIDTH[32-1:0],C_S14_AXIS_TUSER_WIDTH[32-1:0],C_S13_AXIS_TUSER_WIDTH[32-1:0],C_S12_AXIS_TUSER_WIDTH[32-1:0],C_S11_AXIS_TUSER_WIDTH[32-1:0],C_S10_AXIS_TUSER_WIDTH[32-1:0],C_S09_AXIS_TUSER_WIDTH[32-1:0],C_S08_AXIS_TUSER_WIDTH[32-1:0],C_S07_AXIS_TUSER_WIDTH[32-1:0],C_S06_AXIS_TUSER_WIDTH[32-1:0],C_S05_AXIS_TUSER_WIDTH[32-1:0],C_S04_AXIS_TUSER_WIDTH[32-1:0],C_S03_AXIS_TUSER_WIDTH[32-1:0],C_S02_AXIS_TUSER_WIDTH[32-1:0],C_S01_AXIS_TUSER_WIDTH[32-1:0],C_S00_AXIS_TUSER_WIDTH[32-1:0]};
  localparam [16*32-1:0] P_S_AXIS_IS_ACLK_ASYNC_ARRAY = {C_S15_AXIS_IS_ACLK_ASYNC[32-1:0],C_S14_AXIS_IS_ACLK_ASYNC[32-1:0],C_S13_AXIS_IS_ACLK_ASYNC[32-1:0],C_S12_AXIS_IS_ACLK_ASYNC[32-1:0],C_S11_AXIS_IS_ACLK_ASYNC[32-1:0],C_S10_AXIS_IS_ACLK_ASYNC[32-1:0],C_S09_AXIS_IS_ACLK_ASYNC[32-1:0],C_S08_AXIS_IS_ACLK_ASYNC[32-1:0],C_S07_AXIS_IS_ACLK_ASYNC[32-1:0],C_S06_AXIS_IS_ACLK_ASYNC[32-1:0],C_S05_AXIS_IS_ACLK_ASYNC[32-1:0],C_S04_AXIS_IS_ACLK_ASYNC[32-1:0],C_S03_AXIS_IS_ACLK_ASYNC[32-1:0],C_S02_AXIS_IS_ACLK_ASYNC[32-1:0],C_S01_AXIS_IS_ACLK_ASYNC[32-1:0],C_S00_AXIS_IS_ACLK_ASYNC[32-1:0]};
  localparam [16*32-1:0] P_S_AXIS_ACLK_RATIO_ARRAY = {C_S15_AXIS_ACLK_RATIO[32-1:0],C_S14_AXIS_ACLK_RATIO[32-1:0],C_S13_AXIS_ACLK_RATIO[32-1:0],C_S12_AXIS_ACLK_RATIO[32-1:0],C_S11_AXIS_ACLK_RATIO[32-1:0],C_S10_AXIS_ACLK_RATIO[32-1:0],C_S09_AXIS_ACLK_RATIO[32-1:0],C_S08_AXIS_ACLK_RATIO[32-1:0],C_S07_AXIS_ACLK_RATIO[32-1:0],C_S06_AXIS_ACLK_RATIO[32-1:0],C_S05_AXIS_ACLK_RATIO[32-1:0],C_S04_AXIS_ACLK_RATIO[32-1:0],C_S03_AXIS_ACLK_RATIO[32-1:0],C_S02_AXIS_ACLK_RATIO[32-1:0],C_S01_AXIS_ACLK_RATIO[32-1:0],C_S00_AXIS_ACLK_RATIO[32-1:0]};
  localparam [16*32-1:0] P_S_AXIS_REG_CONFIG_ARRAY = {C_S15_AXIS_REG_CONFIG[32-1:0],C_S14_AXIS_REG_CONFIG[32-1:0],C_S13_AXIS_REG_CONFIG[32-1:0],C_S12_AXIS_REG_CONFIG[32-1:0],C_S11_AXIS_REG_CONFIG[32-1:0],C_S10_AXIS_REG_CONFIG[32-1:0],C_S09_AXIS_REG_CONFIG[32-1:0],C_S08_AXIS_REG_CONFIG[32-1:0],C_S07_AXIS_REG_CONFIG[32-1:0],C_S06_AXIS_REG_CONFIG[32-1:0],C_S05_AXIS_REG_CONFIG[32-1:0],C_S04_AXIS_REG_CONFIG[32-1:0],C_S03_AXIS_REG_CONFIG[32-1:0],C_S02_AXIS_REG_CONFIG[32-1:0],C_S01_AXIS_REG_CONFIG[32-1:0],C_S00_AXIS_REG_CONFIG[32-1:0]};
  localparam [16*32-1:0] P_S_AXIS_FIFO_DEPTH_ARRAY = {C_S15_AXIS_FIFO_DEPTH[32-1:0],C_S14_AXIS_FIFO_DEPTH[32-1:0],C_S13_AXIS_FIFO_DEPTH[32-1:0],C_S12_AXIS_FIFO_DEPTH[32-1:0],C_S11_AXIS_FIFO_DEPTH[32-1:0],C_S10_AXIS_FIFO_DEPTH[32-1:0],C_S09_AXIS_FIFO_DEPTH[32-1:0],C_S08_AXIS_FIFO_DEPTH[32-1:0],C_S07_AXIS_FIFO_DEPTH[32-1:0],C_S06_AXIS_FIFO_DEPTH[32-1:0],C_S05_AXIS_FIFO_DEPTH[32-1:0],C_S04_AXIS_FIFO_DEPTH[32-1:0],C_S03_AXIS_FIFO_DEPTH[32-1:0],C_S02_AXIS_FIFO_DEPTH[32-1:0],C_S01_AXIS_FIFO_DEPTH[32-1:0],C_S00_AXIS_FIFO_DEPTH[32-1:0]};
  localparam [16*32-1:0] P_S_AXIS_FIFO_MODE_ARRAY = {C_S15_AXIS_FIFO_MODE[32-1:0],C_S14_AXIS_FIFO_MODE[32-1:0],C_S13_AXIS_FIFO_MODE[32-1:0],C_S12_AXIS_FIFO_MODE[32-1:0],C_S11_AXIS_FIFO_MODE[32-1:0],C_S10_AXIS_FIFO_MODE[32-1:0],C_S09_AXIS_FIFO_MODE[32-1:0],C_S08_AXIS_FIFO_MODE[32-1:0],C_S07_AXIS_FIFO_MODE[32-1:0],C_S06_AXIS_FIFO_MODE[32-1:0],C_S05_AXIS_FIFO_MODE[32-1:0],C_S04_AXIS_FIFO_MODE[32-1:0],C_S03_AXIS_FIFO_MODE[32-1:0],C_S02_AXIS_FIFO_MODE[32-1:0],C_S01_AXIS_FIFO_MODE[32-1:0],C_S00_AXIS_FIFO_MODE[32-1:0]};
  localparam [16*32-1:0] P_M_AXIS_TDATA_WIDTH_ARRAY = {C_M15_AXIS_TDATA_WIDTH[32-1:0],C_M14_AXIS_TDATA_WIDTH[32-1:0],C_M13_AXIS_TDATA_WIDTH[32-1:0],C_M12_AXIS_TDATA_WIDTH[32-1:0],C_M11_AXIS_TDATA_WIDTH[32-1:0],C_M10_AXIS_TDATA_WIDTH[32-1:0],C_M09_AXIS_TDATA_WIDTH[32-1:0],C_M08_AXIS_TDATA_WIDTH[32-1:0],C_M07_AXIS_TDATA_WIDTH[32-1:0],C_M06_AXIS_TDATA_WIDTH[32-1:0],C_M05_AXIS_TDATA_WIDTH[32-1:0],C_M04_AXIS_TDATA_WIDTH[32-1:0],C_M03_AXIS_TDATA_WIDTH[32-1:0],C_M02_AXIS_TDATA_WIDTH[32-1:0],C_M01_AXIS_TDATA_WIDTH[32-1:0],C_M00_AXIS_TDATA_WIDTH[32-1:0]};
  localparam [16*32-1:0] P_M_AXIS_TUSER_WIDTH_ARRAY = {C_M15_AXIS_TUSER_WIDTH[32-1:0],C_M14_AXIS_TUSER_WIDTH[32-1:0],C_M13_AXIS_TUSER_WIDTH[32-1:0],C_M12_AXIS_TUSER_WIDTH[32-1:0],C_M11_AXIS_TUSER_WIDTH[32-1:0],C_M10_AXIS_TUSER_WIDTH[32-1:0],C_M09_AXIS_TUSER_WIDTH[32-1:0],C_M08_AXIS_TUSER_WIDTH[32-1:0],C_M07_AXIS_TUSER_WIDTH[32-1:0],C_M06_AXIS_TUSER_WIDTH[32-1:0],C_M05_AXIS_TUSER_WIDTH[32-1:0],C_M04_AXIS_TUSER_WIDTH[32-1:0],C_M03_AXIS_TUSER_WIDTH[32-1:0],C_M02_AXIS_TUSER_WIDTH[32-1:0],C_M01_AXIS_TUSER_WIDTH[32-1:0],C_M00_AXIS_TUSER_WIDTH[32-1:0]};
  localparam [16*32-1:0] P_M_AXIS_ACLK_RATIO_ARRAY = {C_M15_AXIS_ACLK_RATIO[32-1:0],C_M14_AXIS_ACLK_RATIO[32-1:0],C_M13_AXIS_ACLK_RATIO[32-1:0],C_M12_AXIS_ACLK_RATIO[32-1:0],C_M11_AXIS_ACLK_RATIO[32-1:0],C_M10_AXIS_ACLK_RATIO[32-1:0],C_M09_AXIS_ACLK_RATIO[32-1:0],C_M08_AXIS_ACLK_RATIO[32-1:0],C_M07_AXIS_ACLK_RATIO[32-1:0],C_M06_AXIS_ACLK_RATIO[32-1:0],C_M05_AXIS_ACLK_RATIO[32-1:0],C_M04_AXIS_ACLK_RATIO[32-1:0],C_M03_AXIS_ACLK_RATIO[32-1:0],C_M02_AXIS_ACLK_RATIO[32-1:0],C_M01_AXIS_ACLK_RATIO[32-1:0],C_M00_AXIS_ACLK_RATIO[32-1:0]};
  localparam [16*32-1:0] P_M_AXIS_REG_CONFIG_ARRAY = {C_M15_AXIS_REG_CONFIG[32-1:0],C_M14_AXIS_REG_CONFIG[32-1:0],C_M13_AXIS_REG_CONFIG[32-1:0],C_M12_AXIS_REG_CONFIG[32-1:0],C_M11_AXIS_REG_CONFIG[32-1:0],C_M10_AXIS_REG_CONFIG[32-1:0],C_M09_AXIS_REG_CONFIG[32-1:0],C_M08_AXIS_REG_CONFIG[32-1:0],C_M07_AXIS_REG_CONFIG[32-1:0],C_M06_AXIS_REG_CONFIG[32-1:0],C_M05_AXIS_REG_CONFIG[32-1:0],C_M04_AXIS_REG_CONFIG[32-1:0],C_M03_AXIS_REG_CONFIG[32-1:0],C_M02_AXIS_REG_CONFIG[32-1:0],C_M01_AXIS_REG_CONFIG[32-1:0],C_M00_AXIS_REG_CONFIG[32-1:0]};
  localparam [16*32-1:0] P_M_AXIS_IS_ACLK_ASYNC_ARRAY = {C_M15_AXIS_IS_ACLK_ASYNC[32-1:0],C_M14_AXIS_IS_ACLK_ASYNC[32-1:0],C_M13_AXIS_IS_ACLK_ASYNC[32-1:0],C_M12_AXIS_IS_ACLK_ASYNC[32-1:0],C_M11_AXIS_IS_ACLK_ASYNC[32-1:0],C_M10_AXIS_IS_ACLK_ASYNC[32-1:0],C_M09_AXIS_IS_ACLK_ASYNC[32-1:0],C_M08_AXIS_IS_ACLK_ASYNC[32-1:0],C_M07_AXIS_IS_ACLK_ASYNC[32-1:0],C_M06_AXIS_IS_ACLK_ASYNC[32-1:0],C_M05_AXIS_IS_ACLK_ASYNC[32-1:0],C_M04_AXIS_IS_ACLK_ASYNC[32-1:0],C_M03_AXIS_IS_ACLK_ASYNC[32-1:0],C_M02_AXIS_IS_ACLK_ASYNC[32-1:0],C_M01_AXIS_IS_ACLK_ASYNC[32-1:0],C_M00_AXIS_IS_ACLK_ASYNC[32-1:0]};
  localparam [16*32-1:0] P_M_AXIS_FIFO_DEPTH_ARRAY = {C_M15_AXIS_FIFO_DEPTH[32-1:0],C_M14_AXIS_FIFO_DEPTH[32-1:0],C_M13_AXIS_FIFO_DEPTH[32-1:0],C_M12_AXIS_FIFO_DEPTH[32-1:0],C_M11_AXIS_FIFO_DEPTH[32-1:0],C_M10_AXIS_FIFO_DEPTH[32-1:0],C_M09_AXIS_FIFO_DEPTH[32-1:0],C_M08_AXIS_FIFO_DEPTH[32-1:0],C_M07_AXIS_FIFO_DEPTH[32-1:0],C_M06_AXIS_FIFO_DEPTH[32-1:0],C_M05_AXIS_FIFO_DEPTH[32-1:0],C_M04_AXIS_FIFO_DEPTH[32-1:0],C_M03_AXIS_FIFO_DEPTH[32-1:0],C_M02_AXIS_FIFO_DEPTH[32-1:0],C_M01_AXIS_FIFO_DEPTH[32-1:0],C_M00_AXIS_FIFO_DEPTH[32-1:0]};
  localparam [16*32-1:0] P_M_AXIS_FIFO_MODE_ARRAY = {C_M15_AXIS_FIFO_MODE[32-1:0],C_M14_AXIS_FIFO_MODE[32-1:0],C_M13_AXIS_FIFO_MODE[32-1:0],C_M12_AXIS_FIFO_MODE[32-1:0],C_M11_AXIS_FIFO_MODE[32-1:0],C_M10_AXIS_FIFO_MODE[32-1:0],C_M09_AXIS_FIFO_MODE[32-1:0],C_M08_AXIS_FIFO_MODE[32-1:0],C_M07_AXIS_FIFO_MODE[32-1:0],C_M06_AXIS_FIFO_MODE[32-1:0],C_M05_AXIS_FIFO_MODE[32-1:0],C_M04_AXIS_FIFO_MODE[32-1:0],C_M03_AXIS_FIFO_MODE[32-1:0],C_M02_AXIS_FIFO_MODE[32-1:0],C_M01_AXIS_FIFO_MODE[32-1:0],C_M00_AXIS_FIFO_MODE[32-1:0]};

///////////////////////////////////////////////////////////////////////////////
// Wire Declarations
///////////////////////////////////////////////////////////////////////////////
  wire [16*1-1:0] s_axis_aclk_i;
  wire [16*1-1:0] s_axis_aresetn_i;
  wire [16*1-1:0] s_axis_aclken_i;
  wire [16*1-1:0] s_axis_tvalid_i;
  wire [16*1-1:0] s_axis_tready_i;
  wire [16*C_AXIS_TDATA_MAX_WIDTH-1:0] s_axis_tdata_i;
  wire [16*C_AXIS_TDATA_MAX_WIDTH/8-1:0] s_axis_tstrb_i;
  wire [16*C_AXIS_TDATA_MAX_WIDTH/8-1:0] s_axis_tkeep_i;
  wire [16*1-1:0] s_axis_tlast_i;
  wire [16*C_SWITCH_TID_WIDTH-1:0] s_axis_tid_i;
  wire [16*C_SWITCH_TDEST_WIDTH-1:0] s_axis_tdest_i;
  wire [16*C_AXIS_TUSER_MAX_WIDTH-1:0] s_axis_tuser_i;
  wire [16*1-1:0] m_axis_aclk_i;
  wire [16*1-1:0] m_axis_aresetn_i;
  wire [16*1-1:0] m_axis_aclken_i;
  wire [16*1-1:0] m_axis_tvalid_i;
  wire [16*1-1:0] m_axis_tready_i;
  wire [16*C_AXIS_TDATA_MAX_WIDTH-1:0] m_axis_tdata_i;
  wire [16*C_AXIS_TDATA_MAX_WIDTH/8-1:0] m_axis_tstrb_i;
  wire [16*C_AXIS_TDATA_MAX_WIDTH/8-1:0] m_axis_tkeep_i;
  wire [16*1-1:0] m_axis_tlast_i;
  wire [16*C_SWITCH_TID_WIDTH-1:0] m_axis_tid_i;
  wire [16*C_SWITCH_TDEST_WIDTH-1:0] m_axis_tdest_i;
  wire [16*C_AXIS_TUSER_MAX_WIDTH-1:0] m_axis_tuser_i;
  wire [16*1-1:0] s_arb_req_suppress_i;
  wire [16*1-1:0] s_decode_err_i;
  wire [16*1-1:0] s_sparse_tkeep_removed_i;
  wire [16*1-1:0] s_packer_err_i;
  wire [16*32-1:0] s_fifo_data_count_i;
  wire [16*1-1:0] m_sparse_tkeep_removed_i;
  wire [16*1-1:0] m_packer_err_i;
  wire [16*32-1:0] m_fifo_data_count_i;

///////////////////////////////////////////////////////////////////////////////
// RTL
///////////////////////////////////////////////////////////////////////////////
  assign s_axis_aclk_i[0*1+:1] = S00_AXIS_ACLK;
  assign s_axis_aclk_i[1*1+:1] = S01_AXIS_ACLK;
  assign s_axis_aclk_i[2*1+:1] = S02_AXIS_ACLK;
  assign s_axis_aclk_i[3*1+:1] = S03_AXIS_ACLK;
  assign s_axis_aclk_i[4*1+:1] = S04_AXIS_ACLK;
  assign s_axis_aclk_i[5*1+:1] = S05_AXIS_ACLK;
  assign s_axis_aclk_i[6*1+:1] = S06_AXIS_ACLK;
  assign s_axis_aclk_i[7*1+:1] = S07_AXIS_ACLK;
  assign s_axis_aclk_i[8*1+:1] = S08_AXIS_ACLK;
  assign s_axis_aclk_i[9*1+:1] = S09_AXIS_ACLK;
  assign s_axis_aclk_i[10*1+:1] = S10_AXIS_ACLK;
  assign s_axis_aclk_i[11*1+:1] = S11_AXIS_ACLK;
  assign s_axis_aclk_i[12*1+:1] = S12_AXIS_ACLK;
  assign s_axis_aclk_i[13*1+:1] = S13_AXIS_ACLK;
  assign s_axis_aclk_i[14*1+:1] = S14_AXIS_ACLK;
  assign s_axis_aclk_i[15*1+:1] = S15_AXIS_ACLK;
  assign s_axis_aresetn_i[0*1+:1] = S00_AXIS_ARESETN;
  assign s_axis_aresetn_i[1*1+:1] = S01_AXIS_ARESETN;
  assign s_axis_aresetn_i[2*1+:1] = S02_AXIS_ARESETN;
  assign s_axis_aresetn_i[3*1+:1] = S03_AXIS_ARESETN;
  assign s_axis_aresetn_i[4*1+:1] = S04_AXIS_ARESETN;
  assign s_axis_aresetn_i[5*1+:1] = S05_AXIS_ARESETN;
  assign s_axis_aresetn_i[6*1+:1] = S06_AXIS_ARESETN;
  assign s_axis_aresetn_i[7*1+:1] = S07_AXIS_ARESETN;
  assign s_axis_aresetn_i[8*1+:1] = S08_AXIS_ARESETN;
  assign s_axis_aresetn_i[9*1+:1] = S09_AXIS_ARESETN;
  assign s_axis_aresetn_i[10*1+:1] = S10_AXIS_ARESETN;
  assign s_axis_aresetn_i[11*1+:1] = S11_AXIS_ARESETN;
  assign s_axis_aresetn_i[12*1+:1] = S12_AXIS_ARESETN;
  assign s_axis_aresetn_i[13*1+:1] = S13_AXIS_ARESETN;
  assign s_axis_aresetn_i[14*1+:1] = S14_AXIS_ARESETN;
  assign s_axis_aresetn_i[15*1+:1] = S15_AXIS_ARESETN;
  assign s_axis_aclken_i[0*1+:1] = S00_AXIS_ACLKEN;
  assign s_axis_aclken_i[1*1+:1] = S01_AXIS_ACLKEN;
  assign s_axis_aclken_i[2*1+:1] = S02_AXIS_ACLKEN;
  assign s_axis_aclken_i[3*1+:1] = S03_AXIS_ACLKEN;
  assign s_axis_aclken_i[4*1+:1] = S04_AXIS_ACLKEN;
  assign s_axis_aclken_i[5*1+:1] = S05_AXIS_ACLKEN;
  assign s_axis_aclken_i[6*1+:1] = S06_AXIS_ACLKEN;
  assign s_axis_aclken_i[7*1+:1] = S07_AXIS_ACLKEN;
  assign s_axis_aclken_i[8*1+:1] = S08_AXIS_ACLKEN;
  assign s_axis_aclken_i[9*1+:1] = S09_AXIS_ACLKEN;
  assign s_axis_aclken_i[10*1+:1] = S10_AXIS_ACLKEN;
  assign s_axis_aclken_i[11*1+:1] = S11_AXIS_ACLKEN;
  assign s_axis_aclken_i[12*1+:1] = S12_AXIS_ACLKEN;
  assign s_axis_aclken_i[13*1+:1] = S13_AXIS_ACLKEN;
  assign s_axis_aclken_i[14*1+:1] = S14_AXIS_ACLKEN;
  assign s_axis_aclken_i[15*1+:1] = S15_AXIS_ACLKEN;
  assign s_axis_tvalid_i[0*1+:1] = S00_AXIS_TVALID;
  assign s_axis_tvalid_i[1*1+:1] = S01_AXIS_TVALID;
  assign s_axis_tvalid_i[2*1+:1] = S02_AXIS_TVALID;
  assign s_axis_tvalid_i[3*1+:1] = S03_AXIS_TVALID;
  assign s_axis_tvalid_i[4*1+:1] = S04_AXIS_TVALID;
  assign s_axis_tvalid_i[5*1+:1] = S05_AXIS_TVALID;
  assign s_axis_tvalid_i[6*1+:1] = S06_AXIS_TVALID;
  assign s_axis_tvalid_i[7*1+:1] = S07_AXIS_TVALID;
  assign s_axis_tvalid_i[8*1+:1] = S08_AXIS_TVALID;
  assign s_axis_tvalid_i[9*1+:1] = S09_AXIS_TVALID;
  assign s_axis_tvalid_i[10*1+:1] = S10_AXIS_TVALID;
  assign s_axis_tvalid_i[11*1+:1] = S11_AXIS_TVALID;
  assign s_axis_tvalid_i[12*1+:1] = S12_AXIS_TVALID;
  assign s_axis_tvalid_i[13*1+:1] = S13_AXIS_TVALID;
  assign s_axis_tvalid_i[14*1+:1] = S14_AXIS_TVALID;
  assign s_axis_tvalid_i[15*1+:1] = S15_AXIS_TVALID;
  assign S00_AXIS_TREADY = s_axis_tready_i[0*1+:1];
  assign S01_AXIS_TREADY = s_axis_tready_i[1*1+:1];
  assign S02_AXIS_TREADY = s_axis_tready_i[2*1+:1];
  assign S03_AXIS_TREADY = s_axis_tready_i[3*1+:1];
  assign S04_AXIS_TREADY = s_axis_tready_i[4*1+:1];
  assign S05_AXIS_TREADY = s_axis_tready_i[5*1+:1];
  assign S06_AXIS_TREADY = s_axis_tready_i[6*1+:1];
  assign S07_AXIS_TREADY = s_axis_tready_i[7*1+:1];
  assign S08_AXIS_TREADY = s_axis_tready_i[8*1+:1];
  assign S09_AXIS_TREADY = s_axis_tready_i[9*1+:1];
  assign S10_AXIS_TREADY = s_axis_tready_i[10*1+:1];
  assign S11_AXIS_TREADY = s_axis_tready_i[11*1+:1];
  assign S12_AXIS_TREADY = s_axis_tready_i[12*1+:1];
  assign S13_AXIS_TREADY = s_axis_tready_i[13*1+:1];
  assign S14_AXIS_TREADY = s_axis_tready_i[14*1+:1];
  assign S15_AXIS_TREADY = s_axis_tready_i[15*1+:1];
  assign s_axis_tdata_i[0*C_AXIS_TDATA_MAX_WIDTH+:C_S00_AXIS_TDATA_WIDTH] = S00_AXIS_TDATA[C_S00_AXIS_TDATA_WIDTH-1:0];
  assign s_axis_tdata_i[1*C_AXIS_TDATA_MAX_WIDTH+:C_S01_AXIS_TDATA_WIDTH] = S01_AXIS_TDATA[C_S01_AXIS_TDATA_WIDTH-1:0];
  assign s_axis_tdata_i[2*C_AXIS_TDATA_MAX_WIDTH+:C_S02_AXIS_TDATA_WIDTH] = S02_AXIS_TDATA[C_S02_AXIS_TDATA_WIDTH-1:0];
  assign s_axis_tdata_i[3*C_AXIS_TDATA_MAX_WIDTH+:C_S03_AXIS_TDATA_WIDTH] = S03_AXIS_TDATA[C_S03_AXIS_TDATA_WIDTH-1:0];
  assign s_axis_tdata_i[4*C_AXIS_TDATA_MAX_WIDTH+:C_S04_AXIS_TDATA_WIDTH] = S04_AXIS_TDATA[C_S04_AXIS_TDATA_WIDTH-1:0];
  assign s_axis_tdata_i[5*C_AXIS_TDATA_MAX_WIDTH+:C_S05_AXIS_TDATA_WIDTH] = S05_AXIS_TDATA[C_S05_AXIS_TDATA_WIDTH-1:0];
  assign s_axis_tdata_i[6*C_AXIS_TDATA_MAX_WIDTH+:C_S06_AXIS_TDATA_WIDTH] = S06_AXIS_TDATA[C_S06_AXIS_TDATA_WIDTH-1:0];
  assign s_axis_tdata_i[7*C_AXIS_TDATA_MAX_WIDTH+:C_S07_AXIS_TDATA_WIDTH] = S07_AXIS_TDATA[C_S07_AXIS_TDATA_WIDTH-1:0];
  assign s_axis_tdata_i[8*C_AXIS_TDATA_MAX_WIDTH+:C_S08_AXIS_TDATA_WIDTH] = S08_AXIS_TDATA[C_S08_AXIS_TDATA_WIDTH-1:0];
  assign s_axis_tdata_i[9*C_AXIS_TDATA_MAX_WIDTH+:C_S09_AXIS_TDATA_WIDTH] = S09_AXIS_TDATA[C_S09_AXIS_TDATA_WIDTH-1:0];
  assign s_axis_tdata_i[10*C_AXIS_TDATA_MAX_WIDTH+:C_S10_AXIS_TDATA_WIDTH] = S10_AXIS_TDATA[C_S10_AXIS_TDATA_WIDTH-1:0];
  assign s_axis_tdata_i[11*C_AXIS_TDATA_MAX_WIDTH+:C_S11_AXIS_TDATA_WIDTH] = S11_AXIS_TDATA[C_S11_AXIS_TDATA_WIDTH-1:0];
  assign s_axis_tdata_i[12*C_AXIS_TDATA_MAX_WIDTH+:C_S12_AXIS_TDATA_WIDTH] = S12_AXIS_TDATA[C_S12_AXIS_TDATA_WIDTH-1:0];
  assign s_axis_tdata_i[13*C_AXIS_TDATA_MAX_WIDTH+:C_S13_AXIS_TDATA_WIDTH] = S13_AXIS_TDATA[C_S13_AXIS_TDATA_WIDTH-1:0];
  assign s_axis_tdata_i[14*C_AXIS_TDATA_MAX_WIDTH+:C_S14_AXIS_TDATA_WIDTH] = S14_AXIS_TDATA[C_S14_AXIS_TDATA_WIDTH-1:0];
  assign s_axis_tdata_i[15*C_AXIS_TDATA_MAX_WIDTH+:C_S15_AXIS_TDATA_WIDTH] = S15_AXIS_TDATA[C_S15_AXIS_TDATA_WIDTH-1:0];
  assign s_axis_tstrb_i[0*C_AXIS_TDATA_MAX_WIDTH/8+:C_S00_AXIS_TDATA_WIDTH/8] = S00_AXIS_TSTRB[C_S00_AXIS_TDATA_WIDTH/8-1:0];
  assign s_axis_tstrb_i[1*C_AXIS_TDATA_MAX_WIDTH/8+:C_S01_AXIS_TDATA_WIDTH/8] = S01_AXIS_TSTRB[C_S01_AXIS_TDATA_WIDTH/8-1:0];
  assign s_axis_tstrb_i[2*C_AXIS_TDATA_MAX_WIDTH/8+:C_S02_AXIS_TDATA_WIDTH/8] = S02_AXIS_TSTRB[C_S02_AXIS_TDATA_WIDTH/8-1:0];
  assign s_axis_tstrb_i[3*C_AXIS_TDATA_MAX_WIDTH/8+:C_S03_AXIS_TDATA_WIDTH/8] = S03_AXIS_TSTRB[C_S03_AXIS_TDATA_WIDTH/8-1:0];
  assign s_axis_tstrb_i[4*C_AXIS_TDATA_MAX_WIDTH/8+:C_S04_AXIS_TDATA_WIDTH/8] = S04_AXIS_TSTRB[C_S04_AXIS_TDATA_WIDTH/8-1:0];
  assign s_axis_tstrb_i[5*C_AXIS_TDATA_MAX_WIDTH/8+:C_S05_AXIS_TDATA_WIDTH/8] = S05_AXIS_TSTRB[C_S05_AXIS_TDATA_WIDTH/8-1:0];
  assign s_axis_tstrb_i[6*C_AXIS_TDATA_MAX_WIDTH/8+:C_S06_AXIS_TDATA_WIDTH/8] = S06_AXIS_TSTRB[C_S06_AXIS_TDATA_WIDTH/8-1:0];
  assign s_axis_tstrb_i[7*C_AXIS_TDATA_MAX_WIDTH/8+:C_S07_AXIS_TDATA_WIDTH/8] = S07_AXIS_TSTRB[C_S07_AXIS_TDATA_WIDTH/8-1:0];
  assign s_axis_tstrb_i[8*C_AXIS_TDATA_MAX_WIDTH/8+:C_S08_AXIS_TDATA_WIDTH/8] = S08_AXIS_TSTRB[C_S08_AXIS_TDATA_WIDTH/8-1:0];
  assign s_axis_tstrb_i[9*C_AXIS_TDATA_MAX_WIDTH/8+:C_S09_AXIS_TDATA_WIDTH/8] = S09_AXIS_TSTRB[C_S09_AXIS_TDATA_WIDTH/8-1:0];
  assign s_axis_tstrb_i[10*C_AXIS_TDATA_MAX_WIDTH/8+:C_S10_AXIS_TDATA_WIDTH/8] = S10_AXIS_TSTRB[C_S10_AXIS_TDATA_WIDTH/8-1:0];
  assign s_axis_tstrb_i[11*C_AXIS_TDATA_MAX_WIDTH/8+:C_S11_AXIS_TDATA_WIDTH/8] = S11_AXIS_TSTRB[C_S11_AXIS_TDATA_WIDTH/8-1:0];
  assign s_axis_tstrb_i[12*C_AXIS_TDATA_MAX_WIDTH/8+:C_S12_AXIS_TDATA_WIDTH/8] = S12_AXIS_TSTRB[C_S12_AXIS_TDATA_WIDTH/8-1:0];
  assign s_axis_tstrb_i[13*C_AXIS_TDATA_MAX_WIDTH/8+:C_S13_AXIS_TDATA_WIDTH/8] = S13_AXIS_TSTRB[C_S13_AXIS_TDATA_WIDTH/8-1:0];
  assign s_axis_tstrb_i[14*C_AXIS_TDATA_MAX_WIDTH/8+:C_S14_AXIS_TDATA_WIDTH/8] = S14_AXIS_TSTRB[C_S14_AXIS_TDATA_WIDTH/8-1:0];
  assign s_axis_tstrb_i[15*C_AXIS_TDATA_MAX_WIDTH/8+:C_S15_AXIS_TDATA_WIDTH/8] = S15_AXIS_TSTRB[C_S15_AXIS_TDATA_WIDTH/8-1:0];
  assign s_axis_tkeep_i[0*C_AXIS_TDATA_MAX_WIDTH/8+:C_S00_AXIS_TDATA_WIDTH/8] = S00_AXIS_TKEEP[C_S00_AXIS_TDATA_WIDTH/8-1:0];
  assign s_axis_tkeep_i[1*C_AXIS_TDATA_MAX_WIDTH/8+:C_S01_AXIS_TDATA_WIDTH/8] = S01_AXIS_TKEEP[C_S01_AXIS_TDATA_WIDTH/8-1:0];
  assign s_axis_tkeep_i[2*C_AXIS_TDATA_MAX_WIDTH/8+:C_S02_AXIS_TDATA_WIDTH/8] = S02_AXIS_TKEEP[C_S02_AXIS_TDATA_WIDTH/8-1:0];
  assign s_axis_tkeep_i[3*C_AXIS_TDATA_MAX_WIDTH/8+:C_S03_AXIS_TDATA_WIDTH/8] = S03_AXIS_TKEEP[C_S03_AXIS_TDATA_WIDTH/8-1:0];
  assign s_axis_tkeep_i[4*C_AXIS_TDATA_MAX_WIDTH/8+:C_S04_AXIS_TDATA_WIDTH/8] = S04_AXIS_TKEEP[C_S04_AXIS_TDATA_WIDTH/8-1:0];
  assign s_axis_tkeep_i[5*C_AXIS_TDATA_MAX_WIDTH/8+:C_S05_AXIS_TDATA_WIDTH/8] = S05_AXIS_TKEEP[C_S05_AXIS_TDATA_WIDTH/8-1:0];
  assign s_axis_tkeep_i[6*C_AXIS_TDATA_MAX_WIDTH/8+:C_S06_AXIS_TDATA_WIDTH/8] = S06_AXIS_TKEEP[C_S06_AXIS_TDATA_WIDTH/8-1:0];
  assign s_axis_tkeep_i[7*C_AXIS_TDATA_MAX_WIDTH/8+:C_S07_AXIS_TDATA_WIDTH/8] = S07_AXIS_TKEEP[C_S07_AXIS_TDATA_WIDTH/8-1:0];
  assign s_axis_tkeep_i[8*C_AXIS_TDATA_MAX_WIDTH/8+:C_S08_AXIS_TDATA_WIDTH/8] = S08_AXIS_TKEEP[C_S08_AXIS_TDATA_WIDTH/8-1:0];
  assign s_axis_tkeep_i[9*C_AXIS_TDATA_MAX_WIDTH/8+:C_S09_AXIS_TDATA_WIDTH/8] = S09_AXIS_TKEEP[C_S09_AXIS_TDATA_WIDTH/8-1:0];
  assign s_axis_tkeep_i[10*C_AXIS_TDATA_MAX_WIDTH/8+:C_S10_AXIS_TDATA_WIDTH/8] = S10_AXIS_TKEEP[C_S10_AXIS_TDATA_WIDTH/8-1:0];
  assign s_axis_tkeep_i[11*C_AXIS_TDATA_MAX_WIDTH/8+:C_S11_AXIS_TDATA_WIDTH/8] = S11_AXIS_TKEEP[C_S11_AXIS_TDATA_WIDTH/8-1:0];
  assign s_axis_tkeep_i[12*C_AXIS_TDATA_MAX_WIDTH/8+:C_S12_AXIS_TDATA_WIDTH/8] = S12_AXIS_TKEEP[C_S12_AXIS_TDATA_WIDTH/8-1:0];
  assign s_axis_tkeep_i[13*C_AXIS_TDATA_MAX_WIDTH/8+:C_S13_AXIS_TDATA_WIDTH/8] = S13_AXIS_TKEEP[C_S13_AXIS_TDATA_WIDTH/8-1:0];
  assign s_axis_tkeep_i[14*C_AXIS_TDATA_MAX_WIDTH/8+:C_S14_AXIS_TDATA_WIDTH/8] = S14_AXIS_TKEEP[C_S14_AXIS_TDATA_WIDTH/8-1:0];
  assign s_axis_tkeep_i[15*C_AXIS_TDATA_MAX_WIDTH/8+:C_S15_AXIS_TDATA_WIDTH/8] = S15_AXIS_TKEEP[C_S15_AXIS_TDATA_WIDTH/8-1:0];
  assign s_axis_tlast_i[0*1+:1] = S00_AXIS_TLAST;
  assign s_axis_tlast_i[1*1+:1] = S01_AXIS_TLAST;
  assign s_axis_tlast_i[2*1+:1] = S02_AXIS_TLAST;
  assign s_axis_tlast_i[3*1+:1] = S03_AXIS_TLAST;
  assign s_axis_tlast_i[4*1+:1] = S04_AXIS_TLAST;
  assign s_axis_tlast_i[5*1+:1] = S05_AXIS_TLAST;
  assign s_axis_tlast_i[6*1+:1] = S06_AXIS_TLAST;
  assign s_axis_tlast_i[7*1+:1] = S07_AXIS_TLAST;
  assign s_axis_tlast_i[8*1+:1] = S08_AXIS_TLAST;
  assign s_axis_tlast_i[9*1+:1] = S09_AXIS_TLAST;
  assign s_axis_tlast_i[10*1+:1] = S10_AXIS_TLAST;
  assign s_axis_tlast_i[11*1+:1] = S11_AXIS_TLAST;
  assign s_axis_tlast_i[12*1+:1] = S12_AXIS_TLAST;
  assign s_axis_tlast_i[13*1+:1] = S13_AXIS_TLAST;
  assign s_axis_tlast_i[14*1+:1] = S14_AXIS_TLAST;
  assign s_axis_tlast_i[15*1+:1] = S15_AXIS_TLAST;
  assign s_axis_tid_i[0*C_SWITCH_TID_WIDTH+:C_SWITCH_TID_WIDTH] = S00_AXIS_TID[C_SWITCH_TID_WIDTH-1:0];
  assign s_axis_tid_i[1*C_SWITCH_TID_WIDTH+:C_SWITCH_TID_WIDTH] = S01_AXIS_TID[C_SWITCH_TID_WIDTH-1:0];
  assign s_axis_tid_i[2*C_SWITCH_TID_WIDTH+:C_SWITCH_TID_WIDTH] = S02_AXIS_TID[C_SWITCH_TID_WIDTH-1:0];
  assign s_axis_tid_i[3*C_SWITCH_TID_WIDTH+:C_SWITCH_TID_WIDTH] = S03_AXIS_TID[C_SWITCH_TID_WIDTH-1:0];
  assign s_axis_tid_i[4*C_SWITCH_TID_WIDTH+:C_SWITCH_TID_WIDTH] = S04_AXIS_TID[C_SWITCH_TID_WIDTH-1:0];
  assign s_axis_tid_i[5*C_SWITCH_TID_WIDTH+:C_SWITCH_TID_WIDTH] = S05_AXIS_TID[C_SWITCH_TID_WIDTH-1:0];
  assign s_axis_tid_i[6*C_SWITCH_TID_WIDTH+:C_SWITCH_TID_WIDTH] = S06_AXIS_TID[C_SWITCH_TID_WIDTH-1:0];
  assign s_axis_tid_i[7*C_SWITCH_TID_WIDTH+:C_SWITCH_TID_WIDTH] = S07_AXIS_TID[C_SWITCH_TID_WIDTH-1:0];
  assign s_axis_tid_i[8*C_SWITCH_TID_WIDTH+:C_SWITCH_TID_WIDTH] = S08_AXIS_TID[C_SWITCH_TID_WIDTH-1:0];
  assign s_axis_tid_i[9*C_SWITCH_TID_WIDTH+:C_SWITCH_TID_WIDTH] = S09_AXIS_TID[C_SWITCH_TID_WIDTH-1:0];
  assign s_axis_tid_i[10*C_SWITCH_TID_WIDTH+:C_SWITCH_TID_WIDTH] = S10_AXIS_TID[C_SWITCH_TID_WIDTH-1:0];
  assign s_axis_tid_i[11*C_SWITCH_TID_WIDTH+:C_SWITCH_TID_WIDTH] = S11_AXIS_TID[C_SWITCH_TID_WIDTH-1:0];
  assign s_axis_tid_i[12*C_SWITCH_TID_WIDTH+:C_SWITCH_TID_WIDTH] = S12_AXIS_TID[C_SWITCH_TID_WIDTH-1:0];
  assign s_axis_tid_i[13*C_SWITCH_TID_WIDTH+:C_SWITCH_TID_WIDTH] = S13_AXIS_TID[C_SWITCH_TID_WIDTH-1:0];
  assign s_axis_tid_i[14*C_SWITCH_TID_WIDTH+:C_SWITCH_TID_WIDTH] = S14_AXIS_TID[C_SWITCH_TID_WIDTH-1:0];
  assign s_axis_tid_i[15*C_SWITCH_TID_WIDTH+:C_SWITCH_TID_WIDTH] = S15_AXIS_TID[C_SWITCH_TID_WIDTH-1:0];
  assign s_axis_tdest_i[0*C_SWITCH_TDEST_WIDTH+:C_SWITCH_TDEST_WIDTH] = S00_AXIS_TDEST[C_SWITCH_TDEST_WIDTH-1:0];
  assign s_axis_tdest_i[1*C_SWITCH_TDEST_WIDTH+:C_SWITCH_TDEST_WIDTH] = S01_AXIS_TDEST[C_SWITCH_TDEST_WIDTH-1:0];
  assign s_axis_tdest_i[2*C_SWITCH_TDEST_WIDTH+:C_SWITCH_TDEST_WIDTH] = S02_AXIS_TDEST[C_SWITCH_TDEST_WIDTH-1:0];
  assign s_axis_tdest_i[3*C_SWITCH_TDEST_WIDTH+:C_SWITCH_TDEST_WIDTH] = S03_AXIS_TDEST[C_SWITCH_TDEST_WIDTH-1:0];
  assign s_axis_tdest_i[4*C_SWITCH_TDEST_WIDTH+:C_SWITCH_TDEST_WIDTH] = S04_AXIS_TDEST[C_SWITCH_TDEST_WIDTH-1:0];
  assign s_axis_tdest_i[5*C_SWITCH_TDEST_WIDTH+:C_SWITCH_TDEST_WIDTH] = S05_AXIS_TDEST[C_SWITCH_TDEST_WIDTH-1:0];
  assign s_axis_tdest_i[6*C_SWITCH_TDEST_WIDTH+:C_SWITCH_TDEST_WIDTH] = S06_AXIS_TDEST[C_SWITCH_TDEST_WIDTH-1:0];
  assign s_axis_tdest_i[7*C_SWITCH_TDEST_WIDTH+:C_SWITCH_TDEST_WIDTH] = S07_AXIS_TDEST[C_SWITCH_TDEST_WIDTH-1:0];
  assign s_axis_tdest_i[8*C_SWITCH_TDEST_WIDTH+:C_SWITCH_TDEST_WIDTH] = S08_AXIS_TDEST[C_SWITCH_TDEST_WIDTH-1:0];
  assign s_axis_tdest_i[9*C_SWITCH_TDEST_WIDTH+:C_SWITCH_TDEST_WIDTH] = S09_AXIS_TDEST[C_SWITCH_TDEST_WIDTH-1:0];
  assign s_axis_tdest_i[10*C_SWITCH_TDEST_WIDTH+:C_SWITCH_TDEST_WIDTH] = S10_AXIS_TDEST[C_SWITCH_TDEST_WIDTH-1:0];
  assign s_axis_tdest_i[11*C_SWITCH_TDEST_WIDTH+:C_SWITCH_TDEST_WIDTH] = S11_AXIS_TDEST[C_SWITCH_TDEST_WIDTH-1:0];
  assign s_axis_tdest_i[12*C_SWITCH_TDEST_WIDTH+:C_SWITCH_TDEST_WIDTH] = S12_AXIS_TDEST[C_SWITCH_TDEST_WIDTH-1:0];
  assign s_axis_tdest_i[13*C_SWITCH_TDEST_WIDTH+:C_SWITCH_TDEST_WIDTH] = S13_AXIS_TDEST[C_SWITCH_TDEST_WIDTH-1:0];
  assign s_axis_tdest_i[14*C_SWITCH_TDEST_WIDTH+:C_SWITCH_TDEST_WIDTH] = S14_AXIS_TDEST[C_SWITCH_TDEST_WIDTH-1:0];
  assign s_axis_tdest_i[15*C_SWITCH_TDEST_WIDTH+:C_SWITCH_TDEST_WIDTH] = S15_AXIS_TDEST[C_SWITCH_TDEST_WIDTH-1:0];
  assign s_axis_tuser_i[0*C_AXIS_TUSER_MAX_WIDTH+:C_S00_AXIS_TUSER_WIDTH] = S00_AXIS_TUSER[C_S00_AXIS_TUSER_WIDTH-1:0];
  assign s_axis_tuser_i[1*C_AXIS_TUSER_MAX_WIDTH+:C_S01_AXIS_TUSER_WIDTH] = S01_AXIS_TUSER[C_S01_AXIS_TUSER_WIDTH-1:0];
  assign s_axis_tuser_i[2*C_AXIS_TUSER_MAX_WIDTH+:C_S02_AXIS_TUSER_WIDTH] = S02_AXIS_TUSER[C_S02_AXIS_TUSER_WIDTH-1:0];
  assign s_axis_tuser_i[3*C_AXIS_TUSER_MAX_WIDTH+:C_S03_AXIS_TUSER_WIDTH] = S03_AXIS_TUSER[C_S03_AXIS_TUSER_WIDTH-1:0];
  assign s_axis_tuser_i[4*C_AXIS_TUSER_MAX_WIDTH+:C_S04_AXIS_TUSER_WIDTH] = S04_AXIS_TUSER[C_S04_AXIS_TUSER_WIDTH-1:0];
  assign s_axis_tuser_i[5*C_AXIS_TUSER_MAX_WIDTH+:C_S05_AXIS_TUSER_WIDTH] = S05_AXIS_TUSER[C_S05_AXIS_TUSER_WIDTH-1:0];
  assign s_axis_tuser_i[6*C_AXIS_TUSER_MAX_WIDTH+:C_S06_AXIS_TUSER_WIDTH] = S06_AXIS_TUSER[C_S06_AXIS_TUSER_WIDTH-1:0];
  assign s_axis_tuser_i[7*C_AXIS_TUSER_MAX_WIDTH+:C_S07_AXIS_TUSER_WIDTH] = S07_AXIS_TUSER[C_S07_AXIS_TUSER_WIDTH-1:0];
  assign s_axis_tuser_i[8*C_AXIS_TUSER_MAX_WIDTH+:C_S08_AXIS_TUSER_WIDTH] = S08_AXIS_TUSER[C_S08_AXIS_TUSER_WIDTH-1:0];
  assign s_axis_tuser_i[9*C_AXIS_TUSER_MAX_WIDTH+:C_S09_AXIS_TUSER_WIDTH] = S09_AXIS_TUSER[C_S09_AXIS_TUSER_WIDTH-1:0];
  assign s_axis_tuser_i[10*C_AXIS_TUSER_MAX_WIDTH+:C_S10_AXIS_TUSER_WIDTH] = S10_AXIS_TUSER[C_S10_AXIS_TUSER_WIDTH-1:0];
  assign s_axis_tuser_i[11*C_AXIS_TUSER_MAX_WIDTH+:C_S11_AXIS_TUSER_WIDTH] = S11_AXIS_TUSER[C_S11_AXIS_TUSER_WIDTH-1:0];
  assign s_axis_tuser_i[12*C_AXIS_TUSER_MAX_WIDTH+:C_S12_AXIS_TUSER_WIDTH] = S12_AXIS_TUSER[C_S12_AXIS_TUSER_WIDTH-1:0];
  assign s_axis_tuser_i[13*C_AXIS_TUSER_MAX_WIDTH+:C_S13_AXIS_TUSER_WIDTH] = S13_AXIS_TUSER[C_S13_AXIS_TUSER_WIDTH-1:0];
  assign s_axis_tuser_i[14*C_AXIS_TUSER_MAX_WIDTH+:C_S14_AXIS_TUSER_WIDTH] = S14_AXIS_TUSER[C_S14_AXIS_TUSER_WIDTH-1:0];
  assign s_axis_tuser_i[15*C_AXIS_TUSER_MAX_WIDTH+:C_S15_AXIS_TUSER_WIDTH] = S15_AXIS_TUSER[C_S15_AXIS_TUSER_WIDTH-1:0];
  assign m_axis_aclk_i[0*1+:1] = M00_AXIS_ACLK;
  assign m_axis_aclk_i[1*1+:1] = M01_AXIS_ACLK;
  assign m_axis_aclk_i[2*1+:1] = M02_AXIS_ACLK;
  assign m_axis_aclk_i[3*1+:1] = M03_AXIS_ACLK;
  assign m_axis_aclk_i[4*1+:1] = M04_AXIS_ACLK;
  assign m_axis_aclk_i[5*1+:1] = M05_AXIS_ACLK;
  assign m_axis_aclk_i[6*1+:1] = M06_AXIS_ACLK;
  assign m_axis_aclk_i[7*1+:1] = M07_AXIS_ACLK;
  assign m_axis_aclk_i[8*1+:1] = M08_AXIS_ACLK;
  assign m_axis_aclk_i[9*1+:1] = M09_AXIS_ACLK;
  assign m_axis_aclk_i[10*1+:1] = M10_AXIS_ACLK;
  assign m_axis_aclk_i[11*1+:1] = M11_AXIS_ACLK;
  assign m_axis_aclk_i[12*1+:1] = M12_AXIS_ACLK;
  assign m_axis_aclk_i[13*1+:1] = M13_AXIS_ACLK;
  assign m_axis_aclk_i[14*1+:1] = M14_AXIS_ACLK;
  assign m_axis_aclk_i[15*1+:1] = M15_AXIS_ACLK;
  assign m_axis_aresetn_i[0*1+:1] = M00_AXIS_ARESETN;
  assign m_axis_aresetn_i[1*1+:1] = M01_AXIS_ARESETN;
  assign m_axis_aresetn_i[2*1+:1] = M02_AXIS_ARESETN;
  assign m_axis_aresetn_i[3*1+:1] = M03_AXIS_ARESETN;
  assign m_axis_aresetn_i[4*1+:1] = M04_AXIS_ARESETN;
  assign m_axis_aresetn_i[5*1+:1] = M05_AXIS_ARESETN;
  assign m_axis_aresetn_i[6*1+:1] = M06_AXIS_ARESETN;
  assign m_axis_aresetn_i[7*1+:1] = M07_AXIS_ARESETN;
  assign m_axis_aresetn_i[8*1+:1] = M08_AXIS_ARESETN;
  assign m_axis_aresetn_i[9*1+:1] = M09_AXIS_ARESETN;
  assign m_axis_aresetn_i[10*1+:1] = M10_AXIS_ARESETN;
  assign m_axis_aresetn_i[11*1+:1] = M11_AXIS_ARESETN;
  assign m_axis_aresetn_i[12*1+:1] = M12_AXIS_ARESETN;
  assign m_axis_aresetn_i[13*1+:1] = M13_AXIS_ARESETN;
  assign m_axis_aresetn_i[14*1+:1] = M14_AXIS_ARESETN;
  assign m_axis_aresetn_i[15*1+:1] = M15_AXIS_ARESETN;
  assign m_axis_aclken_i[0*1+:1] = M00_AXIS_ACLKEN;
  assign m_axis_aclken_i[1*1+:1] = M01_AXIS_ACLKEN;
  assign m_axis_aclken_i[2*1+:1] = M02_AXIS_ACLKEN;
  assign m_axis_aclken_i[3*1+:1] = M03_AXIS_ACLKEN;
  assign m_axis_aclken_i[4*1+:1] = M04_AXIS_ACLKEN;
  assign m_axis_aclken_i[5*1+:1] = M05_AXIS_ACLKEN;
  assign m_axis_aclken_i[6*1+:1] = M06_AXIS_ACLKEN;
  assign m_axis_aclken_i[7*1+:1] = M07_AXIS_ACLKEN;
  assign m_axis_aclken_i[8*1+:1] = M08_AXIS_ACLKEN;
  assign m_axis_aclken_i[9*1+:1] = M09_AXIS_ACLKEN;
  assign m_axis_aclken_i[10*1+:1] = M10_AXIS_ACLKEN;
  assign m_axis_aclken_i[11*1+:1] = M11_AXIS_ACLKEN;
  assign m_axis_aclken_i[12*1+:1] = M12_AXIS_ACLKEN;
  assign m_axis_aclken_i[13*1+:1] = M13_AXIS_ACLKEN;
  assign m_axis_aclken_i[14*1+:1] = M14_AXIS_ACLKEN;
  assign m_axis_aclken_i[15*1+:1] = M15_AXIS_ACLKEN;
  assign M00_AXIS_TVALID = m_axis_tvalid_i[0*1+:1];
  assign M01_AXIS_TVALID = m_axis_tvalid_i[1*1+:1];
  assign M02_AXIS_TVALID = m_axis_tvalid_i[2*1+:1];
  assign M03_AXIS_TVALID = m_axis_tvalid_i[3*1+:1];
  assign M04_AXIS_TVALID = m_axis_tvalid_i[4*1+:1];
  assign M05_AXIS_TVALID = m_axis_tvalid_i[5*1+:1];
  assign M06_AXIS_TVALID = m_axis_tvalid_i[6*1+:1];
  assign M07_AXIS_TVALID = m_axis_tvalid_i[7*1+:1];
  assign M08_AXIS_TVALID = m_axis_tvalid_i[8*1+:1];
  assign M09_AXIS_TVALID = m_axis_tvalid_i[9*1+:1];
  assign M10_AXIS_TVALID = m_axis_tvalid_i[10*1+:1];
  assign M11_AXIS_TVALID = m_axis_tvalid_i[11*1+:1];
  assign M12_AXIS_TVALID = m_axis_tvalid_i[12*1+:1];
  assign M13_AXIS_TVALID = m_axis_tvalid_i[13*1+:1];
  assign M14_AXIS_TVALID = m_axis_tvalid_i[14*1+:1];
  assign M15_AXIS_TVALID = m_axis_tvalid_i[15*1+:1];
  assign m_axis_tready_i[0*1+:1] = M00_AXIS_TREADY;
  assign m_axis_tready_i[1*1+:1] = M01_AXIS_TREADY;
  assign m_axis_tready_i[2*1+:1] = M02_AXIS_TREADY;
  assign m_axis_tready_i[3*1+:1] = M03_AXIS_TREADY;
  assign m_axis_tready_i[4*1+:1] = M04_AXIS_TREADY;
  assign m_axis_tready_i[5*1+:1] = M05_AXIS_TREADY;
  assign m_axis_tready_i[6*1+:1] = M06_AXIS_TREADY;
  assign m_axis_tready_i[7*1+:1] = M07_AXIS_TREADY;
  assign m_axis_tready_i[8*1+:1] = M08_AXIS_TREADY;
  assign m_axis_tready_i[9*1+:1] = M09_AXIS_TREADY;
  assign m_axis_tready_i[10*1+:1] = M10_AXIS_TREADY;
  assign m_axis_tready_i[11*1+:1] = M11_AXIS_TREADY;
  assign m_axis_tready_i[12*1+:1] = M12_AXIS_TREADY;
  assign m_axis_tready_i[13*1+:1] = M13_AXIS_TREADY;
  assign m_axis_tready_i[14*1+:1] = M14_AXIS_TREADY;
  assign m_axis_tready_i[15*1+:1] = M15_AXIS_TREADY;
  assign M00_AXIS_TDATA[C_M00_AXIS_TDATA_WIDTH-1:0] = m_axis_tdata_i[0*C_AXIS_TDATA_MAX_WIDTH+:C_M00_AXIS_TDATA_WIDTH];
  assign M01_AXIS_TDATA[C_M01_AXIS_TDATA_WIDTH-1:0] = m_axis_tdata_i[1*C_AXIS_TDATA_MAX_WIDTH+:C_M01_AXIS_TDATA_WIDTH];
  assign M02_AXIS_TDATA[C_M02_AXIS_TDATA_WIDTH-1:0] = m_axis_tdata_i[2*C_AXIS_TDATA_MAX_WIDTH+:C_M02_AXIS_TDATA_WIDTH];
  assign M03_AXIS_TDATA[C_M03_AXIS_TDATA_WIDTH-1:0] = m_axis_tdata_i[3*C_AXIS_TDATA_MAX_WIDTH+:C_M03_AXIS_TDATA_WIDTH];
  assign M04_AXIS_TDATA[C_M04_AXIS_TDATA_WIDTH-1:0] = m_axis_tdata_i[4*C_AXIS_TDATA_MAX_WIDTH+:C_M04_AXIS_TDATA_WIDTH];
  assign M05_AXIS_TDATA[C_M05_AXIS_TDATA_WIDTH-1:0] = m_axis_tdata_i[5*C_AXIS_TDATA_MAX_WIDTH+:C_M05_AXIS_TDATA_WIDTH];
  assign M06_AXIS_TDATA[C_M06_AXIS_TDATA_WIDTH-1:0] = m_axis_tdata_i[6*C_AXIS_TDATA_MAX_WIDTH+:C_M06_AXIS_TDATA_WIDTH];
  assign M07_AXIS_TDATA[C_M07_AXIS_TDATA_WIDTH-1:0] = m_axis_tdata_i[7*C_AXIS_TDATA_MAX_WIDTH+:C_M07_AXIS_TDATA_WIDTH];
  assign M08_AXIS_TDATA[C_M08_AXIS_TDATA_WIDTH-1:0] = m_axis_tdata_i[8*C_AXIS_TDATA_MAX_WIDTH+:C_M08_AXIS_TDATA_WIDTH];
  assign M09_AXIS_TDATA[C_M09_AXIS_TDATA_WIDTH-1:0] = m_axis_tdata_i[9*C_AXIS_TDATA_MAX_WIDTH+:C_M09_AXIS_TDATA_WIDTH];
  assign M10_AXIS_TDATA[C_M10_AXIS_TDATA_WIDTH-1:0] = m_axis_tdata_i[10*C_AXIS_TDATA_MAX_WIDTH+:C_M10_AXIS_TDATA_WIDTH];
  assign M11_AXIS_TDATA[C_M11_AXIS_TDATA_WIDTH-1:0] = m_axis_tdata_i[11*C_AXIS_TDATA_MAX_WIDTH+:C_M11_AXIS_TDATA_WIDTH];
  assign M12_AXIS_TDATA[C_M12_AXIS_TDATA_WIDTH-1:0] = m_axis_tdata_i[12*C_AXIS_TDATA_MAX_WIDTH+:C_M12_AXIS_TDATA_WIDTH];
  assign M13_AXIS_TDATA[C_M13_AXIS_TDATA_WIDTH-1:0] = m_axis_tdata_i[13*C_AXIS_TDATA_MAX_WIDTH+:C_M13_AXIS_TDATA_WIDTH];
  assign M14_AXIS_TDATA[C_M14_AXIS_TDATA_WIDTH-1:0] = m_axis_tdata_i[14*C_AXIS_TDATA_MAX_WIDTH+:C_M14_AXIS_TDATA_WIDTH];
  assign M15_AXIS_TDATA[C_M15_AXIS_TDATA_WIDTH-1:0] = m_axis_tdata_i[15*C_AXIS_TDATA_MAX_WIDTH+:C_M15_AXIS_TDATA_WIDTH];
  assign M00_AXIS_TSTRB[C_M00_AXIS_TDATA_WIDTH/8-1:0] = m_axis_tstrb_i[0*C_AXIS_TDATA_MAX_WIDTH/8+:C_M00_AXIS_TDATA_WIDTH/8];
  assign M01_AXIS_TSTRB[C_M01_AXIS_TDATA_WIDTH/8-1:0] = m_axis_tstrb_i[1*C_AXIS_TDATA_MAX_WIDTH/8+:C_M01_AXIS_TDATA_WIDTH/8];
  assign M02_AXIS_TSTRB[C_M02_AXIS_TDATA_WIDTH/8-1:0] = m_axis_tstrb_i[2*C_AXIS_TDATA_MAX_WIDTH/8+:C_M02_AXIS_TDATA_WIDTH/8];
  assign M03_AXIS_TSTRB[C_M03_AXIS_TDATA_WIDTH/8-1:0] = m_axis_tstrb_i[3*C_AXIS_TDATA_MAX_WIDTH/8+:C_M03_AXIS_TDATA_WIDTH/8];
  assign M04_AXIS_TSTRB[C_M04_AXIS_TDATA_WIDTH/8-1:0] = m_axis_tstrb_i[4*C_AXIS_TDATA_MAX_WIDTH/8+:C_M04_AXIS_TDATA_WIDTH/8];
  assign M05_AXIS_TSTRB[C_M05_AXIS_TDATA_WIDTH/8-1:0] = m_axis_tstrb_i[5*C_AXIS_TDATA_MAX_WIDTH/8+:C_M05_AXIS_TDATA_WIDTH/8];
  assign M06_AXIS_TSTRB[C_M06_AXIS_TDATA_WIDTH/8-1:0] = m_axis_tstrb_i[6*C_AXIS_TDATA_MAX_WIDTH/8+:C_M06_AXIS_TDATA_WIDTH/8];
  assign M07_AXIS_TSTRB[C_M07_AXIS_TDATA_WIDTH/8-1:0] = m_axis_tstrb_i[7*C_AXIS_TDATA_MAX_WIDTH/8+:C_M07_AXIS_TDATA_WIDTH/8];
  assign M08_AXIS_TSTRB[C_M08_AXIS_TDATA_WIDTH/8-1:0] = m_axis_tstrb_i[8*C_AXIS_TDATA_MAX_WIDTH/8+:C_M08_AXIS_TDATA_WIDTH/8];
  assign M09_AXIS_TSTRB[C_M09_AXIS_TDATA_WIDTH/8-1:0] = m_axis_tstrb_i[9*C_AXIS_TDATA_MAX_WIDTH/8+:C_M09_AXIS_TDATA_WIDTH/8];
  assign M10_AXIS_TSTRB[C_M10_AXIS_TDATA_WIDTH/8-1:0] = m_axis_tstrb_i[10*C_AXIS_TDATA_MAX_WIDTH/8+:C_M10_AXIS_TDATA_WIDTH/8];
  assign M11_AXIS_TSTRB[C_M11_AXIS_TDATA_WIDTH/8-1:0] = m_axis_tstrb_i[11*C_AXIS_TDATA_MAX_WIDTH/8+:C_M11_AXIS_TDATA_WIDTH/8];
  assign M12_AXIS_TSTRB[C_M12_AXIS_TDATA_WIDTH/8-1:0] = m_axis_tstrb_i[12*C_AXIS_TDATA_MAX_WIDTH/8+:C_M12_AXIS_TDATA_WIDTH/8];
  assign M13_AXIS_TSTRB[C_M13_AXIS_TDATA_WIDTH/8-1:0] = m_axis_tstrb_i[13*C_AXIS_TDATA_MAX_WIDTH/8+:C_M13_AXIS_TDATA_WIDTH/8];
  assign M14_AXIS_TSTRB[C_M14_AXIS_TDATA_WIDTH/8-1:0] = m_axis_tstrb_i[14*C_AXIS_TDATA_MAX_WIDTH/8+:C_M14_AXIS_TDATA_WIDTH/8];
  assign M15_AXIS_TSTRB[C_M15_AXIS_TDATA_WIDTH/8-1:0] = m_axis_tstrb_i[15*C_AXIS_TDATA_MAX_WIDTH/8+:C_M15_AXIS_TDATA_WIDTH/8];
  assign M00_AXIS_TKEEP[C_M00_AXIS_TDATA_WIDTH/8-1:0] = m_axis_tkeep_i[0*C_AXIS_TDATA_MAX_WIDTH/8+:C_M00_AXIS_TDATA_WIDTH/8];
  assign M01_AXIS_TKEEP[C_M01_AXIS_TDATA_WIDTH/8-1:0] = m_axis_tkeep_i[1*C_AXIS_TDATA_MAX_WIDTH/8+:C_M01_AXIS_TDATA_WIDTH/8];
  assign M02_AXIS_TKEEP[C_M02_AXIS_TDATA_WIDTH/8-1:0] = m_axis_tkeep_i[2*C_AXIS_TDATA_MAX_WIDTH/8+:C_M02_AXIS_TDATA_WIDTH/8];
  assign M03_AXIS_TKEEP[C_M03_AXIS_TDATA_WIDTH/8-1:0] = m_axis_tkeep_i[3*C_AXIS_TDATA_MAX_WIDTH/8+:C_M03_AXIS_TDATA_WIDTH/8];
  assign M04_AXIS_TKEEP[C_M04_AXIS_TDATA_WIDTH/8-1:0] = m_axis_tkeep_i[4*C_AXIS_TDATA_MAX_WIDTH/8+:C_M04_AXIS_TDATA_WIDTH/8];
  assign M05_AXIS_TKEEP[C_M05_AXIS_TDATA_WIDTH/8-1:0] = m_axis_tkeep_i[5*C_AXIS_TDATA_MAX_WIDTH/8+:C_M05_AXIS_TDATA_WIDTH/8];
  assign M06_AXIS_TKEEP[C_M06_AXIS_TDATA_WIDTH/8-1:0] = m_axis_tkeep_i[6*C_AXIS_TDATA_MAX_WIDTH/8+:C_M06_AXIS_TDATA_WIDTH/8];
  assign M07_AXIS_TKEEP[C_M07_AXIS_TDATA_WIDTH/8-1:0] = m_axis_tkeep_i[7*C_AXIS_TDATA_MAX_WIDTH/8+:C_M07_AXIS_TDATA_WIDTH/8];
  assign M08_AXIS_TKEEP[C_M08_AXIS_TDATA_WIDTH/8-1:0] = m_axis_tkeep_i[8*C_AXIS_TDATA_MAX_WIDTH/8+:C_M08_AXIS_TDATA_WIDTH/8];
  assign M09_AXIS_TKEEP[C_M09_AXIS_TDATA_WIDTH/8-1:0] = m_axis_tkeep_i[9*C_AXIS_TDATA_MAX_WIDTH/8+:C_M09_AXIS_TDATA_WIDTH/8];
  assign M10_AXIS_TKEEP[C_M10_AXIS_TDATA_WIDTH/8-1:0] = m_axis_tkeep_i[10*C_AXIS_TDATA_MAX_WIDTH/8+:C_M10_AXIS_TDATA_WIDTH/8];
  assign M11_AXIS_TKEEP[C_M11_AXIS_TDATA_WIDTH/8-1:0] = m_axis_tkeep_i[11*C_AXIS_TDATA_MAX_WIDTH/8+:C_M11_AXIS_TDATA_WIDTH/8];
  assign M12_AXIS_TKEEP[C_M12_AXIS_TDATA_WIDTH/8-1:0] = m_axis_tkeep_i[12*C_AXIS_TDATA_MAX_WIDTH/8+:C_M12_AXIS_TDATA_WIDTH/8];
  assign M13_AXIS_TKEEP[C_M13_AXIS_TDATA_WIDTH/8-1:0] = m_axis_tkeep_i[13*C_AXIS_TDATA_MAX_WIDTH/8+:C_M13_AXIS_TDATA_WIDTH/8];
  assign M14_AXIS_TKEEP[C_M14_AXIS_TDATA_WIDTH/8-1:0] = m_axis_tkeep_i[14*C_AXIS_TDATA_MAX_WIDTH/8+:C_M14_AXIS_TDATA_WIDTH/8];
  assign M15_AXIS_TKEEP[C_M15_AXIS_TDATA_WIDTH/8-1:0] = m_axis_tkeep_i[15*C_AXIS_TDATA_MAX_WIDTH/8+:C_M15_AXIS_TDATA_WIDTH/8];
  assign M00_AXIS_TLAST = m_axis_tlast_i[0*1+:1];
  assign M01_AXIS_TLAST = m_axis_tlast_i[1*1+:1];
  assign M02_AXIS_TLAST = m_axis_tlast_i[2*1+:1];
  assign M03_AXIS_TLAST = m_axis_tlast_i[3*1+:1];
  assign M04_AXIS_TLAST = m_axis_tlast_i[4*1+:1];
  assign M05_AXIS_TLAST = m_axis_tlast_i[5*1+:1];
  assign M06_AXIS_TLAST = m_axis_tlast_i[6*1+:1];
  assign M07_AXIS_TLAST = m_axis_tlast_i[7*1+:1];
  assign M08_AXIS_TLAST = m_axis_tlast_i[8*1+:1];
  assign M09_AXIS_TLAST = m_axis_tlast_i[9*1+:1];
  assign M10_AXIS_TLAST = m_axis_tlast_i[10*1+:1];
  assign M11_AXIS_TLAST = m_axis_tlast_i[11*1+:1];
  assign M12_AXIS_TLAST = m_axis_tlast_i[12*1+:1];
  assign M13_AXIS_TLAST = m_axis_tlast_i[13*1+:1];
  assign M14_AXIS_TLAST = m_axis_tlast_i[14*1+:1];
  assign M15_AXIS_TLAST = m_axis_tlast_i[15*1+:1];
  assign M00_AXIS_TID[C_SWITCH_TID_WIDTH-1:0] = m_axis_tid_i[0*C_SWITCH_TID_WIDTH+:C_SWITCH_TID_WIDTH];
  assign M01_AXIS_TID[C_SWITCH_TID_WIDTH-1:0] = m_axis_tid_i[1*C_SWITCH_TID_WIDTH+:C_SWITCH_TID_WIDTH];
  assign M02_AXIS_TID[C_SWITCH_TID_WIDTH-1:0] = m_axis_tid_i[2*C_SWITCH_TID_WIDTH+:C_SWITCH_TID_WIDTH];
  assign M03_AXIS_TID[C_SWITCH_TID_WIDTH-1:0] = m_axis_tid_i[3*C_SWITCH_TID_WIDTH+:C_SWITCH_TID_WIDTH];
  assign M04_AXIS_TID[C_SWITCH_TID_WIDTH-1:0] = m_axis_tid_i[4*C_SWITCH_TID_WIDTH+:C_SWITCH_TID_WIDTH];
  assign M05_AXIS_TID[C_SWITCH_TID_WIDTH-1:0] = m_axis_tid_i[5*C_SWITCH_TID_WIDTH+:C_SWITCH_TID_WIDTH];
  assign M06_AXIS_TID[C_SWITCH_TID_WIDTH-1:0] = m_axis_tid_i[6*C_SWITCH_TID_WIDTH+:C_SWITCH_TID_WIDTH];
  assign M07_AXIS_TID[C_SWITCH_TID_WIDTH-1:0] = m_axis_tid_i[7*C_SWITCH_TID_WIDTH+:C_SWITCH_TID_WIDTH];
  assign M08_AXIS_TID[C_SWITCH_TID_WIDTH-1:0] = m_axis_tid_i[8*C_SWITCH_TID_WIDTH+:C_SWITCH_TID_WIDTH];
  assign M09_AXIS_TID[C_SWITCH_TID_WIDTH-1:0] = m_axis_tid_i[9*C_SWITCH_TID_WIDTH+:C_SWITCH_TID_WIDTH];
  assign M10_AXIS_TID[C_SWITCH_TID_WIDTH-1:0] = m_axis_tid_i[10*C_SWITCH_TID_WIDTH+:C_SWITCH_TID_WIDTH];
  assign M11_AXIS_TID[C_SWITCH_TID_WIDTH-1:0] = m_axis_tid_i[11*C_SWITCH_TID_WIDTH+:C_SWITCH_TID_WIDTH];
  assign M12_AXIS_TID[C_SWITCH_TID_WIDTH-1:0] = m_axis_tid_i[12*C_SWITCH_TID_WIDTH+:C_SWITCH_TID_WIDTH];
  assign M13_AXIS_TID[C_SWITCH_TID_WIDTH-1:0] = m_axis_tid_i[13*C_SWITCH_TID_WIDTH+:C_SWITCH_TID_WIDTH];
  assign M14_AXIS_TID[C_SWITCH_TID_WIDTH-1:0] = m_axis_tid_i[14*C_SWITCH_TID_WIDTH+:C_SWITCH_TID_WIDTH];
  assign M15_AXIS_TID[C_SWITCH_TID_WIDTH-1:0] = m_axis_tid_i[15*C_SWITCH_TID_WIDTH+:C_SWITCH_TID_WIDTH];
  assign M00_AXIS_TDEST[C_SWITCH_TDEST_WIDTH-1:0] = m_axis_tdest_i[0*C_SWITCH_TDEST_WIDTH+:C_SWITCH_TDEST_WIDTH];
  assign M01_AXIS_TDEST[C_SWITCH_TDEST_WIDTH-1:0] = m_axis_tdest_i[1*C_SWITCH_TDEST_WIDTH+:C_SWITCH_TDEST_WIDTH];
  assign M02_AXIS_TDEST[C_SWITCH_TDEST_WIDTH-1:0] = m_axis_tdest_i[2*C_SWITCH_TDEST_WIDTH+:C_SWITCH_TDEST_WIDTH];
  assign M03_AXIS_TDEST[C_SWITCH_TDEST_WIDTH-1:0] = m_axis_tdest_i[3*C_SWITCH_TDEST_WIDTH+:C_SWITCH_TDEST_WIDTH];
  assign M04_AXIS_TDEST[C_SWITCH_TDEST_WIDTH-1:0] = m_axis_tdest_i[4*C_SWITCH_TDEST_WIDTH+:C_SWITCH_TDEST_WIDTH];
  assign M05_AXIS_TDEST[C_SWITCH_TDEST_WIDTH-1:0] = m_axis_tdest_i[5*C_SWITCH_TDEST_WIDTH+:C_SWITCH_TDEST_WIDTH];
  assign M06_AXIS_TDEST[C_SWITCH_TDEST_WIDTH-1:0] = m_axis_tdest_i[6*C_SWITCH_TDEST_WIDTH+:C_SWITCH_TDEST_WIDTH];
  assign M07_AXIS_TDEST[C_SWITCH_TDEST_WIDTH-1:0] = m_axis_tdest_i[7*C_SWITCH_TDEST_WIDTH+:C_SWITCH_TDEST_WIDTH];
  assign M08_AXIS_TDEST[C_SWITCH_TDEST_WIDTH-1:0] = m_axis_tdest_i[8*C_SWITCH_TDEST_WIDTH+:C_SWITCH_TDEST_WIDTH];
  assign M09_AXIS_TDEST[C_SWITCH_TDEST_WIDTH-1:0] = m_axis_tdest_i[9*C_SWITCH_TDEST_WIDTH+:C_SWITCH_TDEST_WIDTH];
  assign M10_AXIS_TDEST[C_SWITCH_TDEST_WIDTH-1:0] = m_axis_tdest_i[10*C_SWITCH_TDEST_WIDTH+:C_SWITCH_TDEST_WIDTH];
  assign M11_AXIS_TDEST[C_SWITCH_TDEST_WIDTH-1:0] = m_axis_tdest_i[11*C_SWITCH_TDEST_WIDTH+:C_SWITCH_TDEST_WIDTH];
  assign M12_AXIS_TDEST[C_SWITCH_TDEST_WIDTH-1:0] = m_axis_tdest_i[12*C_SWITCH_TDEST_WIDTH+:C_SWITCH_TDEST_WIDTH];
  assign M13_AXIS_TDEST[C_SWITCH_TDEST_WIDTH-1:0] = m_axis_tdest_i[13*C_SWITCH_TDEST_WIDTH+:C_SWITCH_TDEST_WIDTH];
  assign M14_AXIS_TDEST[C_SWITCH_TDEST_WIDTH-1:0] = m_axis_tdest_i[14*C_SWITCH_TDEST_WIDTH+:C_SWITCH_TDEST_WIDTH];
  assign M15_AXIS_TDEST[C_SWITCH_TDEST_WIDTH-1:0] = m_axis_tdest_i[15*C_SWITCH_TDEST_WIDTH+:C_SWITCH_TDEST_WIDTH];
  assign M00_AXIS_TUSER[C_M00_AXIS_TUSER_WIDTH-1:0] = m_axis_tuser_i[0*C_AXIS_TUSER_MAX_WIDTH+:C_M00_AXIS_TUSER_WIDTH];
  assign M01_AXIS_TUSER[C_M01_AXIS_TUSER_WIDTH-1:0] = m_axis_tuser_i[1*C_AXIS_TUSER_MAX_WIDTH+:C_M01_AXIS_TUSER_WIDTH];
  assign M02_AXIS_TUSER[C_M02_AXIS_TUSER_WIDTH-1:0] = m_axis_tuser_i[2*C_AXIS_TUSER_MAX_WIDTH+:C_M02_AXIS_TUSER_WIDTH];
  assign M03_AXIS_TUSER[C_M03_AXIS_TUSER_WIDTH-1:0] = m_axis_tuser_i[3*C_AXIS_TUSER_MAX_WIDTH+:C_M03_AXIS_TUSER_WIDTH];
  assign M04_AXIS_TUSER[C_M04_AXIS_TUSER_WIDTH-1:0] = m_axis_tuser_i[4*C_AXIS_TUSER_MAX_WIDTH+:C_M04_AXIS_TUSER_WIDTH];
  assign M05_AXIS_TUSER[C_M05_AXIS_TUSER_WIDTH-1:0] = m_axis_tuser_i[5*C_AXIS_TUSER_MAX_WIDTH+:C_M05_AXIS_TUSER_WIDTH];
  assign M06_AXIS_TUSER[C_M06_AXIS_TUSER_WIDTH-1:0] = m_axis_tuser_i[6*C_AXIS_TUSER_MAX_WIDTH+:C_M06_AXIS_TUSER_WIDTH];
  assign M07_AXIS_TUSER[C_M07_AXIS_TUSER_WIDTH-1:0] = m_axis_tuser_i[7*C_AXIS_TUSER_MAX_WIDTH+:C_M07_AXIS_TUSER_WIDTH];
  assign M08_AXIS_TUSER[C_M08_AXIS_TUSER_WIDTH-1:0] = m_axis_tuser_i[8*C_AXIS_TUSER_MAX_WIDTH+:C_M08_AXIS_TUSER_WIDTH];
  assign M09_AXIS_TUSER[C_M09_AXIS_TUSER_WIDTH-1:0] = m_axis_tuser_i[9*C_AXIS_TUSER_MAX_WIDTH+:C_M09_AXIS_TUSER_WIDTH];
  assign M10_AXIS_TUSER[C_M10_AXIS_TUSER_WIDTH-1:0] = m_axis_tuser_i[10*C_AXIS_TUSER_MAX_WIDTH+:C_M10_AXIS_TUSER_WIDTH];
  assign M11_AXIS_TUSER[C_M11_AXIS_TUSER_WIDTH-1:0] = m_axis_tuser_i[11*C_AXIS_TUSER_MAX_WIDTH+:C_M11_AXIS_TUSER_WIDTH];
  assign M12_AXIS_TUSER[C_M12_AXIS_TUSER_WIDTH-1:0] = m_axis_tuser_i[12*C_AXIS_TUSER_MAX_WIDTH+:C_M12_AXIS_TUSER_WIDTH];
  assign M13_AXIS_TUSER[C_M13_AXIS_TUSER_WIDTH-1:0] = m_axis_tuser_i[13*C_AXIS_TUSER_MAX_WIDTH+:C_M13_AXIS_TUSER_WIDTH];
  assign M14_AXIS_TUSER[C_M14_AXIS_TUSER_WIDTH-1:0] = m_axis_tuser_i[14*C_AXIS_TUSER_MAX_WIDTH+:C_M14_AXIS_TUSER_WIDTH];
  assign M15_AXIS_TUSER[C_M15_AXIS_TUSER_WIDTH-1:0] = m_axis_tuser_i[15*C_AXIS_TUSER_MAX_WIDTH+:C_M15_AXIS_TUSER_WIDTH];
  assign s_arb_req_suppress_i[0*1+:1] = S00_ARB_REQ_SUPPRESS;
  assign s_arb_req_suppress_i[1*1+:1] = S01_ARB_REQ_SUPPRESS;
  assign s_arb_req_suppress_i[2*1+:1] = S02_ARB_REQ_SUPPRESS;
  assign s_arb_req_suppress_i[3*1+:1] = S03_ARB_REQ_SUPPRESS;
  assign s_arb_req_suppress_i[4*1+:1] = S04_ARB_REQ_SUPPRESS;
  assign s_arb_req_suppress_i[5*1+:1] = S05_ARB_REQ_SUPPRESS;
  assign s_arb_req_suppress_i[6*1+:1] = S06_ARB_REQ_SUPPRESS;
  assign s_arb_req_suppress_i[7*1+:1] = S07_ARB_REQ_SUPPRESS;
  assign s_arb_req_suppress_i[8*1+:1] = S08_ARB_REQ_SUPPRESS;
  assign s_arb_req_suppress_i[9*1+:1] = S09_ARB_REQ_SUPPRESS;
  assign s_arb_req_suppress_i[10*1+:1] = S10_ARB_REQ_SUPPRESS;
  assign s_arb_req_suppress_i[11*1+:1] = S11_ARB_REQ_SUPPRESS;
  assign s_arb_req_suppress_i[12*1+:1] = S12_ARB_REQ_SUPPRESS;
  assign s_arb_req_suppress_i[13*1+:1] = S13_ARB_REQ_SUPPRESS;
  assign s_arb_req_suppress_i[14*1+:1] = S14_ARB_REQ_SUPPRESS;
  assign s_arb_req_suppress_i[15*1+:1] = S15_ARB_REQ_SUPPRESS;
  assign S00_DECODE_ERR = s_decode_err_i[0*1+:1];
  assign S01_DECODE_ERR = s_decode_err_i[1*1+:1];
  assign S02_DECODE_ERR = s_decode_err_i[2*1+:1];
  assign S03_DECODE_ERR = s_decode_err_i[3*1+:1];
  assign S04_DECODE_ERR = s_decode_err_i[4*1+:1];
  assign S05_DECODE_ERR = s_decode_err_i[5*1+:1];
  assign S06_DECODE_ERR = s_decode_err_i[6*1+:1];
  assign S07_DECODE_ERR = s_decode_err_i[7*1+:1];
  assign S08_DECODE_ERR = s_decode_err_i[8*1+:1];
  assign S09_DECODE_ERR = s_decode_err_i[9*1+:1];
  assign S10_DECODE_ERR = s_decode_err_i[10*1+:1];
  assign S11_DECODE_ERR = s_decode_err_i[11*1+:1];
  assign S12_DECODE_ERR = s_decode_err_i[12*1+:1];
  assign S13_DECODE_ERR = s_decode_err_i[13*1+:1];
  assign S14_DECODE_ERR = s_decode_err_i[14*1+:1];
  assign S15_DECODE_ERR = s_decode_err_i[15*1+:1];
  assign S00_SPARSE_TKEEP_REMOVED = s_sparse_tkeep_removed_i[0*1+:1];
  assign S01_SPARSE_TKEEP_REMOVED = s_sparse_tkeep_removed_i[1*1+:1];
  assign S02_SPARSE_TKEEP_REMOVED = s_sparse_tkeep_removed_i[2*1+:1];
  assign S03_SPARSE_TKEEP_REMOVED = s_sparse_tkeep_removed_i[3*1+:1];
  assign S04_SPARSE_TKEEP_REMOVED = s_sparse_tkeep_removed_i[4*1+:1];
  assign S05_SPARSE_TKEEP_REMOVED = s_sparse_tkeep_removed_i[5*1+:1];
  assign S06_SPARSE_TKEEP_REMOVED = s_sparse_tkeep_removed_i[6*1+:1];
  assign S07_SPARSE_TKEEP_REMOVED = s_sparse_tkeep_removed_i[7*1+:1];
  assign S08_SPARSE_TKEEP_REMOVED = s_sparse_tkeep_removed_i[8*1+:1];
  assign S09_SPARSE_TKEEP_REMOVED = s_sparse_tkeep_removed_i[9*1+:1];
  assign S10_SPARSE_TKEEP_REMOVED = s_sparse_tkeep_removed_i[10*1+:1];
  assign S11_SPARSE_TKEEP_REMOVED = s_sparse_tkeep_removed_i[11*1+:1];
  assign S12_SPARSE_TKEEP_REMOVED = s_sparse_tkeep_removed_i[12*1+:1];
  assign S13_SPARSE_TKEEP_REMOVED = s_sparse_tkeep_removed_i[13*1+:1];
  assign S14_SPARSE_TKEEP_REMOVED = s_sparse_tkeep_removed_i[14*1+:1];
  assign S15_SPARSE_TKEEP_REMOVED = s_sparse_tkeep_removed_i[15*1+:1];
  assign S00_PACKER_ERR = s_packer_err_i[0*1+:1];
  assign S01_PACKER_ERR = s_packer_err_i[1*1+:1];
  assign S02_PACKER_ERR = s_packer_err_i[2*1+:1];
  assign S03_PACKER_ERR = s_packer_err_i[3*1+:1];
  assign S04_PACKER_ERR = s_packer_err_i[4*1+:1];
  assign S05_PACKER_ERR = s_packer_err_i[5*1+:1];
  assign S06_PACKER_ERR = s_packer_err_i[6*1+:1];
  assign S07_PACKER_ERR = s_packer_err_i[7*1+:1];
  assign S08_PACKER_ERR = s_packer_err_i[8*1+:1];
  assign S09_PACKER_ERR = s_packer_err_i[9*1+:1];
  assign S10_PACKER_ERR = s_packer_err_i[10*1+:1];
  assign S11_PACKER_ERR = s_packer_err_i[11*1+:1];
  assign S12_PACKER_ERR = s_packer_err_i[12*1+:1];
  assign S13_PACKER_ERR = s_packer_err_i[13*1+:1];
  assign S14_PACKER_ERR = s_packer_err_i[14*1+:1];
  assign S15_PACKER_ERR = s_packer_err_i[15*1+:1];
  assign S00_FIFO_DATA_COUNT[32-1:0] = s_fifo_data_count_i[0*32+:32];
  assign S01_FIFO_DATA_COUNT[32-1:0] = s_fifo_data_count_i[1*32+:32];
  assign S02_FIFO_DATA_COUNT[32-1:0] = s_fifo_data_count_i[2*32+:32];
  assign S03_FIFO_DATA_COUNT[32-1:0] = s_fifo_data_count_i[3*32+:32];
  assign S04_FIFO_DATA_COUNT[32-1:0] = s_fifo_data_count_i[4*32+:32];
  assign S05_FIFO_DATA_COUNT[32-1:0] = s_fifo_data_count_i[5*32+:32];
  assign S06_FIFO_DATA_COUNT[32-1:0] = s_fifo_data_count_i[6*32+:32];
  assign S07_FIFO_DATA_COUNT[32-1:0] = s_fifo_data_count_i[7*32+:32];
  assign S08_FIFO_DATA_COUNT[32-1:0] = s_fifo_data_count_i[8*32+:32];
  assign S09_FIFO_DATA_COUNT[32-1:0] = s_fifo_data_count_i[9*32+:32];
  assign S10_FIFO_DATA_COUNT[32-1:0] = s_fifo_data_count_i[10*32+:32];
  assign S11_FIFO_DATA_COUNT[32-1:0] = s_fifo_data_count_i[11*32+:32];
  assign S12_FIFO_DATA_COUNT[32-1:0] = s_fifo_data_count_i[12*32+:32];
  assign S13_FIFO_DATA_COUNT[32-1:0] = s_fifo_data_count_i[13*32+:32];
  assign S14_FIFO_DATA_COUNT[32-1:0] = s_fifo_data_count_i[14*32+:32];
  assign S15_FIFO_DATA_COUNT[32-1:0] = s_fifo_data_count_i[15*32+:32];
  assign M00_SPARSE_TKEEP_REMOVED = m_sparse_tkeep_removed_i[0*1+:1];
  assign M01_SPARSE_TKEEP_REMOVED = m_sparse_tkeep_removed_i[1*1+:1];
  assign M02_SPARSE_TKEEP_REMOVED = m_sparse_tkeep_removed_i[2*1+:1];
  assign M03_SPARSE_TKEEP_REMOVED = m_sparse_tkeep_removed_i[3*1+:1];
  assign M04_SPARSE_TKEEP_REMOVED = m_sparse_tkeep_removed_i[4*1+:1];
  assign M05_SPARSE_TKEEP_REMOVED = m_sparse_tkeep_removed_i[5*1+:1];
  assign M06_SPARSE_TKEEP_REMOVED = m_sparse_tkeep_removed_i[6*1+:1];
  assign M07_SPARSE_TKEEP_REMOVED = m_sparse_tkeep_removed_i[7*1+:1];
  assign M08_SPARSE_TKEEP_REMOVED = m_sparse_tkeep_removed_i[8*1+:1];
  assign M09_SPARSE_TKEEP_REMOVED = m_sparse_tkeep_removed_i[9*1+:1];
  assign M10_SPARSE_TKEEP_REMOVED = m_sparse_tkeep_removed_i[10*1+:1];
  assign M11_SPARSE_TKEEP_REMOVED = m_sparse_tkeep_removed_i[11*1+:1];
  assign M12_SPARSE_TKEEP_REMOVED = m_sparse_tkeep_removed_i[12*1+:1];
  assign M13_SPARSE_TKEEP_REMOVED = m_sparse_tkeep_removed_i[13*1+:1];
  assign M14_SPARSE_TKEEP_REMOVED = m_sparse_tkeep_removed_i[14*1+:1];
  assign M15_SPARSE_TKEEP_REMOVED = m_sparse_tkeep_removed_i[15*1+:1];
  assign M00_PACKER_ERR = m_packer_err_i[0*1+:1];
  assign M01_PACKER_ERR = m_packer_err_i[1*1+:1];
  assign M02_PACKER_ERR = m_packer_err_i[2*1+:1];
  assign M03_PACKER_ERR = m_packer_err_i[3*1+:1];
  assign M04_PACKER_ERR = m_packer_err_i[4*1+:1];
  assign M05_PACKER_ERR = m_packer_err_i[5*1+:1];
  assign M06_PACKER_ERR = m_packer_err_i[6*1+:1];
  assign M07_PACKER_ERR = m_packer_err_i[7*1+:1];
  assign M08_PACKER_ERR = m_packer_err_i[8*1+:1];
  assign M09_PACKER_ERR = m_packer_err_i[9*1+:1];
  assign M10_PACKER_ERR = m_packer_err_i[10*1+:1];
  assign M11_PACKER_ERR = m_packer_err_i[11*1+:1];
  assign M12_PACKER_ERR = m_packer_err_i[12*1+:1];
  assign M13_PACKER_ERR = m_packer_err_i[13*1+:1];
  assign M14_PACKER_ERR = m_packer_err_i[14*1+:1];
  assign M15_PACKER_ERR = m_packer_err_i[15*1+:1];
  assign M00_FIFO_DATA_COUNT[32-1:0] = m_fifo_data_count_i[0*32+:32];
  assign M01_FIFO_DATA_COUNT[32-1:0] = m_fifo_data_count_i[1*32+:32];
  assign M02_FIFO_DATA_COUNT[32-1:0] = m_fifo_data_count_i[2*32+:32];
  assign M03_FIFO_DATA_COUNT[32-1:0] = m_fifo_data_count_i[3*32+:32];
  assign M04_FIFO_DATA_COUNT[32-1:0] = m_fifo_data_count_i[4*32+:32];
  assign M05_FIFO_DATA_COUNT[32-1:0] = m_fifo_data_count_i[5*32+:32];
  assign M06_FIFO_DATA_COUNT[32-1:0] = m_fifo_data_count_i[6*32+:32];
  assign M07_FIFO_DATA_COUNT[32-1:0] = m_fifo_data_count_i[7*32+:32];
  assign M08_FIFO_DATA_COUNT[32-1:0] = m_fifo_data_count_i[8*32+:32];
  assign M09_FIFO_DATA_COUNT[32-1:0] = m_fifo_data_count_i[9*32+:32];
  assign M10_FIFO_DATA_COUNT[32-1:0] = m_fifo_data_count_i[10*32+:32];
  assign M11_FIFO_DATA_COUNT[32-1:0] = m_fifo_data_count_i[11*32+:32];
  assign M12_FIFO_DATA_COUNT[32-1:0] = m_fifo_data_count_i[12*32+:32];
  assign M13_FIFO_DATA_COUNT[32-1:0] = m_fifo_data_count_i[13*32+:32];
  assign M14_FIFO_DATA_COUNT[32-1:0] = m_fifo_data_count_i[14*32+:32];
  assign M15_FIFO_DATA_COUNT[32-1:0] = m_fifo_data_count_i[15*32+:32];

axis_interconnect_v1_1_axis_interconnect #(
  .C_FAMILY ( C_FAMILY ),
  .C_NUM_MI_SLOTS ( C_NUM_MI_SLOTS ),
  .C_NUM_SI_SLOTS ( C_NUM_SI_SLOTS ),
  .C_AXIS_TDATA_MAX_WIDTH ( C_AXIS_TDATA_MAX_WIDTH ),
  .C_AXIS_TUSER_MAX_WIDTH ( C_AXIS_TUSER_MAX_WIDTH ),
  .C_SWITCH_MI_REG_CONFIG ( C_SWITCH_MI_REG_CONFIG ),
  .C_SWITCH_SI_REG_CONFIG ( C_SWITCH_SI_REG_CONFIG ),
  .C_SWITCH_MODE ( C_SWITCH_MODE ),
  .C_SWITCH_MAX_XFERS_PER_ARB ( C_SWITCH_MAX_XFERS_PER_ARB ),
  .C_SWITCH_NUM_CYCLES_TIMEOUT ( C_SWITCH_NUM_CYCLES_TIMEOUT ),
  .C_SWITCH_TDATA_WIDTH ( C_SWITCH_TDATA_WIDTH ),
  .C_SWITCH_TID_WIDTH ( C_SWITCH_TID_WIDTH ),
  .C_SWITCH_TDEST_WIDTH ( C_SWITCH_TDEST_WIDTH ),
  .C_SWITCH_TUSER_WIDTH ( C_SWITCH_TUSER_WIDTH ),
  .C_SWITCH_SIGNAL_SET ( C_SWITCH_SIGNAL_SET[31:0] ),
  .C_SWITCH_ACLK_RATIO ( C_SWITCH_ACLK_RATIO ),
  .C_SWITCH_USE_ACLKEN ( C_SWITCH_USE_ACLKEN ),
  .C_M_AXIS_CONNECTIVITY_ARRAY ( P_M_AXIS_CONNECTIVITY_ARRAY[C_NUM_MI_SLOTS*C_NUM_SI_SLOTS-1:0] ),
  .C_M_AXIS_BASETDEST_ARRAY ( P_M_AXIS_BASETDEST_ARRAY[C_NUM_MI_SLOTS*C_SWITCH_TDEST_WIDTH-1:0] ),
  .C_M_AXIS_HIGHTDEST_ARRAY ( P_M_AXIS_HIGHTDEST_ARRAY[C_NUM_MI_SLOTS*C_SWITCH_TDEST_WIDTH-1:0] ),
  .C_S_AXIS_TDATA_WIDTH_ARRAY ( P_S_AXIS_TDATA_WIDTH_ARRAY[C_NUM_SI_SLOTS*32-1:0] ),
  .C_S_AXIS_TUSER_WIDTH_ARRAY ( P_S_AXIS_TUSER_WIDTH_ARRAY[C_NUM_SI_SLOTS*32-1:0] ),
  .C_S_AXIS_IS_ACLK_ASYNC_ARRAY ( P_S_AXIS_IS_ACLK_ASYNC_ARRAY[C_NUM_SI_SLOTS*32-1:0] ),
  .C_S_AXIS_ACLK_RATIO_ARRAY ( P_S_AXIS_ACLK_RATIO_ARRAY[C_NUM_SI_SLOTS*32-1:0] ),
  .C_S_AXIS_REG_CONFIG_ARRAY ( P_S_AXIS_REG_CONFIG_ARRAY[C_NUM_SI_SLOTS*32-1:0] ),
  .C_S_AXIS_FIFO_DEPTH_ARRAY ( P_S_AXIS_FIFO_DEPTH_ARRAY[C_NUM_SI_SLOTS*32-1:0] ),
  .C_S_AXIS_FIFO_MODE_ARRAY ( P_S_AXIS_FIFO_MODE_ARRAY[C_NUM_SI_SLOTS*32-1:0] ),
  .C_M_AXIS_TDATA_WIDTH_ARRAY ( P_M_AXIS_TDATA_WIDTH_ARRAY[C_NUM_MI_SLOTS*32-1:0] ),
  .C_M_AXIS_TUSER_WIDTH_ARRAY ( P_M_AXIS_TUSER_WIDTH_ARRAY[C_NUM_MI_SLOTS*32-1:0] ),
  .C_M_AXIS_ACLK_RATIO_ARRAY ( P_M_AXIS_ACLK_RATIO_ARRAY[C_NUM_MI_SLOTS*32-1:0] ),
  .C_M_AXIS_REG_CONFIG_ARRAY ( P_M_AXIS_REG_CONFIG_ARRAY[C_NUM_MI_SLOTS*32-1:0] ),
  .C_M_AXIS_IS_ACLK_ASYNC_ARRAY ( P_M_AXIS_IS_ACLK_ASYNC_ARRAY[C_NUM_MI_SLOTS*32-1:0] ),
  .C_M_AXIS_FIFO_DEPTH_ARRAY ( P_M_AXIS_FIFO_DEPTH_ARRAY[C_NUM_MI_SLOTS*32-1:0] ),
  .C_M_AXIS_FIFO_MODE_ARRAY ( P_M_AXIS_FIFO_MODE_ARRAY[C_NUM_MI_SLOTS*32-1:0] )
)
axis_interconnect_0 (
  .ACLK ( ACLK ),
  .ARESETN ( ARESETN ),
  .ACLKEN ( ACLKEN ),
  .S_AXIS_ACLK ( s_axis_aclk_i[C_NUM_SI_SLOTS*1-1:0] ),
  .S_AXIS_ARESETN ( s_axis_aresetn_i[C_NUM_SI_SLOTS*1-1:0] ),
  .S_AXIS_ACLKEN ( s_axis_aclken_i[C_NUM_SI_SLOTS*1-1:0] ),
  .S_AXIS_TVALID ( s_axis_tvalid_i[C_NUM_SI_SLOTS*1-1:0] ),
  .S_AXIS_TREADY ( s_axis_tready_i[C_NUM_SI_SLOTS*1-1:0] ),
  .S_AXIS_TDATA ( s_axis_tdata_i[C_NUM_SI_SLOTS*C_AXIS_TDATA_MAX_WIDTH-1:0] ),
  .S_AXIS_TSTRB ( s_axis_tstrb_i[C_NUM_SI_SLOTS*C_AXIS_TDATA_MAX_WIDTH/8-1:0] ),
  .S_AXIS_TKEEP ( s_axis_tkeep_i[C_NUM_SI_SLOTS*C_AXIS_TDATA_MAX_WIDTH/8-1:0] ),
  .S_AXIS_TLAST ( s_axis_tlast_i[C_NUM_SI_SLOTS*1-1:0] ),
  .S_AXIS_TID ( s_axis_tid_i[C_NUM_SI_SLOTS*C_SWITCH_TID_WIDTH-1:0] ),
  .S_AXIS_TDEST ( s_axis_tdest_i[C_NUM_SI_SLOTS*C_SWITCH_TDEST_WIDTH-1:0] ),
  .S_AXIS_TUSER ( s_axis_tuser_i[C_NUM_SI_SLOTS*C_AXIS_TUSER_MAX_WIDTH-1:0] ),
  .M_AXIS_ACLK ( m_axis_aclk_i[C_NUM_MI_SLOTS*1-1:0] ),
  .M_AXIS_ARESETN ( m_axis_aresetn_i[C_NUM_MI_SLOTS*1-1:0] ),
  .M_AXIS_ACLKEN ( m_axis_aclken_i[C_NUM_MI_SLOTS*1-1:0] ),
  .M_AXIS_TVALID ( m_axis_tvalid_i[C_NUM_MI_SLOTS*1-1:0] ),
  .M_AXIS_TREADY ( m_axis_tready_i[C_NUM_MI_SLOTS*1-1:0] ),
  .M_AXIS_TDATA ( m_axis_tdata_i[C_NUM_MI_SLOTS*C_AXIS_TDATA_MAX_WIDTH-1:0] ),
  .M_AXIS_TSTRB ( m_axis_tstrb_i[C_NUM_MI_SLOTS*C_AXIS_TDATA_MAX_WIDTH/8-1:0] ),
  .M_AXIS_TKEEP ( m_axis_tkeep_i[C_NUM_MI_SLOTS*C_AXIS_TDATA_MAX_WIDTH/8-1:0] ),
  .M_AXIS_TLAST ( m_axis_tlast_i[C_NUM_MI_SLOTS*1-1:0] ),
  .M_AXIS_TID ( m_axis_tid_i[C_NUM_MI_SLOTS*C_SWITCH_TID_WIDTH-1:0] ),
  .M_AXIS_TDEST ( m_axis_tdest_i[C_NUM_MI_SLOTS*C_SWITCH_TDEST_WIDTH-1:0] ),
  .M_AXIS_TUSER ( m_axis_tuser_i[C_NUM_MI_SLOTS*C_AXIS_TUSER_MAX_WIDTH-1:0] ),
  .S_ARB_REQ_SUPPRESS ( s_arb_req_suppress_i[C_NUM_SI_SLOTS*1-1:0] ),
  .S_DECODE_ERR ( s_decode_err_i[C_NUM_SI_SLOTS*1-1:0] ),
  .S_SPARSE_TKEEP_REMOVED ( s_sparse_tkeep_removed_i[C_NUM_SI_SLOTS*1-1:0] ),
  .S_PACKER_ERR ( s_packer_err_i[C_NUM_SI_SLOTS*1-1:0] ),
  .S_FIFO_DATA_COUNT ( s_fifo_data_count_i[C_NUM_SI_SLOTS*32-1:0] ),
  .M_SPARSE_TKEEP_REMOVED ( m_sparse_tkeep_removed_i[C_NUM_MI_SLOTS*1-1:0] ),
  .M_PACKER_ERR ( m_packer_err_i[C_NUM_MI_SLOTS*1-1:0] ),
  .M_FIFO_DATA_COUNT ( m_fifo_data_count_i[C_NUM_MI_SLOTS*32-1:0] )
);
endmodule // axis_interconnect_16x16_top
`default_nettype wire
