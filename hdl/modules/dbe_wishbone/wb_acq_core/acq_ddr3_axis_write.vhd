------------------------------------------------------------------------------
-- Title      : BPM ACQ Custom <-> DDR3 AXIS Interface conversion
------------------------------------------------------------------------------
-- Author     : Lucas Maziero Russo
-- Company    : CNPEM LNLS-DIG
-- Created    : 2015-07-12
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: Module for the performing interface conversion between custom
--               interface (much alike the Wishbone B4 Pipelined) and DDR3 AXIS
--               interface.
-------------------------------------------------------------------------------
-- Copyright (c) 2015 CNPEM
-- Licensed under GNU Lesser General Public License (LGPL) v3.0
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2015-07-12  1.0      lucas.russo        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
-- Main Wishbone Definitions
use work.wishbone_pkg.all;
-- Genrams cores
use work.genram_pkg.all;
-- General cores
use work.gencores_pkg.all;
-- Acquisition cores
use work.acq_core_pkg.all;
-- AXI cores
use work.bpm_axi_pkg.all;

entity acq_ddr3_axis_write is
generic
(
  g_acq_num_channels                        : natural := 1;
  g_acq_channels                            : t_acq_chan_param_array;
  g_fc_pipe_size                            : natural := 4;
  -- Do not modify these! As they are dependent of the memory controller generated!
  g_ddr_header_width                        : natural := 4;
  g_ddr_payload_width                       : natural := 256;     -- be careful changing these!
  g_ddr_dq_width                            : natural := 64;      -- be careful changing these!
  g_ddr_addr_width                          : natural := 32;      -- be careful changing these!
  g_max_burst_size                          : natural := 4        -- be careful changing these!
);
port
(
  -- DDR3 external clock
  ext_clk_i                                 : in  std_logic;
  ext_rst_n_i                               : in  std_logic;

  -- Flow protocol to interface with external SDRAM. Evaluate the use of
  -- Wishbone Streaming protocol.
  fifo_fc_din_i                             : in std_logic_vector(g_ddr_header_width+g_ddr_payload_width-1 downto 0);
  fifo_fc_valid_i                           : in std_logic;
  fifo_fc_addr_i                            : in std_logic_vector(g_ddr_addr_width-1 downto 0);
  fifo_fc_sof_i                             : in std_logic;
  fifo_fc_eof_i                             : in std_logic;
  fifo_fc_dreq_o                            : out std_logic;
  fifo_fc_stall_o                           : out std_logic;

  wr_start_i                                : in std_logic;
  wr_init_addr_i                            : in std_logic_vector(g_ddr_addr_width-1 downto 0);
  wr_end_addr_i                             : in std_logic_vector(g_ddr_addr_width-1 downto 0);

  lmt_all_trans_done_p_o                    : out std_logic;
  lmt_ddr_trig_addr_o                       : out std_logic_vector(g_ddr_addr_width-1 downto 0);
  lmt_rst_i                                 : in std_logic;

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

  -- DDR3 AXIS Interface
  axis_s2mm_cmd_tdata_o                     : out std_logic_vector(71 downto 0);
  axis_s2mm_cmd_tvalid_o                    : out std_logic;
  axis_s2mm_cmd_tready_i                    : in std_logic;

  axis_s2mm_pld_tdata_o                     : out std_logic_vector(g_ddr_payload_width-1 downto 0);
  axis_s2mm_pld_tkeep_o                     : out std_logic_vector(g_ddr_payload_width/8-1 downto 0);
  axis_s2mm_pld_tlast_o                     : out std_logic;
  axis_s2mm_pld_tvalid_o                    : out std_logic;
  axis_s2mm_pld_tready_i                    : in std_logic;

  axis_s2mm_rstn_o                          : out std_logic;
  axis_s2mm_halt_o                          : out std_logic;
  axis_s2mm_halt_cmplt_i                    : in  std_logic;
  axis_s2mm_allow_addr_req_o                : out std_logic;
  axis_s2mm_addr_req_posted_i               : in  std_logic;
  axis_s2mm_wr_xfer_cmplt_i                 : in  std_logic;
  axis_s2mm_ld_nxt_len_i                    : in  std_logic;
  axis_s2mm_wr_len_i                        : in  std_logic_vector(7 downto 0);

  -- Debug Outputs
  dbg_ddr_addr_cnt_axis_o                   : out std_logic_vector(g_ddr_addr_width-1 downto 0);
  dbg_ddr_addr_init_o                       : out std_logic_vector(g_ddr_addr_width-1 downto 0);
  dbg_ddr_addr_max_o                        : out std_logic_vector(g_ddr_addr_width-1 downto 0)
);
end acq_ddr3_axis_write;

architecture rtl of acq_ddr3_axis_write is

  alias c_acq_channels : t_acq_chan_param_array(g_acq_num_channels-1 downto 0) is g_acq_channels;

  -- Constants
  constant c_acq_chan_slice                 : t_acq_chan_slice_array(g_acq_num_channels-1 downto 0) :=
                                                 f_acq_chan_det_slice(c_acq_channels);
  -- g_ddr_payload_width must be bigger than g_data_width by at least 2 times.
  -- Also, only power of 2 ratio sizes are supported
  constant c_fc_payload_ratio               : t_payld_ratio_array(g_acq_num_channels-1 downto 0) :=
                                                f_fc_payload_ratio (g_ddr_payload_width,
                                                               c_acq_chan_slice);
  constant c_fc_payload_ratio_log2          : t_payld_ratio_array(g_acq_num_channels-1 downto 0) :=
                                                f_log2_size_array(c_fc_payload_ratio);
  constant c_max_ddr_payload_ratio_log2     : natural := f_log2_size(c_max_payload_ratio);
  constant c_ddr_keep_width                 : natural := g_ddr_payload_width/8;
  constant c_ddr_eop_width                  : natural := 1;

  alias c_ddr_payload_width                 is g_ddr_payload_width;

  constant c_ddr_payload_eop_keep_width     : natural := g_ddr_payload_width + c_ddr_eop_width + c_ddr_keep_width;

  -- Data increment constant
  constant c_bytes_per_word                 : natural := g_ddr_dq_width/8; -- in bytes
  constant c_bytes_per_word_log2            : natural := f_log2_size(c_bytes_per_word);
  constant c_addr_ddr_inc                   : natural := c_ddr_payload_width/g_ddr_dq_width; -- in words
  constant c_addr_ddr_inc_axis              : natural := c_ddr_payload_width/g_ddr_dq_width*c_bytes_per_word; -- in bytes
  constant c_ddr_payload_width_byte         : natural := c_ddr_payload_width/8;
  constant c_ddr_payload_width_byte_log2    : natural := f_log2_size(c_ddr_payload_width_byte);

  -- Must be power of 2
  constant c_ddr_axis_max_btt               : natural := 4194304; -- 2^22
  -- Maximum words to transfer
  constant c_ddr_axis_max_wtt               : natural := c_ddr_axis_max_btt/c_ddr_payload_width_byte;
  constant c_ddr_axis_max_wtt_width         : natural := f_log2_size(c_ddr_axis_max_wtt);

  -- Flow Control constants
  constant c_pkt_size_width                 : natural := 32;
  constant c_addr_cnt_width                 : natural := c_max_ddr_payload_ratio_log2;

  -- Constants for data + keep aggregate signal
  constant c_keep_low                       : natural := 0;
  constant c_keep_high                      : natural := c_ddr_keep_width + c_keep_low -1;
  constant c_eop_low                        : natural := c_keep_high + 1;
  constant c_eop_high                       : natural := c_ddr_eop_width + c_eop_low -1;
  constant c_data_low                       : natural := c_eop_high + 1;
  constant c_data_high                      : natural := c_ddr_payload_width + c_data_low -1;
  constant c_header_low                     : natural := c_data_high + 1;
  constant c_header_high                    : natural := g_ddr_header_width + c_header_low -1;

  constant c_ddr_header_top_idx             : natural := g_ddr_header_width + g_ddr_payload_width-1;
  constant c_ddr_header_bot_idx             : natural := g_ddr_payload_width;

  constant c_fc_header_top_idx              : natural := g_ddr_header_width + c_ddr_payload_eop_keep_width -1;
  constant c_fc_header_bot_idx              : natural := c_ddr_payload_eop_keep_width;

  -- Constants for ddr3 address bits
  constant c_ddr_align_shift                : natural := f_log2_size(c_addr_ddr_inc);

  subtype t_addr_cnt is unsigned(c_addr_cnt_width-1 downto 0);
  type t_addr_cnt_array is array (natural range <>) of t_addr_cnt;

  subtype t_addr_cnt_s is std_logic_vector(c_addr_cnt_width-1 downto 0);
  type t_addr_cnt_s_array is array (natural range <>) of t_addr_cnt_s;

  -- Flow control signals
  signal lmt_pre_pkt_size                   : unsigned(c_pkt_size_width-1 downto 0);
  signal lmt_pre_pkt_size_s                 : std_logic_vector(c_pkt_size_width-1 downto 0);
  signal lmt_pre_pkt_size_alig_s            : std_logic_vector(c_pkt_size_width-1 downto 0);
  signal lmt_pre_pkt_size_aggd              : unsigned(c_pkt_size_width-1 downto 0);
  signal lmt_pre_pkt_size_aggd_byte_s       : std_logic_vector(c_pkt_size_width-1 downto 0);
  signal lmt_pre_pkt_size_aggd_byte         : unsigned(c_pkt_size_width-1 downto 0);
  signal lmt_pos_pkt_size                   : unsigned(c_pkt_size_width-1 downto 0);
  signal lmt_pos_pkt_size_s                 : std_logic_vector(c_pkt_size_width-1 downto 0);
  signal lmt_pos_pkt_size_alig_s            : std_logic_vector(c_pkt_size_width-1 downto 0);
  signal lmt_pos_pkt_size_aggd              : unsigned(c_pkt_size_width-1 downto 0);
  signal lmt_pos_pkt_size_aggd_byte_s       : std_logic_vector(c_pkt_size_width-1 downto 0);
  signal lmt_pos_pkt_size_aggd_byte         : unsigned(c_pkt_size_width-1 downto 0);
  signal lmt_full_pkt_size                  : unsigned(c_pkt_size_width-1 downto 0);
  signal lmt_full_pkt_size_s                : std_logic_vector(c_pkt_size_width-1 downto 0);
  signal lmt_full_pkt_size_alig_s           : std_logic_vector(c_pkt_size_width-1 downto 0);
  signal lmt_full_pkt_size_aggd             : unsigned(c_pkt_size_width-1 downto 0);
  signal lmt_full_pkt_size_aggd_byte_s      : std_logic_vector(c_pkt_size_width-1 downto 0);
  signal lmt_full_pkt_size_aggd_byte        : unsigned(c_pkt_size_width-1 downto 0);
  signal lmt_shots_nb                       : unsigned(c_shots_size_width-1 downto 0);
  signal lmt_curr_chan_id                   : unsigned(c_chan_id_width-1 downto 0);
  signal lmt_valid                          : std_logic;
  signal fc_dout                            : std_logic_vector(g_ddr_header_width+g_ddr_payload_width+c_ddr_eop_width+c_ddr_keep_width-1 downto 0);
  signal fc_valid_cmd                       : std_logic;
  signal fc_sof_cmd                         : std_logic;
  signal fc_eof_cmd                         : std_logic;
  signal fc_header_cmd                      : std_logic_vector(g_ddr_header_width-1 downto 0);
  signal fc_valid_pld                       : std_logic;
  signal fc_sof_pld                         : std_logic;
  signal fc_eof_pld                         : std_logic;
  signal fc_eop_pld                         : std_logic;
  signal fc_addr                            : std_logic_vector(g_ddr_addr_width-1 downto 0);
  signal fc_stall_cmd                       : std_logic;
  signal fc_dreq_cmd                        : std_logic;
  signal fc_stall_pld                       : std_logic;
  signal fc_dreq_pld                        : std_logic;
  signal fc_ack                             : std_logic;
  signal fc_trigger_cmd                     : std_logic;
  signal fc_data_id_cmd                     : std_logic_vector(2 downto 0);

  signal valid_trans_cmd                    : std_logic;
  signal valid_trans_cmd_d0                 : std_logic;
  signal valid_trans_pld                    : std_logic;
  signal cnt_all_trans_done_cmd_p           : std_logic;
  signal cnt_all_trans_done_pld_p           : std_logic;
  signal cnt_all_pkts_ct_done_pld_p         : std_logic;
  signal cnt_all_trans_done_cmd_l           : std_logic;
  signal cnt_all_trans_done_pld_l           : std_logic;
  signal cnt_all_trans_done_p               : std_logic;
  signal wr_init_addr_alig                  : std_logic_vector(g_ddr_addr_width-1 downto 0);
  signal wr_end_addr_alig                   : std_logic_vector(g_ddr_addr_width-1 downto 0);

  -- Plain interface control
  signal pl_dreq                            : std_logic;
  signal pl_stall                           : std_logic;
  signal pl_stall_d0                        : std_logic;
  signal pl_dreq_cmd                        : std_logic;
  signal pl_stall_cmd                       : std_logic;
  signal pl_pkt_sent_cmd                    : std_logic;
  signal pl_dreq_pld                        : std_logic;
  signal pl_stall_pld                       : std_logic;
  signal pl_pkt_sent_pld                    : std_logic;
  signal pl_rst_trans                       : std_logic;

  signal pl_pkt_thres_hit_cmd               : std_logic;
  signal pl_pkt_thres_hit_pld               : std_logic;

  -- Counter signals
  signal dbg_cmd_pkt_ct_cnt                 : std_logic_vector(c_pkt_size_width-1 downto 0);
  signal dbg_cmd_shots_cnt                  : std_logic_vector(c_shots_size_width-1 downto 0);
  signal dbg_pld_pkt_ct_cnt                 : std_logic_vector(c_pkt_size_width-1 downto 0);
  signal dbg_pld_shots_cnt                  : std_logic_vector(c_shots_size_width-1 downto 0);
  signal pl_cmd_cnt_en                      : std_logic;
  signal acq_cmd_cnt_en                     : std_logic;
  signal pl_pld_cnt_en                      : std_logic;
  signal acq_pld_cnt_en                     : std_logic;

  -- DDR3 Signals
  signal ddr_data_in                        : std_logic_vector(g_ddr_header_width+g_ddr_payload_width-1 downto 0);
  signal ddr_addr_cnt_axis                  : unsigned(g_ddr_addr_width-1 downto 0);
  signal ddr_addr_init                      : unsigned(g_ddr_addr_width-1 downto 0);
  signal ddr_addr_max                       : unsigned(g_ddr_addr_width-1 downto 0);
  signal ddr_recv_pkt_cnt                   : unsigned(c_ddr_axis_max_wtt_width-1 downto 0);
  signal ddr_addr_first                     : std_logic;
  signal ddr_reissue_trans                  : std_logic;
  signal ddr_new_shot_coming                : std_logic;
  signal ddr_addr_in                        : std_logic_vector(g_ddr_addr_width-1 downto 0);
  signal ddr_addr_in_axis                   : std_logic_vector(g_ddr_addr_width-1 downto 0);
  signal ddr_valid_in                       : std_logic;
  signal ddr_axis_cmd_valid_in              : std_logic;
  signal ddr_sent_cnt_out                   : unsigned(f_log2_size(g_max_burst_size)-1 downto 0);
  signal ddr_valid_in_t                     : std_logic;
  signal ddr_trigger_in                     : std_logic;
  signal ddr_trig_captured                  : std_logic;
  signal ddr_data_id_in                     : std_logic_vector(2 downto 0);
  signal ddr_header_in                      : std_logic_vector(c_acq_header_width-1 downto 0);
  signal ddr_trig_addr                      : unsigned(g_ddr_addr_width-1 downto 0);

  signal ddr_eop_in                         : std_logic_vector(c_ddr_eop_width-1 downto 0);
  signal ddr_keep_in                        : std_logic_vector(c_ddr_keep_width-1 downto 0);
  signal ddr_data_eop_keep_in               : std_logic_vector(g_ddr_header_width+g_ddr_payload_width+c_ddr_eop_width+c_ddr_keep_width-1 downto 0);

  signal ddr_rdy_cmd                        : std_logic;
  signal ddr_rdy_pld                        : std_logic;

  -- Halt/Rst signals
  type   t_hrst_state is (IDLE, HALT_GEN, WAIT_HALT_CMPLT, RST_GEN, RST1, RST2, RST3);
  signal ddr_axis_rstn                      : std_logic := '1';
  signal ddr_axis_halt                      : std_logic := '0';
  signal hrst_state                         : t_hrst_state := IDLE;

begin

  assert (g_ddr_payload_width = 256 or g_ddr_payload_width = 512)
  report "[acq_ddr3_axis_write] Only DDR Payload of 256 or 512 are supported!"
  severity failure;

  ----------------------------------------------------------------------------
  -- Register transaction limits
  -----------------------------------------------------------------------------
  lmt_pre_pkt_size_s <= std_logic_vector(lmt_pre_pkt_size_i);
  lmt_pos_pkt_size_s <= std_logic_vector(lmt_pos_pkt_size_i);
  lmt_full_pkt_size_s <= std_logic_vector(lmt_full_pkt_size_i);

  p_in_reg : process (ext_clk_i)
  begin
    if rising_edge(ext_clk_i) then
      if ext_rst_n_i = '0' then
        lmt_valid <= '0';
        --avoid detection of *_done pulses by setting them to 1
        lmt_pre_pkt_size_alig_s <= (others => '0');
        lmt_pos_pkt_size_alig_s <= (others => '0');
        lmt_full_pkt_size_alig_s <= (others => '0');
        lmt_shots_nb <= to_unsigned(1, lmt_shots_nb'length);
        lmt_curr_chan_id <= to_unsigned(0, lmt_curr_chan_id'length);
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

        end if;
      end if;
    end if;
  end process;

  -- Aggregated packet size
  lmt_pre_pkt_size_aggd <= unsigned(lmt_pre_pkt_size_alig_s);
  lmt_pos_pkt_size_aggd <= unsigned(lmt_pos_pkt_size_alig_s);
  lmt_full_pkt_size_aggd <= unsigned(lmt_full_pkt_size_alig_s);

  lmt_pre_pkt_size_aggd_byte_s <= lmt_pre_pkt_size_alig_s(lmt_pre_pkt_size_alig_s'left - c_ddr_payload_width_byte_log2 downto 0) &
                                    f_gen_std_logic_vector(c_ddr_payload_width_byte_log2, '0');
  lmt_pos_pkt_size_aggd_byte_s <= lmt_pos_pkt_size_alig_s(lmt_pos_pkt_size_alig_s'left - c_ddr_payload_width_byte_log2 downto 0) &
                                    f_gen_std_logic_vector(c_ddr_payload_width_byte_log2, '0');
  lmt_full_pkt_size_aggd_byte_s <= lmt_full_pkt_size_alig_s(lmt_full_pkt_size_alig_s'left - c_ddr_payload_width_byte_log2 downto 0) &
                                    f_gen_std_logic_vector(c_ddr_payload_width_byte_log2, '0');

  lmt_pre_pkt_size_aggd_byte <= unsigned(lmt_pre_pkt_size_aggd_byte_s);
  lmt_pos_pkt_size_aggd_byte <= unsigned(lmt_pos_pkt_size_aggd_byte_s);
  lmt_full_pkt_size_aggd_byte <= unsigned(lmt_full_pkt_size_aggd_byte_s);

  -- To previous flow control module (Acquisition FIFO)
  fifo_fc_stall_o <= pl_stall;
  fifo_fc_dreq_o <= pl_dreq;

  pl_stall <= pl_stall_cmd or pl_stall_pld;
  pl_dreq <= pl_dreq_cmd and pl_dreq_pld;

  -- DDR valid input signal
  p_ddr_valid_data_in : process(ext_clk_i)
  begin
    if rising_edge(ext_clk_i) then
      if ext_rst_n_i = '0' then
        ddr_data_in <= (others => '0');
        ddr_valid_in_t <= '0';
      else
        if fc_ack = '1' or ddr_valid_in_t = '0' then
          ddr_data_in <= fifo_fc_din_i;
        end if;

        if fifo_fc_valid_i = '1' and pl_stall = '0' then
          ddr_valid_in_t <= '1';
        elsif fc_ack = '1' then
          ddr_valid_in_t <= '0';
        end if;
      end if;
    end if;
  end process;

  -- Drive PLD EOP signal. This is needed as AXIS interface PLD TLAST signal must
  -- be asserted each time a new CMD transaction is issued.
  p_eop_pld : process(ext_clk_i)
  begin
    if rising_edge(ext_clk_i) then
      if ext_rst_n_i = '0' then
        ddr_eop_in <= "0";
        ddr_recv_pkt_cnt <= to_unsigned(0, ddr_recv_pkt_cnt'length);
      else
        -- New transaction
        if wr_start_i = '1' then
          ddr_recv_pkt_cnt <= to_unsigned(0, ddr_recv_pkt_cnt'length);
          ddr_eop_in <= "0";
        elsif ddr_valid_in = '1' then
          -- Count the number of valid packets received. This will wrap
          -- around the maximum number of samples per AXI packet
          ddr_recv_pkt_cnt <= ddr_recv_pkt_cnt + 1;

          if ddr_recv_pkt_cnt = to_unsigned(c_ddr_axis_max_wtt-2, ddr_recv_pkt_cnt'length) then -- will increment to last sample
            ddr_eop_in <= "1";
          else
            ddr_eop_in <= "0";
          end if;
        end if;
      end if;
    end if;
  end process;

  fc_ack <= '1' when ddr_valid_in_t = '1' and pl_stall = '0' else '0';
  ddr_valid_in <= ddr_valid_in_t and not pl_stall;

  -- Extract fifo trigger from ddr_data_in
  ddr_trigger_in <= ddr_data_in(c_acq_header_trigger_idx+c_ddr_header_bot_idx);

  -- Extract fifo data id from ddr_data_in
  ddr_data_id_in <= ddr_data_in(c_acq_header_id_top_idx+c_ddr_header_bot_idx downto
                          c_acq_header_id_bot_idx+c_ddr_header_bot_idx);

  ddr_header_in <= ddr_data_id_in & ddr_trigger_in;

  ----------------------------------------------------------------------------
  -- Generate command data valid for AXIS CMD interface, when we are in multishot mode.
  --   In this mode, we need to reissue a new command as our packet length is defined
  --    per shot. Also, out TLAST flag is generate on each last data pakcet of each
  --    transaction. Thus, needing to issue a new command for each TLAST on data stream.
  -----------------------------------------------------------------------------
  p_valid_axis_ms_cmd : process(ext_clk_i)
  begin
    if rising_edge(ext_clk_i) then
      if ext_rst_n_i = '0' then
        ddr_new_shot_coming <= '0';
      else
        -- Current transaction finished, but not all of them -> current shot
        -- finished and next one incoming
        if cnt_all_pkts_ct_done_pld_p = '1' and cnt_all_trans_done_pld_p = '0' then
          ddr_new_shot_coming <= '1';
        -- Hold signal until it's acknowledge
        elsif ddr_axis_cmd_valid_in = '1' then
          ddr_new_shot_coming <= '0';
        end if;
      end if;
    end if;
  end process;

  -- End of AXI datamover packet transaction. Reissue the packet transaction.
  p_reissue_cmd : process(ext_clk_i)
  begin
    if rising_edge(ext_clk_i) then
      if ext_rst_n_i = '0' then
        ddr_reissue_trans <= '0';
      else
        if ddr_valid_in = '1' then
          if ddr_eop_in = "1" then -- will increment to first sample of packet
            ddr_reissue_trans <= '1';
          else
            ddr_reissue_trans <= '0';
          end if;
        end if;
      end if;
    end if;
  end process;

  -- First address or transaction wrapped to init address
  ddr_addr_first <= '1' when ddr_addr_cnt_axis = ddr_addr_init else '0';
  -- First packet of transaction (new shot - used for multishot transactions) or
  -- when we make large (larger than c_ddr_axis_max_wtt words) transfers
  ddr_axis_cmd_valid_in <= '1' when ddr_valid_in = '1' and (ddr_addr_first = '1' or
                                                            ddr_new_shot_coming = '1' or
                                                            ddr_reissue_trans = '1'
                                                           ) else '0';

  ----------------------------------------------------------------------------
  -- Generate address to external controller
  -----------------------------------------------------------------------------

  -- Here we hold the external address
  -- for as long as we still have data to write and just shift the mask.
  --
  -- As we have the restriction of g_ddr_payload_width and g_data_width to be
  -- both power of 2, we can safelly assume that the counter will wrap around
  -- at the correct count and the mask will select the appropriate data

  wr_init_addr_alig <= wr_init_addr_i(wr_init_addr_i'left downto c_ddr_align_shift) &
                             f_gen_std_logic_vector(c_ddr_align_shift, '0');
  wr_end_addr_alig <= wr_end_addr_i(wr_end_addr_i'left downto c_ddr_align_shift) &
                             f_gen_std_logic_vector(c_ddr_align_shift, '0');

  p_ddr_addr_cnt : process(ext_clk_i)
  begin
    if rising_edge(ext_clk_i) then
      if ext_rst_n_i = '0' then
        ddr_addr_cnt_axis <= to_unsigned(0, ddr_addr_cnt_axis'length);
        -- FIXME: Reset the init/end register cause fast acquisition
        -- data path to fail on hw or sw trigger acquisitions.
        -- This might be related to the fact that these addresses
        -- might not be properly configured.
      else

        if wr_start_i = '1' then
          -- This address must be word-aligned
          ddr_addr_cnt_axis <= unsigned(wr_init_addr_alig);
          ddr_addr_init <= unsigned(wr_init_addr_alig);
          ddr_addr_max <= unsigned(wr_end_addr_alig);
        elsif ddr_valid_in = '1' then -- This represents a successful transfer

          -- To Flow Control module
          -- Get ready for the next valid transaction
          ddr_addr_cnt_axis <= ddr_addr_cnt_axis + c_addr_ddr_inc_axis;
          -- Wrap counters if we go over the limit
          if ddr_addr_cnt_axis = ddr_addr_max then
            ddr_addr_cnt_axis <= ddr_addr_init;
          end if;
        end if;
      end if;
    end if;
  end process;

  -- To Flow Control module
  ddr_addr_in_axis <= std_logic_vector(ddr_addr_cnt_axis);

  -- Debug outputs
  dbg_ddr_addr_cnt_axis_o <= std_logic_vector(ddr_addr_cnt_axis);
  dbg_ddr_addr_init_o <= std_logic_vector(ddr_addr_init);
  dbg_ddr_addr_max_o <= std_logic_vector(ddr_addr_max);

  -----------------------------------------------------------------------------
  -- Store DDR Trigger address
  -----------------------------------------------------------------------------
  p_ddr_trig_addr : process(ext_clk_i)
  begin
    if rising_edge(ext_clk_i) then
      if ext_rst_n_i = '0' then
        ddr_trig_addr <= to_unsigned(0, ddr_trig_addr'length);
        ddr_trig_captured <= '0';
      else
        -- Default trigger address is in the beginning of the memory section
        if wr_start_i = '1' then
          ddr_trig_addr <= unsigned(wr_init_addr_alig);
          ddr_trig_captured <= '0';
        -- Store DDR address if there was a trigger occurrence
        elsif (ddr_trigger_in = '1' and ddr_valid_in = '1') or
            -- We have transfered all samples, but no trigger occurred
            (cnt_all_trans_done_p = '1' and ddr_trig_captured = '0') then
          ddr_trig_addr <= ddr_addr_cnt_axis;
          ddr_trig_captured <= '1';
        end if;
      end if;
    end if;
  end process;

  lmt_ddr_trig_addr_o  <= std_logic_vector(ddr_trig_addr);

  -----------------------------------------------------------------------------
  -- Counters
  -----------------------------------------------------------------------------

  -- Only count up to the sample when in pre_trigger or post_trigger and we haven't
  -- acquire enough samples
  pl_cmd_cnt_en <= '1' when (unsigned(dbg_cmd_pkt_ct_cnt) < lmt_pre_pkt_size and
                                fc_data_id_cmd = "010") or -- Pre-trigger
                                (unsigned(dbg_cmd_pkt_ct_cnt) < lmt_full_pkt_size and
                                fc_data_id_cmd = "100") -- Post-trigger
                            else '0';

  -- Counter to detect end of transaction only
  acq_cmd_cnt_en <= '1' when pl_cmd_cnt_en = '1' and pl_pkt_sent_cmd = '1' else '0';

  -- Only count up to the sample when in pre_trigger or post_trigger and we haven't
  -- acquire enough samples
  pl_pld_cnt_en <= '1' when (unsigned(dbg_pld_pkt_ct_cnt) < lmt_pre_pkt_size and
                                fc_data_id_cmd = "010") or -- Pre-trigger
                                (unsigned(dbg_pld_pkt_ct_cnt) < lmt_full_pkt_size and
                                fc_data_id_cmd = "100") -- Post-trigger
                            else '0';

  -- Counter to detect end of transaction only
  acq_pld_cnt_en <= '1' when pl_pld_cnt_en = '1' and pl_pkt_sent_pld = '1' else '0';

  cmp_acq_cnt_cmd : acq_cnt
  port map
  (
    -- DDR3 external clock
    clk_i                                   => ext_clk_i,
    rst_n_i                                 => ext_rst_n_i,

    cnt_all_pkts_ct_done_p_o                => open,
    cnt_all_trans_done_p_o                  => open,
    cnt_en_i                                => acq_cmd_cnt_en,

    -- Size of the transaction in g_fifo_size bytes
    lmt_pkt_size_i                          => lmt_full_pkt_size_aggd,
    -- Number of shots in this acquisition
    lmt_shots_nb_i                          => lmt_shots_nb,
    -- Acquisition limits valid signal. Qualifies lmt_pkt_size_i and lmt_shots_nb_i
    lmt_valid_i                             => lmt_valid,

    dbg_pkt_ct_cnt_o                        => dbg_cmd_pkt_ct_cnt,
    dbg_shots_cnt_o                         => dbg_cmd_shots_cnt
  );

  cmp_acq_cnt_pld : acq_cnt
  port map
  (
    -- DDR3 external clock
    clk_i                                   => ext_clk_i,
    rst_n_i                                 => ext_rst_n_i,

    cnt_all_pkts_ct_done_p_o                => cnt_all_pkts_ct_done_pld_p,
    cnt_all_trans_done_p_o                  => cnt_all_trans_done_pld_p,
    cnt_en_i                                => acq_pld_cnt_en,

    -- Size of the transaction in g_fifo_size bytes
    lmt_pkt_size_i                          => lmt_full_pkt_size_aggd,
    -- Number of shots in this acquisition
    lmt_shots_nb_i                          => lmt_shots_nb,
    -- Acquisition limits valid signal. Qualifies lmt_pkt_size_i and lmt_shots_nb_i
    lmt_valid_i                             => lmt_valid,

    dbg_pkt_ct_cnt_o                        => dbg_pld_pkt_ct_cnt,
    dbg_shots_cnt_o                         => dbg_pld_shots_cnt
  );

  -- Wait for the last pulse
  p_cnt_wait_last_done : process(ext_clk_i)
  begin
    if rising_edge(ext_clk_i) then
      if ext_rst_n_i = '0' then
        cnt_all_trans_done_pld_l <= '0';
      else

        if cnt_all_trans_done_pld_p = '1' then
          cnt_all_trans_done_pld_l <= '1';
        elsif cnt_all_trans_done_p = '1' then
          cnt_all_trans_done_pld_l <= '0';
        end if;

      end if;
    end if;
  end process;

  cnt_all_trans_done_p <= cnt_all_trans_done_pld_l;

  lmt_all_trans_done_p_o <= cnt_all_trans_done_p;

  p_ddr_keep_in : process(ext_clk_i)
  begin
    if rising_edge(ext_clk_i) then
      if ext_rst_n_i = '0' then
        ddr_keep_in <= (others => '1');
      else
        if fifo_fc_valid_i = '1' then
          ddr_keep_in <= (others => '1');
        end if;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- DDR3 AXIS Command Interface
  -----------------------------------------------------------------------------
  cmp_fc_source_cmd : fc_source
  generic map (
    g_header_in_width                       => g_ddr_header_width,
    g_data_width                            => 0, -- Dummy value
    g_pkt_size_width                        => c_pkt_size_width,
    g_addr_width                            => g_ddr_addr_width,
    g_with_fifo_inferred                    => true,
    g_pipe_size                             => g_fc_pipe_size
  )
  port map (
    clk_i                                   => ext_clk_i,
    rst_n_i                                 => ext_rst_n_i,

    pl_data_i                               => (others => '0'),
    pl_addr_i                               => ddr_addr_in_axis,
    pl_valid_i                              => ddr_axis_cmd_valid_in,

    pl_dreq_o                               => pl_dreq_cmd,
    pl_stall_o                              => pl_stall_cmd,
    pl_pkt_sent_o                           => pl_pkt_sent_cmd,

    pl_rst_trans_i                          => pl_rst_trans,

    -- This signals cross clock domains, but lmt_pkt_size_i is asserted long before
    -- (Wishbone CPU register) the lmt_valid_ext signal, which is synchronized
    -- to ext_clk domain
    lmt_pre_pkt_size_i                      => lmt_pre_pkt_size_aggd,
    lmt_pos_pkt_size_i                      => lmt_pos_pkt_size_aggd,
    lmt_full_pkt_size_i                     => lmt_full_pkt_size_aggd,
    lmt_valid_i                             => lmt_valid,

    fc_dout_o                               => fc_header_cmd,
    fc_valid_o                              => fc_valid_cmd,
    fc_addr_o                               => fc_addr,
    fc_sof_o                                => fc_sof_cmd,
    fc_eof_o                                => fc_eof_cmd,

    fc_stall_i                              => fc_stall_cmd,
    fc_dreq_i                               => fc_dreq_cmd
  );

  -----------------------------------------------------------------------------
  -- DDR3 AXIS Write Interface
  -----------------------------------------------------------------------------
  cmp_fc_source_pld : fc_source
  generic map (
    g_header_in_width                       => g_ddr_header_width,
    g_data_width                            => c_ddr_payload_eop_keep_width,
    g_pkt_size_width                        => c_pkt_size_width,
    g_addr_width                            => 1, -- Dummy value
    g_with_fifo_inferred                    => true,
    g_pipe_size                             => g_fc_pipe_size
  )
  port map (
    clk_i                                   => ext_clk_i,
    rst_n_i                                 => ext_rst_n_i,

    pl_data_i                               => ddr_data_eop_keep_in,
    pl_addr_i                               => (others => '0'),
    pl_valid_i                              => ddr_valid_in,

    pl_dreq_o                               => pl_dreq_pld,
    pl_stall_o                              => pl_stall_pld,
    pl_pkt_sent_o                           => pl_pkt_sent_pld,

    pl_rst_trans_i                          => pl_rst_trans,

    -- This signals cross clock domains, but lmt_pkt_size_i is asserted long before
    -- (Wishbone CPU register) the lmt_valid_ext signal, which is synchronized
    -- to ext_clk domain
    lmt_pre_pkt_size_i                      => lmt_pre_pkt_size_aggd,
    lmt_pos_pkt_size_i                      => lmt_pos_pkt_size_aggd,
    lmt_full_pkt_size_i                     => lmt_full_pkt_size_aggd,
    lmt_valid_i                             => lmt_valid,

    fc_dout_o                               => fc_dout,
    fc_valid_o                              => fc_valid_pld,
    fc_addr_o                               => open,
    fc_sof_o                                => fc_sof_pld,
    fc_eof_o                                => fc_eof_pld,

    fc_stall_i                              => fc_stall_pld,
    fc_dreq_i                               => fc_dreq_pld
  );

  -- Concatenate data EOP + (header + data) + keep
  ddr_data_eop_keep_in <= ddr_data_in & ddr_eop_in & ddr_keep_in;

  -- Extract fifo trigger from fc_dout
  fc_trigger_cmd <= fc_dout(c_acq_header_trigger_idx+c_fc_header_bot_idx);

  -- Extract fifo data id from fc_dout
  fc_data_id_cmd <= fc_dout(c_acq_header_id_top_idx+c_fc_header_bot_idx downto
                          c_acq_header_id_bot_idx+c_fc_header_bot_idx);

  -----------------------------------------------------------------------------
  -- AXIS Soft Shutdown Interface
  -----------------------------------------------------------------------------

  -- We reset on two situations: a regular reset (startup or reset trigger) or
  -- when we abort an acquisition (fsm_stop signal). For this to work seamlessly
  -- with AXIS interface, we must drive the halt/rst signals properly

  -- First, generate halt signal to force AXIS datamover to shutdown its engine.
  -- We can use the same as rst, as it's long enough

  -- Secondly, we must look into axis_S2mm_halt_cmplt_i signal. When it completes
  -- its shutdown (asserted high),. we must then reset the AXIS core using
  -- axis_s2mm_rstn_o signal

  -- AXIS Halt/Rst state machine.
  p_axis_halt_rst_fsm : process(ext_clk_i)
  begin
    if rising_edge(ext_clk_i) then
      case hrst_state is
        -- Waits for a halt command to start
        when IDLE =>
          ddr_axis_rstn <= '1';
          ddr_axis_halt <= '0';

          if ext_rst_n_i = '0' then
            hrst_state <= HALT_GEN;
          end if;

        when HALT_GEN =>
          ddr_axis_halt <= '1';
          hrst_state <= WAIT_HALT_CMPLT;

        when WAIT_HALT_CMPLT =>
          -- Wait for AXIS core to gracefully shutdown then reset the core
          -- and deasserts halt
          if axis_s2mm_halt_cmplt_i = '1' then
            ddr_axis_halt <= '0';
            hrst_state <= RST_GEN;
          end if;

        -- Generates a reset for the core
        when RST_GEN =>
          ddr_axis_rstn <= '0';
          hrst_state <= RST1;

        -- Wait for a minimum of 3 clock cycles for a successful reset
        -- (axi datamover v5.1, page 16, table 2-6, about m_axi_s2mm_aresetn)
        when RST1 =>
          hrst_state <= RST2;

        when RST2 =>
          hrst_state <= RST3;

        -- Deasserts rst and go back to the beginning
        when RST3 =>
          ddr_axis_rstn <= '1';
          hrst_state <= IDLE;

        when others =>
          ddr_axis_rstn <= '1';
          ddr_axis_halt <= '0';
          hrst_state <= IDLE;

      end case;
    end if;
  end process;

  axis_s2mm_rstn_o                          <= ddr_axis_rstn;
  axis_s2mm_halt_o                          <= ddr_axis_halt;

  -----------------------------------------------------------------------------
  -- AXIS Interface
  -----------------------------------------------------------------------------

  pl_rst_trans <= '0';

  ddr_rdy_cmd <= axis_s2mm_cmd_tready_i;
  ddr_rdy_pld <= axis_s2mm_pld_tready_i;

  fc_stall_cmd <= not ddr_rdy_cmd;
  fc_stall_pld <= not ddr_rdy_pld;

  fc_dreq_cmd <= '1'; -- always request new data, even when the next module
                      -- in the pipeline cannot receive (ddr is not ready).
                      -- The flow control module will take care of this
  fc_dreq_pld <= '1';

  -- To/From AXIS Stream to Memory Mapped Commands
  axis_s2mm_cmd_tvalid_o <= fc_valid_cmd;

  -- With 23 bits we can transfer up to 8MB of data.  We always set the datamover
  -- to transfer the maximum ammount of data. If we finish early, we can just
  -- abort the transaction asserting the LTAST stream signal (typical case).
  -- WARNING: the datamover MUST be set the support Indeterminate BTT!
  axis_s2mm_cmd_tdata_o(c_axis_cmd_tdata_btt_top_idx downto
    c_axis_cmd_tdata_btt_bot_idx)                             <=
   std_logic_vector(to_unsigned(c_ddr_axis_max_btt, c_axis_cmd_tdata_btt_width));             -- cmd_btt (Bytes to transfer)
  axis_s2mm_cmd_tdata_o(c_axis_cmd_tdata_type_idx)            <= '1';                         -- cmd_type (1 = increment address)
  axis_s2mm_cmd_tdata_o(c_axis_cmd_tdata_dsa_top_idx downto
    c_axis_cmd_tdata_dsa_bot_idx)                             <= "000000";                    -- cmd_dsa
  axis_s2mm_cmd_tdata_o(c_axis_cmd_tdata_last_idx)            <= fc_valid_cmd;                -- cmd_last
  axis_s2mm_cmd_tdata_o(c_axis_cmd_tdata_drr_idx)             <= '0';                         -- cmd_drr (0 = no realignment requested)
  axis_s2mm_cmd_tdata_o(c_axis_cmd_tdata_addr_top_idx downto
    c_axis_cmd_tdata_addr_bot_idx)                            <=
    f_gen_std_logic_vector(c_axis_cmd_tdata_addr_width-g_ddr_addr_width, '0') & fc_addr;      -- cmd_addr
  axis_s2mm_cmd_tdata_o(c_axis_cmd_tdata_tag_top_idx downto
    c_axis_cmd_tdata_tag_bot_idx)                             <= "0000";                      -- cmd_tag
  axis_s2mm_cmd_tdata_o(c_axis_cmd_tdata_pad_top_idx downto
    c_axis_cmd_tdata_pad_bot_idx)                             <= (others => '0');             -- cmd_pad

  -- We always allow address request
  axis_s2mm_allow_addr_req_o <= '1';

  fc_eop_pld <= '1' when fc_dout(c_eop_high downto c_eop_low) = "1" else '0';

  -- To/From AXIS Memory Mapped to Stream Commands
  axis_s2mm_pld_tdata_o  <= fc_dout(c_data_high downto c_data_low);
  axis_s2mm_pld_tlast_o  <= fc_eof_pld or fc_eop_pld;
  axis_s2mm_pld_tkeep_o  <= fc_dout(c_keep_high downto c_keep_low);
  axis_s2mm_pld_tvalid_o <= fc_valid_pld;

end rtl;
