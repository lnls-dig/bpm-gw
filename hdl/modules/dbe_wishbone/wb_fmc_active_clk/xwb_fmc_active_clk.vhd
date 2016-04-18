------------------------------------------------------------------------------
-- Title      : Wishbone FMC Active Clock Interface
------------------------------------------------------------------------------
-- Author     : Lucas Maziero Russo
-- Company    : CNPEM LNLS-DIG
-- Created    : 2016-02-19
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: Top Module for the BPM with FMC250.
-------------------------------------------------------------------------------
-- Copyright (c) 2016 CNPEM
-- Licensed under GNU Lesser General Public License (LGPL) v3.0
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2016-02-19  1.0      lucas.russo        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
-- Main Wishbone Definitions
use work.wishbone_pkg.all;
-- Custom Wishbone Modules
use work.dbe_wishbone_pkg.all;

entity xwb_fmc_active_clk is
generic
(
  g_interface_mode                          : t_wishbone_interface_mode      := CLASSIC;
  g_address_granularity                     : t_wishbone_address_granularity := WORD;
  g_with_extra_wb_reg                       : boolean := false
);
port
(
  sys_clk_i                                 : in std_logic;
  sys_rst_n_i                               : in std_logic;

  -----------------------------
  -- Wishbone Control Interface signals
  -----------------------------

  wb_slv_i                                  : in t_wishbone_slave_in;
  wb_slv_o                                  : out t_wishbone_slave_out;

  -----------------------------
  -- External ports
  -----------------------------

  -- Si571 clock gen
  si571_scl_pad_b                           : inout std_logic;
  si571_sda_pad_b                           : inout std_logic;
  fmc_si571_oe_o                            : out std_logic;

  -- AD9510 clock distribution PLL
  spi_ad9510_cs_o                           : out std_logic;
  spi_ad9510_sclk_o                         : out std_logic;
  spi_ad9510_mosi_o                         : out std_logic;
  spi_ad9510_miso_i                         : in std_logic := '0';

  fmc_pll_function_o                        : out std_logic;
  fmc_pll_status_i                          : in std_logic := '0';

  -- AD9510 clock copy
  fmc_fpga_clk_p_i                          : in std_logic := '0';
  fmc_fpga_clk_n_i                          : in std_logic := '0';

  -- Clock reference selection (TS3USB221)
  fmc_clk_sel_o                             : out std_logic;

  -----------------------------
  -- General ADC output signals and status
  -----------------------------

  -- General board status
  fmc_pll_status_o                          : out std_logic;

  -- fmc_fpga_clk_*_i bypass signals
  fmc_fpga_clk_p_o                          : out std_logic;
  fmc_fpga_clk_n_o                          : out std_logic
);
end xwb_fmc_active_clk;

architecture rtl of xwb_fmc_active_clk is

begin

  cmp_wb_fmc_active_clk : wb_fmc_active_clk
  generic map (
    g_interface_mode                         => g_interface_mode,
    g_address_granularity                    => g_address_granularity,
    g_with_extra_wb_reg                      => g_with_extra_wb_reg
  )
  port map (
    sys_clk_i                                 => sys_clk_i,
    sys_rst_n_i                               => sys_rst_n_i,

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

    -----------------------------
    -- External ports
    -----------------------------

    -- Si571 clock gen
    si571_scl_pad_b                           => si571_scl_pad_b,
    si571_sda_pad_b                           => si571_sda_pad_b,
    fmc_si571_oe_o                            => fmc_si571_oe_o,

    -- AD9510 clock distribution PLL
    spi_ad9510_cs_o                           => spi_ad9510_cs_o,
    spi_ad9510_sclk_o                         => spi_ad9510_sclk_o,
    spi_ad9510_mosi_o                         => spi_ad9510_mosi_o,
    spi_ad9510_miso_i                         => spi_ad9510_miso_i,

    fmc_pll_function_o                        => fmc_pll_function_o,
    fmc_pll_status_i                          => fmc_pll_status_i,

    -- AD9510 clock copy
    fmc_fpga_clk_p_i                          => fmc_fpga_clk_p_i,
    fmc_fpga_clk_n_i                          => fmc_fpga_clk_n_i,

    -- Clock reference selection (TS3USB221)
    fmc_clk_sel_o                             => fmc_clk_sel_o,

    -----------------------------
    -- General ADC output signals and status
    -----------------------------

    -- General board status                      -- General board status
    fmc_pll_status_o                          => fmc_pll_status_o,

    -- fmc_fpga_clk_*_i bypass signals
    fmc_fpga_clk_p_o                          => fmc_fpga_clk_p_o,
    fmc_fpga_clk_n_o                          => fmc_fpga_clk_n_o
  );

end rtl;
