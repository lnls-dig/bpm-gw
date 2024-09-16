-------------------------------------------------------------------------------
-- Title      : Wishbone Orbit Interlock Detector Testbench
-- Project    : BPM gateware
-------------------------------------------------------------------------------
-- File       : xwb_orbit_intlk_tb.vhd
-- Author     : Augusto Fraga Giachero  <augusto.fraga@lnls.br>
-- Company    : CNPEM
-- Created    : 2024-09-16
-- Last update: 2024-09-26
-- Platform   : Simulation
-- Standard   : VHDL 2008
-------------------------------------------------------------------------------
-- Description:
-------------------------------------------------------------------------------
-- Copyright (c) 2024 CNPEM
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2024-09-16  1.0      augusto.fraga   Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
-- Main Wishbone Definitions
use work.wishbone_pkg.all;
-- Orbit interlock cores
use work.orbit_intlk_pkg.all;
-- BPM cores
use work.bpm_cores_pkg.all;
-- Wishbone simulation procedures
use work.sim_wishbone.all;
-- wb_orbit_intlk register addresses and bitfield
use work.wb_orbit_intlk_regs_const_pkg.all;

entity xwb_orbit_intlk_tb is
end entity xwb_orbit_intlk_tb;

architecture sim of xwb_orbit_intlk_tb is
  constant c_INTERFACE_MODE      : t_wishbone_interface_mode      := CLASSIC;
  constant c_ADDRESS_GRANULARITY : t_wishbone_address_granularity := BYTE;
  constant c_WITH_EXTRA_WB_REG   : boolean                        := false;
  constant c_ADC_WIDTH           : natural                        := 16;
  constant c_DECIM_WIDTH         : natural                        := 32;
  constant c_INTLK_LMT_WIDTH     : natural                        := 32;

  type t_bpm_pos is record
    x    : std_logic_vector(c_DECIM_WIDTH-1 downto 0);
    y    : std_logic_vector(c_DECIM_WIDTH-1 downto 0);
    q    : std_logic_vector(c_DECIM_WIDTH-1 downto 0);
    sum  : std_logic_vector(c_DECIM_WIDTH-1 downto 0);
  end record;

  type t_test_stimulus is record
    id: integer;
    intlk_en: std_logic;
    intlk_min_sum_en: std_logic;
    intlk_min_sum: std_logic_vector(31 downto 0);
    intlk_trans_en: std_logic;
    intlk_trans_max_x: std_logic_vector(31 downto 0);
    intlk_trans_max_y: std_logic_vector(31 downto 0);
    intlk_trans_min_x: std_logic_vector(31 downto 0);
    intlk_trans_min_y: std_logic_vector(31 downto 0);
    intlk_ang_en: std_logic;
    intlk_ang_max_x: std_logic_vector(31 downto 0);
    intlk_ang_max_y: std_logic_vector(31 downto 0);
    intlk_ang_min_x: std_logic_vector(31 downto 0);
    intlk_ang_min_y: std_logic_vector(31 downto 0);
    decim_ds_pos: t_bpm_pos;
    decim_us_pos: t_bpm_pos;
    intlk_status: std_logic;
  end record;

  type t_test_stimulus_arr is array (natural range <>) of t_test_stimulus;

  procedure f_wait_cycles(signal   clk    : in std_logic;
                          constant cycles : natural) is
  begin
    for i in 1 to cycles loop
      wait until rising_edge(clk);
    end loop;
  end procedure f_wait_cycles;

  procedure wb_intlk_transaction (
    signal clk               : in std_logic;
    signal wb_mst_o          : out t_wishbone_master_out;
    signal wb_mst_i          : in t_wishbone_master_in;
    test_stimulus            : in t_test_stimulus;
    signal intlk_ltc         : in std_logic;
    signal decim_ds_pos      : out t_bpm_pos;
    signal decim_ds_pos_valid: out std_logic;
    signal decim_us_pos      : out t_bpm_pos;
    signal decim_us_pos_valid: out std_logic
    ) is
    variable wb_reg : std_logic_vector(31 downto 0);
  begin
    report LF & "#####################" & LF &
      "###### TEST #" & to_string(test_stimulus.id) & " ######" & LF &
      "#####################" & LF &
      "## Interlock enable = " & to_string(test_stimulus.intlk_en) & LF &
      "## Interlock minimum sum enable = " & to_string(test_stimulus.intlk_min_sum_en) & LF &
      "## Interlock minimum sum threshold = " & to_string(to_integer(signed(test_stimulus.intlk_min_sum))) & LF &
      "## Interlock translation enable = " & to_string(test_stimulus.intlk_trans_en) & LF &
      "## Interlock translation MAX X = " & to_string(to_integer(signed(test_stimulus.intlk_trans_max_x))) & LF &
      "## Interlock translation MAX Y = " & to_string(to_integer(signed(test_stimulus.intlk_trans_max_y))) & LF &
      "## Interlock translation MIN X = " & to_string(to_integer(signed(test_stimulus.intlk_trans_min_x))) & LF &
      "## Interlock translation MIN Y = " & to_string(to_integer(signed(test_stimulus.intlk_trans_min_y))) & LF &
      "## Interlock angular enable = " & to_string(test_stimulus.intlk_ang_en) & LF &
      "## Interlock angular MAX X = " & to_string(to_integer(signed(test_stimulus.intlk_ang_max_x))) & LF &
      "## Interlock angular MAX Y = " & to_string(to_integer(signed(test_stimulus.intlk_ang_max_y))) & LF &
      "## Interlock angular MIN X = " & to_string(to_integer(signed(test_stimulus.intlk_ang_min_x))) & LF &
      "## Interlock angular MIN Y = " & to_string(to_integer(signed(test_stimulus.intlk_ang_min_y))) & LF &

      "Setting interlock parameters scenario";

    -- Set minimum sum threshold
    write32(clk, wb_mst_o, wb_mst_i, ADDR_ORBIT_INTLK_MIN_SUM, test_stimulus.intlk_min_sum);

    -- Set minimum sum enable
    read32(clk, wb_mst_o, wb_mst_i, ADDR_ORBIT_INTLK_CTRL, wb_reg);
    wb_reg(ORBIT_INTLK_CTRL_MIN_SUM_EN_OFFSET) := test_stimulus.intlk_min_sum_en;
    write32(clk, wb_mst_o, wb_mst_i, ADDR_ORBIT_INTLK_CTRL, wb_reg);

    -- Set translation threshold X/Y max
    write32(clk, wb_mst_o, wb_mst_i, ADDR_ORBIT_INTLK_TRANS_MAX_X, test_stimulus.intlk_trans_max_x);
    write32(clk, wb_mst_o, wb_mst_i, ADDR_ORBIT_INTLK_TRANS_MAX_Y, test_stimulus.intlk_trans_max_y);

    -- Set translation threshold X/Y min
    write32(clk, wb_mst_o, wb_mst_i, ADDR_ORBIT_INTLK_TRANS_MIN_X, test_stimulus.intlk_trans_min_x);
    write32(clk, wb_mst_o, wb_mst_i, ADDR_ORBIT_INTLK_TRANS_MIN_Y, test_stimulus.intlk_trans_min_y);

    -- Set translation enable
    read32(clk, wb_mst_o, wb_mst_i, ADDR_ORBIT_INTLK_CTRL, wb_reg);
    wb_reg(ORBIT_INTLK_CTRL_TRANS_EN_OFFSET) := test_stimulus.intlk_trans_en;
    write32(clk, wb_mst_o, wb_mst_i, ADDR_ORBIT_INTLK_CTRL, wb_reg);

    -- Set angular threshold X/Y max
    write32(clk, wb_mst_o, wb_mst_i, ADDR_ORBIT_INTLK_ANG_MAX_X, test_stimulus.intlk_ang_max_x);
    write32(clk, wb_mst_o, wb_mst_i, ADDR_ORBIT_INTLK_ANG_MAX_Y, test_stimulus.intlk_ang_max_y);

    -- Set angular threshold X/Y min
    write32(clk, wb_mst_o, wb_mst_i, ADDR_ORBIT_INTLK_ANG_MIN_X, test_stimulus.intlk_ang_max_y);
    write32(clk, wb_mst_o, wb_mst_i, ADDR_ORBIT_INTLK_ANG_MIN_Y, test_stimulus.intlk_ang_max_y);

    -- Set angular enable
    read32(clk, wb_mst_o, wb_mst_i, ADDR_ORBIT_INTLK_CTRL, wb_reg);
    wb_reg(ORBIT_INTLK_CTRL_ANG_EN_OFFSET) := test_stimulus.intlk_ang_en;
    write32(clk, wb_mst_o, wb_mst_i, ADDR_ORBIT_INTLK_CTRL, wb_reg);

    -- Set interlock enable
    read32(clk, wb_mst_o, wb_mst_i, ADDR_ORBIT_INTLK_CTRL, wb_reg);
    wb_reg(ORBIT_INTLK_CTRL_EN_OFFSET) := test_stimulus.intlk_en;
    write32(clk, wb_mst_o, wb_mst_i, ADDR_ORBIT_INTLK_CTRL, wb_reg);

    f_wait_cycles(clk, 1);

    -- Set DECIM downstream/upstream positions
    decim_ds_pos       <= test_stimulus.decim_ds_pos;
    decim_ds_pos_valid <= '1';

    decim_us_pos       <= test_stimulus.decim_us_pos;
    decim_us_pos_valid <= '1';

    f_wait_cycles(clk, 1);

    -- Set positions back to zero
    decim_ds_pos.x     <= (others => '0');
    decim_ds_pos.y     <= (others => '0');
    decim_ds_pos.q     <= (others => '0');
    decim_ds_pos.sum   <= (others => '0');
    decim_ds_pos_valid <= '0';

    decim_us_pos.x     <= (others => '0');
    decim_us_pos.y     <= (others => '0');
    decim_us_pos.q     <= (others => '0');
    decim_us_pos.sum   <= (others => '0');
    decim_us_pos_valid <= '0';

    -- Wait for 3 clock cycles
    f_wait_cycles(clk, 3);

    -- Clear interlock flags
    read32(clk, wb_mst_o, wb_mst_i, ADDR_ORBIT_INTLK_CTRL, wb_reg);
    wb_reg(ORBIT_INTLK_CTRL_TRANS_CLR_OFFSET) := '1';
    wb_reg(ORBIT_INTLK_CTRL_ANG_CLR_OFFSET) := '1';
    wb_reg(ORBIT_INTLK_CTRL_CLR_OFFSET) := '1';
    write32(clk, wb_mst_o, wb_mst_i, ADDR_ORBIT_INTLK_CTRL, wb_reg);

    -- Wait for 20 clock cycles
    f_wait_cycles(clk, 20);

    if test_stimulus.intlk_status = '1' then
      assert test_stimulus.intlk_status = intlk_ltc
        report "Test " & to_string(test_stimulus.id) &
        ": False interlock condition detected!"
        severity failure;
    elsif test_stimulus.intlk_status = '0' then
      assert test_stimulus.intlk_status = intlk_ltc
        report "Test " & to_string(test_stimulus.id) &
        ": Interlock expected but not detected!"
        severity failure;
    end if;

    -- Read status bits
    read32(clk, wb_mst_o, wb_mst_i, ADDR_ORBIT_INTLK_STS, wb_reg);
    assert test_stimulus.intlk_status = wb_reg(ORBIT_INTLK_STS_INTLK_LTC_OFFSET)
      report "Test " & to_string(test_stimulus.id) &
      ": Wishbone register DID NOT correctly identify a condition."
      severity failure;

    -- Wait for some time between tests
    f_wait_cycles(clk, 1);
  end procedure;


  -- component ports
  signal rst_n                     : std_logic := '0';
  signal ref_rst_n                 : std_logic := '0';
  signal wb_slv_i                  : t_wishbone_slave_in;
  signal wb_slv_o                  : t_wishbone_slave_out;
  signal adc_ds_ch0_swap           : std_logic_vector(c_ADC_WIDTH-1 downto 0) := (others => '0');
  signal adc_ds_ch1_swap           : std_logic_vector(c_ADC_WIDTH-1 downto 0) := (others => '0');
  signal adc_ds_ch2_swap           : std_logic_vector(c_ADC_WIDTH-1 downto 0) := (others => '0');
  signal adc_ds_ch3_swap           : std_logic_vector(c_ADC_WIDTH-1 downto 0) := (others => '0');
  signal adc_ds_tag                : std_logic_vector(0 downto 0)             := (others => '0');
  signal adc_ds_swap_valid         : std_logic                                := '0';
  signal decim_ds_pos              : t_bpm_pos;
  signal decim_ds_pos_valid        : std_logic;
  signal adc_us_ch0_swap           : std_logic_vector(c_ADC_WIDTH-1 downto 0) := (others => '0');
  signal adc_us_ch1_swap           : std_logic_vector(c_ADC_WIDTH-1 downto 0) := (others => '0');
  signal adc_us_ch2_swap           : std_logic_vector(c_ADC_WIDTH-1 downto 0) := (others => '0');
  signal adc_us_ch3_swap           : std_logic_vector(c_ADC_WIDTH-1 downto 0) := (others => '0');
  signal adc_us_tag                : std_logic_vector(0 downto 0)             := (others => '0');
  signal adc_us_swap_valid         : std_logic                                := '0';
  signal decim_us_pos              : t_bpm_pos;
  signal decim_us_pos_valid        : std_logic;
  signal intlk_trans_bigger_x      : std_logic;
  signal intlk_trans_bigger_y      : std_logic;
  signal intlk_trans_bigger_ltc_x  : std_logic;
  signal intlk_trans_bigger_ltc_y  : std_logic;
  signal intlk_trans_bigger_any    : std_logic;
  signal intlk_trans_bigger_ltc    : std_logic;
  signal intlk_trans_bigger        : std_logic;
  signal intlk_trans_smaller_x     : std_logic;
  signal intlk_trans_smaller_y     : std_logic;
  signal intlk_trans_smaller_ltc_x : std_logic;
  signal intlk_trans_smaller_ltc_y : std_logic;
  signal intlk_trans_smaller_any   : std_logic;
  signal intlk_trans_smaller_ltc   : std_logic;
  signal intlk_trans_smaller       : std_logic;
  signal intlk_ang_bigger_x        : std_logic;
  signal intlk_ang_bigger_y        : std_logic;
  signal intlk_ang_bigger_ltc_x    : std_logic;
  signal intlk_ang_bigger_ltc_y    : std_logic;
  signal intlk_ang_bigger_any      : std_logic;
  signal intlk_ang_bigger_ltc      : std_logic;
  signal intlk_ang_bigger          : std_logic;
  signal intlk_ang_smaller_x       : std_logic;
  signal intlk_ang_smaller_y       : std_logic;
  signal intlk_ang_smaller_ltc_x   : std_logic;
  signal intlk_ang_smaller_ltc_y   : std_logic;
  signal intlk_ang_smaller_any     : std_logic;
  signal intlk_ang_smaller_ltc     : std_logic;
  signal intlk_ang_smaller         : std_logic;
  signal intlk_ltc                 : std_logic;
  signal intlk                     : std_logic;

  -- Aux signal
  signal intlk_en         : std_logic;
  signal intlk_clr        : std_logic;

  signal intlk_min_sum_en : std_logic;
  signal intlk_min_sum    : std_logic_vector(31 downto 0);

  signal intlk_trans_en   : std_logic;
  signal intlk_trans_clr  : std_logic;
  signal intlk_trans_max_x: std_logic_vector(31 downto 0);
  signal intlk_trans_max_y: std_logic_vector(31 downto 0);

  signal intlk_ang_en     : std_logic;
  signal intlk_ang_clr    : std_logic;
  signal intlk_ang_max_x  : std_logic_vector(31 downto 0);
  signal intlk_ang_max_y  : std_logic_vector(31 downto 0);

  -- clock

  signal clk : std_logic := '0';

begin  -- architecture sim

  -- component instantiation
  DUT: entity work.xwb_orbit_intlk
    generic map (
      g_INTERFACE_MODE      => c_INTERFACE_MODE,
      g_ADDRESS_GRANULARITY => c_ADDRESS_GRANULARITY,
      g_WITH_EXTRA_WB_REG   => c_WITH_EXTRA_WB_REG,
      g_ADC_WIDTH           => c_ADC_WIDTH,
      g_DECIM_WIDTH         => c_DECIM_WIDTH
    )
    port map (
      rst_n_i                     => rst_n,
      clk_i                       => clk,
      ref_rst_n_i                 => ref_rst_n,
      ref_clk_i                   => clk,
      wb_slv_i                    => wb_slv_i,
      wb_slv_o                    => wb_slv_o,
      fs_clk_ds_i                 => clk,
      adc_ds_ch0_swap_i           => adc_ds_ch0_swap,
      adc_ds_ch1_swap_i           => adc_ds_ch1_swap,
      adc_ds_ch2_swap_i           => adc_ds_ch2_swap,
      adc_ds_ch3_swap_i           => adc_ds_ch3_swap,
      adc_ds_tag_i                => adc_ds_tag,
      adc_ds_swap_valid_i         => adc_ds_swap_valid,
      decim_ds_pos_x_i            => decim_ds_pos.x,
      decim_ds_pos_y_i            => decim_ds_pos.y,
      decim_ds_pos_q_i            => decim_ds_pos.q,
      decim_ds_pos_sum_i          => decim_ds_pos.sum,
      decim_ds_pos_valid_i        => decim_ds_pos_valid,
      fs_clk_us_i                 => clk,
      adc_us_ch0_swap_i           => adc_us_ch0_swap,
      adc_us_ch1_swap_i           => adc_us_ch1_swap,
      adc_us_ch2_swap_i           => adc_us_ch2_swap,
      adc_us_ch3_swap_i           => adc_us_ch3_swap,
      adc_us_tag_i                => adc_us_tag,
      adc_us_swap_valid_i         => adc_us_swap_valid,
      decim_us_pos_x_i            => decim_us_pos.x,
      decim_us_pos_y_i            => decim_us_pos.y,
      decim_us_pos_q_i            => decim_us_pos.q,
      decim_us_pos_sum_i          => decim_us_pos.sum,
      decim_us_pos_valid_i        => decim_us_pos_valid,
      intlk_trans_bigger_x_o      => intlk_trans_bigger_x,
      intlk_trans_bigger_y_o      => intlk_trans_bigger_y,
      intlk_trans_bigger_ltc_x_o  => intlk_trans_bigger_ltc_x,
      intlk_trans_bigger_ltc_y_o  => intlk_trans_bigger_ltc_y,
      intlk_trans_bigger_any_o    => intlk_trans_bigger_any,
      intlk_trans_bigger_ltc_o    => intlk_trans_bigger_ltc,
      intlk_trans_bigger_o        => intlk_trans_bigger,
      intlk_trans_smaller_x_o     => intlk_trans_smaller_x,
      intlk_trans_smaller_y_o     => intlk_trans_smaller_y,
      intlk_trans_smaller_ltc_x_o => intlk_trans_smaller_ltc_x,
      intlk_trans_smaller_ltc_y_o => intlk_trans_smaller_ltc_y,
      intlk_trans_smaller_any_o   => intlk_trans_smaller_any,
      intlk_trans_smaller_ltc_o   => intlk_trans_smaller_ltc,
      intlk_trans_smaller_o       => intlk_trans_smaller,
      intlk_ang_bigger_x_o        => intlk_ang_bigger_x,
      intlk_ang_bigger_y_o        => intlk_ang_bigger_y,
      intlk_ang_bigger_ltc_x_o    => intlk_ang_bigger_ltc_x,
      intlk_ang_bigger_ltc_y_o    => intlk_ang_bigger_ltc_y,
      intlk_ang_bigger_any_o      => intlk_ang_bigger_any,
      intlk_ang_bigger_ltc_o      => intlk_ang_bigger_ltc,
      intlk_ang_bigger_o          => intlk_ang_bigger,
      intlk_ang_smaller_x_o       => intlk_ang_smaller_x,
      intlk_ang_smaller_y_o       => intlk_ang_smaller_y,
      intlk_ang_smaller_ltc_x_o   => intlk_ang_smaller_ltc_x,
      intlk_ang_smaller_ltc_y_o   => intlk_ang_smaller_ltc_y,
      intlk_ang_smaller_any_o     => intlk_ang_smaller_any,
      intlk_ang_smaller_ltc_o     => intlk_ang_smaller_ltc,
      intlk_ang_smaller_o         => intlk_ang_smaller,
      intlk_ltc_o                 => intlk_ltc,
      intlk_o                     => intlk
    );

  -- clock generation
  clk <= not clk after 10 ns;

  process
    constant test_stimulus: t_test_stimulus_arr(1 to 7) := (
      -- TEST #1: Translation interlock (smaller than threshold X)
      1 => (
        id => 1,
        intlk_en => '1',
        intlk_min_sum_en => '0',
        intlk_min_sum => x"00000000",
        intlk_trans_en => '1',
        intlk_trans_max_x => x"00100000",
        intlk_trans_max_y => x"00100000",
        intlk_trans_min_x => x"00000000",
        intlk_trans_min_y => x"00000000",
        intlk_ang_en => '0',
        intlk_ang_max_x => x"00155CC0",
        intlk_ang_max_y => x"00155CC0",
        intlk_ang_min_x => x"00000000",
        intlk_ang_min_y => x"00000000",
        decim_ds_pos => (
          x => x"00000100",
          y => x"00010000",
          q => x"00000000",
          sum => x"00000000"
        ),
        decim_us_pos => (
          x => x"00000100",
          y => x"00010000",
          q => x"00000000",
          sum => x"00000000"
        ),
        intlk_status => '0'
      ),

      -- TEST #2: Translation interlock (bigger than threshold X)
      2 => (
        id => 2,
        intlk_en => '1',
        intlk_min_sum_en => '0',
        intlk_min_sum => x"00000000",
        intlk_trans_en => '1',
        intlk_trans_max_x => x"00100000",
        intlk_trans_max_y => x"00100000",
        intlk_trans_min_x => x"00000000",
        intlk_trans_min_y => x"00000000",
        intlk_ang_en => '0',
        intlk_ang_max_x => x"00155CC0",
        intlk_ang_max_y => x"00155CC0",
        intlk_ang_min_x => x"00000000",
        intlk_ang_min_y => x"00000000",
        decim_ds_pos => (
          x => x"01000000",
          y => x"00010000",
          q => x"00000000",
          sum => x"00000000"
        ),
        decim_us_pos => (
          x => x"01000000",
          y => x"00010000",
          q => x"00000000",
          sum => x"00000000"
        ),
        intlk_status => '1'
      ),

      -- TEST #3: Translation interlock (equal to threshold X)
      3 => (
        id => 3,
        intlk_en => '1',
        intlk_min_sum_en => '0',
        intlk_min_sum => x"00000000",
        intlk_trans_en => '1',
        intlk_trans_max_x => x"00100000",
        intlk_trans_max_y => x"00100000",
        intlk_trans_min_x => x"00000000",
        intlk_trans_min_y => x"00000000",
        intlk_ang_en => '0',
        intlk_ang_max_x => x"00155CC0",
        intlk_ang_max_y => x"00155CC0",
        intlk_ang_min_x => x"00000000",
        intlk_ang_min_y => x"00000000",
        decim_ds_pos => (
          x => x"00200000",
          y => x"00010000",
          q => x"00000000",
          sum => x"00000000"
        ),
        decim_us_pos => (
          x => x"00080000",
          y => x"00010000",
          q => x"00000000",
          sum => x"00000000"
        ),
        intlk_status => '1'
      ),

      -- TEST #4: No translation interlock (X/Y within limits)
      4 => (
        id => 4,
        intlk_en => '1',
        intlk_min_sum_en => '0',
        intlk_min_sum => x"00000000",
        intlk_trans_en => '1',
        intlk_trans_max_x => x"00100000",
        intlk_trans_max_y => x"00100000",
        intlk_trans_min_x => x"00000000",
        intlk_trans_min_y => x"00000000",
        intlk_ang_en => '0',
        intlk_ang_max_x => x"00155CC0",
        intlk_ang_max_y => x"00155CC0",
        intlk_ang_min_x => x"00000000",
        intlk_ang_min_y => x"00000000",
        decim_ds_pos => (
          x => x"00020000",
          y => x"00030000",
          q => x"00000000",
          sum => x"00000000"
        ),
        decim_us_pos => (
          x => x"00040000",
          y => x"00080000",
          q => x"00000000",
          sum => x"00000000"
        ),
        intlk_status => '0'
      ),

      -- TEST #5: Minimum sum interlock (X/Y outside limits, but sum too small)
      5 => (
        id => 5,
        intlk_en => '1',
        intlk_min_sum_en => '1',
        intlk_min_sum => x"00001000",
        intlk_trans_en => '1',
        intlk_trans_max_x => x"00100000",
        intlk_trans_max_y => x"00100000",
        intlk_trans_min_x => x"00000000",
        intlk_trans_min_y => x"00000000",
        intlk_ang_en => '0',
        intlk_ang_max_x => x"00155CC0",
        intlk_ang_max_y => x"00155CC0",
        intlk_ang_min_x => x"00000000",
        intlk_ang_min_y => x"00000000",
        decim_ds_pos => (
          x => x"01000000",
          y => x"01000000",
          q => x"00000000",
          sum => x"00000100"
        ),
        decim_us_pos => (
          x => x"01000000",
          y => x"01000000",
          q => x"00000000",
          sum => x"00000500"
        ),
        intlk_status => '0'
      ),

      -- TEST #6: Negative position (X/Y within limits)
      6 => (
        id => 6,
        intlk_en => '1',
        intlk_min_sum_en => '1',
        intlk_min_sum => x"00001000",
        intlk_trans_en => '1',
        intlk_trans_max_x => x"00100000",
        intlk_trans_max_y => x"00100000",
        intlk_trans_min_x => x"00000000",
        intlk_trans_min_y => x"00000000",
        intlk_ang_en => '0',
        intlk_ang_max_x => x"00155CC0",
        intlk_ang_max_y => x"00155CC0",
        intlk_ang_min_x => x"00000000",
        intlk_ang_min_y => x"00000000",
        decim_ds_pos => (
          x => x"00100000",
          y => x"00100000",
          q => x"00000000",
          sum => x"00010000"
        ),
        decim_us_pos => (
          x => x"FFFFF000",
          y => x"FFFFF000",
          q => x"00000000",
          sum => x"00010000"
        ),
        intlk_status => '0'
      ),

      -- TEST #7: Negative position (X/Y within limits)
      7 => (
        id => 7,
        intlk_en => '1',
        intlk_min_sum_en => '1',
        intlk_min_sum => x"00001000",
        intlk_trans_en => '1',
        intlk_trans_max_x => x"00000000",
        intlk_trans_max_y => x"00000000",
        intlk_trans_min_x => x"FFFFE000",
        intlk_trans_min_y => x"FFFFE000",
        intlk_ang_en => '0',
        intlk_ang_max_x => x"00155CC0",
        intlk_ang_max_y => x"00155CC0",
        intlk_ang_min_x => x"00000000",
        intlk_ang_min_y => x"00000000",
        decim_ds_pos => (
          x => x"FFFFF000",
          y => x"FFFFF000",
          q => x"00000000",
          sum => x"00010000"
        ),
        decim_us_pos => (
          x => x"FFFFF000",
          y => x"FFFFF000",
          q => x"00000000",
          sum => x"00010000"
        ),
        intlk_status => '0'
      )
    );

  begin
    init(wb_slv_i);
    intlk_en         <= '1';
    intlk_clr        <= '0';

    intlk_min_sum_en <= '0';
    intlk_min_sum    <= (others => '0');

    intlk_trans_en   <= '1';
    intlk_trans_clr  <= '0';

    -- 1mm = 1000000 nm = F4240h
    intlk_trans_max_x <= x"00100000";
    intlk_trans_max_y <= x"00100000";

    intlk_ang_en   <= '1';
    intlk_ang_clr  <= '0';

    -- 200 urad * 7m (distance between BPMs) = 1_400_000 nm = 155CC0h
    intlk_ang_max_x <= x"00155CC0";
    intlk_ang_max_y <= x"00155CC0";

    adc_ds_ch0_swap    <= (others => '0');
    adc_ds_ch1_swap    <= (others => '0');
    adc_ds_ch2_swap    <= (others => '0');
    adc_ds_ch3_swap    <= (others => '0');
    adc_ds_tag         <= "0";
    adc_ds_swap_valid  <= '0';

    decim_ds_pos.x     <= (others => '0');
    decim_ds_pos.y     <= (others => '0');
    decim_ds_pos.q     <= (others => '0');
    decim_ds_pos.sum   <= (others => '0');
    decim_ds_pos_valid <= '0';

    adc_us_ch0_swap    <= (others => '0');
    adc_us_ch1_swap    <= (others => '0');
    adc_us_ch2_swap    <= (others => '0');
    adc_us_ch3_swap    <= (others => '0');
    adc_us_tag         <= "0";
    adc_us_swap_valid  <= '0';

    decim_us_pos.x     <= (others => '0');
    decim_us_pos.y     <= (others => '0');
    decim_us_pos.q     <= (others => '0');
    decim_us_pos.sum   <= (others => '0');
    decim_us_pos_valid <= '0';

    -- Wait for 10 clock cycles to fully reset
    f_wait_cycles(clk, 10);

    ref_rst_n <= '1';
    rst_n <= '1';
    f_wait_cycles(clk, 5);

    -- Execute all tests
    for i in 1 to 7 loop
      wb_intlk_transaction(
        clk,
        wb_slv_i,
        wb_slv_o,
        test_stimulus(i),
        intlk_ltc,
        decim_ds_pos,
        decim_ds_pos_valid,
        decim_us_pos,
        decim_us_pos_valid
      );
    end loop;

    std.env.finish;
  end process;

end architecture sim;
