------------------------------------------------------------------------------
-- Title      : BPM Acquisition data checker
------------------------------------------------------------------------------
-- Author     : Lucas Maziero Russo
-- Company    : CNPEM LNLS-DIG
-- Created    : 2013-06-11
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: Module for simple comparison between two flows of data.
--                One of them is the expected data and the ther is the
--                actual data to be compared
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
use std.textio.all;

library work;
-- Main Wishbone Definitions
use work.wishbone_pkg.all;
-- Genrams cores
use work.genram_pkg.all;
-- Genrams cores
use work.gencores_pkg.all;
use work.acq_core_pkg.all;

entity data_checker is
generic
(
  g_data_width                              : natural := 64;
  g_addr_width                              : natural := 32;
  g_addr_inc                                : natural := 8;
  g_fifo_size                               : natural := 64
);
port
(
  -- DDR3 external clock
  ext_clk_i                                 : in  std_logic;
  ext_rst_n_i                               : in  std_logic;

  -- Expected data
  exp_din_i                                 : in std_logic_vector(g_data_width-1 downto 0);
  exp_valid_i                               : in std_logic;
  exp_addr_i                                : in std_logic_vector(g_addr_width-1 downto 0);

  -- Actual data
  act_din_i                                 : in std_logic_vector(g_data_width-1 downto 0);
  act_valid_i                               : in std_logic;
  act_addr_i                                : in std_logic_vector(g_addr_width-1 downto 0);

  -- Size of the transaction in g_fifo_size bytes
  lmt_pkt_size_i                            : in unsigned(c_pkt_size_width-1 downto 0);
  --lmt_pkt_size_i                            : in std_logic_vector(c_pkt_size_width-1 downto 0);
  -- Number of shots in this acquisition
  lmt_shots_nb_i                            : in unsigned(c_shots_size_width-1 downto 0);
  -- Acquisition limits valid signal. Qualifies lmt_pkt_size_i and lmt_shots_nb_i
  lmt_valid_i                               : in std_logic;

  chk_data_err_o                            : out std_logic;
  chk_addr_err_o                            : out std_logic;
  chk_data_err_cnt_o                        : out unsigned(15 downto 0);
  chk_addr_err_cnt_o                        : out unsigned(15 downto 0);
  chk_end_o                                 : out std_logic;
  chk_pass_o                                : out std_logic
);
end data_checker;

architecture rtl of data_checker is

  type t_data_checker_fsm_state is (IDLE, READ_FIFO, WAIT_VALID_FIFO,
                                    CHECK_ADDR_EQUAL, ALIGN_ADDR, CMP_DATA_ADDR,
                                    FINISH);

  -- Data Checker FSM
  signal data_checker_fsm_state             : t_data_checker_fsm_state;

  -- Constants
  constant c_addr_lsb                       : natural := 0;
  constant c_addr_msb                       : natural := g_addr_width + c_addr_lsb - 1;
  constant c_data_lsb                       : natural := c_addr_msb + 1;
  constant c_data_msb                       : natural := g_data_width + c_data_lsb - 1;
  constant c_addr_inc                       : unsigned(g_addr_width-1 downto 0) :=
                                                to_unsigned(g_addr_inc, g_addr_width);

  signal fifo_exp_din                       : std_logic_vector(g_data_width+g_addr_width-1 downto 0);
  signal fifo_exp_we                        : std_logic;
  signal fifo_exp_dout                      : std_logic_vector(g_data_width+g_addr_width-1 downto 0);
  signal fifo_exp_rd                        : std_logic;
  signal fifo_exp_empty                     : std_logic;
  signal fifo_exp_full                      : std_logic;
  signal fifo_exp_valid                     : std_logic;

  signal fifo_act_din                       : std_logic_vector(g_data_width+g_addr_width-1 downto 0);
  signal fifo_act_we                        : std_logic;
  signal fifo_act_dout                      : std_logic_vector(g_data_width+g_addr_width-1 downto 0);
  signal fifo_act_rd                        : std_logic;
  signal fifo_act_empty                     : std_logic;
  signal fifo_act_full                      : std_logic;
  signal fifo_act_valid                     : std_logic;

  signal data_cmp_valid                     : std_logic;

  signal lmt_pkt_size                       : unsigned(c_pkt_size_width-1 downto 0);
  signal lmt_shots_nb                       : unsigned(c_shots_size_width-1 downto 0);
  signal lmt_valid                          : std_logic;

  signal data_chk_en                        : std_logic;
  signal data_chk_done_p                    : std_logic;
  signal data_chk_done_l                    : std_logic;
  signal data_cmp_match                     : std_logic;
  signal data_cmp_err                       : std_logic;
  signal data_cmp_err_r                     : std_logic;
  signal data_cmp_err_cnt                   : unsigned(15 downto 0);
  signal addr_cmp_err                       : std_logic;
  signal addr_cmp_err_r                     : std_logic;
  signal addr_cmp_err_cnt                   : unsigned(15 downto 0);

  signal chk_pass_p                         : std_logic;
  signal chk_pass_l                         : std_logic;

begin

  -----------------------------------------------------------------------------
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
          lmt_pkt_size <= lmt_pkt_size_i;
          lmt_shots_nb <= lmt_shots_nb_i;
        end if;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- FIFO for storing expected data
  -----------------------------------------------------------------------------

  fifo_exp_din <= exp_din_i & exp_addr_i;
  fifo_exp_we <= exp_valid_i and not(fifo_exp_full);

  cmp_exp_data_fifo : generic_sync_fifo
  generic map (
    g_data_width                            => g_data_width + g_addr_width,
    g_size                                  => g_fifo_size,
    g_almost_empty_threshold                => 0,
    g_almost_full_threshold                 => 0
  )
  port map(
    rst_n_i                                 => ext_rst_n_i,
    clk_i                                   => ext_clk_i,

    d_i                                     => fifo_exp_din,
    we_i                                    => fifo_exp_we,

    q_o                                     => fifo_exp_dout,
    rd_i                                    => fifo_exp_rd,

    empty_o                                 => fifo_exp_empty,
    full_o                                  => fifo_exp_full
  );

  fifo_exp_rd <= '1' when (fifo_exp_empty = '0' and fifo_act_empty = '0' and
                           data_checker_fsm_state = CMP_DATA_ADDR) or
                           -- Dummy state to read a single value from FIFO
                           data_checker_fsm_state = READ_FIFO or
                           -- keep reading FIFO until we align addresses with
                           -- the "actual" FIFO
                           data_checker_fsm_state = ALIGN_ADDR
                           else '0';

  -- Valid flag
  p_exp_valid : process (ext_clk_i) is
  begin
    if rising_edge(ext_clk_i) then
      fifo_exp_valid <= fifo_exp_rd;

      if (fifo_exp_empty = '1') then
        fifo_exp_valid <= '0';
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- FIFO for storing actual data
  -----------------------------------------------------------------------------

  fifo_act_din <= act_din_i & act_addr_i;
  fifo_act_we <= act_valid_i and not(fifo_act_full);

  cmp_act_data_fifo : generic_sync_fifo
  generic map (
    g_data_width                            => g_data_width + g_addr_width,
    g_size                                  => g_fifo_size,
    g_almost_empty_threshold                => 0,
    g_almost_full_threshold                 => 0
  )
  port map(
    rst_n_i                                 => ext_rst_n_i,
    clk_i                                   => ext_clk_i,

    d_i                                     => fifo_act_din,
    we_i                                    => fifo_act_we,

    q_o                                     => fifo_act_dout,
    rd_i                                    => fifo_act_rd,

    empty_o                                 => fifo_act_empty,
    full_o                                  => fifo_act_full
  );

  fifo_act_rd <= '1' when (fifo_act_empty = '0' and fifo_exp_empty = '0' and
                           -- Compare Data/Addr state
                           data_checker_fsm_state = CMP_DATA_ADDR) or
                           -- Dummy state to read a single value from FIFO
                           data_checker_fsm_state = READ_FIFO
                           else '0';
  -- Valid flag
  p_act_valid : process (ext_clk_i) is
  begin
    if rising_edge(ext_clk_i) then
      fifo_act_valid <= fifo_act_rd;

      if (fifo_act_empty = '1') then
        fifo_act_valid <= '0';
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Compare actual data with expected data
  -----------------------------------------------------------------------------

  data_cmp_valid <= fifo_act_valid and fifo_exp_valid;

  p_compare_exp_act : process (ext_clk_i) is
    variable s : line;
  begin
    if rising_edge(ext_clk_i) then
      if ext_rst_n_i = '0' then
        data_cmp_match <= '0';
        data_cmp_err <= '0';
        addr_cmp_err <= '0';
        data_checker_fsm_state <= IDLE;
      else

        case data_checker_fsm_state is

          when IDLE =>
            if (fifo_act_we = '1') then
              data_checker_fsm_state <= READ_FIFO;
            else
              data_cmp_match <= '0';
              data_cmp_err <= '0';
              addr_cmp_err <= '0';
            end if;

          -- Read one single WORD from FIFO
          when READ_FIFO =>
            data_checker_fsm_state <= WAIT_VALID_FIFO;

          -- Wait for FIFO output to become valid
          when WAIT_VALID_FIFO =>
            data_checker_fsm_state <= CHECK_ADDR_EQUAL;

          when CHECK_ADDR_EQUAL =>
            -- Check if data is equal already (in the case we did not wait for
            -- a trigger and both addresses are 0, for instance)
            if unsigned(fifo_exp_dout(c_addr_msb downto c_addr_lsb)) =
               unsigned(fifo_act_dout(c_addr_msb downto c_addr_lsb)) then
              data_checker_fsm_state <= CMP_DATA_ADDR;
            else
              data_checker_fsm_state <= ALIGN_ADDR;
            end if;

          -- Keep reading from the "expected" FIFO until we align its address with
          -- the address coming from the "actual" FIFO
          when ALIGN_ADDR =>
            if unsigned(fifo_exp_dout(c_addr_msb downto c_addr_lsb)) >=
               unsigned(fifo_act_dout(c_addr_msb downto c_addr_lsb)) - c_addr_inc then
              data_checker_fsm_state <= CMP_DATA_ADDR;
            end if;

          when CMP_DATA_ADDR =>
            -- We are comparing data/addr now

            if data_chk_done_p = '1' then
              data_checker_fsm_state <= FINISH;
            elsif data_cmp_valid = '1' then -- comparison is ready to be made
              if (fifo_act_dout = fifo_exp_dout) then -- both data and address match!
                data_cmp_match <= '1'; -- continue
                data_cmp_err <= '0';
                addr_cmp_err <= '0';

                report "[Data Checker]: actual data/addr " &
                 integer'image(to_integer(unsigned(fifo_act_dout(c_data_msb downto c_data_lsb)))) &
                 "/" &
                 integer'image(to_integer(unsigned(fifo_act_dout(c_addr_msb downto c_addr_lsb)))) &
                 " MATCHES expected data/addr " &
                 integer'image(to_integer(unsigned(fifo_exp_dout(c_data_msb downto c_data_lsb)))) &
                 "/" &
                 integer'image(to_integer(unsigned(fifo_exp_dout(c_addr_msb downto c_addr_lsb))))
                 severity note;
              elsif (fifo_act_dout(c_data_msb downto c_data_lsb) =
                       fifo_exp_dout(c_data_msb downto c_data_lsb)) then -- only data match!
                data_cmp_match <= '1'; -- continue
                data_cmp_err <= '0';
                addr_cmp_err <= '1';

                report "[Data Checker]: actual data/addr " &
                 integer'image(to_integer(unsigned(fifo_act_dout(c_data_msb downto c_data_lsb)))) &
                 "/" &
                 integer'image(to_integer(unsigned(fifo_act_dout(c_addr_msb downto c_addr_lsb)))) &
                 " DIFFERS from expected data/addr " &
                 integer'image(to_integer(unsigned(fifo_exp_dout(c_data_msb downto c_data_lsb)))) &
                 "/" &
                 integer'image(to_integer(unsigned(fifo_exp_dout(c_addr_msb downto c_addr_lsb))))
                 severity note;
              else -- only addr or neither match
                data_cmp_match <= '0'; -- stop on error
                data_cmp_err <= '1';
                addr_cmp_err <= '1';

                report "[Data Checker]: actual data/addr " &
                 integer'image(to_integer(unsigned(fifo_act_dout(c_data_msb downto c_data_lsb)))) &
                 "/" &
                 integer'image(to_integer(unsigned(fifo_act_dout(c_addr_msb downto c_addr_lsb)))) &
                 " DIFFERS from expected data/addr " &
                 integer'image(to_integer(unsigned(fifo_exp_dout(c_data_msb downto c_data_lsb)))) &
                 "/" &
                 integer'image(to_integer(unsigned(fifo_exp_dout(c_addr_msb downto c_addr_lsb))))
                 severity error;
              end if;
            end if;

          when FINISH =>
            -- Trap FSM here until a reset comes

          when others =>
            report "[Data Checker]: Invalid State Detected!"
             severity error;
            null;

          end case;
       end if;
    end if;
  end process;

  data_chk_en <= data_cmp_valid;

  -----------------------------------------------------------------------------
  -- Count the errors
  -----------------------------------------------------------------------------
  p_err_cnt : process (ext_clk_i)
  begin
    if rising_edge(ext_clk_i) then
      if ext_rst_n_i = '0' then
        data_cmp_err_cnt <= to_unsigned(0, data_cmp_err_cnt'length);
        addr_cmp_err_cnt <= to_unsigned(0, addr_cmp_err_cnt'length);
      else
        if data_cmp_err = '1' then
          data_cmp_err_cnt <= data_cmp_err_cnt + 1;
        end if;

        if addr_cmp_err = '1' then
          addr_cmp_err_cnt <= addr_cmp_err_cnt + 1;
        end if;
      end if;
    end if;
  end process;

  chk_data_err_cnt_o <= data_cmp_err_cnt;
  chk_addr_err_cnt_o <= addr_cmp_err_cnt;

  p_err_reg : process (ext_clk_i)
  begin
    if rising_edge(ext_clk_i) then
      if ext_rst_n_i = '0' then
        data_cmp_err_r <= '0';
        addr_cmp_err_r <= '0';
      else
        if data_cmp_err = '1' then
          data_cmp_err_r <= '1';
        end if;

        if addr_cmp_err = '1' then
          addr_cmp_err_r <= '1';
        end if;
      end if;
    end if;
  end process;

  chk_data_err_o <= data_cmp_err_r;
  chk_addr_err_o <= addr_cmp_err_r;

  -----------------------------------------------------------------------------
  -- Number of comparison to be made
  -----------------------------------------------------------------------------

  cmp_acq_cnt_req : acq_cnt
  port map
  (
    -- DDR3 external clock
    clk_i                                     => ext_clk_i,
    rst_n_i                                   => ext_rst_n_i,

    cnt_all_pkts_ct_done_p_o                  => open,
    cnt_all_trans_done_p_o                    => data_chk_done_p,
    cnt_en_i                                  => data_chk_en,

    lmt_pkt_size_i                            => lmt_pkt_size,
    lmt_shots_nb_i                            => lmt_shots_nb,
    lmt_valid_i                               => lmt_valid
  );

  -- Convert from pulse to level signal
  p_data_chk_done_l : process (ext_clk_i)
  begin
    if rising_edge(ext_clk_i) then
      if ext_rst_n_i = '0' then
        data_chk_done_l <= '0';
      else
        if data_chk_done_p = '1' then
          data_chk_done_l <= '1';
        end if;
      end if;
    end if;
  end process;

  chk_end_o <= data_chk_done_l;

  -----------------------------------------------------------------------------
  -- Check if the test passed or not
  -----------------------------------------------------------------------------

  p_data_chk_pass : process (ext_clk_i)
  begin
    if rising_edge(ext_clk_i) then
      if ext_rst_n_i = '0' then
        chk_pass_p <= '0';
      else
        if data_chk_done_p = '1' then
          if data_cmp_err_r = '1' or addr_cmp_err_r = '1' then -- if any error
            chk_pass_p <= '0';
          else
            chk_pass_p <= '1';
          end if;
        end if;
      end if;
    end if;
  end process;

  -- Convert from pulse to level signal
  p_data_chk_pass_l : process (ext_clk_i)
  begin
    if rising_edge(ext_clk_i) then
      if ext_rst_n_i = '0' then
        chk_pass_l <= '0';
      else
        if chk_pass_p = '1' then
          chk_pass_l <= '1';
        end if;
      end if;
    end if;
  end process;

  chk_pass_o <= chk_pass_l;

end rtl;
