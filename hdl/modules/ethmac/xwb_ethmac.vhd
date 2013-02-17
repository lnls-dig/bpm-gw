------------------------------------------------------------------------------
-- Title      : Wishbone Ethernet MAC Wrapper
------------------------------------------------------------------------------
-- Author     : Lucas Maziero Russo
-- Company    : CNPEM LNLS-DIG
-- Created    : 2012-11-12
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: Wishbone Wrapper for ETH MAC from Opencores and modified by
--                OpenRISC project
-------------------------------------------------------------------------------
-- Copyright (c) 2012 CNPEM
-- Licensed under GNU Lesser General Public License (LGPL) v3.0
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2012-11-12  1.0      lucas.russo        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.wishbone_pkg.all;
use work.ethmac_pkg.all;

entity xwb_ethmac is
generic (
  g_ma_interface_mode                       : t_wishbone_interface_mode      := PIPELINED;
  g_ma_address_granularity                  : t_wishbone_address_granularity := BYTE;
  g_sl_interface_mode                       : t_wishbone_interface_mode      := PIPELINED;
  g_sl_address_granularity                  : t_wishbone_address_granularity := BYTE
);
port(
  -- WISHBONE common
  wb_clk_i                                    : in std_logic;
  wb_rst_i                                    : in std_logic;

  -- WISHBONE slave
  wb_slave_in                               : in t_wishbone_slave_in;
  wb_slave_out                              : out t_wishbone_slave_out;

  -- WISHBONE master
  wb_master_in                              : in t_wishbone_master_in;
  wb_master_out                             : out t_wishbone_master_out;

  -- PHY TX
  mtx_clk_pad_i                             : in std_logic;
  mtxd_pad_o                                : out std_logic_vector(3 downto 0);
  mtxen_pad_o                               : out std_logic;
  mtxerr_pad_o                              : out std_logic;

  -- PHY RX
  mrx_clk_pad_i                                : in std_logic;
  mrxd_pad_i                                : in std_logic_vector(3 downto 0);
  mrxdv_pad_i                                  : in std_logic;
  mrxerr_pad_i                              : in std_logic;
  mcoll_pad_i                                  : in std_logic;
  mcrs_pad_i                                : in std_logic;

  -- MII
  mdc_pad_o                                 : out std_logic;
  md_pad_i                                  : in std_logic;
  md_pad_o                                  : out std_logic;
  md_padoe_o                                : out std_logic;

  -- Interrupt
  int_o                                          : out std_logic
);
end xwb_ethmac;

architecture rtl of xwb_ethmac is

begin

  cmp_wrapper_wb_ethmac : wb_ethmac
  generic map (
    g_ma_interface_mode                     => g_ma_interface_mode,
    g_ma_address_granularity                => g_ma_address_granularity,
    g_sl_interface_mode                     => g_sl_interface_mode,
    g_sl_address_granularity                => g_sl_address_granularity
  )
  port map(
    -- WISHBONE common
    wb_clk_i                                  => wb_clk_i,
    wb_rst_i                                  => wb_rst_i,

    -- WISHBONE slave
    wb_dat_i                                => wb_slave_in.dat,
    wb_dat_o                                => wb_slave_out.dat,
    wb_adr_i                                => wb_slave_in.adr(11 downto 0),
    wb_sel_i                                  => wb_slave_in.sel,
    wb_we_i                                    => wb_slave_in.we,
    wb_cyc_i                                  => wb_slave_in.cyc,
    wb_stb_i                                  => wb_slave_in.stb,
    wb_ack_o                                  => wb_slave_out.ack,
    wb_err_o                                  => wb_slave_out.err,
    wb_stall_o                              => wb_slave_out.stall,
    --wb_rty_o                                => wb_slave_out.rty,

    -- WISHBONE master
    m_wb_adr_o                              => wb_master_out.adr,
    m_wb_sel_o                              => wb_master_out.sel,
    m_wb_we_o                                  => wb_master_out.we,
    m_wb_dat_o                              => wb_master_out.dat,
    m_wb_dat_i                              => wb_master_in.dat,
    m_wb_cyc_o                              => wb_master_out.cyc,
    m_wb_stb_o                              => wb_master_out.stb,
    m_wb_ack_i                              => wb_master_in.ack,
    m_wb_err_i                              => wb_master_in.err,
    m_wb_stall_i                            => wb_master_in.stall,
    --m_wb_rty_i                              => wb_master_in.rty,

    -- PHY TX
    mtx_clk_pad_i                           => mtx_clk_pad_i,
    mtxd_pad_o                              => mtxd_pad_o,
    mtxen_pad_o                             => mtxen_pad_o,
    mtxerr_pad_o                            => mtxerr_pad_o,

    -- PHY RX
    mrx_clk_pad_i                              => mrx_clk_pad_i,
    mrxd_pad_i                              => mrxd_pad_i,
    mrxdv_pad_i                                => mrxdv_pad_i,
    mrxerr_pad_i                            => mrxerr_pad_i,
    mcoll_pad_i                                => mcoll_pad_i,
    mcrs_pad_i                              => mcrs_pad_i,

    -- MII
    mdc_pad_o                               => mdc_pad_o,
    md_pad_i                                => md_pad_i,
    md_pad_o                                => md_pad_o,
    md_padoe_o                              => md_padoe_o,

    -- Interrupt
    int_o                                        => int_o
  );
end rtl;
