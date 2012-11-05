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

entity fmc516_adc_iface is
generic
(
    g_num_adc_bits                          : natural := 16;
    g_use_clock_chains                      : std_logic_vector(3 downto 0) := "0010";
    g_use_data_chains                       : std_logic_vector(3 downto 0) := "1111";
    g_adc_clk0_delay                        : natural := 0;
    g_adc_clk1_delay                        : natural := 0;
    g_adc_clk2_delay                        : natural := 0;
    g_adc_clk3_delay                        : natural := 0;
    g_adc_data_ch0_delay                    : natural := 0;
    g_adc_data_ch1_delay                    : natural := 0;
    g_adc_data_ch2_delay                    : natural := 0;
    g_adc_data_ch3_delay                    : natural := 0;
    g_sim                                   : integer := 0
);
port
(
    sys_clk_i                               : in std_logic;
    sys_rst_n_i                             : in std_logic;
    sys_clk_200Mhz_i                        : in std_logic;
    
    -----------------------------
    -- External ports
    -----------------------------
    
    -- ADC clocks. One clock per ADC channel
    adc_clk0_p_i                            : in std_logic;
    adc_clk0_n_i                            : in std_logic;
    adc_clk1_p_i                            : in std_logic;
    adc_clk1_n_i                            : in std_logic;
    adc_clk2_p_i                            : in std_logic;
    adc_clk2_n_i                            : in std_logic;
    adc_clk3_p_i                            : in std_logic;
    adc_clk3_n_i                            : in std_logic;
    
    -- DDR ADC data channels.
    adc_data_ch0_p_i                        : in std_logic_vector(g_adc_bits/2 - 1 downto 0);
    adc_data_ch0_n_i                        : in std_logic_vector(g_adc_bits/2 - 1 downto 0);
    adc_data_ch1_p_i                        : in std_logic_vector(g_adc_bits/2 - 1 downto 0);
    adc_data_ch1_n_i                        : in std_logic_vector(g_adc_bits/2 - 1 downto 0);
    adc_data_ch2_p_i                        : in std_logic_vector(g_adc_bits/2 - 1 downto 0);
    adc_data_ch2_n_i                        : in std_logic_vector(g_adc_bits/2 - 1 downto 0);
    adc_data_ch3_p_i                        : in std_logic_vector(g_adc_bits/2 - 1 downto 0);
    adc_data_ch3_n_i                        : in std_logic_vector(g_adc_bits/2 - 1 downto 0);

    -----------------------------
    -- ADC Delay signals.
    -----------------------------
    -- Pulse this to update all delay values to the corresponding adc_xxx_dly_val_i
    adc_dly_pulse_i                         : in std_logic;
    
    adc_clk0_dly_val_i                      : in std_logic_vector(4 downto 0);
    adc_clk0_dly_val_o                      : out std_logic_vector(4 downto 0);

    adc_clk1_dly_val_i                      : in std_logic_vector(4 downto 0);
    adc_clk1_dly_val_o                      : out std_logic_vector(4 downto 0);

    adc_clk2_dly_val_i                      : in std_logic_vector(4 downto 0);
    adc_clk2_dly_val_o                      : out std_logic_vector(4 downto 0);

    adc_clk3_dly_val_i                      : in std_logic_vector(4 downto 0);
    adc_clk3_dly_val_o                      : out std_logic_vector(4 downto 0);

    adc_data_ch0_dly_val_i                  : in std_logic_vector(4 downto 0);
    adc_data_ch0_dly_val_o                  : out std_logic_vector(4 downto 0);
  
    adc_data_ch1_dly_val_i                  : in std_logic_vector(4 downto 0);
    adc_data_ch1_dly_val_o                  : out std_logic_vector(4 downto 0);
  
    adc_data_ch2_dly_val_i                  : in std_logic_vector(4 downto 0);
    adc_data_ch2_dly_val_o                  : out std_logic_vector(4 downto 0);
  
    adc_data_ch3_dly_val_i                  : in std_logic_vector(4 downto 0);
    adc_data_ch3_dly_val_o                  : out std_logic_vector(4 downto 0);
    
    -----------------------------
    -- ADC output signals.
    -----------------------------
    adc_clk_o                               : out std_logic;
    adc_data_ch0_o                          : out std_logic_vector(g_adc_bits - 1 downto 0);
    adc_data_ch1_o                          : out std_logic_vector(g_adc_bits - 1 downto 0);
    adc_data_ch2_o                          : out std_logic_vector(g_adc_bits - 1 downto 0);
    adc_data_ch3_o                          : out std_logic_vector(g_adc_bits - 1 downto 0);
    adc_data_valid_o                        : out std_logic;

    -----------------------------
    -- MMCM general signals
    -----------------------------
    mmcm_adc_locked_o                       : out std_logic;
);

end fmc516_adc_iface;

architecture rtl of fmc516_adc_iface is

  constant c_num_clock_chains               : natural := 4;
  constant c_num_data_chains                : natural := 4;

  -- ADC clock and data type mangling
  type t_adc_clock_chain is record
    adc_clk_p_i : std_logic;
    adc_clk_n_i : std_logic;
    adc_clk_dly_pulse_i : std_logic;
    adc_clk_dly_val_i : std_logic_vector(4 downto 0); 
    adc_clk_dly_val_o : std_logic_vector(4 downto 0);
    adc_clk_bufio_o: std_logic;
    adc_clk_bufr_o : std_logic;
    adc_clk_bufg_o : std_logic;
    mmcm_adc_locked_o : std_logic;   
  end record;

  type t_adc_data_chain is record
    adc_data_p_i : std_logic_vector(g_adc_bits/2 - 1 downto 0);
    adc_data_n_i : std_logic_vector(g_adc_bits/2 - 1 downto 0);
    adc_clk_bufio_i : std_logic;
    adc_clk_bufr_i : std_logic;
    adc_clk_bufg_i : std_logic;
    adc_data_dly_pulse_i : std_logic;
    adc_data_dly_val_i : std_logic_vector(4 downto 0);
    adc_data_dly_val_o : std_logic_vector(4 downto 0);
    adc_data_o : std_logic;
    adc_clk_o	: std_logic;
  end record;

  subtype t_adc_clock_chain_array is array (natural range <>) of t_adc_clock_chain;
  subtype t_adc_data_chain_array is array (natural range <>) of t_adc_data_chain;
  --type clock_chain_t is array(2*c_num_clock_chains-1 downto 0) of std_logic;
  --type clock_delay_chain_t is array(c_num_clock_chains-1) of std_logic_vector(4 downto 0);
  --type data_delay_chain_t is array(c_num_data_chains-1) of std_logic_vector(4 downto 0);

  signal clock_chain                        : t_adc_clock_chain_array(c_num_clock_chains-1);
  signal data_chain                         : t_adc_data_chain_array(c_num_data_chains-1);
 
  --type data_chain is array(c_num_data_chains-1 downto 0) of std_logic;



  

  
   

begin

  -- Reset for internal use
  sys_rst <= not sys_rst_n_i;

  -- External clock pins connections
  clock_chain <= adc_clk3_p_i & adc_clk3_n_i &
                  adc_clk2_p_i & adc_clk2_n_i &
                  adc_clk1_p_i & adc_clk1_n_i &
                  adc_clk3_p_i & adc_clk0_n_i;

  clock_delay_chain <= adc_clk3_dly_val_i &
                        adc_clk2_dly_val_i &
                        adc_clk1_dly_val_i &
                        adc_clk0_dly_val_i;

  data_delay_chain <= adc_data_ch3_dly_val_i &
                        adc_data_ch2_dly_val_i &
                        adc_data_ch1_dly_val_i &
                        adc_data_ch0_dly_val_i;

  -- idelay control for var_loadable iodelay mode
  cmp_idelayctrl : idelayctrl
  port map
  (
    rst                                     => sys_rst,
    refclk                                  => clk_200Mhz_i,
    rdy                                     => open
  );

  gen_adc_clock_chains : for i in 0 to c_num_adc_clock_chains-1 generate
    gen_connect_clock_to_data_chain : if g_use_clock_chains(i) = '1' generate
    
      cmp_fmc516_adc_clk : fmc516_adc_clk
      generic
      (
        g_default_adc_clk_delay                		=>
        g_sim                                   	=> g_sim
      );
      port
      (
        sys_clk_i                                 => sys_clk_i,
        sys_rst_i                                 => sys_rst_i,
            
        -----------------------------
        -- External ports
        -----------------------------
        
        -- ADC clocks. One clock per ADC channel
        adc_clk_p_i                        				: in std_logic;
        adc_clk_n_i                        				: in std_logic;
        
        -----------------------------
        -- ADC Delay signals.
        -----------------------------
        -- Pulse this to update the delay value
        adc_clk_dly_pulse_i                    		: in std_logic;
        adc_clk_dly_val_i                      		: in std_logic_vector(4 downto 0);
        adc_clk_dly_val_o                      		: out std_logic_vector(4 downto 0);
        
        -----------------------------
        -- ADC output signals.
        -----------------------------
        adc_clk_bufio_o                        		: out std_logic;
        adc_clk_bufr_o                        		: out std_logic;
        adc_clk_bufg_o                        		: out std_logic;

        -----------------------------
        -- MMCM general signals
        -----------------------------
        mmcm_adc_locked_o                       	: out std_logic;
      );
        
      end generate;

      gen_adc_data_chains : for j in i downto 0 generate

      end generate;
  end generate;


end rtl;
