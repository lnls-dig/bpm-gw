-------------------------------------------------------------------------------
-- Title      : Wishbone Packet Fabric buffered packet sink
-- Project    : WR Cores Collection
-------------------------------------------------------------------------------
-- File       : xwb_fabric_sink.vhd
-- Author     : Tomasz Wlostowski
-- Company    : CERN BE-CO-HT
-- Created    : 2012-01-16
-- Last update: 2012-01-22
-- Platform   :
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: A simple WB packet streaming sink with builtin FIFO buffer.
-- Outputs a trivial interface (start-of-packet, end-of-packet, data-valid)
-------------------------------------------------------------------------------
--
-- Copyright (c) 2011 CERN
--
-- This source file is free software; you can redistribute it
-- and/or modify it under the terms of the GNU Lesser General
-- Public License as published by the Free Software Foundation;
-- either version 2.1 of the License, or (at your option) any
-- later version.
--
-- This source is distributed in the hope that it will be
-- useful, but WITHOUT ANY WARRANTY; without even the implied
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
-- PURPOSE.  See the GNU Lesser General Public License for more
-- details.
--
-- You should have received a copy of the GNU Lesser General
-- Public License along with this source; if not, download it
-- from http://www.gnu.org/licenses/lgpl-2.1.html
--
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2011-01-16  1.0      twlostow        Created
-------------------------------------------------------------------------------
--
-- Modified by Lucas Russo <lucas.russo@lnls.br> for multiple width support

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.genram_pkg.all;
use work.wb_stream_generic_pkg.all;

entity xwb_stream_sink is
generic (
  --g_wbs_adr_width                         : natural := c_wbs_adr4_width;
  g_wbs_dat_width                         : t_wbs_interface_width := LARGE1
);
port (
  clk_i                                   : in std_logic;
  rst_n_i                                 : in std_logic;

  -- Wishbone Fabric Interface I/O.
  -- Only the used interface must be connected. The others can be left unconnected
  -- 16-bit interface
  snk16_i                                 : in  t_wbs_sink_in16 := cc_dummy_snk_in16;
  snk16_o                                 : out t_wbs_sink_out16;
  -- 32-bit interface
  snk32_i                                 : in  t_wbs_sink_in32 := cc_dummy_snk_in32;
  snk32_o                                 : out t_wbs_sink_out32;
  -- 64-bit interface
  snk64_i                                 : in  t_wbs_sink_in64 := cc_dummy_snk_in64;
  snk64_o                                 : out t_wbs_sink_out64;
  -- 128-bit interface
  snk128_i                                : in  t_wbs_sink_in128 := cc_dummy_snk_in128;
  snk128_o                                : out t_wbs_sink_out128;

  -- Decoded & buffered logic
  -- Only the used interface must be connected. The others can be left unconnected
  -- 16-bit interface
  adr16_o                                 : out std_logic_vector(c_wbs_adr4_width-1 downto 0);
  dat16_o                                 : out std_logic_vector(c_wbs_dat16_width-1 downto 0);
  sel16_o                                 : out std_logic_vector(c_wbs_sel16_width-1 downto 0);
  -- 32-bit interface
  adr32_o                                 : out std_logic_vector(c_wbs_adr4_width-1 downto 0);
  dat32_o                                 : out std_logic_vector(c_wbs_dat32_width-1 downto 0);
  sel32_o                                 : out std_logic_vector(c_wbs_sel32_width-1 downto 0);
  -- 64-bit interface
  adr64_o                                 : out std_logic_vector(c_wbs_adr4_width-1 downto 0);
  dat64_o                                 : out std_logic_vector(c_wbs_dat64_width-1 downto 0);
  sel64_o                                 : out std_logic_vector(c_wbs_sel64_width-1 downto 0);
  -- 128-bit interface
  adr128_o                                : out std_logic_vector(c_wbs_adr4_width-1 downto 0);
  dat128_o                                : out std_logic_vector(c_wbs_dat128_width-1 downto 0);
  sel128_o                                : out std_logic_vector(c_wbs_sel128_width-1 downto 0);

  -- Common lines
  dvalid_i                                : out std_logic;
  sof_i                                   : out std_logic;
  eof_i                                   : out std_logic;
  error_i                                 : out std_logic;
  dreq_o                                  : in std_logic := '0'
);
end xwb_stream_sink;

architecture rtl of xwb_stream_sink is
  signal snk_cyc_int                        : std_logic;
  signal snk_stb_int                        : std_logic;
  signal snk_we_int                         : std_logic;
  signal snk_ack_int                        : std_logic;
  signal snk_stall_int                      : std_logic;
  signal snk_err_int                        : std_logic;
  signal snk_rty_int                        : std_logic;

begin
  -----------------------------
  -- Wishbone Streaming Interface selection
  -----------------------------
  gen_16_bit_interface : if g_wbs_interface_width = NARROW2 generate
    snk_cyc_int                             <= snk16_i.cyc;
    snk_stb_int                             <= snk16_i.stb;
    snk_we_int                              <= snk16_i.we;
    snk16_o.ack                             <= snk_ack_int;
    snk16_o.stall                           <= snk_stall_int;
    snk16_o.err                             <= snk_err_int;
    snk16_o.rty                             <= snk_rty_int;
  end generate;

  gen_32_bit_interface : if g_wbs_interface_width = NARROW1 generate
    snk_cyc_int                             <= snk32_i.cyc;
    snk_stb_int                             <= snk32_i.stb;
    snk_we_int                              <= snk32_i.we;
    snk32_o.ack                             <= snk_ack_int;
    snk32_o.stall                           <= snk_stall_int;
    snk32_o.err                             <= snk_err_int;
    snk32_o.rty                             <= snk_rty_int;
  end generate;

  gen_64_bit_interface : if g_wbs_interface_width = LARGE1 generate
    snk_cyc_int                             <= snk64_i.cyc;
    snk_stb_int                             <= snk64_i.stb;
    snk_we_int                              <= snk64_i.we;
    snk64_o.ack                             <= snk_ack_int;
    snk64_o.stall                           <= snk_stall_int;
    snk64_o.err                             <= snk_err_int;
    snk64_o.rty                             <= snk_rty_int;
  end generate;

  gen_128_bit_interface : if g_wbs_interface_width = LARGE2 generate
    snk_cyc_int                             <= snk128_i.cyc;
    snk_stb_int                             <= snk128_i.stb;
    snk_we_int                              <= snk128_i.we;
    snk128_o.ack                            <= snk_ack_int;
    snk128_o.stall                          <= snk_stall_int;
    snk128_o.err                            <= snk_err_int;
    snk128_o.rty                            <= snk_rty_int;
  end generate;

  cmp_wb_stream_sink : wb_stream_sink
  generic map (
    --g_wbs_adr_width                         : natural := c_wbs_adr4_width;
    g_wbs_dat_width                           : t_wbs_interface_width := LARGE1
  )
  port map(
    clk_i                                     => clk_i,
    rst_n_i                                   => rst_n_i,

    -- Wishbone Streaming Interface I/O.
    -- Only the used interface should be connected. The others can be left unconnected
    -- 16-bit interface
    snk_adr16_i                               => snk16_i.adr,
    snk_dat16_i                               => snk16_i.dat,
    snk_sel16_i                               => snk16_i.sel,

    -- 32-bit interface
    snk_adr32_i                               => snk32_i.adr,
    snk_dat32_i                               => snk32_i.dat,
    snk_sel32_i                               => snk32_i.sel,

    -- 64-bit interface
    snk_adr64_i                               => snk64_i.adr,
    snk_dat64_i                               => snk64_i.dat,
    snk_sel64_i                               => snk64_i.sel,

    -- 128-bit interface
    snk_adr128_i                              => snk128_i.adr,
    snk_dat128_i                              => snk128_i.dat,
    snk_sel128_i                              => snk128_i.sel,

    -- Common Wishbone Streaming lines
    snk_cyc_i                                 => snk_cyc_int,
    snk_stb_i                                 => snk_stb_int,
    snk_we_i                                  => snk_we_int,
    snk_ack_o                                 => snk_ack_int,
    snk_stall_o                               => snk_stall_int,
    snk_err_o                                 => snk_err_int,
    snk_rty_o                                 => snk_rty_int,

    -- Decoded & buffered logic
    -- Only the used interface must be connected. The others can be left unconnected
    -- 16-bit interface
    adr16_o                                 => adr16_o,
    dat16_o                                 => dat16_o,
    sel16_o                                 => sel16_o,
    -- 32-bit interface                               ,
    adr32_o                                 => adr32_o,
    dat32_o                                 => dat32_o,
    sel32_o                                 => sel32_o,
    -- 64-bit interface                               ,
    adr64_o                                 => adr64_o,
    dat64_o                                 => dat64_o,
    sel64_o                                 => sel64_o,
    -- 128-bit interface
    adr128_o                                => adr128_o,
    dat128_o                                => dat128_o,
    sel128_o                                => sel128_o,

    -- Common lines
    dvalid_i                                => dvalid_i,
    sof_i                                   => sof_i,
    eof_i                                   => eof_i,
    error_i                                 => error_i,
    dreq_o                                  => dreq_o
  );
end rtl;

