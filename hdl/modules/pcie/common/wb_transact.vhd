----------------------------------------------------------------------------------
-- Company:  Creotech
-- Engineer: abyszuk
--
-- Create Date:
-- Design Name:
-- Module Name:    wb_transact - Behavioral
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

library work;
use work.abb64Package.all;
use work.genram_pkg.all;

entity wb_transact is
  generic (
    C_ASYNFIFO_WIDTH : integer := 66
    );
  port (
    -- PCIE user clk
    user_clk : in std_logic;
    -- Write port
    wr_we   : in std_logic;
    wr_sof  : in std_logic;
    wr_eof  : in std_logic;
    wr_din  : in std_logic_vector(C_DBUS_WIDTH-1 downto 0);
    wr_full : out std_logic;
    -- Read command port
    rdc_sof  : in std_logic;
    rdc_v    : in std_logic;
    rdc_din  : in std_logic_vector(C_DBUS_WIDTH-1 downto 0);
    rdc_full : out std_logic;
    rd_tout  : in std_logic;
    -- Read data port
    rd_ren   : in std_logic;
    rd_empty : out std_logic;
    rd_dout  : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);

    -- Wishbone interface
    wb_clk : in std_logic;
    wb_rst : in std_logic;
    addr_o : out std_logic_vector(28 downto 0);
    dat_i  : in std_logic_vector(63 downto 0);
    dat_o  : out std_logic_vector(63 downto 0);
    we_o   : out std_logic;
    sel_o  : out std_logic_vector(0 downto 0);
    stb_o  : out std_logic;
    ack_i  : in std_logic;
    cyc_o  : out std_logic;

    --RESET from PCIe
    rst : in std_logic
    );
end entity wb_transact;


architecture Behavioral of wb_transact is

  type wb_states is (st_RESET,
                      st_IDLE,
                      st_LA,
                      st_WR_LOAD,
                      st_WR_SEND,
                      st_RD
                    );

  signal wb_state : wb_states := st_RESET;

  signal wpipe_din   : std_logic_vector(C_ASYNFIFO_WIDTH-1 downto 0) := (others => '0');
  signal wpipe_wen   : std_logic;
  signal wpipe_afull : std_logic;
  signal wpipe_full  : std_logic;
  signal wpipe_empty : std_logic;
  signal wpipe_qout  : std_logic_vector(C_ASYNFIFO_WIDTH-1 downto 0);
  signal wpipe_ren   : std_logic;
  signal wpipe_rd_en : std_logic;
  signal wpipe_valid : std_logic;
  signal wpipe_last  : std_logic;

  signal rpipec_din   : std_logic_vector(C_ASYNFIFO_WIDTH-1 downto 0) := (others => '0');
  signal rpipec_wen   : std_logic;
  signal rpipec_qout  : std_logic_vector(C_ASYNFIFO_WIDTH-1 downto 0);
  signal rpipec_valid : std_logic;
  signal rpipec_ren   : std_logic := '0';
  signal rpipec_empty : std_logic;
  signal rpipec_full  : std_logic;
  signal rpipec_afull : std_logic;

  signal rpiped_din   : std_logic_vector(63 downto 0) := (others => '0');
  signal rpiped_qout  : std_logic_vector(63 downto 0);
  signal rpiped_full  : std_logic;
  signal rpiped_we    : std_logic;
  signal rpiped_afull : std_logic;
  signal rpiped_empty : std_logic;

  signal wb_addr   : unsigned(addr_o'range);
  signal wb_rd_cnt : unsigned(C_TLP_FLD_WIDTH_OF_LENG-2 downto 0);
  signal wb_dat_o  : std_logic_vector(dat_o'range);
  signal wb_we     : std_logic;
  signal wb_sel    : std_logic_vector(sel_o'range);
  signal wb_stb    : std_logic;
  signal wb_cyc    : std_logic;

  signal rst_i      : std_logic;
  signal rst_rd_i   : std_logic;
  signal rst_n_i    : std_logic;
  signal rst_rd_n_i : std_logic;

begin

  rst_rd_i <= rst_i or rd_tout;
  rst_n_i <= not rst_i;
  rst_rd_n_i <= not rst_rd_i;
  
  process (wb_clk)
  begin
  -- sync reset signal
   if rising_edge(wb_clk) then
    rst_i <= wb_rst or rst;
   end if;
  end process;

  --Wishbone interface FSM
  WB_fsm :
  process (wb_clk)
  begin
    if rising_edge(wb_clk) then
      if rst_i = '1' then
        wb_state  <= st_RESET;
        wb_cyc    <= '0';
        wb_we     <= '0';
        wb_stb    <= '0';
        wb_sel    <= (others => '0');
        wpipe_ren <= '0';
        rpiped_we <= '0';
        rpipec_ren <= '0';
      else
        case wb_state is
          when st_RESET =>
            wb_state <= st_IDLE;

          when st_IDLE =>
            wb_stb    <= '0';
            wb_cyc    <= '0';
            wb_we     <= '0';
            wb_sel    <= (others => '0');
            rpiped_we <= '0';
            if wpipe_empty = '0' then
              wpipe_ren  <= '1';
              rpipec_ren <= '0';
              wb_state   <= st_LA;
            elsif rpipec_empty = '0' then
              wpipe_ren  <= '0';
              rpipec_ren <= '1';
              wb_state   <= st_LA;
            else
              wpipe_ren  <= '0';
              rpipec_ren <= '0';
              wb_state   <= st_IDLE;
            end if;

          when st_LA =>
            wb_stb    <= '0';
            wb_cyc    <= '0';
            wpipe_ren <= '0';
            if wpipe_valid = '1' then
              if wpipe_qout(C_DBUS_WIDTH) = '1' then --sof
                wb_addr  <= unsigned(wpipe_qout(wb_addr'left+3 downto 3));
                wb_state <= st_WR_LOAD;
              else
                wb_state <= st_IDLE;
              end if;
            elsif rpipec_valid = '1' then
              wb_addr    <= unsigned(rpipec_qout(wb_addr'left+3 downto 3));
              wb_rd_cnt  <= unsigned(rpipec_qout(C_TLP_FLD_WIDTH_OF_LENG+32+1 downto 32+3)); --omit lowest bit, QW counted
              rpipec_ren <= '0';
              wb_state   <= st_RD;
            else
              wb_state <= st_LA;
            end if;

          when st_RD =>
            wb_stb <= not(rpiped_afull);
            wb_cyc <= '1';
            wb_sel <= (others => '1');
            wb_we  <= '0';
            if rd_tout = '1' then
              wb_stb   <= '0';
              wb_cyc   <= '0';
              wb_state <= st_IDLE;
            elsif wb_stb = '1' and ack_i = '1' then
              rpiped_din <= dat_i;
              rpiped_we  <= '1';
              wb_addr    <= wb_addr + 1;
              wb_rd_cnt  <= wb_rd_cnt - 1;
              if wb_rd_cnt <= 1 then
                wb_stb   <= '0';
                wb_cyc   <= '0';
                wb_state <= st_IDLE;
              else
                wb_state <= st_RD;
              end if;
            else
              rpiped_din <= rpiped_din;
              rpiped_we  <= '0';
              wb_state   <= st_RD;
            end if;

          when st_WR_LOAD =>
            wb_cyc <= '1';
            wb_we  <= '1';
            wb_sel <= (others => '1');
            if wpipe_valid = '1' then
              wpipe_ren  <= '0';
              wpipe_last <= wpipe_qout(C_DBUS_WIDTH+1);
              wb_dat_o   <= wpipe_qout(wb_dat_o'range);
              wb_stb     <= '1';
              wb_state   <= st_WR_SEND;
            else
              wpipe_ren  <= '1';
              wpipe_last <= wpipe_last;
              wb_dat_o   <= wb_dat_o;
              wb_stb     <= '0';
              wb_state   <= st_WR_LOAD;
            end if;

          when st_WR_SEND =>
            wb_cyc <= '1';
            wb_we  <= '1';
            wb_sel <= (others => '1');
            if ack_i = '1' and wb_stb = '1' then
              wb_stb <= '0';
              if wpipe_last = '1' then
                wpipe_ren <= '0';
                wb_addr   <= wb_addr;
                wb_state  <= st_IDLE;
              else
                wpipe_ren <= '1';
                wb_addr   <= wb_addr + 1;
                wb_state  <= st_WR_LOAD;
              end if;
            else
              wb_stb    <= '1';
              wpipe_ren <= '0';
              wb_addr   <= wb_addr;
              wb_state  <= st_WR_SEND;
            end if;

        end case;
      end if;
    end if;
  end process;

  wr_full  <= wpipe_afull;
  rdc_full <= rpipec_afull;
  stb_o    <= wb_stb;
  addr_o   <= std_logic_vector(wb_addr);
  cyc_o    <= wb_cyc;
  dat_o    <= wb_dat_o;
  sel_o    <= wb_sel;
  we_o     <= wb_we;

  wpipe_syn :
  process (user_clk)
  begin
    if rising_edge(user_clk) then
      wpipe_din                          <= (others => '0');
      wpipe_din(C_DBUS_WIDTH-1 downto 0) <= wr_din;
      wpipe_din(C_DBUS_WIDTH)            <= wr_sof;
      wpipe_din(C_DBUS_WIDTH+1)          <= wr_eof;
      wpipe_wen                          <= wr_we;
    end if;
  end process;

  p_wpipe_valid :
  process (wb_clk)
  begin
    if rising_edge(wb_clk) then
      if wpipe_ren = '1' and wpipe_empty = '0' then
        wpipe_valid <= '1';
      else
        wpipe_valid <= '0';
      end if;
    end if;
  end process;
  -- we access one word at a time, so stall read if we got valid data
  wpipe_rd_en <= wpipe_ren and not(wpipe_valid);

  wpipe_fifo :
    generic_async_fifo
      generic map (
        g_data_width => C_ASYNFIFO_WIDTH,
        g_size => 128,
        g_show_ahead => false,
        g_with_rd_empty => true,
        g_with_rd_full => false,
        g_with_rd_almost_empty => false,
        g_with_rd_almost_full => false,
        g_with_rd_count => false,
        g_with_wr_empty => false,
        g_with_wr_full => true,
        g_with_wr_almost_empty => false,
        g_with_wr_almost_full => true,
        g_with_wr_count => false,
        g_almost_full_threshold => 120)
      port map(
        rst_n_i => rst_n_i,

        clk_wr_i          => user_clk,
        d_i               => wpipe_Din,
        we_i              => wpipe_wEn,
        wr_empty_o        => open,
        wr_full_o         => wpipe_Full,
        wr_almost_empty_o => open,
        wr_almost_full_o  => wpipe_aFull,
        wr_count_o        => open,

        clk_rd_i          => wb_clk,
        q_o               => wpipe_qout,
        rd_i              => wpipe_rd_en,
        rd_empty_o        => wpipe_empty,
        rd_full_o         => open,
        rd_almost_empty_o => open,
        rd_almost_full_o  => open,
        rd_count_o        => open);

  rpipe_syn :
  process (user_clk)
  begin
    if rising_edge(user_clk) then
      rpipec_din                          <= (others => '0');
      rpipec_din(C_DBUS_WIDTH-1 downto 0) <= rdc_din;
      rpipec_din(C_DBUS_WIDTH)            <= rdc_v;
      rpipec_din(C_DBUS_WIDTH+1)          <= rdc_sof;
    end if;
  end process;

  p_rpipec_valid :
  process (wb_clk)
  begin
    if rising_edge(wb_clk) then
      if rpipec_ren = '1' and rpipec_empty = '0' then
        rpipec_valid <= '1';
      else
        rpipec_valid <= '0';
      end if;
    end if;
  end process;

  rpipec_wen <= rpipec_din(C_DBUS_WIDTH);

  rpipec_fifo :
    generic_async_fifo
      generic map (
        g_data_width => C_ASYNFIFO_WIDTH,
        g_size => 32,
        g_show_ahead => false,
        g_with_rd_empty => true,
        g_with_rd_full => false,
        g_with_rd_almost_empty => false,
        g_with_rd_almost_full => false,
        g_with_rd_count => false,
        g_with_wr_empty => false,
        g_with_wr_full => true,
        g_with_wr_almost_empty => false,
        g_with_wr_almost_full => true,
        g_with_wr_count => false,
        g_almost_full_threshold => 28)
      port map(
        rst_n_i => rst_rd_n_i,

        clk_wr_i          => user_clk,
        d_i               => rpipec_din,
        we_i              => rpipec_wen,
        wr_empty_o        => open,
        wr_full_o         => rpipec_full,
        wr_almost_empty_o => open,
        wr_almost_full_o  => rpipec_afull,
        wr_count_o        => open,

        clk_rd_i          => wb_clk,
        q_o               => rpipec_qout,
        rd_i              => rpipec_ren,
        rd_empty_o        => rpipec_empty,
        rd_full_o         => open,
        rd_almost_empty_o => open,
        rd_almost_full_o  => open,
        rd_count_o        => open);

  rpiped_fifo :
    generic_async_fifo
      generic map (
        g_data_width => 64,
        g_size => 128,
        g_show_ahead => false,
        g_with_rd_empty => true,
        g_with_rd_full => false,
        g_with_rd_almost_empty => false,
        g_with_rd_almost_full => false,
        g_with_rd_count => false,
        g_with_wr_empty => false,
        g_with_wr_full => true,
        g_with_wr_almost_empty => false,
        g_with_wr_almost_full => true,
        g_with_wr_count => false,
        g_almost_full_threshold => 124)
      port map(
        rst_n_i => rst_rd_n_i,

        clk_wr_i          => wb_clk,
        d_i               => rpiped_din,
        we_i              => rpiped_we,
        wr_empty_o        => open,
        wr_full_o         => rpiped_full,
        wr_almost_empty_o => open,
        wr_almost_full_o  => rpiped_afull,
        wr_count_o        => open,

        clk_rd_i          => user_clk,
        q_o               => rpiped_qout,
        rd_i              => rd_ren,
        rd_empty_o        => rd_empty,
        rd_full_o         => open,
        rd_almost_empty_o => open,
        rd_almost_full_o  => open,
        rd_count_o        => open);

  rd_dout <= rpiped_qout;

end architecture Behavioral;
