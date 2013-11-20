library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.wishbone_pkg.all;
use work.dbe_wishbone_pkg.all;
use work.wr_fabric_pkg.all;

entity xwb_ethmac_adapter_tb is
end xwb_ethmac_adapter_tb;

architecture sim of xwb_ethmac_adapter_tb is

  signal clk_i                                : std_logic;
  signal rstn_i                               : std_logic;
  signal wb_slave_o                           : t_wishbone_slave_out;
  signal wb_slave_i                           : t_wishbone_slave_in;
  signal tx_ram_o                             : t_wishbone_master_out;
  signal tx_ram_i                             : t_wishbone_master_in;
  signal rx_ram_o                             : t_wishbone_master_out;
  signal rx_ram_i                             : t_wishbone_master_in;
  signal rx_eb_o                              : t_wrf_source_out;
  signal rx_eb_i                              : t_wrf_source_in;
  signal tx_eb_i                              : t_wrf_sink_in;
  signal tx_eb_o                              : t_wrf_sink_out;
  signal irq_tx_done_o                        : std_logic;
  signal irq_rx_done_o                        : std_logic;

  -- TX signals
  signal tx_eb_counter                        : unsigned(31 downto 0);

  -- General constants
  constant length_transfer                    : std_logic_vector := x"0000002F";

  constant clock_period                       : time := 10 ns;
  signal stop_the_clock                       : boolean := false;

  function revert_bytes(vec : std_logic_vector)
    return std_logic_vector
  is
    variable result : std_logic_vector(vec'length-1 downto 0) := (others => '0');
  begin
    for i in 0 to result'length/8-1 loop
      for j in 0 to 8-1 loop
        result(j+(i*8)) := vec((i+1)*8-1-j);
      end loop;
    end loop;

    return result;
  end revert_bytes;

  function mirror_nibble_vector(vec : std_logic_vector)
    return std_logic_vector
  is
    variable result : std_logic_vector(vec'length-1 downto 0);
    variable num_nibbles : natural;
  begin
    num_nibbles := result'length/4;
    for i in 0 to num_nibbles-1 loop
      result((i*4)+3 downto (i*4)) := vec(num_nibbles*4-(i*4)-1 downto num_nibbles*4-(i*4)-4);
    end loop;

    return result;
  end mirror_nibble_vector;

begin

  cmp_xwb_ethmac_adapter: xwb_ethmac_adapter
  port map (
    clk_i                                   => clk_i,
    rstn_i                                  => rstn_i,

    wb_slave_o                              => wb_slave_o,
    wb_slave_i                              => wb_slave_i,

    tx_ram_o                                => tx_ram_o,
    tx_ram_i                                => tx_ram_i,

    rx_ram_o                                => rx_ram_o,
    rx_ram_i                                => rx_ram_i,

    rx_eb_o                                 => rx_eb_o,
    rx_eb_i                                 => rx_eb_i,

    tx_eb_o                                 => tx_eb_o,
    tx_eb_i                                 => tx_eb_i,

    irq_tx_done_o                           => irq_tx_done_o,
    irq_rx_done_o                           => irq_rx_done_o
  );

  stimulus: process
  begin

    -- Put initialisation code here
    rstn_i <= '0';

    --tx_eb_i <=   (
    --    cyc => '0',
    --    stb => '0',
    --    adr => (others => '0'),
    --    sel => (others => '1'),
    --    we  => '1',
    --    dat => (others => '0'));

    rx_eb_i  <=   (
      ack   => '0',
      err   => '0',
      rty   => '0',
      stall => '0');

    wb_slave_i <=   (
        cyc => '0',
        stb => '0',
        adr => (others => '0'),
        sel => (others => '1'),
        we  => '0',
        dat => (others => '0'));

    tx_ram_i  <=   (
      ack   => '0',
      err   => '0',
      rty   => '0',
      stall => '0',
      int => '0',
      dat   => (others => '0'));

    --rx_ram_i.err <= '0';
    --rx_ram_i.rty <= '0';
    --rx_ram_i.stall <= '0';
    --rx_ram_i.dat <= (others => '0');

    wait for 2*clock_period;
    rstn_i <= '1';
    wait for clock_period;
    -- put test bench stimulus code here

    --base_adr_tx = 0x00000100
    wb_slave_i <=   (
        cyc => '1',
        stb => '1',
        adr => x"00000004",
        sel => (others => '1'),
        we  => '1',
        dat => x"00000100");

    wait for clock_period;

    --base_adr_rx = 0x00001000
    wb_slave_i <=   (
        cyc => '1',
        stb => '1',
        adr => x"00000008",
        sel => (others => '1'),
        we  => '1',
        dat => x"00001000");

    wait for clock_period;

    --length_rx = 0xFF
    wb_slave_i <=   (
        cyc => '1',
        stb => '1',
        adr => x"0000000C",
        sel => (others => '1'),
        we  => '1',
        dat => length_transfer);

    wait for clock_period;

  --ctrl = 0x00
    wb_slave_i <=   (
        cyc => '1',
        stb => '1',
        adr => x"00000000",
        sel => (others => '1'),
        we  => '1',
        dat => x"00000001");

    wait for clock_period;
  --ctrl = 0x00
    wb_slave_i <=   (
        cyc => '1',
        stb => '1',
        adr => x"00000000",
        sel => (others => '1'),
        we  => '0',
        dat => x"00000001");

    --stop_the_clock <= true;
    wait;
  end process;

  p_rx : process(clk_i)
  begin
    if rising_edge(clk_i) then
      if (rstn_i = '0') then
        rx_ram_i.ack <= '0';
        rx_ram_i.err <= '0';
        rx_ram_i.rty <= '0';
        rx_ram_i.int <= '0';
        rx_ram_i.stall <= '0';
        rx_ram_i.dat <= (others => '0');
      else
        rx_ram_i.ack <=  rx_ram_o.stb and rx_ram_o.cyc;

        -- write the received addresses as the input data
        if(rx_ram_o.stb = '1' and rx_ram_o.cyc = '1' and rx_ram_o.we = '0') then
          rx_ram_i.dat <= mirror_nibble_vector(rx_ram_o.adr(16-1 downto 0)) & rx_ram_o.adr(16-1 downto 0);
        end if;

      end if;
    end if;
  end process;

  p_tx : process(clk_i)
  begin
    if rising_edge(clk_i) then
      if (rstn_i = '0') then
        tx_eb_i.cyc <= '0';
        tx_eb_i.stb <= '0';
        tx_eb_i.adr <= (others => '0');
        tx_eb_i.sel <= (others => '1');
        tx_eb_i.we  <= '1';
        tx_eb_i.dat <= (others => '0');
        tx_eb_counter <= (others => '0');
      else
        -- keep this line high
        tx_eb_i.cyc <= '1';
        tx_eb_i.adr <= c_WRF_DATA;
        -- Check if we have received the whole transfer
        if (irq_rx_done_o = '1' and irq_tx_done_o = '0') then
          -- Prepare to transfer data...
          tx_eb_i.stb <= '0';

          -- Tranasfer data if not done
          if (tx_eb_o.stall = '0') then
            -- reply must be of the same length than request
            tx_eb_i.stb <= '1';
            tx_eb_i.dat <= std_logic_vector(unsigned(tx_eb_i.dat) + 4);
            tx_eb_counter <= tx_eb_counter + 4;
          else
            tx_eb_i.stb <= '0';
          end if;
        else
          tx_eb_i.stb <= '0';
        end if;

      end if;
    end if;
  end process;

  clocking: process
  begin
    while not stop_the_clock loop
      clk_i <= '0', '1' after clock_period / 2;
      wait for clock_period;
    end loop;
    wait;
  end process;

end sim;
