-------------------------------------------------------------------------------
-- Title      : Fixed DDS testbench
-- Project    :
-------------------------------------------------------------------------------
-- File       : fixed_dds_tb.vhd
-- Author     : aylons  <aylons@LNLS190>
-- Company    :
-- Created    : 2014-03-07
-- Last update: 2022-12-15
-- Platform   :
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: Testbench for the fixed-frequency DDS
-------------------------------------------------------------------------------
-- Copyright (c) 2014
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author            Description
-- 2014-03-07  1.0      aylons            Created
-- 2022-12-15  2.0      guilherme.ricioli Refactored. Added output checkness.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library std;
use std.env.finish;
use std.textio.all;

entity fixed_dds_tb is
end entity fixed_dds_tb;

architecture testbench of fixed_dds_tb is

  -- constants
  constant clk_freq : natural := 117429390;

  constant c_output_width : natural := 16;
  constant c_number_of_points : natural := 191;
  constant c_tag_width : natural := 1;

  -- signals
  signal clk : std_logic := '0';
  signal ce : std_logic := '0';
  signal rst : std_logic := '1';
  signal valid : std_logic := '0';
  signal tag : std_logic_vector(c_tag_width-1 downto 0);
  signal sin : std_logic_vector(c_output_width-1 downto 0);
  signal cos : std_logic_vector(c_output_width-1 downto 0);
  signal fixed_dds_valid : std_logic := '0';
  signal cos_checked, sin_checked : boolean := false;

  -- procedures
  procedure f_gen_clk(constant freq : in    natural;
                      signal   clk  : inout std_logic) is
  begin
      loop
          wait for (0.5 / real(freq)) * 1 sec;
          clk <= not clk;
      end loop;
  end procedure f_gen_clk;

  procedure f_wait_cycles(signal   clk    : in std_logic;
                          constant cycles : natural) is
  begin
      for i in 1 to cycles loop
          wait until rising_edge(clk);
      end loop;
  end procedure f_wait_cycles;

  procedure f_wait_clocked_signal(signal clk : in std_logic;
                                  signal sig : in std_logic;
                                  val        : in std_logic;
                                  timeout    : in natural := 2147483647) is
                                  variable cnt : natural := timeout;
  begin
      while sig /= val and cnt > 0 loop
          wait until rising_edge(clk);
          cnt := cnt - 1;
      end loop;
  end procedure f_wait_clocked_signal;

  -- components declaration
  component fixed_dds is
    generic (
      g_output_width      : natural := 16;
      g_number_of_points  : natural := 203;
      g_tag_width         : natural := 1
    );
    port (
      clk_i               : in  std_logic;
      ce_i                : in  std_logic;
      rst_i               : in  std_logic;
      valid_i             : in  std_logic;
      tag_i               : in  std_logic_vector(g_tag_width-1 downto 0) := (others => '0');
      sin_o               : out std_logic_vector(g_output_width-1 downto 0);
      cos_o               : out std_logic_vector(g_output_width-1 downto 0);
      valid_o             : out std_logic;
      tag_o               : out std_logic_vector(g_tag_width-1 downto 0)
    );
  end component fixed_dds;


begin

  f_gen_clk(clk_freq, clk);

  -- process to drive fixed_dds
  drive_fixed_dds: process
  begin
    -- resetting cores
    rst <= '1';
    f_wait_cycles(clk, 10);

    rst <= '0';
    f_wait_cycles(clk, 1);

    for sample in 1 to c_number_of_points
    loop
      ce <= '1';
      valid <= '1';
      tag <= (others => '1');
      f_wait_cycles(clk, 1);
    end loop;

    ce <= '0';
    valid <= '0';
    tag <= (others => '0');
    f_wait_cycles(clk, 1);
    wait;
  end process drive_fixed_dds;

  -- process to check fixed_dds generated cos
  check_cos: process
    file fin : text;
    variable lin : line;
    variable expec_cos : std_logic_vector(c_output_width-1 downto 0);
  begin
    file_open(fin, "../cos_lut_sirius_50_191.dat", read_mode);

    loop
      f_wait_clocked_signal(ce, clk, '1');

      if fixed_dds_valid = '1' then
        if not endfile(fin) then
          readline(fin, lin);
          hread(lin, expec_cos);
        else
          cos_checked <= true;
          exit;
        end if;

        -- check against expected values
        if cos /= expec_cos then
          report
            "wrong cos sample: " & to_hstring(cos) & " (expected " &
            to_hstring(expec_cos) & ")"
          severity error;
        end if;
      end if;
      f_wait_cycles(clk, 1);
    end loop;

    wait;
  end process check_cos;

  -- process to check fixed_dds generated sin
  check_sin: process
    file fin : text;
    variable lin : line;
    variable expec_sin : std_logic_vector(c_output_width-1 downto 0);
  begin
    file_open(fin, "../sin_lut_sirius_50_191.dat", read_mode);

    loop
      f_wait_clocked_signal(ce, clk, '1');

      if fixed_dds_valid = '1' then
        if not endfile(fin) then
          readline(fin, lin);
          hread(lin, expec_sin);
        else
          sin_checked <= true;
          exit;
        end if;

        -- check against expected values
        if sin /= expec_sin then
          report
            "wrong sin sample: " & to_hstring(sin) & " (expected " &
            to_hstring(expec_sin) & ")"
          severity error;
        end if;
      end if;
      f_wait_cycles(clk, 1);
    end loop;

    wait;
  end process check_sin;

  process
  begin
    if rising_edge(clk) then
      if cos_checked = true and sin_checked = true then
        report "everything ok"
        severity note;
        finish;
      end if;
    end if;
    f_wait_cycles(clk, 1);
  end process;

  -- components instantiation
  uut : fixed_dds
    generic map (
      g_output_width      => c_output_width,
      g_number_of_points  => c_number_of_points,
      g_tag_width         => c_tag_width
    )
    port map (
      clk_i               => clk,
      ce_i                => ce,
      rst_i               => rst,
      valid_i             => valid,
      tag_i               => tag,
      sin_o               => sin,
      cos_o               => cos,
      valid_o             => fixed_dds_valid,
      tag_o               => open
  );

end architecture testbench;
