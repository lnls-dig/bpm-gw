-------------------------------------------------------------------------------
-- Title      : Mixer testbench
-- Project    :
-------------------------------------------------------------------------------
-- File       : mixer_tb.vhd
-- Author     : Gustavo BM Bruno
-- Company    : LNLS
-- Created    : 2014-01-21
-- Last update: 2023-01-05
-- Platform   :
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Tests the mixer stage of the BPM DSP chain.
-------------------------------------------------------------------------------
-- Copyright (c) 2014
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author            Description
-- 2014-01-21  1.0      aylons            Created
-- 2023-01-05  2.0      guilherme.ricioli Refactored. Added output checkness.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.env.finish;
use std.textio.all;

entity mixer_tb is
end mixer_tb;

architecture testbench of mixer_tb is

  -- constants
  constant clk_freq : natural := 117429390;

  constant c_number_of_points : natural := 191;
  constant c_input_width : natural := 16;
  constant c_output_width : natural := 16;
  constant c_dds_width : natural := 16;
  constant c_tag_width : natural := 1;
  constant c_mult_levels : natural := 7;

  -- signals
  signal rst : std_logic := '1';
  signal clk : std_logic := '0';
  signal ce : std_logic := '0';
  signal bpm_reading : std_logic_vector(c_input_width-1 downto 0) := (others => '0');
  signal bpm_reading_valid : std_logic := '0';
  signal tag : std_logic_vector(c_tag_width-1 downto 0);
  signal i, q : std_logic_vector(c_output_width-1 downto 0);
  signal mixer_valid : std_logic := '0';
  signal i_checked, q_checked : boolean := false;

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
  component mixer is
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
  end component mixer;

begin

  f_gen_clk(clk_freq, clk);

  -- process to drive mixer
  drive_mixer : process
    file fin : text;
    variable lin : line;
    variable v_bpm_reading : integer;
  begin
    -- resetting cores
    rst <= '1';
    f_wait_cycles(clk, 10);

    rst <= '0';
    f_wait_cycles(clk, 1);

    file_open(fin, "../bpm_readings.dat", read_mode);
    while not endfile(fin)
    loop
      readline(fin, lin);
      read(lin, v_bpm_reading);

      -- driving bpm readings
      bpm_reading <= std_logic_vector(to_signed(v_bpm_reading, c_input_width));
      bpm_reading_valid <= '1';
      tag <= (others => '1');
      ce <= '1';

      f_wait_cycles(clk, 1);
    end loop;

    bpm_reading_valid <= '0';
    tag <= (others => '0');
    f_wait_cycles(clk, 1);

    wait;
  end process drive_mixer;

  -- process to check mixer output i
  check_i : process
    file fin : text;
    variable lin : line;
    variable expec_i : std_logic_vector(c_output_width-1 downto 0);
  begin
    file_open(fin, "../i.dat", read_mode);

    loop
      f_wait_clocked_signal(ce, clk, '1');

      if mixer_valid = '1' then
        if not endfile(fin) then
          readline(fin, lin);
          hread(lin, expec_i);
        else
          report "file ended prematurely"
          severity error;
        end if;

        -- check against expected values
        if i /= expec_i then
          report
            "wrong i: " & to_hstring(i) & " (expected " & to_hstring(expec_i) &
            ")"
          severity error;
        end if;
      end if;

      f_wait_cycles(clk, 1);

      if endfile(fin) then
        i_checked <= true;
        exit;
      end if;
    end loop;

    wait;
  end process check_i;

  -- process to check mixer output q
  check_q : process
    file fin : text;
    variable lin : line;
    variable expec_q : std_logic_vector(c_output_width-1 downto 0);
  begin
    file_open(fin, "../q.dat", read_mode);

    loop
      f_wait_clocked_signal(ce, clk, '1');

      if mixer_valid = '1' then
        if not endfile(fin) then
          readline(fin, lin);
          hread(lin, expec_q);
        else
          report "file ended prematurely"
          severity error;
        end if;

        -- check against expected values
        if q /= expec_q then
          report
            "wrong q: " & to_hstring(q) & " (expected " & to_hstring(expec_q) &
            ")"
          severity error;
        end if;
      end if;

      f_wait_cycles(clk, 1);

      if endfile(fin) then
        q_checked <= true;
        exit;
      end if;
    end loop;

    wait;
  end process check_q;

  process
  begin
    if rising_edge(clk) then
      if i_checked and q_checked = true then
        report "everything ok"
        severity note;
        finish;
      end if;
    end if;

    f_wait_cycles(clk, 1);
  end process;

  -- components instantiation
  uut : mixer
    generic map (
      g_number_of_points  => c_number_of_points,
      g_dds_width         => c_dds_width,
      g_input_width       => c_input_width,
      g_output_width      => c_output_width,
      g_tag_width         => c_tag_width,
      g_mult_levels       => c_mult_levels
    )
    port map (
      rst_i               => rst,
      clk_i               => clk,
      ce_i                => ce,
      signal_i            => bpm_reading,
      valid_i             => bpm_reading_valid,
      tag_i               => tag,
      i_o                 => i,
      q_o                 => q,
      valid_o             => mixer_valid,
      i_tag_o             => open,
      q_tag_o             => open
    );

end testbench;
