-------------------------------------------------------------------------------
-- Title      : Testbench for design "trigger_rcv"
-- Project    :
-------------------------------------------------------------------------------
-- File       : trigger_rcv_tb.vhd
-- Author     : Vitor Finotti Ferreira  <vfinotti@finotti-Inspiron-7520>
-- Company    : Brazilian Synchrotron Light Laboratory, LNLS/CNPEM
-- Created    : 2015-11-27
-- Last update: 2016-01-06
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
-- 2015-11-27  1.0      vfinotti        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library std;
use std.textio.all;

library work;
use work.gencores_pkg.all;

-------------------------------------------------------------------------------

entity trigger_rcv_tb is

end entity trigger_rcv_tb;

-------------------------------------------------------------------------------

architecture test of trigger_rcv_tb is

  -- component generics
  constant g_glitch_len_width : positive := 8;
  constant g_sync_edge        : string   := "positive";
  -- component ports
  signal s_clk     : std_logic                                       := '1';
  signal s_rst     : std_logic                                       := '1';
  signal s_len_i   : std_logic_vector(g_glitch_len_width-1 downto 0) := "01000001";
  signal s_data_i  : std_logic                                       := '0';
  signal s_pulse_o : std_logic;

  -- component declaration
  component trigger_rcv is
    generic (
      g_glitch_len_width : positive;
      g_sync_edge        : string);
    port (
      clk_i   : in  std_logic;
      rst_i   : in  std_logic;
      len_i   : in  std_logic_vector(g_glitch_len_width-1 downto 0);
      data_i  : in  std_logic;
      pulse_o : out std_logic);
  end component trigger_rcv;

  -----------------------------------------------------------------------------
  -- Test procedures
  -----------------------------------------------------------------------------

  procedure p_pwm_gen(
    signal clk           : in  std_ulogic;
    signal rst           : in  std_ulogic;
    signal pwm           : out std_ulogic;
    constant c_on_CYCLE  :     positive;
    constant c_off_CYCLE :     positive) is

    variable on_count  : natural := c_on_CYCLE;
    variable off_count : natural := c_off_CYCLE;

  begin

    loop

      wait until rising_edge(clk) and rst = '0';

      if on_count > 0 then
        on_count := on_count-1;
        pwm      <= '1';
      elsif off_count > 1 then
        off_count := off_count-1;
        pwm       <= '0';
      else
        on_count  := c_on_CYCLE;
        off_count := c_off_CYCLE;
        pwm       <= '0';
      end if;
    end loop;

  end procedure;


begin  -- architecture test

  -- signal generation
  p_pwm_gen(
    clk         => s_clk,
    rst         => s_rst,
    pwm         => s_data_i,
    c_on_CYCLE  => 50,
    c_off_CYCLE => 1550);

  -- component instantiation
  DUT : trigger_rcv
    generic map (
      g_glitch_len_width => g_glitch_len_width,
      g_sync_edge        => "positive")
    port map (
      clk_i   => s_clk,
      rst_i   => s_rst,
      len_i   => s_len_i,
      data_i  => s_data_i,
      pulse_o => s_pulse_o);

  -- clock generation
  s_clk <= not s_clk after 10 ns;

  -- reset generation
  s_rst <= '0' after 40 ns;

end architecture test;
