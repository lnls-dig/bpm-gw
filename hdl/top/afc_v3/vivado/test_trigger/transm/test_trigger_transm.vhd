-------------------------------------------------------------------------------
-- Title      : Transmitter firmware for the test_trigger
-- Project    :
-------------------------------------------------------------------------------
-- File       : test_trigger_transm.vhd
-- Author     : Vitor Finotti Ferreira  <vfinotti@finotti-Inspiron-7520>
-- Company    : Brazilian Synchrotron Light Laboratory, LNLS/CNPEM
-- Created    : 2015-12-09
-- Last update: 2015-12-09
-- Platform   :
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
-------------------------------------------------------------------------------
-- Copyright (c) 2015 Brazilian Synchrotron Light Laboratory, LNLS/CNPEM

-- This program is free software: you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public License
-- as published by the Free Software Foundation, either version 3 of
-- the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-- Lesser General Public License for more details.
--
-- You should have received a copy of the GNU Lesser General Public
-- License along with this program. If not, see
-- <http://www.gnu.org/licenses/>.
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2015-12-09  1.0      vfinotti        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity test_trigger_transm is

  port (
    sys_clk_p_i : in std_logic;
    sys_clk_n_i : in std_logic;
    trigger_o   : in std_logic_vector(7 downto 0));

end entity test_trigger_transm;

architecture structure of test_trigger_transm is

  constant c_glitch_len_width : positive := 8;
  constant c_count_width      : positive := 32;

  signal direction   : std_logic_vector(7 downto 0);
  signal length      : std_logic_vector(c_glitch_len_width-1 downto 0);
  signal trigger_buf : std_logic_vector(7 downto 0);
  signal pulse       : std_logic_vector(7 downto 0);

  constant filler : std_logic_vector(31 downto 0) := (others => '0');

  component sm_transm is
    generic (
      g_num_pins         : natural;
      g_cycles_to_change : natural);
    port (
      clk_i   : in  std_logic;
      rst_n_i : in  std_logic;
      pulse_o : out std_logic_vector(g_num_pins-1 downto 0));
  end component sm_transm;

-------------------------------------------------------------------------------
-- Chipscope
-------------------------------------------------------------------------------

  signal CONTROL0, CONTROL1 : std_logic_vector(35 downto 0);

  component chipscope_icon_4_port is
    port (
      CONTROL0 : inout std_logic_vector(35 downto 0);
      CONTROL1 : inout std_logic_vector(35 downto 0);
      CONTROL2 : inout std_logic_vector(35 downto 0);
      CONTROL3 : inout std_logic_vector(35 downto 0));
  end component chipscope_icon_4_port;

  component chipscope_ila is
    port (
      CONTROL : inout std_logic_vector(35 downto 0);
      CLK     : in    std_logic;
      TRIG0   : in    std_logic_vector(31 downto 0);
      TRIG1   : in    std_logic_vector(31 downto 0);
      TRIG2   : in    std_logic_vector(31 downto 0);
      TRIG3   : in    std_logic_vector(31 downto 0));
  end component chipscope_ila;

  component chipscope_vio_31 is
    port (
      CONTROL  : inout std_logic_vector(35 downto 0);
      CLK      : in    std_logic;
      SYNC_OUT : out   std_logic_vector(31 downto 0));
  end component chipscope_vio_32;

  -----------------------------------------------------------------------------
  -- Clock and system
  -----------------------------------------------------------------------------

  component clk_gen is
    port (
      sys_clk_p_i    : in  std_logic;
      sys_clk_n_i    : in  std_logic;
      sys_clk_o      : out std_logic;
      sys_clk_bufg_o : out std_logic);
  end component clk_gen;

  component sys_pll is
    generic (
      g_clkin_period   : real;
      g_divclk_divide  : integer;
      g_clkbout_mult_f : integer;
      g_clk0_divide_f  : integer;
      g_clk1_divide    : integer);
    port (
      rst_i    : in  std_logic := '0';
      clk_i    : in  std_logic := '0';
      clk0_o   : out std_logic;
      clk1_o   : out std_logic;
      locked_o : out std_logic);
  end component sys_pll;

  -- Global Clock Single ended
  signal clk_100mhz, clk_200mhz : std_logic;
  signal sys_clk_gen_bufg       : std_logic;
  signal locked                 : std_logic;
  signal rst                    : std_logic;

begin  -- architecture behav

  -- Clock generation
  cmp_clk_gen : clk_gen
    port map (
      sys_clk_p_i    => sys_clk_p_i,
      sys_clk_n_i    => sys_clk_n_i,
      sys_clk_o      => open,
      sys_clk_bufg_o => sys_clk_gen_bufg
      );

  sm_transm_1 : sm_transm
    generic map (
      g_num_pins         => c_glitch_len_width,
      g_cycles_to_change => 10)
    port map (
      clk_i   => clk_100mhz,
      rst_n_i => rst_n_i,
      pulse_o => trigger_o);

  -- Obtain core locking and generate necessary clocks
  cmp_sys_pll_inst : sys_pll
    generic map (
      -- 125 MHz input clock
      g_clkin_period   => 8.000,
      g_divclk_divide  => 5,
      g_clkbout_mult_f => 32,

      -- 100 MHz output clock
      g_clk0_divide_f => 8,
      -- 200 MHz output clock
      g_clk1_divide   => 4
      )
    port map (
      rst_i    => '0',
      clk_i    => sys_clk_gen_bufg,
      clk0_o   => clk_100mhz,           -- 100MHz locked clock
      clk1_o   => clk_200mhz,           -- 200MHz locked clock
      locked_o => rst                   -- '1' when the PLL has locked
      );

  cmp_chipscope_icon_4_port : chipscope_icon_4_port
    port map (
      CONTROL0 => CONTROL0,
      CONTROL1 => CONTROL1);

  cmp_chipscope_ila_0 : entity work.chipscope_ila
    port map (
      CONTROL            => CONTROL0,
      CLK                => clk_100mhz,
      TRIG0(7 downto 0)  => trigger_o,
      TRIG0(31 downto 8) => filler(31 downto 8),
      TRIG1              => filler,
      TRIG2              => filler,
      TRIG3              => filler);

  cmp_chipscope_vio : entity work.chipscope_vio_32
    port map (
      CONTROL                => CONTROL1,
      CLK                    => clk_100mhz,
      SYNC_OUT(7 downto 0)   => length,
      SYNC_OUT(15 downto 8)  => direction,
      SYNC_OUT(31 downto 16) => open);

end architecture structure;
