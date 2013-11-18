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
use work.acq_core_pkg.all;

entity fc_source is
generic
(
  --g_hold_valid_on_stall                     : boolean := true;
  g_data_width                              : natural := 64;
  g_pkt_size_width                          : natural := 32;
  g_addr_width                              : natural := 32;
  g_pipe_size                               : natural := 4
  --g_pipe_almost_full                        : natural := 3
);
port
(
  clk_i                                     : in std_logic;
  rst_n_i                                   : in std_logic;

  -- Plain Interface
  pl_data_i                                 : in std_logic_vector(g_data_width-1 downto 0);
  pl_addr_i                                 : in std_logic_vector(g_addr_width-1 downto 0);
  pl_valid_i                                : in std_logic;

  pl_dreq_o                                 : out std_logic; -- optional for driving another FC interface
  pl_stall_o                                : out std_logic; -- optional for driving another FC interface
  pl_pkt_sent_o                             : out std_logic; -- optional for knowing the exact time a packet was sent

  pl_rst_trans_i                            : in std_logic;

  -- Limits
  lmt_pkt_size_i                            : in unsigned(c_pkt_size_width-1 downto 0);
  lmt_valid_i                               : in std_logic;

  -- Flow Control Interface
  fc_dout_o                                 : out std_logic_vector(g_data_width-1 downto 0);
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
  subtype t_fc_data is std_logic_vector(g_data_width-1 downto 0);
  type t_fc_data_array is array (natural range <>) of t_fc_data;

  subtype t_fc_addr is std_logic_vector(g_addr_width-1 downto 0);
  type t_fc_addr_array is array (natural range <>) of t_fc_addr;

  type t_fc_dvalid_array is array (natural range <>) of std_logic;

  subtype t_fc_data_oob is std_logic_vector(c_data_oob_width -1 downto 0);
  type t_fc_data_oob_array is array (natural range <>) of t_fc_data_oob;

  subtype t_fc_pkt is unsigned(g_pkt_size_width-1 downto 0);

  -- Constants
  constant c_pipe_almost_full               : natural := g_pipe_size/2 + g_pipe_size/4; -- 75%
  constant c_pipe_almost_empty              : natural := g_pipe_size/4; -- 25%

  -- Signals
  signal fc_first_data                      : std_logic;
  signal fc_last_data                       : std_logic;
  signal fc_last_data_r                     : std_logic;
  signal fc_stall_s                         : std_logic;
  signal fc_valid_s                         : std_logic;
  signal fc_in_data_pending                 : std_logic;

  signal fc_data_out                        : t_fc_data_array(g_pipe_size-1 downto 0);
  signal fc_addr_out                        : t_fc_addr_array(g_pipe_size-1 downto 0);
  -- SOF and EOF for now
  signal fc_data_oob_out                    : t_fc_data_oob_array(g_pipe_size-1 downto 0);
  signal fc_dvalid_out                      : t_fc_dvalid_array(g_pipe_size-1 downto 0);
  signal fc_read_next_pkt                   : std_logic;

  signal pre_output_counter_wr              : unsigned(f_log2_size(g_pipe_size)-1 downto 0);
  signal output_counter_rd                  : unsigned(f_log2_size(g_pipe_size)-1 downto 0);
  signal pl_stall_s                       : std_logic;
  signal pl_stall_r                       : std_logic;
  signal pl_dreq_s                        : std_logic;
  signal pl_dreq_r                        : std_logic;

  -- signals that a packet was actually transfered
  signal pkt_sent                           : std_logic;
  signal lmt_pkt_size                       : unsigned(c_pkt_size_width-1 downto 0);

  -- Output signals
  signal fc_data_out_int                    : t_fc_data;
  signal fc_addr_out_int                    : t_fc_addr;
  signal fc_valid_out_int                   : std_logic;
  --signal fc_valid_out_int_r                 : std_logic;
  signal fc_oob_out_int                     : t_fc_data_oob;

  -- Counters
  -- counts the completed tranfered words to ext mem
  signal fc_in_pend_cnt                  : t_fc_pkt;
  -- measures the difference difference between the write and read output pointers
  signal fifo_diff_pnt_cnt                  : unsigned(f_log2_size(g_pipe_size)-1 downto 0);

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
        lmt_pkt_size <= to_unsigned(1, lmt_pkt_size'length);
      else
        if lmt_valid_i = '1' then
          lmt_pkt_size <= lmt_pkt_size_i;
        end if;
      end if;
    end if;
  end process;

  p_count_valid : process (clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' then
        fc_in_pend_cnt <= to_unsigned(0, fc_in_pend_cnt'length);
      else
        --fc_last_data_r <= fc_last_data;

        if pl_rst_trans_i = '1' or fc_last_data = '1'then
          fc_in_pend_cnt <= to_unsigned(0, fc_in_pend_cnt'length);
        elsif fc_in_data_pending = '1' then
          fc_in_pend_cnt <= fc_in_pend_cnt + 1;
        --elsif fc_last_data_r = '1' then
        --elsif fc_last_data = '1' then
        --  fc_in_pend_cnt <= to_unsigned(0, fc_in_pend_cnt'length);
        end if;
      end if;
    end if;
  end process;

  --fc_in_data_pending <= '1' when pl_valid_i = '1' else '0';
  fc_in_data_pending <= fc_valid_s;

  -- We have a 2 output delay for FIFO. That being said, if we have a not(fc_stall_i)
  -- signal it will take 2 clock cycles in order to read the pl_data_i from FIFO.
  --
  -- By this time, fc_stall_i might be set and we have to wait for it. To
  -- solve this 2 delay read cycle it is employed a small 4 position "buffer" to
  -- hold the values read from fifo but not yet passed to the external memory.
  --
  -- Also not that that difference between pre_output_counter_wr and output_counter_rd
  -- is at most (at any given point in time) not greater than 2. Thus, with a 2
  -- bit counter, we will not overflow
  gen_fifo_pre_output : for i in 0 to g_pipe_size-1 generate
    p_fifo_pre_output : process(clk_i)
    begin
      if rising_edge(clk_i) then
        if rst_n_i = '0' then
          fc_data_out(i) <= (others => '0');
          fc_addr_out(i) <= (others => '0');
          fc_data_oob_out(i) <= (others => '0');
          fc_dvalid_out(i) <= '0';
        else --if fc_valid_s = '1' then
        -- Fifo output is valid by now as fifo_fc_rd was enabled and it was not empty!
        --
        -- Store output from FIFO in the correct fc_data_out(X) if
        -- fc_valid_s is valid.
        --
        -- On the next fc_valid_s operation (next clock cycle if
        -- fc_valid_s remains 1), clear the past fc_dvalid_out(X)
        -- if ext memory has read from it (read pointer is in the past write position).
          if pre_output_counter_wr = i and fc_valid_s = '1' then
            fc_data_out(i) <= pl_data_i;
            fc_addr_out(i) <= pl_addr_i;
            fc_data_oob_out(i) <= fc_first_data & fc_last_data; -- c_data_oob_sof_ofs & c_data_oob_eof_ofs
            fc_dvalid_out(i) <= '1';
          elsif output_counter_rd = i and fc_stall_s = '0' then
            fc_data_out(i) <= (others => '0');
            fc_addr_out(i) <= (others => '0');
            fc_data_oob_out(i) <= (others => '0');
            fc_dvalid_out(i) <= '0';
          end if;
        end if;
      end if;
    end process;
  end generate;

  fc_stall_s <= '0' when fc_stall_i = '0' else fc_valid_out_int;
  --fc_stall_s <= '0' when fc_stall_i = '0' else fc_valid_out_int_r;
  fc_valid_s <= '1' when pl_valid_i = '1' and pl_stall_r = '0' else '0';

  fc_first_data <= '1' when fc_valid_s = '1' and
                                 fc_in_pend_cnt = to_unsigned(0, fc_in_pend_cnt'length)
                                 else '0';
  --fc_last_data <= '1' when fc_valid_s = '1' and fc_in_pend_cnt = lmt_pkt_size_i - 1 and
  --                                lmt_valid_i = '1'-- not sync to ext_clk!!! Might not met timing!!!
  --                                else '0';
  fc_last_data <= '1' when fc_valid_s = '1' and fc_in_pend_cnt = lmt_pkt_size - 1
                                  else '0';

  p_fifo_pre_output_counter : process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' then
        pre_output_counter_wr <= to_unsigned(0, pre_output_counter_wr'length);
      else
        if fc_valid_s = '1' then
          pre_output_counter_wr <= pre_output_counter_wr + 1;
        end if;
      end if;
    end if;
  end process;

  -- signals that a packet was actually transfered
  pkt_sent <= '1' when fc_valid_out_int = '1' and fc_stall_i = '0' else '0';
  --pkt_sent <= '1' when fc_valid_out_int_r = '1' and fc_stall_i = '0' else '0';

  -- Measures the difference between read and write output pointers.
  -- As the write pointer increments, this counter increments and as
  -- the read pointer increments, this counter decrements.
  -- The output pipeline is full when the counter reaches the maximum count.
  --
  -- There is a special case when both pointers increment in the same clock
  -- cycle. In this case, we do nothing

  p_fifo_diff_counter : process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' then
        fifo_diff_pnt_cnt <= to_unsigned(0, fifo_diff_pnt_cnt'length);
      else
        -- read pointer increment (diff decrement)
        --if fc_stall_s = '0' and output_counter_rd /= pre_output_counter_wr then
        if fc_stall_s = '0' and fc_read_next_pkt = '1' then
          if fc_valid_s = '0' then
            fifo_diff_pnt_cnt <= fifo_diff_pnt_cnt - 1;
          --else --both pointer increments simultaneouslly. Do nothing in this case
          end if;
        elsif fc_valid_s = '1' then
          -- write pointer increment (diff increment)
          fifo_diff_pnt_cnt <= fifo_diff_pnt_cnt + 1;
        end if;
      end if;
    end if;
  end process;

  -- Monitor output pipeline. FIXME!
  output_pipe_full <= '1' when fifo_diff_pnt_cnt = c_pipe_almost_full else '0';
  -- Pipeline almost full. We have room for 1 (or more if c_pipe_almost_full if changed)
  -- more word efore starting to lose data. With this signal we can stall the previous
  -- pipeline component, but still receive the current data (if valid).
  --
  -- Without this signal, we could loose data if the pl_stall_o signal was asserted in the
  -- same cycle as pl_valid_i. This happens for some components that have one (or more) delay
  -- cycles between reading from some FIFO, for instance.
  output_pipe_almost_full <= '1' when fifo_diff_pnt_cnt = c_pipe_almost_full-1 else '0';
  --output_pipe_empty <= '1' when fifo_diff_pnt_cnt = to_unsigned(0, fifo_diff_pnt_cnt'length) else '0';
  output_pipe_empty <= '1' when fifo_diff_pnt_cnt = to_unsigned(0, fifo_diff_pnt_cnt'length) else '0';
  -- only works with the current pipe_size settings! FIXME!
  output_pipe_almost_empty <= '1' when fifo_diff_pnt_cnt = c_pipe_almost_empty else '0';

  --pl_stall_s <= output_pipe_almost_full or output_pipe_full;
  --pl_stall_s <= output_pipe_full;
  --pl_dreq_o <= output_pipe_empty or fc_dreq_i;
  --pl_dreq_s <= output_pipe_empty or output_pipe_almost_empty;
  --pl_dreq_s <= output_pipe_empty or output_pipe_almost_empty; -- avoid starvation
  --pl_dreq_o <= not(pl_stall_t);

  p_reg_stall_dreq_out : process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' then
        pl_stall_r <= '0';
        pl_dreq_r <= '0';
      else

        if output_pipe_almost_full = '1' and fc_valid_s = '1' then
          --pl_stall_r <= pl_stall_s;
          pl_stall_r <= '1';
        elsif output_pipe_full = '0' then
          pl_stall_r <= '0';
        end if;

        --pl_dreq_r <= pl_dreq_s;
        -- FIXME!
        pl_dreq_r <=  output_pipe_empty or output_pipe_almost_empty;
      end if;
    end if;
  end process;

  pl_stall_o <= pl_stall_r;
  pl_dreq_o <= pl_dreq_r;

  p_ext_mux_output : process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' then
        fc_data_out_int <= (others => '0');
        fc_oob_out_int <= (others => '0');
        fc_addr_out_int <= (others => '0');
        fc_valid_out_int <= '0';
        output_counter_rd <= to_unsigned(0, output_counter_rd'length);
      else
        if fc_stall_s = '0' then

          -- There was no if condition before!! remove if error!
          --
          -- In case the previous packet was valid and we do not request another
          -- packet from the FC, hold the current packet in the pipeline and
          -- unvalid this if valid before.
          --
          -- Also, we do not increment the read counter, so no loss of packet
          -- happens here, just a backpressure
          --if fc_dreq_i = '1' then

            --fc_valid_out_int <= fc_dvalid_out(to_integer(output_counter_rd));

          --else
          --  fc_valid_out_int <= '0';
          --end if;

          -- Keep the old data if the current one is not valid
          --if fc_dvalid_out(to_integer(output_counter_rd)) = '1' then
            -- verify wr counter and output corresponding output
            fc_data_out_int <= fc_data_out(to_integer(output_counter_rd));
            fc_addr_out_int <= fc_addr_out(to_integer(output_counter_rd));
            fc_oob_out_int <= fc_data_oob_out(to_integer(output_counter_rd));
            fc_valid_out_int <= fc_dvalid_out(to_integer(output_counter_rd));
            --fifo_fc_addr_r <= std_logic_vector(fifo_fc_addr);
          --end if;

          -- Only increment output_counter_rd if it is different from
          -- pre_output_counter_wr to prevent overflow!
          --if output_counter_rd /= pre_output_counter_wr then
          --if output_counter_rd /= pre_output_counter_wr and fc_dreq_i = '1' then
          if fc_read_next_pkt = '1' then
            output_counter_rd <= output_counter_rd + 1;
          end if;
        end if;

      end if;
    end if;
  end process;

  fc_read_next_pkt <= '1' when output_counter_rd /= pre_output_counter_wr and fc_dreq_i = '1'
                            else '0';

  --p_ext_valid_output : process(clk_i)
  --begin
  --  if rising_edge(clk_i) then
  --    if rst_n_i = '0' then
  --      fc_valid_out_int <= '0';
  --    else
  --      if fc_stall_s = '0' then
  --        fc_valid_out_int <= fc_dvalid_out(to_integer(output_counter_rd));
  --      end if;
  --    end if;
  --  end if;
  --end process;

  fc_dout_o                            <= fc_data_out_int;
  fc_valid_o                           <= fc_valid_out_int;
  fc_addr_o                            <= fc_addr_out_int;
  fc_sof_o                             <= fc_oob_out_int(c_data_oob_sof_ofs);
  fc_eof_o                             <= fc_oob_out_int(c_data_oob_eof_ofs);

  pl_pkt_sent_o                        <= pkt_sent;

end rtl;
