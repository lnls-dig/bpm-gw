------------------------------------------------------------------------------
-- Title      : AFC Diagnostics
------------------------------------------------------------------------------
-- Author     : Andrzej Wojenski, Grzegorz Kasprowicz, Lucas Russo (only this wrapper)
-- Company    :
-- Created    : 2015-09-03
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: Top Module for the AFC diagnostics, including uTCA slot and
-- temperature reading
-------------------------------------------------------------------------------
-- Copyright (c)
-- Licensed under GNU Lesser General Public License (LGPL) v3.0
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2015-09-03  1.0                        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
-- Main Wishbone Definitions
use work.wishbone_pkg.all;
-- DBE Wishbone Definitions
use work.dbe_wishbone_pkg.all;

entity xwb_afc_diag is
generic
(
  g_interface_mode                          : t_wishbone_interface_mode      := CLASSIC;
  g_address_granularity                     : t_wishbone_address_granularity := WORD
);
port
(
  sys_clk_i                                 : in std_logic;
  sys_rst_n_i                               : in std_logic;

  -- Fast SPI clock
  spi_clk_i                                 : in std_logic;

  -----------------------------
  -- Wishbone Control Interface signals
  -----------------------------
  wb_slv_i                                  : in t_wishbone_slave_in;
  wb_slv_o                                  : out t_wishbone_slave_out;

  dbg_spi_clk_o                             : out std_logic;
  dbg_spi_valid_o                           : out std_logic;
  dbg_en_o                                  : out std_logic;
  dbg_addr_o                                : out std_logic_vector(7 downto 0);
  dbg_serial_data_o                         : out std_logic_vector(31 downto 0);
  dbg_spi_data_o                            : out std_logic_vector(31 downto 0);

  -----------------------------
  -- SPI interface
  -----------------------------

  spi_cs                                    : in  std_logic;
  spi_si                                    : in  std_logic;
  spi_so                                    : out std_logic;
  spi_clk                                   : in  std_logic
);
end xwb_afc_diag;

architecture rtl of xwb_afc_diag is

begin

  cmp_wb_afc_diag : wb_afc_diag
  generic map
  (
    g_interface_mode                          => g_interface_mode,
    g_address_granularity                     => g_address_granularity
  )
  port map
  (
    sys_clk_i                                 => sys_clk_i,
    sys_rst_n_i                               => sys_rst_n_i,

    -- Fast SPI clock
    spi_clk_i                                 => spi_clk_i,

    -----------------------------
    -- Wishbone Control Interface signals
    -----------------------------

    wb_adr_i                                  => wb_slv_i.adr,
    wb_dat_i                                  => wb_slv_i.dat,
    wb_dat_o                                  => wb_slv_o.dat,
    wb_sel_i                                  => wb_slv_i.sel,
    wb_we_i                                   => wb_slv_i.we,
    wb_cyc_i                                  => wb_slv_i.cyc,
    wb_stb_i                                  => wb_slv_i.stb,
    wb_ack_o                                  => wb_slv_o.ack,
    wb_err_o                                  => wb_slv_o.err,
    wb_rty_o                                  => wb_slv_o.rty,
    wb_stall_o                                => wb_slv_o.stall,

    dbg_spi_clk_o                             => dbg_spi_clk_o,
    dbg_spi_valid_o                           => dbg_spi_valid_o,
    dbg_en_o                                  => dbg_en_o,
    dbg_addr_o                                => dbg_addr_o,
    dbg_serial_data_o                         => dbg_serial_data_o,
    dbg_spi_data_o                            => dbg_spi_data_o,

    -----------------------------
    -- SPI interface
    -----------------------------

    spi_cs                                   => spi_cs,
    spi_si                                   => spi_si,
    spi_so                                   => spi_so,
    spi_clk                                  => spi_clk
  );

end rtl;
