------------------------------------------------------------------------------
-- Title      : Wishbone FMC516 ADC Interface
------------------------------------------------------------------------------
-- Author     : Lucas Maziero Russo
-- Company    : CNPEM LNLS-DIG
-- Created    : 2012-12-12
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: Ethernet MAC general definitions
-------------------------------------------------------------------------------
-- Copyright (c) 2012 CNPEM
-- Licensed under GNU Lesser General Public License (LGPL) v3.0
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2012-12-12  1.0      lucas.russo        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
-- Main Wishbone Definitions
use work.wishbone_pkg.all;

package ethmac_pkg is

  -- Conponents
  component wb_ethmac
  generic (
    g_ma_interface_mode                     : t_wishbone_interface_mode      := CLASSIC;
    g_ma_address_granularity                : t_wishbone_address_granularity := WORD;
    g_sl_interface_mode                     : t_wishbone_interface_mode      := CLASSIC;
    g_sl_address_granularity                : t_wishbone_address_granularity := WORD
  );
  port(
    -- WISHBONE common
    wb_clk_i	                              : in std_logic;
    wb_rst_i	                              : in std_logic;

    -- WISHBONE slave
    wb_dat_i                                  : in std_logic_vector(31 downto 0);
    wb_dat_o                                  : out std_logic_vector(31 downto 0);
    wb_adr_i                                  : in std_logic_vector(11 downto 0);
    wb_sel_i	                                : in std_logic_vector(3 downto 0);
    wb_we_i	                                  : in std_logic;
    wb_cyc_i	                                : in std_logic;
    wb_stb_i	                                : in std_logic;
    wb_ack_o	                                : out std_logic;
    wb_err_o	                                : out std_logic;
    wb_stall_o                                : out std_logic;
    wb_rty_o                                  : out std_logic;

    -- WISHBONE master
    m_wb_adr_o                                : out std_logic_vector(31 downto 0);
    m_wb_sel_o                                : out std_logic_vector(3 downto 0);
    m_wb_we_o	                                : out std_logic;
    m_wb_dat_o                                : out std_logic_vector(31 downto 0);
    m_wb_dat_i                                : in std_logic_vector(31 downto 0);
    m_wb_cyc_o                                : out std_logic;
    m_wb_stb_o                                : out std_logic;
    m_wb_ack_i                                : in std_logic;
    m_wb_err_i                                : in std_logic;
    m_wb_stall_i                              : in std_logic;
    m_wb_rty_i                                : in std_logic;

    -- PHY TX
    mtx_clk_pad_i                           : in std_logic;
    mtxd_pad_o                              : out std_logic_vector(3 downto 0);
    mtxen_pad_o                             : out std_logic;
    mtxerr_pad_o                            : out std_logic;

    -- PHY RX
    mrx_clk_pad_i	                          : in std_logic;
    mrxd_pad_i                              : in std_logic_vector(3 downto 0);
    mrxdv_pad_i	                            : in std_logic;
    mrxerr_pad_i                            : in std_logic;
    mcoll_pad_i	                            : in std_logic;
    mcrs_pad_i                              : in std_logic;

    -- MII
    mdc_pad_o                               : out std_logic;
    md_pad_i                                : in std_logic;
    md_pad_o                                : out std_logic;
    md_padoe_o                              : out std_logic;

    -- Interrupt
    int_o		                                : out std_logic
  );
  end component;

  component xwb_ethmac
  generic (
    g_ma_interface_mode                     : t_wishbone_interface_mode      := CLASSIC;
    g_ma_address_granularity                : t_wishbone_address_granularity := WORD;
    g_sl_interface_mode                     : t_wishbone_interface_mode      := CLASSIC;
    g_sl_address_granularity                : t_wishbone_address_granularity := WORD
  );
  port(
    -- WISHBONE common
    wb_clk_i	                              : in std_logic;
    wb_rst_i	                              : in std_logic;

    -- WISHBONE slave
    wb_slave_in                             : in t_wishbone_slave_in;
    wb_slave_out                            : out t_wishbone_slave_out;

    -- WISHBONE master
    wb_master_in                            : in t_wishbone_master_in;
    wb_master_out                           : out t_wishbone_master_out;

    -- PHY TX
    mtx_clk_pad_i                           : in std_logic;
    mtxd_pad_o                              : out std_logic_vector(3 downto 0);
    mtxen_pad_o                             : out std_logic;
    mtxerr_pad_o                            : out std_logic;

    -- PHY RX
    mrx_clk_pad_i	                          : in std_logic;
    mrxd_pad_i                              : in std_logic_vector(3 downto 0);
    mrxdv_pad_i	                            : in std_logic;
    mrxerr_pad_i                            : in std_logic;
    mcoll_pad_i	                            : in std_logic;
    mcrs_pad_i                              : in std_logic;

    -- MII
    mdc_pad_o                               : out std_logic;
    md_pad_i                                : in std_logic;
    md_pad_o                                : out std_logic;
    md_padoe_o                              : out std_logic;

    -- Interrupt
    int_o		                                : out std_logic
  );
  end component;

  -- SDB for internal ethmac core
  constant c_xwb_ethmac_sdb : t_sdb_device := (
    abi_class     => x"0000", 				-- undocumented device
    abi_ver_major => x"01",
    abi_ver_minor => x"00",
    wbd_endian    => c_sdb_endian_big,
    wbd_width     => x"4", 					-- 32-bit port granularity (0100)
    sdb_component => (
    addr_first    => x"0000000000000000",
    addr_last     => x"0000000000000fff",
    product => (
    vendor_id     => x"100000004E2C05E5", 	-- OpenCores
    device_id     => x"f8cfeb16",
    version       => x"00000001",
    date          => x"20121212",
    name          => "OCORES_ETHMAC      ")));

end ethmac_pkg;
