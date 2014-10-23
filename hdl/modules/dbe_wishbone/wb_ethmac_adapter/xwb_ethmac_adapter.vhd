-------------------------------------------------------------------------------
-- White Rabbit Switch / GSI BEL
-------------------------------------------------------------------------------
--
-- unit name: Parallel-In/Serial-Out shift register
--
-- author: Mathias Kreider, m.kreider@gsi.de
--
-- date: $Date:: $:
--
-- version: $Rev:: $:
--
-- description: <file content, behaviour, purpose, special usage notes...>
-- <further description>
--
-- dependencies: <entity name>, ...
--
-- references: <reference one>
-- <reference two> ...
--
-- modified by: $Author:: $:
--
-------------------------------------------------------------------------------
-- last changes: <date> <initials> <log>
-- <extended description>
-------------------------------------------------------------------------------
-- TODO: <next thing to do>
-- <another thing to do>
--
-- This code is subject to GPL
-------------------------------------------------------------------------------
-- Modified by Lucas Russo <lucas.russo@lnls.br>.
-- Simple convertion of regular pipelined wishbone to wishbone streaming
-- fabric used by etherbone (32-bit to 16-bit data).

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.wishbone_pkg.all;
use work.wr_fabric_pkg.all;
use work.eb_internals_pkg.all;

entity xwb_ethmac_adapter is
port(
  clk_i                                     : in std_logic;
  rstn_i                                    : in std_logic;

  wb_slave_o                                : out t_wishbone_slave_out;
  wb_slave_i                                : in t_wishbone_slave_in;

  tx_ram_o                                  : out t_wishbone_master_out;
  tx_ram_i                                  : in t_wishbone_master_in;

  rx_ram_o                                  : out t_wishbone_master_out;
  rx_ram_i                                  : in t_wishbone_master_in;

  --rx_eb_o                                   : out t_wishbone_master_out;
  --rx_eb_i                                   : in t_wishbone_master_in;
  --
  --tx_eb_i                                   : in t_wishbone_slave_in;
  --tx_eb_o                                   : out t_wishbone_slave_out;

  rx_eb_o                                   : out t_wrf_source_out;
  rx_eb_i                                   : in t_wrf_source_in;

  tx_eb_o                                   : out t_wrf_sink_out;
  tx_eb_i                                   : in t_wrf_sink_in;

  irq_tx_done_o                             : out std_logic;
  irq_rx_done_o                             : out std_logic
);
end xwb_ethmac_adapter;

architecture behavioral of xwb_ethmac_adapter is

  --function f_ceil_log2(x : natural) return natural is
  --begin
  --  if x <= 2
  --    then return 1;
  --  else
  --    return f_ceil_log2((x+1)/2) +1;
  --  end if;
  --end f_ceil_log2;

  --constant c_ram_width                        : natural := 32;
  --constant c_wrf_width                        : natural := 16;
  --constant c_counter_full                     : natural := c_ram_width/c_wrf_width;
  --constant c_counter_msb                      : natural := f_ceil_log2(c_ram_width/c_wrf_width);

  -- Wishbone Interface
  signal ctrl                                 : std_logic_vector(31 downto 0);  --x00
  alias buffers_rdy                           : std_logic is ctrl(0);

  signal base_adr_rx                          : std_logic_vector(31 downto 0);  --x04
  signal base_adr_tx                          : std_logic_vector(31 downto 0);  --x08
  signal length_rx                            : std_logic_vector(31 downto 0);  --c
  signal bytes_rx                             : std_logic_vector(31 downto 0);  --c
  signal bytes_tx                             : std_logic_vector(31 downto 0);  --c
  signal rx_done                              : std_logic;

  signal eb_stall                             : std_logic;

  signal wb_adr                               : std_logic_vector(31 downto 0);
  alias adr                                   : std_logic_vector(7 downto 0) is wb_adr(7 downto 0);

  -- Dma Controller
  signal irq_tx_done                          : std_logic;
  signal irq_rx_done                          : std_logic;

  type fsm is (idle, init, transfer, waiting, done);

  signal state_tx                             : fsm;
  signal state_rx                             : fsm;
  signal rx_counter                           : unsigned(15 downto 0);
  signal tx_counter                           : unsigned(31 downto 0);

  -- Internal Streaming interface
  --signal rx_eb32_i                            : t_wrf_source32_in;
  --signal rx_eb32_o                            : t_wrf_source32_out;
  signal rx_eb32_i                            : t_wishbone_master_in;
  signal rx_eb32_o                            : t_wishbone_master_out;

  signal rx_eb16_i                            : t_wishbone_master_in;
  signal rx_eb16_o                            : t_wishbone_master_out;

  --signal tx_eb32_i                            : t_wrf_sink32_in;
  --signal tx_eb32_o                            : t_wrf_sink32_out;
  signal tx_eb32_i                            : t_wishbone_slave_in;
  signal tx_eb32_o                            : t_wishbone_slave_out;

  signal tx_eb16_i                            : t_wishbone_slave_in;
  signal tx_eb16_o                            : t_wishbone_slave_out;

  -- word counter
  --signal transfer_counter                     : unsigned(c_ram_width/c_wrf_width-1 downto 0);
  --signal transfer_in_progress                 : std_logic;

  signal rx_ram_dat_reg                       : std_logic_vector(31 downto 0);

begin

  wb_adr <= wb_slave_i.adr;

  wishbone_if : process (clk_i)
  begin
    if (clk_i'event and clk_i = '1') then
      if(rstn_i = '0') then
        ctrl <= (others => '0');
        base_adr_tx <= (others => '0');
        base_adr_rx <= (others => '0');
        length_rx <= (others => '0');
        --length_tx <= (others => '0');

        wb_slave_o  <=   (
                          ack   => '0',
                          err   => '0',
                          rty   => '0',
                          stall => '0',
                          int => '0',
                          dat   => (others => '0'));
      else
        wb_slave_o.ack <= wb_slave_i.cyc and wb_slave_i.stb;
        wb_slave_o.dat <= (others => '0');
        ctrl <= (others => '0');

        if(wb_slave_i.we ='1') then
          case adr  is
            when x"00" => ctrl    <= wb_slave_i.dat and x"00000001";
            when x"04" => base_adr_tx <= wb_slave_i.dat;
            when x"08" => base_adr_rx <= wb_slave_i.dat;
            when x"0C" => length_rx <= wb_slave_i.dat;
            when others => null;
          end case;
        else
          -- set output to zero so all bits are driven
          case adr  is
            --when x"00" => ctrl    <= wb_slave_i.dat and x"00000003";
            when x"04" => wb_slave_o.dat <= base_adr_tx;
            when x"08" => wb_slave_o.dat <= base_adr_rx;
            when x"0C" => wb_slave_o.dat <= length_rx;
            when x"10" => wb_slave_o.dat <= bytes_rx;
            when x"14" => wb_slave_o.dat <= bytes_tx;
            when others => null;
          end case;
        end if;
      end if;
    end if;
  end process;

  ------------------------------------------

  tx_eb32_o.stall <= tx_ram_i.stall;
  tx_eb32_o.ack <= tx_ram_i.ack;

  tx_ram_o.cyc <= tx_eb32_i.cyc;
  tx_ram_o.stb <= tx_eb32_i.stb;
  tx_ram_o.dat <= tx_eb32_i.dat;
  tx_ram_o.adr <= std_logic_vector(tx_counter);
  tx_ram_o.we <= '1';
  tx_ram_o.sel <= (others => '1');

  irq_tx_done_o <= irq_tx_done;

  bytes_tx <= std_logic_vector(tx_counter);

  -- convert streaming output from 16 to 32 bit data width
  cmp_tx_adapter_16_to_32: eb_stream_widen
  generic map (
    g_slave_width                           => 16,
    g_master_width                          => 32
  )
  port map (
    clk_i                                   => clk_i,
    rst_n_i                                 => rstn_i,
    slave_i                                 => tx_eb16_i,
    slave_o                                 => tx_eb16_o,
    master_i                                => tx_eb32_o,
    master_o                                => tx_eb32_i
  );

  tx_eb16_i.cyc <= tx_eb_i.cyc;
  tx_eb16_i.stb <= tx_eb_i.stb;
  tx_eb16_i.adr(tx_eb_i.adr'left downto 0) <= tx_eb_i.adr;
  tx_eb16_i.adr(c_wishbone_address_width-1 downto tx_eb_i.adr'left+1) <= (others => '0');
  tx_eb16_i.sel(tx_eb_i.sel'left downto 0) <= tx_eb_i.sel;
  tx_eb16_i.sel(c_wishbone_address_width/8-1 downto tx_eb_i.sel'left+1) <= (others =>'0');
  tx_eb16_i.we  <= tx_eb_i.we;
  tx_eb16_i.dat(tx_eb_i.dat'left downto 0) <= tx_eb_i.dat;
  tx_eb16_i.dat(c_wishbone_data_width/8-1 downto tx_eb_i.dat'left+1) <= (others =>'0');

  tx_eb_o.ack   <= tx_eb16_o.ack;
  tx_eb_o.err   <= tx_eb16_o.err;
  tx_eb_o.rty   <= tx_eb16_o.rty;
  tx_eb_o.stall <= tx_eb16_o.stall;

  dma_tx  : process (clk_i)
  begin
    if (clk_i'event and clk_i = '1') then
      if(rstn_i = '0') then
        tx_eb32_o.err <= '0';
        tx_eb32_o.rty <= '0';
        --tx_eb_o.dat <= (others => '0');
        rx_ram_dat_reg  <= (others => '0');

        irq_tx_done <= '0';
        tx_counter <= (others => '0');
        state_tx <= idle;
      else
        case state_tx  is
            when idle =>
              if(buffers_rdy = '1') then -- rx is already receiving and the ebcore wants to send an answer
                state_tx <= init;
              end if;

            when init =>
              irq_tx_done <= '0';
              tx_counter <= unsigned(base_adr_tx); -- reply must be the same length than request
              state_tx <= transfer;

            when transfer =>
              if((tx_counter < unsigned(length_rx)+unsigned(base_adr_tx)) and tx_eb32_i.cyc = '1') then
                if(tx_eb32_i.stb = '1' and tx_ram_i.stall = '0') then
                  tx_counter <= tx_counter + 4;
                end if;
              else
                state_tx <= done;
              end if;

            when done =>
              irq_tx_done <= '1';
              state_tx <= idle;

            when others =>
              state_tx <= idle;
        end case;
      end if;
    end if;
  end process;

  irq_rx_done_o <= irq_rx_done;

  rx_done <= '0' when (rx_counter < (unsigned(length_rx(15 downto 0))+unsigned(base_adr_rx(15 downto 0))))
      else  '1';

  --transfer_in_progress <= '1' when state_rx = transfer and transfer_counter_full = '0';
  --transfer_counter_full <= '1' when transfer_counter = c_counter_full else '0';
  rx_ram_o.stb <= not (rx_eb32_i.stall) and not rx_done;
  --rx_ram_o.stb <= not (rx_eb_i.stall) and not rx_done and w_counter_full;
  rx_ram_o.adr <= std_logic_vector(resize(rx_counter, 32));
  rx_eb32_o.dat <= rx_ram_i.dat;
  --rx_eb_o.dat <= ;
  rx_eb32_o.stb <= rx_ram_i.ack;
  --rx_eb_o.stb <= ;
  bytes_rx <= std_logic_vector(resize(rx_counter, 32));

  -- convert streaming input from 16 to 32 bit data width
  cmp_rx_adapter_32_to_16: eb_stream_narrow
  generic map (
    g_slave_width                           => 32,
    g_master_width                          => 16
  )
  port map (
    clk_i                                   => clk_i,
    rst_n_i                                 => rstn_i,
    slave_i                                 => rx_eb32_o,
    slave_o                                 => rx_eb32_i,
    master_i                                => rx_eb16_i,
    master_o                                => rx_eb16_o
  );

  rx_eb_o.cyc <= rx_eb16_o.cyc;
  rx_eb_o.stb <= rx_eb16_o.stb;
  rx_eb_o.adr <= rx_eb16_o.adr(rx_eb_o.adr'left downto 0);
  rx_eb_o.sel <= rx_eb16_o.sel(rx_eb_o.sel'left downto 0);
  rx_eb_o.we  <= rx_eb16_o.we;
  rx_eb_o.dat <= rx_eb16_o.dat(rx_eb_o.dat'left downto 0);

  rx_eb16_i.ack   <= rx_eb_i.ack;
  rx_eb16_i.err   <= rx_eb_i.err;
  rx_eb16_i.rty   <= rx_eb_i.rty;
  rx_eb16_i.stall <= rx_eb_i.stall;
  rx_eb16_i.dat   <= (others =>'0');
  rx_eb16_i.int   <= '0';

  dma_rx : process (clk_i)
  begin
    if (clk_i'event and clk_i = '1') then
      if(rstn_i = '0') then
        state_rx <= idle;
        irq_rx_done <= '0';
        rx_counter <= (others => '0');
        --transfer_counter <= (others => '0');
        --transfer_in_progress <= '0';

        rx_ram_o.cyc <= '0';
        rx_ram_o.we <= '0';
        rx_ram_o.sel <= (others => '1');
        rx_ram_o.dat <= (others => '0');

        rx_eb32_o.cyc <= '0';
        rx_eb32_o.we <= '1';
        rx_eb32_o.sel <= (others => '1');
        --rx_eb_o.adr <= (others => '0');
        rx_eb32_o.adr <= std_logic_vector(resize(unsigned(c_WRF_DATA), rx_eb32_o.adr'length));
        eb_stall <= '0';
      else
        eb_stall <= rx_eb32_i.stall;

        case state_rx  is
          when idle =>
            if(buffers_rdy ='1') then
              state_rx <= init;
            end if;

          when init =>
            irq_rx_done <= '0';
            rx_counter <= unsigned(base_adr_rx(15 downto 0));
            rx_ram_o.cyc <= '1';
            rx_eb32_o.cyc <= '1';
            state_rx <= transfer;

          when transfer =>
            --if (rx_done = '0') then --- all rx done
            --  rx_ram_data_int <= rx_ram_i.dat;
            --  rx_ram_valid_int <= rx_ram_i.ack;
            --
            --  if(rx_eb_i.stall = '0' and eb_stall = '0') then
            --
            --
            --  if(rx_ram_i.stall = '0' and  and transfer_counter_full = '1') then
            --    rx_counter <= rx_counter + 4;
            --  end if;
            --else
            --  state_rx <= done;
            --  rx_ram_o.cyc <= '0';
            --end if;
            --
            --if (transfer_counter_full = '0') then
            --  transfer_counter <= transfer_counter + 1;
            --else
            --  transfer_counter <= (others => '0');
            --end if;

            if (rx_done = '0') then --- all rx done
              if(rx_ram_i.stall = '0' and rx_eb32_i.stall = '0' and eb_stall = '0') then
                rx_counter <= rx_counter + 4;
              end if;
            else
              state_rx <= done;
              rx_ram_o.cyc <= '0';
            end if;

          when done =>
            rx_eb32_o.cyc <= '0';
            irq_rx_done <= '1';
            state_rx <= idle;

          when others  =>
            state_rx <= idle;
        end case;
      end if;
    end if;
  end process;
end behavioral;
