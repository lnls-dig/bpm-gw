------------------------------------------------------------------------------
-- Title      : RF channels Swapping Testbench
------------------------------------------------------------------------------
-- Author     : José Alvim Berkenbrock
-- Company    : CNPEM LNLS-DIG
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: Simulation of rf_ch_swap desing behavior.
--
-------------------------------------------------------------------------------
-- Copyright (c) 2012 CNPEM
-- Licensed under GNU Lesser General Public License (LGPL) v3.0
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author                Description
-- 2012-10-18  1.0      jose.berkenbrock      Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity rf_ch_swap_tb is
end rf_ch_swap_tb;

architecture behavior of rf_ch_swap_tb is

    -- component Declaration for the Unit Under Test (UUT)
  component rf_ch_swap
    generic(
    g_direct   : std_logic_vector(7 downto 0) := "10100101";
    g_inverted : std_logic_vector(7 downto 0) := "01011010");
    port(
        clk_i     :   in   std_logic;
        rst_i     :   in   std_logic;
        en_swap_i :   in   std_logic;
        mode_i    :   in   std_logic_vector(1 downto 0);
        ctrl_o    :   out  std_logic_vector(7 downto 0));
    end component;

   --inputs
   signal clk_i     : std_logic := '0';
   signal rst_i     : std_logic := '0';
   signal en_swap_i   : std_logic := '0';
   signal mode_i    : std_logic_vector(1 downto 0) := (others => '0');

   --outputs
   signal ctrl_o    : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 8  ns;
   constant en_period  : time := 80 ns;

   begin
   -- instantiate the Unit Under Test (UUT)
   uut: rf_ch_swap
   port map (
        clk_i   => clk_i,
        rst_i   => rst_i,
        en_swap_i => en_swap_i,
        mode_i  => mode_i,
        ctrl_o  => ctrl_o
        );

   -- Clock process definitions
   p_clock :process
   begin
    clk_i <= '1';
    wait for clk_period/2;
    clk_i <= '0';
    wait for clk_period/2;
   end process;

   p_enable :process
   begin
    en_swap_i <= '1';
    wait for en_period/2;
    en_swap_i <= '0';
    wait for en_period/2;
   end process;

   -- Stimulus process
   p_stim: process
   begin
      -- hold reset state for 16 ns.
      rst_i <= '1';
      wait for clk_period*2;
      rst_i <= '0';
      wait for clk_period*14;

      -- insert stimulus here 
      rst_i <= '0';
      mode_i <= "11";
      wait for clk_period*44;

      -- Another reset period
      rst_i <= '1';
      wait for clk_period*20;

      -- insert stimulus here
      rst_i <= '0';
      mode_i <= "11";
      wait for clk_period*22;
      mode_i <= "01";
      wait for clk_period*30;

      mode_i <= "11";
      wait for clk_period*22;
      -- Another reset period
      rst_i <= '1';
      wait for clk_period*14;

      -- insert stimulus here
      rst_i <= '0';
      wait for clk_period*44;
      mode_i <= "10";
      wait for clk_period*5;

      wait;
   end process;

end;