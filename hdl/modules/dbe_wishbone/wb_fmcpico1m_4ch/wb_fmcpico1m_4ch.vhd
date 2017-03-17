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
use ieee.math_real.all;

library work;
-- Main Wishbone Definitions
use work.wishbone_pkg.all;
-- Custom Wishbone Modules
use work.dbe_wishbone_pkg.all;
-- Wishbone Stream Interface
--use work.wb_stream_pkg.all;
use work.wb_stream_generic_pkg.all;
-- Wishbone Register Interface
use work.wb_fmcpico1m_4ch_csr_wbgen2_pkg.all;
-- FMC ADC package
-- use work.fmc_adc_pkg.all;
-- Reset Synch
use work.dbe_common_pkg.all;
-- General common cores
use work.gencores_pkg.all;

--package wb_stream_64_pkg is new wb_stream_generic_pkg
--   generic map (type => std_logic_vector(63 downto 0));

entity wb_fmcpico1m_4ch is
generic
(
  g_interface_mode                          : t_wishbone_interface_mode      := CLASSIC;
  g_address_granularity                     : t_wishbone_address_granularity := WORD;
  g_with_extra_wb_reg                       : boolean := false;
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
end wb_fmcpico1m_4ch;

architecture rtl of wb_fmcpico1m_4ch is

  -- Slightly different behaviour than the one located at wishbone_pkg.vhd.
  -- The original f_ceil_log2 returns 0 for x <= 1. We cannot allow this,
  -- as we must have at least one bit size, for x > 0
  function f_ceil_log2(x : natural) return natural is
  begin
    if x <= 2
    then return 1;
    else return f_ceil_log2((x+1)/2) +1;
    end if;
  end f_ceil_log2;

  -----------------------------
  -- General Constants
  -----------------------------
  constant c_cdc_ref_size                   : natural := 4;
  constant c_cdc_width                      : natural := g_num_adc_bits * g_num_adc_channels;
  -- Number of bits in Wishbone register interface. Plus 2 to account for BYTE addressing
  constant c_periph_addr_size               : natural := 2+2;

  -----------------------------
  -- Crossbar component constants
  -----------------------------
  -- Internal crossbar layout
  -- 0 -> FMCPICO_1M_4CH Register Wishbone Interface
  -- 1 -> System EEPROM I2C Bus
  -- 2 -> Application EEPROM I2C Bus
  -- Number of slaves
  constant c_slaves                         : natural := 3;
  -- Number of masters
  constant c_masters                        : natural := 1;            -- Top master.

  constant c_layout : t_sdb_record_array(c_slaves-1 downto 0) :=
  ( 0 => f_sdb_embed_device(c_xwb_fmcpico_1m_4ch_regs_sdb,
                                                        x"00000000"),   -- Register interface
    1 => f_sdb_embed_device(c_xwb_i2c_master_sdb,       x"00001000"),   -- EEPROM I2C
    2 => f_sdb_embed_device(c_xwb_i2c_master_sdb,       x"00002000")    -- EEPROM I2C
  );

  -- Self Describing Bus ROM Address. It will be an addressed slave as well.
  constant c_sdb_address                    : t_wishbone_address := x"00006000";

  -----------------------------
  -- Clock and reset signals
  -----------------------------
  signal sys_rst_n                          : std_logic;
  signal adc_fast_spi_rstn                  : std_logic;
  signal adc_fast_spi_rst                   : std_logic;

  -----------------------------
  -- Wishbone Register Interface signals
  -----------------------------
  -- FMC250 reg structure
  signal regs_out                           : t_wb_fmcpico1m_4ch_csr_out_registers;
  signal regs_in                            : t_wb_fmcpico1m_4ch_csr_in_registers;

  -----------------------------
  -- Test data signals and constants
  -----------------------------
  -- Counter width. It willl count up to 2^32 clock cycles
  constant c_counter_width                  : natural := 16;
  -- 100MHz period or 1 second
  constant c_counter_full                   : natural := 1000000;
  -- Offset between adjacent test data channels
  constant c_offset_test_data               : natural := 10;
  -- Counter signal
  type t_wbs_test_data_array is array(natural range<>) of unsigned(c_counter_width-1 downto 0);

  signal wbs_test_data                      : t_wbs_test_data_array(g_num_adc_channels-1 downto 0);

  -----------------------------
  -- Wishbone Streaming control signals
  -----------------------------
  type t_wbs_dat16_array is array(natural range<>) of std_logic_vector(c_wbs_dat16_width-1 downto 0);
  type t_wbs_valid16_array is array(natural range<>) of std_logic;

  signal wbs_dat                            : t_wbs_dat16_array(g_num_adc_channels-1 downto 0);
  signal wbs_valid                          : t_wbs_valid16_array(g_num_adc_channels-1 downto 0);
  signal wbs_adr                            : std_logic_vector(c_wbs_adr4_width-1 downto 0);
  signal wbs_sof                            : std_logic;
  signal wbs_eof                            : std_logic;
  signal wbs_error                          : std_logic;
  signal wbs_sel                            : std_logic_vector(c_wbs_sel16_width-1 downto 0);

  -- Wishbone Streaming interface structure
  signal wbs_stream_out                     : t_wbs_source_out16_array(g_num_adc_channels-1 downto 0);
  signal wbs_stream_in                      : t_wbs_source_in16_array(g_num_adc_channels-1 downto 0);

  -----------------------------
  -- Wishbone slave adapter signals/structures
  -----------------------------
  signal wb_slv_adp_out                     : t_wishbone_master_out;
  signal wb_slv_adp_in                      : t_wishbone_master_in;
  signal resized_addr                       : std_logic_vector(c_wishbone_address_width-1 downto 0);

  signal wb_slv_adp_acommon_out             : t_wishbone_master_out;
  signal wb_slv_adp_acommon_in              : t_wishbone_master_in;
  signal resized_acommon_addr               : std_logic_vector(c_wishbone_address_width-1 downto 0);

  -----------------------------
  -- Wishbone crossbar signals
  -----------------------------
  -- Crossbar master/slave arrays
  signal cbar_slave_in                      : t_wishbone_slave_in_array (c_masters-1 downto 0);
  signal cbar_slave_out                     : t_wishbone_slave_out_array(c_masters-1 downto 0);
  signal cbar_master_in                     : t_wishbone_master_in_array(c_slaves-1 downto 0);
  signal cbar_master_out                    : t_wishbone_master_out_array(c_slaves-1 downto 0);

  -- Extra Wishbone registering stage
  signal cbar_slave_in_reg0                 : t_wishbone_slave_in_array (c_masters-1 downto 0);
  signal cbar_slave_out_reg0                : t_wishbone_slave_out_array(c_masters-1 downto 0);

  -----------------------------
  -- ADC signals
  -----------------------------
  signal adc_fifo_data_in                   : std_logic_vector(g_num_adc_bits*g_num_adc_channels-1 downto 0);
  signal adc_fifo_valid_in                  : std_logic;
  signal adc_fifo_data_out                  : std_logic_vector(g_num_adc_bits*g_num_adc_channels-1 downto 0);
  signal adc_fifo_valid_out                 : std_logic;

  signal adc_out_data1_int                  : std_logic_vector(g_num_adc_bits-1 downto 0);
  signal adc_out_data2_int                  : std_logic_vector(g_num_adc_bits-1 downto 0);
  signal adc_out_data3_int                  : std_logic_vector(g_num_adc_bits-1 downto 0);
  signal adc_out_data4_int                  : std_logic_vector(g_num_adc_bits-1 downto 0);
  signal adc_out_valid_int                  : std_logic;
  signal adc_out_busy_int                   : std_logic;

  -----------------------------
  -- Components
  -----------------------------
  component wb_fmcpico1m_4ch_csr
  port (
    rst_n_i                                  : in     std_logic;
    clk_sys_i                                : in     std_logic;
    wb_adr_i                                 : in     std_logic_vector(2 downto 0);
    wb_dat_i                                 : in     std_logic_vector(31 downto 0);
    wb_dat_o                                 : out    std_logic_vector(31 downto 0);
    wb_cyc_i                                 : in     std_logic;
    wb_sel_i                                 : in     std_logic_vector(3 downto 0);
    wb_stb_i                                 : in     std_logic;
    wb_we_i                                  : in     std_logic;
    wb_ack_o                                 : out    std_logic;
    wb_stall_o                               : out    std_logic;
    regs_i                                   : in     t_wb_fmcpico1m_4ch_csr_in_registers;
    regs_o                                   : out    t_wb_fmcpico1m_4ch_csr_out_registers
  );
  end component;

  component fmc_pico_spi
  generic (
    BITS                                      : natural := 20;
    -- main clock frequency
    CLK_FREQ                                  : natural := 300000000;
    -- SCLK frequency
    SCLK_FREQ                                 : natural := 75000000;
    -- number of channels
    NR_CHAN                                   : natural := 4;
    -- time for CONV to be held high
    T_CONV_HIGH                               : real    := 25.0e-9;
    -- ADC supports max 1MSPS
    T_CONV_MIN_TIME                           : real    := 1.0e-6;
    -- time from CONV high to BUSY low
    T_CONV_WAIT                               : real    := 675.0e-9 + 7.0e-9
  );
  port (
    --------------- Clock and reset ---------------
     clk                                      : in std_logic;
     reset                                    : in std_logic;
    --------------- Control signals ---------------
    start,
    --------------- SPI bus -----------------------
    sdo1                                      : in std_logic;
    sdo2                                      : in std_logic;
    sdo3                                      : in std_logic;
    sdo4                                      : in std_logic;
    sck                                       : out std_logic;
    sck_rtrn                                  : in std_logic;
    busy_cmn                                  : in std_logic;
    cnv                                       : out std_logic;
    --------------- output bus -------------------
    out_data1                                 : out std_logic_vector(BITS-1 downto 0);
    out_data2                                 : out std_logic_vector(BITS-1 downto 0);
    out_data3                                 : out std_logic_vector(BITS-1 downto 0);
    out_data4                                 : out std_logic_vector(BITS-1 downto 0);
    out_valid                                 : out std_logic;
    out_busy                                  : out std_logic
  );
  end component;

  component cdc_fifo
  generic
  (
    g_data_width                              : natural;
    g_size                                    : natural
  );
  port
  (
    clk_wr_i                                  : in std_logic;
    data_i                                    : in std_logic_vector(g_data_width-1 downto 0);
    valid_i                                   : in std_logic;

    clk_rd_i                                  : in std_logic;
    data_o                                    : out std_logic_vector(g_data_width-1 downto 0);
    valid_o                                   : out std_logic
  );
  end component;

begin
  sys_rst_n <= sys_rst_n_i;
  adc_fast_spi_rstn <= adc_fast_spi_rstn_i;
  adc_fast_spi_rst <= not adc_fast_spi_rstn;

  -----------------------------
  -- Insert extra Wishbone registering stage for ease timing.
  -- It effectively cuts the bandwidth in half!
  -----------------------------
  gen_with_extra_wb_reg : if g_with_extra_wb_reg generate

    cmp_register_link : xwb_register_link -- puts a register of delay between crossbars
    port map (
      clk_sys_i                             => sys_clk_i,
      rst_n_i                               => sys_rst_n,
      slave_i                               => cbar_slave_in_reg0(0),
      slave_o                               => cbar_slave_out_reg0(0),
      master_i                              => cbar_slave_out(0),
      master_o                              => cbar_slave_in(0)
    );

    cbar_slave_in_reg0(0).adr               <= wb_adr_i;
    cbar_slave_in_reg0(0).dat               <= wb_dat_i;
    cbar_slave_in_reg0(0).sel               <= wb_sel_i;
    cbar_slave_in_reg0(0).we                <= wb_we_i;
    cbar_slave_in_reg0(0).cyc               <= wb_cyc_i;
    cbar_slave_in_reg0(0).stb               <= wb_stb_i;

    wb_dat_o                                <= cbar_slave_out_reg0(0).dat;
    wb_ack_o                                <= cbar_slave_out_reg0(0).ack;
    wb_err_o                                <= cbar_slave_out_reg0(0).err;
    wb_rty_o                                <= cbar_slave_out_reg0(0).rty;
    wb_stall_o                              <= cbar_slave_out_reg0(0).stall;

  end generate;

  gen_without_extra_wb_reg : if not g_with_extra_wb_reg generate

    -- External master connection
    cbar_slave_in(0).adr                    <= wb_adr_i;
    cbar_slave_in(0).dat                    <= wb_dat_i;
    cbar_slave_in(0).sel                    <= wb_sel_i;
    cbar_slave_in(0).we                     <= wb_we_i;
    cbar_slave_in(0).cyc                    <= wb_cyc_i;
    cbar_slave_in(0).stb                    <= wb_stb_i;

    wb_dat_o                                <= cbar_slave_out(0).dat;
    wb_ack_o                                <= cbar_slave_out(0).ack;
    wb_err_o                                <= cbar_slave_out(0).err;
    wb_rty_o                                <= cbar_slave_out(0).rty;
    wb_stall_o                              <= cbar_slave_out(0).stall;

  end generate;

  -----------------------------
  -- Crossbar component constants
  -----------------------------
  -- Internal crossbar layout
  -- 0 -> FMCPICO_1M_4CH Register Wishbone Interface
  -- 1 -> System EEPROM I2C Bus
  -- 2 -> Application EEPROM I2C Bus
  -- The Internal Wishbone B.4 crossbar
  cmp_interconnect : xwb_sdb_crossbar
  generic map(
    g_num_masters                             => c_masters,
    g_num_slaves                              => c_slaves,
    g_registered                              => true,
    g_wraparound                              => true, -- Should be true for nested buses
    g_layout                                  => c_layout,
    g_sdb_addr                                => c_sdb_address
  )
  port map(
    clk_sys_i                                 => sys_clk_i,
    rst_n_i                                   => sys_rst_n,
    -- Master connections (INTERCON is a slave)
    slave_i                                   => cbar_slave_in,
    slave_o                                   => cbar_slave_out,
    -- Slave connections (INTERCON is a master)
    master_i                                  => cbar_master_in,
    master_o                                  => cbar_master_out
  );

  -----------------------------
  -- Slave adapter for Wishbone Register Interface
  -----------------------------
  cmp_slave_adapter : wb_slave_adapter
  generic map (
    g_master_use_struct                     => true,
    g_master_mode                           => PIPELINED,
    g_master_granularity                    => WORD,
    g_slave_use_struct                      => false,
    g_slave_mode                            => g_interface_mode,
    g_slave_granularity                     => g_address_granularity
  )
  port map (
    clk_sys_i                               => sys_clk_i,
    rst_n_i                                 => sys_rst_n,
    master_i                                => wb_slv_adp_in,
    master_o                                => wb_slv_adp_out,
    sl_adr_i                                => resized_addr,
    sl_dat_i                                => cbar_master_out(0).dat,
    sl_sel_i                                => cbar_master_out(0).sel,
    sl_cyc_i                                => cbar_master_out(0).cyc,
    sl_stb_i                                => cbar_master_out(0).stb,
    sl_we_i                                 => cbar_master_out(0).we,
    sl_dat_o                                => cbar_master_in(0).dat,
    sl_ack_o                                => cbar_master_in(0).ack,
    sl_rty_o                                => cbar_master_in(0).rty,
    sl_err_o                                => cbar_master_in(0).err,
    sl_int_o                                => cbar_master_in(0).int,
    sl_stall_o                              => cbar_master_in(0).stall
  );

  -- By doing this zeroing we avoid the issue related to BYTE -> WORD  conversion
  -- slave addressing (possibly performed by the slave adapter component)
  -- in which a bit in the MSB of the peripheral addressing part (31 - 5 in our case)
  -- is shifted to the internal register adressing part (4 - 0 in our case).
  -- Therefore, possibly changing the these bits!
  resized_addr(c_periph_addr_size-1 downto 0)
                                            <= cbar_master_out(0).adr(c_periph_addr_size-1 downto 0);
  resized_addr(c_wishbone_address_width-1 downto c_periph_addr_size)
                                            <= (others => '0');

  -----------------------------
  -- FMCPICO_1M Register Wishbone Interface. Word addressed!
  -----------------------------
  --FMCPICO_1M register interface is the slave number 0, word addressed
  cmp_wb_fmcpico1m_4ch_csr : wb_fmcpico1m_4ch_csr
  port map(
    rst_n_i                                 => sys_rst_n,
    clk_sys_i                               => sys_clk_i,
    wb_adr_i                                => wb_slv_adp_out.adr(2 downto 0),
    wb_dat_i                                => wb_slv_adp_out.dat,
    wb_dat_o                                => wb_slv_adp_in.dat,
    wb_cyc_i                                => wb_slv_adp_out.cyc,
    wb_sel_i                                => wb_slv_adp_out.sel,
    wb_stb_i                                => wb_slv_adp_out.stb,
    wb_we_i                                 => wb_slv_adp_out.we,
    wb_ack_o                                => wb_slv_adp_in.ack,
    wb_stall_o                              => wb_slv_adp_in.stall,
    regs_i                                  => regs_in,
    regs_o                                  => regs_out
  );

  -- Unused wishbone signals
  wb_slv_adp_in.int                         <= '0';
  wb_slv_adp_in.err                         <= '0';
  wb_slv_adp_in.rty                         <= '0';

  -- FMC PICO ADC
  cmp_fmc_pico_spi : fmc_pico_spi
  generic map (
    BITS                                     => g_num_adc_bits,
    CLK_FREQ                                 => g_clk_freq,
    SCLK_FREQ                                => g_sclk_freq
  )
  port map (
    clk                                      => adc_fast_spi_clk_i,
    reset                                    => adc_fast_spi_rst,

    start                                    => adc_start_i,

    sdo1                                     => adc_sdo1_i,
    sdo2                                     => adc_sdo2_i,
    sdo3                                     => adc_sdo3_i,
    sdo4                                     => adc_sdo4_i,
    sck                                      => adc_sck_o,
    sck_rtrn                                 => adc_sck_rtrn_i,
    busy_cmn                                 => adc_busy_cmn_i,
    cnv                                      => adc_cnv_out_o,

    out_data1                                => adc_out_data1_int,
    out_data2                                => adc_out_data2_int,
    out_data3                                => adc_out_data3_int,
    out_data4                                => adc_out_data4_int,
    out_valid                                => adc_out_valid_int,
    out_busy                                 => adc_out_busy_int
  );

  -- CDC FIFO
  cmp_cdc_fifo : cdc_fifo
  generic map
  (
    g_data_width                              => c_cdc_width,
    g_size                                    => c_cdc_ref_size
  )
  port map
  (
    clk_wr_i                                  => adc_fast_spi_clk_i,
    data_i                                    => adc_fifo_data_in,
    valid_i                                   => adc_fifo_valid_in,

    clk_rd_i                                  => adc_clk_i,
    data_o                                    => adc_fifo_data_out,
    valid_o                                   => adc_fifo_valid_out
  );

  adc_fifo_valid_in <= adc_out_valid_int;
  adc_fifo_data_in <= adc_out_data4_int &
                      adc_out_data3_int &
                      adc_out_data2_int &
                      adc_out_data1_int;

  adc_data_o <= adc_fifo_data_out;
  adc_data_valid_o <= (others => adc_fifo_valid_out);

end rtl;
