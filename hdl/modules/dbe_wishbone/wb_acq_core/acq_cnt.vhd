------------------------------------------------------------------------------
-- Title      : BPM Acquisition Counter
------------------------------------------------------------------------------
-- Author     : Lucas Maziero Russo
-- Company    : CNPEM LNLS-DIG
-- Created    : 2013-06-11
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: Simple counter of transactions and shots
-------------------------------------------------------------------------------
-- Copyright (c) 2013 CNPEM
-- Licensed under GNU Lesser General Public License (LGPL) v3.0
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2013-06-11  1.0      lucas.russo        Created
-------------------------------------------------------------------------------

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

entity acq_cnt is
port
(
  -- DDR3 external clock
  clk_i                                     : in  std_logic;
  rst_n_i                                   : in  std_logic;

  cnt_all_pkts_ct_done_p_o                  : out std_logic; -- all current transaction packets done
  cnt_all_trans_done_p_o                    : out std_logic; -- all transactions done
  cnt_en_i                                  : in std_logic;
  --cnt_rst_i                                 : in std_logic;

  -- Size of the transaction in g_fifo_size bytes
  lmt_pkt_size_i                            : in unsigned(c_pkt_size_width-1 downto 0);
  -- Number of shots in this acquisition
  lmt_shots_nb_i                            : in unsigned(c_shots_size_width-1 downto 0);
  -- Acquisition limits valid signal. Qualifies lmt_pkt_size_i and lmt_shots_nb_i
  lmt_valid_i                               : in std_logic;

  dbg_pkt_ct_cnt_o                          : out std_logic_vector(c_pkt_size_width-1 downto 0);
  dbg_shots_cnt_o                           : out std_logic_vector(c_shots_size_width-1 downto 0)
);
end acq_cnt;

architecture rtl of acq_cnt is

  signal pkt_ct_cnt                          : unsigned(c_pkt_size_width-1 downto 0);
  signal pkt_cnt_en                          : std_logic;

  signal pkt_ct_cnt_all                      : std_logic;

  signal shots_cnt                           : unsigned(c_shots_size_width-1 downto 0);
  signal shots_cnt_all                       : std_logic;
  --signal shots_cnt_all_p                     : std_logic;

  signal lmt_pkt_size                        : unsigned(c_pkt_size_width-1 downto 0);
  signal lmt_shots_nb                        : unsigned(c_shots_size_width-1 downto 0);

begin

  -----------------------------------------------------------------------------
  -- Register input
  -----------------------------------------------------------------------------
  p_in_reg : process (clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' then
        --Avoid detection of *_done pulses by setting them to 1
        lmt_pkt_size <= to_unsigned(1, lmt_pkt_size'length);
        lmt_shots_nb <= to_unsigned(1, lmt_shots_nb'length);
      else
        if lmt_valid_i = '1' then
          lmt_pkt_size <= lmt_pkt_size_i;
          lmt_shots_nb <= lmt_shots_nb_i;
        end if;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Number of packets
  -----------------------------------------------------------------------------

  --p_pkt_ct_cnt : process (clk_i)
  --begin
  --  if rising_edge(clk_i) then
  --    if rst_n_i = '0' then
  --      pkt_ct_cnt <= to_unsigned(0, pkt_ct_cnt'length);
  --    else
  --      if pkt_ct_cnt_all = '1' then
  --        pkt_ct_cnt <= to_unsigned(0, pkt_ct_cnt'length);
  --      elsif pkt_cnt_en = '1' then
  --        pkt_ct_cnt <= pkt_ct_cnt + 1;
  --      end if;
  --    end if;
  --  end if;
  --end process;

  p_pkt_ct_cnt : process (clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' then
        pkt_ct_cnt <= to_unsigned(0, pkt_ct_cnt'length);
      else
        if pkt_ct_cnt_all = '1' then -- counter wrap-around
          if pkt_cnt_en = '1' then -- simultaneously wrap-around and increment by one
            pkt_ct_cnt <= to_unsigned(1, pkt_ct_cnt'length);
          else
            pkt_ct_cnt <= to_unsigned(0, pkt_ct_cnt'length);
          end if;
        elsif pkt_cnt_en = '1' then
          pkt_ct_cnt <= pkt_ct_cnt + 1;
        end if;
      end if;
    end if;
  end process;

  pkt_cnt_en <= cnt_en_i;

  -- Debug outputs
  dbg_pkt_ct_cnt_o <= std_logic_vector(pkt_ct_cnt);

  p_pkt_ct_cnt_reg : process (clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' then
        pkt_ct_cnt_all <= '0';
      else
        if pkt_ct_cnt = lmt_pkt_size-1 and pkt_cnt_en = '1' then
          pkt_ct_cnt_all <= '1';
        else
          pkt_ct_cnt_all <= '0';
        end if;
      end if;
    end if;
  end process;

  --pkt_ct_cnt_all <= '1' when pkt_ct_cnt = lmt_pkt_size_i and
  --                                  lmt_valid_i = '1' else '0';

  cnt_all_pkts_ct_done_p_o <= pkt_ct_cnt_all; -- this is necessarilly a pulse

  -----------------------------------------------------------------------------
  -- Number of shots
  -----------------------------------------------------------------------------
  --p_shots_cnt : process (clk_i)
  --begin
  --  if rising_edge(clk_i) then
  --    if rst_n_i = '0' then
  --      shots_cnt <= to_unsigned(0, shots_cnt'length);
  --    else
  --      if shots_cnt_all = '1' then
  --        shots_cnt <= to_unsigned(0, shots_cnt'length);
  --      elsif pkt_ct_cnt_all = '1' then
  --        shots_cnt <= shots_cnt + 1;
  --      end if;
  --    end if;
  --  end if;
  --end process;

  p_shots_cnt : process (clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' then
        shots_cnt <= to_unsigned(0, shots_cnt'length);
      else
        if shots_cnt_all = '1' then
          if pkt_ct_cnt_all = '1' then -- This case won't happen. Should we keep it?
            shots_cnt <= to_unsigned(1, shots_cnt'length);
          else
            shots_cnt <= to_unsigned(0, shots_cnt'length);
          end if;
        elsif pkt_ct_cnt_all = '1' then
          shots_cnt <= shots_cnt + 1;
        end if;
      end if;
    end if;
  end process;

  -- Debug outputs
  dbg_shots_cnt_o <= std_logic_vector(shots_cnt);

  p_shots_cnt_reg : process (clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' then
        shots_cnt_all <= '0';
      else
        if shots_cnt = lmt_shots_nb-1 and pkt_ct_cnt_all = '1' then
          shots_cnt_all <= '1';
        else
          shots_cnt_all <= '0';
        end if;
      end if;
    end if;
  end process;

  --shots_cnt_all <= '1' when shots_cnt = lmt_shots_nb_i and lmt_valid_i = '1'
  --                             else '0'; -- this is necessarilly a pulse

  ---- Level to Pulse converter
  --cmp_lmt_valid_ffs : gc_sync_ffs
  --port map(
  --  clk_i                                   => clk_i,
  --  rst_n_i                                 => rst_n_i,
  --  data_i                                  => shots_cnt_all,
  --  synced_o                                => open,
  --  npulse_o                                => open,
  --  ppulse_o                                => shots_cnt_all_p
  --);

  --cnt_all_trans_done_p_o <= shots_cnt_all_p;
  cnt_all_trans_done_p_o <= shots_cnt_all;

end rtl;
