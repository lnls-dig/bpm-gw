--*****************************************************************************
-- (c) Copyright 2009 - 2010 Xilinx, Inc. All rights reserved.
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
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version:3.92
--  \   \         Application: MIG
--  /   /         Filename: clk_ibuf.vhd
-- /___/   /\     Date Last Modified: $Date: 2011/06/02 07:18:11 $
-- \   \  /  \    Date Created:Mon Aug 3 2009
--  \___\/\___\
--
--Device: Virtex-6
--Design Name: DDR3 SDRAM
--Purpose:
--   Clock generation/distribution and reset synchronization
--Reference:
--Revision History:
--*****************************************************************************
library ieee;
library unisim;
use ieee.std_logic_1164.all;
use unisim.vcomponents.all;

entity clk_ibuf is
  generic(
    INPUT_CLK_TYPE : string := "DIFFERENTIAL"
    );
  port(
    -- Clock inputs
    sys_clk_p : in  std_logic; -- System clock diff input
    sys_clk_n : in  std_logic;
    sys_clk   : in  std_logic;
    mmcm_clk  : out std_logic
    );
end entity clk_ibuf;

architecture arch_clk_ibuf of clk_ibuf is

  signal sys_clk_ibufg : std_logic;

  attribute keep : string;
  attribute keep of sys_clk_ibufg : signal is "TRUE";

begin

  diff_input_clk : if(INPUT_CLK_TYPE = "DIFFERENTIAL") generate
    --***********************************************************************
    -- Differential input clock input buffers
    --***********************************************************************
    u_ibufg_sys_clk : IBUFGDS
      generic map(
        DIFF_TERM    => TRUE,
        IBUF_LOW_PWR => FALSE
        )
      port map(
        I  => sys_clk_p,
        IB => sys_clk_n,
        O  => sys_clk_ibufg
        );
  end generate diff_input_clk;

  se_input_clk : if(INPUT_CLK_TYPE = "SINGLE_ENDED") generate
    --***********************************************************************
    -- SINGLE_ENDED input clock input buffers
    --***********************************************************************
--    u_ibufg_sys_clk : IBUFG
--      generic map(
--        IBUF_LOW_PWR => FALSE
--        )
--      port map(
--        I => sys_clk,
--        O => sys_clk_ibufg
--        );
    sys_clk_ibufg <= sys_clk;
  end generate se_input_clk;

  mmcm_clk <= sys_clk_ibufg;

end arch_clk_ibuf;
