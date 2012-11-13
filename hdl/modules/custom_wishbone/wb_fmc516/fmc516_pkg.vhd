library ieee;
use ieee.std_logic_1164.all;

library work;
use work.wishbone_pkg.all;
use work.wb_stream_pkg.all;

package fmc516_pkg is
  --------------------------------------------------------------------
  -- Constants
  --------------------------------------------------------------------
  -- constants for the fmc516_adc_iface
  constant c_num_adc_channels : natural := 4;
  constant c_num_adc_bits : natural := 16;
  --------------------------------------------------------------------
  -- Generic definitions
  --------------------------------------------------------------------
  type t_real_array is array (natural range <>) of real;
  type t_natural_array is array (natural range <>) of natural;

  --------------------------------------------------------------------
  -- Specific definitions
  --------------------------------------------------------------------
  -- types for the fmc516_adc_iface
  type t_adc_in is record
    adc_clk_p : std_logic;
    adc_clk_n : std_logic;
    adc_rst_n : std_logic;
    adc_data_p : std_logic_vector(c_num_adc_bits/2 - 1 downto 0);
    adc_data_n : std_logic_vector(c_num_adc_bits/2 - 1 downto 0);
  end record;

  type t_adc_in_array is array (natural range <>) of t_adc_in;

  type t_adc_dly is record
    adc_clk_dly_pulse : std_logic;
    adc_clk_dly_val : std_logic_vector(4 downto 0);
    adc_data_dly_pulse : std_logic;
    adc_data_dly_val : std_logic_vector(4 downto 0);
  end record;

  type t_adc_dly_array is array (natural range <>) of t_adc_dly;

  type t_adc_out is record
    adc_clk : std_logic;
    adc_data : std_logic_vector(c_num_adc_bits-1 downto 0);
    adc_data_valid : std_logic;
  end record;

  type t_adc_out_array is array (natural range <>) of t_adc_out;

  -- types for fmc516_adc_iface generic definitions
  subtype t_default_adc_dly is t_natural_array(c_num_adc_channels-1 downto 0);
  subtype t_clk_values_array is t_real_array(c_num_adc_channels-1 downto 0);
  subtype t_clk_use_chain is std_logic_vector(c_num_adc_channels-1 downto 0);
  subtype t_data_use_chain is std_logic_vector(c_num_adc_channels-1 downto 0);

  -- dummy values for fmc516_adc_iface generic definitions
  -- Warning: all clocks are null here! Should be modified
  constant dummy_clks : t_clk_values_array := (others => 0.0);
  constant dummy_clk_use_chain : t_clk_use_chain := (others => '0');
  constant dummy_data_use_chain : t_data_use_chain := (others => '0');
  constant dummy_default_dly : t_default_adc_dly := (others => 0);

end fmc516_pkg;
