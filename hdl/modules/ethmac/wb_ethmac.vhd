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

entity wb_ethmac is
generic (
  g_ma_interface_mode                       : t_wishbone_interface_mode      := CLASSIC;
  g_ma_address_granularity                  : t_wishbone_address_granularity := WORD;
  g_sl_interface_mode                       : t_wishbone_interface_mode      := CLASSIC;
  g_sl_address_granularity                  : t_wishbone_address_granularity := WORD
);
port(
  -- WISHBONE common
  wb_clk_i                                    : in std_logic;
  wb_rst_i                                    : in std_logic;

  -- WISHBONE slave
  wb_dat_i                                  : in std_logic_vector(31 downto 0);
  wb_dat_o                                  : out std_logic_vector(31 downto 0);
  wb_adr_i                                  : in std_logic_vector(11 downto 0);
  wb_sel_i                                    : in std_logic_vector(3 downto 0);
  wb_we_i                                      : in std_logic;
  wb_cyc_i                                    : in std_logic;
  wb_stb_i                                    : in std_logic;
  wb_ack_o                                    : out std_logic;
  wb_err_o                                    : out std_logic;
  wb_stall_o                                : out std_logic;
  --wb_rty_o                                  : out std_logic;

  -- WISHBONE master
  m_wb_adr_o                                : out std_logic_vector(31 downto 0);
  m_wb_sel_o                                : out std_logic_vector(3 downto 0);
  m_wb_we_o                                    : out std_logic;
  m_wb_dat_o                                : out std_logic_vector(31 downto 0);
  m_wb_dat_i                                : in std_logic_vector(31 downto 0);
  m_wb_cyc_o                                : out std_logic;
  m_wb_stb_o                                : out std_logic;
  m_wb_ack_i                                : in std_logic;
  m_wb_err_i                                : in std_logic;
  m_wb_stall_i                              : in std_logic;
  --m_wb_rty_i                                : in std_logic;

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
end wb_ethmac;

architecture rtl of wb_ethmac is

  signal wb_sl_in                           : t_wishbone_slave_in;
  signal wb_sl_out                          : t_wishbone_slave_out;

  signal wb_ma_in                           : t_wishbone_master_in;
  signal wb_ma_out                          : t_wishbone_master_out;

  signal rst_n                              : std_logic;

  constant c_periph_addr_size               : natural := 12;
  signal resized_addr                       : std_logic_vector(c_wishbone_address_width-1 downto 0);

  component ethmac
  port(
    -- WISHBONE common
    wb_clk_i                                  : in std_logic;
    wb_rst_i                                  : in std_logic;

    -- WISHBONE slave
    wb_dat_i                                : in std_logic_vector(31 downto 0);
    wb_dat_o                                : out std_logic_vector(31 downto 0);
    wb_adr_i                                : in std_logic_vector(11 downto 2);
    wb_sel_i                                  : in std_logic_vector(3 downto 0);
    wb_we_i                                    : in std_logic;
    wb_cyc_i                                  : in std_logic;
    wb_stb_i                                  : in std_logic;
    wb_ack_o                                  : out std_logic;
    wb_err_o                                  : out std_logic;

    -- WISHBONE master
    m_wb_adr_o                              : out std_logic_vector(31 downto 0);
    m_wb_sel_o                              : out std_logic_vector(3 downto 0);
    m_wb_we_o                                  : out std_logic;
    m_wb_dat_o                              : out std_logic_vector(31 downto 0);
    m_wb_dat_i                              : in std_logic_vector(31 downto 0);
    m_wb_cyc_o                              : out std_logic;
    m_wb_stb_o                              : out std_logic;
    m_wb_ack_i                              : in std_logic;
    m_wb_err_i                              : in std_logic;

    -- PHY TX
    mtx_clk_pad_i                           : in std_logic;
    mtxd_pad_o                              : out std_logic_vector(3 downto 0);
    mtxen_pad_o                             : out std_logic;
    mtxerr_pad_o                            : out std_logic;

    -- PHY RX
    mrx_clk_pad_i                              : in std_logic;
    mrxd_pad_i                              : in std_logic_vector(3 downto 0);
    mrxdv_pad_i                                : in std_logic;
    mrxerr_pad_i                            : in std_logic;
    mcoll_pad_i                                : in std_logic;
    mcrs_pad_i                              : in std_logic;

    -- MII
    mdc_pad_o                               : out std_logic;
    md_pad_i                                : in std_logic;
    md_pad_o                                : out std_logic;
    md_padoe_o                              : out std_logic;

    -- Interrupt
    int_o                                        : out std_logic
  );
  end component;

begin
  rst_n                                     <= not wb_rst_i;

  resized_addr(c_periph_addr_size-1 downto 0)
                                            <= wb_adr_i;
  resized_addr(c_wishbone_address_width-1 downto c_periph_addr_size)
                                            <= (others => '0');

  -- ETHMAC slave interface is byte addressed, classic wishbone
  cmp_sl_iface_slave_adapter : wb_slave_adapter
  generic map (
    g_master_use_struct                     => true,
    g_master_mode                           => CLASSIC,
    g_master_granularity                    => BYTE,
    g_slave_use_struct                      => false,
    g_slave_mode                            => g_sl_interface_mode,
    g_slave_granularity                     => g_sl_address_granularity
  )
  port map (
    clk_sys_i                               => wb_clk_i,
    rst_n_i                                 => rst_n,
    master_i                                => wb_sl_out,
    master_o                                => wb_sl_in,
    sl_adr_i                                => resized_addr,
    sl_dat_i                                => wb_dat_i,
    sl_sel_i                                => wb_sel_i,
    sl_cyc_i                                => wb_cyc_i,
    sl_stb_i                                => wb_stb_i,
    sl_we_i                                 => wb_we_i,
    sl_dat_o                                => wb_dat_o,
    sl_ack_o                                => wb_ack_o,
    sl_stall_o                              => wb_stall_o,
    --sl_int_o                                => wb_int_o,
    --sl_rty_o                                => wb_rty_o,
    sl_err_o                                => wb_err_o
  );

  -- Unused slave signals
  wb_sl_out.rty                             <= '0';
  wb_sl_out.stall                           <= '0';
  wb_sl_out.int                             <= '0';

  -- ETHMAC master interface is byte addressed, classic wishbone
  cmp_ma_iface_slave_adapter : wb_slave_adapter
  generic map (
    g_master_use_struct                     => false,
    g_master_mode                           => g_ma_interface_mode,
    g_master_granularity                    => g_ma_address_granularity,
    g_slave_use_struct                      => true,
    g_slave_mode                            => CLASSIC,
    g_slave_granularity                     => BYTE
  )
  port map (
    clk_sys_i                               => wb_clk_i,
    rst_n_i                                 => rst_n,
    slave_i                                 => wb_ma_out,
    slave_o                                 => wb_ma_in,
    ma_adr_o                                => m_wb_adr_o,
    ma_dat_o                                => m_wb_dat_o,
    ma_sel_o                                => m_wb_sel_o,
    ma_cyc_o                                => m_wb_cyc_o,
    ma_stb_o                                => m_wb_stb_o,
    ma_we_o                                 => m_wb_we_o,
    ma_dat_i                                => m_wb_dat_i,
    ma_ack_i                                => m_wb_ack_i,
    ma_stall_i                              => m_wb_stall_i,
    --ma_int_i                                => m_wb_int_i,
    --ma_rty_i                                => m_wb_rty_i,
    ma_err_i                                => m_wb_err_i
  );

  -- Unused slave signals
  --wb_ma_in.rty                              <= '0';
  --wb_ma_in.stall                            <= '0';
  --wb_ma_in.int                              <= '0';

  cmp_wrapper_ethmac : ethmac
  port map (
    -- WISHBONE common
    wb_clk_i                                  => wb_clk_i,
    wb_rst_i                                  => wb_rst_i,

    -- WISHBONE slave
    wb_dat_i                                => wb_sl_in.dat,
    wb_dat_o                                => wb_sl_out.dat,
    wb_adr_i                                => wb_sl_in.adr(11 downto 2),
    wb_sel_i                                  => wb_sl_in.sel,
    wb_we_i                                    => wb_sl_in.we,
    wb_cyc_i                                  => wb_sl_in.cyc,
    wb_stb_i                                  => wb_sl_in.stb,
    wb_ack_o                                  => wb_sl_out.ack,
    wb_err_o                                  => wb_sl_out.err,

    -- WISHBONE master
    m_wb_adr_o                              => wb_ma_out.adr,
    m_wb_sel_o                              => wb_ma_out.sel,
    m_wb_we_o                               => wb_ma_out.we,
    m_wb_dat_o                              => wb_ma_out.dat,
    m_wb_dat_i                              => wb_ma_in.dat,
    m_wb_cyc_o                              => wb_ma_out.cyc,
    m_wb_stb_o                              => wb_ma_out.stb,
    m_wb_ack_i                              => wb_ma_in.ack,
    m_wb_err_i                              => wb_ma_in.err,

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
