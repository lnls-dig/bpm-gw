-------------------------------------------------------------------------------
-- Title      : Fixed sin-cos DDS
-- Project    :
-------------------------------------------------------------------------------
-- File       : fixed_dds.vhd
-- Author     : aylons  <aylons@LNLS190>
-- Company    :
-- Created    : 2014-03-07
-- Last update: 2022-12-15
-- Platform   :
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Fixed frequency phase and quadrature DDS for use in tuned DDCs.
-------------------------------------------------------------------------------
-- Copyright (c) 2014
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author            Description
-- 2014-03-07  1.0      aylons            Created
-- 2022-12-15  1.1      guilherme.ricioli Fixed pipeline stages
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.genram_pkg.all;
use work.dsp_cores_pkg.all;
use work.bpm_cores_pkg.all;

entity fixed_dds is
  generic (
    -- output resolution
    g_output_width      : natural := 16;

    -- number of data points of sin/cos files (each)
    g_number_of_points  : natural := 203
  );
  port (
    clk_i               : in  std_logic;
    ce_i                : in  std_logic;
    rst_i               : in  std_logic;
    valid_i             : in  std_logic;
    sin_o               : out std_logic_vector(g_output_width-1 downto 0);
    cos_o               : out std_logic_vector(g_output_width-1 downto 0);
    valid_o             : out std_logic
  );
end entity fixed_dds;

architecture structural of fixed_dds is

  -- constants
  constant c_bus_size : natural := f_log2_size(g_number_of_points);

  -- signals
  signal address          : std_logic_vector(c_bus_size-1 downto 0);
  signal lut_sweep_valid  : std_logic := '0';
  signal sin, cos         : std_logic_vector(g_output_width-1 downto 0);

begin

  -- components instantiation

  -- stage 1 of 2: get next lut address
  cmp_lut_sweep : lut_sweep
    generic map (
      g_number_of_points  => g_number_of_points,
      g_bus_size          => c_bus_size
    )
    port map (
      clk_i               => clk_i,
      ce_i                => ce_i,
      rst_i               => rst_i,
      valid_i             => valid_i,
      address_o           => address,
      valid_o             => lut_sweep_valid
    );

  -- stage 2 of 2: read sin lut sample
  cmp_dds_sin_lut : dds_sin_lut
    port map (
      clka  => clk_i,
      addra => address,
      douta => sin_o
    );

  -- stage 2 of 2: read cos lut sample
  cmp_dds_cos_lut : dds_cos_lut
    port map (
      clka  => clk_i,
      addra => address,
      douta => cos_o
    );

  -- leveling dds_{sin,cos}_lut reading delay
  cmp_pipeline_valid : pipeline
    generic map (
      g_width   => 1,
      g_depth   => 1
    )
    port map (
      clk_i     => clk_i,
      ce_i      => ce_i,
      data_i(0) => lut_sweep_valid,
      data_o(0) => valid_o
    );

end architecture structural;
