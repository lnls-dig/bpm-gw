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
-- Wishbone FMC Active Clock Register Interface
use work.wb_fmc_active_clk_csr_wbgen2_pkg.all;

entity wb_fmc_active_clk is
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
end wb_fmc_active_clk;

architecture rtl of wb_fmc_active_clk is

   -- Number of bits in Wishbone register interface. Plus 2 to account for BYTE addressing
   constant c_periph_addr_size               : natural := 1+2;

  -----------------------------
  -- Crossbar component constants
  -----------------------------
  -- Internal crossbar layout
  -- 0 -> FMC Active Clock Register Wishbone Interface
  -- 1 -> PLL and Clock Distribution AD9510 SPI
  -- 2 -> VCXO Si571 I2C Bus.
  -- Number of slaves
  constant c_slaves                         : natural := 3;
  -- Number of masters
  constant c_masters                        : natural := 1;            -- Top master.

  -- FMC Active Clock layout
  constant c_layout : t_sdb_record_array(c_slaves-1 downto 0) :=
  ( 0 => f_sdb_embed_device(c_xwb_fmc_active_clk_regs_sdb,
                                                        x"00000000"),   -- FMC Active Clock Interface regs
    1 => f_sdb_embed_device(c_xwb_i2c_master_sdb,       x"00000100"),   -- VCXO Si571 I2C
    2 => f_sdb_embed_device(c_xwb_spi_sdb,              x"00000200")    -- AD9510 SPI
  );

  -- Self Describing Bus ROM Address. It will be an addressed slave as well.
  constant c_sdb_address                    : t_wishbone_address := x"00000300";

  -----------------------------
  -- Wishbone Register Interface signals
  -----------------------------
  -- FMC Active Clock reg structure
  signal regs_out                           : t_wb_fmc_active_clk_csr_out_registers;
  signal regs_in                            : t_wb_fmc_active_clk_csr_in_registers;

  -----------------------------
  -- Wishbone slave adapter signals/structures
  -----------------------------
  signal wb_slv_adp_out                     : t_wishbone_master_out;
  signal wb_slv_adp_in                      : t_wishbone_master_in;
  signal resized_addr                       : std_logic_vector(c_wishbone_address_width-1 downto 0);

  -- Extra Wishbone registering stage
  signal cbar_slave_in_reg0                 : t_wishbone_slave_in_array (c_masters-1 downto 0);
  signal cbar_slave_out_reg0                : t_wishbone_slave_out_array(c_masters-1 downto 0);

  -----------------------------
  -- Wishbone crossbar signals
  -----------------------------
  -- Crossbar master/slave arrays
  signal cbar_slave_in                      : t_wishbone_slave_in_array (c_masters-1 downto 0);
  signal cbar_slave_out                     : t_wishbone_slave_out_array(c_masters-1 downto 0);
  signal cbar_master_in                     : t_wishbone_master_in_array(c_slaves-1 downto 0);
  signal cbar_master_out                    : t_wishbone_master_out_array(c_slaves-1 downto 0);

  -----------------------------
  -- AD9510 SPI signals
  -----------------------------
  signal ad9510_spi_din                     : std_logic;
  signal ad9510_spi_dout                    : std_logic;
  signal ad9510_spi_ss_int                  : std_logic_vector(7 downto 0);
  signal ad9510_spi_clk                     : std_logic;
  signal ad9510_spi_miosio_oe_n             : std_logic;

  signal fmc_pll_status                     : std_logic;

  -----------------------------
  -- VCXO Si571 I2C Signals
  -----------------------------
  signal si571_i2c_scl_in                   : std_logic;
  signal si571_i2c_scl_out                  : std_logic;
  signal si571_i2c_scl_oe_n                 : std_logic;
  signal si571_i2c_sda_in                   : std_logic;
  signal si571_i2c_sda_out                  : std_logic;
  signal si571_i2c_sda_oe_n                 : std_logic;

  -----------------------------
  -- Components
  -----------------------------
  component wb_fmc_active_clk_csr
  port (
    rst_n_i                                  : in     std_logic;
    clk_sys_i                                : in     std_logic;
    wb_adr_i                                 : in     std_logic_vector(0 downto 0);
    wb_dat_i                                 : in     std_logic_vector(31 downto 0);
    wb_dat_o                                 : out    std_logic_vector(31 downto 0);
    wb_cyc_i                                 : in     std_logic;
    wb_sel_i                                 : in     std_logic_vector(3 downto 0);
    wb_stb_i                                 : in     std_logic;
    wb_we_i                                  : in     std_logic;
    wb_ack_o                                 : out    std_logic;
    wb_stall_o                               : out    std_logic;
    regs_i                                   : in     t_wb_fmc_active_clk_csr_in_registers;
    regs_o                                   : out    t_wb_fmc_active_clk_csr_out_registers
  );
  end component;

begin

  -----------------------------
  -- General status board pins
  -----------------------------
  -- PLL status available through a regular core pin
  fmc_pll_status                            <= fmc_pll_status_i;

  fmc_pll_status_o                          <= fmc_pll_status;
  fmc_fpga_clk_p_o                          <= fmc_fpga_clk_p_i;
  fmc_fpga_clk_n_o                          <= fmc_fpga_clk_n_i;

  -----------------------------
  -- Insert extra Wishbone registering stage for ease timing.
  -- It effectively cuts the bandwidth in half!
  -----------------------------
  gen_with_extra_wb_reg : if g_with_extra_wb_reg generate

    cmp_register_link : xwb_register_link -- puts a register of delay between crossbars
    port map (
      clk_sys_i                             => sys_clk_i,
      rst_n_i                               => sys_rst_n_i,
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
  -- FMC Active Clock Address decoder for Wishbone interfaces modules
  -----------------------------
  -- Internal crossbar layout
  -- 0 -> FMC Active Clock Register Wishbone Interface
  -- 1 -> VCXO Si571 I2C Bus
  -- 2 -> PLL and Clock Distribution AD9510 SPI

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
    rst_n_i                                   => sys_rst_n_i,
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
    rst_n_i                                 => sys_rst_n_i,
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
  -- See wb_fmc_active_clk_port.vhd for register bank addresses
  resized_addr(c_periph_addr_size-1 downto 0)
                                            <= cbar_master_out(0).adr(c_periph_addr_size-1 downto 0);
  resized_addr(c_wishbone_address_width-1 downto c_periph_addr_size)
                                            <= (others => '0');

  -----------------------------
  -- FMC Active Clock Register Wishbone Interface. Word addressed!
  -----------------------------
  --FMC Active Clock register interface is the slave number 0, word addressed
  cmp_wb_fmc_active_clk_port : wb_fmc_active_clk_csr
  port map(
    rst_n_i                                 => sys_rst_n_i,
    clk_sys_i                               => sys_clk_i,
    wb_adr_i                                => wb_slv_adp_out.adr(0 downto 0),
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

  -- Wishbone Interface Register input assignments.
  regs_in.clk_distrib_pll_status_i          <= fmc_pll_status;
  regs_in.clk_distrib_reserved_i            <= (others => '0');
  regs_in.dummy_reserved_i                  <= (others => '0');

  -- Wishbone Interface Register output assignments.
  fmc_si571_oe_o                            <= regs_out.clk_distrib_si571_oe_o;
  fmc_pll_function_o                        <= regs_out.clk_distrib_pll_function_o;
  fmc_clk_sel_o                             <= regs_out.clk_distrib_clk_sel_o;

  -----------------------------
  -- I2C Programmable Si571 VCXO
  -----------------------------
  -- I2C Programmable VCXO control interface.
  -- I2C Programmable VCXO is slave number 1, word addressed
  -- Note: I2C registers are 8-bit wide, but accessed as 32-bit registers

  cmp_vcxo_i2c : xwb_i2c_master
  generic map(
    g_interface_mode                        => g_interface_mode,
    g_address_granularity                   => g_address_granularity
  )
  port map (
    clk_sys_i                               => sys_clk_i,
    rst_n_i                                 => sys_rst_n_i,

    slave_i                                 => cbar_master_out(1),
    slave_o                                 => cbar_master_in(1),
    desc_o                                  => open,

    scl_pad_i                               => si571_i2c_scl_in,
    scl_pad_o                               => si571_i2c_scl_out,
    scl_padoen_o                            => si571_i2c_scl_oe_n,
    sda_pad_i                               => si571_i2c_sda_in,
    sda_pad_o                               => si571_i2c_sda_out,
    sda_padoen_o                            => si571_i2c_sda_oe_n
  );

  si571_scl_pad_b  <= si571_i2c_scl_out when si571_i2c_scl_oe_n = '0' else 'Z';
  si571_i2c_scl_in <= si571_scl_pad_b;

  si571_sda_pad_b  <= si571_i2c_sda_out when si571_i2c_sda_oe_n = '0' else 'Z';
  si571_i2c_sda_in <= si571_sda_pad_b;

  -- Not used wishbone signals
  --cbar_master_in(1).err                     <= '0';
  --cbar_master_in(1).rty                     <= '0';

  -----------------------------
  -- AD9510 SPI Bus
  -----------------------------
  -- AD9510 control interface. Four-wire mode.
  -- AD9510 is slave number 2, word addressed

  cmp_ad9510_spi : xwb_spi_bidir
  generic map(
    g_interface_mode                        => g_interface_mode,
    g_address_granularity                   => g_address_granularity
  )
  port map (
    clk_sys_i                               => sys_clk_i,
    rst_n_i                                 => sys_rst_n_i,

    slave_i                                 => cbar_master_out(2),
    slave_o                                 => cbar_master_in(2),
    desc_o                                  => open,

    pad_cs_o                                => ad9510_spi_ss_int,
    pad_sclk_o                              => ad9510_spi_clk, --spi_ad9510_sclk_o,
    pad_mosi_o                              => ad9510_spi_dout, --spi_ad9510_mosi_o,
    pad_mosi_i                              => '0',
    pad_mosi_en_o                           => open,
    pad_miso_i                              => ad9510_spi_din --spi_ad9510_miso_i
  );

  spi_ad9510_cs_o                           <= ad9510_spi_ss_int(0);
  spi_ad9510_sclk_o                         <= ad9510_spi_clk;
  spi_ad9510_mosi_o                         <= ad9510_spi_dout;
  ad9510_spi_din                            <= spi_ad9510_miso_i;

  -- Not used wishbone signals
  --cbar_master_in(2).err                     <= '0';
  --cbar_master_in(2).rty                     <= '0';

end rtl;
