-------------------------------------------------------------------------------
-- Title      : Wishbone trigger component toplevel
-- Project    :
-------------------------------------------------------------------------------
-- File       : wb_trigger_top.vhd
-- Author     : Vitor Finotti Ferreira  <vfinotti@finotti-Inspiron-7520>
-- Company    : Brazilian Synchrotron Light Laboratory, LNLS/CNPEM
-- Created    : 2016-02-02
-- Last update: 2016-05-10
-- Platform   :
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
-------------------------------------------------------------------------------
-- Copyright (c) 2016 Brazilian Synchrotron Light Laboratory, LNLS/CNPEM

-- This program is free software: you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public License
-- as published by the Free Software Foundation, either version 3 of
-- the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-- Lesser General Public License for more details.
--
-- You should have received a copy of the GNU Lesser General Public
-- License along with this program. If not, see
-- <http://www.gnu.org/licenses/>.
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2016-02-02  1.0      vfinotti        Created
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
-- Main Wishbone Definitions
use work.wishbone_pkg.all;
-- Memory core generator
use work.gencores_pkg.all;
-- Custom Wishbone Modules
use work.ifc_wishbone_pkg.all;
-- Custom common cores
use work.ifc_common_pkg.all;
-- Trigger definitons
use work.trigger_pkg.all;
-- Positicon Calc constants
use work.machine_pkg.all;
-- Genrams
use work.genram_pkg.all;

-- Meta Package
--use work.synthesis_descriptor_pkg.all;
-- AXI cores
--use work.pcie_cntr_axi_pkg.all;
use work.bpm_pcie_a7_const_pkg.all;
-- PCIe Core
use work.bpm_pcie_a7_pkg.all;



library UNISIM;
use UNISIM.vcomponents.all;

entity wb_trigger_top is
  port(
    sys_clk_p_i : in std_logic;
    sys_clk_n_i : in std_logic;


    -----------------------------------------
    -- PCIe pins
    -----------------------------------------

    -- DDR3 memory pins
    ddr3_dq_b      : inout std_logic_vector(c_ddr_dq_width-1 downto 0);
    ddr3_dqs_p_b   : inout std_logic_vector(c_ddr_dqs_width-1 downto 0);
    ddr3_dqs_n_b   : inout std_logic_vector(c_ddr_dqs_width-1 downto 0);
    ddr3_addr_o    : out   std_logic_vector(c_ddr_row_width-1 downto 0);
    ddr3_ba_o      : out   std_logic_vector(c_ddr_bank_width-1 downto 0);
    ddr3_cs_n_o    : out   std_logic_vector(0 downto 0);
    ddr3_ras_n_o   : out   std_logic;
    ddr3_cas_n_o   : out   std_logic;
    ddr3_we_n_o    : out   std_logic;
    ddr3_reset_n_o : out   std_logic;
    ddr3_ck_p_o    : out   std_logic_vector(c_ddr_ck_width-1 downto 0);
    ddr3_ck_n_o    : out   std_logic_vector(c_ddr_ck_width-1 downto 0);
    ddr3_cke_o     : out   std_logic_vector(c_ddr_cke_width-1 downto 0);
    ddr3_dm_o      : out   std_logic_vector(c_ddr_dm_width-1 downto 0);
    ddr3_odt_o     : out   std_logic_vector(c_ddr_odt_width-1 downto 0);

    -- PCIe transceivers
    pci_exp_rxp_i : in  std_logic_vector(c_pcie_lanes - 1 downto 0);
    pci_exp_rxn_i : in  std_logic_vector(c_pcie_lanes - 1 downto 0);
    pci_exp_txp_o : out std_logic_vector(c_pcie_lanes - 1 downto 0);
    pci_exp_txn_o : out std_logic_vector(c_pcie_lanes - 1 downto 0);

    -- PCI clock and reset signals
    pcie_clk_p_i : in std_logic;
    pcie_clk_n_i : in std_logic;

    -- Trigger signals
    trig_dir_o : out   std_logic_vector(7 downto 0);
    trig_b     : inout std_logic_vector(7 downto 0)

    );
end wb_trigger_top;

architecture structural of wb_trigger_top is


-------------------------------------------------------------------------------
-- Chipscope
-------------------------------------------------------------------------------

  component chipscope_icon_1_port is
    port (
      CONTROL0 : inout std_logic_vector(35 downto 0));
  end component chipscope_icon_1_port;

  component chipscope_ila is
    port (
      CONTROL : inout std_logic_vector(35 downto 0);
      CLK     : in    std_logic;
      TRIG0   : in    std_logic_vector(31 downto 0);
      TRIG1   : in    std_logic_vector(31 downto 0);
      TRIG2   : in    std_logic_vector(31 downto 0);
      TRIG3   : in    std_logic_vector(31 downto 0));
  end component chipscope_ila;

  component chipscope_vio_16 is
    port (
      CONTROL  : inout std_logic_vector(35 downto 0);
      CLK      : in    std_logic;
      SYNC_OUT : out   std_logic_vector(15 downto 0));
  end component chipscope_vio_16;

  -----------------------------------------------------------------------------
  -- Clock and system
  -----------------------------------------------------------------------------

  component clk_gen is
    port (
      sys_clk_p_i    : in  std_logic;
      sys_clk_n_i    : in  std_logic;
      sys_clk_o      : out std_logic;
      sys_clk_bufg_o : out std_logic);
  end component clk_gen;

  component sys_pll is
    generic(
      -- 200 MHz input clock
      g_clkin_period   : real    := 5.000;
      g_divclk_divide  : integer := 1;
      g_clkbout_mult_f : integer := 5;

      -- Reference jitter
      g_ref_jitter : real := 0.010;

      -- 100 MHz output clock
      g_clk0_divide_f : integer := 10;
      -- 200 MHz output clock
      g_clk1_divide   : integer := 5;
      g_clk2_divide   : integer := 6
      );
    port (
      rst_i    : in  std_logic := '0';
      clk_i    : in  std_logic := '0';
      clk0_o   : out std_logic;
      clk1_o   : out std_logic;
      clk2_o   : out std_logic;
      locked_o : out std_logic);
  end component sys_pll;

  -- Constants

  constant c_width_bus_size       : positive := 8;
  constant c_rcv_len_bus_width    : positive := 8;
  constant c_transm_len_bus_width : positive := 8;
  constant c_sync_edge            : string   := "positive";
  constant c_trig_num             : positive := 8;
  constant c_intern_num           : positive := 8;
  constant c_rcv_intern_num       : positive := 2;
  constant c_counter_wid          : positive := 16;
  constant c_num_tlvl_clks        : natural  := 3;

  constant c_masters : natural := 1;
  constant c_slaves  : natural := 3;

  constant c_slv_trigger_iface_id  : natural := 0;
  constant c_slv_trigger_mux0_id   : natural := 1;
  constant c_slv_trigger_mux1_id   : natural := 2;

  constant c_layout : t_sdb_record_array(c_slaves-1 downto 0) :=
    (
      c_slv_trigger_iface_id => f_sdb_embed_device(c_xwb_trigger_iface_sdb, x"10000000"),
      c_slv_trigger_mux0_id => f_sdb_embed_device(c_xwb_trigger_mux_sdb, x"20000000"),
      c_slv_trigger_mux1_id => f_sdb_embed_device(c_xwb_trigger_mux_sdb, x"30000000")
    );

  constant c_button_rst_width : natural            := 255;
  constant c_sdb_address      : t_wishbone_address := x"00000000";
  constant c_ma_pcie_id       : natural            := 0;

  constant c_num_mux_interfaces : natural          := 2;


  signal c_clk_sys_id    : natural := 0;
  signal c_clk_200mhz_id : natural := 1;
  signal c_clk_133mhz_id : natural := 2;

  signal CONTROL0 : std_logic_vector(35 downto 0);

  -- Global Clock Single ended
  signal clk_sys, clk_200mhz, clk_133mhz : std_logic;
  signal sys_clk_gen_bufg                : std_logic;
  signal sys_clk_gen                     : std_logic;
  signal reset_rstn                      : std_logic_vector(c_num_tlvl_clks-1 downto 0);
  signal reset_clks                      : std_logic_vector(c_num_tlvl_clks-1 downto 0);

  -- Clocks and resets signals
  signal locked            : std_logic;
  signal clk_sys_pcie_rstn : std_logic;
  signal clk_sys_pcie_rst  : std_logic;
  signal clk_sys_rstn      : std_logic;
  signal clk_sys_rst       : std_logic;
  signal clk_200mhz_rst    : std_logic;
  signal clk_200mhz_rstn   : std_logic;
  signal clk_133mhz_rst    : std_logic;
  signal clk_133mhz_rstn   : std_logic;

  signal rst_button_sys_pp : std_logic;
  signal rst_button_sys    : std_logic;
  signal rst_button_sys_n  : std_logic;

  -- Crossbar master/slave arrays
  signal cbar_slave_i  : t_wishbone_slave_in_array (c_masters-1 downto 0);
  signal cbar_slave_o  : t_wishbone_slave_out_array(c_masters-1 downto 0);
  signal cbar_master_i : t_wishbone_master_in_array(c_slaves-1 downto 0);
  signal cbar_master_o : t_wishbone_master_out_array(c_slaves-1 downto 0);

  signal wb_ma_pcie_rst       : std_logic;
  signal wb_ma_pcie_rstn      : std_logic;
  signal wb_ma_pcie_rstn_sync : std_logic;

  signal wb_slv_in  : t_wishbone_slave_in;
  signal wb_slv_out : t_wishbone_slave_out;

  signal trig_rcv_intern    : t_trig_channel_array2d(1 downto 0, 1 downto 0);
  signal trig_pulse_transm  : t_trig_channel_array2d(1 downto 0, 7 downto 0);
  signal trig_pulse_rcv     : t_trig_channel_array2d(1 downto 0, 7 downto 0);

  signal trig_dir_int : std_logic_vector(7 downto 0);

begin


  cmp_chipscope_icon_1 : chipscope_icon_1_port
    port map (
      CONTROL0 => CONTROL0);

  cmp_chipscope_ila_0 : chipscope_ila
    port map (
      CONTROL             => CONTROL0,
      CLK                 => clk_133mhz,
      TRIG0(31 downto 24) => trig_dir_int,
      TRIG0(23) => trig_pulse_rcv(0, 7).pulse,
      TRIG0(22) => trig_pulse_rcv(0, 6).pulse,
      TRIG0(21) => trig_pulse_rcv(0, 5).pulse,
      TRIG0(20) => trig_pulse_rcv(0, 4).pulse,
      TRIG0(19) => trig_pulse_rcv(0, 3).pulse,
      TRIG0(18) => trig_pulse_rcv(0, 2).pulse,
      TRIG0(17) => trig_pulse_rcv(0, 1).pulse,
      TRIG0(16) => trig_pulse_rcv(0, 0).pulse,
      TRIG0(15) => trig_pulse_transm(0, 7).pulse,
      TRIG0(14) => trig_pulse_transm(0, 6).pulse,
      TRIG0(13) => trig_pulse_transm(0, 5).pulse,
      TRIG0(12) => trig_pulse_transm(0, 4).pulse,
      TRIG0(11) => trig_pulse_transm(0, 3).pulse,
      TRIG0(10) => trig_pulse_transm(0, 2).pulse,
      TRIG0(9)  => trig_pulse_transm(0, 1).pulse,
      TRIG0(8)  => trig_pulse_transm(0, 0).pulse,
      TRIG0(7 downto 2)   => (others => '0'),
      TRIG0(1)   => trig_rcv_intern(0, 1).pulse,
      TRIG0(0)   => trig_rcv_intern(0, 0).pulse,
      TRIG1               => (others => '0'),
      TRIG2               => (others => '0'),
      TRIG3               => (others => '0'));

  trig_dir_o <= trig_dir_int;


  -- Clock generation
  cmp_clk_gen : clk_gen
    port map (
      sys_clk_p_i    => sys_clk_p_i,
      sys_clk_n_i    => sys_clk_n_i,
      sys_clk_o      => sys_clk_gen,
      sys_clk_bufg_o => sys_clk_gen_bufg
      );

  -- Obtain core locking and generate necessary clocks
  cmp_sys_pll_inst : sys_pll
    generic map (
      -- 125 MHz input clock
      g_clkin_period   => 8.000,
      g_divclk_divide  => 5,
      g_clkbout_mult_f => 32,

      -- 100 MHz output clock
      g_clk0_divide_f => 8,
      -- 200 MHz output clock
      g_clk1_divide   => 4,
      -- 133 MHz output clock
      g_clk2_divide   => 6
      )
    port map (
      rst_i    => '0',
      clk_i    => sys_clk_gen_bufg,
      --clk_i                                   => sys_clk_gen,
      clk0_o   => clk_sys,              -- 100MHz locked clock
      clk1_o   => clk_200mhz,           -- 200MHz locked clock
      clk2_o   => clk_133mhz,           -- 133MHz locked clock
      locked_o => locked                -- '1' when the PLL has locked
      );

  -- Reset synchronization. Hold reset line until few locked cycles have passed.
  cmp_reset : gc_reset
    generic map(
      g_clocks => c_num_tlvl_clks       -- CLK_SYS & CLK_200
      )
    port map(
      --free_clk_i                              => sys_clk_gen,
      free_clk_i => sys_clk_gen_bufg,
      locked_i   => locked,
      clks_i     => reset_clks,
      rstn_o     => reset_rstn
      );

  reset_clks(c_clk_sys_id)    <= clk_sys;
  reset_clks(c_clk_200mhz_id) <= clk_200mhz;
  reset_clks(c_clk_133mhz_id) <= clk_133mhz;

  -- Reset for PCIe core. Caution when resetting the PCIe core after the
  -- initialization. The PCIe core needs to retrain the link and the PCIe
  -- host (linux OS, likely) will not be able to do that automatically,
  -- probably.
  clk_sys_pcie_rstn <= reset_rstn(c_clk_sys_id) and rst_button_sys_n;
  clk_sys_pcie_rst  <= not clk_sys_pcie_rstn;
  -- Reset for all other modules
  clk_sys_rstn      <= reset_rstn(c_clk_sys_id) and rst_button_sys_n and
                  wb_ma_pcie_rstn_sync;
  clk_sys_rst     <= not clk_sys_rstn;
  -- Reset synchronous to clk200mhz
  clk_200mhz_rstn <= reset_rstn(c_clk_200mhz_id);
  clk_200mhz_rst  <= not(reset_rstn(c_clk_200mhz_id));
  -- Reset synchronous to clk133mhz
  clk_133mhz_rstn <= reset_rstn(c_clk_133mhz_id);
  clk_133mhz_rst  <= not(reset_rstn(c_clk_133mhz_id));

  -- Generate button reset synchronous to each clock domain
  -- Detect button positive edge of clk_sys
  cmp_button_sys_ffs : gc_sync_ffs
    port map (
      clk_i    => clk_sys,
      rst_n_i  => '1',
      data_i   => '0',                  --sys_rst_button_n_i,
      npulse_o => rst_button_sys_pp
      );

  -- Generate the reset signal based on positive edge
  -- of synched gc
  cmp_button_sys_rst : gc_extend_pulse
    generic map (
      g_width => c_button_rst_width
      )
    port map(
      clk_i      => clk_sys,
      rst_n_i    => '1',
      pulse_i    => rst_button_sys_pp,
      extended_o => rst_button_sys
      );

  rst_button_sys_n <= not rst_button_sys;

  -- The top-most Wishbone B.4 crossbar
  cmp_interconnect : xwb_sdb_crossbar
    generic map(
      g_num_masters => c_masters,
      g_num_slaves  => c_slaves,
      g_registered  => true,
      g_wraparound  => true,            -- Should be true for nested buses
      g_layout      => c_layout,
      g_sdb_addr    => c_sdb_address
      )
    port map(
      clk_sys_i => clk_sys,
      rst_n_i   => clk_sys_rstn,
      -- Master connections (INTERCON is a slave)
      slave_i   => cbar_slave_i,
      slave_o   => cbar_slave_o,
      -- Slave connections (INTERCON is a master)
      master_i  => cbar_master_i,
      master_o  => cbar_master_o
      );

  -- The LM32 is master 0+1
  --lm32_rstn                                 <= clk_sys_rstn;

  --cmp_lm32 : xwb_lm32
  --generic map(
  --  g_profile                               => "medium_icache_debug"
  --) -- Including JTAG and I-cache (no divide)
  --port map(
  --  clk_sys_i                               => clk_sys,
  --  rst_n_i                                 => lm32_rstn,
  --  irq_i                                   => lm32_interrupt,
  --  dwb_o                                   => cbar_slave_i(0), -- Data bus
  --  dwb_i                                   => cbar_slave_o(0),
  --  iwb_o                                   => cbar_slave_i(1), -- Instruction bus
  --  iwb_i                                   => cbar_slave_o(1)
  --);

  -- Interrupt '0' is Button(0).
  -- Interrupts 31 downto 1 are disabled

  --lm32_interrupt <= (0 => not buttons_i(0), others => '0');

  ----------------------------------
  --         PCIe Core            --
  ----------------------------------

  cmp_xwb_bpm_pcie_a7 : xwb_bpm_pcie_a7
    generic map (
      g_ma_interface_mode      => PIPELINED,
      g_ma_address_granularity => BYTE,
      g_ext_rst_pin            => false,
      g_sim_bypass_init_cal    => "OFF"
      )
    port map (
      -- DDR3 memory pins
      ddr3_dq_b      => ddr3_dq_b,
      ddr3_dqs_p_b   => ddr3_dqs_p_b,
      ddr3_dqs_n_b   => ddr3_dqs_n_b,
      ddr3_addr_o    => ddr3_addr_o,
      ddr3_ba_o      => ddr3_ba_o,
      ddr3_cs_n_o    => ddr3_cs_n_o,
      ddr3_ras_n_o   => ddr3_ras_n_o,
      ddr3_cas_n_o   => ddr3_cas_n_o,
      ddr3_we_n_o    => ddr3_we_n_o,
      ddr3_reset_n_o => ddr3_reset_n_o,
      ddr3_ck_p_o    => ddr3_ck_p_o,
      ddr3_ck_n_o    => ddr3_ck_n_o,
      ddr3_cke_o     => ddr3_cke_o,
      ddr3_dm_o      => ddr3_dm_o,
      ddr3_odt_o     => ddr3_odt_o,

      -- PCIe transceivers
      pci_exp_rxp_i => pci_exp_rxp_i,
      pci_exp_rxn_i => pci_exp_rxn_i,
      pci_exp_txp_o => pci_exp_txp_o,
      pci_exp_txn_o => pci_exp_txn_o,

      -- Necessity signals
      ddr_clk_p_i  => clk_200mhz,  --200 MHz DDR core clock (connect through BUFG or PLL)
      ddr_clk_n_i  => '0',  --200 MHz DDR core clock (connect through BUFG or PLL)
      pcie_clk_p_i => pcie_clk_p_i,  --100 MHz PCIe Clock (connect directly to input pin)
      pcie_clk_n_i => pcie_clk_n_i,     --100 MHz PCIe Clock
      pcie_rst_n_i => clk_sys_pcie_rstn,  -- PCIe core reset

      -- DDR memory controller interface --
      ddr_core_rst_i   => clk_sys_pcie_rst,
      memc_ui_clk_o    => open,
      memc_ui_rst_o    => open,
      memc_cmd_rdy_o   => open,
      memc_cmd_en_i    => '0',
      memc_cmd_instr_i => (others => '0'),
      memc_cmd_addr_i  => (others => '0'),
      memc_wr_en_i     => '0',
      memc_wr_end_i    => '0',
      memc_wr_mask_i   => (others => '0'),
      memc_wr_data_i   => (others => '0'),
      memc_wr_rdy_o    => open,
      memc_rd_data_o   => open,
      memc_rd_valid_o  => open,
      ---- memory arbiter interface
      memarb_acc_req_i => '0',
      memarb_acc_gnt_o => open,

      -- Wishbone interface --
      wb_clk_i         => clk_sys,
      -- Reset wishbone interface with the same reset as the other
      -- modules, including a reset coming from the PCIe itself.
      wb_rst_i         => clk_sys_rst,
      wb_ma_i          => cbar_slave_o(c_ma_pcie_id),
      wb_ma_o          => cbar_slave_i(c_ma_pcie_id),
      -- Additional exported signals for instantiation
      wb_ma_pcie_rst_o => wb_ma_pcie_rst,

      -- Debug signals
      dbg_app_addr_o          => open,
      dbg_app_cmd_o           => open,
      dbg_app_en_o            => open,
      dbg_app_wdf_data_o      => open,
      dbg_app_wdf_end_o       => open,
      dbg_app_wdf_wren_o      => open,
      dbg_app_wdf_mask_o      => open,
      dbg_app_rd_data_o       => open,
      dbg_app_rd_data_end_o   => open,
      dbg_app_rd_data_valid_o => open,
      dbg_app_rdy_o           => open,
      dbg_app_wdf_rdy_o       => open,
      dbg_ddr_ui_clk_o        => open,
      dbg_ddr_ui_reset_o      => open,

      dbg_arb_req_o => open,
      dbg_arb_gnt_o => open
      );

  wb_ma_pcie_rstn <= not wb_ma_pcie_rst;

  cmp_pcie_reset_synch : reset_synch
    port map
    (
      clk_i    => clk_sys,
      arst_n_i => wb_ma_pcie_rstn,
      rst_n_o  => wb_ma_pcie_rstn_sync
      );

  cmp_xwb_trigger : xwb_trigger
    generic map (
      g_interface_mode       => PIPELINED,
      g_address_granularity  => BYTE,
      g_sync_edge            => c_sync_edge,
      g_trig_num             => c_trig_num,
      g_intern_num           => c_intern_num,
      g_rcv_intern_num       => c_rcv_intern_num,
      g_num_mux_interfaces   => c_num_mux_interfaces,
      g_out_resolver         => "fanout",
      g_in_resolver          => "or"
    )
    port map (
      rst_n_i             => clk_sys_rstn,
      clk_i               => clk_sys,

      ref_clk_i         => clk_133mhz,
      ref_rst_n_i       => clk_133mhz_rstn,

      fs_clk_array_i    => (clk_133mhz, clk_133mhz),
      fs_rst_n_array_i  => (clk_133mhz_rstn, clk_133mhz_rstn),

      wb_slv_trigger_iface_i => cc_dummy_slave_in,
      wb_slv_trigger_iface_o => open,

      wb_slv_trigger_mux_i => (cc_dummy_slave_in, cc_dummy_slave_in),
      wb_slv_trigger_mux_o => open,

      trig_dir_o          => trig_dir_int,
      trig_rcv_intern_i   => trig_rcv_intern,
      trig_pulse_transm_i => trig_pulse_transm,
      trig_pulse_rcv_o    => trig_pulse_rcv,
      trig_b              => trig_b);

end architecture structural;
