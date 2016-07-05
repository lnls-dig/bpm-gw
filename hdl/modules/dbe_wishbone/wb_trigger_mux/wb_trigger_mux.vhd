------------------------------------------------------------------------
-- Title      : Wishbone Trigger Interface
-- Project    :
-------------------------------------------------------------------------------
-- File       : wb_trigger_mux.vhd
-- Author     : Lucas Russo  <lerwys@gmail.com>
-- Company    : Brazilian Synchrotron Light Laboratory, LNLS/CNPEM
-- Created    : 2016-05-11
-- Last update:
-- Platform   :
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Top module for the Wishbone Trigger MUX interface
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
-- Date        Version  Author          Description
-- 2016-05-11  1.0      lerwys          Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
-- Main Wishbone Definitions
use work.wishbone_pkg.all;
-- Custom Wishbone Modules
use work.dbe_wishbone_pkg.all;
-- Wishbone Register Interface
use work.wb_trig_mux_wbgen2_pkg.all;
-- Reset Synch
use work.dbe_common_pkg.all;
-- f_log2_size
use work.genram_pkg.all;
-- General common cores
use work.gencores_pkg.all;
-- Trigger definitions
use work.trigger_pkg.all;

entity wb_trigger_mux is
  generic (
    g_interface_mode       : t_wishbone_interface_mode      := CLASSIC;
    g_address_granularity  : t_wishbone_address_granularity := WORD;
    g_trig_num             : natural range 1 to 24          := 8; -- channels facing outside the FPGA. Limit defined by wb_trigger_mux_regs.vhd
    g_intern_num           : natural range 1 to 24          := 8; -- channels facing inside the FPGA. Limit defined by wb_trigger_mux_regs.vhd
    g_rcv_intern_num       : natural range 1 to 24          := 2  -- signals from inside the FPGA that can be used as input at a rcv mux.
                                                                  -- Limit defined by wb_trigger_mux_regs.vhd
    );

  port (
    clk_i   : in std_logic;
    rst_n_i : in std_logic;

    fs_clk_i   : in std_logic;
    fs_rst_n_i : in std_logic;

    -------------------------------
    ---- Wishbone Control Interface signals
    -------------------------------

    wb_adr_i   : in  std_logic_vector(c_wishbone_address_width-1 downto 0) := (others => '0');
    wb_dat_i   : in  std_logic_vector(c_wishbone_data_width-1 downto 0)    := (others => '0');
    wb_dat_o   : out std_logic_vector(c_wishbone_data_width-1 downto 0);
    wb_sel_i   : in  std_logic_vector(c_wishbone_data_width/8-1 downto 0)  := (others => '0');
    wb_we_i    : in  std_logic                                             := '0';
    wb_cyc_i   : in  std_logic                                             := '0';
    wb_stb_i   : in  std_logic                                             := '0';
    wb_ack_o   : out std_logic;
    wb_err_o   : out std_logic;
    wb_rty_o   : out std_logic;
    wb_stall_o : out std_logic;

    -------------------------------
    ---- External ports
    -------------------------------

    trig_out_o : out t_trig_channel_array(g_trig_num-1 downto 0);
    trig_in_i  : in  t_trig_channel_array(g_trig_num-1 downto 0);

    -------------------------------
    ---- Internal ports
    -------------------------------

    trig_rcv_intern_i   : in  t_trig_channel_array(g_rcv_intern_num-1 downto 0);  -- signals from inside the FPGA that can be used as input at a rcv mux

    trig_pulse_transm_i : in  t_trig_channel_array(g_intern_num-1 downto 0);
    trig_pulse_rcv_o    : out t_trig_channel_array(g_intern_num-1 downto 0)
    );

end entity wb_trigger_mux;

architecture rtl of wb_trigger_mux is

  --------------------------
  --Component Declarations--
  --------------------------

  component wb_trigger_mux_regs is
    port (
      rst_n_i    : in  std_logic;
      clk_sys_i  : in  std_logic;
      wb_adr_i   : in  std_logic_vector(5 downto 0);
      wb_dat_i   : in  std_logic_vector(31 downto 0);
      wb_dat_o   : out std_logic_vector(31 downto 0);
      wb_cyc_i   : in  std_logic;
      wb_sel_i   : in  std_logic_vector(3 downto 0);
      wb_stb_i   : in  std_logic;
      wb_we_i    : in  std_logic;
      wb_ack_o   : out std_logic;
      wb_stall_o : out std_logic;
      fs_clk_i   : in  std_logic;
      regs_i     : in     t_wb_trig_mux_in_registers;
      regs_o     : out    t_wb_trig_mux_out_registers
    );
  end component wb_trigger_mux_regs;

  constant c_periph_addr_size : natural := 6+2;
  constant c_max_num_channels : natural := 24;

  constant c_rcv_sel_buf_len    : positive := 8;  -- Defined according to the wb_slave_trigger.vhd
  constant c_transm_sel_buf_len : positive := 8;  -- Defined according to the wb_slave_trigger.vhd

  -----------
  --Signals--
  -----------

  signal regs_in  : t_wb_trig_mux_in_registers;
  signal regs_out : t_wb_trig_mux_out_registers;

  type t_wb_trig_out_channel is record
    ch_ctl_rcv_src            : std_logic;
    ch_ctl_rcv_in_sel         : std_logic_vector(c_rcv_sel_buf_len-1 downto 0);
    ch_ctl_transm_src         : std_logic;
    ch_ctl_transm_out_sel     : std_logic_vector(c_transm_sel_buf_len-1 downto 0);
  end record;

  type t_wb_trig_out_array is array(natural range <>) of t_wb_trig_out_channel;

  type t_wb_trig_in_channel is record
    dummy    : std_logic_vector(31 downto 0);
  end record;

  type t_wb_trig_in_array is array(natural range <>) of t_wb_trig_in_channel;

  signal ch_regs_out : t_wb_trig_out_array(c_max_num_channels-1 downto 0);
  signal ch_regs_in  : t_wb_trig_in_array(c_max_num_channels-1 downto 0);

  signal rcv_mux_bus        : t_trig_channel_array(g_trig_num-1 downto 0);  -- input of rcv multiplexers
  signal rcv_mux_intern_bus : t_trig_channel_array(g_rcv_intern_num-1 downto 0);  -- signals from inside the FPGA that can be used as input at a rcv mux

  signal transm_mux_bus : t_trig_channel_array(g_intern_num-1 downto 0);  -- input of transm multiplexers

  signal rcv_mux_out    : t_trig_channel_array(g_intern_num-1 downto 0);
  signal transm_mux_out : t_trig_channel_array(g_trig_num-1 downto 0);

  -----------------------------
  -- Wishbone slave adapter signals/structures
  -----------------------------
  signal wb_slv_adp_out : t_wishbone_master_out;
  signal wb_slv_adp_in  : t_wishbone_master_in;
  signal resized_addr   : std_logic_vector(c_wishbone_address_width-1 downto 0);

begin  -- architecture rtl

  -- Test for maximum number of interfaces defined in wb_trigger_mux_regs.vhd
  assert (g_trig_num <= 24) -- number of wb_trigger_mux_regs.vhd registers
  report "[wb_trigger_mux] Only g_trig_num less or equal 24 is supported!"
  severity failure;

  assert (g_intern_num <= 24) -- number of wb_trigger_mux_regs.vhd registers
  report "[wb_trigger_mux] Only g_intern_num less or equal 24 is supported!"
  severity failure;

  assert (g_rcv_intern_num <= 24) -- number of wb_trigger_mux_regs.vhd registers
  report "[wb_trigger_mux] Only g_rcv_intern_num less or equal 24 is supported!"
  severity failure;

  -- Test for maximum width of multiplexor selector wb_trigger_mux_regs.vhd
  assert (f_log2_size(g_trig_num) <= 8) -- sel width
  report "[wb_trigger_mux] log2(g_trig_num) must be less than the selector width (8)!"
  severity failure;

  assert (f_log2_size(g_intern_num) <= 8) -- sel width
  report "[wb_trigger_mux] log2(g_intern_num) must be less than the selector width (8)!"
  severity failure;

  assert (f_log2_size(g_rcv_intern_num) <= 8) -- sel width
  report "[wb_trigger_mux] log2(g_rcv_intern_num) must be less than the selector width (8)!"
  severity failure;

  -----------------------------
  -- Slave adapter for Wishbone Register Interface
  -----------------------------
  cmp_slave_adapter : wb_slave_adapter
  generic map (
    g_master_use_struct                     => true,
    g_master_mode                           => PIPELINED,
    g_master_granularity                    => WORD,
    g_slave_use_struct                      => false,
    g_slave_mode                            => g_interface_mode,
    g_slave_granularity                     => g_address_granularity
  )
  port map (
    clk_sys_i                               => clk_i,
    rst_n_i                                 => rst_n_i,
    master_i                                => wb_slv_adp_in,
    master_o                                => wb_slv_adp_out,
    sl_adr_i                                => resized_addr,
    sl_dat_i                                => wb_dat_i,
    sl_sel_i                                => wb_sel_i,
    sl_cyc_i                                => wb_cyc_i,
    sl_stb_i                                => wb_stb_i,
    sl_we_i                                 => wb_we_i,
    sl_dat_o                                => wb_dat_o,
    sl_ack_o                                => wb_ack_o,
    sl_rty_o                                => open,
    sl_err_o                                => open,
    sl_int_o                                => open,
    sl_stall_o                              => wb_stall_o
  );

  resized_addr(c_periph_addr_size-1 downto 0) <= wb_adr_i(c_periph_addr_size-1 downto 0);
  resized_addr(c_wishbone_address_width-1 downto c_periph_addr_size) <= (others => '0');

  cmp_wb_trigger_mux_regs : wb_trigger_mux_regs
    port map (
      rst_n_i    => rst_n_i,
      clk_sys_i  => clk_i,
      fs_clk_i   => fs_clk_i,
      wb_adr_i   => wb_slv_adp_out.adr(5 downto 0),
      wb_dat_i   => wb_slv_adp_out.dat,
      wb_dat_o   => wb_slv_adp_in.dat,
      wb_cyc_i   => wb_slv_adp_out.cyc,
      wb_sel_i   => wb_slv_adp_out.sel,
      wb_stb_i   => wb_slv_adp_out.stb,
      wb_we_i    => wb_slv_adp_out.we,
      wb_ack_o   => wb_slv_adp_in.ack,
      wb_stall_o => wb_slv_adp_in.stall,
      regs_i     => regs_in,
      regs_o     => regs_out);

  -----------------------------------------------------------------
  -- Connecting slave ports to signals
  -----------------------------------------------------------------

  ch_regs_out(0).ch_ctl_rcv_src            <= regs_out.ch0_ctl_rcv_src_o;
  ch_regs_out(0).ch_ctl_rcv_in_sel         <= regs_out.ch0_ctl_rcv_in_sel_o;
  ch_regs_out(0).ch_ctl_transm_src         <= regs_out.ch0_ctl_transm_src_o;
  ch_regs_out(0).ch_ctl_transm_out_sel     <= regs_out.ch0_ctl_transm_out_sel_o;
  regs_in.ch0_dummy_i                      <= ch_regs_in(0).dummy;

  ch_regs_out(1).ch_ctl_rcv_src            <= regs_out.ch1_ctl_rcv_src_o;
  ch_regs_out(1).ch_ctl_rcv_in_sel         <= regs_out.ch1_ctl_rcv_in_sel_o;
  ch_regs_out(1).ch_ctl_transm_src         <= regs_out.ch1_ctl_transm_src_o;
  ch_regs_out(1).ch_ctl_transm_out_sel     <= regs_out.ch1_ctl_transm_out_sel_o;
  regs_in.ch1_dummy_i                      <= ch_regs_in(1).dummy;

  ch_regs_out(2).ch_ctl_rcv_src            <= regs_out.ch2_ctl_rcv_src_o;
  ch_regs_out(2).ch_ctl_rcv_in_sel         <= regs_out.ch2_ctl_rcv_in_sel_o;
  ch_regs_out(2).ch_ctl_transm_src         <= regs_out.ch2_ctl_transm_src_o;
  ch_regs_out(2).ch_ctl_transm_out_sel     <= regs_out.ch2_ctl_transm_out_sel_o;
  regs_in.ch2_dummy_i                      <= ch_regs_in(2).dummy;

  ch_regs_out(3).ch_ctl_rcv_src            <= regs_out.ch3_ctl_rcv_src_o;
  ch_regs_out(3).ch_ctl_rcv_in_sel         <= regs_out.ch3_ctl_rcv_in_sel_o;
  ch_regs_out(3).ch_ctl_transm_src         <= regs_out.ch3_ctl_transm_src_o;
  ch_regs_out(3).ch_ctl_transm_out_sel     <= regs_out.ch3_ctl_transm_out_sel_o;
  regs_in.ch3_dummy_i                      <= ch_regs_in(3).dummy;

  ch_regs_out(4).ch_ctl_rcv_src            <= regs_out.ch4_ctl_rcv_src_o;
  ch_regs_out(4).ch_ctl_rcv_in_sel         <= regs_out.ch4_ctl_rcv_in_sel_o;
  ch_regs_out(4).ch_ctl_transm_src         <= regs_out.ch4_ctl_transm_src_o;
  ch_regs_out(4).ch_ctl_transm_out_sel     <= regs_out.ch4_ctl_transm_out_sel_o;
  regs_in.ch4_dummy_i                      <= ch_regs_in(4).dummy;

  ch_regs_out(5).ch_ctl_rcv_src            <= regs_out.ch5_ctl_rcv_src_o;
  ch_regs_out(5).ch_ctl_rcv_in_sel         <= regs_out.ch5_ctl_rcv_in_sel_o;
  ch_regs_out(5).ch_ctl_transm_src         <= regs_out.ch5_ctl_transm_src_o;
  ch_regs_out(5).ch_ctl_transm_out_sel     <= regs_out.ch5_ctl_transm_out_sel_o;
  regs_in.ch5_dummy_i                      <= ch_regs_in(5).dummy;

  ch_regs_out(6).ch_ctl_rcv_src            <= regs_out.ch6_ctl_rcv_src_o;
  ch_regs_out(6).ch_ctl_rcv_in_sel         <= regs_out.ch6_ctl_rcv_in_sel_o;
  ch_regs_out(6).ch_ctl_transm_src         <= regs_out.ch6_ctl_transm_src_o;
  ch_regs_out(6).ch_ctl_transm_out_sel     <= regs_out.ch6_ctl_transm_out_sel_o;
  regs_in.ch6_dummy_i                      <= ch_regs_in(6).dummy;

  ch_regs_out(7).ch_ctl_rcv_src            <= regs_out.ch7_ctl_rcv_src_o;
  ch_regs_out(7).ch_ctl_rcv_in_sel         <= regs_out.ch7_ctl_rcv_in_sel_o;
  ch_regs_out(7).ch_ctl_transm_src         <= regs_out.ch7_ctl_transm_src_o;
  ch_regs_out(7).ch_ctl_transm_out_sel     <= regs_out.ch7_ctl_transm_out_sel_o;
  regs_in.ch7_dummy_i                      <= ch_regs_in(7).dummy;

  ch_regs_out(8).ch_ctl_rcv_src            <= regs_out.ch8_ctl_rcv_src_o;
  ch_regs_out(8).ch_ctl_rcv_in_sel         <= regs_out.ch8_ctl_rcv_in_sel_o;
  ch_regs_out(8).ch_ctl_transm_src         <= regs_out.ch8_ctl_transm_src_o;
  ch_regs_out(8).ch_ctl_transm_out_sel     <= regs_out.ch8_ctl_transm_out_sel_o;
  regs_in.ch8_dummy_i                      <= ch_regs_in(8).dummy;

  ch_regs_out(9).ch_ctl_rcv_src            <= regs_out.ch9_ctl_rcv_src_o;
  ch_regs_out(9).ch_ctl_rcv_in_sel         <= regs_out.ch9_ctl_rcv_in_sel_o;
  ch_regs_out(9).ch_ctl_transm_src         <= regs_out.ch9_ctl_transm_src_o;
  ch_regs_out(9).ch_ctl_transm_out_sel     <= regs_out.ch9_ctl_transm_out_sel_o;
  regs_in.ch9_dummy_i                      <= ch_regs_in(9).dummy;

  ch_regs_out(10).ch_ctl_rcv_src           <= regs_out.ch10_ctl_rcv_src_o;
  ch_regs_out(10).ch_ctl_rcv_in_sel        <= regs_out.ch10_ctl_rcv_in_sel_o;
  ch_regs_out(10).ch_ctl_transm_src        <= regs_out.ch10_ctl_transm_src_o;
  ch_regs_out(10).ch_ctl_transm_out_sel    <= regs_out.ch10_ctl_transm_out_sel_o;
  regs_in.ch10_dummy_i                     <= ch_regs_in(10).dummy;

  ch_regs_out(11).ch_ctl_rcv_src           <= regs_out.ch11_ctl_rcv_src_o;
  ch_regs_out(11).ch_ctl_rcv_in_sel        <= regs_out.ch11_ctl_rcv_in_sel_o;
  ch_regs_out(11).ch_ctl_transm_src        <= regs_out.ch11_ctl_transm_src_o;
  ch_regs_out(11).ch_ctl_transm_out_sel    <= regs_out.ch11_ctl_transm_out_sel_o;
  regs_in.ch11_dummy_i                     <= ch_regs_in(11).dummy;

  ch_regs_out(12).ch_ctl_rcv_src           <= regs_out.ch12_ctl_rcv_src_o;
  ch_regs_out(12).ch_ctl_rcv_in_sel        <= regs_out.ch12_ctl_rcv_in_sel_o;
  ch_regs_out(12).ch_ctl_transm_src        <= regs_out.ch12_ctl_transm_src_o;
  ch_regs_out(12).ch_ctl_transm_out_sel    <= regs_out.ch12_ctl_transm_out_sel_o;
  regs_in.ch12_dummy_i                     <= ch_regs_in(12).dummy;

  ch_regs_out(13).ch_ctl_rcv_src           <= regs_out.ch13_ctl_rcv_src_o;
  ch_regs_out(13).ch_ctl_rcv_in_sel        <= regs_out.ch13_ctl_rcv_in_sel_o;
  ch_regs_out(13).ch_ctl_transm_src        <= regs_out.ch13_ctl_transm_src_o;
  ch_regs_out(13).ch_ctl_transm_out_sel    <= regs_out.ch13_ctl_transm_out_sel_o;
  regs_in.ch13_dummy_i                     <= ch_regs_in(13).dummy;

  ch_regs_out(14).ch_ctl_rcv_src           <= regs_out.ch14_ctl_rcv_src_o;
  ch_regs_out(14).ch_ctl_rcv_in_sel        <= regs_out.ch14_ctl_rcv_in_sel_o;
  ch_regs_out(14).ch_ctl_transm_src        <= regs_out.ch14_ctl_transm_src_o;
  ch_regs_out(14).ch_ctl_transm_out_sel    <= regs_out.ch14_ctl_transm_out_sel_o;
  regs_in.ch14_dummy_i                     <= ch_regs_in(14).dummy;

  ch_regs_out(15).ch_ctl_rcv_src           <= regs_out.ch15_ctl_rcv_src_o;
  ch_regs_out(15).ch_ctl_rcv_in_sel        <= regs_out.ch15_ctl_rcv_in_sel_o;
  ch_regs_out(15).ch_ctl_transm_src        <= regs_out.ch15_ctl_transm_src_o;
  ch_regs_out(15).ch_ctl_transm_out_sel    <= regs_out.ch15_ctl_transm_out_sel_o;
  regs_in.ch15_dummy_i                     <= ch_regs_in(15).dummy;

  ch_regs_out(16).ch_ctl_rcv_src           <= regs_out.ch16_ctl_rcv_src_o;
  ch_regs_out(16).ch_ctl_rcv_in_sel        <= regs_out.ch16_ctl_rcv_in_sel_o;
  ch_regs_out(16).ch_ctl_transm_src        <= regs_out.ch16_ctl_transm_src_o;
  ch_regs_out(16).ch_ctl_transm_out_sel    <= regs_out.ch16_ctl_transm_out_sel_o;
  regs_in.ch16_dummy_i                     <= ch_regs_in(16).dummy;

  ch_regs_out(17).ch_ctl_rcv_src           <= regs_out.ch17_ctl_rcv_src_o;
  ch_regs_out(17).ch_ctl_rcv_in_sel        <= regs_out.ch17_ctl_rcv_in_sel_o;
  ch_regs_out(17).ch_ctl_transm_src        <= regs_out.ch17_ctl_transm_src_o;
  ch_regs_out(17).ch_ctl_transm_out_sel    <= regs_out.ch17_ctl_transm_out_sel_o;
  regs_in.ch17_dummy_i                     <= ch_regs_in(17).dummy;

  ch_regs_out(18).ch_ctl_rcv_src           <= regs_out.ch18_ctl_rcv_src_o;
  ch_regs_out(18).ch_ctl_rcv_in_sel        <= regs_out.ch18_ctl_rcv_in_sel_o;
  ch_regs_out(18).ch_ctl_transm_src        <= regs_out.ch18_ctl_transm_src_o;
  ch_regs_out(18).ch_ctl_transm_out_sel    <= regs_out.ch18_ctl_transm_out_sel_o;
  regs_in.ch18_dummy_i                     <= ch_regs_in(18).dummy;

  ch_regs_out(19).ch_ctl_rcv_src           <= regs_out.ch19_ctl_rcv_src_o;
  ch_regs_out(19).ch_ctl_rcv_in_sel        <= regs_out.ch19_ctl_rcv_in_sel_o;
  ch_regs_out(19).ch_ctl_transm_src        <= regs_out.ch19_ctl_transm_src_o;
  ch_regs_out(19).ch_ctl_transm_out_sel    <= regs_out.ch19_ctl_transm_out_sel_o;
  regs_in.ch19_dummy_i                     <= ch_regs_in(19).dummy;

  ch_regs_out(20).ch_ctl_rcv_src           <= regs_out.ch20_ctl_rcv_src_o;
  ch_regs_out(20).ch_ctl_rcv_in_sel        <= regs_out.ch20_ctl_rcv_in_sel_o;
  ch_regs_out(20).ch_ctl_transm_src        <= regs_out.ch20_ctl_transm_src_o;
  ch_regs_out(20).ch_ctl_transm_out_sel    <= regs_out.ch20_ctl_transm_out_sel_o;
  regs_in.ch20_dummy_i                     <= ch_regs_in(20).dummy;

  ch_regs_out(21).ch_ctl_rcv_src           <= regs_out.ch21_ctl_rcv_src_o;
  ch_regs_out(21).ch_ctl_rcv_in_sel        <= regs_out.ch21_ctl_rcv_in_sel_o;
  ch_regs_out(21).ch_ctl_transm_src        <= regs_out.ch21_ctl_transm_src_o;
  ch_regs_out(21).ch_ctl_transm_out_sel    <= regs_out.ch21_ctl_transm_out_sel_o;
  regs_in.ch21_dummy_i                     <= ch_regs_in(21).dummy;

  ch_regs_out(22).ch_ctl_rcv_src           <= regs_out.ch22_ctl_rcv_src_o;
  ch_regs_out(22).ch_ctl_rcv_in_sel        <= regs_out.ch22_ctl_rcv_in_sel_o;
  ch_regs_out(22).ch_ctl_transm_src        <= regs_out.ch22_ctl_transm_src_o;
  ch_regs_out(22).ch_ctl_transm_out_sel    <= regs_out.ch22_ctl_transm_out_sel_o;
  regs_in.ch22_dummy_i                     <= ch_regs_in(22).dummy;

  ch_regs_out(23).ch_ctl_rcv_src           <= regs_out.ch23_ctl_rcv_src_o;
  ch_regs_out(23).ch_ctl_rcv_in_sel        <= regs_out.ch23_ctl_rcv_in_sel_o;
  ch_regs_out(23).ch_ctl_transm_src        <= regs_out.ch23_ctl_transm_src_o;
  ch_regs_out(23).ch_ctl_transm_out_sel    <= regs_out.ch23_ctl_transm_out_sel_o;
  regs_in.ch23_dummy_i                     <= ch_regs_in(23).dummy;

  ch_regs_in(0).dummy                       <= (others => '0');
  ch_regs_in(1).dummy                       <= (others => '0');
  ch_regs_in(2).dummy                       <= (others => '0');
  ch_regs_in(3).dummy                       <= (others => '0');
  ch_regs_in(4).dummy                       <= (others => '0');
  ch_regs_in(5).dummy                       <= (others => '0');
  ch_regs_in(6).dummy                       <= (others => '0');
  ch_regs_in(7).dummy                       <= (others => '0');
  ch_regs_in(8).dummy                       <= (others => '0');
  ch_regs_in(9).dummy                       <= (others => '0');
  ch_regs_in(10).dummy                      <= (others => '0');
  ch_regs_in(11).dummy                      <= (others => '0');
  ch_regs_in(12).dummy                      <= (others => '0');
  ch_regs_in(13).dummy                      <= (others => '0');
  ch_regs_in(14).dummy                      <= (others => '0');
  ch_regs_in(15).dummy                      <= (others => '0');
  ch_regs_in(16).dummy                      <= (others => '0');
  ch_regs_in(17).dummy                      <= (others => '0');
  ch_regs_in(18).dummy                      <= (others => '0');
  ch_regs_in(19).dummy                      <= (others => '0');
  ch_regs_in(20).dummy                      <= (others => '0');
  ch_regs_in(21).dummy                      <= (others => '0');
  ch_regs_in(22).dummy                      <= (others => '0');
  ch_regs_in(23).dummy                      <= (others => '0');

  ---------------------------
  -- Instantiation Process --
  ---------------------------

  -- data signals
  rcv_mux_bus <= trig_in_i;
  rcv_mux_intern_bus <=  trig_rcv_intern_i;

  ----------------------------------
  --Generate receiver multiplexers--
  ----------------------------------
  mux_rcv : for ir in g_intern_num -1 downto 0 generate
    process (fs_clk_i)is
      variable sel : integer := 0;
    begin  -- process
      sel := to_integer(unsigned(ch_regs_out(ir).ch_ctl_rcv_in_sel));

      if rising_edge(fs_clk_i) then     -- rising clock edge
        if fs_rst_n_i = '0' then        -- synchronous reset (active low)
          rcv_mux_out(ir) <= rcv_mux_bus(0);
        else

          if (ch_regs_out(ir).ch_ctl_rcv_src = '0') then -- checks the source of receiver (triggers/internal)
            -- check if sel is bigger than internal channels
            if (sel >= g_trig_num) then
              rcv_mux_out(ir) <= rcv_mux_bus(0);
            else
              rcv_mux_out(ir) <= rcv_mux_bus(sel);
            end if;

          else
            -- check if sel is bigger than  internal rcv signals
            if (sel >= g_rcv_intern_num) then
              rcv_mux_out(ir) <= rcv_mux_intern_bus(0);
            else
              rcv_mux_out(ir) <= rcv_mux_intern_bus(sel);
            end if;

          end if;
        end if;
      end if;

    end process;
  end generate mux_rcv;

  trig_pulse_rcv_o <= rcv_mux_out;

  -- data signals
  transm_mux_bus <= trig_pulse_transm_i;

  -------------------------------------
  --Generate transmitter multiplexers--
  -------------------------------------
  mux_transm : for it in g_trig_num-1 downto 0 generate
    process (fs_clk_i) is
      variable sel : integer := 0;
    begin  -- process
      sel := to_integer(unsigned(ch_regs_out(it).ch_ctl_transm_out_sel));
      if rising_edge(fs_clk_i) then     -- rising clock edge
        if fs_rst_n_i = '0' then        -- synchronous reset (active low)
          transm_mux_out(it) <= transm_mux_bus(0);
        else

          if (ch_regs_out(it).ch_ctl_transm_src = '0') then -- checks the source of receiver (triggers/internal)
            -- check if sel is bigger than internal channels
            if (sel >= g_intern_num) then
              transm_mux_out(it) <= transm_mux_bus(0);
            else
              transm_mux_out(it) <= transm_mux_bus(sel);
            end if;

          else

            -- check if sel is bigger than  internal rcv signals
            if (sel >= g_rcv_intern_num) then
              transm_mux_out(it) <= rcv_mux_intern_bus(0);
            else
              transm_mux_out(it) <= rcv_mux_intern_bus(sel);
            end if;

          end if;
        end if;
      end if;
    end process;
  end generate mux_transm;

  trig_out_o <= transm_mux_out;

end architecture rtl;
