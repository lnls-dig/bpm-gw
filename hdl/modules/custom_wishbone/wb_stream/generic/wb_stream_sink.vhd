-------------------------------------------------------------------------------
-- Title      : Wishbone Packet Fabric buffered packet sink
-- Project    : WR Cores Collection
-------------------------------------------------------------------------------
-- File       : xwb_fabric_sink.vhd
-- Author     : Tomasz Wlostowski
-- Company    : CERN BE-CO-HT
-- Created    : 2012-01-16
-- Last update: 2012-01-22
-- Platform   :
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: A simple WB packet streaming sink with builtin FIFO buffer.
-- Outputs a trivial interface (start-of-packet, end-of-packet, data-valid)
-------------------------------------------------------------------------------
--
-- Copyright (c) 2011 CERN
--
-- This source file is free software; you can redistribute it
-- and/or modify it under the terms of the GNU Lesser General
-- Public License as published by the Free Software Foundation;
-- either version 2.1 of the License, or (at your option) any
-- later version.
--
-- This source is distributed in the hope that it will be
-- useful, but WITHOUT ANY WARRANTY; without even the implied
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
-- PURPOSE.  See the GNU Lesser General Public License for more
-- details.
--
-- You should have received a copy of the GNU Lesser General
-- Public License along with this source; if not, download it
-- from http://www.gnu.org/licenses/lgpl-2.1.html
--
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2011-01-16  1.0      twlostow        Created
-------------------------------------------------------------------------------
--
-- Modified by Lucas Russo <lucas.russo@lnls.br> for multiple width support

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.genram_pkg.all;
use work.wb_stream_generic_pkg.all;

entity wb_stream_sink is
generic (
  --g_wbs_adr_width                         : natural := c_wbs_adr4_width;
  g_wbs_dat_width                           : t_wbs_interface_width := LARGE1
);
port (
  clk_i                                     : in std_logic;
  rst_n_i                                   : in std_logic;

  -- Wishbone Streaming Interface I/O.
  -- Only the used interface should be connected. The others can be left unconnected
  -- 16-bit interface
  snk_adr16_i                               : in t_wbs_adr4 := cc_dummy_wbs_adr;
  snk_dat16_i                               : in t_wbs_dat16 := cc_dummy_wbs_dat;
  snk_sel16_i                               : in t_wbs_sel2 := cc_dummy_wbs_sel;

  -- 32-bit interface
  snk_adr32_i                               : in t_wbs_adr4 := cc_dummy_wbs_adr;
  snk_dat32_i                               : in t_wbs_dat32 := cc_dummy_wbs_dat;
  snk_sel32_i                               : in t_wbs_sel4 := cc_dummy_wbs_sel;

  -- 64-bit interface
  snk_adr64_i                               : in t_wbs_adr4 := cc_dummy_wbs_adr;
  snk_dat64_i                               : in t_wbs_dat64 := cc_dummy_wbs_dat;
  snk_sel64_i                               : in t_wbs_sel8 := cc_dummy_wbs_sel;

  -- 128-bit interface
  snk_adr128_i                              : in t_wbs_adr4 := cc_dummy_wbs_adr;
  snk_dat128_i                              : in t_wbs_dat128 := cc_dummy_wbs_dat;
  snk_sel128_i                              : in t_wbs_sel16 := cc_dummy_wbs_sel;

  -- Common Wishbone Streaming lines
  snk_cyc_i                                 : in std_logic := '0';
  snk_stb_i                                 : in std_logic := '0';
  snk_we_i                                  : in std_logic := '0';
  snk_ack_o                                 : out std_logic;
  snk_stall_o                               : out std_logic;
  snk_err_o                                 : out std_logic;
  snk_rty_o                                 : out std_logic;

  -- Decoded & buffered logic
  -- Only the used interface must be connected. The others can be left unconnected
  -- 16-bit interface
  adr16_o                                 : out std_logic_vector(c_wbs_adr4_width-1 downto 0);
  dat16_o                                 : out std_logic_vector(c_wbs_dat16_width-1 downto 0);
  sel16_o                                 : out std_logic_vector(c_wbs_sel16_width-1 downto 0);
  -- 32-bit interface
  adr32_o                                 : out std_logic_vector(c_wbs_adr4_width-1 downto 0);
  dat32_o                                 : out std_logic_vector(c_wbs_dat32_width-1 downto 0);
  sel32_o                                 : out std_logic_vector(c_wbs_sel32_width-1 downto 0);
  -- 64-bit interface
  adr64_o                                 : out std_logic_vector(c_wbs_adr4_width-1 downto 0);
  dat64_o                                 : out std_logic_vector(c_wbs_dat64_width-1 downto 0);
  sel64_o                                 : out std_logic_vector(c_wbs_sel64_width-1 downto 0);
  -- 128-bit interface
  adr128_o                                : out std_logic_vector(c_wbs_adr4_width-1 downto 0);
  dat128_o                                : out std_logic_vector(c_wbs_dat128_width-1 downto 0);
  sel128_o                                : out std_logic_vector(c_wbs_sel128_width-1 downto 0);

  -- Common lines
  dvalid_i                                : out std_logic;
  sof_i                                   : out std_logic;
  eof_i                                   : out std_logic;
  error_i                                 : out std_logic;
  dreq_o                                  : in std_logic := '0'
);
end wb_stream_sink;

architecture rtl of wb_stream_sink is
  -- Convert enum to natural
  constant c_wbs_dat_width : natural := f_conv_wbs_dat_width(g_wbs_interface_width);
  constant c_wbs_sel_width : natural := c_wbs_dat_width/8;
  -- Fixed 4-bit address as we do not exceptct it to address real peripheral
  -- just to inform some other conditions
  constant c_wbs_adr_width : natural := c_wbs_adr4_width;

  -- FIFO ranges
  constant c_dat_lsb                        : natural := 0;
  constant c_dat_msb                        : natural := c_dat_lsb + c_wbs_dat_width - 1;

  constant c_adr_lsb                        : natural := c_dat_msb + 1;
  constant c_adr_msb                        : natural := c_adr_lsb + c_wbs_adr_width -1;

  constant c_valid_bit                      : natural := c_adr_msb + 1;

  constant c_sel_lsb                        : natural := c_valid_bit + 1;
  constant c_sel_msb                        : natural := c_sel_lsb + c_wbs_sel_width - 1;

  constant c_eof_bit                        : natural := c_sel_msb + 1;
  constant c_sof_bit                        : natural := c_eof_bit + 1;

  alias c_logic_lsb                         is c_valid_bit;
  alias c_logic_msb                         is c_sof_bit;
  constant c_logic_width                    : integer := c_sof_bit - c_valid_bit + 1;

  constant c_fifo_width                     : integer := c_sof_bit - c_dat_lsb + 1;
  constant c_fifo_depth                     : integer := 32;

  constant c_logic_zeros                    : std_logic_vector(c_logic_msb downto c_logic_lsb)
                := std_logic_vector(to_unsigned(0, c_logic_width));

  signal q_valid, full, we, rd              : std_logic;
  signal fin, fout, fout_reg                : std_logic_vector(c_fifo_width-1 downto 0);
  signal cyc_d0, rd_d0                      : std_logic;

  signal pre_dvalid                         : std_logic;
  signal pre_eof                            : std_logic;
  signal pre_dat                            : std_logic_vector(c_wbs_dat_width-1 downto 0);
  signal pre_adr                            : std_logic_vector(c_wbs_adr_width-1 downto 0);
  signal pre_sel                            : std_logic_vector(c_wbs_sel_width-1 downto 0);

  signal post_sof, post_dvalid              : std_logic;
  signal post_adr                           : std_logic_vector(c_wbs_adr_width-1 downto 0);
  signal post_dat                           : std_logic_vector(c_wbs_dat_width-1 downto 0);
  signal post_eof                           : std_logic;
  signal post_sel                           : std_logic_vector(c_wbs_sel_width-1 downto 0);

  -- Internal signals
  signal snk_stall_int                      : std_logic;
  signal snk_ack_int                        : std_logic;
  signal snk_rty_int                        : std_logic;
  signal snk_err_int                        : std_logic;

begin  -- rtl

  p_delay_cyc_and_rd : process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' then
        cyc_d0 <= '0';
        rd_d0  <= '0';
      else
        if(full = '0') then
          cyc_d0 <= snk_cyc_i;
        end if;

        rd_d0 <= rd;
      end if;
    end if;
  end process;

  pre_sof <= snk_cyc_i and not cyc_d0;
  pre_eof <= not snk_i.cyc and cyc_d0;
  pre_dvalid <= snk_stb_i and snk_we_i and snk_cyc_i and not snk_stall_int;

  -----------------------------
  -- Wishbone Streaming Interface selection
  -----------------------------
  gen_16_bit_interface : if g_wbs_interface_width = NARROW2 generate
    fin(c_dat_msb downto c_dat_lsb) <= snk_dat16_i;
    fin(c_adr_msb downto c_adr_lsb) <= snk_adr16_i;
    pre_sel <= snk_sel16_i;
  end generate;

  gen_32_bit_interface : if g_wbs_interface_width = NARROW1 generate
    fin(c_dat_msb downto c_dat_lsb) <= snk_dat32_i;
    fin(c_adr_msb downto c_adr_lsb) <= snk_adr32_i;
    pre_sel <= snk_sel32_i;
  end generate;

  gen_64_bit_interface : if g_wbs_interface_width = LARGE1 generate
    fin(c_dat_msb downto c_dat_lsb) <= snk_dat64_i;
    fin(c_adr_msb downto c_adr_lsb) <= snk_adr64_i;
    pre_sel <= snk_sel64_i;
  end generate;

  gen_128_bit_interface : if g_wbs_interface_width = LARGE2 generate
    fin(c_dat_msb downto c_dat_lsb) <= snk_dat128_i;
    fin(c_adr_msb downto c_adr_lsb) <= snk_adr128_i;
    pre_sel <= snk_sel128_i;
  end generate;

  fin(c_logic_msb downto c_logic_lsb) <= pre_sof & pre_eof & pre_sel & pre_dvalid;

  snk_stall_int <= full or (snk_cyc_i and not cyc_d0);
  snk_err_int <= '0';
  snk_rty_int <= '0';

  p_gen_ack : process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' then
        snk_ack_int <= '0';
      else
        snk_ack_int <= snk_cyc_i and snk_stb_i and snk_we_i and not snk_stall_int;
      end if;
    end if;
  end process;

  we <= '1' when fin(c_logic_msb downto c_logic_lsb) /= c_logic_zeros
                and full = '0' else '0';
  rd <= q_valid and dreq_i and not post_sof;

  cmp_fifo : generic_shiftreg_fifo
  generic map (
    g_data_width                            => c_fifo_width,
    g_size                                  => c_fifo_depth
  )
  port map (
    rst_n_i                                 => rst_n_i,
    clk_i                                   => clk_i,
    d_i                                     => fin,
    we_i                                    => we,
    q_o                                     => fout,
    rd_i                                    => rd,
    almost_full_o                           => full,
    q_valid_o                               => q_valid
  );

  p_fout_reg : process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' then
        fout_reg <= (others => '0');
      elsif(rd = '1') then
        fout_reg <= fout;
      end if;
    end if;
  end process;

  -- Output fifo registers only when valid
  --p_post_regs : process(fout_reg, q_valid)
  --begin
  --  if q_valid = '1' then
  --    post_data <= fout_reg(c_data_msb downto c_data_lsb);
  --    post_addr <= fout_reg(c_addr_msb downto c_addr_lsb);
  --    post_sof  <= fout_reg(c_sof_bit); --and rd_d0; --and q_valid;
  --    post_dvalid <= fout_reg(c_valid_bit);
  --    post_eof <= fout_reg(c_eof_bit);-- and rd_d0;
  --    post_bytesel <= fout_reg(c_sel_msb downto c_sel_lsb);
  --  else
  --    post_data <= (others => '0');
  --    post_addr <= (others => '0');
  --    post_sof  <= '0';
  --    post_dvalid <= '0';
  --    post_eof <= '0';
  --    post_bytesel <= (others => '0');
  --  end if;
  --end process;

  post_sof  <= fout_reg(c_sof_bit) and rd_d0; --and q_valid;
  post_dvalid <= fout_reg(c_valid_bit);
  post_eof <= fout_reg(c_eof_bit);
  post_sel <= fout_reg(c_sel_msb downto c_sel_lsb);
  post_dat <= fout_reg(c_dat_msb downto c_dat_lsb);
  post_adr <= fout_reg(c_adr_msb downto c_adr_lsb);

  snk_stall_o <= snk_stall_int;
  snk_ack_o <= snk_ack_int;
  snk_rty_o <= snk_rty_int;
  snk_err_o <= snk_err_int;

  sof_o <= post_sof and rd_d0;
  dvalid_o <= post_dvalid and rd_d0;
  error_o <= '1' when rd_d0 = '1' and (post_adr = std_logic_vector(c_WBS_STATUS)) and
          (f_unmarshall_wbs_status(post_dat).error = '1') else '0';
  eof_o <= post_eof and rd_d0;

  -----------------------------
  -- Wishbone Streaming Interface selection
  -----------------------------
  gen_16_bit_interface : if g_wbs_interface_width = NARROW2 generate
    sel16_o <= post_sel;
    dat16_o <= post_dat;
    adr16_o <= post_adr;
  end generate;

  gen_32_bit_interface : if g_wbs_interface_width = NARROW1 generate
    sel32_o <= post_sel;
    dat32_o <= post_dat;
    adr32_o <= post_adr;
  end generate;

  gen_64_bit_interface : if g_wbs_interface_width = LARGE1 generate
    sel64_o <= post_sel;
    dat64_o <= post_dat;
    adr64_o <= post_adr;
  end generate;

  gen_128_bit_interface : if g_wbs_interface_width = LARGE2 generate
    sel128_o <= post_sel;
    dat128_o <= post_dat;
    adr128_o <= post_adr;
  end generate;

end rtl;
