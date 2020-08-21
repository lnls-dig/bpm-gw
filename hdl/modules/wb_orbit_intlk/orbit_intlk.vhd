------------------------------------------------------------------------------
-- Title      : BPM orbit interlock
------------------------------------------------------------------------------
-- Author     : Lucas Maziero Russo
-- Company    : CNPEM LNLS-DIG
-- Created    : 2022-06-12
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: Module for orbit interlock
-------------------------------------------------------------------------------
-- Copyright (c) 2020 CNPEM
-- Licensed under GNU Lesser General Public License (LGPL) v3.0
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2020-06-02  1.0      lucas.russo        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
-- General cores
use work.gencores_pkg.all;
-- Orbit interlock cores
use work.orbit_intlk_pkg.all;

entity orbit_intlk is
generic
(
  g_ADC_WIDTH                                : natural := 16;
  g_DECIM_WIDTH                              : natural := 32;
  -- interlock limits
  g_INTLK_LMT_WIDTH                          : natural := 32
);
port
(
  -----------------------------
  -- Clocks and resets
  -----------------------------

  ref_rst_n_i                                : in std_logic;
  ref_clk_i                                  : in std_logic;

  -----------------------------
  -- Interlock enable and limits signals
  -----------------------------

  intlk_en_i                                 : in std_logic;
  intlk_clr_i                                : in std_logic;
  -- Minimum threshold interlock on/off
  intlk_min_sum_en_i                         : in std_logic;
  -- Minimum threshold to interlock
  intlk_min_sum_i                            : in std_logic_vector(g_INTLK_LMT_WIDTH-1 downto 0);
  -- Translation interlock on/off
  intlk_trans_en_i                           : in std_logic;
  -- Translation interlock clear
  intlk_trans_clr_i                          : in std_logic;
  intlk_trans_max_x_i                        : in std_logic_vector(g_INTLK_LMT_WIDTH-1 downto 0);
  intlk_trans_max_y_i                        : in std_logic_vector(g_INTLK_LMT_WIDTH-1 downto 0);
  -- Angular interlock on/off
  intlk_ang_en_i                             : in std_logic;
  -- Angular interlock clear
  intlk_ang_clr_i                            : in std_logic;
  intlk_ang_max_x_i                          : in std_logic_vector(g_INTLK_LMT_WIDTH-1 downto 0);
  intlk_ang_max_y_i                          : in std_logic_vector(g_INTLK_LMT_WIDTH-1 downto 0);

  -----------------------------
  -- Downstream ADC and position signals
  -----------------------------

  fs_clk_ds_i                                : in std_logic;

  adc_ds_ch0_swap_i                          : in std_logic_vector(g_ADC_WIDTH-1 downto 0) := (others => '0');
  adc_ds_ch1_swap_i                          : in std_logic_vector(g_ADC_WIDTH-1 downto 0) := (others => '0');
  adc_ds_ch2_swap_i                          : in std_logic_vector(g_ADC_WIDTH-1 downto 0) := (others => '0');
  adc_ds_ch3_swap_i                          : in std_logic_vector(g_ADC_WIDTH-1 downto 0) := (others => '0');
  adc_ds_tag_i                               : in std_logic_vector(0 downto 0) := (others => '0');
  adc_ds_swap_valid_i                        : in std_logic := '0';

  decim_ds_pos_x_i                           : in std_logic_vector(g_DECIM_WIDTH-1 downto 0);
  decim_ds_pos_y_i                           : in std_logic_vector(g_DECIM_WIDTH-1 downto 0);
  decim_ds_pos_q_i                           : in std_logic_vector(g_DECIM_WIDTH-1 downto 0);
  decim_ds_pos_sum_i                         : in std_logic_vector(g_DECIM_WIDTH-1 downto 0);
  decim_ds_pos_valid_i                       : in std_logic;

  -----------------------------
  -- Upstream ADC and position signals
  -----------------------------

  fs_clk_us_i                                : in std_logic;

  adc_us_ch0_swap_i                          : in std_logic_vector(g_ADC_WIDTH-1 downto 0) := (others => '0');
  adc_us_ch1_swap_i                          : in std_logic_vector(g_ADC_WIDTH-1 downto 0) := (others => '0');
  adc_us_ch2_swap_i                          : in std_logic_vector(g_ADC_WIDTH-1 downto 0) := (others => '0');
  adc_us_ch3_swap_i                          : in std_logic_vector(g_ADC_WIDTH-1 downto 0) := (others => '0');
  adc_us_tag_i                               : in std_logic_vector(0 downto 0) := (others => '0');
  adc_us_swap_valid_i                        : in std_logic := '0';

  decim_us_pos_x_i                           : in std_logic_vector(g_DECIM_WIDTH-1 downto 0);
  decim_us_pos_y_i                           : in std_logic_vector(g_DECIM_WIDTH-1 downto 0);
  decim_us_pos_q_i                           : in std_logic_vector(g_DECIM_WIDTH-1 downto 0);
  decim_us_pos_sum_i                         : in std_logic_vector(g_DECIM_WIDTH-1 downto 0);
  decim_us_pos_valid_i                       : in std_logic;

  -----------------------------
  -- Interlock outputs
  -----------------------------
  intlk_trans_bigger_x_o                     : out std_logic;
  intlk_trans_bigger_y_o                     : out std_logic;

  intlk_trans_bigger_ltc_x_o                 : out std_logic;
  intlk_trans_bigger_ltc_y_o                 : out std_logic;

  intlk_trans_bigger_o                       : out std_logic;

  -- only cleared when intlk_trans_clr_i is asserted
  intlk_trans_ltc_o                          : out std_logic;
  -- conditional to intlk_trans_en_i
  intlk_trans_o                              : out std_logic;

  intlk_ang_bigger_x_o                       : out std_logic;
  intlk_ang_bigger_y_o                       : out std_logic;

  intlk_ang_bigger_ltc_x_o                   : out std_logic;
  intlk_ang_bigger_ltc_y_o                   : out std_logic;

  intlk_ang_bigger_o                         : out std_logic;

  -- only cleared when intlk_ang_clr_i is asserted
  intlk_ang_ltc_o                            : out std_logic;
  -- conditional to intlk_ang_en_i
  intlk_ang_o                                : out std_logic;

  -- only cleared when intlk_clr_i is asserted
  intlk_ltc_o                                : out std_logic;
  -- conditional to intlk_en_i
  intlk_o                                    : out std_logic
);
end orbit_intlk;

architecture rtl of orbit_intlk is

  -- constants
  constant c_ADC_WIDTH       : natural := g_ADC_WIDTH;
  constant c_DECIM_WIDTH     : natural := g_DECIM_WIDTH;
  constant c_INTLK_LMT_WIDTH : natural := g_INTLK_LMT_WIDTH;

  -- types
  type t_bit_array is array (natural range <>) of std_logic;

  subtype t_decim_data is std_logic_vector(c_DECIM_WIDTH-1 downto 0);
  type t_decim_data_array is array (natural range <>) of t_decim_data;

  --signals
  signal decim_pos_sum_array   : t_decim_data_array(c_NUM_BPMS-1 downto 0);
  signal decim_pos_valid_array : t_bit_array(c_NUM_BPMS-1 downto 0);

  signal intlk_trans_ltc      : std_logic;
  signal intlk_trans          : std_logic;
  signal intlk_ang_ltc        : std_logic;
  signal intlk_ang            : std_logic;

  signal intlk_all            : std_logic;
  signal intlk_ltc            : std_logic;
  signal intlk                : std_logic;

  signal intlk_min_sum_n     : std_logic_vector(g_INTLK_LMT_WIDTH-1 downto 0);

  signal intlk_min_sum_valid        : t_bit_array(c_NUM_BPMS-1 downto 0);
  signal intlk_sum_bigger           : t_bit_array(c_NUM_BPMS-1 downto 0);
  signal intlk_sum_bigger_valid     : t_bit_array(c_NUM_BPMS-1 downto 0);
  signal intlk_sum_bigger_reg       : t_bit_array(c_NUM_BPMS-1 downto 0);
  signal intlk_sum_bigger_valid_reg : t_bit_array(c_NUM_BPMS-1 downto 0);
  signal intlk_sum_bigger_or        : t_bit_array(c_NUM_BPMS downto 0);
  signal intlk_sum_bigger_any       : std_logic;
  signal intlk_sum_bigger_en        : std_logic;
  signal intlk_trans_master_en      : std_logic;
  signal intlk_ang_master_en        : std_logic;

  -- synched signals
  signal adc_ds_ch0_swap          : std_logic_vector(g_ADC_WIDTH-1 downto 0) := (others => '0');
  signal adc_ds_ch1_swap          : std_logic_vector(g_ADC_WIDTH-1 downto 0) := (others => '0');
  signal adc_ds_ch2_swap          : std_logic_vector(g_ADC_WIDTH-1 downto 0) := (others => '0');
  signal adc_ds_ch3_swap          : std_logic_vector(g_ADC_WIDTH-1 downto 0) := (others => '0');
  signal adc_ds_tag               : std_logic_vector(0 downto 0) := (others => '0');
  signal adc_ds_swap_valid        : std_logic := '0';

  signal decim_ds_pos_x           : std_logic_vector(g_DECIM_WIDTH-1 downto 0);
  signal decim_ds_pos_y           : std_logic_vector(g_DECIM_WIDTH-1 downto 0);
  signal decim_ds_pos_q           : std_logic_vector(g_DECIM_WIDTH-1 downto 0);
  signal decim_ds_pos_sum         : std_logic_vector(g_DECIM_WIDTH-1 downto 0);
  signal decim_ds_pos_valid       : std_logic;

  signal adc_us_ch0_swap          : std_logic_vector(g_ADC_WIDTH-1 downto 0) := (others => '0');
  signal adc_us_ch1_swap          : std_logic_vector(g_ADC_WIDTH-1 downto 0) := (others => '0');
  signal adc_us_ch2_swap          : std_logic_vector(g_ADC_WIDTH-1 downto 0) := (others => '0');
  signal adc_us_ch3_swap          : std_logic_vector(g_ADC_WIDTH-1 downto 0) := (others => '0');
  signal adc_us_tag               : std_logic_vector(0 downto 0) := (others => '0');
  signal adc_us_swap_valid        : std_logic := '0';

  signal decim_us_pos_x           : std_logic_vector(g_DECIM_WIDTH-1 downto 0);
  signal decim_us_pos_y           : std_logic_vector(g_DECIM_WIDTH-1 downto 0);
  signal decim_us_pos_q           : std_logic_vector(g_DECIM_WIDTH-1 downto 0);
  signal decim_us_pos_sum         : std_logic_vector(g_DECIM_WIDTH-1 downto 0);
  signal decim_us_pos_valid       : std_logic;

begin

  cmp_orbit_intlk_cdc : orbit_intlk_cdc
  generic map
  (
    g_ADC_WIDTH               =>  g_ADC_WIDTH,
    g_DECIM_WIDTH             =>  g_DECIM_WIDTH,
    g_INTLK_LMT_WIDTH         =>  g_INTLK_LMT_WIDTH
  )
  port map
  (
    -----------------------------
    -- Clocks and resets
    -----------------------------

    ref_rst_n_i                                => ref_rst_n_i,
    ref_clk_i                                  => ref_clk_i,

    -----------------------------
    -- Downstream ADC and position signals
    -----------------------------

    fs_clk_ds_i                                => fs_clk_ds_i,

    adc_ds_ch0_swap_i                          => adc_ds_ch0_swap_i,
    adc_ds_ch1_swap_i                          => adc_ds_ch1_swap_i,
    adc_ds_ch2_swap_i                          => adc_ds_ch2_swap_i,
    adc_ds_ch3_swap_i                          => adc_ds_ch3_swap_i,
    adc_ds_tag_i                               => adc_ds_tag_i,
    adc_ds_swap_valid_i                        => adc_ds_swap_valid_i,

    decim_ds_pos_x_i                           => decim_ds_pos_x_i,
    decim_ds_pos_y_i                           => decim_ds_pos_y_i,
    decim_ds_pos_q_i                           => decim_ds_pos_q_i,
    decim_ds_pos_sum_i                         => decim_ds_pos_sum_i,
    decim_ds_pos_valid_i                       => decim_ds_pos_valid_i,

    -----------------------------
    -- Upstream ADC and position signals
    -----------------------------
    fs_clk_us_i                                => fs_clk_us_i,

    adc_us_ch0_swap_i                          => adc_us_ch0_swap_i,
    adc_us_ch1_swap_i                          => adc_us_ch1_swap_i,
    adc_us_ch2_swap_i                          => adc_us_ch2_swap_i,
    adc_us_ch3_swap_i                          => adc_us_ch3_swap_i,
    adc_us_tag_i                               => adc_us_tag_i,
    adc_us_swap_valid_i                        => adc_us_swap_valid_i,

    decim_us_pos_x_i                           => decim_us_pos_x_i,
    decim_us_pos_y_i                           => decim_us_pos_y_i,
    decim_us_pos_q_i                           => decim_us_pos_q_i,
    decim_us_pos_sum_i                         => decim_us_pos_sum_i,
    decim_us_pos_valid_i                       => decim_us_pos_valid_i,

    -----------------------------
    -- Synched Downstream ADC and position signals
    -----------------------------

    adc_ds_ch0_swap_o                          => adc_ds_ch0_swap,
    adc_ds_ch1_swap_o                          => adc_ds_ch1_swap,
    adc_ds_ch2_swap_o                          => adc_ds_ch2_swap,
    adc_ds_ch3_swap_o                          => adc_ds_ch3_swap,
    adc_ds_tag_o                               => adc_ds_tag,
    adc_ds_swap_valid_o                        => adc_ds_swap_valid,

    decim_ds_pos_x_o                           => decim_ds_pos_x,
    decim_ds_pos_y_o                           => decim_ds_pos_y,
    decim_ds_pos_q_o                           => decim_ds_pos_q,
    decim_ds_pos_sum_o                         => decim_ds_pos_sum,
    decim_ds_pos_valid_o                       => decim_ds_pos_valid,

    -----------------------------
    -- Synched Upstream ADC and position signals
    -----------------------------

    adc_us_ch0_swap_o                          => adc_us_ch0_swap,
    adc_us_ch1_swap_o                          => adc_us_ch1_swap,
    adc_us_ch2_swap_o                          => adc_us_ch2_swap,
    adc_us_ch3_swap_o                          => adc_us_ch3_swap,
    adc_us_tag_o                               => adc_us_tag,
    adc_us_swap_valid_o                        => adc_us_swap_valid,

    decim_us_pos_x_o                           => decim_us_pos_x,
    decim_us_pos_y_o                           => decim_us_pos_y,
    decim_us_pos_q_o                           => decim_us_pos_q,
    decim_us_pos_sum_o                         => decim_us_pos_sum,
    decim_us_pos_valid_o                       => decim_us_pos_valid
  );

  ---------------------------------
  -- Signal mangling
  --------------------------------

  -- Downstream
  decim_pos_sum_array(c_BPM_DS_IDX)   <= decim_ds_pos_sum;
  decim_pos_valid_array(c_BPM_DS_IDX) <= decim_ds_pos_valid;

  -- Upstream
  decim_pos_sum_array(c_BPM_US_IDX)   <= decim_us_pos_sum;
  decim_pos_valid_array(c_BPM_US_IDX) <= decim_us_pos_valid;

  intlk_min_sum_n <= not intlk_min_sum_i;

  gen_sum_intlk : for i in 0 to c_INTLK_GEN_UPTO_CHANNEL generate
    ----------------------------------
    -- Detect sum >= Threshold
    ----------------------------------
    -- Compare with threshold. Use the simple identity that:
    -- A >= B is the same A + (-B) and we check if MSB Carry
    -- is 1
    cmp_trans_thold_bigger : gc_big_adder2
    generic map (
      g_data_bits => c_DECIM_WIDTH
    )
    port map (
      clk_i        => ref_clk_i,
      stall_i      => '0',
      valid_i      => decim_pos_valid_array(i),
      a_i          => decim_pos_sum_array(i),
      b_i          => intlk_min_sum_n,
      c_i          => '1',
      c2_o         => intlk_sum_bigger(i),
      c2x2_valid_o => intlk_sum_bigger_valid(i)
    );

    -- gc_big_adder2 outputs are unregistered. So register them.
    p_sum_thold_bigger_reg : process(ref_clk_i)
    begin
      if rising_edge(ref_clk_i) then
        intlk_sum_bigger_reg(i) <= intlk_sum_bigger(i);
        intlk_sum_bigger_valid_reg(i) <= intlk_sum_bigger_valid(i);
      end if;
    end process;

  end generate;

  intlk_sum_bigger_or(0) <= '0';
  -- ORing all trans_bigger
  gen_intlk_sum_bigger : for i in 0 to c_INTLK_GEN_UPTO_CHANNEL generate
    intlk_sum_bigger_or(i+1) <= intlk_sum_bigger_or(i) or (intlk_sum_bigger_reg(i) and
                                                            intlk_sum_bigger_valid_reg(i));
  end generate;

  p_reg_enable : process(ref_clk_i)
  begin
    if rising_edge(ref_clk_i) then
      if ref_rst_n_i = '0' then
        intlk_sum_bigger_any <= '0';
        intlk_trans_master_en <= '0';
        intlk_ang_master_en <= '0';
      else
        intlk_sum_bigger_any <= intlk_sum_bigger_or(c_INTLK_GEN_UPTO_CHANNEL+1);
        intlk_trans_master_en <= intlk_trans_en_i and intlk_sum_bigger_en;
        intlk_ang_master_en <= intlk_ang_en_i and intlk_sum_bigger_en;
      end if;
    end if;
  end process;

  intlk_sum_bigger_en <= '1' when intlk_min_sum_en_i = '0' else intlk_sum_bigger_any;

  -----------------------------
  -- Translation interlock
  -----------------------------
  cmp_orbit_intlk_trans : orbit_intlk_trans
  generic map
  (
    g_ADC_WIDTH                                => g_ADC_WIDTH,
    g_DECIM_WIDTH                              => g_DECIM_WIDTH,
    -- interlock limits
    g_INTLK_LMT_WIDTH                          => g_INTLK_LMT_WIDTH
  )
  port map
  (
    -----------------------------
    -- Clocks and resets
    -----------------------------

    fs_rst_n_i                                 => ref_rst_n_i,
    fs_clk_i                                   => ref_clk_i,

    -----------------------------
    -- Interlock enable and limits signals
    -----------------------------

    -- Translation interlock on/off
    intlk_trans_en_i                           => intlk_trans_master_en,
    -- Translation interlock clear
    intlk_trans_clr_i                          => intlk_trans_clr_i,
    intlk_trans_max_x_i                        => intlk_trans_max_x_i,
    intlk_trans_max_y_i                        => intlk_trans_max_y_i,

    -----------------------------
    -- Downstream ADC and position signals
    -----------------------------

    adc_ds_ch0_swap_i                          => adc_ds_ch0_swap,
    adc_ds_ch1_swap_i                          => adc_ds_ch1_swap,
    adc_ds_ch2_swap_i                          => adc_ds_ch2_swap,
    adc_ds_ch3_swap_i                          => adc_ds_ch3_swap,
    adc_ds_tag_i                               => adc_ds_tag,
    adc_ds_swap_valid_i                        => adc_ds_swap_valid,

    decim_ds_pos_x_i                           => decim_ds_pos_x,
    decim_ds_pos_y_i                           => decim_ds_pos_y,
    decim_ds_pos_q_i                           => decim_ds_pos_q,
    decim_ds_pos_sum_i                         => decim_ds_pos_sum,
    decim_ds_pos_valid_i                       => decim_ds_pos_valid,

    -----------------------------
    -- Upstream ADC and position signals
    -----------------------------

    adc_us_ch0_swap_i                          => adc_us_ch0_swap,
    adc_us_ch1_swap_i                          => adc_us_ch1_swap,
    adc_us_ch2_swap_i                          => adc_us_ch2_swap,
    adc_us_ch3_swap_i                          => adc_us_ch3_swap,
    adc_us_tag_i                               => adc_us_tag,
    adc_us_swap_valid_i                        => adc_us_swap_valid,

    decim_us_pos_x_i                           => decim_us_pos_x,
    decim_us_pos_y_i                           => decim_us_pos_y,
    decim_us_pos_q_i                           => decim_us_pos_q,
    decim_us_pos_sum_i                         => decim_us_pos_sum,
    decim_us_pos_valid_i                       => decim_us_pos_valid,

    -----------------------------
    -- Interlock outputs
    -----------------------------
    intlk_trans_bigger_x_o                     => intlk_trans_bigger_x_o,
    intlk_trans_bigger_y_o                     => intlk_trans_bigger_y_o,

    intlk_trans_bigger_ltc_x_o                 => intlk_trans_bigger_ltc_x_o,
    intlk_trans_bigger_ltc_y_o                 => intlk_trans_bigger_ltc_y_o,

    intlk_trans_bigger_o                       => intlk_trans_bigger_o,

    intlk_trans_ltc_o                          => intlk_trans_ltc,
    intlk_trans_o                              => intlk_trans
  );

  intlk_trans_ltc_o <= intlk_trans_ltc;
  intlk_trans_o <= intlk_trans;

  -----------------------------
  -- Angular interlock
  -----------------------------
  cmp_orbit_intlk_ang : orbit_intlk_ang
  generic map
  (
    g_ADC_WIDTH                                => g_ADC_WIDTH,
    g_DECIM_WIDTH                              => g_DECIM_WIDTH,
    -- interlock limits
    g_INTLK_LMT_WIDTH                          => g_INTLK_LMT_WIDTH
  )
  port map
  (
    -----------------------------
    -- Clocks and resets
    -----------------------------

    fs_rst_n_i                                 => ref_rst_n_i,
    fs_clk_i                                   => ref_clk_i,

    -----------------------------
    -- Interlock enable and limits signals
    -----------------------------

    -- Angular interlock on/off
    intlk_ang_en_i                             => intlk_ang_master_en,
    -- Angular interlock clear
    intlk_ang_clr_i                            => intlk_ang_clr_i,
    intlk_ang_max_x_i                          => intlk_ang_max_x_i,
    intlk_ang_max_y_i                          => intlk_ang_max_y_i,

    -----------------------------
    -- Downstream ADC and position signals
    -----------------------------

    adc_ds_ch0_swap_i                          => adc_ds_ch0_swap,
    adc_ds_ch1_swap_i                          => adc_ds_ch1_swap,
    adc_ds_ch2_swap_i                          => adc_ds_ch2_swap,
    adc_ds_ch3_swap_i                          => adc_ds_ch3_swap,
    adc_ds_tag_i                               => adc_ds_tag,
    adc_ds_swap_valid_i                        => adc_ds_swap_valid,

    decim_ds_pos_x_i                           => decim_ds_pos_x,
    decim_ds_pos_y_i                           => decim_ds_pos_y,
    decim_ds_pos_q_i                           => decim_ds_pos_q,
    decim_ds_pos_sum_i                         => decim_ds_pos_sum,
    decim_ds_pos_valid_i                       => decim_ds_pos_valid,

    -----------------------------
    -- Upstream ADC and position signals
    -----------------------------

    adc_us_ch0_swap_i                          => adc_us_ch0_swap,
    adc_us_ch1_swap_i                          => adc_us_ch1_swap,
    adc_us_ch2_swap_i                          => adc_us_ch2_swap,
    adc_us_ch3_swap_i                          => adc_us_ch3_swap,
    adc_us_tag_i                               => adc_us_tag,
    adc_us_swap_valid_i                        => adc_us_swap_valid,

    decim_us_pos_x_i                           => decim_us_pos_x,
    decim_us_pos_y_i                           => decim_us_pos_y,
    decim_us_pos_q_i                           => decim_us_pos_q,
    decim_us_pos_sum_i                         => decim_us_pos_sum,
    decim_us_pos_valid_i                       => decim_us_pos_valid,

    -----------------------------
    -- Interlock outputs
    -----------------------------
    intlk_ang_bigger_x_o                       => intlk_ang_bigger_x_o,
    intlk_ang_bigger_y_o                       => intlk_ang_bigger_y_o,

    intlk_ang_bigger_ltc_x_o                   => intlk_ang_bigger_ltc_x_o,
    intlk_ang_bigger_ltc_y_o                   => intlk_ang_bigger_ltc_y_o,

    intlk_ang_bigger_o                         => intlk_ang_bigger_o,

    intlk_ang_ltc_o                            => intlk_ang_ltc,
    intlk_ang_o                                => intlk_ang
  );

  intlk_ang_ltc_o <= intlk_ang_ltc;
  intlk_ang_o <= intlk_ang;

  -------------------------------------------------------------------------
  -- General interlock detector. Only for X and Y.
  -------------------------------------------------------------------------

  intlk_all <= (intlk_trans or intlk_ang) and intlk_en_i;

  p_out : process(ref_clk_i)
  begin
    if rising_edge(ref_clk_i) then
      if ref_rst_n_i = '0' then
        intlk_ltc <= '0';
        intlk <= '0';
      else
        -- latch up translation interlock status
        -- only clear on "clear" signal
        if intlk_clr_i = '1' then
          intlk_ltc <= '0';
        elsif intlk_all = '1' then
          intlk_ltc <= '1';
        end if;

        -- register translation interlock when active
        if intlk_clr_i = '1' or intlk_en_i = '0' then
          intlk <= '0';
        elsif intlk_en_i = '1' then
          intlk <= intlk_all;
        end if;
      end if;
    end if;
  end process;

  intlk_ltc_o     <= intlk_ltc;
  intlk_o         <= intlk;

end rtl;
