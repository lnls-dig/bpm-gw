------------------------------------------------------------------------------
-- Title      : Wishbone FMC250 Interface
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
-- Wishbone Stream Interface
use work.wb_stream_generic_pkg.all;
-- FMC ADC package
--use work.fmc_adc_pkg.all;

entity xwb_fmcpico1m_4ch is
generic
(
  g_interface_mode                          : t_wishbone_interface_mode      := CLASSIC;
  g_address_granularity                     : t_wishbone_address_granularity := WORD;
  g_num_adc_bits                            : natural := 20;
  g_num_adc_channels                        : natural := 4;
  g_clk_freq                                : natural := 300000000; -- Hz
  g_sclk_freq                               : natural := 75000000 --Hz
);
port
(
  sys_clk_i                                 : in std_logic;
  sys_rst_n_i                               : in std_logic;
  sys_clk_200Mhz_i                          : in std_logic;

  -----------------------------
  -- Wishbone Control Interface signals
  -----------------------------

  wb_slv_i                                  : in t_wishbone_slave_in;
  wb_slv_o                                  : out t_wishbone_slave_out;

  -----------------------------
  -- External ports
  -----------------------------

  adc_fast_spi_clk_i                        : in std_logic;
  adc_fast_spi_rstn_i                       : in std_logic;

  -- Control signals
  adc_start_i                               : in std_logic;

  -- SPI bus
  adc_sdo1_i                                : in std_logic;
  adc_sdo2_i                                : in std_logic;
  adc_sdo3_i                                : in std_logic;
  adc_sdo4_i                                : in std_logic;
  adc_sck_o                                 : out std_logic;
  adc_sck_rtrn_i                            : in std_logic;
  adc_busy_cmn_i                            : in std_logic;
  adc_cnv_out_o                             : out std_logic;

  -----------------------------
  -- ADC output signals. Continuous flow
  -----------------------------
  -- clock to CDC. This must be g_sclk_freq/g_num_adc_bits. A regular 100MHz should
  -- suffice in all cases
  adc_clk_i                                 : in std_logic;
  adc_data_o                                : out std_logic_vector(g_num_adc_channels*g_num_adc_bits-1 downto 0);
  adc_data_valid_o                          : out std_logic_vector(g_num_adc_channels-1 downto 0);
  adc_out_busy_o                            : out std_logic

);
end xwb_fmcpico1m_4ch;

architecture rtl of xwb_fmcpico1m_4ch is

  signal wbs_adr_int                        : std_logic_vector(c_num_adc_channels*c_wbs_adr4_width-1 downto 0);
  signal wbs_dat_int                        : std_logic_vector(c_num_adc_channels*c_wbs_dat16_width-1 downto 0);
  signal wbs_cyc_int                        : std_logic_vector(c_num_adc_channels-1 downto 0);
  signal wbs_stb_int                        : std_logic_vector(c_num_adc_channels-1 downto 0);
  signal wbs_we_int                         : std_logic_vector(c_num_adc_channels-1 downto 0);
  signal wbs_sel_int                        : std_logic_vector(c_num_adc_channels*c_wbs_sel16_width-1 downto 0);
  signal wbs_ack_int                        : std_logic_vector(c_num_adc_channels-1 downto 0);
  signal wbs_stall_int                      : std_logic_vector(c_num_adc_channels-1 downto 0);
  signal wbs_err_int                        : std_logic_vector(c_num_adc_channels-1 downto 0);
  signal wbs_rty_int                        : std_logic_vector(c_num_adc_channels-1 downto 0);

begin

  cmp_wb_fmcpico1m_4ch : wb_fmcpico1m_4ch
  generic map (
    g_interface_mode                          => g_interface_mode,
    g_address_granularity                     => g_address_granularity,
    g_num_adc_bits                            => g_num_adc_bits,
    g_num_adc_channels                        => g_num_adc_channels,
    g_clk_freq                                => g_clk_freq,
    g_sclk_freq                               => g_sclk_freq
  )
  port map (
    sys_clk_i                                 => sys_clk_i,
    sys_rst_n_i                               => sys_rst_n_i,
    sys_clk_200Mhz_i                          => sys_clk_200Mhz_i,

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
    adc_fast_spi_clk_i                        => adc_fast_spi_clk_i,
    adc_fast_spi_rstn_i                       => adc_fast_spi_rstn_i,

    -- Control signals
    adc_start_i                               => adc_start_i,

    -- SPI bus
    adc_sdo1_i                                => adc_sdo1_i,
    adc_sdo2_i                                => adc_sdo2_i,
    adc_sdo3_i                                => adc_sdo3_i,
    adc_sdo4_i                                => adc_sdo4_i,
    adc_sck_o                                 => adc_sck_o,
    adc_sck_rtrn_i                            => adc_sck_rtrn_i,
    adc_busy_cmn_i                            => adc_busy_cmn_i,
    adc_cnv_out_o                             => adc_cnv_out_o,

    -----------------------------
    -- ADC output signals. Continuous flow
    -----------------------------
    -- clock to CDC. This must be g_sclk_freq/g_num_adc_bits. A regular 100MHz should
    -- suffice in all cases
    adc_clk_i                                => adc_clk_i,
    adc_data_o                               => adc_data_o,
    adc_data_valid_o                         => adc_data_valid_o,
    adc_out_busy_o                           => adc_out_busy_o
  );

  --gen_wbs_interfaces : for i in 0 to c_num_adc_channels-1 generate
  --  gen_wbs_interfaces_ch : if g_use_data_chains(i) = '1' generate
  --    wbs_ack_int(i)                            <=  wbs_source_i(i).ack;
  --    wbs_stall_int(i)                          <=  wbs_source_i(i).stall;
  --    wbs_err_int(i)                            <=  wbs_source_i(i).err;
  --    wbs_rty_int(i)                            <=  wbs_source_i(i).rty;

  --    wbs_source_o(i).adr                       <= wbs_adr_int(c_wbs_adr4_width*(i+1)-1 downto
  --                                                    c_wbs_adr4_width*i);
  --    wbs_source_o(i).dat                       <= wbs_dat_int(c_wbs_dat16_width*(i+1)-1 downto
  --                                                    c_wbs_dat16_width*i);
  --    wbs_source_o(i).sel                       <= wbs_sel_int(c_wbs_sel16_width*(i+1)-1 downto
  --                                                    c_wbs_sel16_width*i);
  --    wbs_source_o(i).cyc                       <= wbs_cyc_int(i);
  --    wbs_source_o(i).stb                       <= wbs_stb_int(i);
  --    wbs_source_o(i).we                        <= wbs_we_int(i);
  --  end generate;
  --end generate;

end rtl;
