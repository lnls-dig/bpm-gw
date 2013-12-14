------------------------------------------------------------------------------
-- Title      : Wishbone FMC ADC Package
------------------------------------------------------------------------------
-- Author     : Lucas Maziero Russo
-- Company    : CNPEM LNLS-DIG
-- Created    : 2012-17-10
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: General definitions package for the FMC ADC boards.
-------------------------------------------------------------------------------
-- Copyright (c) 2012 CNPEM
-- Licensed under GNU Lesser General Public License (LGPL) v3.0
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2012-29-10  1.0      lucas.russo        Created
-- 2013-19-08  1.1      lucas.russo        Refactored to enable use with other FMC ADC boards
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.wishbone_pkg.all;
use work.wb_stream_pkg.all;

package fmc_adc_pkg is
  --------------------------------------------------------------------
  -- Constants
  --------------------------------------------------------------------
  -- constants for the fmc_adc_iface
  constant c_num_adc_channels : natural := 4;
  constant c_num_adc_bits : natural := 16;
  --------------------------------------------------------------------
  -- Generic definitions
  --------------------------------------------------------------------
  type t_real_array is array (natural range <>) of real;
  type t_natural_array is array (natural range <>) of natural;
  type t_integer_array is array (natural range <>) of integer;

  --------------------------------------------------------------------
  -- Specific definitions
  --------------------------------------------------------------------
  -- ADC input structures
  type t_adc_in is record
    adc_clk : std_logic;
    adc_rst_n : std_logic;
    adc_data : std_logic_vector(c_num_adc_bits/2 - 1 downto 0);
  end record;

  type t_adc_in_array is array (natural range <>) of t_adc_in;

  type t_adc_sdr_in is record
    adc_clk : std_logic;
    adc_rst_n : std_logic;
    adc_data : std_logic_vector(c_num_adc_bits - 1 downto 0);
  end record;

  type t_adc_sdr_in_array is array (natural range <>) of t_adc_sdr_in;

  -- Fine delay structures
  type t_adc_idelay_fn_dly is record
    pulse : std_logic;
    val : std_logic_vector(4 downto 0);
    incdec : std_logic;
  end record;

  type t_adc_idelay_fn_dly_array is array (natural range <>) of t_adc_idelay_fn_dly;

  type t_adc_clk_idelay_sel is record
    which : std_logic;
  end record;

  type t_adc_clk_idelay_sel_array is array (natural range <>) of t_adc_clk_idelay_sel;

  type t_adc_data_idelay_sel is record
    which : std_logic_vector(c_num_adc_bits-1 downto 0);
  end record;

  type t_adc_data_idelay_sel_array is array (natural range <>) of t_adc_data_idelay_sel;

  type t_adc_clk_fn_dly is record
    idelay : t_adc_idelay_fn_dly;
    sel : t_adc_clk_idelay_sel;
  end record;

  type t_adc_clk_fn_dly_array is array (natural range <>) of t_adc_clk_fn_dly;

  type t_adc_data_fn_dly is record
    idelay : t_adc_idelay_fn_dly;
    sel : t_adc_data_idelay_sel;
  end record;

  type t_adc_data_fn_dly_array is array (natural range <>) of t_adc_data_fn_dly;

  type t_adc_fn_dly is record
    clk_chain : t_adc_clk_fn_dly;
    data_chain : t_adc_data_fn_dly;
  end record;

  type t_adc_fn_dly_array is array (natural range <>) of t_adc_fn_dly;

  -- Wishbone <-> Fine delay interface structures
  type t_adc_fn_data_loadable_ctl is record
    val : std_logic_vector(4 downto 0);
    load : std_logic;
    pulse : std_logic;
  end record;

  type t_adc_fn_data_loadable_ctl_array is array (natural range <>)
                                           of t_adc_fn_data_loadable_ctl;

  type t_adc_fn_data_var_ctl is record
    inc : std_logic;
    dec : std_logic;
    --pulse : std_logic;
  end record;

  type t_adc_fn_data_var_ctl_array is array (natural range <>)
                                           of t_adc_fn_data_var_ctl;

  type t_adc_fn_data_dly_wb_ctl is record
    loadable : t_adc_fn_data_loadable_ctl;
    var : t_adc_fn_data_var_ctl;
    sel : t_adc_data_idelay_sel;
  end record;

  type t_adc_fn_data_dly_wb_ctl_array is array (natural range <>)
                                           of t_adc_fn_data_dly_wb_ctl;

  type t_adc_fn_clk_dly_wb_ctl is record
    loadable : t_adc_fn_data_loadable_ctl;
    var : t_adc_fn_data_var_ctl;
    sel : t_adc_clk_idelay_sel;
  end record;

  type t_adc_fn_clk_dly_wb_ctl_array is array (natural range <>)
                                           of t_adc_fn_clk_dly_wb_ctl;

  type t_adc_fn_dly_wb_ctl is record
    clk_chain : t_adc_fn_clk_dly_wb_ctl;
    data_chain : t_adc_fn_data_dly_wb_ctl;
  end record;

  type t_adc_fn_dly_wb_ctl_array is array (natural range <>)
                                           of t_adc_fn_dly_wb_ctl;

  -- ADC coarse delay control (falling edge or whole chain)
  type t_adc_cs_dly is record
    adc_data_rg_d1_en : std_logic;
    adc_data_rg_d2_en : std_logic;
    adc_data_fe_d1_en : std_logic;
    adc_data_fe_d2_en : std_logic;
  end record;

  type t_adc_cs_dly_array is array (natural range<>) of t_adc_cs_dly;

  type t_adc_out is record
    adc_clk : std_logic;
    adc_clk2x : std_logic;
    adc_data : std_logic_vector(c_num_adc_bits-1 downto 0);
    adc_data_valid : std_logic;
  end record;

  alias t_adc_int is t_adc_out;

  type t_adc_out_array is array (natural range <>) of t_adc_out;
  alias t_adc_int_array is t_adc_out_array;

  -- Type for f_chain_intercon function
  type t_chain_intercon is array (natural range <>) of integer;

  type t_adc_clk_chain_priv is record
    adc_clk_bufio: std_logic;
    adc_clk_bufr : std_logic;
  end record;

  type t_adc_clk_chain_priv_array is array (natural range <>) of t_adc_clk_chain_priv;

  -- ADC clock structure
  type t_adc_clk_chain_glob is record
    adc_clk_bufg : std_logic;
    adc_clk2x_bufg : std_logic;
    mmcm_adc_locked : std_logic;
  end record;

  type t_adc_clk_chain_glob_array is array (natural range <>) of t_adc_clk_chain_glob;

  -- Xilinx MMCM parameters
  type t_mmcm_param is record
    divclk : natural;
    clkbout_mult_f : real;  -- Can be integer on some FPGA families (such as Virtex6, but not 7-series)
    clk0_in_period : real;

    clk0_out_div_f : real;
    clk1_out_div : natural;
  end record;

  -- types for fmc_adc_iface generic definitions
  subtype t_default_adc_dly is t_natural_array(c_num_adc_channels-1 downto 0);
  subtype t_clk_values_array is t_real_array(c_num_adc_channels-1 downto 0);
  subtype t_clk_use_chain is std_logic_vector(c_num_adc_channels-1 downto 0);
  subtype t_data_use_chain is std_logic_vector(c_num_adc_channels-1 downto 0);
  subtype t_clk_use_bufio_chain is std_logic_vector(c_num_adc_channels-1 downto 0);
  subtype t_clk_use_bufr_chain is std_logic_vector(c_num_adc_channels-1 downto 0);
  subtype t_map_clk_data_chain is t_integer_array(c_num_adc_channels-1 downto 0);
  subtype t_ref_adc_clk is natural range 0 to c_num_adc_channels-1;

  -- Constant default values.
  constant default_adc_clk_period : real := 4.0; -- 250 MHz
  constant default_data_dly : t_default_adc_dly := (others => 9);
  constant default_clk_dly : t_default_adc_dly := (others => 5);
  constant default_adc_clk_period_values : t_clk_values_array :=
    (default_adc_clk_period, default_adc_clk_period, default_adc_clk_period, default_adc_clk_period);
  constant default_clk_use_chain : t_clk_use_chain :=
    ("0011");
  constant default_data_use_chain : t_data_use_chain :=
    ("1111");
  constant default_clk_use_bufio_chain : t_clk_use_bufio_chain :=
    ("1111");
  constant default_clk_use_bufr_chain : t_clk_use_bufr_chain :=
    ("1111");
  -- Fallback to general conflict resolution mode. See chain_intercon function
  constant default_map_clk_data_chain : t_map_clk_data_chain :=
    (-1, -1, -1, -1);
  --constant default_map_clk_data_chain : t_map_clk_data_chain :=
  --  (1, 0, 0, 1);
  -- Reference ADC clock is clock 1
  constant default_ref_adc_clk : t_ref_adc_clk := 1;
  constant default_mmcm_param : t_mmcm_param := (2, 8.000, default_adc_clk_period, 8.000, 4); -- 250 MHz defaults

  -- dummy values for fmc_adc_iface generic definitions
  -- Warning: all clocks are null here! Should be modified
  constant dummy_clks : t_clk_values_array := (others => 0.0);
  constant dummy_clk_use_chain : t_clk_use_chain := (others => '0');
  constant dummy_data_use_chain : t_data_use_chain := (others => '0');
  constant dummy_default_dly : t_default_adc_dly := (others => 0);

  -----------------------------
  -- Functions declaration
  ----------------------------

  -- Functions
  function f_chain_intercon(clock_chains : std_logic_vector; data_chains : std_logic_vector)
    return t_chain_intercon;

  function f_first_used_clk(use_clk_chain : std_logic_vector)
    return integer;

  function f_explicitly_clk_data_map(map_chain : t_map_clk_data_chain)
    return boolean;

  -- Wrapper for generating chain_intercon structure. It will decide
  -- between explicitly or implicitly mapping for clock/data chains
  function f_generate_chain_intercon(clock_chains : std_logic_vector;
                                      data_chains : std_logic_vector;
                                      map_chain : t_map_clk_data_chain)
    return t_chain_intercon;

  function f_with_ref_clk(clk_chain : natural; ref_clk : natural)
    return boolean;

  function f_num_adc_pins(sdr_data : boolean) return natural;

  function f_std_logic_to_bool(input : std_logic) return boolean;

  -----------------------------
  -- Components declaration
  ----------------------------
  component fmc_adc_buf
  generic
  (
    g_with_clk_single_ended                   : boolean := false;
    g_with_data_single_ended                  : boolean := false;
    g_with_data_sdr                           : boolean := false
  );
  port
  (
    -----------------------------
    -- External ports
    -----------------------------

    -- ADC differential clocks. One clock per ADC channel
    adc_clk0_p_i                              : in std_logic;
    adc_clk0_n_i                              : in std_logic;
    adc_clk1_p_i                              : in std_logic;
    adc_clk1_n_i                              : in std_logic;
    adc_clk2_p_i                              : in std_logic;
    adc_clk2_n_i                              : in std_logic;
    adc_clk3_p_i                              : in std_logic;
    adc_clk3_n_i                              : in std_logic;

    -- ADC single ended clocks. One clock per ADC channel
    adc_clk0_i                                : in std_logic;
    adc_clk1_i                                : in std_logic;
    adc_clk2_i                                : in std_logic;
    adc_clk3_i                                : in std_logic;

    -- Differential ADC data channels.
    adc_data_ch0_p_i                          : in std_logic_vector(f_num_adc_pins(g_with_data_sdr) - 1 downto 0);
    adc_data_ch0_n_i                          : in std_logic_vector(f_num_adc_pins(g_with_data_sdr) - 1 downto 0);
    adc_data_ch1_p_i                          : in std_logic_vector(f_num_adc_pins(g_with_data_sdr) - 1 downto 0);
    adc_data_ch1_n_i                          : in std_logic_vector(f_num_adc_pins(g_with_data_sdr) - 1 downto 0);
    adc_data_ch2_p_i                          : in std_logic_vector(f_num_adc_pins(g_with_data_sdr) - 1 downto 0);
    adc_data_ch2_n_i                          : in std_logic_vector(f_num_adc_pins(g_with_data_sdr) - 1 downto 0);
    adc_data_ch3_p_i                          : in std_logic_vector(f_num_adc_pins(g_with_data_sdr) - 1 downto 0);
    adc_data_ch3_n_i                          : in std_logic_vector(f_num_adc_pins(g_with_data_sdr) - 1 downto 0);

    -- Single ended ADC data channels.
    adc_data_ch0_i                            : in std_logic_vector(f_num_adc_pins(g_with_data_sdr) - 1 downto 0);
    adc_data_ch1_i                            : in std_logic_vector(f_num_adc_pins(g_with_data_sdr) - 1 downto 0);
    adc_data_ch2_i                            : in std_logic_vector(f_num_adc_pins(g_with_data_sdr) - 1 downto 0);
    adc_data_ch3_i                            : in std_logic_vector(f_num_adc_pins(g_with_data_sdr) - 1 downto 0);

    -- Output clocks
    adc_clk0_o                                : out std_logic;
    adc_clk1_o                                : out std_logic;
    adc_clk2_o                                : out std_logic;
    adc_clk3_o                                : out std_logic;

    -- Output data
    adc_data_ch0_o                            : out std_logic_vector(f_num_adc_pins(g_with_data_sdr) - 1 downto 0);
    adc_data_ch1_o                            : out std_logic_vector(f_num_adc_pins(g_with_data_sdr) - 1 downto 0);
    adc_data_ch2_o                            : out std_logic_vector(f_num_adc_pins(g_with_data_sdr) - 1 downto 0);
    adc_data_ch3_o                            : out std_logic_vector(f_num_adc_pins(g_with_data_sdr) - 1 downto 0)
  );
  end component;

  component fmc_adc_clk
  generic
  (
      -- The only supported values are VIRTEX6 and 7SERIES
    g_fpga_device                             : string := "VIRTEX6";
    g_delay_type                              : string := "VARIABLE";
    g_adc_clock_period                        : real;
    g_default_adc_clk_delay                   : natural := 0;
    g_with_ref_clk                            : boolean := false;
    g_mmcm_param                              : t_mmcm_param := default_mmcm_param;
    g_with_fn_dly_select                      : boolean := false;
    g_with_bufio                              : boolean := true;
    g_with_bufr                               : boolean := true;
    g_sim                                     : integer := 0
  );
  port
  (
    sys_clk_i                                 : in std_logic;
    sys_clk_200Mhz_i                          : in std_logic;
    sys_rst_i                                 : in std_logic;

    -----------------------------
    -- External ports
    -----------------------------

    -- ADC clocks. One clock per ADC channel
    adc_clk_i                                 : in std_logic;

    -----------------------------
    -- ADC Delay signals.
    -----------------------------
    -- ADC fine delay control
    adc_clk_fn_dly_i                          : in t_adc_clk_fn_dly;
    adc_clk_fn_dly_o                          : out t_adc_clk_fn_dly;

    -----------------------------
    -- ADC output signals.
    -----------------------------
    adc_clk_chain_priv_o                        : out t_adc_clk_chain_priv;
    adc_clk_chain_glob_o                        : out t_adc_clk_chain_glob
  );

  end component;

  component fmc_adc_data
  generic
  (
    g_delay_type                              : string := "VARIABLE";
    g_default_adc_data_delay                  : natural := 0;
    g_with_data_sdr                           : boolean := false;
    g_with_fn_dly_select                      : boolean := false;
    g_sim                                     : integer := 0
  );
  port
  (
    sys_clk_i                                 : in std_logic;
    sys_clk_200Mhz_i                          : in std_logic;
    sys_rst_n_i                               : in std_logic;

    -----------------------------
    -- External ports
    -----------------------------

    -- ADC data channel
    adc_data_i                                : in std_logic_vector(f_num_adc_pins(g_with_data_sdr)-1 downto 0);

    -----------------------------
    -- Input Clocks from fmc_adc_clk signals
    -----------------------------
    adc_clk_chain_priv_i                        : in t_adc_clk_chain_priv;
    adc_clk_chain_glob_i                        : in t_adc_clk_chain_glob;

    -----------------------------
    -- ADC Data Delay signals
    -----------------------------
    adc_data_fn_dly_i                         : in t_adc_data_fn_dly;
    adc_data_fn_dly_o                         : out t_adc_data_fn_dly;

    adc_cs_dly_i                              : in t_adc_cs_dly;

    -----------------------------
    -- ADC output signals
    -----------------------------

    adc_out_o                                 : out t_adc_out;

    fifo_debug_valid_o                        : out std_logic;
    fifo_debug_full_o                         : out std_logic;
    fifo_debug_empty_o                        : out std_logic
  );

  end component;

  component fmc_adc_dly_iface
  generic
  (
    g_with_var_loadable                     : boolean := true;
    g_with_variable                         : boolean := true;
    g_with_fn_dly_select                    : boolean := false
  );
  port
  (
    rst_n_i                                 : in std_logic;
    clk_sys_i                               : in std_logic;

    adc_fn_dly_wb_ctl_i                     : in t_adc_fn_dly_wb_ctl;
    adc_fn_dly_o                            : out t_adc_fn_dly
  );
  end component;

  component fmc_adc_iface
  generic
  (
      -- The only supported values are VIRTEX6 and 7SERIES
    g_fpga_device                             : string := "VIRTEX6";
    g_delay_type                              : string := "VARIABLE";
    g_adc_clk_period_values                   : t_clk_values_array;
    g_use_clk_chains                          : t_clk_use_chain := default_clk_use_chain;
    g_clk_default_dly                         : t_default_adc_dly := default_clk_dly;
    g_use_data_chains                         : t_data_use_chain := default_data_use_chain;
    g_map_clk_data_chains                     : t_map_clk_data_chain := default_map_clk_data_chain;
    g_data_default_dly                        : t_default_adc_dly := default_data_dly;
    g_ref_clk                                 : t_ref_adc_clk := default_ref_adc_clk;
    g_mmcm_param                              : t_mmcm_param := default_mmcm_param;
    g_with_bufio_clk_chains                   : t_clk_use_bufio_chain := default_clk_use_bufio_chain;
    g_with_bufr_clk_chains                    : t_clk_use_bufr_chain := default_clk_use_bufr_chain;
    g_with_data_sdr                           : boolean := false;
    g_with_fn_dly_select                      : boolean := false;
    g_sim                                     : integer := 0
  );
  port
  (
    sys_clk_i                                 : in std_logic;
    -- System Reset. Rgular reset, not ANDed with mmcm_adc_locked
    sys_rst_n_i                               : in std_logic;
    sys_clk_200Mhz_i                          : in std_logic;

    -----------------------------
    -- External ports
    -----------------------------
    -- Do I need really to worry about the deassertion of async resets?
    -- Generate them outside this module, as this reset is needed by
    -- external logic

    -- ADC clock + data differential inputs (from the top module)
    adc_in_i                                  : in t_adc_in_array(c_num_adc_channels-1 downto 0);
    -- ADC clock + data single ended inputs (from the top module)
    adc_in_sdr_i                              : in t_adc_sdr_in_array(c_num_adc_channels-1 downto 0);

    -----------------------------
    -- ADC Delay signals.
    -----------------------------
    -- ADC fine delay control
    adc_fn_dly_i                              : in t_adc_fn_dly_array(c_num_adc_channels-1 downto 0);
    adc_fn_dly_o                              : out t_adc_fn_dly_array(c_num_adc_channels-1 downto 0);

    -- ADC coarse delay control (falling edge + regular delay)
    adc_cs_dly_i                              : in t_adc_cs_dly_array(c_num_adc_channels-1 downto 0);

    -----------------------------
    -- ADC output signals.
    -----------------------------
    adc_out_o                                 : out t_adc_out_array(c_num_adc_channels-1 downto 0);

    -----------------------------
    -- General status signals
    -----------------------------
    -- MMCM lock signal
    mmcm_adc_locked_o                         : out std_logic;
    -- Idelay ready signal
    idelay_rdy_o                              : out std_logic;

    fifo_debug_valid_o                        : out std_logic_vector(c_num_adc_channels-1 downto 0);
    fifo_debug_full_o                         : out std_logic_vector(c_num_adc_channels-1 downto 0);
    fifo_debug_empty_o                        : out std_logic_vector(c_num_adc_channels-1 downto 0)
  );
  end component;

  component fmc_adc_sync_chains
  --generic
  --(
  --)
  port
  (
    sys_clk_i                               : std_logic;
    sys_rst_n_i                             : std_logic;

    -----------------------------
    -- ADC Data Input signals. Each data chain is synchronous to its
    -- own clock.
    -----------------------------
    adc_out_i                               : in t_adc_out_array(c_num_adc_channels-1 downto 0);

    -- Reference clock for synchronization with all data chains
    adc_refclk_i                            : in t_adc_clk_chain_glob;

    -----------------------------
    -- ADC output signals. Synchronous to a single clock
    -----------------------------
    adc_out_o                               : out t_adc_out_array(c_num_adc_channels-1 downto 0)
  );
  end component;

  -- SDB for internal FMC516 layout. More general cores have its SDB structure
  -- defined indes dbe_wishbone_pkg file.
  -- FMC516 Interface
  constant c_xwb_fmc516_regs_sdb : t_sdb_device := (
    abi_class     => x"0000",                 -- undocumented device
    abi_ver_major => x"01",
    abi_ver_minor => x"00",
    wbd_endian    => c_sdb_endian_big,
    wbd_width     => x"4",                    -- 32-bit port granularity (0100)
    sdb_component => (
    addr_first    => x"0000000000000000",
    addr_last     => x"00000000000000FF",
    product => (
    vendor_id     => x"1000000000001215",     -- LNLS
    device_id     => x"27b95341",
    version       => x"00000001",
    date          => x"20121124",
    name          => "LNLS_FMC516_REGS   ")));

  -- FMC130M_4CH
  constant c_xwb_fmc130m_4ch_regs_sdb : t_sdb_device := (
    abi_class     => x"0000",                 -- undocumented device
    abi_ver_major => x"01",
    abi_ver_minor => x"00",
    wbd_endian    => c_sdb_endian_big,
    wbd_width     => x"4",                     -- 32-bit port granularity (0100)
    sdb_component => (
    addr_first    => x"0000000000000000",
    addr_last     => x"00000000000000FF",
    product => (
    vendor_id     => x"1000000000001215",     -- LNLS
    device_id     => x"7085ef15",
    version       => x"00000001",
    date          => x"20132008",
    name          => "LNLS_FMC130M_REGS  ")));

end fmc_adc_pkg;


package body fmc_adc_pkg is

  -- Fill out the intercon vector. This vector has c_num_data_chains positions
  -- and means which clock is connected for each data chain (position index): -1,
  -- means not to use this data chain; 0..c_num_clock_chains, means the clock
  -- driving this data chain.
  --
  -- The policy for attributing a data chain to a clock chain is simply clocking
  -- the data chain index that is less or equal than the next usable clock index
  -- in the clock chain. If there are remaining data chain to be clocked using the
  -- above logic, the default is to connect them to the last available clock in
  -- the clock chain.
  function f_chain_intercon(clock_chains : std_logic_vector; data_chains : std_logic_vector)
    return t_chain_intercon
  is
    constant c_num_chains : natural := clock_chains'length;
    variable intercon : t_chain_intercon(c_num_chains-1 downto 0) := (others => -1);
    variable data_chain_idx : natural := 0;
    variable i : natural := 0;
    variable j : natural := 0;
    variable k : natural := 0;
  begin
    -- Check for the sizes
    assert (clock_chains'length = data_chains'length) report
      "Vectors clocks and data have different sizes" severity failure;

    --for i in 0 to c_num_clock_chains-1 loop
    while i < c_num_chains loop
      if clock_chains(i) = '1' then
        --for j in data_chain_idx to i loop
        j := data_chain_idx;
        while j <= i loop
          if data_chains(j) = '1' then
            intercon(j) := i;
          end if;
          j := j + 1;
        end loop;
        data_chain_idx := i+1;
      end if;
      i := i + 1;
    end loop;

    -- If there are remaining data chains unclocked, assign
    -- them to the last usable clock
    for i in data_chain_idx to c_num_chains-1 loop
      if data_chains(i) = '1' then
        intercon(i) := data_chain_idx-1;
      end if;
    end loop;

    -- Print the intercon vector
    --for k in 0 to c_num_chains-1 loop
    --  report "[ intercon(" & integer'image(k) & ") = " &
    --      Integer'image(intercon(k)) & " ]"
    --  severity note;
    --end loop;

    return intercon;
  end f_chain_intercon;

  -- Determine first used clock
  function f_first_used_clk(use_clk_chain : std_logic_vector)
    return integer
  is
  begin
    for i in 0 to c_num_adc_channels-1 loop
      if use_clk_chain(i) = '1' then
        return i;
      end if;
    end loop;

    return -1;
  end f_first_used_clk;

  -- Check if the user specified a explicitly mapping between clocks
  -- and data chains
  function f_explicitly_clk_data_map(map_chain : t_map_clk_data_chain)
    return boolean
  is
    constant c_num_chains : natural := map_chain'length;
    variable i : natural := 0;
    variable j : natural := 0;
    variable result : boolean := true;
  begin
    for i in 0 to c_num_chains-1 loop
      if map_chain(i) < 0 then
        result := false;
        exit;
      end if;
    end loop;

    -- Print the map vector
    for j in 0 to c_num_chains-1 loop
      report "[ map vector(" & integer'image(j) & ") = " &
          Integer'image(map_chain(j)) & " ]"
      severity note;
    end loop;

    return result;
  end f_explicitly_clk_data_map;

  function f_generate_chain_intercon(clock_chains : std_logic_vector;
                                        data_chains : std_logic_vector;
                                        map_chain : t_map_clk_data_chain)
    return t_chain_intercon
  is
    constant c_num_chains : natural := clock_chains'length;
    variable intercon : t_chain_intercon(c_num_chains-1 downto 0);
    variable i : natural := 0;
  begin
    -- Check for the sizes
    assert (clock_chains'length = data_chains'length) report
      "Vectors clocks and data have different sizes" severity failure;
    assert (data_chains'length = map_chain'length) report
      "Vectors data and map_clk have different sizes" severity failure;

    -- Trust the user mapping...
    if f_explicitly_clk_data_map(map_chain) = true then
      for i in 0 to c_num_chains-1 loop
        intercon(i) := map_chain(i);
      end loop;
    else --f_explicitly_clk_data_map(map_chain) = false
      -- Fallback to implicit policy in order to map clock to data chains
      intercon := f_chain_intercon(clock_chains, data_chains);
    end if;

    -- Print the intercon vector
    for i in 0 to c_num_chains-1 loop
      report "[ intercon(" & integer'image(i) & ") = " &
          Integer'image(intercon(i)) & " ]"
      severity note;
    end loop;

    return intercon;
  end f_generate_chain_intercon;

  function f_with_ref_clk(clk_chain : natural; ref_clk : natural)
    return boolean
  is
  begin
    if clk_chain = ref_clk then
      return true;
    else
      return false;
    end if;
  end f_with_ref_clk;

  function f_num_adc_pins(sdr_data : boolean)
    return natural
  is
  begin
    if (sdr_data) then
      return c_num_adc_bits;
    else -- ddr data
      return c_num_adc_bits/2;
    end if;
  end f_num_adc_pins;

  function f_std_logic_to_bool(input : std_logic)
    return boolean
  is
  begin
    if (input = '1') then
      return true;
    else
      return false;
    end if;
  end f_std_logic_to_bool;

  ---- revise function and make it generic? Does it worth it?
  --function f_mmcm_params(clk_in : real)
  --  return t_mmcm_param
  --is
  --  constant fvco_min : real := 600.00;
  --  constant fvco_max : real := 1200.00;
  --  constant fvco_middle : real := (fvco_max - fvco_min)/2;
  --begin
  --  -- Calculate FVCO and find mult_f and divclk values
  --  -- such that FCVO fall within 600 - 1200 MHz for virtex-6
  --  --
  --  -- FVCO = clk_in * clkbout_mult_f / divclk
  --end f_mmcm_params;

end fmc_adc_pkg;
