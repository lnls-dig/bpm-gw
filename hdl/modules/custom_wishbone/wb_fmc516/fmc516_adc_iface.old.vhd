------------------------------------------------------------------------------
-- Title      : Wishbone FMC516 ADC Interface
------------------------------------------------------------------------------
-- Author     : Lucas Maziero Russo
-- Company    : CNPEM LNLS-DIG
-- Created    : 2012-17-10
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: ADC Interface with FMC516 ADC board from Curtis Wright.
--
-- Currently all ADC data is clocked on rising_edge of clk1, as this is an
-- IO pin capable of driving regional clocks up to 3 clocks regions (MRCC).
--
-- The generic parameter g_use_clocks specifies which clocks are to be used
-- for acquiring the corresponding adc data. This is not yet implemented!
-- Because of this, it should not be modified!
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

-- Should each channel have its own signal struture?
-- Should each related signal be in a separate struture?
-- If they were we could simplify the internal assignts for the generate statements
-- and make this module more generic and ADC agnostic (=])
entity fmc516_adc_iface is
generic
(
  g_adc_bits                                : natural := 16;
  g_adc_clock_period_values                 : t_clock_values_array(3 downto 0) := dummy_clocks;
  g_use_clock_chains                        : std_logic_vector(3 downto 0) := "0010";
  g_use_data_chains                         : std_logic_vector(3 downto 0) := "1111";
  g_sim                                     : integer := 0
);
port
(
  sys_clk_i                                 : in std_logic;
  -- System Reset
  sys_rst_n_i                               : in std_logic;
  -- ADC clock generation reset. Just a regular asynchronous reset.
  adc_clk_chain_rst_i                       : in std_logic;
  sys_clk_200Mhz_i                          : in std_logic;

  -----------------------------
  -- External ports
  -----------------------------

  -- ADC clocks. One clock per ADC channel
  adc_clk0_p_i                              : in std_logic;
  adc_clk0_n_i                              : in std_logic;
  adc_clk1_p_i                              : in std_logic;
  adc_clk1_n_i                              : in std_logic;
  adc_clk2_p_i                              : in std_logic;
  adc_clk2_n_i                              : in std_logic;
  adc_clk3_p_i                              : in std_logic;
  adc_clk3_n_i                              : in std_logic;

  -- Do I need really to worry about the deassertion of async resets?
  -- Generate them outside this module, as this reset is needed by
  -- external logic
  adc_clk0_rst_n_i                          : in std_logic;
  adc_clk1_rst_n_i                          : in std_logic;
  adc_clk2_rst_n_i                          : in std_logic;
  adc_clk3_rst_n_i                          : in std_logic;

  -- DDR ADC data channels.
  adc_data_ch0_p_i                          : in std_logic_vector(g_adc_bits/2 - 1 downto 0);
  adc_data_ch0_n_i                          : in std_logic_vector(g_adc_bits/2 - 1 downto 0);
  adc_data_ch1_p_i                          : in std_logic_vector(g_adc_bits/2 - 1 downto 0);
  adc_data_ch1_n_i                          : in std_logic_vector(g_adc_bits/2 - 1 downto 0);
  adc_data_ch2_p_i                          : in std_logic_vector(g_adc_bits/2 - 1 downto 0);
  adc_data_ch2_n_i                          : in std_logic_vector(g_adc_bits/2 - 1 downto 0);
  adc_data_ch3_p_i                          : in std_logic_vector(g_adc_bits/2 - 1 downto 0);
  adc_data_ch3_n_i                          : in std_logic_vector(g_adc_bits/2 - 1 downto 0);

  -----------------------------
  -- ADC Delay signals.
  -----------------------------
  -- Pulse this to update all delay values to the corresponding adc_xxx_dly_val_i
  adc_dly_pulse_i                           : in std_logic;

  adc_clk0_dly_val_i                        : in std_logic_vector(4 downto 0);
  adc_clk0_dly_val_o                        : out std_logic_vector(4 downto 0);
  adc_clk1_dly_val_i                        : in std_logic_vector(4 downto 0);
  adc_clk1_dly_val_o                        : out std_logic_vector(4 downto 0);
  adc_clk2_dly_val_i                        : in std_logic_vector(4 downto 0);
  adc_clk2_dly_val_o                        : out std_logic_vector(4 downto 0);
  adc_clk3_dly_val_i                        : in std_logic_vector(4 downto 0);
  adc_clk3_dly_val_o                        : out std_logic_vector(4 downto 0);

  adc_data_ch0_dly_val_i                    : in std_logic_vector(4 downto 0);
  adc_data_ch0_dly_val_o                    : out std_logic_vector(4 downto 0);
  adc_data_ch1_dly_val_i                    : in std_logic_vector(4 downto 0);
  adc_data_ch1_dly_val_o                    : out std_logic_vector(4 downto 0);
  adc_data_ch2_dly_val_i                    : in std_logic_vector(4 downto 0);
  adc_data_ch2_dly_val_o                    : out std_logic_vector(4 downto 0);
  adc_data_ch3_dly_val_i                    : in std_logic_vector(4 downto 0);
  adc_data_ch3_dly_val_o                    : out std_logic_vector(4 downto 0);

  -----------------------------
  -- ADC output signals.
  -----------------------------
  adc_clk_o                                 : out std_logic_vector(g_use_clock_chains'length-1 downto 0);
  adc_data_ch0_o                            : out std_logic_vector(g_adc_bits - 1 downto 0);
  adc_data_ch1_o                            : out std_logic_vector(g_adc_bits - 1 downto 0);
  adc_data_ch2_o                            : out std_logic_vector(g_adc_bits - 1 downto 0);
  adc_data_ch3_o                            : out std_logic_vector(g_adc_bits - 1 downto 0);
  adc_data_valid_o                          : out std_logic;

  -----------------------------
  -- MMCM general signals
  -----------------------------
  mmcm_adc_locked_o                         : out std_logic
);

end fmc516_adc_iface;

architecture rtl of fmc516_adc_iface is

  constant c_num_clock_chains               : natural := g_use_clock_chains'length;
  constant c_num_data_chains                : natural := g_use_data_chains'length;

  -- General signals
  signal sys_rst                            : std_logic;
  signal sys_rst_all                        : std_logic;
  signal sys_rst_adc_clk_chain              : std_logic;

  -- AND mmcm signals. Use the MSB bit for the final result
  signal mmcm_adc_locked_and                : std_logic_vector(c_num_clock_chains downto 0);

  -- ADC clock type mangling for generates statements
  type t_adc_clock_chain is record
    adc_clk_p : std_logic;
    adc_clk_n : std_logic;
    adc_clk_bufio: std_logic;
    adc_clk_bufr : std_logic;
    adc_clk_bufg : std_logic;
    adc_clk_dly_pulse : std_logic;
    adc_clk_dly_val_in : std_logic_vector(4 downto 0);
    adc_clk_dly_val_out : std_logic_vector(4 downto 0);
    mmcm_adc_locked : std_logic;
  end record;

  -- ADC data type mangling for generates statements
  type t_adc_data_chain is record
    adc_data_p : std_logic_vector(g_adc_bits/2 - 1 downto 0);
    adc_data_n : std_logic_vector(g_adc_bits/2 - 1 downto 0);
    adc_clk_bufio : std_logic;
    adc_clk_bufr : std_logic;
    adc_clk_bufg : std_logic;
    adc_clk_bufg_rst_n : std_logic;
    adc_data_dly_pulse : std_logic;
    adc_data_dly_val_in : std_logic_vector(4 downto 0);
    adc_data_dly_val_out : std_logic_vector(4 downto 0);
    adc_data : std_logic_vector(g_adc_bits-1 downto 0);
    adc_data_valid : std_logic;
    adc_clk	: std_logic;
  end record;

  -- Delay array for generate statements
  type t_delay_array is array (natural range <>) of natural;

  -- ADC and Clock chain for generate statements
  type t_adc_clock_chain_array is array (natural range <>) of t_adc_clock_chain;
  type t_adc_data_chain_array is array (natural range <>) of t_adc_data_chain;

  -- Conectivity vector for interconnecting clocks and data chains
  type t_chain_intercon is array (natural range <>) of integer;

  -- ADc and Clock chains
  signal adc_clock_chain						 				: t_adc_clock_chain_array(c_num_clock_chains-1 downto 0);
  signal adc_data_chain                     : t_adc_data_chain_array(c_num_data_chains-1 downto 0);

  -- Constant delay chains
  constant adc_clock_delay					 				: t_delay_array(c_num_clock_chains-1 downto 0) := (others => 0);
  constant adc_data_delay					 				  : t_delay_array(c_num_data_chains-1 downto 0) := (others => 0);

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

    -- If there are remaining data chains unclocked, attribute
    -- them to the last usable clock
    for i in data_chain_idx to c_num_chains-1 loop
      if data_chains(i) = '1' then
        intercon(i) := data_chain_idx-1;
      end if;
    end loop;

    -- Print the intercon vector
    --k := 0;
    --while k < c_num_chains loop
    for k in 0 to c_num_chains-1 loop
      report "[ intercon(" & integer'image(k) & ") = " &
          Integer'image(intercon(k)) & " ]"
      severity note;
      --k := k + 1;
    end loop;

    return intercon;
  end f_chain_intercon;

  constant chain_intercon                   : t_chain_intercon :=
      f_chain_intercon(g_use_clock_chains, g_use_data_chains);

  -----------------------------
  -- Components declaration
  -----------------------------

  component fmc516_adc_clk
  generic(
    -- This genric must be specified
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
    adc_clk_p_i                             : in std_logic;
    adc_clk_n_i                        		  : in std_logic;

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

    -----------------------------
    -- MMCM general signals
    -----------------------------
    mmcm_adc_locked_o                       : out std_logic
  );
  end component;

  component fmc516_adc_data
  generic(
    g_adc_bits                              : natural := 16;
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
    adc_data_p_i	                          : in std_logic_vector(g_adc_bits/2 - 1 downto 0);
    adc_data_n_i														: in std_logic_vector(g_adc_bits/2 - 1 downto 0);

    -----------------------------
    -- Input Clocks from fmc516_adc_clk signals
    -----------------------------
    adc_clk_bufio_i                        	: in std_logic;
    adc_clk_bufr_i                        	: in std_logic;
    adc_clk_bufg_i                        	: in std_logic;
    adc_clk_bufg_rst_n_i										: in std_logic;

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
    adc_data_o                              : out std_logic_vector(g_adc_bits-1 downto 0);
    adc_data_valid_o                        : out std_logic;
    adc_clk_o                               : out std_logic
  );
  end component;

begin

  -- Reset for internal use
  sys_rst <= not(sys_rst_n_i);

  -----------------------------
  -- External clock pins connections for generate statements
  -----------------------------

  adc_clock_chain(3).adc_clk_p <= adc_clk3_p_i;
	adc_clock_chain(3).adc_clk_n <= adc_clk3_n_i;
	adc_clock_chain(3).adc_clk_dly_pulse <= adc_dly_pulse_i;
	adc_clock_chain(3).adc_clk_dly_val_in <= adc_data_ch3_dly_val_i;

  adc_clock_chain(2).adc_clk_p <= adc_clk2_p_i;
	adc_clock_chain(2).adc_clk_n <= adc_clk2_n_i;
	adc_clock_chain(2).adc_clk_dly_pulse <= adc_dly_pulse_i;
	adc_clock_chain(2).adc_clk_dly_val_in <= adc_data_ch2_dly_val_i;

  adc_clock_chain(1).adc_clk_p <= adc_clk1_p_i;
	adc_clock_chain(1).adc_clk_n <= adc_clk1_n_i;
	adc_clock_chain(1).adc_clk_dly_pulse <= adc_dly_pulse_i;
	adc_clock_chain(1).adc_clk_dly_val_in <= adc_data_ch1_dly_val_i;

  adc_clock_chain(0).adc_clk_p <= adc_clk0_p_i;
	adc_clock_chain(0).adc_clk_n <= adc_clk0_n_i;
	adc_clock_chain(0).adc_clk_dly_pulse <= adc_dly_pulse_i;
	adc_clock_chain(0).adc_clk_dly_val_in <= adc_data_ch0_dly_val_i;

  adc_data_chain(3).adc_data_p <= adc_data_ch3_p_i;
  adc_data_chain(3).adc_data_n <= adc_data_ch3_n_i;
  adc_data_chain(3).adc_data_dly_pulse <= adc_dly_pulse_i;
  adc_data_chain(3).adc_data_dly_val_in <= adc_data_ch3_dly_val_i;
  adc_data_chain(3).adc_clk_bufg_rst_n <= adc_clk3_rst_n_i;

  adc_data_chain(2).adc_data_p <= adc_data_ch2_p_i;
  adc_data_chain(2).adc_data_n <= adc_data_ch2_n_i;
  adc_data_chain(2).adc_data_dly_pulse <= adc_dly_pulse_i;
  adc_data_chain(2).adc_data_dly_val_in <= adc_data_ch2_dly_val_i;
  adc_data_chain(2).adc_clk_bufg_rst_n <= adc_clk2_rst_n_i;

  adc_data_chain(1).adc_data_p <= adc_data_ch1_p_i;
  adc_data_chain(1).adc_data_n <= adc_data_ch1_n_i;
  adc_data_chain(1).adc_data_dly_pulse <= adc_dly_pulse_i;
  adc_data_chain(1).adc_data_dly_val_in <= adc_data_ch1_dly_val_i;
  adc_data_chain(1).adc_clk_bufg_rst_n <= adc_clk1_rst_n_i;

  adc_data_chain(0).adc_data_p <= adc_data_ch0_p_i;
  adc_data_chain(0).adc_data_n <= adc_data_ch0_n_i;
  adc_data_chain(0).adc_data_dly_pulse <= adc_dly_pulse_i;
  adc_data_chain(0).adc_data_dly_val_in <= adc_data_ch0_dly_val_i;
  adc_data_chain(0).adc_clk_bufg_rst_n <= adc_clk0_rst_n_i;

  -- idelay control for var_loadable iodelay mode
  cmp_idelayctrl : idelayctrl
  port map(
    rst                                     => sys_rst,
    refclk                                  => sys_clk_200Mhz_i,
    rdy                                     => open
  );

  -- Generate clock chains
  gen_clock_chains : for i in 0 to chain_intercon'length-1 generate
    gen_check_clock_chains : if g_use_clock_chains(i) = '1' generate
      cmp_fmc516_adc_clk : fmc516_adc_clk
      generic map (
        g_adc_clock_period                  => g_adc_clock_period_values(i),
        g_default_adc_clk_delay             => adc_clock_delay(i),
        g_sim                              	=> g_sim
      )
      port map (
        sys_clk_i                       		=> sys_clk_i,
        sys_rst_i                       		=> adc_clk_chain_rst_i,

        -----------------------------
        -- External ports
        -----------------------------

        -- ADC clocks. One clock per ADC channel
        adc_clk_p_i              						=> adc_clock_chain(i).adc_clk_p,
        adc_clk_n_i               					=> adc_clock_chain(i).adc_clk_n,

        -----------------------------
        -- ADC Delay signals.
        -----------------------------
        -- Pulse this to update the delay value
        adc_clk_dly_pulse_i                 => adc_clock_chain(i).adc_clk_dly_pulse,
        adc_clk_dly_val_i                   => adc_clock_chain(i).adc_clk_dly_val_in,
        adc_clk_dly_val_o                   => adc_clock_chain(i).adc_clk_dly_val_out,

        -----------------------------
        -- ADC output signals.
        -----------------------------
        adc_clk_bufio_o                 		=> adc_clock_chain(i).adc_clk_bufio,
        adc_clk_bufr_o                  		=> adc_clock_chain(i).adc_clk_bufr,
        adc_clk_bufg_o                  		=> adc_clock_chain(i).adc_clk_bufg,

        -----------------------------
        -- MMCM general signals
        -----------------------------
        mmcm_adc_locked_o             			=> adc_clock_chain(i).mmcm_adc_locked
      );

    end generate;

    -- Default mmcm_locked signals to 1 is this chain is not used
    gen_mmcm_locked_clock_chains : if g_use_clock_chains(i) = '0' generate
      adc_clock_chain(i).mmcm_adc_locked <= '1';
    end generate;
  end generate;

  mmcm_adc_locked_and(0) <= '1';
  -- ANDing all clock chains mmcm_adc_locked_o
  gen_mmcm_adc_locked : for i in 0 to chain_intercon'length-1 generate
    mmcm_adc_locked_and(i+1) <= mmcm_adc_locked_and(i) and adc_clock_chain(i).mmcm_adc_locked;
  end generate;

  -- output the MSB of mmcm_adc_locked_and, as it contains the and of all the chain.
  -- Note, however, that the snsthesis tool will generate an AND tree for all the
  -- inputs and a single output (mmcm_adc_locked_and(c_num_clock_chains))
  mmcm_adc_locked_o <= mmcm_adc_locked_and(c_num_clock_chains);

  -- Generate data chains and connect it to the clock chain as specified
  -- in chain_intercon
  gen_adc_data_chains : for i in 0 to chain_intercon'length-1 generate
    -- Check if this data chain is to be instanciated
    gen_adc_data_chains_check : if chain_intercon(i) /= -1 generate
      cmp_fmc516_adc_data : fmc516_adc_data
        generic map (
          g_adc_bits                  		    => g_adc_bits,
          g_default_adc_data_delay            => adc_data_delay(i),
          g_sim                              	=> g_sim
        )
        port map (
          sys_clk_i                         	=> sys_clk_i,
          sys_rst_n_i                       	=> sys_rst_n_i,

          -----------------------------
          -- External ports
          -----------------------------

          -- DDR ADC data channels.
          adc_data_p_i												=> adc_data_chain(i).adc_data_p,
          adc_data_n_i												=> adc_data_chain(i).adc_data_n,

          -----------------------------
          -- Input Clocks from fmc516_adc_clk signals
          -----------------------------
          adc_clk_bufio_i                   	=> adc_clock_chain(chain_intercon(i)).adc_clk_bufio,
          adc_clk_bufr_i                    	=> adc_clock_chain(chain_intercon(i)).adc_clk_bufr,
          adc_clk_bufg_i                    	=> adc_clock_chain(chain_intercon(i)).adc_clk_bufg,
          adc_clk_bufg_rst_n_i								=> adc_data_chain(i).adc_clk_bufg_rst_n,

          -----------------------------
          -- ADC Data Delay signals.
          -----------------------------
          -- Pulse this to update the delay value
          adc_data_dly_pulse_i								=> adc_data_chain(i).adc_data_dly_pulse,
          adc_data_dly_val_i  								=> adc_data_chain(i).adc_data_dly_val_in,
          adc_data_dly_val_o  								=> adc_data_chain(i).adc_data_dly_val_out,

          -----------------------------
          -- ADC output signals.
          -----------------------------
          adc_data_o													=> adc_data_chain(i).adc_data,
          adc_data_valid_o                    => adc_data_chain(i).adc_data_valid,
          adc_clk_o														=> adc_data_chain(i).adc_clk
        );
    end generate;
  end generate;

  -- Generate the ADC clocks
  gen_adc_out_clocks : for i in 0 to chain_intercon'length-1 generate
    adc_clk_o(i)                            <= adc_data_chain(i).adc_clk
  end generate;

end rtl;
