library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
-- Main Wishbone Definitions
use work.wishbone_pkg.all;

package bpm_cores_pkg is

  -------------------------------------------------------------------------------
  -- Types
  -------------------------------------------------------------------------------

  subtype t_swap_mode is std_logic_vector(1 downto 0);
  constant c_swmode_rffe_swap       : t_swap_mode := "00";
  constant c_swmode_static_direct   : t_swap_mode := "01";
  constant c_swmode_static_inverted : t_swap_mode := "10";
  constant c_swmode_swap_deswap     : t_swap_mode := "11";

  --------------------------------------------------------------------
  -- Components
  --------------------------------------------------------------------

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

  component mixer is
    generic (
      g_sin_file         : string;
      g_cos_file         : string;
      g_number_of_points : natural := 6;
      g_input_width      : natural := 16;
      g_dds_width        : natural := 16;
      g_output_width     : natural := 32;
      g_tag_width        : natural := 1;
      g_mult_levels      : natural := 7);
    port (
      rst_i       : in  std_logic;
      clk_i       : in  std_logic;
      ce_i        : in  std_logic;
      signal_i    : in  std_logic_vector(g_input_width-1 downto 0);
      valid_i     : in  std_logic;
      tag_i       : in  std_logic_vector(g_tag_width-1 downto 0) := (others => '0');
      I_out       : out std_logic_vector(g_output_width-1 downto 0);
      I_tag_out   : out std_logic_vector(g_tag_width-1 downto 0);
      Q_out       : out std_logic_vector(g_output_width-1 downto 0);
      Q_tag_out   : out std_logic_vector(g_tag_width-1 downto 0);
      valid_o     : out std_logic);
  end component mixer;

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

  component position_calc is
    generic (
      g_with_downconv            : boolean  := true;
      g_input_width              : natural  := 16;
      g_mixed_width              : natural  := 16;
      g_adc_ratio                : natural  := 1;
      g_dds_width                : natural  := 16;
      g_dds_points               : natural  := 35;
      g_sin_file                 : string   := "../../../dsp-cores/hdl/modules/position_calc/dds_sin.nif";
      g_cos_file                 : string   := "../../../dsp-cores/hdl/modules/position_calc/dds_cos.nif";
      g_tbt_tag_desync_cnt_width : natural := 14;
      g_tbt_cic_mask_samples_width : natural := 16;
      g_tbt_cic_delay            : natural  := 1;
      g_tbt_cic_stages           : natural  := 2;
      g_tbt_ratio                : natural  := 35;
      g_tbt_decim_width          : natural  := 32;
      g_fofb_cic_delay           : natural  := 1;
      g_fofb_cic_stages          : natural  := 2;
      g_fofb_ratio               : natural  := 980;
      g_fofb_decim_width         : natural  := 32;
      g_fofb_decim_desync_cnt_width : natural := 14;
      g_fofb_cic_mask_samples_width : natural := 16;
      g_monit1_cic_delay         : natural  := 1;
      g_monit1_cic_stages        : natural  := 1;
      g_monit1_ratio             : natural  := 100;
      g_monit1_cic_ratio         : positive := 8;
      g_monit2_cic_delay         : natural  := 1;
      g_monit2_cic_stages        : natural  := 1;
      g_monit2_ratio             : natural  := 100;
      g_monit2_cic_ratio         : positive := 8;
      g_monit_decim_width        : natural  := 32;
      g_tbt_cordic_stages        : positive := 12;
      g_tbt_cordic_iter_per_clk  : positive := 3;
      g_tbt_cordic_ratio         : positive := 4;
      g_fofb_cordic_stages       : positive := 15;
      g_fofb_cordic_iter_per_clk : positive := 3;
      g_fofb_cordic_ratio        : positive := 4;
      g_k_width                  : natural  := 24;
      g_IQ_width                 : natural  := 32);
    port (
      adc_ch0_i          : in  std_logic_vector(g_input_width-1 downto 0);
      adc_ch1_i          : in  std_logic_vector(g_input_width-1 downto 0);
      adc_ch2_i          : in  std_logic_vector(g_input_width-1 downto 0);
      adc_ch3_i          : in  std_logic_vector(g_input_width-1 downto 0);
      adc_tag_i          : in  std_logic_vector(0 downto 0);
      adc_tag_en_i       : in  std_logic                                   := '0';
      adc_valid_i        : in  std_logic;
      clk_i              : in  std_logic;
      rst_i              : in  std_logic;
      ksum_i             : in  std_logic_vector(g_k_width-1 downto 0);
      kx_i               : in  std_logic_vector(g_k_width-1 downto 0);
      ky_i               : in  std_logic_vector(g_k_width-1 downto 0);
      mix_ch0_i_o        : out std_logic_vector(g_IQ_width-1 downto 0);
      mix_ch0_q_o        : out std_logic_vector(g_IQ_width-1 downto 0);
      mix_ch1_i_o        : out std_logic_vector(g_IQ_width-1 downto 0);
      mix_ch1_q_o        : out std_logic_vector(g_IQ_width-1 downto 0);
      mix_ch2_i_o        : out std_logic_vector(g_IQ_width-1 downto 0);
      mix_ch2_q_o        : out std_logic_vector(g_IQ_width-1 downto 0);
      mix_ch3_i_o        : out std_logic_vector(g_IQ_width-1 downto 0);
      mix_ch3_q_o        : out std_logic_vector(g_IQ_width-1 downto 0);
      mix_valid_o        : out std_logic;
      mix_ce_o           : out std_logic;
      tbt_tag_i                         : in std_logic_vector(0 downto 0);
      tbt_tag_en_i                      : in std_logic := '0';
      tbt_tag_desync_cnt_rst_i          : in std_logic := '0';
      tbt_tag_desync_cnt_o              : out std_logic_vector(g_tbt_tag_desync_cnt_width-1 downto 0);
      tbt_decim_mask_en_i               : in std_logic := '0';
      tbt_decim_mask_num_samples_beg_i  : in unsigned(g_tbt_cic_mask_samples_width-1 downto 0) := (others => '0');
      tbt_decim_mask_num_samples_end_i  : in unsigned(g_tbt_cic_mask_samples_width-1 downto 0) := (others => '0');
      tbt_decim_ch0_i_o  : out std_logic_vector(g_tbt_decim_width-1 downto 0);
      tbt_decim_ch0_q_o  : out std_logic_vector(g_tbt_decim_width-1 downto 0);
      tbt_decim_ch1_i_o  : out std_logic_vector(g_tbt_decim_width-1 downto 0);
      tbt_decim_ch1_q_o  : out std_logic_vector(g_tbt_decim_width-1 downto 0);
      tbt_decim_ch2_i_o  : out std_logic_vector(g_tbt_decim_width-1 downto 0);
      tbt_decim_ch2_q_o  : out std_logic_vector(g_tbt_decim_width-1 downto 0);
      tbt_decim_ch3_i_o  : out std_logic_vector(g_tbt_decim_width-1 downto 0);
      tbt_decim_ch3_q_o  : out std_logic_vector(g_tbt_decim_width-1 downto 0);
      tbt_decim_valid_o  : out std_logic;
      tbt_decim_ce_o     : out std_logic;
      tbt_amp_ch0_o      : out std_logic_vector(g_tbt_decim_width-1 downto 0);
      tbt_amp_ch1_o      : out std_logic_vector(g_tbt_decim_width-1 downto 0);
      tbt_amp_ch2_o      : out std_logic_vector(g_tbt_decim_width-1 downto 0);
      tbt_amp_ch3_o      : out std_logic_vector(g_tbt_decim_width-1 downto 0);
      tbt_amp_valid_o    : out std_logic;
      tbt_amp_ce_o       : out std_logic;
      tbt_pha_ch0_o      : out std_logic_vector(g_tbt_decim_width-1 downto 0);
      tbt_pha_ch1_o      : out std_logic_vector(g_tbt_decim_width-1 downto 0);
      tbt_pha_ch2_o      : out std_logic_vector(g_tbt_decim_width-1 downto 0);
      tbt_pha_ch3_o      : out std_logic_vector(g_tbt_decim_width-1 downto 0);
      tbt_pha_valid_o    : out std_logic;
      tbt_pha_ce_o       : out std_logic;
      fofb_decim_desync_cnt_rst_i  : in std_logic := '0';
      fofb_decim_desync_cnt_o      : out std_logic_vector(g_fofb_decim_desync_cnt_width-1 downto 0);
      fofb_decim_mask_en_i : in std_logic := '0';
      fofb_decim_mask_num_samples_i : in unsigned(g_fofb_cic_mask_samples_width-1 downto 0) := (others => '0');
      fofb_decim_ch0_i_o : out std_logic_vector(g_fofb_decim_width-1 downto 0);
      fofb_decim_ch0_q_o : out std_logic_vector(g_fofb_decim_width-1 downto 0);
      fofb_decim_ch1_i_o : out std_logic_vector(g_fofb_decim_width-1 downto 0);
      fofb_decim_ch1_q_o : out std_logic_vector(g_fofb_decim_width-1 downto 0);
      fofb_decim_ch2_i_o : out std_logic_vector(g_fofb_decim_width-1 downto 0);
      fofb_decim_ch2_q_o : out std_logic_vector(g_fofb_decim_width-1 downto 0);
      fofb_decim_ch3_i_o : out std_logic_vector(g_fofb_decim_width-1 downto 0);
      fofb_decim_ch3_q_o : out std_logic_vector(g_fofb_decim_width-1 downto 0);
      fofb_decim_valid_o : out std_logic;
      fofb_decim_ce_o    : out std_logic;
      fofb_amp_ch0_o     : out std_logic_vector(g_fofb_decim_width-1 downto 0);
      fofb_amp_ch1_o     : out std_logic_vector(g_fofb_decim_width-1 downto 0);
      fofb_amp_ch2_o     : out std_logic_vector(g_fofb_decim_width-1 downto 0);
      fofb_amp_ch3_o     : out std_logic_vector(g_fofb_decim_width-1 downto 0);
      fofb_amp_valid_o   : out std_logic;
      fofb_amp_ce_o      : out std_logic;
      fofb_pha_ch0_o     : out std_logic_vector(g_fofb_decim_width-1 downto 0);
      fofb_pha_ch1_o     : out std_logic_vector(g_fofb_decim_width-1 downto 0);
      fofb_pha_ch2_o     : out std_logic_vector(g_fofb_decim_width-1 downto 0);
      fofb_pha_ch3_o     : out std_logic_vector(g_fofb_decim_width-1 downto 0);
      fofb_pha_valid_o   : out std_logic;
      fofb_pha_ce_o      : out std_logic;
      monit1_amp_ch0_o   : out std_logic_vector(g_monit_decim_width-1 downto 0);
      monit1_amp_ch1_o   : out std_logic_vector(g_monit_decim_width-1 downto 0);
      monit1_amp_ch2_o   : out std_logic_vector(g_monit_decim_width-1 downto 0);
      monit1_amp_ch3_o   : out std_logic_vector(g_monit_decim_width-1 downto 0);
      monit1_amp_valid_o : out std_logic;
      monit1_amp_ce_o    : out std_logic;
      monit_amp_ch0_o    : out std_logic_vector(g_monit_decim_width-1 downto 0);
      monit_amp_ch1_o    : out std_logic_vector(g_monit_decim_width-1 downto 0);
      monit_amp_ch2_o    : out std_logic_vector(g_monit_decim_width-1 downto 0);
      monit_amp_ch3_o    : out std_logic_vector(g_monit_decim_width-1 downto 0);
      monit_amp_valid_o  : out std_logic;
      monit_amp_ce_o     : out std_logic;
      tbt_pos_x_o        : out std_logic_vector(g_tbt_decim_width-1 downto 0);
      tbt_pos_y_o        : out std_logic_vector(g_tbt_decim_width-1 downto 0);
      tbt_pos_q_o        : out std_logic_vector(g_tbt_decim_width-1 downto 0);
      tbt_pos_sum_o      : out std_logic_vector(g_tbt_decim_width-1 downto 0);
      tbt_pos_valid_o    : out std_logic;
      tbt_pos_ce_o       : out std_logic;
      fofb_pos_x_o       : out std_logic_vector(g_fofb_decim_width-1 downto 0);
      fofb_pos_y_o       : out std_logic_vector(g_fofb_decim_width-1 downto 0);
      fofb_pos_q_o       : out std_logic_vector(g_fofb_decim_width-1 downto 0);
      fofb_pos_sum_o     : out std_logic_vector(g_fofb_decim_width-1 downto 0);
      fofb_pos_valid_o   : out std_logic;
      fofb_pos_ce_o      : out std_logic;
      monit1_pos_x_o     : out std_logic_vector(g_monit_decim_width-1 downto 0);
      monit1_pos_y_o     : out std_logic_vector(g_monit_decim_width-1 downto 0);
      monit1_pos_q_o     : out std_logic_vector(g_monit_decim_width-1 downto 0);
      monit1_pos_sum_o   : out std_logic_vector(g_monit_decim_width-1 downto 0);
      monit1_pos_valid_o : out std_logic;
      monit1_pos_ce_o    : out std_logic;
      monit_pos_x_o      : out std_logic_vector(g_monit_decim_width-1 downto 0);
      monit_pos_y_o      : out std_logic_vector(g_monit_decim_width-1 downto 0);
      monit_pos_q_o      : out std_logic_vector(g_monit_decim_width-1 downto 0);
      monit_pos_sum_o    : out std_logic_vector(g_monit_decim_width-1 downto 0);
      monit_pos_valid_o  : out std_logic;
      monit_pos_ce_o     : out std_logic);
  end component position_calc;

  component swap_freqgen
  generic(
    g_delay_vec_width                       : natural := 8;
    g_swap_div_freq_vec_width               : natural := 16
  );
  port(
    clk_i                                   : in  std_logic;
    rst_n_i                                 : in  std_logic;

    sync_trig_i                             : in  std_logic;

    -- Swap and de-swap signals
    swap_o                                  : out std_logic;
    deswap_o                                : out std_logic;

    -- Swap mode setting
    swap_mode_i                             : in  t_swap_mode;

    -- Swap frequency settings
    swap_div_f_i                            : in  std_logic_vector(g_swap_div_freq_vec_width-1 downto 0);

    -- De-swap delay setting
    deswap_delay_i                          : in  std_logic_vector(g_delay_vec_width-1 downto 0)
  );
  end component;

  component deswap_channels
  generic(
    g_ch_width  : natural := 16
  );
  port(
    clk_i       : in   std_logic;
    rst_n_i     : in   std_logic;

    deswap_i    : in   std_logic;

    ch1_i       : in   std_logic_vector(g_ch_width-1 downto 0);
    ch2_i       : in   std_logic_vector(g_ch_width-1 downto 0);
    ch_valid_i  : in   std_logic;

    ch1_o       : out  std_logic_vector(g_ch_width-1 downto 0);
    ch2_o       : out  std_logic_vector(g_ch_width-1 downto 0);
    deswap_o    : out std_logic;
    ch_valid_o  : out  std_logic
  );
  end component;

  component swmode_sel
  port(
    clk_i                                     :    in  std_logic;
    rst_n_i                                   :    in  std_logic;

    -- Swap master clock
    clk_swap_i                                :    in  std_logic;

    -- Swap and de-swap signals
    swap_o                                    :    out std_logic;
    deswap_o                                  :    out std_logic;

    -- Swap mode setting
    swap_mode_i                               :    in  t_swap_mode
  );
  end component;

  component bpm_swap
    generic(
      g_delay_vec_width         : natural := 8;
      g_swap_div_freq_vec_width : natural := 16;
      g_ch_width                : natural := 16
    );
    port(
      clk_i             : in  std_logic;
      rst_n_i           : in  std_logic;

      -- Input data from ADCs
      cha_i             : in  std_logic_vector(g_ch_width-1 downto 0);
      chb_i             : in  std_logic_vector(g_ch_width-1 downto 0);
      chc_i             : in  std_logic_vector(g_ch_width-1 downto 0);
      chd_i             : in  std_logic_vector(g_ch_width-1 downto 0);
      ch_valid_i        : in  std_logic;

      -- Output data to BPM DSP chain
      cha_o             : out std_logic_vector(g_ch_width-1 downto 0);
      chb_o             : out std_logic_vector(g_ch_width-1 downto 0);
      chc_o             : out std_logic_vector(g_ch_width-1 downto 0);
      chd_o             : out std_logic_vector(g_ch_width-1 downto 0);
      ch_tag_o          : out std_logic_vector(0 downto 0);
      ch_valid_o        : out std_logic;

      -- RFFE swap clock (or switchwing clock)
      rffe_swclk_o      : out std_logic;

      -- RFFE swap clock synchronization trigger
      sync_trig_i       : in std_logic;

      -- Swap mode setting
      swap_mode_i       : in  std_logic_vector(1 downto 0);

      -- Swap frequency settings
      swap_div_f_i      : in  std_logic_vector(g_swap_div_freq_vec_width-1 downto 0);

      -- De-swap delay setting
      deswap_delay_i    : in  std_logic_vector(g_delay_vec_width-1 downto 0)
    );
  end component;

  component wb_bpm_swap is
    generic
    (
      g_interface_mode          : t_wishbone_interface_mode      := CLASSIC;
      g_address_granularity     : t_wishbone_address_granularity := WORD;
      g_delay_vec_width         : natural := 8;
      g_swap_div_freq_vec_width : natural := 16;
      g_ch_width                : natural := 16
    );
    port
    (
      rst_n_i         : in std_logic;
      clk_sys_i       : in std_logic;
      fs_rst_n_i      : in std_logic;
      fs_clk_i        : in std_logic;

      -----------------------------
      -- Wishbone signals
      -----------------------------
      wb_adr_i        : in  std_logic_vector(c_wishbone_address_width-1 downto 0) := (others => '0');
      wb_dat_i        : in  std_logic_vector(c_wishbone_data_width-1 downto 0) := (others => '0');
      wb_dat_o        : out std_logic_vector(c_wishbone_data_width-1 downto 0);
      wb_sel_i        : in  std_logic_vector(c_wishbone_data_width/8-1 downto 0) := (others => '0');
      wb_we_i         : in  std_logic := '0';
      wb_cyc_i        : in  std_logic := '0';
      wb_stb_i        : in  std_logic := '0';
      wb_ack_o        : out std_logic;
      wb_stall_o      : out std_logic;

      -----------------------------
      -- External ports
      -----------------------------
      -- Input data from ADCs
      cha_i           : in  std_logic_vector(g_ch_width-1 downto 0);
      chb_i           : in  std_logic_vector(g_ch_width-1 downto 0);
      chc_i           : in  std_logic_vector(g_ch_width-1 downto 0);
      chd_i           : in  std_logic_vector(g_ch_width-1 downto 0);
      ch_valid_i      : in  std_logic;

      -- Output data to BPM DSP chain
      cha_o           : out std_logic_vector(g_ch_width-1 downto 0);
      chb_o           : out std_logic_vector(g_ch_width-1 downto 0);
      chc_o           : out std_logic_vector(g_ch_width-1 downto 0);
      chd_o           : out std_logic_vector(g_ch_width-1 downto 0);
      ch_tag_o        : out std_logic_vector(0 downto 0);
      ch_valid_o      : out std_logic;

      -- RFFE swap clock (or switchwing clock)
      rffe_swclk_o    : out std_logic;

      -- RFFE swap clock synchronization trigger
      sync_trig_i     : in std_logic

    );
  end component wb_bpm_swap;

  component xwb_bpm_swap
    generic
    (
      g_interface_mode      : t_wishbone_interface_mode      := CLASSIC;
      g_address_granularity : t_wishbone_address_granularity := WORD;
      g_ch_width            : natural := 16
    );
    port
    (
      rst_n_i         : in std_logic;
      clk_sys_i       : in std_logic;
      fs_rst_n_i      : in std_logic;
      fs_clk_i        : in std_logic;

      -----------------------------
      -- Wishbone signals
      -----------------------------
      wb_slv_i        : in t_wishbone_slave_in;
      wb_slv_o        : out t_wishbone_slave_out;

      -----------------------------
      -- External ports
      -----------------------------
      -- Input data from ADCs
      cha_i           : in  std_logic_vector(g_ch_width-1 downto 0);
      chb_i           : in  std_logic_vector(g_ch_width-1 downto 0);
      chc_i           : in  std_logic_vector(g_ch_width-1 downto 0);
      chd_i           : in  std_logic_vector(g_ch_width-1 downto 0);
      ch_valid_i      : in  std_logic;

      -- Output data to BPM DSP chain
      cha_o           : out std_logic_vector(g_ch_width-1 downto 0);
      chb_o           : out std_logic_vector(g_ch_width-1 downto 0);
      chc_o           : out std_logic_vector(g_ch_width-1 downto 0);
      chd_o           : out std_logic_vector(g_ch_width-1 downto 0);
      ch_tag_o        : out std_logic_vector(0 downto 0);
      ch_valid_o      : out std_logic;

      -- RFFE swap clock (or switchwing clock)
      rffe_swclk_o    : out std_logic;

      -- RFFE swap clock synchronization trigger
      sync_trig_i     : in std_logic

    );
  end component;

  component position_calc_cdc_fifo is
    generic (
      g_data_width : natural;
      g_size       : natural);
    port (
      clk_wr_i : in  std_logic;
      data_i   : in  std_logic_vector(g_data_width-1 downto 0);
      valid_i  : in  std_logic;
      clk_rd_i : in  std_logic;
      data_o   : out std_logic_vector(g_data_width-1 downto 0);
      valid_o  : out std_logic);
  end component position_calc_cdc_fifo;

  component wb_position_calc_core
    generic
      (
        g_interface_mode      : t_wishbone_interface_mode      := CLASSIC;
        g_address_granularity : t_wishbone_address_granularity := WORD;
        g_with_extra_wb_reg   : boolean                        := false;
        g_rffe_version        : string                         := "V2";

        -- selection of position_calc stages
        g_with_downconv  : boolean  := true;

        -- input sizes
        g_input_width : natural := 16;
        g_mixed_width : natural := 16;
        g_adc_ratio   : natural := 1;

        -- mixer
        g_dds_width  : natural := 16;
        g_dds_points : natural := 35;
        g_sin_file   : string  := "../../../dsp-cores/hdl/modules/position_nosysgen/dds_sin.nif";
        g_cos_file   : string  := "../../../dsp-cores/hdl/modules/position_nosysgen/dds_cos.nif";

        -- CIC setup
        g_tbt_cic_delay   : natural := 1;
        g_tbt_cic_stages  : natural := 2;
        g_tbt_ratio       : natural := 35;  -- ratio between
        g_tbt_decim_width : natural := 32;

        g_fofb_cic_delay   : natural := 1;
        g_fofb_cic_stages  : natural := 2;
        g_fofb_ratio       : natural := 980;  -- ratio between adc and fofb rates
        g_fofb_decim_width : natural := 32;

        g_monit1_cic_delay  : natural := 1;
        g_monit1_cic_stages : natural := 1;
        g_monit1_ratio      : natural := 100;  --ratio between fofb and monit 1
        g_monit1_cic_ratio  : positive := 8;

        g_monit2_cic_delay  : natural := 1;
        g_monit2_cic_stages : natural := 1;
        g_monit2_ratio      : natural := 100;  -- ratio between monit 1 and 2
        g_monit2_cic_ratio  : positive := 8;

        g_monit_decim_width : natural := 32;

        -- Cordic setup
        g_tbt_cordic_stages       : positive := 12;
        g_tbt_cordic_iter_per_clk : positive := 3;
        g_tbt_cordic_ratio        : positive := 4;

        g_fofb_cordic_stages       : positive := 15;
        g_fofb_cordic_iter_per_clk : positive := 3;
        g_fofb_cordic_ratio        : positive := 4;

        -- width of K constants
        g_k_width : natural := 24;

        --width for IQ output
        g_IQ_width : natural := 32;

        -- Swap/de-swap setup
        g_delay_vec_width         : natural := 8;
        g_swap_div_freq_vec_width : natural := 16
        );
    port
      (
        rst_n_i      : in std_logic;
        clk_i        : in std_logic;    -- Wishbone clock
        fs_rst_n_i   : in std_logic;    -- FS reset
        fs_rst2x_n_i : in std_logic;    -- FS 2x reset
        fs_clk_i     : in std_logic;  -- clock period = 8.8823218389287 ns (112.583175675676 Mhz)
        fs_clk2x_i   : in std_logic;  -- clock period = 4.4411609194644 ns (225.166351351351 Mhz)

        -----------------------------
        -- Wishbone signals
        -----------------------------

        wb_adr_i   : in  std_logic_vector(c_wishbone_address_width-1 downto 0) := (others => '0');
        wb_dat_i   : in  std_logic_vector(c_wishbone_data_width-1 downto 0)    := (others => '0');
        wb_dat_o   : out std_logic_vector(c_wishbone_data_width-1 downto 0);
        wb_sel_i   : in  std_logic_vector(c_wishbone_data_width/8-1 downto 0)  := (others => '0');
        wb_we_i    : in  std_logic                                             := '0';
        wb_cyc_i   : in  std_logic                                             := '0';
        wb_stb_i   : in  std_logic                                             := '0';
        wb_ack_o   : out std_logic;
        wb_stall_o : out std_logic;

        -----------------------------
        -- Raw ADC signals
        -----------------------------

        adc_ch0_i : in std_logic_vector(g_input_width-1 downto 0);
        adc_ch1_i : in std_logic_vector(g_input_width-1 downto 0);
        adc_ch2_i : in std_logic_vector(g_input_width-1 downto 0);
        adc_ch3_i : in std_logic_vector(g_input_width-1 downto 0);
        adc_valid_i : in std_logic;

        -----------------------------
        -- Position calculation at various rates
        -----------------------------

        adc_ch0_swap_o   : out std_logic_vector(g_input_width-1 downto 0);
        adc_ch1_swap_o   : out std_logic_vector(g_input_width-1 downto 0);
        adc_ch2_swap_o   : out std_logic_vector(g_input_width-1 downto 0);
        adc_ch3_swap_o   : out std_logic_vector(g_input_width-1 downto 0);
        adc_tag_o        : out std_logic_vector(0 downto 0);
        adc_swap_valid_o : out std_logic;

        -----------------------------
        -- MIX Data
        -----------------------------

        mix_ch0_i_o : out std_logic_vector(g_IQ_width-1 downto 0);
        mix_ch0_q_o : out std_logic_vector(g_IQ_width-1 downto 0);
        mix_ch1_i_o : out std_logic_vector(g_IQ_width-1 downto 0);
        mix_ch1_q_o : out std_logic_vector(g_IQ_width-1 downto 0);
        mix_ch2_i_o : out std_logic_vector(g_IQ_width-1 downto 0);
        mix_ch2_q_o : out std_logic_vector(g_IQ_width-1 downto 0);
        mix_ch3_i_o : out std_logic_vector(g_IQ_width-1 downto 0);
        mix_ch3_q_o : out std_logic_vector(g_IQ_width-1 downto 0);
        mix_valid_o : out std_logic;

        -----------------------------
        -- TBT Data
        -----------------------------

        tbt_decim_ch0_i_o : out std_logic_vector(g_tbt_decim_width-1 downto 0);
        tbt_decim_ch0_q_o : out std_logic_vector(g_tbt_decim_width-1 downto 0);
        tbt_decim_ch1_i_o : out std_logic_vector(g_tbt_decim_width-1 downto 0);
        tbt_decim_ch1_q_o : out std_logic_vector(g_tbt_decim_width-1 downto 0);
        tbt_decim_ch2_i_o : out std_logic_vector(g_tbt_decim_width-1 downto 0);
        tbt_decim_ch2_q_o : out std_logic_vector(g_tbt_decim_width-1 downto 0);
        tbt_decim_ch3_i_o : out std_logic_vector(g_tbt_decim_width-1 downto 0);
        tbt_decim_ch3_q_o : out std_logic_vector(g_tbt_decim_width-1 downto 0);
        tbt_decim_valid_o : out std_logic;

        tbt_amp_ch0_o   : out std_logic_vector(g_tbt_decim_width-1 downto 0);
        tbt_amp_ch1_o   : out std_logic_vector(g_tbt_decim_width-1 downto 0);
        tbt_amp_ch2_o   : out std_logic_vector(g_tbt_decim_width-1 downto 0);
        tbt_amp_ch3_o   : out std_logic_vector(g_tbt_decim_width-1 downto 0);
        tbt_amp_valid_o : out std_logic;

        tbt_pha_ch0_o   : out std_logic_vector(g_tbt_decim_width-1 downto 0);
        tbt_pha_ch1_o   : out std_logic_vector(g_tbt_decim_width-1 downto 0);
        tbt_pha_ch2_o   : out std_logic_vector(g_tbt_decim_width-1 downto 0);
        tbt_pha_ch3_o   : out std_logic_vector(g_tbt_decim_width-1 downto 0);
        tbt_pha_valid_o : out std_logic;

        -----------------------------
        -- FOFB Data
        -----------------------------

        fofb_decim_ch0_i_o : out std_logic_vector(g_fofb_decim_width-1 downto 0);
        fofb_decim_ch0_q_o : out std_logic_vector(g_fofb_decim_width-1 downto 0);
        fofb_decim_ch1_i_o : out std_logic_vector(g_fofb_decim_width-1 downto 0);
        fofb_decim_ch1_q_o : out std_logic_vector(g_fofb_decim_width-1 downto 0);
        fofb_decim_ch2_i_o : out std_logic_vector(g_fofb_decim_width-1 downto 0);
        fofb_decim_ch2_q_o : out std_logic_vector(g_fofb_decim_width-1 downto 0);
        fofb_decim_ch3_i_o : out std_logic_vector(g_fofb_decim_width-1 downto 0);
        fofb_decim_ch3_q_o : out std_logic_vector(g_fofb_decim_width-1 downto 0);
        fofb_decim_valid_o : out std_logic;

        fofb_amp_ch0_o   : out std_logic_vector(g_fofb_decim_width-1 downto 0);
        fofb_amp_ch1_o   : out std_logic_vector(g_fofb_decim_width-1 downto 0);
        fofb_amp_ch2_o   : out std_logic_vector(g_fofb_decim_width-1 downto 0);
        fofb_amp_ch3_o   : out std_logic_vector(g_fofb_decim_width-1 downto 0);
        fofb_amp_valid_o : out std_logic;

        fofb_pha_ch0_o   : out std_logic_vector(g_fofb_decim_width-1 downto 0);
        fofb_pha_ch1_o   : out std_logic_vector(g_fofb_decim_width-1 downto 0);
        fofb_pha_ch2_o   : out std_logic_vector(g_fofb_decim_width-1 downto 0);
        fofb_pha_ch3_o   : out std_logic_vector(g_fofb_decim_width-1 downto 0);
        fofb_pha_valid_o : out std_logic;

        -----------------------------
        -- Monit. Data
        -----------------------------

        monit1_amp_ch0_o    : out std_logic_vector(g_monit_decim_width-1 downto 0);
        monit1_amp_ch1_o    : out std_logic_vector(g_monit_decim_width-1 downto 0);
        monit1_amp_ch2_o    : out std_logic_vector(g_monit_decim_width-1 downto 0);
        monit1_amp_ch3_o    : out std_logic_vector(g_monit_decim_width-1 downto 0);
        monit1_amp_valid_o  : out std_logic;

        monit_amp_ch0_o   : out std_logic_vector(g_monit_decim_width-1 downto 0);
        monit_amp_ch1_o   : out std_logic_vector(g_monit_decim_width-1 downto 0);
        monit_amp_ch2_o   : out std_logic_vector(g_monit_decim_width-1 downto 0);
        monit_amp_ch3_o   : out std_logic_vector(g_monit_decim_width-1 downto 0);
        monit_amp_valid_o : out std_logic;

        -----------------------------
        -- Position Data
        -----------------------------

        tbt_pos_x_o     : out std_logic_vector(g_tbt_decim_width-1 downto 0);
        tbt_pos_y_o     : out std_logic_vector(g_tbt_decim_width-1 downto 0);
        tbt_pos_q_o     : out std_logic_vector(g_tbt_decim_width-1 downto 0);
        tbt_pos_sum_o   : out std_logic_vector(g_tbt_decim_width-1 downto 0);
        tbt_pos_valid_o : out std_logic;

        fofb_pos_x_o     : out std_logic_vector(g_fofb_decim_width-1 downto 0);
        fofb_pos_y_o     : out std_logic_vector(g_fofb_decim_width-1 downto 0);
        fofb_pos_q_o     : out std_logic_vector(g_fofb_decim_width-1 downto 0);
        fofb_pos_sum_o   : out std_logic_vector(g_fofb_decim_width-1 downto 0);
        fofb_pos_valid_o : out std_logic;

        monit1_pos_x_o      : out std_logic_vector(g_monit_decim_width-1 downto 0);
        monit1_pos_y_o      : out std_logic_vector(g_monit_decim_width-1 downto 0);
        monit1_pos_q_o      : out std_logic_vector(g_monit_decim_width-1 downto 0);
        monit1_pos_sum_o    : out std_logic_vector(g_monit_decim_width-1 downto 0);
        monit1_pos_valid_o  : out std_logic;

        monit_pos_x_o     : out std_logic_vector(g_monit_decim_width-1 downto 0);
        monit_pos_y_o     : out std_logic_vector(g_monit_decim_width-1 downto 0);
        monit_pos_q_o     : out std_logic_vector(g_monit_decim_width-1 downto 0);
        monit_pos_sum_o   : out std_logic_vector(g_monit_decim_width-1 downto 0);
        monit_pos_valid_o : out std_logic;

        -----------------------------
        -- Output to RFFE board
        -----------------------------

        rffe_swclk_o : out std_logic;

        -----------------------------
        -- Synchronization trigger for RFFE swap clock
        -----------------------------

        sync_trig_i  : in std_logic;

        -----------------------------
        -- Synchronization trigger for TBT Filter Chain
        -----------------------------

        sync_tbt_trig_i                           : in std_logic := '0';

        -----------------------------
        -- Debug signals
        -----------------------------

        dbg_cur_address_o  : out std_logic_vector(31 downto 0);
        dbg_adc_ch0_cond_o : out std_logic_vector(g_input_width-1 downto 0);
        dbg_adc_ch1_cond_o : out std_logic_vector(g_input_width-1 downto 0);
        dbg_adc_ch2_cond_o : out std_logic_vector(g_input_width-1 downto 0);
        dbg_adc_ch3_cond_o : out std_logic_vector(g_input_width-1 downto 0)
        );
  end component;

  component xwb_position_calc_core
    generic
      (
        g_interface_mode      : t_wishbone_interface_mode      := CLASSIC;
        g_address_granularity : t_wishbone_address_granularity := WORD;
        g_with_extra_wb_reg   : boolean                        := false;
        g_rffe_version        : string                         := "V2";

        -- selection of position_calc stages
        g_with_downconv  : boolean  := true;

        -- input sizes
        g_input_width : natural := 16;
        g_mixed_width : natural := 16;
        g_adc_ratio   : natural := 1;

        -- mixer
        g_dds_width  : natural := 16;
        g_dds_points : natural := 35;
        g_sin_file   : string  := "../../../dsp-cores/hdl/modules/position_nosysgen/dds_sin.nif";
        g_cos_file   : string  := "../../../dsp-cores/hdl/modules/position_nosysgen/dds_cos.nif";

        -- CIC setup
        g_tbt_cic_delay   : natural := 1;
        g_tbt_cic_stages  : natural := 2;
        g_tbt_ratio       : natural := 35;  -- ratio between
        g_tbt_decim_width : natural := 32;

        g_fofb_cic_delay   : natural := 1;
        g_fofb_cic_stages  : natural := 2;
        g_fofb_ratio       : natural := 980;  -- ratio between adc and fofb rates
        g_fofb_decim_width : natural := 32;

        g_monit1_cic_delay  : natural := 1;
        g_monit1_cic_stages : natural := 1;
        g_monit1_ratio      : natural := 100;  --ratio between fofb and monit 1
        g_monit1_cic_ratio  : positive := 8;

        g_monit2_cic_delay  : natural := 1;
        g_monit2_cic_stages : natural := 1;
        g_monit2_ratio      : natural := 100;  -- ratio between monit 1 and 2
        g_monit2_cic_ratio  : positive := 8;

        -- Cordic setup
        g_tbt_cordic_stages       : positive := 12;
        g_tbt_cordic_iter_per_clk : positive := 3;
        g_tbt_cordic_ratio        : positive := 4;

        g_fofb_cordic_stages       : positive := 15;
        g_fofb_cordic_iter_per_clk : positive := 3;
        g_fofb_cordic_ratio        : positive := 4;

        g_monit_decim_width : natural := 32;

        -- width of K constants
        g_k_width : natural := 24;

        --width for IQ output
        g_IQ_width : natural := 32;

        -- Swap/de-swap setup
        g_delay_vec_width         : natural := 8;
        g_swap_div_freq_vec_width : natural := 16
        );
    port
      (
        rst_n_i      : in std_logic;
        clk_i        : in std_logic;    -- Wishbone clock
        fs_rst_n_i   : in std_logic;    -- FS reset
        fs_rst2x_n_i : in std_logic;    -- FS 2x reset
        fs_clk_i     : in std_logic;  -- clock period = 8.8823218389287 ns (112.583175675676 Mhz)
        fs_clk2x_i   : in std_logic;  -- clock period = 4.4411609194644 ns (225.166351351351 Mhz)

        -----------------------------
        -- Wishbone signals
        -----------------------------
        wb_slv_i : in  t_wishbone_slave_in;
        wb_slv_o : out t_wishbone_slave_out;

        -----------------------------
        -- Raw ADC signals
        -----------------------------

        adc_ch0_i : in std_logic_vector(g_input_width-1 downto 0);
        adc_ch1_i : in std_logic_vector(g_input_width-1 downto 0);
        adc_ch2_i : in std_logic_vector(g_input_width-1 downto 0);
        adc_ch3_i : in std_logic_vector(g_input_width-1 downto 0);
        adc_valid_i : in std_logic;

        -----------------------------
        -- Position calculation at various rates
        -----------------------------

        adc_ch0_swap_o   : out std_logic_vector(g_input_width-1 downto 0);
        adc_ch1_swap_o   : out std_logic_vector(g_input_width-1 downto 0);
        adc_ch2_swap_o   : out std_logic_vector(g_input_width-1 downto 0);
        adc_ch3_swap_o   : out std_logic_vector(g_input_width-1 downto 0);
        adc_tag_o        : out std_logic_vector(0 downto 0);
        adc_swap_valid_o : out std_logic;

        -----------------------------
        -- MIX Data
        -----------------------------

        mix_ch0_i_o : out std_logic_vector(g_IQ_width-1 downto 0);
        mix_ch0_q_o : out std_logic_vector(g_IQ_width-1 downto 0);
        mix_ch1_i_o : out std_logic_vector(g_IQ_width-1 downto 0);
        mix_ch1_q_o : out std_logic_vector(g_IQ_width-1 downto 0);
        mix_ch2_i_o : out std_logic_vector(g_IQ_width-1 downto 0);
        mix_ch2_q_o : out std_logic_vector(g_IQ_width-1 downto 0);
        mix_ch3_i_o : out std_logic_vector(g_IQ_width-1 downto 0);
        mix_ch3_q_o : out std_logic_vector(g_IQ_width-1 downto 0);
        mix_valid_o : out std_logic;

        -----------------------------
        -- TBT Data
        -----------------------------

        tbt_decim_ch0_i_o : out std_logic_vector(g_tbt_decim_width-1 downto 0);
        tbt_decim_ch0_q_o : out std_logic_vector(g_tbt_decim_width-1 downto 0);
        tbt_decim_ch1_i_o : out std_logic_vector(g_tbt_decim_width-1 downto 0);
        tbt_decim_ch1_q_o : out std_logic_vector(g_tbt_decim_width-1 downto 0);
        tbt_decim_ch2_i_o : out std_logic_vector(g_tbt_decim_width-1 downto 0);
        tbt_decim_ch2_q_o : out std_logic_vector(g_tbt_decim_width-1 downto 0);
        tbt_decim_ch3_i_o : out std_logic_vector(g_tbt_decim_width-1 downto 0);
        tbt_decim_ch3_q_o : out std_logic_vector(g_tbt_decim_width-1 downto 0);
        tbt_decim_valid_o : out std_logic;

        tbt_amp_ch0_o   : out std_logic_vector(g_tbt_decim_width-1 downto 0);
        tbt_amp_ch1_o   : out std_logic_vector(g_tbt_decim_width-1 downto 0);
        tbt_amp_ch2_o   : out std_logic_vector(g_tbt_decim_width-1 downto 0);
        tbt_amp_ch3_o   : out std_logic_vector(g_tbt_decim_width-1 downto 0);
        tbt_amp_valid_o : out std_logic;

        tbt_pha_ch0_o   : out std_logic_vector(g_tbt_decim_width-1 downto 0);
        tbt_pha_ch1_o   : out std_logic_vector(g_tbt_decim_width-1 downto 0);
        tbt_pha_ch2_o   : out std_logic_vector(g_tbt_decim_width-1 downto 0);
        tbt_pha_ch3_o   : out std_logic_vector(g_tbt_decim_width-1 downto 0);
        tbt_pha_valid_o : out std_logic;

        -----------------------------
        -- FOFB Data
        -----------------------------

        fofb_decim_ch0_i_o : out std_logic_vector(g_fofb_decim_width-1 downto 0);
        fofb_decim_ch0_q_o : out std_logic_vector(g_fofb_decim_width-1 downto 0);
        fofb_decim_ch1_i_o : out std_logic_vector(g_fofb_decim_width-1 downto 0);
        fofb_decim_ch1_q_o : out std_logic_vector(g_fofb_decim_width-1 downto 0);
        fofb_decim_ch2_i_o : out std_logic_vector(g_fofb_decim_width-1 downto 0);
        fofb_decim_ch2_q_o : out std_logic_vector(g_fofb_decim_width-1 downto 0);
        fofb_decim_ch3_i_o : out std_logic_vector(g_fofb_decim_width-1 downto 0);
        fofb_decim_ch3_q_o : out std_logic_vector(g_fofb_decim_width-1 downto 0);
        fofb_decim_valid_o : out std_logic;

        fofb_amp_ch0_o   : out std_logic_vector(g_fofb_decim_width-1 downto 0);
        fofb_amp_ch1_o   : out std_logic_vector(g_fofb_decim_width-1 downto 0);
        fofb_amp_ch2_o   : out std_logic_vector(g_fofb_decim_width-1 downto 0);
        fofb_amp_ch3_o   : out std_logic_vector(g_fofb_decim_width-1 downto 0);
        fofb_amp_valid_o : out std_logic;

        fofb_pha_ch0_o   : out std_logic_vector(g_fofb_decim_width-1 downto 0);
        fofb_pha_ch1_o   : out std_logic_vector(g_fofb_decim_width-1 downto 0);
        fofb_pha_ch2_o   : out std_logic_vector(g_fofb_decim_width-1 downto 0);
        fofb_pha_ch3_o   : out std_logic_vector(g_fofb_decim_width-1 downto 0);
        fofb_pha_valid_o : out std_logic;

        -----------------------------
        -- Monit. Data
        -----------------------------

        monit1_amp_ch0_o   : out std_logic_vector(g_monit_decim_width-1 downto 0);
        monit1_amp_ch1_o   : out std_logic_vector(g_monit_decim_width-1 downto 0);
        monit1_amp_ch2_o   : out std_logic_vector(g_monit_decim_width-1 downto 0);
        monit1_amp_ch3_o   : out std_logic_vector(g_monit_decim_width-1 downto 0);
        monit1_amp_valid_o : out std_logic;

        monit_amp_ch0_o   : out std_logic_vector(g_monit_decim_width-1 downto 0);
        monit_amp_ch1_o   : out std_logic_vector(g_monit_decim_width-1 downto 0);
        monit_amp_ch2_o   : out std_logic_vector(g_monit_decim_width-1 downto 0);
        monit_amp_ch3_o   : out std_logic_vector(g_monit_decim_width-1 downto 0);
        monit_amp_valid_o : out std_logic;

        -----------------------------
        -- Position Data
        -----------------------------

        tbt_pos_x_o     : out std_logic_vector(g_tbt_decim_width-1 downto 0);
        tbt_pos_y_o     : out std_logic_vector(g_tbt_decim_width-1 downto 0);
        tbt_pos_q_o     : out std_logic_vector(g_tbt_decim_width-1 downto 0);
        tbt_pos_sum_o   : out std_logic_vector(g_tbt_decim_width-1 downto 0);
        tbt_pos_valid_o : out std_logic;

        fofb_pos_x_o     : out std_logic_vector(g_fofb_decim_width-1 downto 0);
        fofb_pos_y_o     : out std_logic_vector(g_fofb_decim_width-1 downto 0);
        fofb_pos_q_o     : out std_logic_vector(g_fofb_decim_width-1 downto 0);
        fofb_pos_sum_o   : out std_logic_vector(g_fofb_decim_width-1 downto 0);
        fofb_pos_valid_o : out std_logic;

        monit1_pos_x_o      : out std_logic_vector(g_monit_decim_width-1 downto 0);
        monit1_pos_y_o      : out std_logic_vector(g_monit_decim_width-1 downto 0);
        monit1_pos_q_o      : out std_logic_vector(g_monit_decim_width-1 downto 0);
        monit1_pos_sum_o    : out std_logic_vector(g_monit_decim_width-1 downto 0);
        monit1_pos_valid_o  : out std_logic;

        monit_pos_x_o     : out std_logic_vector(g_monit_decim_width-1 downto 0);
        monit_pos_y_o     : out std_logic_vector(g_monit_decim_width-1 downto 0);
        monit_pos_q_o     : out std_logic_vector(g_monit_decim_width-1 downto 0);
        monit_pos_sum_o   : out std_logic_vector(g_monit_decim_width-1 downto 0);
        monit_pos_valid_o : out std_logic;

        -----------------------------
        -- Output to RFFE board
        -----------------------------

        rffe_swclk_o : out std_logic;

        -----------------------------
        -- Synchronization trigger for RFFE swap clock
        -----------------------------

        sync_trig_i : in std_logic;

        -----------------------------
        -- Synchronization trigger for TBT Filter Chain
        -----------------------------

        sync_tbt_trig_i                           : in std_logic := '0';

        -----------------------------
        -- Debug signals
        -----------------------------

        dbg_cur_address_o  : out std_logic_vector(31 downto 0);
        dbg_adc_ch0_cond_o : out std_logic_vector(g_input_width-1 downto 0);
        dbg_adc_ch1_cond_o : out std_logic_vector(g_input_width-1 downto 0);
        dbg_adc_ch2_cond_o : out std_logic_vector(g_input_width-1 downto 0);
        dbg_adc_ch3_cond_o : out std_logic_vector(g_input_width-1 downto 0)
        );
  end component;

  component wb_orbit_intlk
  generic
  (
    -- Wishbone
    g_INTERFACE_MODE                           : t_wishbone_interface_mode      := CLASSIC;
    g_ADDRESS_GRANULARITY                      : t_wishbone_address_granularity := WORD;
    g_WITH_EXTRA_WB_REG                        : boolean := false;
    -- Position
    g_ADC_WIDTH                                : natural := 16;
    g_DECIM_WIDTH                              : natural := 32
  );
  port
  (
    -----------------------------
    -- Clocks and resets
    -----------------------------

    rst_n_i                                    : in std_logic;
    clk_i                                      : in std_logic; -- Wishbone clock
    fs_rst_n_i                                 : in std_logic;
    fs_clk_i                                   : in std_logic;

    -----------------------------
    -- Wishbone signals
    -----------------------------

    wb_adr_i                                  : in  std_logic_vector(c_WISHBONE_ADDRESS_WIDTH-1 downto 0) := (others => '0');
    wb_dat_i                                  : in  std_logic_vector(c_WISHBONE_DATA_WIDTH-1 downto 0) := (others => '0');
    wb_dat_o                                  : out std_logic_vector(c_WISHBONE_DATA_WIDTH-1 downto 0);
    wb_sel_i                                  : in  std_logic_vector(c_WISHBONE_DATA_WIDTH/8-1 downto 0) := (others => '0');
    wb_we_i                                   : in  std_logic := '0';
    wb_cyc_i                                  : in  std_logic := '0';
    wb_stb_i                                  : in  std_logic := '0';
    wb_ack_o                                  : out std_logic;
    wb_stall_o                                : out std_logic;

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
  end component;

  component xwb_orbit_intlk
  generic
  (
    -- Wishbone
    g_INTERFACE_MODE                           : t_wishbone_interface_mode      := CLASSIC;
    g_ADDRESS_GRANULARITY                      : t_wishbone_address_granularity := WORD;
    g_WITH_EXTRA_WB_REG                        : boolean := false;
    -- Position
    g_ADC_WIDTH                                : natural := 16;
    g_DECIM_WIDTH                              : natural := 32
  );
  port
  (
    -----------------------------
    -- Clocks and resets
    -----------------------------

    rst_n_i                                    : in std_logic;
    clk_i                                      : in std_logic; -- Wishbone clock
    fs_rst_n_i                                 : in std_logic;
    fs_clk_i                                   : in std_logic;

    -----------------------------
    -- Wishbone signals
    -----------------------------

    wb_slv_i                                   : in t_wishbone_slave_in;
    wb_slv_o                                   : out t_wishbone_slave_out;

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
  end component;

end bpm_cores_pkg;

package body bpm_cores_pkg is

end bpm_cores_pkg;
