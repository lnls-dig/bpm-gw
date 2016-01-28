------------------------------------------------------------------------
-- Title      : Wishbone MLVDS Trigger Interface
-- Project    :
-------------------------------------------------------------------------------
-- File       : wb_mlvds_trigger.vhd
-- Author     : Vitor Finotti Ferreira  <vfinotti@finotti-Inspiron-7520>
-- Company    : Brazilian Synchrotron Light Laboratory, LNLS/CNPEM
-- Created    : 2016-01-22
-- Last update: 2016-01-28
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
-- Reset Synch
use work.dbe_common_pkg.all;
-- General common cores
use work.gencores_pkg.all;

-- For Xilinx primitives
library unisim;
use unisim.vcomponents.all;

entity wb_mlvds_trigger is
  generic (
    g_width_bus_size       : positive := 8;
    g_rcv_len_bus_width    : positive := 8;
    g_transm_len_bus_width : positive := 8;
    g_sync_edge            : string   := "positive";
    g_trig_num             : positive := 8
    );

  port (
    clk_i   : in std_logic;
    rst_n_i : in std_logic;

    -------------------------------
    ---- Wishbone Control Interface signals
    -------------------------------

    wb_adr_i   : in  std_logic_vector(2 downto 0)  := (others => '0');
    wb_dat_i   : in  std_logic_vector(31 downto 0) := (others => '0');
    wb_dat_o   : out std_logic_vector(31 downto 0);
    wb_sel_i   : in  std_logic_vector(3 downto 0)  := (others => '0');
    wb_we_i    : in  std_logic                     := '0';
    wb_cyc_i   : in  std_logic                     := '0';
    wb_stb_i   : in  std_logic                     := '0';
    wb_ack_o   : out std_logic;
    wb_err_o   : out std_logic;
    wb_rty_o   : out std_logic;
    wb_stall_o : out std_logic;

    -------------------------------
    ---- External ports
    -------------------------------

    ---- Trigger
    trig_dir_o  : out std_logic_vector(g_trig_num-1 downto 0);
    trig_term_o : out std_logic_vector(g_trig_num-1 downto 0);

    trig_pulse_transm_i : in    std_logic_vector(g_trig_num-1 downto 0);
    trig_pulse_rcv_o    : out   std_logic_vector(g_trig_num-1 downto 0);
    trig_extended_b     : inout std_logic_vector(g_trig_num-1 downto 0)
    );

end entity wb_mlvds_trigger;

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

      wb_trig_rcv_len_0_3_o      : out std_logic_vector(31 downto 0);
      wb_trig_rcv_len_4_7_o      : out std_logic_vector(31 downto 0);
      wb_trig_transm_len_0_3_o   : out std_logic_vector(31 downto 0);
      wb_trig_transm_len_4_7_o   : out std_logic_vector(31 downto 0);
      wb_trig_trigger_dir_o      : out std_logic_vector(7 downto 0);
      wb_trig_trigger_term_o     : out std_logic_vector(7 downto 0);
      wb_trig_trigger_trig_val_o : out std_logic_vector(7 downto 0));
  end component wb_slave_mlvds_trigger;

  component extend_pulse_dyn is
    generic (
      g_width_bus_size : natural);
    port (
      clk_i         : in  std_logic;
      rst_n_i       : in  std_logic;
      pulse_i       : in  std_logic;
      pulse_width_i : in  unsigned(g_width_bus_size-1 downto 0);
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

  signal wb_trig_rcv_len_0_3      : std_logic_vector(31 downto 0);
  signal wb_trig_rcv_len_4_7      : std_logic_vector(31 downto 0);
  signal wb_trig_transm_len_0_3   : std_logic_vector(31 downto 0);
  signal wb_trig_transm_len_4_7   : std_logic_vector(31 downto 0);
  signal wb_trig_trigger_dir      : std_logic_vector(7 downto 0);
  signal wb_trig_trigger_term     : std_logic_vector(7 downto 0);
  signal wb_trig_trigger_trig_val : std_logic_vector(7 downto 0);


  signal extended_rcv : std_logic_vector(g_trig_num-1 downto 0);
  signal extended_transm : std_logic_vector(g_trig_num-1 downto 0);

  signal trigger_dir_n : std_logic_vector(g_trig_num-1 downto 0);

begin  -- architecture rtl

  -- 'high' dir signal represents 'rcv', and 'low' represents 'transm' (see iobufs to understand)
  trigger_dir_n <= not(wb_trig_trigger_dir);


  wb_slave_mlvds_trigger_1 : entity work.wb_slave_mlvds_trigger
    port map (
      rst_n_i                    => rst_n_i,
      clk_sys_i                  => clk_i,
      wb_adr_i                   => wb_adr_i,
      wb_dat_i                   => wb_dat_i,
      wb_dat_o                   => wb_dat_o,
      wb_cyc_i                   => wb_cyc_i,
      wb_sel_i                   => wb_sel_i,
      wb_stb_i                   => wb_stb_i,
      wb_we_i                    => wb_we_i,
      wb_ack_o                   => wb_ack_o,
      wb_stall_o                 => wb_stall_o,
      wb_trig_rcv_len_0_3_o      => wb_trig_rcv_len_0_3,
      wb_trig_rcv_len_4_7_o      => wb_trig_rcv_len_4_7,
      wb_trig_transm_len_0_3_o   => wb_trig_transm_len_0_3,
      wb_trig_transm_len_4_7_o   => wb_trig_transm_len_4_7,
      wb_trig_trigger_dir_o      => wb_trig_trigger_dir,
      wb_trig_trigger_term_o     => wb_trig_trigger_term,
      wb_trig_trigger_trig_val_o => wb_trig_trigger_trig_val);

  ---------------------------
  -- Instantiation Process --
  ---------------------------

  trigger_rcv_transm : for i in g_trig_num-1 downto 0 generate

    -- Ports 0 to 3
    ports_0_to_3 : if i <= 3 generate

      trigger_transm : entity work.extend_pulse_dyn
        generic map (
          g_width_bus_size => g_width_bus_size)
        port map (
          clk_i         => clk_i,
          rst_n_i       => rst_n_i,
          pulse_i       => trig_pulse_transm_i(i),
          pulse_width_i => unsigned(wb_trig_transm_len_0_3((8*i+7) downto 8*i)),
          extended_o    => extended_transm(i));

      trigger_rcv_1 : entity work.trigger_rcv
        generic map (
          g_glitch_len_width => g_rcv_len_bus_width,
          g_sync_edge        => g_sync_edge)
        port map (
          clk_i   => clk_i,
          rst_n_i => rst_n_i,
          len_i   => wb_trig_rcv_len_0_3((8*i+7) downto 8*i),
          data_i  => extended_rcv(i),
          pulse_o => trig_pulse_rcv_o(i));

    end generate ports_0_to_3;

    -- Ports 4 to 7
    ports_4_to_7 : if i > 3 generate

      trigger_transm : entity work.extend_pulse_dyn
        generic map (
          g_width_bus_size => g_width_bus_size)
        port map (
          clk_i         => clk_i,
          rst_n_i       => rst_n_i,
          pulse_i       => trig_pulse_transm_i(i),
          pulse_width_i => unsigned(wb_trig_transm_len_4_7((8*(i-4)+7) downto 8*(i-4))),
          extended_o    => extended_transm(i));

      trigger_rcv_1 : entity work.trigger_rcv
        generic map (
          g_glitch_len_width => g_rcv_len_bus_width,
          g_sync_edge        => g_sync_edge)
        port map (
          clk_i   => clk_i,
          rst_n_i => rst_n_i,
          len_i   => wb_trig_rcv_len_4_7((8*(i-4)+7) downto 8*(i-4)),
          data_i  => extended_rcv(i),
          pulse_o => trig_pulse_rcv_o(i));

    end generate ports_4_to_7;

    --------------------------------
    -- Connects cores to backplane
    --------------------------------

    cmp_iobuf : iobuf
      port map (
        o  => extended_rcv(i),          -- Buffer output for further use
        io => trig_extended_b(i),  -- inout (connect directly to top-level port)
        i  => extended_transm(i),       -- Buffer input
        t  => wb_trig_trigger_dir(i)  -- 3-state enable input, high=input, low=output
        );

  end generate trigger_rcv_transm;

end architecture rtl;
