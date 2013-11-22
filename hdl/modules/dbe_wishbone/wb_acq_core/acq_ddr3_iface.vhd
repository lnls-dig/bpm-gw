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
--               (BC4) Xilinx interface.
--             For now, this modules performs very simple (and dumb) DDR3 write
--              through the UI interface. It can perform much better than this!
--             Also, this module is killing all the performance, as it does not
--               aggregate data before sending it. It just sends the input word
--               masked to the correct position to the DDR3 controller.
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

entity acq_ddr3_iface is
generic
(
  g_data_width                              : natural := 64;
  g_addr_width                              : natural := 32;
  -- Do not modify these! As they are dependent of the memory controller generated!
  g_ddr_payload_width                       : natural := 256;
  g_ddr_addr_width                          : natural := 32
);
port
(
  -- DDR3 external clock
  ext_clk_i                                 : in  std_logic;
  ext_rst_n_i                               : in  std_logic;

  -- Flow protocol to interface with external SDRAM. Evaluate the use of
  -- Wishbone Streaming protocol.
  fifo_fc_din_i                             : in std_logic_vector(g_data_width-1 downto 0);
  fifo_fc_valid_i                           : in std_logic;
  fifo_fc_addr_i                            : in std_logic_vector(g_addr_width-1 downto 0);
  fifo_fc_sof_i                             : in std_logic;
  fifo_fc_eof_i                             : in std_logic;
  fifo_fc_dreq_o                            : out std_logic;
  fifo_fc_stall_o                           : out std_logic;

  wr_start_i                                : in std_logic;
  wr_init_addr_i                            : in std_logic_vector(g_ddr_addr_width-1 downto 0);

  lmt_all_trans_done_p_o                    : out std_logic;
  lmt_rst_i                                 : in std_logic;

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

  -- Constants
  -- g_ddr_payload_width must be bigger than g_data_width by at least 2 times.
  -- Also, only power of 2 ratio sizes are supported
  constant c_ddr_fc_payload_ratio           : natural := g_ddr_payload_width/g_data_width;
  constant c_ddr_mask_width                 : natural := g_ddr_payload_width/8;
  alias c_ddr_payload_width                 is g_ddr_payload_width;
  --constant c_ddr_mask_shift                 : natural := g_data_width/8;

  -- Data increment constants
  constant c_addr_col_inc                   : natural := 1;
  constant c_addr_bc4_inc                   : natural := 4;
  constant c_addr_bl8_inc                   : natural := 8;
  constant c_addr_ddr_inc                   : natural := c_addr_bc4_inc;

  -- Flow Control constants
  constant c_pkt_size_width                 : natural := 32;
  constant c_pipe_size                      : natural := 4;
  constant c_addr_cnt_width                 : natural := f_log2_size(c_ddr_fc_payload_ratio);
  constant c_pkt_size_shift                 : natural := f_log2_size(c_ddr_fc_payload_ratio);
  constant c_max_addr_cnt                   : natural := c_ddr_fc_payload_ratio-1;
  --constant c_addr_width                     : natural := 32;

  -- UI Commands
  constant c_ui_cmd_write                   : std_logic_vector(2 downto 0) := "000";
  constant c_ui_cmd_read                    : std_logic_vector(2 downto 0) := "001";

  -- Constants for data + mask aggregate signal
  constant c_mask_low                       : natural := 0;
  constant c_mask_high                      : natural := c_ddr_mask_width + c_mask_low -1;
  constant c_data_low                       : natural := c_mask_high + 1;
  constant c_data_high                      : natural := c_ddr_payload_width + c_data_low -1;

  -- Constants for ddr3 address bits
  constant c_ddr_addr_ovf_lsb               : natural := 0;
  constant c_ddr_addr_ovf_msb               : natural := c_addr_cnt_width-1;
  constant c_ddr_addr_ovf_bit               : natural := c_addr_cnt_width;
  constant c_ddr_align_shift                : natural := f_log2_size(c_ddr_fc_payload_ratio);

  -- Flow control signals
  signal lmt_pkt_size                       : unsigned(c_pkt_size_width-1 downto 0);
  signal lmt_pkt_size_shd                   : unsigned(c_pkt_size_width-1 downto 0);
  signal lmt_shots_nb                       : unsigned(c_shots_size_width-1 downto 0);
  signal lmt_valid                          : std_logic;
  signal fc_dout                            : std_logic_vector(g_ddr_payload_width+c_ddr_mask_width-1 downto 0);
  signal fc_valid_app                       : std_logic;
  signal fc_valid_app_wdf                   : std_logic;
  signal fc_addr                            : std_logic_vector(g_addr_width-1 downto 0);
  signal fc_stall_app                       : std_logic;
  signal fc_dreq_app                        : std_logic;
  signal fc_stall_app_wdf                   : std_logic;
  signal fc_dreq_app_wdf                    : std_logic;

  signal valid_trans_app                    : std_logic;
  signal valid_trans_app_d0                 : std_logic;
  signal valid_trans_app_wdf                : std_logic;
  signal cnt_all_trans_done_p               : std_logic;
  signal wr_init_addr_alig                  : std_logic_vector(g_ddr_addr_width-1 downto 0);

  -- Plain interface control
  signal pl_dreq                            : std_logic;
  signal pl_stall                           : std_logic;
  -- FIXME: Ue single signal!
  --signal pl_stall_addr_d0                   : std_logic;
  --signal pl_stall_data_d0                   : std_logic;
  signal pl_stall_d0                        : std_logic;
  signal pl_dreq_app                        : std_logic;
  signal pl_stall_app                       : std_logic;
  signal pl_pkt_sent_app                    : std_logic;
  signal pl_dreq_app_wdf                    : std_logic;
  signal pl_stall_app_wdf                   : std_logic;
  signal pl_pkt_sent_app_wdf                : std_logic;
  signal pl_rst_trans                       : std_logic;

  -- DDR3 Signals
  signal ddr_data_in                        : std_logic_vector(g_ddr_payload_width-1 downto 0);
  signal ddr_addr_cnt_min                   : unsigned(c_addr_cnt_width-1 downto 0);
  signal ddr_addr_cnt_min_ovf               : unsigned(c_addr_cnt_width downto 0); -- with overflow bit
  signal ddr_addr_cnt_min_ovf_s             : std_logic_vector(c_addr_cnt_width downto 0); -- with overflow bit
  signal ddr_addr_cnt_inc                   : std_logic;
  signal ddr_addr_inc                       : unsigned(c_addr_cnt_width-1 downto 0);
  signal ddr_addr_cnt                       : unsigned(g_ddr_addr_width-1 downto 0);
  signal ddr_addr_in                        : std_logic_vector(g_ddr_addr_width-1 downto 0);
  --signal ddr_data_valid_in                  : std_logic;
  --signal ddr_addr_valid_in                  : std_logic;
  signal ddr_valid_in                       : std_logic;
  
  signal ddr_mask_in                        : std_logic_vector(c_ddr_mask_width-1 downto 0);
  signal ddr_data_mask_in                   : std_logic_vector(g_ddr_payload_width+c_ddr_mask_width-1 downto 0);

  signal ddr_rdy_app                        : std_logic;
  signal ddr_rdy_app_wdf                    : std_logic;

  -- DDR3 Arbitrer Signals
  signal ddr_req                            : std_logic;

  signal acq_cnt_rst_n                      : std_logic;

  -- Generates a big std_logic_vector concatenating a determined "word" of size
  -- "atom_size", in offset "ofs" in the generated word, filling the remaining
  -- positions with the "filler" pattern
  function f_gen_big_word(b_word_size : natural; atom_size : natural; ofs : natural;
                            word : std_logic_vector; filler : std_logic_vector)
    return std_logic_vector
  is
    variable b_word : std_logic_vector(b_word_size-1 downto 0);
  begin
    for i in 0 to b_word_size/atom_size-1 loop
      if i = ofs then
        b_word((i+1)*atom_size-1 downto i*atom_size) :=
                    word(atom_size-1 downto 0); -- Caution passing this parameter!
      else
        b_word((i+1)*atom_size-1 downto i*atom_size) :=
                    filler(atom_size-1 downto 0); -- Caution passing this parameter!
      end if;
    end loop;

    return b_word;
  end;

  -- Generate mask for writing data to exernal interface.
  --
  -- not(mask_pol) means "do not mask" and mask_pol means "mask"
  function f_gen_mask(mask_size : natural; mask_atom_size : natural; mask_ofs : natural;
                        mask_pol : std_logic)
    return std_logic_vector
  is
    variable mask : std_logic_vector(mask_size-1 downto 0);
  begin
    mask := f_gen_big_word(mask_size, mask_atom_size, mask_ofs,
                            f_gen_std_logic_vector(mask_atom_size, not(mask_pol)),
                            f_gen_std_logic_vector(mask_atom_size, mask_pol));

    return mask;
  end;

  function f_gen_padded_word(padded_word_size : natural; word_atom_size: natural; word_ofs : natural;
                           word : std_logic_vector; filler : std_logic_vector)
    return std_logic_vector
  is
    variable padded_word : std_logic_vector(padded_word_size-1 downto 0);
  begin
    padded_word := f_gen_big_word(padded_word_size, word_atom_size,
                            word_ofs, word, filler);

    return padded_word;
  end;

  function f_gen_zeros(width : natural)
    return std_logic_vector
  is
    variable ret : std_logic_vector(width-1 downto 0);
  begin
    for i in 0 to width-1 loop
      ret(i) := '0';
    end loop;

    return ret;
  end;

begin

  -- g_addr_width != g_ddr_addr_width is not supported!
  assert (g_addr_width = g_ddr_addr_width)
  report "[DDR3 Interface] Different address widths are not supported!"
  severity error;
  
  ----------------------------------------------------------------------------
  -- Register transaction limits
  -----------------------------------------------------------------------------
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
          --lmt_pkt_size <= lmt_pkt_size_i;
          -- The packet size here is constrained by the relation f_log2(g_ddr_payload_width/g_data_width),
          -- as we aggregate data by that amount to send it to the DDR3 controller
          lmt_pkt_size <= shift_right(lmt_pkt_size_i, c_pkt_size_shift);
          lmt_shots_nb <= lmt_shots_nb_i;
        end if;
      end if;
    end if;
  end process;

  -- To previous flow control module (Acquisition FIFO)
  fifo_fc_stall_o <= pl_stall;
  fifo_fc_dreq_o <= pl_dreq;

  -- Dummy signals as we don't use SOF or EOF signals
  --lmt_pkt_size <= to_unsigned(1, lmt_pkt_size'length);
  --lmt_valid <= '1';

  -- Delayed signals
  p_valid_trans_d0 : process(ext_clk_i)
  begin
    if rising_edge(ext_clk_i) then
      if ext_rst_n_i = '0' then
        valid_trans_app_d0 <= '0';
        pl_stall_d0 <= '0';
      else
        valid_trans_app_d0 <= valid_trans_app;

        pl_stall_d0 <= pl_stall;
      end if;
    end if;
  end process;

  valid_trans_app <= '1' when fifo_fc_valid_i = '1' and pl_stall = '0' else '0';
  valid_trans_app_wdf <= '1' when fifo_fc_valid_i = '1' and pl_stall = '0' else '0';

  pl_stall <= pl_stall_app or pl_stall_app_wdf;
  pl_dreq <= pl_dreq_app and pl_dreq_app_wdf;

  -- DDR valid in signal
  p_ddr_valid_in : process(ext_clk_i)
  begin
    if rising_edge(ext_clk_i) then
      if ext_rst_n_i = '0' then
        ddr_valid_in <= '0';
      else
        -- We deassert ddr_valid_in in case it was already acknowledge by the
        -- fc-source module
        if ddr_valid_in = '1' and (pl_stall_d0 = '0' or pl_stall = '0') then
          ddr_valid_in <= '0';
        -- And we assert ddr_valid_in only when there was an overflow in the counter
        -- caused by a previous detection of a valid_trans (valid_trans_app_d0)
        --elsif ddr_addr_cnt_min_ovf_s(c_ddr_addr_ovf_bit) = '1' and valid_trans_app_d0 = '1' then
        elsif ddr_addr_cnt_min_ovf = c_max_addr_cnt and valid_trans_app = '1' then
          ddr_valid_in <= '1';
        end if;
      end if;
    end if;
  end process;

  p_ddr_data_reg : process(ext_clk_i)
  begin
    if rising_edge(ext_clk_i) then
      if ext_rst_n_i = '0' then
        ddr_data_in <= (others => '0');
        --ddr_data_valid_in <= '0';
      else
        ---- We deassert ddr_addr_valid_in in case it was already acknowledge by the
        ---- fc-source module
        --if ddr_data_valid_in = '1' and (pl_stall_addr_d0 = '0' or pl_stall = '0') then
        --  ddr_addr_valid_in <= '0';
        ---- And we assert ddr_data_valid_in only when there was an overflow in the counter
        ---- caused by a previous detection of a valid_trans (valid_trans_app_d0)
        --elsif ddr_addr_cnt_min_ovf_s(c_ddr_addr_ovf_bit) = '1' and valid_trans_app_d0 = '1' then
        --  ddr_data_valid_in <= '1';
        --  pl_stall_addr_d0 <= pl_stall;
        --end if;
        
        if valid_trans_app_wdf = '1' then
          --ddr_data_in <= f_gen_padded_word(g_ddr_payload_width,
          --                             g_data_width,
          --                             to_integer(ddr_addr_cnt_min),
          --                             fifo_fc_din_i,
          --                             f_gen_std_logic_vector(g_data_width, '0'));
          ddr_data_in((to_integer(ddr_addr_cnt_min)+1)*g_data_width-1 downto
                                to_integer(ddr_addr_cnt_min)*g_data_width) <= fifo_fc_din_i;
            
        end if;
      end if;
    end if;
  end process;

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
        -- get access to DDR3 from arbitrer. Maybe its better to
        -- hold the ddr_req signal until the end of the acquisition
        if valid_trans_app = '1'  and fifo_fc_sof_i = '1' then
          ddr_req <= '1';
        elsif cnt_all_trans_done_p = '1' then -- release access only when this
                                                -- acquisition is done
          ddr_req <= '0';
        end if;
      end if;
    end if;
  end process;

  ui_app_req_o <= ddr_req;

  -- To allow bit-by-bit operations
  ddr_addr_cnt_min_ovf_s <= std_logic_vector(ddr_addr_cnt_min_ovf);

  -- Generate address to external controller. Here we hold the external address
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
        ddr_addr_cnt_min_ovf <= to_unsigned(0, ddr_addr_cnt_min_ovf'length);
        ddr_addr_cnt <= to_unsigned(0, ddr_addr_cnt'length);
        --ddr_addr_valid_in <= '0';
      else
        ---- We deassert ddr_addr_valid_in in case it was already acknowledge by the
        ---- fc-source module
        --if ddr_addr_valid_in = '1' and (pl_stall_addr_d0 = '0' or pl_stall = '0') then
        --  ddr_addr_valid_in <= '0';
        ---- And we assert ddr_addr_valid_in only when there was an overflow in the counter
        ---- caused by a previous detection of a valid_trans (valid_trans_app_d0)
        --elsif ddr_addr_cnt_min_ovf_s(c_ddr_addr_ovf_bit) = '1' and valid_trans_app_d0 = '1' then
        --  ddr_addr_valid_in <= '1';
        --  pl_stall_addr_d0 <= pl_stall;
        --end if;

        if wr_start_i = '1' then
          -- This address must be word-aligned
          ddr_addr_cnt <= unsigned(wr_init_addr_alig);
          ddr_addr_cnt_min_ovf <= to_unsigned(0, ddr_addr_cnt_min_ovf'length);
          --ddr_addr_inc <= to_unsigned(0, ddr_addr_inc'length);
        elsif valid_trans_app = '1' then -- This represents a successful transfer

          if ddr_addr_cnt_min_ovf_s(c_ddr_addr_ovf_bit) = '1' then -- reset to 1
            ddr_addr_cnt_min_ovf <= to_unsigned(1, ddr_addr_cnt_min_ovf'length);
          else
            ddr_addr_cnt_min_ovf <= ddr_addr_cnt_min_ovf + 1;
          end if;

          -- overflow bit asserted
          if ddr_addr_cnt_min_ovf_s(c_ddr_addr_ovf_bit) = '1' then
            ddr_addr_cnt <= ddr_addr_cnt + c_addr_ddr_inc;
          end if;

        end if;
      end if;
    end if;
  end process;

  ddr_addr_cnt_min <= ddr_addr_cnt_min_ovf(ddr_addr_cnt_min'left downto 0);

  -- To Flow Control module
  ddr_addr_in <= std_logic_vector(ddr_addr_cnt);

  -----------------------------------------------------------------------------
  -- Counters
  -----------------------------------------------------------------------------

  cmp_acq_cnt : acq_cnt
  port map
  (
    -- DDR3 external clock
    clk_i                                     => ext_clk_i,
    rst_n_i                                   => acq_cnt_rst_n,

    cnt_all_pkts_ct_done_p_o                  => open,
    cnt_all_trans_done_p_o                    => cnt_all_trans_done_p,
    --cnt_en_i                                  => pl_pkt_sent,
    cnt_en_i                                  => pl_pkt_sent_app_wdf, -- could be pl_pkt_sent_app also?
    --cnt_rst_i                                 => lmt_rst_i,

    -- Size of the transaction in g_fifo_size bytes
    --lmt_pkt_size_i                            => lmt_pkt_size_i,
    lmt_pkt_size_i                            => lmt_pkt_size,
    -- Number of shots in this acquisition
    lmt_shots_nb_i                            => lmt_shots_nb,
    -- Acquisition limits valid signal. Qualifies lmt_pkt_size_i and lmt_shots_nb_i
    lmt_valid_i                               => lmt_valid
  );

  lmt_all_trans_done_p_o <= cnt_all_trans_done_p;

  acq_cnt_rst_n <= ext_rst_n_i and not(lmt_rst_i);

  p_ddr_mask_in : process(ext_clk_i)
  begin
    if rising_edge(ext_clk_i) then
      if ext_rst_n_i = '0' then
        ddr_mask_in <= (others => '0');
      else
        if valid_trans_app_wdf = '1' then
          --ddr_mask_in <= f_gen_mask(g_ddr_payload_width/8, 8,
          --                           to_integer(ddr_addr_cnt_min), '1');
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
    --g_hold_valid_on_stall                  => false,
    g_data_width                           => 1,
    g_pkt_size_width                       => c_pkt_size_width,
    g_addr_width                           => g_ddr_addr_width,
    g_pipe_size                            => c_pipe_size
  )
  port map (
    clk_i                                   => ext_clk_i,
    rst_n_i                                 => ext_rst_n_i,

    pl_data_i                               => (others => '0'),
    pl_addr_i                               => ddr_addr_in,
    --pl_valid_i                              => ddr_addr_valid_in, -- CHECK THIS!
    pl_valid_i                              => ddr_valid_in, -- CHECK THIS!

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
    --g_hold_valid_on_stall                  => false,
    g_data_width                           => g_ddr_payload_width + c_ddr_mask_width,
    g_pkt_size_width                       => c_pkt_size_width,
    g_addr_width                           => 1, -- Dummy value
    g_pipe_size                            => c_pipe_size
  )
  port map (
    clk_i                                   => ext_clk_i,
    rst_n_i                                 => ext_rst_n_i,

    pl_data_i                               => ddr_data_mask_in,
    --pl_addr_i                               => ddr_addr_in,
    pl_addr_i                               => (others => '0'),
    --pl_valid_i                              => ddr_data_valid_in, -- CHECK THIS!
    pl_valid_i                              => ddr_valid_in, -- CHECK THIS!

    pl_dreq_o                               => pl_dreq_app_wdf,
    pl_stall_o                              => pl_stall_app_wdf,
    pl_pkt_sent_o                           => pl_pkt_sent_app_wdf,

    pl_rst_trans_i                          => pl_rst_trans,

    lmt_pkt_size_i                          => lmt_pkt_size,
    lmt_valid_i                             => lmt_valid,

    fc_dout_o                               => fc_dout,
    fc_valid_o                              => fc_valid_app_wdf,
    --fc_addr_o                               => fc_addr,
    fc_addr_o                               => open,
    fc_sof_o                                => open,
    fc_eof_o                                => open,

    fc_stall_i                              => fc_stall_app_wdf,
    fc_dreq_i                               => fc_dreq_app_wdf
  );

  pl_rst_trans <= '0';

  --ddr_ui_rdy_t <= ui_app_rdy_i and ui_app_wdf_rdy_i;
  ddr_rdy_app <= ui_app_rdy_i;
  ddr_rdy_app_wdf <= ui_app_wdf_rdy_i;

  -- From next flow control module (DDR3 Controller)
  --fc_stall_ui_app <= not(ddr_ui_rdy_t);
  --fc_stall_app <= not(ddr_rdy_app);
  --fc_stall_app_wdf <= not(ddr_rdy_app_wdf);
  --fc_stall_app <= not(ddr_rdy_app and ui_app_gnt_i);
  --fc_stall_app_wdf <= not(ddr_rdy_app_wdf and ui_app_gnt_i);
  --fc_stall_app <= not(ddr_rdy_app and ddr_rdy_app_wdf);
  --fc_stall_app_wdf <= not(ddr_rdy_app and ddr_rdy_app_wdf);
  fc_stall_app <= not(ddr_rdy_app and ddr_rdy_app_wdf and ui_app_gnt_i);
  fc_stall_app_wdf <= not(ddr_rdy_app and ddr_rdy_app_wdf and ui_app_gnt_i);

  fc_dreq_app <= '1'; -- always request new data, even when the next module
                      -- in the pipeline cannot receive (ddr is not ready).
                      -- The flow control module will take care of this
  fc_dreq_app_wdf <= '1';

  -- Only request new data when the other interface is not stalled. This gives
  -- some flexibility to the interface to control its own flow, but constraints
  -- its output to the other one. This is necessary as unrelated flow from either
  -- the write or app interface causes the controller to drop some data.
  --
  -- DDR3 Controller datasheet tells something like 2 clock cycles distance from
  -- data word (wdf interface) and the corresponding command (app interface)
  --fc_dreq_app <= ddr_rdy_app_wdf;
  --fc_dreq_app <= ddr_rdy_app and ddr_rdy_app_wdf;

  --fc_dreq_app_wdf <= ddr_rdy_app;
  --fc_dreq_app_wdf <= ddr_rdy_app and ddr_rdy_app_wdf;

  -- To/From UI Xilinx Interface
  --
  -- We are using the simplest approach here! We expect DR3 Controller to be in
  -- BC4 Burst Mode, with "app_en", "wren" and "wdf_end" signals in the same cycle.
  -- Also, we only transmit when "app_rdy" and "wdf_rdy" are both high.
  ui_app_addr_o <= fc_addr;
  ui_app_cmd_o <= c_ui_cmd_write;
  --ui_app_en_o <= fc_valid_app;
  -- Note that we AND the output with "ddr_rdy_app_wdf" and not with ddr_rdy_app
  ui_app_en_o <= fc_valid_app and ddr_rdy_app_wdf; -- FIXME! BAD! Combinatorial outputs

  ui_app_wdf_data_o <= fc_dout(c_data_high downto c_data_low);
  ui_app_wdf_end_o <= fc_valid_app_wdf;
  ui_app_wdf_mask_o <= fc_dout(c_mask_high downto c_mask_low);
  --ui_app_wdf_wren_o <= fc_valid_app_wdf;
  -- Note that we AND the output with "ddr_rdy_app" and not with ddr_rdy_app_wdf
  ui_app_wdf_wren_o <= fc_valid_app_wdf and ddr_rdy_app; -- FIXME! BAD! Combinatorial outputs

end rtl;
