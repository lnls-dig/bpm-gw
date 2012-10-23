------------------------------------------------------------------------------
-- Title      : RF channels Swapping
------------------------------------------------------------------------------
-- Author     : José Alvim Berkenbrock
-- Company    : CNPEM LNLS-DIG
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: This core controls the swapping mechanism for ONE pair of 
--              channels. It is possible swapping channels inputs @ clk_in_ext 
--              frequency or stay fixed at direct/inverted/off position.
--
--              MODE: 00 turned off 01 direct 10 inverted 11 Swapping
--
--              CTRL: b1b0d1d0
--              This core was developed to Sirus Synchrotron Light Source. 
--              The BPM RFFE uses HSWA2-30DR+ switches and are controlled by
--              arrangement of bits in CTRL.
-------------------------------------------------------------------------------
-- Copyright (c) 2012 CNPEM
-- Licensed under GNU Lesser General Public License (LGPL) v3.0
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author                Description
-- 2012-10-18  1.0      jose.berkenbrock      Created 
-- 2012-10-20  1.1      daniel.tavares
-------------------------------------------------------------------------------
library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rf_ch_swap is
generic
(
    g_direct   : std_logic_vector(7 downto 0) := "10100101";
    g_inverted : std_logic_vector(7 downto 0) := "01011010"
);
port(
  clk_i     :    in std_logic;
  rst_i     :    in std_logic;
  en_swap_i :    in std_logic;
  mode_i    :    in std_logic_vector(1 downto 0);
  ctrl_o    :    out std_logic_vector(7 downto 0));
end rf_ch_swap;

architecture rtl of rf_ch_swap is

--signal s_mode     :    std_logic_vector(1 downto 0);
signal ctrl     :    std_logic_vector(7 downto 0);
--signal ctrl_aux :    std_logic_vector(7 downto 0);
--signal ctrl_old :    std_logic_vector(7 downto 0);
--signal s_bit      :    std_logic;

begin
--------------------------------
-- Input Register
--------------------------------
--  p_reg_mode : process(rst_i, clk_i)
--  begin
--    if rst_i = '1' then
--      s_mode <= (others => '0');
--    elsif rising_edge(clk_i) then
--      s_mode <= mode_i;
--    else s_mode <= s_mode;
--    end if;
--  end process p_reg_mode;
--------------------------------
-- Swapping Process
--------------------------------
  p_swap : process(clk_i,rst_i)
  begin
---------------------------------------------------------------
--    if rst_i = '1' then
--      s_bit <= '0';
--      ctrl_aux <= "10100101";
--      ctrl <= "10100101";
--    elsif rising_edge(clk_i) then
--      s_bit <= not s_bit;
--    else s_bit <= s_bit;
--    end if;

---------------------------------------------------------------
    if rst_i = '1' then
     --ctrl_old <= "10100101";             -- initialize in direct channels
     --s_bit <= '0';
       ctrl <= "00000000";
   elsif rising_edge(clk_i) then
     if mode_i = "11" then                 -- crossed Swapping
     --  ctrl <= not ctrl;
       if en_swap_i = '0' then
          ctrl <= g_direct;
       else 
          ctrl <= g_inverted;
       end if;
     elsif mode_i = "10" then              -- inverted
       ctrl <= g_inverted;
     elsif mode_i = "01" then              -- direct
       ctrl <= g_direct;
     else
       ctrl <= (others=>'0');            -- Swapping off
     end if;
     --ctrl_old <= ctrl;
 end if;
--  ctrl <= "10100101" when s_bit = '1' else "01011010";
--  with s_bit select
--  ctrl <= "10100101" when '0',
--            "01011010" when others;
---------------------------------------------------------------
  end process p_swap;
  
---------------------------------------------------------------
--    with s_bit select
--    ctrl_aux <= "10100101" when '0',
--                  "01011010" when '1';
--                  ctrl_aux when others;
--
--    with s_mode select
--    ctrl <= "00000000" when "00",
--              "10100101" when "01",
--              "01011010" when "10",
--              ctrl_aux when "11";
--              ctrl when others;
--------------------------------
-- Output Register
--------------------------------
  p_reg_ctrl : process(rst_i, clk_i)
  begin
    if rst_i = '1' then
      ctrl_o <= (others => '0');            -- rst_i = 1 => Swapping off
--      ctrl_old <= "00000000"; 
    elsif rising_edge(clk_i) then
      ctrl_o <= ctrl;
--      ctrl_old <= ctrl;
    end if;
  end process p_reg_ctrl;

end rtl;