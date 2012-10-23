------------------------------------------------------------------------------
-- Title      : Minicircuits Serial Controller Testbench
------------------------------------------------------------------------------
-- Author     : Daniel de Oliveira Tavares
-- Company    : CNPEM LNLS-DIG
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: Simulation of mc_serial_ctrl with 100101 as data_i
--              and g_clkdiv = 17 as divider of clk_i.
-------------------------------------------------------------------------------
-- Copyright (c) 2012 CNPEM
-- Licensed under GNU Lesser General Public License (LGPL) v3.0
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author                Description
-- 2012-01-12  1.0      daniel.tavares        Created
-- 2012-10-16  1.1      jose.berkenbrock      Names Adpated 
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
 
entity mc_serial_ctrl_tb is
end mc_serial_ctrl_tb;
 
architecture behavior of mc_serial_ctrl_tb is 
 
    -- component Declaration for the Unit Under Test (UUT)
    component mc_serial_ctrl
    generic(
        g_nbits : natural := 6;
        g_clkdiv : natural := 128
    );
    port(
        clk_i : in  std_logic;
        trg_i : in  std_logic;
        data_i : in  std_logic_vector(5 downto 0);
        clk_o : out  std_logic;
        data_o : out  std_logic;
        le_o : out  std_logic
        );
    end component;

   --inputs
   signal clk_i     : std_logic := '0';
   signal trg_i     : std_logic := '0';
   signal data_i    : std_logic_vector(5 downto 0) := (others => '0');

  --outputs
   signal clk_o : std_logic;
   signal data_o : std_logic;
   signal le_o : std_logic;

   -- Clock period definitions
   constant clk_i_period : time := 8 ns;
 
   begin
  -- instantiate the Unit Under Test (UUT)
   uut: mc_serial_ctrl
   generic map (
        g_clkdiv => 17
   )
   port map (
        clk_i => clk_i,
        trg_i => trg_i,
        data_i => data_i,
        clk_o => clk_o,
        data_o => data_o,
        le_o => le_o
        );

   -- Clock process definitions
   p_clk_i :process
   begin
    clk_i <= '0';
    wait for clk_i_period/2;
    clk_i <= '1';
    wait for clk_i_period/2;
   end process;

   -- Stimulus process
   p_stim: process
   begin
      -- hold reset state for 100 ns.
      wait for 100 ns;

      wait for clk_i_period*10;

      -- insert stimulus here 
      trg_i <= '1';
      data_i <= "100101";
      wait for clk_i_period;
      trg_i <= '0';
      
      wait;
   end process;

end;
