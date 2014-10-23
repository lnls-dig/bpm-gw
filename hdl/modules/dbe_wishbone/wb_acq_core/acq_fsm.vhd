------------------------------------------------------------------------------
-- Title      : BPM FSM Data Acquisition
------------------------------------------------------------------------------
-- Author     : Lucas Maziero Russo
-- Company    : CNPEM LNLS-DIG
-- Created    : 2013-22-10
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: Module for the BPM FSM Data Acquisition. This module allow for
--               the following types of acquisition:
--               1) Simple acquisition on request
--               2) Pre-trigger acquisition
--               3) Post-trigger acquisition
--               4) Pre+Post-trigger acquisition
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
-- General common cores
use work.gencores_pkg.all;
-- Genrams cores
use work.genram_pkg.all;
-- Acquisition cores
use work.acq_core_pkg.all;

entity acq_fsm is
port
(
  fs_clk_i                                  : in std_logic;
  fs_ce_i                                   : in std_logic;
  fs_rst_n_i                                : in std_logic;

  -----------------------------
  -- FSM Commands (Inputs)
  -----------------------------
  acq_start_i                               : in  std_logic := '0';
  acq_now_i                                 : in  std_logic := '0';
  acq_stop_i                                : in  std_logic := '0';
  acq_trig_i                                : in  std_logic := '0';
  acq_dvalid_i                              : in  std_logic := '0';

  -----------------------------
  -- FSM Number of Samples
  -----------------------------
  pre_trig_samples_i                        : in unsigned(c_acq_samples_size-1 downto 0);
  post_trig_samples_i                       : in unsigned(c_acq_samples_size-1 downto 0);
  shots_nb_i                                : in unsigned(15 downto 0);
  samples_cnt_o                             : out unsigned(c_acq_samples_size-1 downto 0);

  -----------------------------
  -- FSM Monitoring
  -----------------------------
  acq_end_o                                 : out std_logic;
  acq_single_shot_o                         : out std_logic;
  acq_in_pre_trig_o                         : out std_logic;
  acq_in_wait_trig_o                        : out std_logic;
  acq_in_post_trig_o                        : out std_logic;
  acq_pre_trig_done_o                       : out std_logic;
  acq_wait_trig_skip_done_o                 : out std_logic;
  acq_post_trig_done_o                      : out std_logic;
  acq_fsm_state_o                           : out std_logic_vector(2 downto 0);

  -----------------------------
  -- FSM Outputs
  -----------------------------
  shots_decr_o                              : out std_logic;
  acq_trig_o                                : out std_logic;
  multishot_buffer_sel_o                    : out std_logic;
  samples_wr_en_o                           : out std_logic
);
end acq_fsm;

architecture rtl of acq_fsm is

  type t_acq_fsm_state is (IDLE, PRE_TRIG, WAIT_TRIG, WAIT_TRIG_SKIP, POST_TRIG,
                                 POST_TRIG_SKIP, DECR_SHOT);

  -- Acquisition FSM
  signal acq_fsm_state                      : std_logic_vector(2 downto 0);
  signal acq_start                          : std_logic;
  signal acq_stop                           : std_logic;
  signal acq_trig                           : std_logic;
  signal acq_end                            : std_logic;
  signal acq_end_t                          : std_logic;
  signal acq_in_pre_trig                    : std_logic;
  signal acq_in_wait_trig                   : std_logic;
  signal acq_in_post_trig                   : std_logic;
  signal samples_wr_en                      : std_logic;

  -- Pre/Post trigger and shots counters
  signal pre_trig_cnt                       : unsigned(c_acq_samples_size-1 downto 0);
  signal pre_trig_done                      : std_logic;
  signal wait_trig_skip_r                   : std_logic;
  signal wait_trig_skip_done                : std_logic;
  signal post_trig_cnt                      : unsigned(c_acq_samples_size-1 downto 0);
  signal post_trig_done                     : std_logic;
  signal samples_cnt                        : unsigned(c_acq_samples_size-1 downto 0);
  signal shots_cnt                          : unsigned(15 downto 0);
  signal shots_done                         : std_logic;
  signal shots_decr                         : std_logic;
  signal single_shot                        : std_logic;

begin

--------------------------------------------------------------------
  -- Shots counter
  --------------------------------------------------------------------
  p_shots_cnt : process (fs_clk_i)
  begin
    if rising_edge(fs_clk_i) then
      if fs_rst_n_i = '0' then
        shots_cnt   <= to_unsigned(0, shots_cnt'length);
        single_shot <= '0';
      else
        if acq_start_i = '1' then
          shots_cnt <= shots_nb_i;
        elsif shots_decr = '1' then
          shots_cnt <= shots_cnt - 1;
        end if;

        if shots_nb_i = to_unsigned(1, shots_nb_i'length) then
          single_shot <= '1';
        else
          single_shot <= '0';
        end if;
      end if;
    end if;
  end process;

  multishot_buffer_sel_o <= std_logic(shots_cnt(0));
  shots_done             <= '1' when shots_cnt = to_unsigned(1, shots_cnt'length) else '0';

  acq_single_shot_o <= single_shot;

  ------------------------------------------------------------------------------
  -- Pre-trigger counter
  ------------------------------------------------------------------------------

  p_pre_trig_cnt : process (fs_clk_i)
  begin
    if rising_edge(fs_clk_i) then
      if fs_rst_n_i = '0' then
        pre_trig_cnt <= to_unsigned(1, pre_trig_cnt'length);
      else
        if (acq_start_i = '1' or pre_trig_done = '1') then
          if pre_trig_samples_i = to_unsigned(0, pre_trig_samples_i'length) then
            pre_trig_cnt <= (others => '0');
          else
            pre_trig_cnt <= pre_trig_samples_i - 1;
          end if;
        elsif (acq_in_pre_trig = '1' and acq_dvalid_i = '1') then
          pre_trig_cnt <= pre_trig_cnt - 1;
        end if;
      end if;
    end if;
  end process;

  pre_trig_done <= '1' when (pre_trig_cnt = to_unsigned(0, pre_trig_cnt'length) and
                             acq_dvalid_i = '1' and acq_in_pre_trig = '1') else '0';
  acq_pre_trig_done_o <= pre_trig_done;

  ------------------------------------------------------------------------------
  -- Wait trigger event skip
  ------------------------------------------------------------------------------

  -- Check if we want to acquire data on trigger or not
  p_wait_trig_skip : process (fs_clk_i)
  begin
    if rising_edge(fs_clk_i) then
      if fs_rst_n_i = '0' then
        wait_trig_skip_r <= '0';
      else
        if (acq_start_i = '1') then
          wait_trig_skip_r <= acq_now_i;
        end if;
      end if;
    end if;
  end process;

  wait_trig_skip_done <= '1' when (wait_trig_skip_r = '1' and acq_in_wait_trig = '1') else '0';
  acq_wait_trig_skip_done_o <= wait_trig_skip_done;

  ------------------------------------------------------------------------------
  -- Post-trigger counter
  ------------------------------------------------------------------------------

  p_post_trig_cnt : process (fs_clk_i)
  begin
    if rising_edge(fs_clk_i) then
      if fs_rst_n_i = '0' then
        post_trig_cnt <= to_unsigned(1, post_trig_cnt'length);
      else
        if (acq_start = '1' or post_trig_done = '1') then
          if post_trig_samples_i = to_unsigned(0, post_trig_samples_i'length) then
            post_trig_cnt <= (others => '0');
          else
            post_trig_cnt <= post_trig_samples_i - 1;
          end if;
        elsif (acq_in_post_trig = '1' and acq_dvalid_i = '1') then
          post_trig_cnt <= post_trig_cnt - 1;
        end if;
      end if;
    end if;
  end process;

  post_trig_done <= '1' when (post_trig_cnt = to_unsigned(0, post_trig_cnt'length) and
                              (acq_dvalid_i = '1' or wait_trig_skip_r = '1') and acq_in_post_trig = '1') else '0';
  acq_post_trig_done_o <= post_trig_done;

  ------------------------------------------------------------------------------
  -- Samples counter
  ------------------------------------------------------------------------------

  p_samples_cnt : process (fs_clk_i)
  begin
    if rising_edge(fs_clk_i) then
      if fs_rst_n_i = '0' then
        samples_cnt <= (others => '0');
      else
        if (acq_start = '1') then
          samples_cnt <= (others => '0');
        elsif ((acq_in_pre_trig = '1' or acq_in_post_trig = '1') and acq_dvalid_i = '1') then
          samples_cnt <= samples_cnt + 1;
        end if;
      end if;
    end if;
  end process;

  samples_cnt_o <= samples_cnt;

  ------------------------------------------------------------------------------
  -- Aqcuisition FSM
  ------------------------------------------------------------------------------

  -- End of acquisition pulse generation
  p_acq_end : process (fs_clk_i)
  begin
    if rising_edge(fs_clk_i) then
      if fs_rst_n_i = '0' then
        acq_end <= '0';
      else
        if acq_start_i = '1' then
          acq_end <= '0';
        elsif acq_end_t = '1' then
          acq_end <= '1';
        end if;
      end if;
    end if;
  end process;

  acq_end_o <= acq_end;

  -- FSM commands
  acq_start <= acq_start_i;
  acq_stop  <= acq_stop_i;
  acq_trig  <= acq_dvalid_i and acq_trig_i and acq_in_wait_trig;
  acq_end_t   <= shots_done and post_trig_done;

  -- FSM transitions + outputs
  p_acq_fsm : process(fs_clk_i)
    variable acq_fsm_current_state : t_acq_fsm_state;
  begin
    if rising_edge(fs_clk_i) then
      if fs_rst_n_i = '0' then
        acq_fsm_current_state := IDLE;

        -- Outputs
        shots_decr       <= '0';
        acq_in_pre_trig  <= '0';
        acq_in_wait_trig <= '0';
        acq_in_post_trig <= '0';
        samples_wr_en    <= '0';
        acq_fsm_state    <= "001";
      else

        -- FSM transitions
        case acq_fsm_current_state is

          when IDLE =>
            if acq_start = '1' then
              acq_fsm_current_state := PRE_TRIG;
            end if;

          when PRE_TRIG =>
            if acq_stop = '1' then
              acq_fsm_current_state := IDLE;
            elsif pre_trig_done = '1' then
                acq_fsm_current_state := WAIT_TRIG;

                -- Hack to avoid writing samples in wait_trig_skip mode. FIXME!
                if wait_trig_skip_r = '1' then
                  acq_fsm_current_state := WAIT_TRIG_SKIP;
                end if;

            end if;

          -- Dummy state to skip writing samples in wait_trig_skip mode
          when WAIT_TRIG_SKIP =>
            if acq_stop = '1' then
              acq_fsm_current_state := IDLE;
            else
              acq_fsm_current_state := POST_TRIG_SKIP;
            end if;

          when WAIT_TRIG =>
            if acq_stop = '1' then
              acq_fsm_current_state := IDLE;
            elsif acq_trig = '1' then
              acq_fsm_current_state := POST_TRIG;
            end if;

          -- Dummy state to skip writing samples in wait_trig_skip mode
          when POST_TRIG_SKIP =>
            if acq_stop = '1' then
              acq_fsm_current_state := IDLE;
            elsif post_trig_done = '1' then

              if single_shot = '1' then
                acq_fsm_current_state := IDLE;
              else
                acq_fsm_current_state := DECR_SHOT;
              end if;

            end if;

          when POST_TRIG =>
            if acq_stop = '1' then
              acq_fsm_current_state := IDLE;
            elsif post_trig_done = '1' then

              if single_shot = '1' then
                acq_fsm_current_state := IDLE;
              else
                acq_fsm_current_state := DECR_SHOT;
              end if;

            end if;

          when DECR_SHOT =>
            if acq_stop = '1' then
              acq_fsm_current_state := IDLE;
            else

              if shots_done = '1' then
                acq_fsm_current_state := IDLE;
              else
                acq_fsm_current_state := PRE_TRIG;

              end if;
            end if;

          when others =>
            acq_fsm_current_state := IDLE;

        end case;

        -- FSM outputs
        case acq_fsm_current_state is

          when IDLE =>
            shots_decr       <= '0';
            acq_in_pre_trig  <= '0';
            acq_in_wait_trig <= '0';
            acq_in_post_trig <= '0';
            samples_wr_en    <= '0';
            acq_fsm_state    <= "001";

          when PRE_TRIG =>
            shots_decr       <= '0';
            acq_in_pre_trig  <= '1';
            acq_in_wait_trig <= '0';
            acq_in_post_trig <= '0';
            samples_wr_en    <= '1';
            acq_fsm_state    <= "010";

          when WAIT_TRIG_SKIP =>
            shots_decr       <= '0';
            acq_in_pre_trig  <= '0';
            acq_in_wait_trig <= '1'; -- Other logic will detect the same state
            acq_in_post_trig <= '0';
            samples_wr_en    <= '0'; -- Don't write samples when in wait_skip_trig mode
            acq_fsm_state    <= "011"; -- Other logic will detect the same state

          -- As we don't know when the trigger will come, we enable write
          -- (samples_wr_en) in this state and keep acquiring, until the
          -- trigger arrives.
          --
          -- On writting to the FIFO flow control we then get only the "true"
          -- pre-trigger samples stored on the DPRAMs
          when WAIT_TRIG =>
            shots_decr       <= '0';
            acq_in_pre_trig  <= '0';
            acq_in_wait_trig <= '1';
            acq_in_post_trig <= '0';
            samples_wr_en    <= '1';
            acq_fsm_state    <= "011";

          when POST_TRIG_SKIP =>
            shots_decr       <= '0';
            acq_in_pre_trig  <= '0';
            acq_in_wait_trig <= '0'; -- Other logic will detect the same state
            acq_in_post_trig <= '1';
            samples_wr_en    <= '0'; -- Don't write samples when in wait_skip_trig mode
            acq_fsm_state    <= "100"; -- Other logic will detect the same state

          when POST_TRIG =>
            shots_decr       <= '0';
            acq_in_pre_trig  <= '0';
            acq_in_wait_trig <= '0';
            acq_in_post_trig <= '1';
            samples_wr_en    <= '1';
            acq_fsm_state    <= "100";

          when DECR_SHOT =>
            shots_decr       <= '1';
            acq_in_pre_trig  <= '0';
            acq_in_wait_trig <= '0';
            acq_in_post_trig <= '0';
            samples_wr_en    <= '0';
            acq_fsm_state    <= "101";

          when others =>
            shots_decr       <= '0';
            acq_in_pre_trig  <= '0';
            acq_in_wait_trig <= '0';
            acq_in_post_trig <= '0';
            samples_wr_en    <= '0';
            acq_fsm_state    <= "111";

        end case;

      end if;
    end if;
  end process;

  shots_decr_o       <= shots_decr;
  acq_trig_o         <= acq_trig;
  acq_in_pre_trig_o  <= acq_in_pre_trig;
  acq_in_wait_trig_o <= acq_in_wait_trig;
  acq_in_post_trig_o <= acq_in_post_trig;
  samples_wr_en_o    <= samples_wr_en;
  acq_fsm_state_o    <= acq_fsm_state;

end rtl;
