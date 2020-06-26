------------------------------------------------------------------------------
-- Title      : BPM orbit interlock CDC FIFOs
------------------------------------------------------------------------------
-- Author     : Lucas Maziero Russo
-- Company    : CNPEM LNLS-DIG
-- Created    : 2022-06-12
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: Module for orbit interlock CDC FIFOs
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

entity orbit_intlk_cdc is
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
  -- Synched Downstream ADC and position signals
  -----------------------------

  adc_ds_ch0_swap_o                          : out std_logic_vector(g_ADC_WIDTH-1 downto 0) := (others => '0');
  adc_ds_ch1_swap_o                          : out std_logic_vector(g_ADC_WIDTH-1 downto 0) := (others => '0');
  adc_ds_ch2_swap_o                          : out std_logic_vector(g_ADC_WIDTH-1 downto 0) := (others => '0');
  adc_ds_ch3_swap_o                          : out std_logic_vector(g_ADC_WIDTH-1 downto 0) := (others => '0');
  adc_ds_tag_o                               : out std_logic_vector(0 downto 0) := (others => '0');
  adc_ds_swap_valid_o                        : out std_logic := '0';

  decim_ds_pos_x_o                           : out std_logic_vector(g_DECIM_WIDTH-1 downto 0);
  decim_ds_pos_y_o                           : out std_logic_vector(g_DECIM_WIDTH-1 downto 0);
  decim_ds_pos_q_o                           : out std_logic_vector(g_DECIM_WIDTH-1 downto 0);
  decim_ds_pos_sum_o                         : out std_logic_vector(g_DECIM_WIDTH-1 downto 0);
  decim_ds_pos_valid_o                       : out std_logic;

  -----------------------------
  -- Synched Upstream ADC and position signals
  -----------------------------

  adc_us_ch0_swap_o                          : out std_logic_vector(g_ADC_WIDTH-1 downto 0) := (others => '0');
  adc_us_ch1_swap_o                          : out std_logic_vector(g_ADC_WIDTH-1 downto 0) := (others => '0');
  adc_us_ch2_swap_o                          : out std_logic_vector(g_ADC_WIDTH-1 downto 0) := (others => '0');
  adc_us_ch3_swap_o                          : out std_logic_vector(g_ADC_WIDTH-1 downto 0) := (others => '0');
  adc_us_tag_o                               : out std_logic_vector(0 downto 0) := (others => '0');
  adc_us_swap_valid_o                        : out std_logic := '0';

  decim_us_pos_x_o                           : out std_logic_vector(g_DECIM_WIDTH-1 downto 0);
  decim_us_pos_y_o                           : out std_logic_vector(g_DECIM_WIDTH-1 downto 0);
  decim_us_pos_q_o                           : out std_logic_vector(g_DECIM_WIDTH-1 downto 0);
  decim_us_pos_sum_o                         : out std_logic_vector(g_DECIM_WIDTH-1 downto 0);
  decim_us_pos_valid_o                       : out std_logic
);
end orbit_intlk_cdc;

architecture rtl of orbit_intlk_cdc is

  -- constants
  constant c_ADC_WIDTH       : natural := g_ADC_WIDTH;
  constant c_DECIM_WIDTH     : natural := g_DECIM_WIDTH;
  constant c_INTLK_LMT_WIDTH : natural := g_INTLK_LMT_WIDTH;

  constant c_CDC_REF_SIZE    : natural := 4;

  -- types
  type t_bit_array is array (natural range <>) of std_logic;
  type t_bit_array2d is array (natural range <>, natural range <>) of std_logic;

  subtype t_adc_data is std_logic_vector(c_adc_width-1 downto 0);
  type t_adc_data_array is array (natural range <>) of t_adc_data;

  subtype t_adc_tag is std_logic_vector(0 downto 0);
  type t_adc_tag_array is array (natural range <>) of t_adc_tag;

  subtype t_decim_data is std_logic_vector(c_decim_width-1 downto 0);
  type t_decim_data_array is array (natural range <>) of t_decim_data;

  subtype t_intlk_lmt_data is std_logic_vector(c_intlk_lmt_width-1 downto 0);
  type t_intlk_lmt_data_array is array (natural range <>) of t_intlk_lmt_data;

  type t_adc_data_array2d is array (natural range <>, natural range <>) of t_adc_data;
  type t_decim_data_array2d is array (natural range <>, natural range <>) of t_decim_data;

  --signals

  -- input mangling
  signal adc_array               : t_adc_data_array2d(c_NUM_BPMS-1 downto 0, c_NUM_CHANNELS-1 downto 0);
  signal adc_tag_array           : t_adc_tag_array(c_NUM_BPMS-1 downto 0);
  signal adc_valid_array         : t_bit_array(c_NUM_BPMS-1 downto 0);
  signal decim_pos_array         : t_decim_data_array2d(c_NUM_BPMS-1 downto 0, c_NUM_CHANNELS-1 downto 0);
  signal decim_pos_valid_array   : t_bit_array(c_NUM_BPMS-1 downto 0);

  signal adc_synch_array             : t_adc_data_array2d(c_NUM_BPMS-1 downto 0, c_NUM_CHANNELS-1 downto 0);
  signal adc_synch_valid_array       : t_bit_array2d(c_NUM_BPMS-1 downto 0, c_NUM_CHANNELS-1 downto 0);
  signal adc_synch_tag_array         : t_adc_tag_array(c_NUM_BPMS-1 downto 0);
  signal adc_synch_tag_valid_array   : t_bit_array(c_NUM_BPMS-1 downto 0);
  signal decim_pos_synch_array       : t_decim_data_array2d(c_NUM_BPMS-1 downto 0, c_NUM_CHANNELS-1 downto 0);
  signal decim_pos_synch_valid_array : t_bit_array2d(c_NUM_BPMS-1 downto 0, c_NUM_CHANNELS-1 downto 0);

  signal adc_synch_rd                : std_logic;
  signal decim_pos_synch_rd          : std_logic;
  signal adc_synch_rd_and            : std_logic_vector(c_NUM_BPMS downto 0);
  signal decim_pos_synch_rd_and      : std_logic_vector(c_NUM_BPMS downto 0);

  signal fs_clk_array                : std_logic_vector(c_NUM_BPMS-1 downto 0);
  signal adc_synch_tag_empty         : t_bit_array(c_NUM_BPMS-1 downto 0);
  signal adc_synch_empty             : t_bit_array2d(c_NUM_BPMS-1 downto 0, c_NUM_CHANNELS-1 downto 0);
  signal decim_pos_synch_empty       : t_bit_array2d(c_NUM_BPMS-1 downto 0, c_NUM_CHANNELS-1 downto 0);

begin

  ---------------------------------
  -- Signal mangling
  --------------------------------

  fs_clk_array(c_BPM_DS_IDX)    <= fs_clk_ds_i;

  -- Downstream
  adc_array(c_BPM_DS_IDX, 0)    <= adc_ds_ch0_swap_i;
  adc_array(c_BPM_DS_IDX, 1)    <= adc_ds_ch1_swap_i;
  adc_array(c_BPM_DS_IDX, 2)    <= adc_ds_ch2_swap_i;
  adc_array(c_BPM_DS_IDX, 3)    <= adc_ds_ch3_swap_i;
  adc_tag_array(c_BPM_DS_IDX)   <= adc_ds_tag_i;
  adc_valid_array(c_BPM_DS_IDX) <= adc_ds_swap_valid_i;

  decim_pos_array(c_BPM_DS_IDX, 0)    <= decim_ds_pos_x_i;
  decim_pos_array(c_BPM_DS_IDX, 1)    <= decim_ds_pos_y_i;
  decim_pos_array(c_BPM_DS_IDX, 2)    <= decim_ds_pos_q_i;
  decim_pos_array(c_BPM_DS_IDX, 3)    <= decim_ds_pos_sum_i;
  decim_pos_valid_array(c_BPM_DS_IDX) <= decim_ds_pos_valid_i;

  -- Upwnstream
  fs_clk_array(c_BPM_US_IDX)    <= fs_clk_us_i;

  adc_array(c_BPM_US_IDX, 0)    <= adc_us_ch0_swap_i;
  adc_array(c_BPM_US_IDX, 1)    <= adc_us_ch1_swap_i;
  adc_array(c_BPM_US_IDX, 2)    <= adc_us_ch2_swap_i;
  adc_array(c_BPM_US_IDX, 3)    <= adc_us_ch3_swap_i;
  adc_tag_array(c_BPM_US_IDX)   <= adc_us_tag_i;
  adc_valid_array(c_BPM_US_IDX) <= adc_us_swap_valid_i;

  decim_pos_array(c_BPM_US_IDX, 0)    <= decim_us_pos_x_i;
  decim_pos_array(c_BPM_US_IDX, 1)    <= decim_us_pos_y_i;
  decim_pos_array(c_BPM_US_IDX, 2)    <= decim_us_pos_q_i;
  decim_pos_array(c_BPM_US_IDX, 3)    <= decim_us_pos_sum_i;
  decim_pos_valid_array(c_BPM_US_IDX) <= decim_us_pos_valid_i;

  ---------------------------------
  -- Decim CDC FIFOs
  --------------------------------
  gen_cdc_fifos_bpms : for i in 0 to c_NUM_BPMS-1 generate

    cmp_orbit_intlk_adc_tag_cdc_fifo : orbit_intlk_cdc_fifo
    generic map
    (
      g_data_width                              => 1,
      g_size                                    => c_CDC_REF_SIZE
    )
    port map
    (
      clk_wr_i                                  => fs_clk_array(i),
      data_i                                    => adc_tag_array(i),
      valid_i                                   => adc_valid_array(i),

      clk_rd_i                                  => ref_clk_i,
      rd_i                                      => adc_synch_rd,
      data_o                                    => adc_synch_tag_array(i),
      valid_o                                   => adc_synch_tag_valid_array(i),
      empty_o                                   => adc_synch_tag_empty(i)
    );

    gen_cdc_fifos_chan : for j in 0 to c_NUM_CHANNELS-1 generate

      cmp_orbit_intlk_adc_cdc_fifo : orbit_intlk_cdc_fifo
      generic map
      (
        g_data_width                              => c_ADC_WIDTH,
        g_size                                    => c_CDC_REF_SIZE
      )
      port map
      (
        clk_wr_i                                  => fs_clk_array(i),
        data_i                                    => adc_array(i, j),
        valid_i                                   => adc_valid_array(i),

        clk_rd_i                                  => ref_clk_i,
        rd_i                                      => adc_synch_rd,
        data_o                                    => adc_synch_array(i, j),
        valid_o                                   => adc_synch_valid_array(i, j),
        empty_o                                   => adc_synch_empty(i, j)
      );

      cmp_orbit_intlk_decim_cdc_fifo : orbit_intlk_cdc_fifo
      generic map
      (
        g_data_width                              => c_DECIM_WIDTH,
        g_size                                    => c_CDC_REF_SIZE
      )
      port map
      (
        clk_wr_i                                  => fs_clk_array(i),
        data_i                                    => decim_pos_array(i, j),
        valid_i                                   => decim_pos_valid_array(i),

        clk_rd_i                                  => ref_clk_i,
        rd_i                                      => decim_pos_synch_rd,
        data_o                                    => decim_pos_synch_array(i, j),
        valid_o                                   => decim_pos_synch_valid_array(i, j),
        empty_o                                   => decim_pos_synch_empty(i, j)
      );

    end generate;

  end generate;

  -- generate read signals based on empty FIFO flags

  adc_synch_rd_and(0) <= '1';
  -- ANDing all trans_bigger
  gen_adc_synch_rd_and : for i in 0 to c_NUM_BPMS-1 generate
    adc_synch_rd_and(i+1) <= adc_synch_rd_and(i) and not adc_synch_empty(i, 0);
  end generate;

  adc_synch_rd <= adc_synch_rd_and(c_NUM_BPMS);

  decim_pos_synch_rd_and(0) <= '1';
  -- ANDing all trans_bigger
  gen_decim_pos_synch_rd_and : for i in 0 to c_NUM_BPMS-1 generate
    decim_pos_synch_rd_and(i+1) <= decim_pos_synch_rd_and(i) and not decim_pos_synch_empty(i, 0);
  end generate;

  decim_pos_synch_rd <= decim_pos_synch_rd_and(c_NUM_BPMS);

  ---------------------------------
  -- Signal unmangling
  --------------------------------

  -- Downstream
  adc_ds_ch0_swap_o      <= adc_synch_array(c_BPM_DS_IDX, 0);
  adc_ds_ch1_swap_o      <= adc_synch_array(c_BPM_DS_IDX, 1);
  adc_ds_ch2_swap_o      <= adc_synch_array(c_BPM_DS_IDX, 2);
  adc_ds_ch3_swap_o      <= adc_synch_array(c_BPM_DS_IDX, 3);
  adc_ds_tag_o           <= adc_synch_tag_array(c_BPM_DS_IDX);
  adc_ds_swap_valid_o    <= adc_synch_valid_array(c_BPM_DS_IDX, 0);

  decim_ds_pos_x_o       <= decim_pos_synch_array(c_BPM_DS_IDX, 0);
  decim_ds_pos_y_o       <= decim_pos_synch_array(c_BPM_DS_IDX, 1);
  decim_ds_pos_q_o       <= decim_pos_synch_array(c_BPM_DS_IDX, 2);
  decim_ds_pos_sum_o     <= decim_pos_synch_array(c_BPM_DS_IDX, 3);
  decim_ds_pos_valid_o   <= decim_pos_synch_valid_array(c_BPM_DS_IDX, 0);

  -- Upstream
  adc_us_ch0_swap_o      <= adc_synch_array(c_BPM_US_IDX, 0);
  adc_us_ch1_swap_o      <= adc_synch_array(c_BPM_US_IDX, 1);
  adc_us_ch2_swap_o      <= adc_synch_array(c_BPM_US_IDX, 2);
  adc_us_ch3_swap_o      <= adc_synch_array(c_BPM_US_IDX, 3);
  adc_us_tag_o           <= adc_synch_tag_array(c_BPM_US_IDX);
  adc_us_swap_valid_o    <= adc_synch_valid_array(c_BPM_US_IDX, 0);

  decim_us_pos_x_o       <= decim_pos_synch_array(c_BPM_US_IDX, 0);
  decim_us_pos_y_o       <= decim_pos_synch_array(c_BPM_US_IDX, 1);
  decim_us_pos_q_o       <= decim_pos_synch_array(c_BPM_US_IDX, 2);
  decim_us_pos_sum_o     <= decim_pos_synch_array(c_BPM_US_IDX, 3);
  decim_us_pos_valid_o   <= decim_pos_synch_valid_array(c_BPM_US_IDX, 0);

end rtl;
