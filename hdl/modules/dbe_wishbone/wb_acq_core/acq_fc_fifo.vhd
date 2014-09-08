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
use work.acq_core_pkg.all;

entity acq_fc_fifo is
generic
(
  g_data_width                              : natural := 64;
  g_addr_width                              : natural := 32;
  g_fifo_size                               : natural := 64;
  g_fc_pipe_size                            : natural := 4
  --g_pkt_size_width                          : natural := 32
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
  dpram_data_i                              : in std_logic_vector(g_data_width-1 downto 0);
  dpram_dvalid_i                            : in std_logic;

  -- Passthough data
  pt_data_i                                 : in std_logic_vector(g_data_width-1 downto 0);
  pt_dvalid_i                               : in std_logic;
  pt_wr_en_i                                : in std_logic;

  -- Request transaction reset as soon as possible (when all outstanding
  -- transactions have been commited)
  req_rst_trans_i                           : in std_logic;
  -- select between multi-buffer mode and pass-through mode (data directly
  -- through external module interface)
  passthrough_en_i                          : in std_logic;
  -- which buffer (0 or 1) to store data in. valid only when passthrough_en_i = '0'
  buffer_sel_i                              : in std_logic;

  -- Size of the transaction in g_fifo_size bytes
  --lmt_pkt_size_i                       : in unsigned(g_addr_width-1 downto 0); -- t_fc_pkt
  lmt_pkt_size_i                            : in unsigned(c_pkt_size_width-1 downto 0); -- t_fc_pkt
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
  fifo_fc_dout_o                            : out std_logic_vector(g_data_width-1 downto 0);
  fifo_fc_valid_o                           : out std_logic;
  fifo_fc_addr_o                            : out std_logic_vector(g_addr_width-1 downto 0);
  fifo_fc_sof_o                             : out std_logic;
  fifo_fc_eof_o                             : out std_logic;
  fifo_fc_dreq_i                            : in std_logic;
  fifo_fc_stall_i                           : in std_logic;

  dbg_fifo_we_o		                	        : out std_logic;
  dbg_fifo_wr_count_o	                	    : out std_logic_vector(f_log2_size(g_fifo_size)-1 downto 0);
  dbg_fifo_re_o		                	        : out std_logic;
  dbg_fifo_fc_rd_en_o	                	    : out std_logic;
  dbg_fifo_rd_empty_o	                    	: out std_logic;
  dbg_fifo_wr_full_o	                    	: out std_logic;
  dbg_fifo_fc_valid_fwft_o			            : out std_logic;
  dbg_source_pl_dreq_o	                	  : out std_logic;
  dbg_source_pl_stall_o	                	  : out std_logic;
  dbg_pkt_ct_cnt_o                          : out std_logic_vector(c_pkt_size_width-1 downto 0);
  dbg_shots_cnt_o                           : out std_logic_vector(c_shots_size_width-1 downto 0)
);
end acq_fc_fifo;

architecture rtl of acq_fc_fifo is

  ---- Constants
  constant c_pipe_size                        : natural := 4;
  --alias c_pkt_size_width                      is g_addr_width;
  --constant c_data_oob_width                 : natural := 2; -- SOF and EOF
  --
  --constant c_data_oob_sof_ofs               : natural := 1; -- SOF offset
  --constant c_data_oob_eof_ofs               : natural := 0; -- EOF offset

  -- Type declarations
  subtype t_fc_data is std_logic_vector(g_data_width-1 downto 0);
  type t_fc_data_array is array (natural range <>) of t_fc_data;

  type t_fc_dvalid_array is array (natural range <>) of std_logic;

  subtype t_fc_data_oob is std_logic_vector(c_data_oob_width -1 downto 0);
  type t_fc_data_oob_array is array (natural range <>) of t_fc_data_oob;

  subtype t_fc_pkt is unsigned(c_pkt_size_width-1 downto 0);
  subtype t_fc_addr is std_logic_vector(g_addr_width-1 downto 0);

  -- Signals
  signal fifo_fc_din                        : t_fc_data;
  signal fifo_fc_dout                       : t_fc_data;
  signal fifo_fc_we                         : std_logic;
  signal fifo_fc_we_en                      : std_logic;
  signal fifo_fc_we_en_r                    : std_logic;
  signal fifo_fc_wr_count                   : std_logic_vector(f_log2_size(g_fifo_size)-1 downto 0);

  signal fifo_fc_data_out                   : t_fc_data;
  signal fifo_fc_oob_out                    : t_fc_data_oob;
  signal fifo_fc_valid_out                  : std_logic;
  signal fifo_fc_rd                         : std_logic;
  signal fifo_fc_rd_en                      : std_logic;
  signal fifo_fc_valid                      : std_logic;
  signal fifo_fc_valid_fwft                 : std_logic;

  signal fifo_fc_last_data                  : std_logic;
  signal fifo_fc_first_data                 : std_logic;
  signal pl_dreq                          : std_logic;
  signal pl_stall                         : std_logic;
  signal pl_pkt_sent                        : std_logic;
  signal ext_stall_s                        : std_logic;
  signal fifo_pkt_sent                      : std_logic;
  signal fifo_fc_data_out_pnd               : std_logic; -- Pending data

  signal fifo_data_out                      : t_fc_data_array(g_fc_pipe_size-1 downto 0);
  -- SOF and EOF for now
  signal fifo_data_oob_out                  : t_fc_data_oob_array(g_fc_pipe_size-1 downto 0);
  signal fifo_dvalid_out                    : t_fc_dvalid_array(g_fc_pipe_size-1 downto 0);

  signal pre_output_counter_wr              : unsigned(f_log2_size(g_fc_pipe_size)-1 downto 0);
  signal output_counter_rd                  : unsigned(f_log2_size(g_fc_pipe_size)-1 downto 0);

  signal fifo_fc_rd_empty                   : std_logic;
  signal fifo_fc_wr_full                    : std_logic;
  signal fifo_fc_addr                       : unsigned(g_addr_width-1 downto 0);

  -- Output signals
  signal fc_dout                            : std_logic_vector(g_data_width-1 downto 0);
  signal fc_valid                           : std_logic;
  signal fc_addr                            : std_logic_vector(g_addr_width-1 downto 0);
  signal fc_sof                             : std_logic;
  signal fc_eof                             : std_logic;
  signal fc_dreq                            : std_logic;
  signal fc_stall                           : std_logic;

  -- reset transaction signals
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

  -- counts the completed tranfered words to ext mem
  signal fifo_out_pend_cnt                  : t_fc_pkt;
  --signal fifo_pkt_sent_cnt                  : unsigned(g_addr_width -1 downto 0);
  --signal fifo_pkt_sent_ct_cnt               : unsigned(g_addr_width -1 downto 0);
  signal fifo_pkt_sent_cnt                  : t_fc_pkt;
  signal fifo_pkt_sent_ct_cnt               : t_fc_pkt;
  signal fifo_pkt_sent_ct_all               : std_logic;

  -- Transaction limit signals
  signal lmt_pkt_size                       : unsigned(c_pkt_size_width-1 downto 0);
  signal lmt_shots_nb                       : unsigned(c_shots_size_width-1 downto 0);
  signal lmt_valid                          : std_logic;

  -- number of shots transfers
  signal shots_sent_cnt                     : unsigned(c_shots_size_width-1 downto 0);
  signal shots_sent_all                     : std_logic;

  -- End of transcation signals
  signal fifo_fc_all_trans_done             : std_logic;
  signal fifo_fc_all_trans_done_lvl         : std_logic;
  signal fifo_fc_all_trans_done_sync        : std_logic;

begin

  --CHANGE THIS TO COUNTER MODULE
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

  -----------------------------------------------------------------------------
  -- FIFO write logic
  -----------------------------------------------------------------------------

  -- TODO: Improve the fifo write enable control!
  p_fifo_fc_input : process (fs_clk_i)
  begin
    if rising_edge(fs_clk_i) then
      if fs_rst_n_i = '0' then
        fifo_fc_din <= (others => '0');
        fifo_fc_we_en_r <= '0';
      else
        if passthrough_en_i = '1' then
          --fifo_fc_din <= acq_trig & pt_data_i(63 downto 0);  -- trigger + data
          fifo_fc_din <= pt_data_i;  -- trigger + data
          --fifo_fc_we_en_r <= pt_wr_en_i and pt_dvalid_i and not(fifo_in_valid_full);
          fifo_fc_we_en_r <= fifo_fc_we_en;
        else
          --fifo_fc_din <= '0' & dpram_dout;
          fifo_fc_din <= dpram_data_i;
          fifo_fc_we_en_r <= dpram_dvalid_i;
        end if;
      end if;
    end if;
  end process;

  -- counts the words written in the FIFO
  p_cnt_valid_in : process (fs_clk_i)
  begin
    if rising_edge(fs_clk_i) then
      if fs_rst_n_i = '0' then
        fifo_in_valid_cnt <= to_unsigned(0, fifo_in_valid_cnt'length);
      else
        if rst_trans_fs_sync = '1' then
        --if rst_trans_ext_sync = '1' then -- not in sync with fs_clk!!!
          fifo_in_valid_cnt <= to_unsigned(0, fifo_in_valid_cnt'length);
        elsif fifo_fc_we_en = '1' then -- valid word on fifo input
          fifo_in_valid_cnt <= fifo_in_valid_cnt + 1;
        end if;
      end if;
    end if;
  end process;

  -- Used only for passthrough mode
  fifo_in_valid_full <= '1' when fifo_in_valid_cnt = lmt_pkt_size else '0';

  -- fifo valid input
  -- Long combinatorial logic. TODO: Try to reduce it!
  fifo_fc_we_en <= pt_wr_en_i and pt_dvalid_i and not(fifo_in_valid_full) and not(fifo_fc_wr_full);

  -- fs clk domain
  fifo_fc_we <= fifo_fc_we_en_r;

  cmp_wb_ddr_fifo : generic_async_fifo
  generic map (
    g_data_width                            => g_data_width,
    g_size                                  => g_fifo_size,
    --g_almost_empty_threshold                => 4,
    --g_almost_full_threshold                 => 256,
    g_almost_empty_threshold                => 0,
    g_almost_full_threshold                 => 0,
    g_with_wr_count                         => true
  )
  port map(
    rst_n_i                                 => fs_rst_n_i,

    clk_wr_i                                => fs_clk_i,
    d_i                                     => fifo_fc_din,
    we_i                                    => fifo_fc_we,
    wr_count_o                              => fifo_fc_wr_count, --std_logic_vector(f_log2_size(g_size)-1 downto 0);

    clk_rd_i                                => ext_clk_i,
    q_o                                     => fifo_fc_dout,
    rd_i                                    => fifo_fc_rd,

    rd_empty_o                              => fifo_fc_rd_empty,
    wr_full_o                               => fifo_fc_wr_full
  );

  fifo_fc_full_o <= fifo_fc_wr_full;

  -- Debug signals
  dbg_fifo_we_o <= fifo_fc_we;
  dbg_fifo_wr_count_o <= fifo_fc_wr_count;
  dbg_fifo_re_o <= fifo_fc_rd;
  dbg_fifo_fc_rd_en_o <= fifo_fc_rd_en;
  dbg_fifo_rd_empty_o <= fifo_fc_rd_empty;
  dbg_fifo_wr_full_o <= fifo_fc_wr_full;
  dbg_fifo_fc_valid_fwft_o <= fifo_fc_valid_fwft;
  dbg_source_pl_dreq_o <= pl_dreq;
  dbg_source_pl_stall_o <= pl_stall;

  -- Valid flag
  --p_fifo_fc_valid : process (ext_clk_i) is
  --begin
  --  if rising_edge(ext_clk_i) then
  --    fifo_fc_valid <= fifo_fc_rd;
  --    --fifo_fc_valid_d0 <= fifo_fc_valid;
  --
  --    if (fifo_fc_rd_empty = '1') then
  --      fifo_fc_valid <= '0';
  --    end if;
  --  end if;
  --end process;

  -- First Word Fall Through (FWFT) implementation
  fifo_fc_rd <= not(fifo_fc_rd_empty) and (not(fifo_fc_valid_fwft) or fifo_fc_rd_en);
  -- This is the actually valid flag from this FIFO
  fifo_fc_valid <= fifo_fc_valid_fwft;

  p_fifo_fc_valid_fwft : process (ext_clk_i) is
  begin
    if rising_edge(ext_clk_i) then
      if ext_rst_n_i = '0' then
         fifo_fc_valid_fwft <= '0';
      else
        if fifo_fc_rd = '1' then
           fifo_fc_valid_fwft <= '1';
        elsif fifo_fc_rd_en = '1' then
           fifo_fc_valid_fwft <= '0';
        end if;
      end if;
    end if;
  end process;

  -- ext clk domain
  -- We actually don't need to wait until fifo_fc_stall_i is clean to read from fifo.
  -- We could read from FIFO as long as the output pipeline is not full.
  -- TODO: implement better fifo reading mechanism!
  --fifo_fc_rd <= fifo_fc_dreq_i and not(fifo_fc_rd_empty) and not(fifo_fc_stall_i);
  --fifo_fc_rd <= pl_dreq and not(fifo_fc_rd_empty) and not(pl_stall);

  -- FIXME!
  -- Start reading only after a determined threshold! In this way we avoid excessive
  -- throttling of the "fifo_fc_valid" signal for the FIFO being empty!
  -- This happens bexause the reading clock (200 MHz) is generally faster
  -- than fs_clk (~113 MHz)
  --fifo_fc_rd <= pl_dreq and not(pl_stall); -- ??? AND?
  fifo_fc_rd_en <= pl_dreq or not(pl_stall);

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

  --rst_trans_fs_sync <= '1' when req_rst_trans_i = '1' and fifo_fc_all_trans_done = '1' else '0';

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

  --fifo_pkt_sent <= '1' when fifo_fc_valid = '1' and pl_stall = '0' else '0';
  -- The fc_source module accpets one more data after the stall is asserted.
  -- So, even if the pl_stall is asserted the current fifo data is still
  -- accpeted by the fc_source module.
  --
  -- We also deasserted fifo_rd_en to avoid a second data valid from the asunc_fifo,
  -- which, in this case, would cause a data loss.
  --fifo_pkt_sent <= pl_pkt_sent;
  fifo_pkt_sent <= not(pl_stall) and fifo_fc_valid;

  -----------------------------------------------------------------------------
  -- Number of packets and shots transfered
  -----------------------------------------------------------------------------
  cmp_acq_cnt : acq_cnt
  port map
  (
    -- DDR3 external clock
    clk_i                                     => ext_clk_i,
    rst_n_i                                   => acq_cnt_rst_n,

    cnt_all_pkts_ct_done_p_o                  => fifo_pkt_sent_ct_all,
    cnt_all_trans_done_p_o                    => shots_sent_all,
    cnt_en_i                                  => fifo_pkt_sent,

    -- Size of the transaction in g_fifo_size bytes
    lmt_pkt_size_i                            => lmt_pkt_size_i,
    -- Number of shots in this acquisition
    lmt_shots_nb_i                            => lmt_shots_nb_i,
    -- Acquisition limits valid signal. Qualifies lmt_pkt_size_i and lmt_shots_nb_i
    lmt_valid_i                               => lmt_valid_i,

    dbg_pkt_ct_cnt_o                          => dbg_pkt_ct_cnt_o,
    dbg_shots_cnt_o                           => dbg_shots_cnt_o
  );

  -- TESTING ONly!!!!!!!!!!!!!!!!
  -- FIXME FIXME
  acq_cnt_rst_n <= ext_rst_n_i and not(rst_trans_ext_sync); -- is this a good idea?
  --------------------------acq_cnt_rst_n <= ext_rst_n_i; -- is this a good idea?

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

  -- This is not necessarilly a pulse. Thus, we need to detect the positive edge
  -- of this signal
  --fifo_fc_trans_done <= '1' when fifo_pkt_sent_cnt = lmt_pkt_size else '0'; -- sync to ext_clk_i
  --fifo_fc_trans_done <= '1' when fifo_pkt_sent_ct_cnt = lmt_pkt_size else '0'; -- sync to ext_clk_i
  fifo_fc_all_trans_done <= shots_sent_all; -- sync to ext_clk_i

  fifo_fc_all_trans_done_p_o <= fifo_fc_all_trans_done_sync;

  -------------------------------------------------------------------------
  -- Pulse to level conversion
  -------------------------------------------------------------------------
  p_conv_fifo_fc_all_trans_done : process (ext_clk_i)
  begin
  if rising_edge(ext_clk_i) then
    if ext_rst_n_i = '0' then
      fifo_fc_all_trans_done_lvl <= '0';
    else
      if rst_trans_ext_sync_d = '1' then
        fifo_fc_all_trans_done_lvl <= '0';
      elsif fifo_fc_all_trans_done = '1' then
        fifo_fc_all_trans_done_lvl <= '1';
      end if;
    end if;
  end if;
  end process;

  ------------------------------------------------------------------------------
  -- Output Protocol Logic
  ------------------------------------------------------------------------------

  cmp_fc_source : fc_source
  generic map (
    g_data_width                            => g_data_width,
    g_pkt_size_width                        => c_pkt_size_width,
    g_addr_width                            => g_addr_width,
    g_pipe_size                             => c_pipe_size
  )
  port map (
    clk_i                                   => ext_clk_i,
    rst_n_i                                 => ext_rst_n_i,

    pl_data_i                               => fifo_fc_dout,
    pl_addr_i                               => std_logic_vector(fifo_fc_addr),
    pl_valid_i                              => fifo_fc_valid,

    pl_dreq_o                               => pl_dreq,
    pl_stall_o                              => pl_stall,
    --pl_pkt_sent_o                           => pl_pkt_sent,
    pl_pkt_sent_o                           => open,

    pl_rst_trans_i                          => pl_rst_trans,

    lmt_pkt_size_i                          => lmt_pkt_size,
    lmt_valid_i                             => lmt_valid,

    fc_dout_o                               => fc_dout,
    fc_valid_o                              => fc_valid,
    fc_addr_o                               => fc_addr,
    fc_sof_o                                => fc_sof,
    fc_eof_o                                => fc_eof,

    fc_stall_i                              => fc_stall,
    fc_dreq_i                               => fc_dreq
  );

  --pl_rst_trans <= rst_trans_ext_sync or fifo_pkt_sent_ct_all;
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
