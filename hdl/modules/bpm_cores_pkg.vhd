library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
-- Main Wishbone Definitions
use work.wishbone_pkg.all;

package bpm_cores_pkg is

  component downconv is
    generic (
      g_input_width      : natural := 16;
      g_mixed_width      : natural := 24;
      g_output_width     : natural := 32;
      g_phase_width      : natural := 8;
      g_sin_file         : string  := "./dds_sin.nif";
      g_cos_file         : string  := "./dds_cos.nif";
      g_number_of_points : natural := 6;
      g_diff_delay       : natural := 2;
      g_stages           : natural := 3;
      g_decimation_rate  : natural := 1000);
    port (
      signal_i : in  std_logic_vector(g_input_width-1 downto 0);
      clk_i    : in  std_logic;
      ce_i     : in  std_logic;
      rst_i    : in  std_logic;
      phase_i  : in  std_logic_vector(g_phase_width-1 downto 0);
      I_o      : out std_logic_vector(g_output_width-1 downto 0);
      Q_o      : out std_logic_vector(g_output_width-1 downto 0);
      valid_o  : out std_logic);
  end component downconv;

  component hpf_adcinput
  port
  (
    clk_i    : in  std_logic;
    rst_n_i  : in  std_logic;
    ce_i     : in  std_logic;

    data_i   : in  std_logic_vector(15 downto 0);
    data_o   : out std_logic_vector(15 downto 0)
  );
  end component hpf_adcinput;

  component input_gen is
    generic (
      g_input_width  : natural := 16;
      g_output_width : natural := 16;
      g_ksum         : integer := 1);
    port (
      x_i   : in  std_logic_vector(g_input_width-1 downto 0);
      y_i   : in  std_logic_vector(g_input_width-1 downto 0);
      clk_i : in  std_logic;
      ce_i  : in  std_logic;
      a_o   : out std_logic_vector(g_output_width-1 downto 0);
      b_o   : out std_logic_vector(g_output_width-1 downto 0);
      c_o   : out std_logic_vector(g_output_width-1 downto 0);
      d_o   : out std_logic_vector(g_output_width-1 downto 0));
  end component input_gen;

  component fixed_dds is
    generic (
      g_number_of_points : natural := 203;
      g_output_width     : natural := 16;
      g_sin_file         : string  := "./dds_sin.ram";
      g_cos_file         : string  := "./dds_cos.ram");
    port (
      clk_i   : in  std_logic;
      ce_i    : in  std_logic;
      rst_i   : in  std_logic;
      valid_i : in  std_logic;
      sin_o   : out std_logic_vector(g_output_width-1 downto 0);
      cos_o   : out std_logic_vector(g_output_width-1 downto 0);
      valid_o : out std_logic);
  end component fixed_dds;

  component lut_sweep is
    generic (
      g_number_of_points : natural := 203;
      g_bus_size         : natural := 16);
    port (
      rst_i     : in  std_logic;
      clk_i     : in  std_logic;
      ce_i      : in  std_logic;
      valid_i   : in  std_logic;
      address_o : out std_logic_vector(g_bus_size-1 downto 0);
      valid_o   : out std_logic);
  end component lut_sweep;

  component dds_sin_lut
    port (
      clka  : in  std_logic;
      addra : in  std_logic_vector;
      douta : out std_logic_vector);
  end component dds_sin_lut;

  component dds_cos_lut
    port (
      clka  : in  std_logic;
      addra : in  std_logic_vector;
      douta : out std_logic_vector);
  end component dds_cos_lut;

  component sw_windowing_n_251_tukey_0_2
    port (
      clka  : in  std_logic;
      addra : in  std_logic_vector(7 downto 0);
      douta : out std_logic_vector(23 downto 0)
      );
  end component sw_windowing_n_251_tukey_0_2;

  component input_conditioner is
    generic (
      g_sw_interval      : natural := 1000;
      g_input_width      : natural := 16;
      g_output_width     : natural := 24;
      g_window_width     : natural := 24;
      g_input_delay      : natural := 2;
      g_window_coef_file : string);
    port (
      rst_n_i         : in  std_logic;
      clk_i             : in  std_logic;
      adc_a_i           : in  std_logic_vector(g_input_width-1 downto 0);
      adc_b_i           : in  std_logic_vector(g_input_width-1 downto 0);
      adc_c_i           : in  std_logic_vector(g_input_width-1 downto 0);
      adc_d_i           : in  std_logic_vector(g_input_width-1 downto 0);
      switch_o          : out std_logic;
      switch_en_i       : in  std_logic;
      switch_delay_i    : in  std_logic_vector(15 downto 0);
      a_o               : out std_logic_vector(g_output_width-1 downto 0);
      b_o               : out std_logic_vector(g_output_width-1 downto 0);
      c_o               : out std_logic_vector(g_output_width-1 downto 0);
      d_o               : out std_logic_vector(g_output_width-1 downto 0);
      dbg_cur_address_o : out std_logic_vector(31 downto 0));
  end component input_conditioner;

  component counter is
    generic (
      g_mem_size : natural := 601;
      g_bus_size : natural := 15);
    port (
      clk_i          : in  std_logic;
      ce_i           : in  std_logic;
      rst_n_i      : in  std_logic;
      switch_delay_i : in  std_logic_vector(15 downto 0);
      switch_en_i    : in  std_logic;
      switch_o       : out std_logic;
      index_o        : out std_logic_vector(g_bus_size-1 downto 0));
  end component counter;

end bpm_cores_pkg;

package body bpm_cores_pkg is

end bpm_cores_pkg;
