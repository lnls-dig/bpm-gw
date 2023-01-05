-------------------------------------------------------------------------------
-- Title      : BPM Mixer
-- Project    :
-------------------------------------------------------------------------------
-- File       : mixer.vhd
-- Author     : Gustavo BM Bruno
-- Company    : LNLS - CNPEM
-- Created    : 2014-01-21
-- Last update: 2022-12-16
-- Platform   :
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Mixer at input stage for BPM
-------------------------------------------------------------------------------
-- Copyright (c) 2014
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author            Description
-- 2014-01-21  1.0      aylons            Created
-- 2022-12-16  1.1      guilherme.ricioli Properly propagated input and tag
--                                        signals
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library work;
use work.dsp_cores_pkg.all;
use work.bpm_cores_pkg.all;

entity mixer is
  generic (
    g_number_of_points  : natural := 6;
    g_dds_width         : natural := 16;
    g_input_width       : natural := 16;
    g_output_width      : natural := 32;
    g_tag_width         : natural := 1;
    g_mult_levels       : natural := 7
  );
  port (
    rst_i               : in  std_logic;
    clk_i               : in  std_logic;
    ce_i                : in  std_logic;
    signal_i            : in  std_logic_vector(g_input_width-1 downto 0);
    valid_i             : in  std_logic;
    tag_i               : in  std_logic_vector(g_tag_width-1 downto 0) := (others => '0');
    i_o                 : out std_logic_vector(g_output_width-1 downto 0);
    q_o                 : out std_logic_vector(g_output_width-1 downto 0);
    valid_o             : out std_logic;
    i_tag_o             : out std_logic_vector(g_tag_width-1 downto 0);
    q_tag_o             : out std_logic_vector(g_tag_width-1 downto 0)
  );

end entity mixer;

architecture structural of mixer is

  -- signals
  signal sin, cos         : std_logic_vector(g_dds_width-1 downto 0);
  signal fixed_dds_tag    : std_logic_vector(g_tag_width-1 downto 0) := (others => '0');
  signal fixed_dds_valid  : std_logic;
  signal signal_d2        : std_logic_vector(g_input_width-1 downto 0);
  signal i_valid          : std_logic;

begin

  -- components instantiation

  -- stages 1 and 2 of 12: get next sin/cos sample
  cmp_fixed_dds : fixed_dds
    generic map (
      g_number_of_points  => g_number_of_points,
      g_output_width      => g_dds_width,
      g_tag_width         => g_tag_width
    )
    port map (
      clk_i               => clk_i,
      ce_i                => ce_i,
      rst_i               => rst_i,
      valid_i             => valid_i,
      tag_i               => tag_i,
      sin_o               => sin,
      cos_o               => cos,
      valid_o             => fixed_dds_valid,
      tag_o               => fixed_dds_tag
    );

  -- leveling cmp_fixed_dds delay
  cmp_pipeline_signal : pipeline
    generic map (
      g_width => g_input_width,
      g_depth => 2
    )
    port map (
      clk_i   => clk_i,
      ce_i    => ce_i,
      data_i  => signal_i,
      data_o  => signal_d2
    );

  -- stages 3 through 12 of 12: computing in-phase signal (i)
  cmp_mult_i : generic_multiplier
    generic map (
      g_a_width           => g_input_width,
      g_b_width           => g_dds_width,
      g_signed            => true,
      g_tag_width         => g_tag_width,
      g_p_width           => g_output_width,
      g_round_convergent  => 1,
      g_levels            => g_mult_levels
    )
    port map (
      a_i                 => signal_d2,
      b_i                 => cos,
      tag_i               => fixed_dds_tag,
      valid_i             => fixed_dds_valid,
      p_o                 => i_o,
      valid_o             => i_valid,
      tag_o               => i_tag_o,
      ce_i                => ce_i,
      clk_i               => clk_i,
      rst_i               => rst_i
    );


  -- stages 3 through 12 of 12: computing quadrature signal (q)
  cmp_mult_q : generic_multiplier
    generic map (
      g_a_width           => g_input_width,
      g_b_width           => g_dds_width,
      g_signed            => true,
      g_tag_width         => g_tag_width,
      g_p_width           => g_output_width,
      g_round_convergent  => 1,
      g_levels            => g_mult_levels
    )
    port map (
      a_i                 => signal_d2,
      b_i                 => sin,
      tag_i               => fixed_dds_tag,
      valid_i             => fixed_dds_valid,
      p_o                 => q_o,
      valid_o             => open,
      tag_o               => q_tag_o,
      clk_i               => clk_i,
      ce_i                => ce_i,
      rst_i               => rst_i
    );

    -- any valid, either from i or q is fine.
    valid_o <= i_valid;

end structural;
