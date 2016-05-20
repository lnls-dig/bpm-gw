------------------------------------------------------------------------
-- Title      : Wishbone Trigger Interface
-- Project    :
-------------------------------------------------------------------------------
-- File       : wb_trigger.vhd
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
-- General common cores
use work.gencores_pkg.all;
-- Trigger package
use work.trigger_pkg.all;

entity wb_trigger is
  generic (
    g_interface_mode       : t_wishbone_interface_mode      := CLASSIC;
    g_address_granularity  : t_wishbone_address_granularity := WORD;
    g_sync_edge            : string                         := "positive";
    g_trig_num             : natural range 1 to 24          := 8; -- channels facing outside the FPGA. Limit defined by wb_trigger_regs.vhd
    g_intern_num           : natural range 1 to 24          := 8; -- channels facing inside the FPGA. Limit defined by wb_trigger_regs.vhd
    g_rcv_intern_num       : natural range 1 to 24          := 2; -- signals from inside the FPGA that can be used as input at a rcv mux.
                                                                  -- Limit defined by wb_trigger_regs.vhd
    g_num_mux_interfaces   : natural                        := 2;  -- Number of wb_trigger_mux modules
    g_out_resolver         : string                         := "fanout"; -- Resolver policy for output triggers
    g_in_resolver          : string                         := "or";     -- Resolver policy for input triggers
    g_with_input_sync      : boolean                        := true;
    g_with_output_sync     : boolean                        := true
  );
  port (
    clk_i   : in std_logic;
    rst_n_i : in std_logic;

    ref_clk_i   : in std_logic;
    ref_rst_n_i : in std_logic;

    fs_clk_array_i    : in std_logic_vector(g_num_mux_interfaces-1 downto 0);
    fs_rst_n_array_i  : in std_logic_vector(g_num_mux_interfaces-1 downto 0);

    -------------------------------
    ---- Wishbone Control Interface signals
    -------------------------------

    wb_trigger_iface_adr_i   : in  std_logic_vector(c_wishbone_address_width-1 downto 0) := (others => '0');
    wb_trigger_iface_dat_i   : in  std_logic_vector(c_wishbone_data_width-1 downto 0)    := (others => '0');
    wb_trigger_iface_dat_o   : out std_logic_vector(c_wishbone_data_width-1 downto 0);
    wb_trigger_iface_sel_i   : in  std_logic_vector(c_wishbone_data_width/8-1 downto 0)  := (others => '0');
    wb_trigger_iface_we_i    : in  std_logic                                             := '0';
    wb_trigger_iface_cyc_i   : in  std_logic                                             := '0';
    wb_trigger_iface_stb_i   : in  std_logic                                             := '0';
    wb_trigger_iface_ack_o   : out std_logic;
    wb_trigger_iface_err_o   : out std_logic;
    wb_trigger_iface_rty_o   : out std_logic;
    wb_trigger_iface_stall_o : out std_logic;

    wb_trigger_mux_adr_i   : in  std_logic_vector(g_num_mux_interfaces*c_wishbone_address_width-1 downto 0) := (others => '0');
    wb_trigger_mux_dat_i   : in  std_logic_vector(g_num_mux_interfaces*c_wishbone_data_width-1 downto 0)    := (others => '0');
    wb_trigger_mux_dat_o   : out std_logic_vector(g_num_mux_interfaces*c_wishbone_data_width-1 downto 0);
    wb_trigger_mux_sel_i   : in  std_logic_vector(g_num_mux_interfaces*c_wishbone_data_width/8-1 downto 0)  := (others => '0');
    wb_trigger_mux_we_i    : in  std_logic_vector(g_num_mux_interfaces-1 downto 0)                          := (others => '0');
    wb_trigger_mux_cyc_i   : in  std_logic_vector(g_num_mux_interfaces-1 downto 0)                          := (others => '0');
    wb_trigger_mux_stb_i   : in  std_logic_vector(g_num_mux_interfaces-1 downto 0)                          := (others => '0');
    wb_trigger_mux_ack_o   : out std_logic_vector(g_num_mux_interfaces-1 downto 0);
    wb_trigger_mux_err_o   : out std_logic_vector(g_num_mux_interfaces-1 downto 0);
    wb_trigger_mux_rty_o   : out std_logic_vector(g_num_mux_interfaces-1 downto 0);
    wb_trigger_mux_stall_o : out std_logic_vector(g_num_mux_interfaces-1 downto 0);

    -------------------------------
    ---- External ports
    -------------------------------

    trig_b      : inout std_logic_vector(g_trig_num-1 downto 0);
    trig_dir_o  : out   std_logic_vector(g_trig_num-1 downto 0);

    -------------------------------
    ---- Internal ports
    -------------------------------

    trig_rcv_intern_i   : in  t_trig_channel_array(g_num_mux_interfaces*g_rcv_intern_num-1 downto 0);  -- signals from inside the FPGA that can be used as input at a rcv mux

    trig_pulse_transm_i : in  t_trig_channel_array(g_num_mux_interfaces*g_intern_num-1 downto 0);
    trig_pulse_rcv_o    : out t_trig_channel_array(g_num_mux_interfaces*g_intern_num-1 downto 0);

    -------------------------------
    ---- Debug ports
    -------------------------------

    trig_dbg_o          : out std_logic_vector(g_trig_num-1 downto 0)
    );

end entity wb_trigger;

architecture rtl of wb_trigger is

  -- Trigger 2d <-> 1d conversion
  type t_trig_channel_compat_array2d is array (natural range <>) of t_trig_channel_array(g_trig_num-1 downto 0);

  signal trig_out_int_compat_array : t_trig_channel_compat_array2d(g_num_mux_interfaces-1 downto 0);
  signal trig_in_int_compat_array : t_trig_channel_compat_array2d(g_num_mux_interfaces-1 downto 0);

  signal trig_out_int_array2d : t_trig_channel_array2d(g_num_mux_interfaces-1 downto 0, g_trig_num-1 downto 0);
  signal trig_in_int_array2d : t_trig_channel_array2d(g_num_mux_interfaces-1 downto 0, g_trig_num-1 downto 0);

  signal trig_out_resolved : t_trig_channel_array(g_trig_num-1 downto 0);
  signal trig_in_resolved  : t_trig_channel_array(g_trig_num-1 downto 0);

begin  -- architecture rtl

  cmp_wb_trigger_iface : wb_trigger_iface
    generic map (
      g_interface_mode       => g_interface_mode,
      g_address_granularity  => g_address_granularity,
      g_sync_edge            => g_sync_edge,
      g_trig_num             => g_trig_num
    )
    port map (
      clk_i      => clk_i,
      rst_n_i    => rst_n_i,

      ref_clk_i   => ref_clk_i,
      ref_rst_n_i => ref_rst_n_i,

      wb_adr_i   => wb_trigger_iface_adr_i,
      wb_dat_i   => wb_trigger_iface_dat_i,
      wb_dat_o   => wb_trigger_iface_dat_o,
      wb_sel_i   => wb_trigger_iface_sel_i,
      wb_we_i    => wb_trigger_iface_we_i,
      wb_cyc_i   => wb_trigger_iface_cyc_i,
      wb_stb_i   => wb_trigger_iface_stb_i,
      wb_ack_o   => wb_trigger_iface_ack_o,
      wb_err_o   => wb_trigger_iface_err_o,
      wb_rty_o   => wb_trigger_iface_rty_o,
      wb_stall_o => wb_trigger_iface_stall_o,

      trig_b      => trig_b,
      trig_dir_o  => trig_dir_o,
      trig_out_o  => trig_out_resolved,
      trig_in_i   => trig_in_resolved,
      trig_dbg_o  => trig_dbg_o
    );

  cmp_trigger_resolver : trigger_resolver
    generic map (
      g_trig_num             => g_trig_num,
      g_num_mux_interfaces   => g_num_mux_interfaces,
      g_out_resolver         => g_out_resolver,
      g_in_resolver          => g_in_resolver,
      g_with_input_sync      => g_with_input_sync,
      g_with_output_sync     => g_with_output_sync
   )
    port map (
      ref_clk_i      => ref_clk_i,
      ref_rst_n_i    => ref_rst_n_i,

      fs_clk_array_i    => fs_clk_array_i,
      fs_rst_n_array_i  => fs_rst_n_array_i,

      trig_resolved_out_o => trig_in_resolved,
      trig_resolved_in_i  => trig_out_resolved,

      trig_mux_out_o => trig_out_int_array2d,
      trig_mux_in_i  => trig_in_int_array2d
    );

  gen_input_interfaces : for i in 0 to g_num_mux_interfaces-1 generate
    gen_reorder_trigger_channels : for j in 0 to g_trig_num-1 generate

      trig_out_int_compat_array(i)(j) <= trig_out_int_array2d(i, j);
      trig_in_int_array2d(i, j) <= trig_in_int_compat_array(i)(j);

    end generate;
  end generate;

  gen_mux_interfaces : for i in 0 to g_num_mux_interfaces-1 generate
    cmp_wb_trigger : wb_trigger_mux
      generic map (
        g_interface_mode       => g_interface_mode,
        g_address_granularity  => g_address_granularity,
        g_trig_num             => g_trig_num,
        g_intern_num           => g_intern_num,
        g_rcv_intern_num       => g_rcv_intern_num
     )
      port map (
        clk_i      => clk_i,
        rst_n_i    => rst_n_i,

        fs_clk_i   => fs_clk_array_i(i),
        fs_rst_n_i => fs_rst_n_array_i(i),

        wb_adr_i   => wb_trigger_mux_adr_i((i+1)*c_wishbone_address_width-1 downto i*c_wishbone_address_width),
        wb_dat_i   => wb_trigger_mux_dat_i((i+1)*c_wishbone_data_width-1 downto i*c_wishbone_data_width),
        wb_dat_o   => wb_trigger_mux_dat_o((i+1)*c_wishbone_data_width-1 downto i*c_wishbone_data_width),
        wb_sel_i   => wb_trigger_mux_sel_i((i+1)*c_wishbone_data_width/8-1 downto i*c_wishbone_data_width/8),
        wb_we_i    => wb_trigger_mux_we_i(i),
        wb_cyc_i   => wb_trigger_mux_cyc_i(i),
        wb_stb_i   => wb_trigger_mux_stb_i(i),
        wb_ack_o   => wb_trigger_mux_ack_o(i),
        wb_err_o   => wb_trigger_mux_err_o(i),
        wb_rty_o   => wb_trigger_mux_rty_o(i),
        wb_stall_o => wb_trigger_mux_stall_o(i),

        trig_out_o => trig_in_int_compat_array(i),
        trig_in_i  => trig_out_int_compat_array(i),

        trig_rcv_intern_i   => trig_rcv_intern_i ((i+1)*g_rcv_intern_num-1 downto i*g_rcv_intern_num),
        trig_pulse_transm_i => trig_pulse_transm_i ((i+1)*g_intern_num-1 downto i*g_intern_num),
        trig_pulse_rcv_o    => trig_pulse_rcv_o ((i+1)*g_intern_num-1 downto i*g_intern_num)
      );
  end generate;

end architecture rtl;
