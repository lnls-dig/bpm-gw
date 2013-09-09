--*****************************************************************************
-- (c) Copyright 2008-2009 Xilinx, Inc. All rights reserved.
--
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
--
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
--
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
--
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
--
--*****************************************************************************
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor                : Xilinx
-- \   \   \/     Version               : 3.92
--  \   \         Application           : MIG
--  /   /         Filename              : chipscope.vhd
-- /___/   /\     Date Last Modified    : $date$
-- \   \  /  \    Date Created          : Aug 07 2009
--  \___\/\___\
--
--Device            : Virtex-6
--Design Name       : DDR2/3 SDRAM
--Purpose           : Chipscope cores declarations used if debug option is
--                    enabled in MIG when generating design. These are
--                    empty declarations to allow compilation to pass both in
--                    simulation and synthesis. The proper .ngc files must be
--                    referenced during the actual ISE build.
--Reference         :
--Revision History  :
--*****************************************************************************
library ieee;
use ieee.std_logic_1164.all;

package ddr2_ddr3_chipscope is

component icon5
  port(
    CONTROL0 : inout std_logic_vector(35 downto 0);
    CONTROL1 : inout std_logic_vector(35 downto 0);
    CONTROL2 : inout std_logic_vector(35 downto 0);
    CONTROL3 : inout std_logic_vector(35 downto 0);
    CONTROL4 : inout std_logic_vector(35 downto 0)
    );
end component icon5;

component ila384_8
  port(
    CLK     : in    std_logic;
    DATA    : in    std_logic_vector(383 downto 0);
    TRIG0   : in    std_logic_vector(7 downto 0);
    CONTROL : inout std_logic_vector(35 downto 0)
    );
end component ila384_8;

component vio_async_in256
  port(
    ASYNC_IN : in    std_logic_vector(255 downto 0);
    CONTROL  : inout std_logic_vector(35 downto 0)
    );
end component vio_async_in256;

component vio_sync_out32
  port(
    SYNC_OUT : out   std_logic_vector(31 downto 0);
    CLK      : in    std_logic;
    CONTROL  : inout std_logic_vector(35 downto 0)
    );
end component vio_sync_out32;

  attribute syn_noprune   : boolean;
  attribute syn_black_box : boolean;

  attribute syn_noprune of icon5             : component is TRUE;
  attribute syn_black_box of icon5           : component is TRUE;
  attribute syn_noprune of ila384_8          : component is TRUE;
  attribute syn_black_box of ila384_8        : component is TRUE;
  attribute syn_noprune of vio_async_in256   : component is TRUE;
  attribute syn_black_box of vio_async_in256 : component is TRUE;
  attribute syn_noprune of vio_sync_out32    : component is TRUE;
  attribute syn_black_box of vio_sync_out32  : component is TRUE;

end package ddr2_ddr3_chipscope;
