------------------------------------------------------------------------
-- Title      : Wishbone MLVDS Trigger Interface
-- Project    :
-------------------------------------------------------------------------------
-- File       : wb_mlvds_trigger.vhd
-- Author     : Vitor Finotti Ferreira  <vfinotti@finotti-Inspiron-7520>
-- Company    : Brazilian Synchrotron Light Laboratory, LNLS/CNPEM
-- Created    : 2016-01-22
-- Last update: 2016-01-26
-- Platform   :
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Top module for the MLVDS Trigger AFC board interface
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
-- 2016-01-22  1.0      vfinotti        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
-- Main Wishbone Definitions
use work.wishbone_pkg.all;
-- Custom Wishbone Modules
use work.dbe_wishbone_pkg.all;
-- Wishbone Stream Interface
--use work.wb_stream_pkg.all;
use work.wb_stream_generic_pkg.all;
-- Register interface
use work.wb_fmc_130m_4ch_csr_wbgen2_pkg.all;
-- FMC ADC package
use work.fmc_adc_pkg.all;
-- Reset Synch
use work.dbe_common_pkg.all;
-- General common cores
use work.gencores_pkg.all;

-- For Xilinx primitives
library unisim;
use unisim.vcomponents.all;

entity wb_mlvds_trigger is
  generic
    (
      constant g_max_width            : natural  := 1000;
      constant g_rcv_len_bus_width    : positive := 8;
      constant g_transm_len_bus_width : positive := 8;
      constant g_sync_edge            : string   := "positive";
      constant g_trig_num             : positive := 8);

  port
    (
      sys_clk_i   : in std_logic;
      sys_rst_n_i : in std_logic;

      -----------------------------
      -- Wishbone Control Interface signals
      -----------------------------

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

      -----------------------------
      -- External ports
      -----------------------------

      -- Trigger
      fmc_trig_dir_o   : out   std_logic_vector(g_trig_num-1 downto 0);
      fmc_trig_term_o  : out   std_logic_vector(g_trig_num-1 downto 0);

      fmc_trig_dif_p_b : inout std_logic_vector(g_trig_num-1 downto 0);
      fmc_trig_dif_n_b : inout std_logic_vector(g_trig_num-1 downto 0);

      fmc_trig_pulse_b : inout std_logic_vector(g_trig_num-1 downto 0);

      );

end wb_mlvds_trigger;

architecture rtl of wb_mlvds_trigger is


  --------------------------
  --Component Declarations--
  --------------------------

  component wb_slave_mlvds_trigger is
    port (
      rst_n_i    : in  std_logic;
      clk_sys_i  : in  std_logic;
      wb_adr_i   : in  std_logic_vector(2 downto 0);
      wb_dat_i   : in  std_logic_vector(31 downto 0);
      wb_dat_o   : out std_logic_vector(31 downto 0);
      wb_cyc_i   : in  std_logic;
      wb_sel_i   : in  std_logic_vector(3 downto 0);
      wb_stb_i   : in  std_logic;
      wb_we_i    : in  std_logic;
      wb_ack_o   : out std_logic;
      wb_stall_o : out std_logic;

      wb_trig_rcv_len_0_3_o            : out std_logic_vector(31 downto 0);
      wb_trig_rcv_len_4_7_o            : out std_logic_vector(31 downto 0);
      wb_trig_rcv_data_data_p_o        : out std_logic_vector(7 downto 0);
      wb_trig_rcv_data_data_n_o        : out std_logic_vector(7 downto 0);
      wb_trig_rcv_data_pulse_i         : in  std_logic_vector(7 downto 0);
      wb_trig_transm_len_0_3_o         : out std_logic_vector(31 downto 0);
      wb_trig_transm_len_4_7_o         : out std_logic_vector(31 downto 0);
      wb_trig_transm_data_pulse_o      : out std_logic_vector(7 downto 0);
      wb_trig_transm_data_extended_n_i : in  std_logic_vector(7 downto 0);
      wb_trig_transm_data_extended_p_i : in  std_logic_vector(7 downto 0);
      wb_trig_trigger_dir_o            : out std_logic_vector(7 downto 0);
      wb_trig_trigger_term_o           : out std_logic_vector(7 downto 0);
      wb_trig_trigger_trig_val_o       : out std_logic_vector(7 downto 0));
  end component wb_slave_mlvds_trigger;

  component extend_pulse_dyn is
    generic (
      g_max_width : natural);
    port (
      clk_i         : in  std_logic;
      rst_n_i       : in  std_logic;
      pulse_i       : in  std_logic;
      pulse_width_i : in  natural;
      extended_o    : out std_logic := '0');
  end component extend_pulse_dyn;

  component trigger_rcv is
    generic (
      g_glitch_len_width : positive;
      g_sync_edge        : string);
    port (
      clk_i   : in  std_logic;
      rst_n_i : in  std_logic;
      len_i   : in  std_logic_vector(g_glitch_len_width-1 downto 0);
      data_i  : in  std_logic;
      pulse_o : out std_logic);
  end component trigger_rcv;


  -----------
  --Signals--
  -----------

  signal wb_trig_rcv_len_0_3            : std_logic_vector(31 downto 0);
  signal wb_trig_rcv_len_4_7            : std_logic_vector(31 downto 0);
  signal wb_trig_rcv_data_data_p        : std_logic_vector(7 downto 0);
  signal wb_trig_rcv_data_data_n        : std_logic_vector(7 downto 0);
  signal wb_trig_rcv_data_pulse         : std_logic_vector(7 downto 0);
  signal wb_trig_transm_len_0_3         : std_logic_vector(31 downto 0);
  signal wb_trig_transm_len_4_7         : std_logic_vector(31 downto 0);
  signal wb_trig_transm_data_pulse      : std_logic_vector(7 downto 0);
  signal wb_trig_transm_data_extended_n : std_logic_vector(7 downto 0);
  signal wb_trig_transm_data_extended_p : std_logic_vector(7 downto 0);
  signal wb_trig_trigger_dir            : std_logic_vector(7 downto 0);
  signal wb_trig_trigger_term           : std_logic_vector(7 downto 0);
  signal wb_trig_trigger_trig_val       : std_logic_vector(7 downto 0);

  signal inter_buf   : std_logic_vector(g_trig_num-1 downto 0);
  signal inter_bufds : std_logic_vector(g_trig_num-1 downto 0);


begin  -- architecture rtl

  wb_slave_mlvds_trigger_1 : entity work.wb_slave_mlvds_trigger
    port map (
      rst_n_i                          => rst_n_i,
      clk_sys_i                        => clk_sys_i,
      wb_adr_i                         => wb_adr_i,
      wb_dat_i                         => wb_dat_i,
      wb_dat_o                         => wb_dat_o,
      wb_cyc_i                         => wb_cyc_i,
      wb_sel_i                         => wb_sel_i,
      wb_stb_i                         => wb_stb_i,
      wb_we_i                          => wb_we_i,
      wb_ack_o                         => wb_ack_o,
      wb_stall_o                       => wb_stall_o,
      wb_trig_rcv_len_0_3_o            => wb_trig_rcv_len_0_3,
      wb_trig_rcv_len_4_7_o            => wb_trig_rcv_len_4_7,
      wb_trig_rcv_data_data_p_o        => wb_trig_rcv_data_data_p,
      wb_trig_rcv_data_data_n_o        => wb_trig_rcv_data_data_n,
      wb_trig_rcv_data_pulse_i         => wb_trig_rcv_data_pulse,
      wb_trig_transm_len_0_3_o         => wb_trig_transm_len_0_3,
      wb_trig_transm_len_4_7_o         => wb_trig_transm_len_4_7,
      wb_trig_transm_data_pulse_o      => wb_trig_transm_data_pulse,
      wb_trig_transm_data_extended_n_i => wb_trig_transm_data_extended_n,
      wb_trig_transm_data_extended_p_i => wb_trig_transm_data_extended_p,
      wb_trig_trigger_dir_o            => wb_trig_trigger_dir,
      wb_trig_trigger_term_o           => wb_trig_trigger_term,
      wb_trig_trigger_trig_val_o       => wb_trig_trigger_trig_val);

  ------------------------------------
  -- Instantiation for buses 0 to 3 --
  ------------------------------------

  trigger_rcv_transm_0_3 : for i in g_trig_num-1 downto 0 generate

    extend_pulse_dyn_1 : entity work.extend_pulse_dyn
      generic map (
        g_max_width => g_max_width)
      port map (
        clk_i         => clk_sys_i,
        rst_n_i       => rst_n_i,
        pulse_i       => wb_trig_transm_data_pulse,
        pulse_width_i => wb_trig_transm_data_pulse_width((8*i+7) downto 8*i),
        extended_o    => );

    trigger_rcv_1 : entity work.trigger_rcv
      generic map (
        g_glitch_len_width => g_rcv_len_bus_width,
        g_sync_edge        => g_sync_edge)
      port map (
        clk_i   => clk_sys_i,
        rst_n_i => rst_n_i,
        len_i   => wb_trig_rcv_data_len((8*i+7) downto 8*i),
        data_i  => ,
        pulse_o => );

    -- iobuf connected to the wishbone component and to the other iobuf
    cmp_iobuf_wb : iobuf
      generic map (
       --iostandard   => "BLVDS_25"      -- Specify the I/O standard
        )
      port map (
        o  => fmc_trig_val_in,          -- Buffer output for further use
        io => fmc_trig_val_p_b,  -- inout (connect directly to top-level port)
        i  => fmc_trig_val_int,         -- Buffer input
        t  =>  -- 3-state enable input, high=output, low=input
        );

    -- iobuf connected to the transm and rcv components and to the other iobuf
    cmp_iobuf_cores : iobuf
      generic map (
       --iostandard   => "BLVDS_25"      -- Specify the I/O standard
        )
      port map (
        o  => fmc_trig_val_in,          -- Buffer output for further use
        io => fmc_trig_val_p_b,  -- inout (connect directly to top-level port)
        i  => fmc_trig_val_int,         -- Buffer input
        t  =>  -- 3-state enable input, high=output, low=input
        );

    -- iobuf connected to the transm and rcv components and to the other iobuf
    cmp_iobufds_wb : iobufds
      generic map (
        diff_term    => true,   -- Differential Termination ("TRUE"/"FALSE")
        ibuf_low_pwr => false,  -- Low Power - "TRUE", High Performance = "FALSE"
        iostandard   => "BLVDS_25"      -- Specify the I/O standard
        )
      port map (
        o   => ,                        -- Buffer output for further use
        io  => ,  -- Diff_p inout (connect directly to top-level port)
        iob => ,  -- Diff_n inout (connect directly to top-level port)
        i   => ,                        -- Buffer input
        t   => wb_trig_trigger_dir_o  -- 3-state enable input, high=output, low=input
        );

    -- iobuf connected to the transm and rcv components and to the other iobuf
    cmp_iobufds_cores : iobufds
      generic map (
        diff_term    => true,   -- Differential Termination ("TRUE"/"FALSE")
        ibuf_low_pwr => false,  -- Low Power - "TRUE", High Performance = "FALSE"
        iostandard   => "BLVDS_25"      -- Specify the I/O standard
        )
      port map (
        o   => ,                        -- Buffer output for further use
        io  => ,  -- Diff_p inout (connect directly to top-level port)
        iob => ,  -- Diff_n inout (connect directly to top-level port)
        i   => ,                        -- Buffer input
        t   => wb_trig_trigger_dir_o  -- 3-state enable input, high=output, low=input
        );

  end generate trigger_rcv_transm_0_3;

end architecture rtl;
