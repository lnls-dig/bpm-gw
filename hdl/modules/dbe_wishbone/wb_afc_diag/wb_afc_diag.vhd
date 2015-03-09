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

entity wb_afc_diag is
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

  wb_adr_i                                  : in  std_logic_vector(c_wishbone_address_width-1 downto 0) := (others => '0');
  wb_dat_i                                  : in  std_logic_vector(c_wishbone_data_width-1 downto 0) := (others => '0');
  wb_dat_o                                  : out std_logic_vector(c_wishbone_data_width-1 downto 0);
  wb_sel_i                                  : in  std_logic_vector(c_wishbone_data_width/8-1 downto 0) := (others => '0');
  wb_we_i                                   : in  std_logic := '0';
  wb_cyc_i                                  : in  std_logic := '0';
  wb_stb_i                                  : in  std_logic := '0';
  wb_ack_o                                  : out std_logic;
  wb_err_o                                  : out std_logic;
  wb_rty_o                                  : out std_logic;
  wb_stall_o                                : out std_logic;

  -----------------------------
  -- SPI interface
  -----------------------------

  spi_cs                                    : in  std_logic;
  spi_si                                    : in  std_logic;
  spi_so                                    : out std_logic;
  spi_clk                                   : in  std_logic
);
end wb_afc_diag;

architecture rtl of wb_afc_diag is

  -----------------------------
  -- General Constants
  -----------------------------

  constant c_periph_addr_size               : natural := 8;

  ------------------------------------------------------------------------------
  -- Wishbone Adapater Signals
  ------------------------------------------------------------------------------

  -- Wishbone slave adapter signals/structures
  signal wb_slv_adp_out                     : t_wishbone_master_out;
  signal wb_slv_adp_in                      : t_wishbone_master_in;
  signal resized_addr                       : std_logic_vector(c_wishbone_address_width-1 downto 0);

  signal sys_rst                            : std_logic;

  component spi2wb
    port (
    wb_clk_i    : in std_logic;
    spi_clk_i   : in std_logic;
    wb_rst_i    : in std_logic;

    SPI_CS    : in std_logic;
    SPI_SI    : in std_logic;
    SPI_SO    : out std_logic;
    SPI_CLK   : in std_logic;

    wb_addr_i  : in  std_logic_vector(15 downto 0);
    wb_data_i  : in  std_logic_vector(31 downto 0);
    wb_data_o  : out std_logic_vector(31 downto 0);
    wb_cyc_i   : in  std_logic;
    wb_sel_i   : in  std_logic_vector(3 downto 0);
    wb_stb_i   : in  std_logic;
    wb_we_i    : in  std_logic;
    wb_ack_o   : out std_logic
  );
  end component;

begin

  sys_rst <= not sys_rst_n_i;

  -----------------------------
  -- Slave adapter for Wishbone Register Interface
  -----------------------------
  cmp_slave_adapter : wb_slave_adapter
  generic map (
    g_master_use_struct                     => true,
    g_master_mode                           => CLASSIC,
    g_master_granularity                    => WORD,
    g_slave_use_struct                      => false,
    g_slave_mode                            => g_interface_mode,
    g_slave_granularity                     => g_address_granularity
  )
  port map (
    clk_sys_i                               => sys_clk_i,
    rst_n_i                                 => sys_rst_n_i,
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
    sl_rty_o                                => wb_rty_o,
    sl_err_o                                => wb_err_o,
    sl_int_o                                => open,
    sl_stall_o                              => wb_stall_o
  );

  resized_addr(c_periph_addr_size-1 downto 0)
                                            <= wb_adr_i(c_periph_addr_size-1 downto 0);
  resized_addr(c_wishbone_address_width-1 downto c_periph_addr_size)
                                            <= (others => '0');

  cmp_spi2wb : spi2wb
  port map (
    wb_clk_i                                => sys_clk_i,
    -- Fast SPI clock
    spi_clk_i                               => spi_clk_i,
    wb_rst_i                                => sys_rst,

    -- SPI bus
    SPI_CS                                  => spi_cs,
    SPI_SI                                  => spi_si,
    SPI_SO                                  => spi_so,
    SPI_CLK                                 => spi_clk,

    -- Wishbone bus
    wb_addr_i                               => wb_slv_adp_out.adr(15 downto 0),
    wb_data_i                               => wb_slv_adp_out.dat,
    wb_data_o                               => wb_slv_adp_in.dat,
    wb_cyc_i                                => wb_slv_adp_out.cyc,
    wb_sel_i                                => wb_slv_adp_out.sel,
    wb_stb_i                                => wb_slv_adp_out.stb,
    wb_we_i                                 => wb_slv_adp_out.we,
    wb_ack_o                                => wb_slv_adp_in.ack
  );

end rtl;
