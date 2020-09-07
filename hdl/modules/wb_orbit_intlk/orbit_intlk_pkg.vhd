library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.wishbone_pkg.all;

package orbit_intlk_pkg is

  -------------------------------------------------------------------------------
  -- Types
  -------------------------------------------------------------------------------

  -------------------------------------------------------------------------------
  -- Constants
  -------------------------------------------------------------------------------
  constant c_CHAN_X_IDX   : natural := 0;
  constant c_CHAN_Y_IDX   : natural := 1;
  constant c_CHAN_Q_IDX   : natural := 2;
  constant c_CHAN_SUM_IDX : natural := 3;

  constant c_CHAN_A_IDX   : natural := 0;
  constant c_CHAN_B_IDX   : natural := 1;
  constant c_CHAN_C_IDX   : natural := 2;
  constant c_CHAN_D_IDX   : natural := 3;

  constant c_NUM_CHANNELS : natural := 4;

  constant c_BPM_DS_IDX   : natural := 0;
  constant c_BPM_US_IDX   : natural := 1;
  constant c_NUM_BPMS     : natural := 2;

  -- generate interlock logic up to which channel?
  constant c_INTLK_GEN_UPTO_CHANNEL : natural := c_CHAN_Y_IDX;

  --------------------------------------------------------------------
  -- Components
  --------------------------------------------------------------------
  component orbit_intlk
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
    intlk_trans_min_x_i                        : in std_logic_vector(g_INTLK_LMT_WIDTH-1 downto 0);
    intlk_trans_min_y_i                        : in std_logic_vector(g_INTLK_LMT_WIDTH-1 downto 0);
    -- Angular interlock on/off
    intlk_ang_en_i                             : in std_logic;
    -- Angular interlock clear
    intlk_ang_clr_i                            : in std_logic;
    intlk_ang_max_x_i                          : in std_logic_vector(g_INTLK_LMT_WIDTH-1 downto 0);
    intlk_ang_max_y_i                          : in std_logic_vector(g_INTLK_LMT_WIDTH-1 downto 0);
    intlk_ang_min_x_i                          : in std_logic_vector(g_INTLK_LMT_WIDTH-1 downto 0);
    intlk_ang_min_y_i                          : in std_logic_vector(g_INTLK_LMT_WIDTH-1 downto 0);

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

    -- only cleared when intlk_trans_clr_i is asserted
    intlk_trans_bigger_ltc_x_o                 : out std_logic;
    intlk_trans_bigger_ltc_y_o                 : out std_logic;

    intlk_trans_bigger_any_o                   : out std_logic;

    -- only cleared when intlk_trans_clr_i is asserted
    intlk_trans_bigger_ltc_o                   : out std_logic;
    -- conditional to intlk_trans_en_i
    intlk_trans_bigger_o                       : out std_logic;

    intlk_trans_smaller_x_o                    : out std_logic;
    intlk_trans_smaller_y_o                    : out std_logic;

    -- only cleared when intlk_trans_clr_i is asserted
    intlk_trans_smaller_ltc_x_o                : out std_logic;
    intlk_trans_smaller_ltc_y_o                : out std_logic;

    intlk_trans_smaller_any_o                  : out std_logic;

    -- only cleared when intlk_trans_clr_i is asserted
    intlk_trans_smaller_ltc_o                  : out std_logic;
    -- conditional to intlk_trans_en_i
    intlk_trans_smaller_o                      : out std_logic;

    -- only cleared when intlk_clr_i is asserted
    intlk_trans_ltc_o                          : out std_logic;
    -- conditional to intlk_en_i
    intlk_trans_o                              : out std_logic;

    intlk_ang_bigger_x_o                       : out std_logic;
    intlk_ang_bigger_y_o                       : out std_logic;

    intlk_ang_bigger_ltc_x_o                   : out std_logic;
    intlk_ang_bigger_ltc_y_o                   : out std_logic;

    intlk_ang_bigger_any_o                     : out std_logic;

    -- only cleared when intlk_ang_clr_i is asserted
    intlk_ang_bigger_ltc_o                     : out std_logic;
    -- conditional to intlk_ang_en_i
    intlk_ang_bigger_o                         : out std_logic;

    intlk_ang_smaller_x_o                      : out std_logic;
    intlk_ang_smaller_y_o                      : out std_logic;

    intlk_ang_smaller_ltc_x_o                  : out std_logic;
    intlk_ang_smaller_ltc_y_o                  : out std_logic;

    intlk_ang_smaller_any_o                    : out std_logic;

    -- only cleared when intlk_ang_clr_i is asserted
    intlk_ang_smaller_ltc_o                    : out std_logic;
    -- conditional to intlk_ang_en_i
    intlk_ang_smaller_o                        : out std_logic;

    -- only cleared when intlk_clr_i is asserted
    intlk_ang_ltc_o                            : out std_logic;
    -- conditional to intlk_en_i
    intlk_ang_o                                : out std_logic;

    -- only cleared when intlk_clr_i is asserted
    intlk_ltc_o                                : out std_logic;
    -- conditional to intlk_en_i
    intlk_o                                    : out std_logic
  );
  end component;

  component orbit_intlk_trans is
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

    fs_rst_n_i                                 : in std_logic;
    fs_clk_i                                   : in std_logic;

    -----------------------------
    -- Interlock enable and limits signals
    -----------------------------

    -- Translation interlock on/off
    intlk_trans_en_i                           : in std_logic;
    -- Translation interlock clear
    intlk_trans_clr_i                          : in std_logic;
    intlk_trans_max_x_i                        : in std_logic_vector(g_INTLK_LMT_WIDTH-1 downto 0);
    intlk_trans_max_y_i                        : in std_logic_vector(g_INTLK_LMT_WIDTH-1 downto 0);
    intlk_trans_min_x_i                        : in std_logic_vector(g_INTLK_LMT_WIDTH-1 downto 0);
    intlk_trans_min_y_i                        : in std_logic_vector(g_INTLK_LMT_WIDTH-1 downto 0);

    -----------------------------
    -- Downstream ADC and position signals
    -----------------------------

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

    intlk_trans_bigger_any_o                   : out std_logic;

    -- only cleared when intlk_trans_clr_i is asserted
    intlk_trans_bigger_ltc_o                   : out std_logic;
    -- conditional to intlk_trans_en_i
    intlk_trans_bigger_o                       : out std_logic;

    intlk_trans_smaller_x_o                    : out std_logic;
    intlk_trans_smaller_y_o                    : out std_logic;

    intlk_trans_smaller_ltc_x_o                : out std_logic;
    intlk_trans_smaller_ltc_y_o                : out std_logic;

    intlk_trans_smaller_any_o                  : out std_logic;

    -- only cleared when intlk_trans_clr_i is asserted
    intlk_trans_smaller_ltc_o                  : out std_logic;
    -- conditional to intlk_trans_en_i
    intlk_trans_smaller_o                      : out std_logic
  );
  end component;

  component orbit_intlk_ang is
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

    fs_rst_n_i                                 : in std_logic;
    fs_clk_i                                   : in std_logic;

    -----------------------------
    -- Interlock enable and limits signals
    -----------------------------

    -- Angular interlock on/off
    intlk_ang_en_i                             : in std_logic;
    -- Angular interlock clear
    intlk_ang_clr_i                            : in std_logic;
    intlk_ang_max_x_i                          : in std_logic_vector(g_INTLK_LMT_WIDTH-1 downto 0);
    intlk_ang_max_y_i                          : in std_logic_vector(g_INTLK_LMT_WIDTH-1 downto 0);
    intlk_ang_min_x_i                          : in std_logic_vector(g_INTLK_LMT_WIDTH-1 downto 0);
    intlk_ang_min_y_i                          : in std_logic_vector(g_INTLK_LMT_WIDTH-1 downto 0);

    -----------------------------
    -- Downstream ADC and position signals
    -----------------------------

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
    intlk_ang_bigger_x_o                       : out std_logic;
    intlk_ang_bigger_y_o                       : out std_logic;

    intlk_ang_bigger_ltc_x_o                   : out std_logic;
    intlk_ang_bigger_ltc_y_o                   : out std_logic;

    intlk_ang_bigger_any_o                     : out std_logic;

    -- only cleared when intlk_ang_clr_i is asserted
    intlk_ang_bigger_ltc_o                     : out std_logic;
    -- conditional to intlk_ang_en_i
    intlk_ang_bigger_o                         : out std_logic;

    intlk_ang_smaller_x_o                      : out std_logic;
    intlk_ang_smaller_y_o                      : out std_logic;

    intlk_ang_smaller_ltc_x_o                  : out std_logic;
    intlk_ang_smaller_ltc_y_o                  : out std_logic;

    intlk_ang_smaller_any_o                    : out std_logic;

    -- only cleared when intlk_ang_clr_i is asserted
    intlk_ang_smaller_ltc_o                    : out std_logic;
    -- conditional to intlk_ang_en_i
    intlk_ang_smaller_o                        : out std_logic
  );
  end component;

  component orbit_intlk_cdc_fifo
  generic
  (
    g_data_width                              : natural;
    g_size                                    : natural
  );
  port
  (
    clk_wr_i                                  : in std_logic;
    data_i                                    : in std_logic_vector(g_data_width-1 downto 0);
    valid_i                                   : in std_logic;

    clk_rd_i                                  : in std_logic;
    rd_i                                      : in std_logic;
    data_o                                    : out std_logic_vector(g_data_width-1 downto 0);
    valid_o                                   : out std_logic;
    empty_o                                   : out std_logic
  );
  end component;

  component orbit_intlk_cdc
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
  end component;

  constant c_xwb_orbit_intlk_sdb : t_sdb_device := (
    abi_class     => x"0000",                 -- undocumented device
    abi_ver_major => x"01",
    abi_ver_minor => x"00",
    wbd_endian    => c_sdb_endian_big,
    wbd_width     => x"4",                     -- 8/16/32-bit port granularity (0100)
    sdb_component => (
    addr_first    => x"0000000000000000",
    addr_last     => x"00000000000000FF",
    product => (
    vendor_id     => x"1000000000001215",     -- LNLS
    device_id     => x"87efeda8",
    version       => x"00000001",
    date          => x"20200612",
    name          => "LNLS_INTLK_REGS    ")));

end orbit_intlk_pkg;

package body orbit_intlk_pkg is

end orbit_intlk_pkg;
