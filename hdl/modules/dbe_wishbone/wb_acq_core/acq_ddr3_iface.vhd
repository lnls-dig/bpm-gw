------------------------------------------------------------------------------
-- Title      : BPM ACQ Custom <-> DDR3 Interface conversion
------------------------------------------------------------------------------
-- Author     : Lucas Maziero Russo
-- Company    : CNPEM LNLS-DIG
-- Created    : 2013-22-10
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: Module for the performing interface conversion between custom
--               interface (much alike the Wishbone B4 Pipelined) and DDR3 UI
--               (BC4 or BL8 with single data transaction per valid cycle)
--               Xilinx interface.
--
--             As we only got one cycle latency pipeline until the fc_source
--               module, we don't need to worry about flow control
--
--             TODO: modularize read/write transactions into modules (paths),
--                    like "ddr3_write_path" and "ddr3_read_path", for instance.
-------------------------------------------------------------------------------
-- Copyright (c) 2013 CNPEM
-- Licensed under GNU Lesser General Public License (LGPL) v3.0
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2013-31-10  1.0      lucas.russo        Created
-- 2014-17-09  2.0      lucas.russo        Remove output data aggregation
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

entity acq_ddr3_iface is
generic
(
  g_acq_num_channels                        : natural := 1;
  g_acq_channels                            : t_acq_chan_param_array;
  g_fc_pipe_size                            : natural := 4;
  -- Do not modify these! As they are dependent of the memory controller generated!
  g_ddr_payload_width                       : natural := 256;     -- be careful changing these!
  g_ddr_dq_width                            : natural := 64;      -- be careful changing these!
  g_ddr_addr_width                          : natural := 32       -- be careful changing these!
);
port
(
  -- DDR3 external clock
  ext_clk_i                                 : in  std_logic;
  ext_rst_n_i                               : in  std_logic;

  -- Flow protocol to interface with external SDRAM. Evaluate the use of
  -- Wishbone Streaming protocol.
  fifo_fc_din_i                             : in std_logic_vector(g_ddr_payload_width-1 downto 0);
  fifo_fc_valid_i                           : in std_logic;
  fifo_fc_addr_i                            : in std_logic_vector(g_ddr_addr_width-1 downto 0);
  fifo_fc_sof_i                             : in std_logic;
  fifo_fc_eof_i                             : in std_logic;
  fifo_fc_dreq_o                            : out std_logic;
  fifo_fc_stall_o                           : out std_logic;

  wr_start_i                                : in std_logic;
  wr_init_addr_i                            : in std_logic_vector(g_ddr_addr_width-1 downto 0);

  lmt_all_trans_done_p_o                    : out std_logic;
  lmt_rst_i                                 : in std_logic;

  -- Current channel selection ID
  lmt_curr_chan_id_i                        : in unsigned(c_chan_id_width-1 downto 0);
  -- Size of the transaction in g_fifo_size bytes
  lmt_pkt_size_i                            : in unsigned(c_pkt_size_width-1 downto 0);
  -- Number of shots in this acquisition
  lmt_shots_nb_i                            : in unsigned(c_shots_size_width-1 downto 0);
  -- Acquisition limits valid signal. Qu  alifies lmt_fifo_pkt_size_i and lmt_shots_nb_i
  lmt_valid_i                               : in std_logic;

  -- Xilinx DDR3 UI Interface
  ui_app_addr_o                             : out std_logic_vector(g_ddr_addr_width-1 downto 0);
  ui_app_cmd_o                              : out std_logic_vector(2 downto 0);
  ui_app_en_o                               : out std_logic;
  ui_app_rdy_i                              : in std_logic;

  ui_app_wdf_data_o                         : out std_logic_vector(g_ddr_payload_width-1 downto 0);
  ui_app_wdf_end_o                          : out std_logic;
  ui_app_wdf_mask_o                         : out std_logic_vector(g_ddr_payload_width/8-1 downto 0);
  ui_app_wdf_wren_o                         : out std_logic;
  ui_app_wdf_rdy_i                          : in std_logic;

  ui_app_rd_data_i                          : in std_logic_vector(g_ddr_payload_width-1 downto 0);
  ui_app_rd_data_end_i                      : in std_logic;
  ui_app_rd_data_valid_i                    : in std_logic;

  ui_app_req_o                              : out std_logic;
  ui_app_gnt_i                              : in std_logic
);
end acq_ddr3_iface;

architecture rtl of acq_ddr3_iface is

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
  constant c_ddr_mask_width                 : natural := g_ddr_payload_width/8;

  alias c_ddr_payload_width                 is g_ddr_payload_width;

  -- Data increment constant
  constant c_addr_ddr_inc                   : natural := g_ddr_payload_width/g_ddr_dq_width;

  -- Flow Control constants
  constant c_pkt_size_width                 : natural := 32;
  ---------constant c_pipe_size                      : natural := 4;
  constant c_addr_cnt_width                 : natural := c_max_ddr_payload_ratio_log2;

  -- UI Commands
  constant c_ui_cmd_write                   : std_logic_vector(2 downto 0) := "000";
  constant c_ui_cmd_read                    : std_logic_vector(2 downto 0) := "001";

  -- Constants for data + mask aggregate signal
  constant c_mask_low                       : natural := 0;
  constant c_mask_high                      : natural := c_ddr_mask_width + c_mask_low -1;
  constant c_data_low                       : natural := c_mask_high + 1;
  constant c_data_high                      : natural := c_ddr_payload_width + c_data_low -1;

  -- Constants for ddr3 address bits
  constant c_ddr_align_shift                : natural := f_log2_size(c_addr_ddr_inc);

  subtype t_addr_cnt is unsigned(c_addr_cnt_width-1 downto 0);
  type t_addr_cnt_array is array (natural range <>) of t_addr_cnt;

  subtype t_addr_cnt_s is std_logic_vector(c_addr_cnt_width-1 downto 0);
  type t_addr_cnt_s_array is array (natural range <>) of t_addr_cnt_s;

  -- Flow control signals
  signal lmt_pkt_size                       : unsigned(c_pkt_size_width-1 downto 0);
  signal lmt_pkt_size_s                     : std_logic_vector(c_pkt_size_width-1 downto 0);
  signal lmt_pkt_size_alig_s                : std_logic_vector(c_pkt_size_width-1 downto 0);
  signal lmt_shots_nb                       : unsigned(c_shots_size_width-1 downto 0);
  signal lmt_curr_chan_id                   : unsigned(c_chan_id_width-1 downto 0);
  signal lmt_valid                          : std_logic;
  signal fc_dout                            : std_logic_vector(g_ddr_payload_width+c_ddr_mask_width-1 downto 0);
  signal fc_valid_app                       : std_logic;
  signal fc_valid_app_wdf                   : std_logic;
  signal fc_addr                            : std_logic_vector(g_ddr_addr_width-1 downto 0);
  signal fc_stall_app                       : std_logic;
  signal fc_dreq_app                        : std_logic;
  signal fc_stall_app_wdf                   : std_logic;
  signal fc_dreq_app_wdf                    : std_logic;
  signal fc_ack                             : std_logic;

  signal valid_trans_app                    : std_logic;
  signal valid_trans_app_d0                 : std_logic;
  signal valid_trans_app_wdf                : std_logic;
  signal cnt_all_trans_done_app_p           : std_logic;
  signal cnt_all_trans_done_wdf_p           : std_logic;
  signal cnt_all_trans_done_app_l           : std_logic;
  signal cnt_all_trans_done_wdf_l           : std_logic;
  signal cnt_all_trans_done_p               : std_logic;
  signal wr_init_addr_alig                  : std_logic_vector(g_ddr_addr_width-1 downto 0);

  -- Plain interface control
  signal pl_dreq                            : std_logic;
  signal pl_stall                           : std_logic;
  signal pl_stall_d0                        : std_logic;
  signal pl_dreq_app                        : std_logic;
  signal pl_stall_app                       : std_logic;
  signal pl_pkt_sent_app                    : std_logic;
  signal pl_dreq_app_wdf                    : std_logic;
  signal pl_stall_app_wdf                   : std_logic;
  signal pl_pkt_sent_app_wdf                : std_logic;
  signal pl_rst_trans                       : std_logic;

  signal pl_pkt_thres_hit_app               : std_logic;
  signal pl_pkt_thres_hit_wdf               : std_logic;

  -- DDR3 Signals
  signal ddr_data_in                        : std_logic_vector(g_ddr_payload_width-1 downto 0);
  signal ddr_addr_cnt                       : unsigned(g_ddr_addr_width-1 downto 0);
  signal ddr_addr_in                        : std_logic_vector(g_ddr_addr_width-1 downto 0);
  signal ddr_valid_in                       : std_logic;
  signal ddr_valid_in_t                     : std_logic;

  signal ddr_mask_in                        : std_logic_vector(c_ddr_mask_width-1 downto 0);
  signal ddr_data_mask_in                   : std_logic_vector(g_ddr_payload_width+c_ddr_mask_width-1 downto 0);

  signal ddr_rdy_app                        : std_logic;
  signal ddr_rdy_app_wdf                    : std_logic;

  -- DDR3 Arbitrer Signals
  signal ddr_req                            : std_logic;

begin

  assert (g_ddr_payload_width = 256 or g_ddr_payload_width = 512)
  report "[acq_ddr3_iface] Only DDR Payload of 256 or 512 are supported!"
  severity failure;

  ----------------------------------------------------------------------------
  -- Register transaction limits
  -----------------------------------------------------------------------------
  lmt_pkt_size_s <= std_logic_vector(lmt_pkt_size_i);

  p_in_reg : process (ext_clk_i)
  begin
    if rising_edge(ext_clk_i) then
      if ext_rst_n_i = '0' then
        lmt_valid <= '0';
        --avoid detection of *_done pulses by setting them to 1
        lmt_pkt_size_alig_s <= (others => '0');
        lmt_shots_nb <= to_unsigned(1, lmt_shots_nb'length);
        lmt_curr_chan_id <= to_unsigned(0, lmt_curr_chan_id'length);
      else
        lmt_valid <= lmt_valid_i;

        if lmt_valid_i = '1' then

          -- the packet size here is constrained by the relation
          -- f_log2(<output data width>/<input channel data width>),
          -- as we aggregate data by that amount to send it to the ddr3 controller
          case c_fc_payload_ratio_log2(to_integer(lmt_curr_chan_id_i)) is
            when 1 =>
              lmt_pkt_size_alig_s <= f_gen_std_logic_vector(1, '0') &
                                    lmt_pkt_size_s(lmt_pkt_size_s'left downto 1);
            when 2 =>
              lmt_pkt_size_alig_s <= f_gen_std_logic_vector(2, '0') &
                                    lmt_pkt_size_s(lmt_pkt_size_s'left downto 2);
            when 3 =>
              lmt_pkt_size_alig_s <= f_gen_std_logic_vector(3, '0') &
                                    lmt_pkt_size_s(lmt_pkt_size_s'left downto 3);
            when others =>
              lmt_pkt_size_alig_s <= f_gen_std_logic_vector(1, '0') &
                                    lmt_pkt_size_s(lmt_pkt_size_s'left downto 1);
          end case;

          lmt_shots_nb <= lmt_shots_nb_i;
          lmt_curr_chan_id <= lmt_curr_chan_id_i;
        end if;
      end if;
    end if;
  end process;

  lmt_pkt_size <= unsigned(lmt_pkt_size_alig_s);

  -- To previous flow control module (Acquisition FIFO)
  fifo_fc_stall_o <= pl_stall;
  fifo_fc_dreq_o <= pl_dreq;

  pl_stall <= pl_stall_app or pl_stall_app_wdf;
  pl_dreq <= pl_dreq_app and pl_dreq_app_wdf;

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

  fc_ack <= '1' when ddr_valid_in_t = '1' and pl_stall = '0' else '0';
  ddr_valid_in <= ddr_valid_in_t and not pl_stall;

  -- WARNING: FIXME?
  -- We might have problems with this if other device, previously granted access
  -- to DDR3 controller, doesn't release it and we start an acquisition.
  -- In this scenario the Acquisition FIFO will become full and we will loose
  -- data!
  --
  ---- Drive DDR request signal upon receiving SOF
  p_ddr_drive_req : process(ext_clk_i)
  begin
    if rising_edge(ext_clk_i) then
      if ext_rst_n_i = '0' then
        ddr_req <= '0';
      else
        -- Get access to DDR3 from arbitrer. Maybe its better to
        -- hold the ddr_req signal until the end of the acquisition
        if fifo_fc_valid_i = '1' and fifo_fc_sof_i = '1' then
          ddr_req <= '1';
        elsif cnt_all_trans_done_p = '1' then -- release access only when this
                                                -- acquisition is done
          ddr_req <= '0';
        end if;
      end if;
    end if;
  end process;

  ui_app_req_o <= ddr_req;

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

  p_ddr_addr_cnt : process(ext_clk_i)
  begin
    if rising_edge(ext_clk_i) then
      if ext_rst_n_i = '0' then
        ddr_addr_cnt <= to_unsigned(0, ddr_addr_cnt'length);
      else

        if wr_start_i = '1' then
          -- This address must be word-aligned
          ddr_addr_cnt <= unsigned(wr_init_addr_alig);
        elsif fc_ack = '1' then -- This represents a successful transfer

          -- To Flow Control module
          -- Get ready for the next valid transaction
          ddr_addr_cnt <= ddr_addr_cnt + c_addr_ddr_inc;

        end if;
      end if;
    end if;
  end process;

  -- To Flow Control module
  ddr_addr_in <= std_logic_vector(ddr_addr_cnt);

  -----------------------------------------------------------------------------
  -- Counters
  -----------------------------------------------------------------------------

  cmp_acq_cnt_app : acq_cnt
  port map
  (
    -- DDR3 external clock
    clk_i                                     => ext_clk_i,
    rst_n_i                                   => ext_rst_n_i,

    cnt_all_pkts_ct_done_p_o                  => open,
    cnt_all_trans_done_p_o                    => cnt_all_trans_done_app_p,
    cnt_en_i                                  => pl_pkt_sent_app,

    -- Size of the transaction in g_fifo_size bytes
    lmt_pkt_size_i                            => lmt_pkt_size,
    -- Number of shots in this acquisition
    lmt_shots_nb_i                            => lmt_shots_nb,
    -- Acquisition limits valid signal. Qualifies lmt_pkt_size_i and lmt_shots_nb_i
    lmt_valid_i                               => lmt_valid
  );

  cmp_acq_cnt_wdf : acq_cnt
  port map
  (
    -- DDR3 external clock
    clk_i                                     => ext_clk_i,
    rst_n_i                                   => ext_rst_n_i,

    cnt_all_pkts_ct_done_p_o                  => open,
    cnt_all_trans_done_p_o                    => cnt_all_trans_done_wdf_p,
    cnt_en_i                                  => pl_pkt_sent_app_wdf,

    -- Size of the transaction in g_fifo_size bytes
    lmt_pkt_size_i                            => lmt_pkt_size,
    -- Number of shots in this acquisition
    lmt_shots_nb_i                            => lmt_shots_nb,
    -- Acquisition limits valid signal. Qualifies lmt_pkt_size_i and lmt_shots_nb_i
    lmt_valid_i                               => lmt_valid
  );

  -- Wait for the last pulse
  p_cnt_wait_last_done : process(ext_clk_i)
  begin
    if rising_edge(ext_clk_i) then
      if ext_rst_n_i = '0' then
        cnt_all_trans_done_app_l <= '0';
        cnt_all_trans_done_wdf_l <= '0';
      else
        if cnt_all_trans_done_app_p = '1' then
          cnt_all_trans_done_app_l <= '1';
        elsif cnt_all_trans_done_p = '1' then
          cnt_all_trans_done_app_l <= '0';
        end if;

        if cnt_all_trans_done_wdf_p = '1' then
          cnt_all_trans_done_wdf_l <= '1';
        elsif cnt_all_trans_done_p = '1' then
          cnt_all_trans_done_wdf_l <= '0';
        end if;

      end if;
    end if;
  end process;

  cnt_all_trans_done_p <= cnt_all_trans_done_app_l and cnt_all_trans_done_wdf_l;

  lmt_all_trans_done_p_o <= cnt_all_trans_done_p;

  p_ddr_mask_in : process(ext_clk_i)
  begin
    if rising_edge(ext_clk_i) then
      if ext_rst_n_i = '0' then
        ddr_mask_in <= (others => '0');
      else
        if fifo_fc_valid_i = '1' then
          ddr_mask_in <= (others => '0');
        end if;
      end if;
    end if;
  end process;

  -- We have 2 independent interfaces for driving the APP UI Xilinx interface
  -- and another one for the APP WDF UI Xilinx interface.
  --
  -- For now we are just tieing the 2 togheter and issuing the APP UI and
  -- WDG UI synchronously

  -----------------------------------------------------------------------------
  -- DDR3 UI Command Interface
  -----------------------------------------------------------------------------
  cmp_fc_source_app : fc_source
  generic map (
    g_data_width                           => 1, -- Dummy value
    g_pkt_size_width                       => c_pkt_size_width,
    g_addr_width                           => g_ddr_addr_width,
    g_with_fifo_inferred                   => true,
    g_pipe_size                            => g_fc_pipe_size
  )
  port map (
    clk_i                                   => ext_clk_i,
    rst_n_i                                 => ext_rst_n_i,

    pl_data_i                               => (others => '0'),
    pl_addr_i                               => ddr_addr_in,
    pl_valid_i                              => ddr_valid_in,

    pl_dreq_o                               => pl_dreq_app,
    pl_stall_o                              => pl_stall_app,
    pl_pkt_sent_o                           => pl_pkt_sent_app,

    pl_rst_trans_i                          => pl_rst_trans,

    lmt_pkt_size_i                          => lmt_pkt_size,
    lmt_valid_i                             => lmt_valid,

    fc_dout_o                               => open,
    fc_valid_o                              => fc_valid_app,
    fc_addr_o                               => fc_addr,
    fc_sof_o                                => open,
    fc_eof_o                                => open,

    fc_stall_i                              => fc_stall_app,
    fc_dreq_i                               => fc_dreq_app
  );

  -- Concatenate data + mask
  ddr_data_mask_in <= ddr_data_in & ddr_mask_in;

  -----------------------------------------------------------------------------
  -- DDR3 UI Data Write Interface
  -----------------------------------------------------------------------------
  cmp_fc_source_app_wdf : fc_source
  generic map (
    g_data_width                           => g_ddr_payload_width + c_ddr_mask_width,
    g_pkt_size_width                       => c_pkt_size_width,
    g_addr_width                           => 1, -- Dummy value
    g_with_fifo_inferred                   => true,
    g_pipe_size                            => g_fc_pipe_size
  )
  port map (
    clk_i                                   => ext_clk_i,
    rst_n_i                                 => ext_rst_n_i,

    pl_data_i                               => ddr_data_mask_in,
    pl_addr_i                               => (others => '0'),
    pl_valid_i                              => ddr_valid_in,

    pl_dreq_o                               => pl_dreq_app_wdf,
    pl_stall_o                              => pl_stall_app_wdf,
    pl_pkt_sent_o                           => pl_pkt_sent_app_wdf,

    pl_rst_trans_i                          => pl_rst_trans,

    lmt_pkt_size_i                          => lmt_pkt_size,
    lmt_valid_i                             => lmt_valid,

    fc_dout_o                               => fc_dout,
    fc_valid_o                              => fc_valid_app_wdf,
    fc_addr_o                               => open,
    fc_sof_o                                => open,
    fc_eof_o                                => open,

    fc_stall_i                              => fc_stall_app_wdf,
    fc_dreq_i                               => fc_dreq_app_wdf
  );

  pl_rst_trans <= '0';

  ddr_rdy_app <= ui_app_rdy_i;
  ddr_rdy_app_wdf <= ui_app_wdf_rdy_i;

  -----------------------------------------------------------------------------
  -- DDR3 UI Difference Control
  -----------------------------------------------------------------------------
  -- Stall the other interface if the difference between them becomes greater
  -- than 2
  --cmp_acq_2_diff_cnt : acq_2_diff_cnt
  --generic map
  --(
  --  -- Threshold in which the counters can differ
  --  g_threshold_max                           => c_ddr3_ui_diff_threshold
  --)
  --port map
  --(
  --  clk_i                                     => ext_clk_i,
  --  rst_n_i                                   => ext_rst_n_i,

  --  -- Counter 0 is APP interface
  --  cnt0_en_i                                 => pl_pkt_sent_app,
  --  cnt0_thres_hit_o                          => pl_pkt_thres_hit_app,

  --  -- Counter 1 is WDF interface
  --  cnt1_en_i                                 => pl_pkt_sent_app_wdf,
  --  cnt1_thres_hit_o                          => pl_pkt_thres_hit_wdf
  --);

  -- From next flow control module (DDR3 Controller)

  -- Only request new data when the other interface is not stalled. This gives
  -- some flexibility to the interface to control its own flow, but constraints
  -- its output to the other one. This is necessary as unrelated flow from either
  -- the write or app interface causes the controller to drop some data.
  --
  -- DDR3 Controller datasheet tells something like 2 clock cycles distance from
  -- data word (wdf interface) and the corresponding command (app interface)

  fc_stall_app <= not(ddr_rdy_app and ui_app_gnt_i);
  fc_stall_app_wdf <= not(ddr_rdy_app_wdf and ui_app_gnt_i);

  fc_dreq_app <= '1'; -- always request new data, even when the next module
                      -- in the pipeline cannot receive (ddr is not ready).
                      -- The flow control module will take care of this
  fc_dreq_app_wdf <= '1';

  -- To/From UI Xilinx Interface
  --
  -- We are using the simplest approach here! We expect DR3 Controller to be in
  -- BC4 Burst Mode, with "app_en", "wren" and "wdf_end" signals in the same cycle.
  -- Also, we only transmit when "app_rdy" and "wdf_rdy" are both high.
  ui_app_addr_o <= fc_addr;
  ui_app_cmd_o <= c_ui_cmd_write;

  ui_app_en_o <= fc_valid_app;

  ui_app_wdf_data_o <= fc_dout(c_data_high downto c_data_low);
  ui_app_wdf_end_o <= fc_valid_app_wdf;
  ui_app_wdf_mask_o <= fc_dout(c_mask_high downto c_mask_low);

  ui_app_wdf_wren_o <= fc_valid_app_wdf;

end rtl;
