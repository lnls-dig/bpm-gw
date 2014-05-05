------------------------------------------------------------------------------
-- Title      : Wishbone FMC ADC Interface
------------------------------------------------------------------------------
-- Author     : Lucas Maziero Russo
-- Company    : CNPEM LNLS-DIG
-- Created    : 2012-29-10
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: ADC Interface with FMC ADC boards.
--
-- Currently ADC data (channel) 1 and 2 are clocked on rising_edge of clk0
-- (CLK1_M2C_P and CLK1_M2C_N from the FMC Specifications) and ADC data 0 and 3
-- are clocked on rising edge of clk1 as they are IO pins capable of driving
-- regional clocks up to 3 clocks regions (MRCC), but only half of an IO bank.
-- Hence, in order to use BUFIOs to drive all ILOGIC blocks (e.g., IDDR) of all
-- ADC channels, we need to use both of the clocks
--
-- The generic parameter g_use_clocks specifies which clocks are to be used
-- for acquiring the corresponding adc data. Alternatively, one can use the new
-- generic parameter (g_map_clk_data_chains) to explicitly map which ADC clock
-- chain will clock the ADC data chain. Use with caution!
--
-- Generics:
-- g_clk_default_dly and g_data_default_dly are ignored for now, as the iodelay
-- xilinx primitive in VAR_LOADABLE mode does not consider it
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
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

library work;
use work.dbe_wishbone_pkg.all;
use work.fmc_adc_pkg.all;
use work.fmc_adc_private_pkg.all;

entity fmc_adc_iface is
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
  -- Optional external reference clock port
  -----------------------------
  adc_ext_glob_clk_i                        : in t_adc_clk_chain_glob;

  -----------------------------
  -- ADC Delay signals
  -----------------------------
  -- ADC fine delay control
  adc_fn_dly_i                              : in t_adc_fn_dly_array(c_num_adc_channels-1 downto 0);
  adc_fn_dly_o                              : out t_adc_fn_dly_array(c_num_adc_channels-1 downto 0);

  -- ADC coarse delay control (falling edge + regular delay)
  adc_cs_dly_i                              : in t_adc_cs_dly_array(c_num_adc_channels-1 downto 0);

  -----------------------------
  -- ADC output signals
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

end fmc_adc_iface;

architecture rtl of fmc_adc_iface is

  -- Fill out the intercon vector. This vector has c_num_data_chains positions
  -- and means which clock is connected for each data chain (position index): -1,
  -- means not to use this data chain; 0..c_num_clock_chains, means the clock
  -- driving this data chain.
  constant chain_intercon                   : t_chain_intercon :=
      f_generate_chain_intercon(g_use_clk_chains, g_use_data_chains, g_map_clk_data_chains);

  constant first_used_clk                   : natural := f_first_used_clk(g_use_clk_chains);

  -- Number of ADC input pins. This is different for SDR or DDR ADCs.
  constant c_num_in_adc_pins                : natural := f_num_adc_pins(g_with_data_sdr);

  -- Temporary!
  constant c_with_bufio                     : boolean := true;
  constant c_with_bufr                      : boolean := true;

  -- ADC input signals
  signal adc_in_t                           : t_adc_sdr_in_array(c_num_adc_channels-1 downto 0);

  -- Reset generation
  signal sys_rst                            : std_logic;

  -- AND mmcm signals. Use the MSB bit for the final result
  signal mmcm_adc_locked_and                : std_logic_vector(c_num_adc_channels downto 0);

  -- ADC and Clock chains
  signal adc_clk_chain_glob                 : t_adc_clk_chain_glob_array(c_num_adc_channels-1 downto 0);
  signal adc_clk_chain_priv                 : t_adc_clk_chain_priv_array(c_num_adc_channels-1 downto 0);
  signal adc_out_int                        : t_adc_out_array(c_num_adc_channels-1 downto 0);
  --signal adc_data_chain_out                 : t_adc_int_array(c_num_adc_channels-1 downto 0);

  --type t_adc_fn_dly_val_array is array (natural range <>) of std_logic_vector(4 downto 0);
  -- Optional external global clock
  signal adc_clk_chain_glob_int             : t_adc_clk_chain_glob;

  -- ADC fine delay internal signal
  signal adc_data_dly_sel_int               : std_logic_vector(c_num_in_adc_pins-1 downto 0);

  signal adc_fn_dly_clk_chain_int           : t_adc_clk_fn_dly_array(c_num_adc_channels-1 downto 0);
  signal adc_fn_dly_data_chain_int          : t_adc_data_fn_dly_array(c_num_adc_channels-1 downto 0);

begin
  sys_rst <= not (sys_rst_n_i);

  gen_channels_adc_in : for i in 0 to c_num_adc_channels-1 generate

    -- SDR data structure
    gen_with_data_sdr : if (g_with_data_sdr) generate

      adc_in_t(i).adc_data(c_num_in_adc_pins-1 downto 0)
                                            <= adc_in_sdr_i(i).adc_data;
      adc_in_t(i).adc_clk                   <= adc_in_sdr_i(i).adc_clk;
      adc_in_t(i).adc_rst_n                 <= adc_in_sdr_i(i).adc_rst_n;

    -- DDR data structure
    gen_without_data_sdr : if (not g_with_data_sdr) generate

      adc_in_t(i).adc_data(c_num_in_adc_pins-1 downto 0)
                                            <= adc_in_i(i).adc_data;
      adc_in_t(i).adc_clk                   <= adc_in_i(i).adc_clk;
      adc_in_t(i).adc_rst_n                 <= adc_in_i(i).adc_rst_n;

    end generate;

    end generate;
  end generate;

  -- idelay control for var_loadable iodelay mode
  cmp_idelayctrl : idelayctrl
  port map(
    rst                                     => sys_rst,
    refclk                                  => sys_clk_200Mhz_i,
    rdy                                     => idelay_rdy_o
  );

  -- Generate clock chains
  gen_clock_chains : for i in 0 to chain_intercon'length-1 generate
    gen_clock_chains_check : if g_use_clk_chains(i) = '1' generate
      cmp_fmc_adc_clk : fmc_adc_clk
      generic map (
        -- The only supported values are VIRTEX6 and 7SERIES
        g_fpga_device                       => g_fpga_device,
        --g_delay_type                        => "VARIABLE",
        g_delay_type                        => g_delay_type,
        g_adc_clock_period                  => g_adc_clk_period_values(i),
        g_default_adc_clk_delay             => g_clk_default_dly(i),
        -- This will always fail if we use an external clock, as expected
        g_with_ref_clk                      => f_with_ref_clk(i, g_ref_clk),
        g_mmcm_param                        => g_mmcm_param,
        g_with_fn_dly_select                => g_with_fn_dly_select,
        g_with_bufio                        => f_std_logic_to_bool(g_with_bufio_clk_chains(i)),
        g_with_bufr                         => f_std_logic_to_bool(g_with_bufr_clk_chains(i)),
        g_sim                               => g_sim
      )
      port map (
        sys_clk_i                           => sys_clk_i,
        sys_clk_200Mhz_i                    => sys_clk_200Mhz_i,
        sys_rst_i                           => sys_rst,

        -----------------------------
        -- External ports
        -----------------------------

        -- ADC clocks. One clock per ADC channel
        adc_clk_i                           => adc_in_t(i).adc_clk,

        -----------------------------
        -- ADC Delay signals.
        -----------------------------
        adc_clk_fn_dly_i                    => adc_fn_dly_i(i).clk_chain,
        adc_clk_fn_dly_o                    => adc_fn_dly_clk_chain_int(i),

        -----------------------------
        -- ADC output signals.
        -----------------------------
        adc_clk_chain_priv_o                => adc_clk_chain_priv(i),
        adc_clk_chain_glob_o                => adc_clk_chain_glob(i)
      );

    end generate;

    -- Give the user the possibility to use an external clock for
    -- as the global clocks
    gen_ext_adc_glob_clk : if g_ref_clk = c_num_adc_channels generate
      adc_clk_chain_glob_int <= adc_ext_glob_clk_i;
    end generate;

    gen_without_ext_adc_glob_clk : if g_ref_clk /= c_num_adc_channels generate
      adc_clk_chain_glob_int <= adc_clk_chain_glob(g_ref_clk);
    end generate;

    -- Default mmcm_locked signals to 1 is this chain is not used
    gen_mmcm_locked_clock_chains : if (g_use_clk_chains(i) = '0') generate
      adc_clk_chain_glob(i).mmcm_adc_locked <= '1';
    end generate;
  end generate;

  mmcm_adc_locked_and(0) <= '1';
  -- ANDing all clock chains mmcm_adc_locked_o
  gen_mmcm_adc_locked : for i in 0 to chain_intercon'length-1 generate
    mmcm_adc_locked_and(i+1) <= mmcm_adc_locked_and(i) and adc_clk_chain_glob(i).mmcm_adc_locked;
  end generate;

  -- Output the MSB of mmcm_adc_locked_and, as it contains the and of all the chain.
  -- Note, however, that the snsthesis tool will generate an AND tree for all the
  -- inputs and a single output (mmcm_adc_locked_and(c_num_clock_chains))
  mmcm_adc_locked_o <= mmcm_adc_locked_and(c_num_adc_channels);

  -- Generate data chains and connect it to the clock chain as specified
  -- in chain_intercon
  gen_adc_data_chains : for i in 0 to chain_intercon'length-1 generate
    -- Check if this data chain is to be instanciated
    gen_adc_data_chains_check : if chain_intercon(i) /= -1 generate

      --gen_implicitly_clk_data_map : if f_explicitly_clk_data_map(g_map_clk_data_chains) = false generate
        cmp_fmc_adc_data : fmc_adc_data
          generic map (
            g_default_adc_data_delay            => g_data_default_dly(i),
            --g_delay_type                        => "VARIABLE",
            g_delay_type                        => g_delay_type,
            g_with_data_sdr                     => g_with_data_sdr,
            g_with_fn_dly_select                => g_with_fn_dly_select,
            g_sim                               => g_sim
          )
          port map (
            sys_clk_i                           => sys_clk_i,
            sys_clk_200Mhz_i                    => sys_clk_200Mhz_i,
            sys_rst_n_i                         => adc_in_t(i).adc_rst_n,--sys_rst_n_i,

            -----------------------------
            -- External ports
            -----------------------------

            -- DDR ADC data channels.
            adc_data_i                          => adc_in_t(i).adc_data(c_num_in_adc_pins-1 downto 0),

            -----------------------------
            -- Input Clocks from fmc_adc_clk signals
            -----------------------------
            adc_clk_chain_priv_i                => adc_clk_chain_priv(chain_intercon(i)),
            adc_clk_chain_glob_i                => adc_clk_chain_glob_int,

            -----------------------------
            -- ADC Data Delay signals.
            -----------------------------
            -- Fine delay
            adc_data_fn_dly_i                  => adc_fn_dly_i(i).data_chain,
            adc_data_fn_dly_o                  => adc_fn_dly_data_chain_int(i),
            -- Coarse delay
            adc_cs_dly_i                        => adc_cs_dly_i(i),

            -----------------------------
            -- ADC output signals.
            -----------------------------
            adc_out_o                           => adc_out_int(i),

            fifo_debug_valid_o                  => fifo_debug_valid_o(i),
            fifo_debug_full_o                   => fifo_debug_full_o(i),
            fifo_debug_empty_o                  => fifo_debug_empty_o(i)
          );

          -- The clock delay information for each channel corresponds to the delay
          -- in its correspondent clock chain, referenced by chain_intercon(i).
          adc_fn_dly_o(i).data_chain <= adc_fn_dly_data_chain_int(i);
          adc_fn_dly_o(i).clk_chain <= adc_fn_dly_clk_chain_int(chain_intercon(i));

    end generate;
  end generate;

  -- We have the possibility that some adc data chains are clocked with
  -- different source-synchronous clocks. In this case, we need to synchronize
  -- all data chains to a single clock domain. Need to evaluate its real
  -- necessity

  cmp_fmc_adc_sync_chains : fmc_adc_sync_chains
  --generic map (
  --)
  port map (
    sys_clk_i                               => sys_clk_i,
    --sys_rst_n_i                             => sys_rst_n_i,
    sys_rst_n_i                             => adc_in_t(g_ref_clk).adc_rst_n,

    -----------------------------
    -- ADC Data Input signals. Each data chain is synchronous to its
    -- own clock.
    -----------------------------
    adc_out_i                              => adc_out_int,

    -- Reference clock for synchronization with all data chains
    adc_refclk_i                            => adc_clk_chain_glob_int,

    -----------------------------
    -- ADC output signals. Synchronous to a single clock
    -----------------------------
    adc_out_o                              => adc_out_o
  );

end rtl;
