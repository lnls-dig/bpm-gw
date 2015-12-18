-------------------------------------------------------------------------------
-- Title      : Transmitter firmware for the test_trigger
-- Project    :
-------------------------------------------------------------------------------
-- File       : test_trigger_transm.vhd
-- Author     : Vitor Finotti Ferreira  <vfinotti@finotti-Inspiron-7520>
-- Company    : Brazilian Synchrotron Light Laboratory, LNLS/CNPEM
-- Created    : 2015-12-09
-- Last update: 2015-12-17
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
    sys_clk_p_i : in  std_logic;
    sys_clk_n_i : in  std_logic;
    trigger_o   : out std_logic_vector(7 downto 0);
    direction_o : out std_logic_vector(7 downto 0));

end entity test_trigger_transm;

architecture structure of test_trigger_transm is

  constant c_glitch_len_width : positive := 8;
  constant c_count_width      : positive := 32;

  signal direction   : std_logic_vector(7 downto 0);
  signal length      : std_logic_vector(c_glitch_len_width-1 downto 0);
  signal trigger_buf : std_logic_vector(7 downto 0);
  signal pulse       : std_logic_vector(7 downto 0);

  type count_array is array(7 downto 0) of std_logic_vector(c_count_width-1 downto 0);
  signal count_sent : count_array;

  constant filler : std_logic_vector(31 downto 0) := (others => '0');

  component sm_transm is
    generic (
      g_num_pins   : natural;
      g_max_period : natural);
    port (
      clk_i              : in  std_logic;
      rst_n_i            : in  std_logic;
      cycles_to_change_i : in  natural;
      pulse_o            : out std_logic_vector(g_num_pins-1 downto 0));
  end component sm_transm;

  component counter_simple is
    generic (
      g_output_width : positive);
    port (
      clk_i   : in  std_logic;
      rst_n_i : in  std_logic;
      ce_i    : in  std_logic;
      up_i    : in  std_logic;
      down_i  : in  std_logic;
      count_o : out std_logic_vector(g_output_width-1 downto 0));
  end component counter;

-------------------------------------------------------------------------------
-- Chipscope
-------------------------------------------------------------------------------

  signal CONTROL0, CONTROL1, CONTROL2, CONTROL3 : std_logic_vector(35 downto 0);

  component chipscope_icon_4_port is
    port (
      CONTROL0 : inout std_logic_vector(35 downto 0);
      CONTROL1 : inout std_logic_vector(35 downto 0);
      CONTROL2 : inout std_logic_vector(35 downto 0);
      CONTROL3 : inout std_logic_vector(35 downto 0)
      );
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

  component chipscope_vio_32 is
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
  signal rst_n                  : std_logic;

begin  -- architecture behav

  trigger_o <= pulse;

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
      g_num_pins   => c_glitch_len_width,
      g_max_period => 10000)
    port map (
      clk_i              => clk_100mhz,
      rst_n_i            => rst_n,
      cycles_to_change_i => to_integer(unsigned(length)),
      pulse_o            => pulse);

  generate_counter : for i in c_glitch_len_width-1 downto 0 generate

    counter_simplei : counter_simple
      generic map (
        g_output_width => c_count_width)
      port map (
        clk_i   => clk_100mhz,
        rst_n_i => rst_n,
        ce_i    => '1',
        up_i    => pulse(i),
        down_i  => '0',
        count_o => count_sent(i));

  end generate generate_counter;

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
      locked_o => rst_n                 -- '1' when the PLL has locked
      );

  cmp_chipscope_icon_4_port : chipscope_icon_4_port
    port map (
      CONTROL0 => CONTROL0,
      CONTROL1 => CONTROL1,
      CONTROL2 => CONTROL2,
      CONTROL3 => CONTROL3);

  cmp_chipscope_ila_0 : entity work.chipscope_ila
    port map (
      CONTROL            => CONTROL0,
      CLK                => clk_100mhz,
      TRIG0(7 downto 0)  => pulse,
      TRIG0(8)           => clk_100mhz,
      TRIG0(31 downto 9) => filler(31 downto 9),
      TRIG1              => filler,
      TRIG2              => filler,
      TRIG3              => filler);
  cmp_chipscope_ila_2 : entity work.chipscope_ila
    port map (
      CONTROL => CONTROL2,
      CLK     => clk_100mhz,
      TRIG0   => filler,
      TRIG1   => filler,
      TRIG2   => filler,
      TRIG3   => filler);
  cmp_chipscope_ila_3 : entity work.chipscope_ila
    port map (
      CONTROL => CONTROL3,
      CLK     => clk_100mhz,
      TRIG0   => filler,
      TRIG1   => filler,
      TRIG2   => filler,
      TRIG3   => filler);

  cmp_chipscope_vio : entity work.chipscope_vio_32
    port map (
      CONTROL                => CONTROL1,
      CLK                    => clk_100mhz,
      SYNC_OUT(7 downto 0)   => length,
      SYNC_OUT(15 downto 8)  => open,
      SYNC_OUT(31 downto 16) => open);


end architecture structure;
