-------------------------------------------------------------------------------
--
-- (c) Copyright 2010-2011 Xilinx, Inc. All rights reserved.
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
-------------------------------------------------------------------------------
-- Project    : Series-7 Integrated Block for PCI Express
-- File       : pcie_core_fast_cfg_init_cntr.vhd
-- Version    : 1.3
--
-- Description:  PCIe Fast Configuration Init Counter
--
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pcie_core_fast_cfg_init_cntr is
  generic (
    PATTERN_WIDTH : integer                      := 8;
    INIT_PATTERN  : std_logic_vector(7 downto 0) := X"A5";
    TCQ           : time                         := 1 ns
  );
  port (
    clk                      : in std_logic;
    rst                      : in std_logic;
  
    pattern_o                : out std_logic_vector(PATTERN_WIDTH-1 downto 0)
  );

end pcie_core_fast_cfg_init_cntr;

architecture rtl of pcie_core_fast_cfg_init_cntr is

  signal pattern_o_int : std_logic_vector(PATTERN_WIDTH-1 downto 0);

  begin
  
    -----------------------------------------------
    --  Implement counter
    -----------------------------------------------
    process(clk)
    begin

      if rising_edge(clk) then
        if rst = '1' then
          pattern_o_int <= (others => '0');
        elsif pattern_o_int /= INIT_PATTERN then
          pattern_o_int <= std_logic_vector(unsigned(pattern_o_int) + 1) after TCQ;
        end if;
      end if;
    end process;

    pattern_o <= pattern_o_int;

end rtl;
