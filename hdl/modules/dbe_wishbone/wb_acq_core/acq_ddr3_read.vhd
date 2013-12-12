------------------------------------------------------------------------------
-- Title      : BPM ACQ Custom <-> DDR3 Interface conversion
------------------------------------------------------------------------------
-- Author     : Lucas Maziero Russo
-- Company    : CNPEM LNLS-DIG
-- Created    : 2013-06-11
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: Module for simple read from DDR3. Just for simulation!
-------------------------------------------------------------------------------
-- Copyright (c) 2013 CNPEM
-- Licensed under GNU Lesser General Public License (LGPL) v3.0
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2013-06-11  1.0      lucas.russo        Created
-------------------------------------------------------------------------------

-- SIMULATION ONLY!

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
use work.acq_core_pkg.all;

entity acq_ddr3_read is
generic
(
  g_acq_addr_width                          : natural := 32;
  g_acq_num_channels                        : natural := 1;
  g_acq_channels                            : t_acq_chan_param_array;
  --g_data_width                              : natural := 64;
  --g_addr_width                              : natural := 32;
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
  fifo_fc_din_o                             : out std_logic_vector(f_acq_chan_find_widest(g_acq_channels)-1 downto 0);
  fifo_fc_valid_o                           : out std_logic;
  fifo_fc_addr_o                            : out std_logic_vector(g_acq_addr_width-1 downto 0);
  fifo_fc_sof_o                             : out std_logic; -- ignored
  fifo_fc_eof_o                             : out std_logic; -- ignored
  fifo_fc_dreq_i                            : in std_logic;  -- ignored
  fifo_fc_stall_i                           : in std_logic;  -- ignored

  rb_start_i                                : in std_logic;
  rb_init_addr_i                            : in std_logic_vector(g_ddr_addr_width-1 downto 0);

  lmt_all_trans_done_p_o                    : out std_logic;
  lmt_rst_i                                 : in std_logic;

  -- Current channel selection ID
  lmt_curr_chan_id_i                        : in unsigned(4 downto 0); 
  -- Size of the transaction in g_fifo_size bytes
  lmt_pkt_size_i                            : in unsigned(c_pkt_size_width-1 downto 0); -- t_fc_pkt
  -- Number of shots in this acquisition
  lmt_shots_nb_i                            : in unsigned(c_shots_size_width-1 downto 0);
  -- Acquisition limits valid signal. Qualifies lmt_fifo_pkt_size_i and lmt_shots_nb_i
  lmt_valid_i                               : in std_logic;

  -- Xilinx DDR3 UI Interface
  ui_app_addr_o                             : out std_logic_vector(g_ddr_addr_width-1 downto 0);
  ui_app_cmd_o                              : out std_logic_vector(2 downto 0);
  ui_app_en_o                               : out std_logic;
  ui_app_rdy_i                              : in std_logic;

  ui_app_rd_data_i                          : in std_logic_vector(g_ddr_payload_width-1 downto 0);
  ui_app_rd_data_end_i                      : in std_logic;
  ui_app_rd_data_valid_i                    : in std_logic;

  ui_app_req_o                              : out std_logic;
  ui_app_gnt_i                              : in std_logic
);
end acq_ddr3_read;

architecture rtl of acq_ddr3_read is

  alias c_acq_channels : t_acq_chan_param_array(g_acq_num_channels-1 downto 0) is g_acq_channels;

  -- Constants
  -- g_ddr_payload_width must be bigger than g_data_width by at least 2 times.
  -- Also, only power of 2 ratio sizes are supported
  --constant c_ddr_fc_payload_ratio           : natural := g_ddr_payload_width/g_data_width;
  alias c_ddr_payload_width                 is g_ddr_payload_width;

  --constant c_addr_col_inc                   : natural := 1;
  --constant c_addr_bc4_inc                   : natural := 4;
  --constant c_addr_bl8_inc                   : natural := 8;
  --constant c_addr_ddr_inc                   : natural := g_ddr_payload_width/g_ddr_dq_width;
  --constant c_addr_ddr_inc                   : natural := lmt_chan_curr_width/g_ddr_dq_width;
  constant c_ddr_payload_ratio_2            : natural := 2;
  constant c_ddr_payload_ratio_4            : natural := 4;
  constant c_ddr_payload_ratio_8            : natural := 8;
  constant c_max_ddr_payload_ratio          : natural := 8;
  constant c_max_ddr_payload_ratio_log2     : natural := f_log2_size(c_max_ddr_payload_ratio);

  --constant c_data_fifo_lsb                  : natural := 0;
  --constant c_data_fifo_msb                  : natural := c_data_fifo_lsb + g_data_width - 1;

  -- UI Commands
  constant c_ui_cmd_write                   : std_logic_vector(2 downto 0) := "000";
  constant c_ui_cmd_read                    : std_logic_vector(2 downto 0) := "001";

  -- Strobe signals
  signal ddr_read_en                        : std_logic;
  signal ddr_recv_en                        : std_logic;
  signal valid_trans_in                     : std_logic;
  signal valid_trans_out                    : std_logic;
  signal cnt_all_recv_trans_done_p          : std_logic;
  signal cnt_all_recv_trans_done_l          : std_logic;
  signal cnt_all_req_trans_done_p           : std_logic;
  signal cnt_all_req_trans_done_l           : std_logic;

  signal issue_rb                           : std_logic;
  signal ddr_req                            : std_logic;

  signal lmt_pkt_size                       : unsigned(c_pkt_size_width-1 downto 0);
  signal lmt_shots_nb                       : unsigned(c_shots_size_width-1 downto 0);
  --signal lmt_valid_sync                     : std_logic;
  signal lmt_valid                          : std_logic;
  signal lmt_chan_curr_width                : unsigned(c_acq_chan_max_w_log2-1 downto 0);

  -- DDR3 Signals
  --signal ddr_data_in                        : std_logic_vector(c_ddr_payload_width-1 downto 0);
  signal ddr_data_in                        : std_logic_vector(f_acq_chan_find_widest(g_acq_channels)-1 downto 0);
  signal ddr_addr_inc                       : unsigned(f_log2_size(c_max_ddr_payload_ratio) downto 0); -- max of 8
  signal ddr_addr_cnt_out                   : unsigned(g_acq_addr_width-1 downto 0);
  signal ddr_addr_cnt_in                    : unsigned(g_acq_addr_width-1 downto 0);
  signal ddr_addr_cnt_in_d0                 : unsigned(g_acq_addr_width-1 downto 0);
  signal ddr_addr_out                       : std_logic_vector(g_ddr_addr_width-1 downto 0);
  signal ddr_valid_out                      : std_logic;

  signal ddr_ui_rdy_t                       : std_logic;
  --signal acq_cnt_rst_n                  : std_logic;

begin

  -- g_acq_addr_width != g_ddr_addr_width is not supported!
  assert (g_acq_addr_width = g_ddr_addr_width)
  report "[DDR3 Interface] Different address widths are not supported!"
  severity error;

  -----------------------------------------------------------------------------
  -- Register transaction limits
  -----------------------------------------------------------------------------
  -- This 2 clock cycle delay might introduce a bug in detection of last_*
  -- signals!!! Check this!
  --cmp_lmt_valid_ffs : gc_sync_ffs
  --port map(
  --  clk_i                                   => ext_clk_i,
  --  rst_n_i                                 => ext_rst_n_i,
  --  data_i                                  => lmt_valid_i,
  --  synced_o                                => lmt_valid_sync,
  --  npulse_o                                => open,
  --  ppulse_o                                => open
  --);

  p_in_reg : process (ext_clk_i)
  begin
    if rising_edge(ext_clk_i) then
      if ext_rst_n_i = '0' then
        --Avoid detection of *_done pulses by setting them to 1
        lmt_pkt_size <= to_unsigned(1, lmt_pkt_size'length);
        lmt_shots_nb <= to_unsigned(1, lmt_shots_nb'length);
        lmt_valid <= '0';
      else
        lmt_valid <= lmt_valid_i;
  
        if lmt_valid_i = '1' then
          lmt_pkt_size <= lmt_pkt_size_i;
          lmt_shots_nb <= lmt_shots_nb_i;
        end if;
      end if;
    end if;
  end process;

  ----------------------------------------------------------------------------
  -- Determine the DDR payload / Data Input ratio
  -----------------------------------------------------------------------------
  -- This is only valid upon assertion of "rb_start_i"
  lmt_chan_curr_width <= c_acq_channels(to_integer(lmt_curr_chan_id_i)).width;
  
  ---- if this is true, ddr_fc_payload_ratio can only be 2
  ---- (lmt_chan_curr_width > c_acq_chan_width) or 4
  ---- (lmt_chan_curr_width <= c_acq_chan_width)
  ----
  --gen_ddr3_payload_256 : if (g_ddr_payload_width = 256) generate
  --  p_ddr3_data_ratio : process(ext_clk_i)
  --  begin
  --    if rising_edge(ext_clk_i) then
  --      if ext_rst_n_i = '0' then
  --        ddr_fc_payload_ratio <= to_unsigned(c_ddr_payload_ratio_2, ddr_fc_payload_ratio'length);
  --        ddr_fc_payload_ratio_log2 <= to_unsigned(1, ddr_fc_payload_ratio_log2'length);
  --
  --        --Avoid detection of *_done pulses by setting them to 1
  --        lmt_pkt_size <= to_unsigned(1, lmt_pkt_size'length);
  --        lmt_shots_nb <= to_unsigned(1, lmt_shots_nb'length);
  --        lmt_valid <= '0';
  --      else
  --        if rb_start_i = '1' then
  --          if lmt_chan_curr_width > c_acq_chan_width then
  --            ddr_fc_payload_ratio <= to_unsigned(c_ddr_payload_ratio_2, ddr_fc_payload_ratio'length);
  --            ddr_fc_payload_ratio_log2 <= to_unsigned(1, ddr_fc_payload_ratio_log2'length);
  --          else -- lmt_chan_curr_width <= c_acq_chan_width
  --            ddr_fc_payload_ratio <= to_unsigned(c_ddr_payload_ratio_4, ddr_fc_payload_ratio'length);
  --            ddr_fc_payload_ratio_log2 <= to_unsigned(2, ddr_fc_payload_ratio_log2'length);
  --          end if;
  --        end if;
  --
  --        lmt_valid <= lmt_valid_i;
  --
  --        if lmt_valid_i = '1' then
  --          -- The packet size here is constrained by "ddr_fc_payload_ratio",
  --          -- as we aggregate data by that amount to send it to the DDR3 controller
  --          --if lmt_chan_curr_width > c_acq_chan_width then
  --          --  lmt_pkt_size <= shift_right(lmt_pkt_size_i, 1); -- c_ddr_payload_ratio_2
  --          --else
  --          --  lmt_pkt_size <= shift_right(lmt_pkt_size_i, 2); -- c_ddr_payload_ratio_4
  --          --end if;
  --
  --          lmt_pkt_size <= lmt_pkt_size_i;
  --
  --          lmt_shots_nb <= lmt_shots_nb_i;
  --        end if;
  --
  --      end if;
  --    end if;
  --  end process;
  --end generate;
  --
  ----if this is true, ddr_fc_payload_ratio can only be 4
  ----(lmt_chan_curr_width > c_acq_chan_width) or 8
  ----(lmt_chan_curr_width <= c_acq_chan_width)
  --
  --gen_ddr3_payload_512 : if (g_ddr_payload_width = 512) generate
  --  p_ddr3_data_ratio : process(ext_clk_i)
  --  begin
  --    if rising_edge(ext_clk_i) then
  --      if ext_rst_n_i = '0' then
  --        ddr_fc_payload_ratio <= to_unsigned(c_ddr_payload_ratio_4, ddr_fc_payload_ratio'length);
  --        ddr_fc_payload_ratio_log2 <= to_unsigned(2, ddr_fc_payload_ratio_log2'length);
  --
  --        --Avoid detection of *_done pulses by setting them to 1
  --        lmt_pkt_size <= to_unsigned(1, lmt_pkt_size'length);
  --        lmt_shots_nb <= to_unsigned(1, lmt_shots_nb'length);
  --        lmt_valid <= '0';
  --      else
  --        if rb_start_i = '1' then
  --          if lmt_chan_curr_width > c_acq_chan_width then
  --            ddr_fc_payload_ratio <= to_unsigned(c_ddr_payload_ratio_4, ddr_fc_payload_ratio'length);
  --            ddr_fc_payload_ratio_log2 <= to_unsigned(2, ddr_fc_payload_ratio_log2'length);
  --          else -- lmt_chan_curr_width <= c_acq_chan_width
  --            ddr_fc_payload_ratio <= to_unsigned(c_ddr_payload_ratio_8, ddr_fc_payload_ratio'length);
  --            ddr_fc_payload_ratio_log2 <= to_unsigned(3, ddr_fc_payload_ratio_log2'length);
  --          end if;
  --        end if;
  --
  --        lmt_valid <= lmt_valid_i;
  --
  --        if lmt_valid_i = '1' then
  --          -- The packet size here is constrained by "ddr_fc_payload_ratio",
  --          -- as we aggregate data by that amount to send it to the DDR3 controller
  --          --if lmt_chan_curr_width > c_acq_chan_width then
  --          --  lmt_pkt_size <= shift_right(lmt_pkt_size_i, 2); -- c_ddr_payload_ratio_4
  --          --else
  --          --  lmt_pkt_size <= shift_right(lmt_pkt_size_i, 3); -- c_ddr_payload_ratio_8
  --          --end if;
  --
  --          lmt_pkt_size <= lmt_pkt_size_i;
  --
  --          lmt_shots_nb <= lmt_shots_nb_i;
  --        end if;
  --      end if;
  --    end if;
  --  end process;
  --end generate;

  ----------------------------------------------------------------------------
  -- Determine the DDR read address
  -----------------------------------------------------------------------------
  gen_ddr3_rd_addr_dq_32 : if (g_ddr_dq_width = 32) generate
    p_ddr3_data_ratio : process(ext_clk_i)
    begin
      if rising_edge(ext_clk_i) then
        if ext_rst_n_i = '0' then
          ddr_addr_inc <= to_unsigned(1, ddr_addr_inc'length);
        else
          if rb_start_i = '1' then
            if lmt_chan_curr_width > c_acq_chan_width then
              ddr_addr_inc <= to_unsigned(4, ddr_addr_inc'length); -- works for 128
            else
              ddr_addr_inc <= to_unsigned(2, ddr_addr_inc'length); -- works for 64
            end if;
          end if;
        end if;
      end if;
    end process;
  end generate;
  
  gen_ddr3_rd_addr_dq_64 : if (g_ddr_dq_width = 64) generate
    p_ddr3_data_ratio : process(ext_clk_i)
    begin
      if rising_edge(ext_clk_i) then
        if ext_rst_n_i = '0' then
          ddr_addr_inc <= to_unsigned(1, ddr_addr_inc'length);
        else
          if rb_start_i = '1' then
            if lmt_chan_curr_width > c_acq_chan_width then
              ddr_addr_inc <= to_unsigned(2, ddr_addr_inc'length); -- works for 128
            else
              ddr_addr_inc <= to_unsigned(1, ddr_addr_inc'length); -- works for 64
            end if;
          end if;
        end if;
      end if;
    end process;
  end generate;

  -- Issues read to the DDR controler when we receive a start_rb signal.
  -- We only stop issuing transactions when we have requested all of them
  p_in_issue_rb : process (ext_clk_i)
  begin
    if rising_edge(ext_clk_i) then
      if ext_rst_n_i = '0' then
        issue_rb <= '0';
        --ddr_req <= '0';
      else
        if cnt_all_req_trans_done_p = '1' then
          issue_rb <= '0';

          -- Release access from DDR3 from arbitrer
          --ddr_req <= '0';
        elsif rb_start_i = '1' then
          issue_rb <= '1';

          -- Request access to DDR3 from arbitrer
          --ddr_req <= '1';
        end if;
      end if;
    end if;
  end process;

  -- Drive DDR request signal upon receiving SOF
  p_ddr_drive_req : process(ext_clk_i)
  begin
    if rising_edge(ext_clk_i) then
      if ext_rst_n_i = '0' then
        ddr_req <= '0';
      else
        -- get access to DDR3 from arbitrer
        if rb_start_i = '1' then
          ddr_req <= '1';
        elsif cnt_all_recv_trans_done_p = '1' then -- release access only when we
                                                   -- have received all packets
          ddr_req <= '0';
        end if;
      end if;
    end if;
  end process;

  ui_app_req_o <= ddr_req;

  valid_trans_in <= '1' when ui_app_rd_data_valid_i = '1' and ui_app_rd_data_end_i = '1' else '0';

  p_ddr_data_reg : process(ext_clk_i)
  begin
    if rising_edge(ext_clk_i) then
      if ext_rst_n_i = '0' then
        ddr_data_in <= (others => '0');
        ddr_valid_out <= '0';
      else
        ddr_valid_out <= valid_trans_in;

        if valid_trans_in = '1' then
          ddr_data_in(to_integer(lmt_chan_curr_width)-1 downto 0) <=
                   ui_app_rd_data_i(to_integer(lmt_chan_curr_width)-1 downto 0);
          ddr_data_in(ddr_data_in'left downto to_integer(lmt_chan_curr_width)) <=
                   (others => '0');
        end if;
      end if;
    end if;
  end process;

  fifo_fc_din_o <= ddr_data_in;
  fifo_fc_valid_o <= ddr_valid_out;
  fifo_fc_addr_o <= ddr_addr_out;

  ddr_addr_out <= std_logic_vector(ddr_addr_cnt_in_d0);

  -- Generate address to FIFO interface.
  -- FIXME: Word for the application point of view might not be the same
  -- as the word for the DDR3 point of view (ddr_dq_width parameter)
  p_ddr_addr_cnt_in : process(ext_clk_i)
  begin
    if rising_edge(ext_clk_i) then
      if ext_rst_n_i = '0' then
        ddr_addr_cnt_in <= to_unsigned(0, ddr_addr_cnt_in'length);
      else
        if rb_start_i = '1' then
            --ddr_addr_cnt_in <= to_unsigned(0, ddr_addr_cnt_in'length);
            ddr_addr_cnt_in <= unsigned(rb_init_addr_i);
        elsif valid_trans_in = '1' then -- successfull acquisition
          ddr_addr_cnt_in_d0 <= ddr_addr_cnt_in;
          --ddr_addr_cnt_in <= ddr_addr_cnt_in + c_addr_ddr_inc; -- word by word
          ddr_addr_cnt_in <= ddr_addr_cnt_in + ddr_addr_inc; -- word by word
        end if;
      end if;
    end if;
  end process;

  -- Generate address to external controller.
  -- FIXME: Word for the application point of view might not be the same
  -- as the word for the DDR3 point of view (ddr_dq_width parameter)
  p_ddr_addr_cnt_out : process(ext_clk_i)
  begin
    if rising_edge(ext_clk_i) then
      if ext_rst_n_i = '0' then
        ddr_addr_cnt_out <= to_unsigned(0, ddr_addr_cnt_out'length);
      else
        if rb_start_i = '1' then
            ddr_addr_cnt_out <= to_unsigned(0, ddr_addr_cnt_out'length);
        --elsif ddr_read_en = '1' then -- successfull request
        elsif valid_trans_out = '1' then -- successfull request
          --ddr_addr_cnt_out <= ddr_addr_cnt_out + c_addr_ddr_inc; -- word by word
          ddr_addr_cnt_out <= ddr_addr_cnt_out + ddr_addr_inc;
        end if;
      end if;
    end if;
  end process;

  valid_trans_out <= ddr_read_en;

  -----------------------------------------------------------------------------
  -- Count the number of read requests
  ------------------------------------------------------------------------------
  cmp_acq_cnt_req : acq_cnt
  port map
  (
    -- DDR3 external clock
    clk_i                                     => ext_clk_i,
    rst_n_i                                   => ext_rst_n_i,

    cnt_all_pkts_ct_done_p_o                  => open,
    cnt_all_trans_done_p_o                    => cnt_all_req_trans_done_p,
    cnt_en_i                                  => ddr_read_en,
    --cnt_rst_i                                 => lmt_rst_i,

    -- Size of the transaction in g_fifo_size bytes
    lmt_pkt_size_i                            => lmt_pkt_size,
    -- Number of shots in this acquisition
    lmt_shots_nb_i                            => lmt_shots_nb,
    -- Acquisition limits valid signal. Qualifies lmt_pkt_size and lmt_shots_nb
    lmt_valid_i                               => lmt_valid
  );

  -- Convert from pulse to level signal
  p_cnt_all_req_trans_done : process (ext_clk_i)
  begin
    if rising_edge(ext_clk_i) then
      if ext_rst_n_i = '0' then
        cnt_all_req_trans_done_l <= '0';
      else
        -- Start of a new read batch, so we can be sure that the level signal
        -- was acknowledged by other logic
        if rb_start_i = '1' then
          cnt_all_req_trans_done_l <= '0';
        elsif cnt_all_req_trans_done_p = '1' then
          cnt_all_req_trans_done_l <= '1';
        end if;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Count the number of write repetitions
  ------------------------------------------------------------------------------
  cmp_acq_cnt_recv : acq_cnt
  port map
  (
    -- DDR3 external clock
    clk_i                                     => ext_clk_i,
    rst_n_i                                   => ext_rst_n_i,

    cnt_all_pkts_ct_done_p_o                  => open,
    cnt_all_trans_done_p_o                    => cnt_all_recv_trans_done_p,
    cnt_en_i                                  => ddr_recv_en,
    --cnt_rst_i                                 => lmt_rst_i,

    -- Size of the transaction in g_fifo_size bytes
    lmt_pkt_size_i                            => lmt_pkt_size,
    -- Number of shots in this acquisition
    lmt_shots_nb_i                            => lmt_shots_nb,
    -- Acquisition limits valid signal. Qualifies lmt_pkt_size_i and lmt_shots_nb
    lmt_valid_i                               => lmt_valid
  );

  --acq_cnt_rst_n <= ext_rst_n_i and not(lmt_rst_i);

  -- Convert from pulse to level signal
  p_cnt_all_recv_trans_done : process (ext_clk_i)
  begin
    if rising_edge(ext_clk_i) then
      if ext_rst_n_i = '0' then
        cnt_all_recv_trans_done_l <= '0';
      else
        -- Start of a new read batch, so we can be sure that the level signal
        -- was acknowledged by other logic
        if rb_start_i = '1' then
          cnt_all_recv_trans_done_l <= '0';
        elsif cnt_all_recv_trans_done_p = '1' then
          cnt_all_recv_trans_done_l <= '1';
        end if;
      end if;
    end if;
  end process;

  lmt_all_trans_done_p_o <= cnt_all_recv_trans_done_p;

  -- For simulation this is ok. Not for synthesis!
  --ddr_read_en <= ddr_ui_rdy_t when cnt_all_req_trans_done_p = '0' and
  --                     cnt_all_req_trans_done_l = '0' and lmt_valid_i = '1' and
  --                     lmt_rst_i = '0' else '0';
  --
  --ddr_recv_en <= valid_trans_in when cnt_all_recv_trans_done_p = '0' and
  --                     cnt_all_recv_trans_done_l = '0' and lmt_valid_i = '1' and
  --                     lmt_rst_i = '0' else '0';
  -- For simulation only. Not for synthesis!
  ddr_read_en <= ddr_ui_rdy_t when cnt_all_req_trans_done_p = '0' and
                       cnt_all_req_trans_done_l = '0' and issue_rb = '1' and
                       ui_app_gnt_i = '1' else '0';
  -- For simulation only. Not for synthesis!
  ddr_recv_en <= valid_trans_in when cnt_all_recv_trans_done_p = '0' and
                       cnt_all_recv_trans_done_l = '0' and ui_app_gnt_i = '1'
                       else '0';

  ddr_ui_rdy_t <= ui_app_rdy_i;

  -- To/From UI Xilinx Interface
  ui_app_addr_o <= std_logic_vector(ddr_addr_cnt_out);
  ui_app_cmd_o <= c_ui_cmd_read;
  ui_app_en_o <= ddr_read_en;

end rtl;
