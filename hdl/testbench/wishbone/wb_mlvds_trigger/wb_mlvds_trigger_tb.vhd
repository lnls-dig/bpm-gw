-------------------------------------------------------------------------------
-- Title      : Testbench for design "wb_mlvds_trigger"
-- Project    :
-------------------------------------------------------------------------------
-- File       : wb_mlvds_trigger_tb.vhd
-- Author     : Vitor Finotti Ferreira  <vfinotti@finotti-Inspiron-7520>
-- Company    : Brazilian Synchrotron Light Laboratory, LNLS/CNPEM
-- Created    : 2016-01-27
-- Last update: 2016-01-27
-- Platform   :
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
-------------------------------------------------------------------------------
-- Copyright (c) 2016 Brazilian Synchrotron Light Laboratory, LNLS/CNPEM

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
-- 2016-01-27  1.0      vfinotti	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity wb_mlvds_trigger_tb is

end entity wb_mlvds_trigger_tb;

-------------------------------------------------------------------------------

architecture test of wb_mlvds_trigger_tb is

  -- component generics
  constant g_width_bus_size       : positive := 8;
  constant g_rcv_len_bus_width    : positive := 8;
  constant g_transm_len_bus_width : positive := 8;
  constant g_sync_edge            : string   := "positive";
  constant g_trig_num             : positive := 8;

  -- component ports
  signal sys_clk_i       : std_logic;
  signal sys_rst_n_i     : std_logic;
  signal wb_adr_i        : std_logic_vector(2 downto 0)  := (others => '0');
  signal wb_dat_i        : std_logic_vector(31 downto 0) := (others => '0');
  signal wb_dat_o        : std_logic_vector(31 downto 0);
  signal wb_sel_i        : std_logic_vector(3 downto 0)  := (others => '0');
  signal wb_we_i         : std_logic                     := '0';
  signal wb_cyc_i        : std_logic                     := '0';
  signal wb_stb_i        : std_logic                     := '0';
  signal wb_ack_o        : std_logic;
  signal wb_err_o        : std_logic;
  signal wb_rty_o        : std_logic;
  signal wb_stall_o      : std_logic;
  signal trig_dir_o      : std_logic_vector(g_trig_num-1 downto 0);
  signal trig_term_o     : std_logic_vector(g_trig_num-1 downto 0);
  signal trig_pulse_b    : std_logic_vector(g_trig_num-1 downto 0);
  signal trig_extended_b : std_logic_vector(g_trig_num-1 downto 0);

  -- clock
  signal Clk : std_logic := '1';

begin  -- architecture test

  -- component instantiation
  DUT: entity work.wb_mlvds_trigger
    generic map (
      g_width_bus_size       => g_width_bus_size,
      g_rcv_len_bus_width    => g_rcv_len_bus_width,
      g_transm_len_bus_width => g_transm_len_bus_width,
      g_sync_edge            => g_sync_edge,
      g_trig_num             => g_trig_num)
    port map (
      clk_i           => sys_clk_i,
      rst_n_i         => sys_rst_n_i,
      wb_adr_i        => wb_adr_i,
      wb_dat_i        => wb_dat_i,
      wb_dat_o        => wb_dat_o,
      wb_sel_i        => wb_sel_i,
      wb_we_i         => wb_we_i,
      wb_cyc_i        => wb_cyc_i,
      wb_stb_i        => wb_stb_i,
      wb_ack_o        => wb_ack_o,
      wb_err_o        => wb_err_o,
      wb_rty_o        => wb_rty_o,
      wb_stall_o      => wb_stall_o,
      trig_dir_o      => trig_dir_o,
      trig_term_o     => trig_term_o,
      trig_pulse_b    => trig_pulse_b,
      trig_extended_b => trig_extended_b);

  -- clock generation
  Clk <= not Clk after 10 ns;

  -- waveform generation
  WaveGen_Proc: process
  begin
    -- insert signal assignments here

    wait until Clk = '1';
  end process WaveGen_Proc;



end architecture test;

-------------------------------------------------------------------------------

configuration wb_mlvds_trigger_tb_test_cfg of wb_mlvds_trigger_tb is
  for test
  end for;
end wb_mlvds_trigger_tb_test_cfg;

-------------------------------------------------------------------------------
