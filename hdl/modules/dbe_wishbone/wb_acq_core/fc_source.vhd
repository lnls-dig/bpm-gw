------------------------------------------------------------------------------
-- Title      : BPM Flow Control Source module
------------------------------------------------------------------------------
-- Author     : Lucas Maziero Russo
-- Company    : CNPEM LNLS-DIG
-- Created    : 2013-22-10
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: Implments a simple Flow Control module
-------------------------------------------------------------------------------
-- Copyright (c) 2013 CNPEM
-- Licensed under GNU Lesser General Public License (LGPL) v3.0
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2013-31-10  1.0      lucas.russo        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
-- Genrams cores
use work.genram_pkg.all;
-- Genrams cores
use work.gencores_pkg.all;
-- Acquisition cores
use work.acq_core_pkg.all;

entity fc_source is
generic
(
  g_header_in_width                         : natural := 4;
  g_data_width                              : natural := 64;
  g_pkt_size_width                          : natural := 32;
  g_addr_width                              : natural := 32;
  g_with_fifo_inferred                      : boolean := false;
  g_pipe_size                               : natural := 4
);
port
(
  clk_i                                     : in std_logic;
  rst_n_i                                   : in std_logic;

  -- Plain Interface
  pl_data_i                                 : in std_logic_vector(g_header_in_width+g_data_width-1 downto 0);
  pl_addr_i                                 : in std_logic_vector(g_addr_width-1 downto 0);
  pl_valid_i                                : in std_logic;

  pl_dreq_o                                 : out std_logic; -- optional for driving another FC interface
  pl_stall_o                                : out std_logic; -- optional for driving another FC interface
  pl_pkt_sent_o                             : out std_logic; -- optional for knowing the exact time a packet was sent

  pl_rst_trans_i                            : in std_logic;

  -- Limits
  lmt_pre_pkt_size_i                        : in unsigned(c_pkt_size_width-1 downto 0);
  lmt_pos_pkt_size_i                        : in unsigned(c_pkt_size_width-1 downto 0);
  lmt_full_pkt_size_i                       : in unsigned(c_pkt_size_width-1 downto 0);
  lmt_valid_i                               : in std_logic;

  -- Flow Control Interface
  fc_dout_o                                 : out std_logic_vector(g_header_in_width+g_data_width-1 downto 0);
  fc_valid_o                                : out std_logic;
  fc_addr_o                                 : out std_logic_vector(g_addr_width-1 downto 0);
  fc_sof_o                                  : out std_logic;
  fc_eof_o                                  : out std_logic;

  fc_stall_i                                : in std_logic;
  fc_dreq_i                                 : in std_logic
);
end fc_source;

architecture rtl of fc_source is

  -- Types declaration
  subtype t_fc_data is std_logic_vector(g_header_in_width+g_data_width-1 downto 0);
  type t_fc_data_array is array (natural range <>) of t_fc_data;

  subtype t_fc_addr is std_logic_vector(g_addr_width-1 downto 0);
  type t_fc_addr_array is array (natural range <>) of t_fc_addr;

  subtype t_fc_dvalid is std_logic;
  type t_fc_dvalid_array is array (natural range <>) of t_fc_dvalid;

  subtype t_fc_data_oob is std_logic_vector(c_data_oob_width-1 downto 0);
  type t_fc_data_oob_array is array (natural range <>) of t_fc_data_oob;

  subtype t_fc_pkt is unsigned(g_pkt_size_width-1 downto 0);

  -- Constants
  constant c_pipe_almost_full_thres        : natural := g_pipe_size-2;
  constant c_pipe_almost_empty_thres       : natural := 2;
  constant c_pre_out_fifo_width            : natural := g_header_in_width + g_data_width + g_addr_width +
                                                          c_data_oob_width;
  constant c_pre_out_fifo_data_lsb         : natural := 0;
  constant c_pre_out_fifo_data_msb         : natural := c_pre_out_fifo_data_lsb + g_header_in_width + g_data_width - 1;
  constant c_pre_out_fifo_addr_lsb         : natural := c_pre_out_fifo_data_msb + 1;
  constant c_pre_out_fifo_addr_msb         : natural := c_pre_out_fifo_addr_lsb + g_addr_width - 1;
  constant c_pre_out_fifo_oob_lsb          : natural := c_pre_out_fifo_addr_msb + 1;
  constant c_pre_out_fifo_oob_msb          : natural := c_pre_out_fifo_oob_lsb + c_data_oob_width - 1;

  constant c_fc_in_header_top_idx          : natural := g_header_in_width+g_data_width-1;
  constant c_fc_in_header_bot_idx          : natural := g_data_width;

  -- Signals
  signal fc_first_data                      : std_logic;
  signal fc_last_data                       : std_logic;
  signal fc_stall_s                         : std_logic;
  signal fc_valid_s                         : std_logic;
  signal fc_in_data_pending                 : std_logic;
  signal fc_in_cnt_en                       : std_logic;
  signal fc_in_trigger                      : std_logic;
  signal fc_in_data_id                      : std_logic_vector(2 downto 0);

  signal fc_read_next_pkt                   : std_logic;
  signal pl_stall_r                         : std_logic;
  signal pl_dreq_r                          : std_logic;

  -- signals that a packet was actually transfered
  signal pkt_sent                           : std_logic;
  signal lmt_pre_pkt_size                   : unsigned(c_pkt_size_width-1 downto 0);
  signal lmt_pos_pkt_size                   : unsigned(c_pkt_size_width-1 downto 0);
  signal lmt_full_pkt_size                  : unsigned(c_pkt_size_width-1 downto 0);

  -- Pre output FIFO signals
  signal pre_out_fifo_we                    : std_logic;
  signal pre_out_fifo_din                   : std_logic_vector(c_pre_out_fifo_width-1 downto 0);
  signal pre_out_fifo_marsh                 : std_logic_vector(c_pre_out_fifo_width-1 downto 0);
  signal pre_out_almost_empty               : std_logic;
  signal pre_out_almost_full                : std_logic;
  signal pre_out_empty                      : std_logic;
  signal pre_out_full                       : std_logic;

  signal pre_out_fifo_rd_en                 : std_logic;
  signal pre_out_fifo_valid_out             : std_logic;
  signal pre_out_fifo_dout                  : std_logic_vector(c_pre_out_fifo_width-1 downto 0);

  -- Output signals
  signal fc_data_out_int                    : t_fc_data;
  signal fc_addr_out_int                    : t_fc_addr;
  signal fc_valid_out_int                   : t_fc_dvalid;
  signal fc_oob_out_int                     : t_fc_data_oob;

  -- Counters
  signal fc_in_pend_cnt                  : t_fc_pkt;

  signal output_pipe_full                   : std_logic;
  signal output_pipe_almost_full            : std_logic;
  signal output_pipe_empty                  : std_logic;
  signal output_pipe_almost_empty           : std_logic;

begin

  ----------------------------------------------------------------------------
  -- Register transaction limits.
  -----------------------------------------------------------------------------
  -- We register the pkt_size signal again here as this module may not be
  -- used as it was. Thus, changing its behavior
  p_in_reg : process (clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' then
        --Avoid detection of *_done pulses by setting them to 1
        lmt_pre_pkt_size <= to_unsigned(1, lmt_pre_pkt_size'length);
        lmt_pos_pkt_size <= to_unsigned(1, lmt_pos_pkt_size'length);
        lmt_full_pkt_size <= to_unsigned(1, lmt_full_pkt_size'length);
      else
        if lmt_valid_i = '1' then
          lmt_pre_pkt_size <= lmt_pre_pkt_size_i;
          lmt_pos_pkt_size <= lmt_pos_pkt_size_i;
          lmt_full_pkt_size <= lmt_full_pkt_size_i;
        end if;
      end if;
    end if;
  end process;

  -- Extract fifo trigger from pl_data_i
  fc_in_trigger <= pl_data_i(c_acq_header_trigger_idx+c_fc_in_header_bot_idx);

  -- Extract fifo data id from pl_data_i
  fc_in_data_id <= pl_data_i(c_acq_header_id_top_idx+c_fc_in_header_bot_idx downto
                          c_acq_header_id_bot_idx+c_fc_in_header_bot_idx);

  p_count_valid : process (clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' then
        fc_in_pend_cnt <= to_unsigned(0, fc_in_pend_cnt'length);
      else

        if pl_rst_trans_i = '1' or fc_last_data = '1'then
          fc_in_pend_cnt <= to_unsigned(0, fc_in_pend_cnt'length);
        elsif fc_in_data_pending = '1' and fc_in_cnt_en = '1' then
          fc_in_pend_cnt <= fc_in_pend_cnt + 1;
        end if;

      end if;
    end if;
  end process;

  -- Only count up to the sample when in pre_trigger or post_trigger and we haven't
  -- acquire enough samples
  fc_in_cnt_en <= '1' when (fc_in_pend_cnt < lmt_pre_pkt_size and
                                fc_in_data_id = "010") or -- Pre-trigger
                                (fc_in_pend_cnt < lmt_full_pkt_size and
                                fc_in_data_id = "100") -- Post-trigger
                            else '0';
  fc_in_data_pending <= fc_valid_s;

  cmp_pre_out_fwft_fifo : acq_fwft_fifo
  generic map
  (
    g_data_width                            => c_pre_out_fifo_width,
    g_size                                  => g_pipe_size,
    g_with_rd_almost_empty                  => true,
    g_with_wr_almost_empty                  => true,
    g_with_rd_almost_full                   => true,
    g_with_wr_almost_full                   => true,
    g_almost_empty_threshold                => c_pipe_almost_empty_thres,
    g_almost_full_threshold                 => c_pipe_almost_full_thres,
    g_with_wr_count                         => false,
    g_with_rd_count                         => false,
    g_with_fifo_inferred                    => g_with_fifo_inferred,
    g_async                                 => false
  )
  port map
  (
    -- Write clock
    wr_clk_i                                => clk_i,
    wr_rst_n_i                              => rst_n_i,

    wr_data_i                               => pre_out_fifo_din,
    wr_en_i                                 => pre_out_fifo_we,
    wr_full_o                               => pre_out_full,
    wr_count_o                              => open,
    wr_almost_empty_o                       => pre_out_almost_empty,
    wr_almost_full_o                        => pre_out_almost_full,

    -- Read clock
    rd_clk_i                                => clk_i,
    rd_rst_n_i                              => rst_n_i,

    rd_data_o                               => pre_out_fifo_dout,
    rd_valid_o                              => pre_out_fifo_valid_out,
    rd_en_i                                 => pre_out_fifo_rd_en,
    rd_empty_o                              => pre_out_empty,
    rd_count_o                              => open
  );

  pre_out_fifo_we <= fc_valid_s;
  -- FIFO inputs marshall
  pre_out_fifo_marsh <= fc_first_data & fc_last_data & pl_addr_i & pl_data_i;
  pre_out_fifo_din <= pre_out_fifo_marsh;

  pre_out_fifo_rd_en <= '1' when pkt_sent = '1' else '0';

  -- FIFO output unmarshall
  fc_data_out_int <= pre_out_fifo_dout(c_pre_out_fifo_data_msb downto c_pre_out_fifo_data_lsb);
  fc_addr_out_int <= pre_out_fifo_dout(c_pre_out_fifo_addr_msb downto c_pre_out_fifo_addr_lsb);
  fc_valid_out_int <= pre_out_fifo_valid_out;
  fc_oob_out_int <= pre_out_fifo_dout(c_pre_out_fifo_oob_msb downto c_pre_out_fifo_oob_lsb);

  fc_stall_s <= '0' when fc_stall_i = '0' else fc_valid_out_int;
  fc_valid_s <= '1' when pl_valid_i = '1' and pl_stall_r = '0' else '0';

  ----------------------------------------------------------------------------
  -- SOF and EOF genaration
  -----------------------------------------------------------------------------
  -- Register signals to ease critical path
  p_reg_sof_eof : process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' then
        fc_first_data <= '1';
        fc_last_data <= '0';
      else
        -- We don't care if the first data is asserted for a long time.
        -- It just matters when fc_valid_s = '1' anyway
        if fc_first_data = '1' and fc_valid_s = '1' then -- first data tag
          fc_first_data <= '0';
        elsif fc_in_pend_cnt = to_unsigned(0, fc_in_pend_cnt'length) then
          fc_first_data <= '1';
        end if;

        if lmt_full_pkt_size = to_unsigned(1, lmt_full_pkt_size'length) or -- base case of lmt_full_pkt_size = 1
            (fc_in_pend_cnt = lmt_full_pkt_size-2 and fc_valid_s = '1') then -- will increment
          fc_last_data <= '1';
        elsif fc_valid_s = '1' then
          fc_last_data <= '0';
        end if;

      end if;
    end if;
  end process;

  -- signals that a packet was actually transfered
  pkt_sent <= '1' when fc_valid_out_int = '1' and fc_stall_i = '0' else '0';

  -- Monitor output pipeline.
  output_pipe_full <= pre_out_full;
  output_pipe_almost_full <= pre_out_almost_full;
  output_pipe_empty <= pre_out_empty;
  output_pipe_almost_empty <= pre_out_almost_empty;

  p_reg_stall_dreq_out : process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' then
        pl_stall_r <= '0';
        pl_dreq_r <= '0';
      else

        if output_pipe_almost_full = '1' and fc_valid_s = '1' then
          pl_stall_r <= '1';
        elsif output_pipe_almost_full = '0' then
          pl_stall_r <= '0';
        end if;

        pl_dreq_r <=  output_pipe_empty or output_pipe_almost_empty;
      end if;
    end if;
  end process;

  pl_stall_o                            <= pl_stall_r;
  pl_dreq_o                             <= pl_dreq_r;

  fc_dout_o                             <= fc_data_out_int;
  fc_valid_o                            <= fc_valid_out_int;
  fc_addr_o                             <= fc_addr_out_int;
  fc_sof_o                              <= fc_oob_out_int(c_data_oob_sof_ofs);
  fc_eof_o                              <= fc_oob_out_int(c_data_oob_eof_ofs);

  pl_pkt_sent_o                         <= pkt_sent;

end rtl;
