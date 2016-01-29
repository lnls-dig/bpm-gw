------------------------------------------------------------------------------
-- Title      : BPM ACQ Flow Control FIFO
------------------------------------------------------------------------------
-- Author     : Lucas Maziero Russo
-- Company    : CNPEM LNLS-DIG
-- Created    : 2013-22-10
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: Module for the performing flow control between DPRAM FSM acquisition
--                and external DDR3 memory
-------------------------------------------------------------------------------
-- Copyright (c) 2013 CNPEM
-- Licensed under GNU Lesser General Public License (LGPL) v3.0
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2013-22-10  1.0      lucas.russo        Created
-- 2014-17-09  2.0      lucas.russo        Add output data aggregation
-------------------------------------------------------------------------------

-- Based on FMC-ADC-100M (http://www.ohwr.org/projects/fmc-adc-100m14b4cha/repository)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
-- Main Wishbone Definitions
use work.wishbone_pkg.all;
-- Genrams cores
use work.genram_pkg.all;
-- Genrams cores
use work.gencores_pkg.all;
-- Acquisition cores
use work.acq_core_pkg.all;
-- DBE common cores
use work.dbe_common_pkg.all;

entity acq_fc_fifo is
generic
(
  g_header_in_width                         : natural := 1;
  g_data_in_width                           : natural := 128;
  g_header_out_width                        : natural := 2;
  g_data_out_width                          : natural := 256;
  g_addr_width                              : natural := 32;
  g_acq_num_channels                        : natural := 1;
  g_acq_channels                            : t_acq_chan_param_array;
  g_fifo_size                               : natural := 64;
  g_fc_pipe_size                            : natural := 4
);
port
(
  fs_clk_i                                  : in  std_logic;
  fs_ce_i                                   : in  std_logic;
  fs_rst_n_i                                : in  std_logic;

  -- DDR3 external clock
  ext_clk_i                                 : in  std_logic;
  ext_rst_n_i                               : in  std_logic;

  -- DPRAM data
  dpram_data_i                              : in std_logic_vector(g_header_in_width+g_data_in_width-1 downto 0);
  dpram_dvalid_i                            : in std_logic;

  -- Passthough data
  pt_data_i                                 : in std_logic_vector(g_data_in_width-1 downto 0);
  pt_data_id_i                              : in std_logic_vector(2 downto 0);
  pt_trig_i                                 : in std_logic;
  pt_dvalid_i                               : in std_logic;
  pt_wr_en_i                                : in std_logic;

  -- Request transaction reset as soon as possible (when all outstanding
  -- transactions have been commited)
  req_rst_trans_i                           : in std_logic;
  -- Select between multi-buffer mode and pass-through mode (data directly
  -- through external module interface)
  passthrough_en_i                          : in std_logic;
  -- which buffer (0 or 1) to store data in. valid only when passthrough_en_i = '0'
  buffer_sel_i                              : in std_logic;

  -- Current channel selection ID
  lmt_curr_chan_id_i                        : in unsigned(c_chan_id_width-1 downto 0);
  -- Size of the pre trigger transaction in g_fifo_size bytes
  lmt_pre_pkt_size_i                        : in unsigned(c_pkt_size_width-1 downto 0);
  -- Size of the post trigger transaction in g_fifo_size bytes
  lmt_pos_pkt_size_i                        : in unsigned(c_pkt_size_width-1 downto 0);
  -- Size of the full transaction in g_fifo_size bytes
  lmt_full_pkt_size_i                       : in unsigned(c_pkt_size_width-1 downto 0);
  -- Number of shots in this acquisition
  lmt_shots_nb_i                            : in unsigned(15 downto 0);
  -- Acquisition limits valid signal. Qualifies lmt_pkt_size_i and lmt_shots_nb_i
  lmt_valid_i                               : in std_logic;

  -- Asserted when all words are transfered to the external memory
  fifo_fc_all_trans_done_p_o                : out std_logic;
  -- Asserted when the Acquisition FIFO is full. Data is lost when this signal is
  -- set and valid data keeps coming
  fifo_fc_full_o                            : out std_logic;

  -- Flow protocol to interface with external SDRAM. Evaluate the use of
  -- Wishbone Streaming protocol.
  fifo_fc_dout_o                            : out std_logic_vector(g_header_out_width+g_data_out_width-1 downto 0);
  fifo_fc_valid_o                           : out std_logic;
  fifo_fc_addr_o                            : out std_logic_vector(g_addr_width-1 downto 0);
  fifo_fc_sof_o                             : out std_logic;
  fifo_fc_eof_o                             : out std_logic;
  fifo_fc_dreq_i                            : in std_logic;
  fifo_fc_stall_i                           : in std_logic;

  dbg_fifo_we_o                             : out std_logic;
  dbg_fifo_wr_count_o                       : out std_logic_vector(f_log2_size(g_fifo_size)-1 downto 0);
  dbg_fifo_re_o                             : out std_logic;
  dbg_fifo_fc_rd_en_o                       : out std_logic;
  dbg_fifo_rd_empty_o                       : out std_logic;
  dbg_fifo_wr_full_o                        : out std_logic;
  dbg_fifo_fc_valid_fwft_o                  : out std_logic;
  dbg_source_pl_dreq_o                      : out std_logic;
  dbg_source_pl_stall_o                     : out std_logic;
  dbg_pkt_ct_cnt_o                          : out std_logic_vector(c_pkt_size_width-1 downto 0);
  dbg_shots_cnt_o                           : out std_logic_vector(c_shots_size_width-1 downto 0)
);
end acq_fc_fifo;

architecture rtl of acq_fc_fifo is

  -- Type declarations
  subtype t_fc_data is std_logic_vector(g_data_in_width+g_header_in_width-1 downto 0);
  type t_fc_data_array is array (natural range <>) of t_fc_data;

  subtype t_fc_data_marsh is std_logic_vector(g_header_out_width+g_data_out_width-1 downto 0);
  type t_fc_data_marsh_array is array (natural range <>) of t_fc_data_marsh;

  subtype t_fc_dvalid is std_logic;
  type t_fc_dvalid_array is array (natural range <>) of std_logic;

  subtype t_fc_data_id is std_logic_vector(2 downto 0);
  type t_fc_data_id_array is array (natural range <>) of t_fc_data_id;

  subtype t_fc_data_oob is std_logic_vector(c_data_oob_width -1 downto 0);
  type t_fc_data_oob_array is array (natural range <>) of t_fc_data_oob;

  subtype t_fc_count is std_logic_vector(f_log2_size(g_fifo_size)-1 downto 0);
  type t_fc_count_array is array (natural range <>) of t_fc_count;

  subtype t_fc_pkt is unsigned(c_pkt_size_width-1 downto 0);
  subtype t_fc_addr is std_logic_vector(g_addr_width-1 downto 0);

  -- Constants
  constant c_fc_data_header_top_idx         : natural := g_header_in_width+g_data_in_width-1;
  constant c_fc_data_header_bot_idx         : natural := g_data_in_width;
  constant c_fc_data_marsh_header_top_idx   : natural := g_header_out_width+g_data_out_width-1;
  constant c_fc_data_marsh_header_bot_idx   : natural := g_data_out_width;

  constant c_narrowest_channel_width        : natural := f_acq_chan_find_narrowest(g_acq_channels);
  constant c_widest_channel_width           : natural := g_header_in_width+g_data_in_width;

  -- Number of FIFOs to store incoming data. We do this, as the ext_clk_i may be
  -- as low as 100 MHz (for Artix7 DDR3 controllers), whereas the fs_clk_i may
  -- be as high as 250 MHz (typically 130 MHz). So, we do a multiple buffer approach,
  -- as the high speed data (ADC data) is 64 bits (16-bits per channel) and the
  -- DDR3 data is 256-bit.
  constant c_num_acq_fifos                  : natural := g_data_out_width/c_narrowest_channel_width;

  constant c_fc_data_zeros                  : t_fc_data := (others => '0');
  constant c_fc_data_array_zeros            : t_fc_data_array(c_num_acq_fifos-1 downto 0) :=
      (others => (c_fc_data_zeros));

  constant c_fc_dvalid_zeros                : t_fc_dvalid := '0';
  constant c_fc_dvalid_array_zeros          : t_fc_dvalid_array(c_num_acq_fifos-1 downto 0) :=
      (others => (c_fc_dvalid_zeros));

  constant c_acq_chan_slice                 : t_acq_chan_slice_array(g_acq_num_channels-1 downto 0) :=
                                                 f_acq_chan_det_slice(g_acq_channels);
  -- g_data_out_width must be bigger than data input width (f_acq_chan_find_widest(g_acq_channels))
  --by at least 2 times. Also, only power of 2 ratio sizes are supported
  constant c_fc_payload_ratio               : t_payld_ratio_array(g_acq_num_channels-1 downto 0) :=
                                                   f_fc_payload_ratio (g_data_out_width,
                                                                c_acq_chan_slice);
  constant c_fc_payload_ratio_log2          : t_payld_ratio_array(g_acq_num_channels-1 downto 0) :=
                                                  f_log2_size_array(c_fc_payload_ratio);

  -- Signals
  signal fifo_fc_din                        : t_fc_data_array(c_num_acq_fifos-1 downto 0);
  signal fifo_fc_dout                       : t_fc_data_array(c_num_acq_fifos-1 downto 0);
  signal fifo_fc_trigger                    : t_fc_dvalid_array(c_num_acq_fifos-1 downto 0);
  signal fifo_fc_data_id                    : t_fc_data_id_array(c_num_acq_fifos-1 downto 0);
  signal fifo_fc_dout_marsh                 : t_fc_data_marsh_array(g_acq_num_channels-1 downto 0);
  signal fifo_fc_wr_en                      : std_logic;
  signal fifo_fc_cnt_en                     : std_logic;
  signal fifo_fc_dpram_wr_en                : std_logic;
  signal fifo_fc_we                         : t_fc_dvalid_array(c_num_acq_fifos-1 downto 0);
  signal fifo_fc_mux_cnt                    : unsigned(f_log2_size(c_num_acq_fifos)-1 downto 0);
  signal fifo_fc_mux_inc                    : std_logic;
  signal fifo_fc_fifo_idx_max               : unsigned(f_log2_size(c_num_acq_fifos)-1 downto 0);
  signal fifo_fc_wr_full                    : t_fc_dvalid_array(c_num_acq_fifos-1 downto 0);
  signal fifo_fc_wr_count                   : t_fc_count_array(c_num_acq_fifos-1 downto 0);
  signal fifo_fc_rd_count                   : t_fc_count_array(c_num_acq_fifos-1 downto 0);
  signal fifo_fc_rd_empty                   : t_fc_dvalid_array(c_num_acq_fifos-1 downto 0);
  signal fifo_fc_addr                       : unsigned(g_addr_width-1 downto 0);

  signal fifo_fc_id_din                     : std_logic_vector(c_chan_id_width-1 downto 0);
  signal fifo_fc_id_we                      : t_fc_dvalid;
  signal fifo_fc_id_dout                    : std_logic_vector(c_chan_id_width-1 downto 0);
  signal fifo_fc_id_valid_out               : t_fc_dvalid;
  signal fifo_fc_id_rd_en                   : t_fc_dvalid;

  signal fifo_fc_rd_en                      : std_logic;
  signal fifo_fc_valid_out                  : t_fc_dvalid_array(c_num_acq_fifos-1 downto 0);
  signal fifo_fc_valid_and                  : t_fc_dvalid_array(c_num_acq_fifos downto 0);
  signal fifo_fc_trigger_or                 : t_fc_dvalid_array(c_num_acq_fifos downto 0);
  signal fifo_fc_valid_marsh                : t_fc_dvalid_array(g_acq_num_channels-1 downto 0);
  signal fifo_fc_valid_pkt                  : std_logic;
  signal fifo_fc_valid_fwft                 : std_logic;

  signal fifo_fc_last_data                  : std_logic;
  signal fifo_fc_first_data                 : std_logic;
  signal pl_dreq                            : std_logic;
  signal pl_stall                           : std_logic;
  signal pl_pkt_sent                        : std_logic;
  signal ext_stall_s                        : std_logic;

  -- FC source input signals
  signal fc_src_data_in                     : t_fc_data_marsh;
  signal fc_src_valid_in                    : std_logic;
  signal fc_src_addr_in                     : std_logic_vector(g_addr_width-1 downto 0);

  -- Output signals
  signal fc_dout                            : std_logic_vector(g_header_out_width+g_data_out_width-1 downto 0);
  signal fc_valid                           : std_logic;
  signal fc_addr                            : std_logic_vector(g_addr_width-1 downto 0);
  signal fc_sof                             : std_logic;
  signal fc_eof                             : std_logic;
  signal fc_dreq                            : std_logic;
  signal fc_stall                           : std_logic;

  -- Reset transaction signals
  signal req_rst_trans_sync                 : std_logic;
  signal rst_trans_fs_sync                  : std_logic;
  signal rst_trans_ext_sync                 : std_logic;
  signal rst_trans_ext_sync_d               : std_logic;
  signal pl_rst_trans                       : std_logic;
  signal acq_cnt_rst_n                      : std_logic;

  -- Samples counts
  -- counts the words written in the FIFO
  signal fifo_in_valid_cnt                  : t_fc_pkt;
  signal fifo_in_valid_full                 : std_logic;

  -- Counts the completed tranfered words to ext mem
  signal fifo_pkt_sent                      : std_logic;
  signal fifo_pkt_cnt_en                    : std_logic;
  signal fifo_pkt_sent_cnt                  : t_fc_pkt;
  signal fifo_pkt_sent_ct_cnt               : t_fc_pkt;
  signal fifo_pkt_sent_ct_all               : std_logic;
  signal acq_cnt_en                         : std_logic;
  signal dbg_pkt_ct_cnt                     : std_logic_vector(c_pkt_size_width-1 downto 0);
  signal dbg_shots_cnt                      : std_logic_vector(c_shots_size_width-1 downto 0);

  -- Transaction limit signals
  signal lmt_pre_pkt_size                   : unsigned(c_pkt_size_width-1 downto 0);
  signal lmt_pre_pkt_size_s                 : std_logic_vector(c_pkt_size_width-1 downto 0);
  signal lmt_pre_pkt_size_alig_s            : std_logic_vector(c_pkt_size_width-1 downto 0);
  signal lmt_pre_pkt_size_aggd              : unsigned(c_pkt_size_width-1 downto 0);
  signal lmt_pos_pkt_size                   : unsigned(c_pkt_size_width-1 downto 0);
  signal lmt_pos_pkt_size_s                 : std_logic_vector(c_pkt_size_width-1 downto 0);
  signal lmt_pos_pkt_size_alig_s            : std_logic_vector(c_pkt_size_width-1 downto 0);
  signal lmt_pos_pkt_size_aggd              : unsigned(c_pkt_size_width-1 downto 0);
  signal lmt_full_pkt_size                  : unsigned(c_pkt_size_width-1 downto 0);
  signal lmt_full_pkt_size_s                : std_logic_vector(c_pkt_size_width-1 downto 0);
  signal lmt_full_pkt_size_alig_s           : std_logic_vector(c_pkt_size_width-1 downto 0);
  signal lmt_full_pkt_size_aggd             : unsigned(c_pkt_size_width-1 downto 0);
  signal lmt_shots_nb                       : unsigned(c_shots_size_width-1 downto 0);
  signal lmt_curr_chan_id                   : unsigned(c_chan_id_width-1 downto 0);
  signal lmt_curr_chan_id_ext               : unsigned(c_chan_id_width-1 downto 0);
  signal lmt_valid                          : std_logic;
  signal lmt_valid_ext                      : std_logic;

  -- Number of shots transfers
  signal shots_sent_cnt                     : unsigned(c_shots_size_width-1 downto 0);
  signal shots_sent_all                     : std_logic;

  -- End of transaction signals
  signal fifo_fc_all_trans_done             : std_logic;
  signal fifo_fc_all_trans_done_lvl         : std_logic;
  signal fifo_fc_all_trans_done_sync        : std_logic;

begin
  -- For now, we only support 4, 8 or 16 output buffers
  assert (c_num_acq_fifos = 2 or c_num_acq_fifos = 4 or c_num_acq_fifos = 8)
  report "[acq_fc_fifo] Only c_num_acq_fifos equal 2, 4 or 8 are supported!" & lf &
            " Consider changing g_data_out_width and/or g_channels channel width"
  severity failure;

  -- For now, ww support only 256 or 512 output bits
  assert (g_data_out_width = 256 or g_data_out_width = 512)
  report "[acq_fc_fifo] Only g_data_out_width equal 256 or 512 are supported!"
  severity failure;

  ----------------------------------------------------------------------------
  -- Register transaction limits
  -----------------------------------------------------------------------------
  lmt_pre_pkt_size_s <= std_logic_vector(lmt_pre_pkt_size_i);
  lmt_pos_pkt_size_s <= std_logic_vector(lmt_pos_pkt_size_i);
  lmt_full_pkt_size_s <= std_logic_vector(lmt_full_pkt_size_i);

  p_in_reg : process (fs_clk_i)
  begin
    if rising_edge(fs_clk_i) then
      if fs_rst_n_i = '0' then
        lmt_valid <= '0';
        --avoid detection of *_done pulses by setting them to 1
        lmt_pre_pkt_size_alig_s <= (others => '0');
        lmt_pos_pkt_size_alig_s <= (others => '0');
        lmt_full_pkt_size_alig_s <= (others => '0');
        lmt_shots_nb <= to_unsigned(1, lmt_shots_nb'length);
        lmt_curr_chan_id <= to_unsigned(0, lmt_curr_chan_id'length);
        fifo_fc_fifo_idx_max <= to_unsigned(0, fifo_fc_fifo_idx_max'length);
      else
        lmt_valid <= lmt_valid_i;

        if lmt_valid_i = '1' then
          lmt_pre_pkt_size <= lmt_pre_pkt_size_i;
          lmt_pos_pkt_size <= lmt_pos_pkt_size_i;
          lmt_full_pkt_size <= lmt_full_pkt_size_i;

          -- Aggregated packet size. The packet size here is constrained by the
          -- relation f_log2(<output data width>/<input channel data width>),
          -- as we aggregate data by that amount to send it to the ddr3
          -- controller. Some modules need this packet size to function properly
          case c_fc_payload_ratio_log2(to_integer(lmt_curr_chan_id_i)) is
            when 1 =>
              lmt_pre_pkt_size_alig_s <= f_gen_std_logic_vector(1, '0') &
                                    lmt_pre_pkt_size_s(lmt_pre_pkt_size_s'left downto 1);
              lmt_pos_pkt_size_alig_s <= f_gen_std_logic_vector(1, '0') &
                                    lmt_pos_pkt_size_s(lmt_pos_pkt_size_s'left downto 1);
              lmt_full_pkt_size_alig_s <= f_gen_std_logic_vector(1, '0') &
                                    lmt_full_pkt_size_s(lmt_full_pkt_size_s'left downto 1);
            when 2 =>
              lmt_pre_pkt_size_alig_s <= f_gen_std_logic_vector(2, '0') &
                                    lmt_pre_pkt_size_s(lmt_pre_pkt_size_s'left downto 2);
              lmt_pos_pkt_size_alig_s <= f_gen_std_logic_vector(2, '0') &
                                    lmt_pos_pkt_size_s(lmt_pos_pkt_size_s'left downto 2);
              lmt_full_pkt_size_alig_s <= f_gen_std_logic_vector(2, '0') &
                                    lmt_full_pkt_size_s(lmt_full_pkt_size_s'left downto 2);
            when 3 =>
              lmt_pre_pkt_size_alig_s <= f_gen_std_logic_vector(3, '0') &
                                    lmt_pre_pkt_size_s(lmt_pre_pkt_size_s'left downto 3);
              lmt_pos_pkt_size_alig_s <= f_gen_std_logic_vector(3, '0') &
                                    lmt_pos_pkt_size_s(lmt_pos_pkt_size_s'left downto 3);
              lmt_full_pkt_size_alig_s <= f_gen_std_logic_vector(3, '0') &
                                    lmt_full_pkt_size_s(lmt_full_pkt_size_s'left downto 3);
            when others =>
              lmt_pre_pkt_size_alig_s <= f_gen_std_logic_vector(1, '0') &
                                    lmt_pre_pkt_size_s(lmt_pre_pkt_size_s'left downto 1);
              lmt_pos_pkt_size_alig_s <= f_gen_std_logic_vector(1, '0') &
                                    lmt_pos_pkt_size_s(lmt_pos_pkt_size_s'left downto 1);
              lmt_full_pkt_size_alig_s <= f_gen_std_logic_vector(1, '0') &
                                    lmt_full_pkt_size_s(lmt_full_pkt_size_s'left downto 1);
          end case;

          lmt_shots_nb <= lmt_shots_nb_i;
          lmt_curr_chan_id <= lmt_curr_chan_id_i;

          -- prepare the maximun fifo index to be used by the current channel
          fifo_fc_fifo_idx_max <= to_unsigned(c_fc_payload_ratio(to_integer(lmt_curr_chan_id_i)),
                                 fifo_fc_fifo_idx_max'length) - 1;
        end if;
      end if;
    end if;
  end process;

  -- Aggregated pakcet size
  lmt_pre_pkt_size_aggd <= unsigned(lmt_pre_pkt_size_alig_s);
  lmt_pos_pkt_size_aggd <= unsigned(lmt_pos_pkt_size_alig_s);
  lmt_full_pkt_size_aggd <= unsigned(lmt_full_pkt_size_alig_s);

  cmp_lmt_valid_pulse_synchronizer : gc_pulse_synchronizer
  port map (
    clk_in_i                                => fs_clk_i,
    clk_out_i                               => ext_clk_i,
    rst_n_i                                 => fs_rst_n_i,
    d_ready_o                               => open,
    d_p_i                                   => lmt_valid, -- pulse input
    q_p_o                                   => lmt_valid_ext -- pulse output
  );

  -----------------------------------------------------------------------------
  -- FIFO write logic
  -----------------------------------------------------------------------------

  p_fifo_fc_input : process (fs_clk_i)
    variable v_fifo_fc_mux_cnt_prev : unsigned(f_log2_size(c_num_acq_fifos)-1 downto 0) :=
              to_unsigned(0, f_log2_size(c_num_acq_fifos));
  begin
    if rising_edge(fs_clk_i) then
      if fs_rst_n_i = '0' then
        fifo_fc_din <= c_fc_data_array_zeros;
        fifo_fc_we <= c_fc_dvalid_array_zeros;
        fifo_fc_id_din <= (others => '0');
        fifo_fc_mux_cnt <= to_unsigned(0, fifo_fc_mux_cnt'length);
      else
        if passthrough_en_i = '1' then
          fifo_fc_din(to_integer(fifo_fc_mux_cnt)) <= pt_data_id_i & pt_trig_i &
                                                        pt_data_i;  -- data_id + trigger + data
          fifo_fc_we(to_integer(fifo_fc_mux_cnt)) <= fifo_fc_wr_en;
        else
          fifo_fc_din(to_integer(fifo_fc_mux_cnt)) <= dpram_data_i; -- This already has data_id + trigger + data
          fifo_fc_we(to_integer(fifo_fc_mux_cnt)) <= dpram_dvalid_i;
        end if;

        -- Drive the previous MUX pointer and fix it for the 0 case
        v_fifo_fc_mux_cnt_prev := fifo_fc_mux_cnt-1;

        if fifo_fc_mux_cnt = 0 then
          v_fifo_fc_mux_cnt_prev := fifo_fc_fifo_idx_max;
        end if;

        -- Clear the previous fifo_fc_we
        fifo_fc_we(to_integer(v_fifo_fc_mux_cnt_prev)) <= '0';

        -- Current channel ID FIFO input
        fifo_fc_id_din <= std_logic_vector(lmt_curr_chan_id);

        -- Change the FIFO buffer when the previous one has been written.
        --
        -- WARNING: If the fifo_fc_mux_cnt signal is not zero at the end of transaction,
        -- it means we have a problem in the transaction, typically an unaligned
        -- trigger detection (trigger asserted in a atom that is not the last one).
        -- We have this limitation as we aggregate atoms into a sample prior to
        -- transferring it to the next module. So a fifo_fc_mux_cnt not zero means
        -- we have atoms not belonging in that transaction.
        -- TODO: assert error to user if that condition is detected
        if fifo_fc_mux_inc = '1' then
          fifo_fc_mux_cnt <= fifo_fc_mux_cnt + 1;

          if fifo_fc_mux_cnt = fifo_fc_fifo_idx_max then
            fifo_fc_mux_cnt <= to_unsigned(0, fifo_fc_mux_cnt'length);
         end if;
        end if;
      end if;
    end if;
  end process;

  -- FOR SIMULATION ONLY
  -- Assert error if fifo_fc_mux_cnt signal is anything different than zero after the
  -- end of transaction
  assert (not(fs_rst_n_i = '1' and ext_rst_n_i = '1') or ((fifo_fc_all_trans_done_lvl = '1' and
            fifo_fc_mux_cnt = to_unsigned(0, fifo_fc_mux_cnt'length)) or -- end of transaction case
            (fifo_fc_all_trans_done_sync = '0'))) -- every other case
  report "[acq_fc_fifo] fifo_fc_mux_cnt signal is not 0 after the end of the transaction!"
  severity failure;

  fifo_fc_mux_inc <= fifo_fc_wr_en when passthrough_en_i = '1' else fifo_fc_dpram_wr_en;

  -- We read the ID FIFO synchronized with the data FIFOs. So, we only need
  -- to write to the ID fifo once per data FIFO loop.
  fifo_fc_id_we <= fifo_fc_we(0);

  -- Count the words written in the FIFO
  p_cnt_valid_in : process (fs_clk_i)
  begin
    if rising_edge(fs_clk_i) then
      if fs_rst_n_i = '0' then
        fifo_in_valid_cnt <= to_unsigned(0, fifo_in_valid_cnt'length);
      else
        if rst_trans_fs_sync = '1' then
          fifo_in_valid_cnt <= to_unsigned(0, fifo_in_valid_cnt'length);
        elsif fifo_fc_wr_en = '1' and fifo_fc_cnt_en = '1' then -- valid word on fifo input
          fifo_in_valid_cnt <= fifo_in_valid_cnt + 1;
        end if;
      end if;
    end if;
  end process;

  -- Used only for passthrough mode
  fifo_in_valid_full <= '1' when fifo_in_valid_cnt = lmt_full_pkt_size else '0';

  -- Fifo valid input. We use only the first FIFO full, for precaution and simplicity
  fifo_fc_wr_en <= pt_wr_en_i and pt_dvalid_i and not(fifo_in_valid_full) and not(fifo_fc_wr_full(0));
  fifo_fc_dpram_wr_en <= dpram_dvalid_i and not(fifo_fc_wr_full(0));

  -- Only count when in pre_trigger or post_trigger and we haven't acquire
  -- enough samples
  fifo_fc_cnt_en <= '1' when (fifo_in_valid_cnt < lmt_pre_pkt_size and
                                pt_data_id_i = "010") or -- Pre-trigger
                                (fifo_in_valid_cnt < lmt_full_pkt_size and
                                pt_data_id_i = "100") -- Post-trigger
                            else '0';

  -----------------------------------------------------------------------------
  -- Output FIFOs
  -----------------------------------------------------------------------------

  -- Current channel Cross-clocking FIFO
  cmp_acq_curr_chan_fwft_fifo : acq_fwft_fifo
  generic map
  (
    g_data_width                            => c_chan_id_width,
    g_size                                  => g_fifo_size,
    g_almost_empty_threshold                => 0,
    g_almost_full_threshold                 => 0,
    g_with_wr_count                         => true,
    g_with_rd_count                         => false
  )
  port map
  (
    -- Write clock
    wr_clk_i                                => fs_clk_i,
    wr_rst_n_i                              => fs_rst_n_i,

    wr_data_i                               => fifo_fc_id_din,
    wr_en_i                                 => fifo_fc_id_we,
    -- Ignored, as we rely on the data FIFOs wr_full signal
    wr_full_o                               => open,
    wr_count_o                              => open,

    -- Read clock
    rd_clk_i                                => ext_clk_i,
    rd_rst_n_i                              => ext_rst_n_i,

    rd_data_o                               => fifo_fc_id_dout,
    rd_valid_o                              => fifo_fc_id_valid_out,
    rd_en_i                                 => fifo_fc_id_rd_en,
    rd_empty_o                              => open,
    rd_count_o                              => open
  );

  fifo_fc_id_rd_en <= fifo_fc_rd_en;

  -- Data FIFOs
  gen_outfifo_buffers : for i in 0 to c_num_acq_fifos-1 generate

    cmp_acq_fwft_fifo : acq_fwft_fifo
    generic map
    (
      -- For simplicity take the widest channel
      g_data_width                          => c_widest_channel_width,
      g_size                                => g_fifo_size,
      g_almost_empty_threshold              => 0,
      g_almost_full_threshold               => 0,
      g_with_wr_count                       => true,
      g_with_rd_count                       => false
    )
    port map
    (
      -- Write clock
      wr_clk_i                              => fs_clk_i,
      wr_rst_n_i                            => fs_rst_n_i,

      wr_data_i                             => fifo_fc_din(i),
      wr_en_i                               => fifo_fc_we(i),
      wr_full_o                             => fifo_fc_wr_full(i),
      wr_count_o                            => fifo_fc_wr_count(i),

      -- Read clock
      rd_clk_i                              => ext_clk_i,
      rd_rst_n_i                            => ext_rst_n_i,

      rd_data_o                             => fifo_fc_dout(i),
      rd_valid_o                            => fifo_fc_valid_out(i),
      rd_en_i                               => fifo_fc_rd_en,
      rd_empty_o                            => fifo_fc_rd_empty(i),
      rd_count_o                            => open
    );

    -- Extract fifo trigger from fifo_fc_dout
    fifo_fc_trigger(i) <= fifo_fc_dout(i)(c_acq_header_trigger_idx+c_fc_data_header_bot_idx);

    -- Extract fifo data id from fifo_fc_dout
    fifo_fc_data_id(i) <= fifo_fc_dout(i)(c_acq_header_id_top_idx+c_fc_data_header_bot_idx downto
                            c_acq_header_id_bot_idx+c_fc_data_header_bot_idx);
  end generate;

  fifo_fc_full_o <= fifo_fc_wr_full(0);

  -- TODO1: implement better fifo reading mechanism!
  -- We actually don't need to wait until fifo_fc_stall_i is clean to read from fifo.
  -- We could read from FIFO as long as the output pipeline is not full.
  --
  -- TODO2: Start reading only after a determined threshold! In this way we avoid
  -- excessive throttling of the "fifo_fc_valid" signal for the FIFO being empty!
  -- This happens because the reading clock (200 MHz) is generally faster
  -- than fs_clk (~113 MHz)

  fifo_fc_valid_pkt <= fifo_fc_valid_marsh(to_integer(lmt_curr_chan_id_ext));
  fifo_fc_rd_en <= (pl_dreq or not(pl_stall)) and fifo_fc_valid_pkt;

  -- FIFO Debug signals
  dbg_fifo_we_o <= fifo_fc_we(0);
  dbg_fifo_wr_count_o <= fifo_fc_wr_count(0);
  dbg_fifo_re_o <= '0';
  dbg_fifo_fc_rd_en_o <= fifo_fc_rd_en;
  dbg_fifo_rd_empty_o <= fifo_fc_rd_empty(0);
  dbg_fifo_wr_full_o <= fifo_fc_wr_full(0);
  dbg_fifo_fc_valid_fwft_o <= '0';
  dbg_source_pl_dreq_o <= pl_dreq;
  dbg_source_pl_stall_o <= pl_stall;

  -----------------------------------------------------------------------------
  -- Marsh all data from the used output buffers.
  -----------------------------------------------------------------------------
  -- ANDing all clock chains mmcm_adc_locked_o
  fifo_fc_valid_and(0) <= '1';
  gen_fifo_fc_valid_and : for i in 0 to c_num_acq_fifos-1 generate
    fifo_fc_valid_and(i+1) <= fifo_fc_valid_and(i) and fifo_fc_valid_out(i);
  end generate;

  -- ORing all header trigger data
  fifo_fc_trigger_or(0) <= '0';
  gen_fifo_fc_trigger_or : for i in 0 to c_num_acq_fifos-1 generate
    fifo_fc_trigger_or(i+1) <= fifo_fc_trigger_or(i) or fifo_fc_trigger(i);
  end generate;

  -- Marsh FIFO data outputs
  gen_marsh_data_channels : for i in 0 to g_acq_num_channels-1  generate -- for all input channels

    gen_marsh_data_fifos : for j in 0 to c_fc_payload_ratio(i)-1 generate -- for all valid FIFOs for this channel
      -- Data
      fifo_fc_dout_marsh(i)(to_integer(g_acq_channels(i).width)*(j+1)-1 downto
                            to_integer(g_acq_channels(i).width)*j)
          <= fifo_fc_dout(j)(to_integer(g_acq_channels(i).width)-1 downto 0);
    end generate;

    -- Header
    fifo_fc_dout_marsh(i)(c_fc_data_marsh_header_top_idx downto
                          c_fc_data_marsh_header_bot_idx)
                          <= fifo_fc_data_id(c_fc_payload_ratio(i)-1) & -- Get last channel data id as
                                                                  -- all buffers will have the same ID when
                                                                  -- fifo_fc_valid_marsh is 1
                            fifo_fc_trigger_or(c_fc_payload_ratio(i));
    -- Valid
    fifo_fc_valid_marsh(i) <= fifo_fc_valid_and(c_fc_payload_ratio(i)); -- get the corresponding FIFO valid AND'ed signal

  end generate;

  -----------------------------------------------------------------------------
  -- Synchronize current channel ID with ext_clk_i domain
  -----------------------------------------------------------------------------

  p_synch_lmt_curr_chan_id : process (ext_clk_i)
  begin
    if rising_edge(ext_clk_i) then
      if ext_rst_n_i = '0' then
        lmt_curr_chan_id_ext <= to_unsigned(0, lmt_curr_chan_id_ext'length);
      else
        if lmt_valid_ext = '1' then
          lmt_curr_chan_id_ext <= lmt_curr_chan_id;
        end if;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Reset transaction logic
  -----------------------------------------------------------------------------

  -- Sync Request Reset
  cmp_sync_req_rst : gc_sync_ffs
  port map(
    clk_i                                   => ext_clk_i,
    rst_n_i                                 => ext_rst_n_i,
    data_i                                  => req_rst_trans_i,
    synced_o                                => req_rst_trans_sync,
    npulse_o                                => open,
    ppulse_o                                => open
  );

  rst_trans_ext_sync <= '1' when req_rst_trans_sync = '1' and
            fifo_fc_all_trans_done_lvl = '1' else '0';

  -- Delay Reset signal to Level logic. This will give a few cycles
  -- for all modules to safely reset
  cmp_sync_rst_trans_ext : gc_sync_ffs
  port map(
    clk_i                                   => ext_clk_i,
    rst_n_i                                 => ext_rst_n_i,
    data_i                                  => rst_trans_ext_sync,
    synced_o                                => rst_trans_ext_sync_d,
    npulse_o                                => open,
    ppulse_o                                => open
  );

  cmp_rst_trans_gc_pulse_synchronizer : gc_pulse_synchronizer
  port map (
    clk_in_i                                => ext_clk_i,
    clk_out_i                               => fs_clk_i,
    rst_n_i                                 => ext_rst_n_i,
    d_ready_o                               => open,
    d_p_i                                   => rst_trans_ext_sync, -- pulse input
    q_p_o                                   => rst_trans_fs_sync -- pulse output
  );

  -----------------------------------------------------------------------------
  -- RAM address counter (32-bit word address)
  --
  -- Number of packets sent in all of the transactions inside one acquisition
  -----------------------------------------------------------------------------

  p_fifo_pkt_sent_cnt : process (ext_clk_i)
  begin
    if rising_edge(ext_clk_i) then
      if ext_rst_n_i = '0' then
        fifo_pkt_sent_cnt <= to_unsigned(0, fifo_pkt_sent_cnt'length);
      else
        if rst_trans_ext_sync = '1' then
          fifo_pkt_sent_cnt <= to_unsigned(0, fifo_pkt_sent_cnt'length);
        elsif fifo_pkt_sent = '1' then
          fifo_pkt_sent_cnt <= fifo_pkt_sent_cnt + 1;
        end if;
      end if;
    end if;
  end process;

  fifo_fc_addr <= resize(fifo_pkt_sent_cnt, fifo_fc_addr'length);

  -- When the input of FC module is valid, not stalled and we are in pre-trigger
  -- or post-trigger, packet is considered sent
  fifo_pkt_sent <= not(pl_stall) and fc_src_valid_in;

  -- Only count when in pre_trigger or post_trigger and we haven't acquire
  -- enough samples
  fifo_pkt_cnt_en <= '1' when (unsigned(dbg_pkt_ct_cnt) < lmt_pre_pkt_size_aggd and
                                fifo_fc_data_id(c_fc_payload_ratio(to_integer(lmt_curr_chan_id))-1) = "010") or -- Pre-trigger
                                (unsigned(dbg_pkt_ct_cnt) < lmt_full_pkt_size_aggd and
                                fifo_fc_data_id(c_fc_payload_ratio(to_integer(lmt_curr_chan_id))-1) = "100") -- Post-trigger
                            else '0';

   -- Counter to detect end of transaction only
   acq_cnt_en <= '1' when fifo_pkt_cnt_en = '1' and fifo_pkt_sent = '1' else '0';

  -----------------------------------------------------------------------------
  -- Number of packets and shots transfered
  -----------------------------------------------------------------------------
  cmp_acq_cnt : acq_cnt
  port map
  (
    -- DDR3 external clock
    clk_i                                   => ext_clk_i,
    rst_n_i                                 => acq_cnt_rst_n,

    cnt_all_pkts_ct_done_p_o                => fifo_pkt_sent_ct_all,
    cnt_all_trans_done_p_o                  => shots_sent_all,
    cnt_en_i                                => acq_cnt_en,

    -- Size of the transaction in g_fifo_size bytes
    lmt_pkt_size_i                          => lmt_full_pkt_size_aggd,
    -- Number of shots in this acquisition
    lmt_shots_nb_i                          => lmt_shots_nb,
    -- Acquisition limits valid signal. Qualifies lmt_pkt_size_i and lmt_shots_nb_i
    lmt_valid_i                             => lmt_valid_ext,

    dbg_pkt_ct_cnt_o                        => dbg_pkt_ct_cnt,
    dbg_shots_cnt_o                         => dbg_shots_cnt
  );

  dbg_pkt_ct_cnt_o <= dbg_pkt_ct_cnt;
  dbg_shots_cnt_o <= dbg_shots_cnt;

  acq_cnt_rst_n <= ext_rst_n_i and not(rst_trans_ext_sync); -- is this a good idea?

  -----------------------------------------------------------------------------
  -- End of transaction pulse
  -----------------------------------------------------------------------------
  cmp_eot_gc_pulse_synchronizer : gc_pulse_synchronizer
  port map (
    clk_in_i                                => ext_clk_i,
    clk_out_i                               => fs_clk_i,
    rst_n_i                                 => ext_rst_n_i,
    d_ready_o                               => open,
    d_p_i                                   => fifo_fc_all_trans_done, -- pulse input
    q_p_o                                   => fifo_fc_all_trans_done_sync -- pulse output
  );

  fifo_fc_all_trans_done <= shots_sent_all; -- sync'ed to ext_clk_i
  fifo_fc_all_trans_done_p_o <= fifo_fc_all_trans_done_sync;

  -------------------------------------------------------------------------
  -- Pulse to level conversion
  -------------------------------------------------------------------------
  cmp_conv_fifo_fc_all_trans_done : pulse2level
  port map
  (
    clk_i                                   => ext_clk_i,
    rst_n_i                                 => ext_rst_n_i,

    pulse_i                                 => fifo_fc_all_trans_done,
    clr_i                                   => rst_trans_ext_sync_d,
    level_o                                 => fifo_fc_all_trans_done_lvl
  );

  -----------------------------------------------------------------------------
  -- Marsh FIFO outputs
  -----------------------------------------------------------------------------

  fc_src_data_in <= fifo_fc_dout_marsh(to_integer(lmt_curr_chan_id_ext));
  fc_src_valid_in <= fifo_fc_valid_marsh(to_integer(lmt_curr_chan_id_ext));
  fc_src_addr_in <= std_logic_vector(fifo_fc_addr);

  ------------------------------------------------------------------------------
  -- Output Protocol Logic
  ------------------------------------------------------------------------------

  cmp_fc_source : fc_source
  generic map (
    g_header_in_width                       => g_header_out_width,
    g_data_width                            => g_data_out_width,
    g_pkt_size_width                        => c_pkt_size_width,
    g_addr_width                            => g_addr_width,
    g_pipe_size                             => g_fc_pipe_size
  )
  port map (
    clk_i                                   => ext_clk_i,
    rst_n_i                                 => ext_rst_n_i,

    pl_data_i                               => fc_src_data_in,
    pl_addr_i                               => fc_src_addr_in,
    pl_valid_i                              => fc_src_valid_in,

    pl_dreq_o                               => pl_dreq,
    pl_stall_o                              => pl_stall,
    pl_pkt_sent_o                           => open,

    pl_rst_trans_i                          => pl_rst_trans,

    -- This signals cross clock domains, but lmt_pkt_size_i is asserted long before
    -- (Wishbone CPU register) the lmt_valid_ext signal, which is synchronized
    -- to ext_clk domain
    lmt_pre_pkt_size_i                      => lmt_pre_pkt_size_aggd,
    lmt_pos_pkt_size_i                      => lmt_pos_pkt_size_aggd,
    lmt_full_pkt_size_i                     => lmt_full_pkt_size_aggd,
    lmt_valid_i                             => lmt_valid_ext,

    fc_dout_o                               => fc_dout,
    fc_valid_o                              => fc_valid,
    fc_addr_o                               => fc_addr,
    fc_sof_o                                => fc_sof,
    fc_eof_o                                => fc_eof,

    fc_stall_i                              => fc_stall,
    fc_dreq_i                               => fc_dreq
  );

  pl_rst_trans <= '0';

  -- Output assignments
  fifo_fc_dout_o <= fc_dout;
  fifo_fc_valid_o <= fc_valid;
  fifo_fc_addr_o <= fc_addr;
  fifo_fc_sof_o <= fc_sof;
  fifo_fc_eof_o <= fc_eof;

  fc_dreq <= fifo_fc_dreq_i;
  fc_stall <= fifo_fc_stall_i;

end rtl;
