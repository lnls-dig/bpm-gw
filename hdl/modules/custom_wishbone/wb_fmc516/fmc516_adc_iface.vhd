------------------------------------------------------------------------------
-- Title      : Wishbone FMC516 ADC Interface
------------------------------------------------------------------------------
-- Author     : Lucas Maziero Russo
-- Company    : CNPEM LNLS-DIG
-- Created    : 2012-29-10
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: ADC Interface with FMC516 ADC board from Curtis Wright.
--
-- Currently all ADC data is clocked on rising_edge of clk0 (CLK1_M2C_P
-- and CLK1_M2C_N from the FMC Specifications), as this is an
-- IO pin capable of driving regional clocks up to 3 clocks regions (MRCC).
--
-- The generic parameter g_use_clocks specifies which clocks are to be used
-- for acquiring the corresponding adc data. Use with caution!
-------------------------------------------------------------------------------
-- Copyright (c) 2012 CNPEM
-- Licensed under GNU Lesser General Public License (LGPL) v3.0
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2012-29-10  1.0      lucas.russo        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

library work;
use work.custom_wishbone_pkg.all;
use work.fmc516_pkg.all;

-- Should each channel have its own signal struture?
-- Should each related signal be in a separate struture?
-- If they were we could simplify the internal assignts for the generate statements
-- and make this module more generic and ADC agnostic (=])
--
-- g_clk_default_dly and g_data_default_dly are ignored for now, as the iodelay
-- xilinx primitive in VAR_LOADABLE mode does not consider it
entity fmc516_adc_iface is
generic
(
	-- The only supported values are VIRTEX6 and 7SERIES
  g_fpga_device                             : string := "VIRTEX6";
  g_adc_clk_period_values                   : t_clk_values_array;
  g_use_clk_chains                          : t_clk_use_chain := default_clk_use_chain;
  g_clk_default_dly                         : t_default_adc_dly := default_clk_dly;
  g_use_data_chains                         : t_data_use_chain := default_data_use_chain;
  g_data_default_dly                        : t_default_adc_dly := default_data_dly;
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

  -----------------------------
  -- ADC Delay signals.
  -----------------------------
  -- ADC clock + data delays
  adc_dly_i                                 : in t_adc_dly_array(c_num_adc_channels-1 downto 0);
  adc_dly_o                                 : out t_adc_dly_array(c_num_adc_channels-1 downto 0);

  -----------------------------
  -- ADC output signals.
  -----------------------------
  adc_out_o                                 : out t_adc_out_array(c_num_adc_channels-1 downto 0);

  -----------------------------
  -- MMCM general signals
  -----------------------------
  mmcm_adc_locked_o                         : out std_logic
);

end fmc516_adc_iface;

architecture rtl of fmc516_adc_iface is

  -- Reset generation
  signal sys_rst                            : std_logic;

  -- AND mmcm signals. Use the MSB bit for the final result
  signal mmcm_adc_locked_and                : std_logic_vector(c_num_adc_channels downto 0);

  -- ADC clock type mangling for generates statements
  type t_adc_clk_chain is record
    adc_clk_bufio: std_logic;
    adc_clk_bufr : std_logic;
    adc_clk_bufg : std_logic;
    adc_clk2x_bufg : std_logic;
    mmcm_adc_locked : std_logic;
  end record;

  -- ADC and Clock chain for generate statements
  type t_adc_clk_chain_array is array (natural range <>) of t_adc_clk_chain;
  --type t_adc_data_chain_array is array (natural range <>) of t_adc_data_chain;

  -- Conectivity vector for interconnecting clocks and data chains
  --type t_chain_intercon is array (natural range <>) of integer;

  -- ADc and Clock chains
  signal adc_clk_chain						 				  : t_adc_clk_chain_array(c_num_adc_channels-1 downto 0);

  -- Fill out the intercon vector. This vector has c_num_data_chains positions
  -- and means which clock is connected for each data chain (position index): -1,
  -- means not to use this data chain; 0..c_num_clock_chains, means the clock
  -- driving this data chain.
  constant chain_intercon                   : t_chain_intercon :=
      f_chain_intercon(g_use_clk_chains, g_use_data_chains);

  -----------------------------
  -- Components declaration
  -----------------------------

  component fmc516_adc_clk
  generic(
	-- The only supported values are VIRTEX6 and 7SERIES
    g_fpga_device                           : string := "VIRTEX6";
    g_adc_clock_period                      : real;
    g_default_adc_clk_delay                 : natural := 0;
    g_sim                                   : integer := 0
  );
  port(
    sys_clk_i                               : in std_logic;
    sys_rst_i                               : in std_logic;

    -----------------------------
    -- External ports
    -----------------------------

    -- ADC clocks. One clock per ADC channel
    adc_clk_i                        		    : in std_logic;

    -----------------------------
    -- ADC Delay signals.
    -----------------------------
    -- Pulse this to update the delay value
    adc_clk_dly_pulse_i                     : in std_logic;
    adc_clk_dly_val_i                       : in std_logic_vector(4 downto 0);
    adc_clk_dly_val_o                       : out std_logic_vector(4 downto 0);

    -----------------------------
    -- ADC output signals.
    -----------------------------
    adc_clk_bufio_o                         : out std_logic;
    adc_clk_bufr_o                          : out std_logic;
    adc_clk_bufg_o                          : out std_logic;
    adc_clk2x_bufg_o                        : out std_logic;

    -----------------------------
    -- MMCM general signals
    -----------------------------
    mmcm_adc_locked_o                       : out std_logic
  );
  end component;

  component fmc516_adc_data
  generic(
    g_default_adc_data_delay                : natural := 0;
    g_sim                                   : integer := 0
  );
  port(
    sys_clk_i                               : in std_logic;
    sys_rst_n_i                             : in std_logic;

    -----------------------------
    -- External ports
    -----------------------------

    -- DDR ADC data channels.
    adc_data_i	                            : in std_logic_vector(c_num_adc_bits/2 - 1 downto 0);

    -----------------------------
    -- Input Clocks from fmc516_adc_clk signals
    -----------------------------
    adc_clk_bufio_i                        	: in std_logic;
    adc_clk_bufr_i                        	: in std_logic;
    adc_clk_bufg_i                        	: in std_logic;
    adc_clk2x_bufg_i                        : in std_logic;

    -----------------------------
    -- ADC Data Delay signals.
    -----------------------------
    -- Pulse this to update the delay value
    adc_data_dly_pulse_i                    : in std_logic;
    adc_data_dly_val_i                      : in std_logic_vector(4 downto 0);
    adc_data_dly_val_o                      : out std_logic_vector(4 downto 0);

    -----------------------------
    -- ADC output signals.
    -----------------------------
    adc_data_o                              : out std_logic_vector(c_num_adc_bits-1 downto 0);
    adc_data_valid_o                        : out std_logic;
    adc_clk_o                               : out std_logic;
    adc_clk2x_o                             : out std_logic
  );
  end component;

begin
  sys_rst <= not (sys_rst_n_i);

  -- idelay control for var_loadable iodelay mode
  cmp_idelayctrl : idelayctrl
  port map(
    rst                                     => sys_rst,
    refclk                                  => sys_clk_200Mhz_i,
    rdy                                     => open
  );

  -- Generate clock chains
  gen_clock_chains : for i in 0 to chain_intercon'length-1 generate
    gen_clock_chains_check : if g_use_clk_chains(i) = '1' generate
      cmp_fmc516_adc_clk : fmc516_adc_clk
      generic map (
      	-- The only supported values are VIRTEX6 and 7SERIES
        g_fpga_device                       => g_fpga_device,
        g_adc_clock_period                  => g_adc_clk_period_values(i),
        g_default_adc_clk_delay             => g_clk_default_dly(i),
        g_sim                              	=> g_sim
      )
      port map (
        sys_clk_i                       		=> sys_clk_i,
        sys_rst_i                       		=> sys_rst,

        -----------------------------
        -- External ports
        -----------------------------

        -- ADC clocks. One clock per ADC channel
        adc_clk_i               					  => adc_in_i(i).adc_clk,

        -----------------------------
        -- ADC Delay signals.
        -----------------------------
        -- Pulse this to update the delay value
        adc_clk_dly_pulse_i                 => adc_dly_i(i).adc_clk_dly_pulse,
        adc_clk_dly_val_i                   => adc_dly_i(i).adc_clk_dly_val,
        adc_clk_dly_val_o                   => adc_dly_o(i).adc_clk_dly_val,

        -----------------------------
        -- ADC output signals.
        -----------------------------
        adc_clk_bufio_o                 		=> adc_clk_chain(i).adc_clk_bufio,
        adc_clk_bufr_o                  		=> adc_clk_chain(i).adc_clk_bufr,
        adc_clk_bufg_o                  		=> adc_clk_chain(i).adc_clk_bufg,
        adc_clk2x_bufg_o                  	=> adc_clk_chain(i).adc_clk2x_bufg,

        -----------------------------
        -- MMCM general signals
        -----------------------------
        mmcm_adc_locked_o             			=> adc_clk_chain(i).mmcm_adc_locked
      );

    end generate;

    -- Default mmcm_locked signals to 1 is this chain is not used
    gen_mmcm_locked_clock_chains : if g_use_clk_chains(i) = '0' generate
      adc_clk_chain(i).mmcm_adc_locked <= '1';
    end generate;
  end generate;

  mmcm_adc_locked_and(0) <= '1';
  -- ANDing all clock chains mmcm_adc_locked_o
  gen_mmcm_adc_locked : for i in 0 to chain_intercon'length-1 generate
    mmcm_adc_locked_and(i+1) <= mmcm_adc_locked_and(i) and adc_clk_chain(i).mmcm_adc_locked;
  end generate;

  -- output the MSB of mmcm_adc_locked_and, as it contains the and of all the chain.
  -- Note, however, that the snsthesis tool will generate an AND tree for all the
  -- inputs and a single output (mmcm_adc_locked_and(c_num_clock_chains))
  mmcm_adc_locked_o <= mmcm_adc_locked_and(c_num_adc_channels);

  -- Generate data chains and connect it to the clock chain as specified
  -- in chain_intercon
  gen_adc_data_chains : for i in 0 to chain_intercon'length-1 generate
    -- Check if this data chain is to be instanciated
    gen_adc_data_chains_check : if chain_intercon(i) /= -1 generate
      cmp_fmc516_adc_data : fmc516_adc_data
        generic map (
          g_default_adc_data_delay            => g_data_default_dly(i),
          g_sim                              	=> g_sim
        )
        port map (
          sys_clk_i                         	=> sys_clk_i,
          sys_rst_n_i                       	=> adc_in_i(i).adc_rst_n,--sys_rst_n_i,

          -----------------------------
          -- External ports
          -----------------------------

          -- DDR ADC data channels.
          adc_data_i												  => adc_in_i(i).adc_data,

          -----------------------------
          -- Input Clocks from fmc516_adc_clk signals
          -----------------------------
          adc_clk_bufio_i                   	=> adc_clk_chain(chain_intercon(i)).adc_clk_bufio,
          adc_clk_bufr_i                    	=> adc_clk_chain(chain_intercon(i)).adc_clk_bufr,
          adc_clk_bufg_i                    	=> adc_clk_chain(chain_intercon(i)).adc_clk_bufg,
          adc_clk2x_bufg_i                  	=> adc_clk_chain(chain_intercon(i)).adc_clk2x_bufg,
          --adc_clk_bufg_rst_n_i								=> adc_in_i(i).adc_rst_n,

          -----------------------------
          -- ADC Data Delay signals.
          -----------------------------
          -- Pulse this to update the delay value
          adc_data_dly_pulse_i								=> adc_dly_i(i).adc_data_dly_pulse,
          adc_data_dly_val_i  								=> adc_dly_i(i).adc_data_dly_val,
          adc_data_dly_val_o  								=> adc_dly_o(i).adc_data_dly_val,

          -----------------------------
          -- ADC output signals.
          -----------------------------
          adc_data_o													=> adc_out_o(i).adc_data,
          adc_data_valid_o                    => adc_out_o(i).adc_data_valid,
          adc_clk_o														=> adc_out_o(i).adc_clk,
          adc_clk2x_o													=> adc_out_o(i).adc_clk2x
        );
    end generate;
  end generate;

end rtl;
