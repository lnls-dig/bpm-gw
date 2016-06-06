library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Common cores
use work.genram_pkg.all;

entity heartbeat is
generic
(
  -- number of system clock cycles to count before blinking
  g_clk_counts                             : natural := 100000000
);
port
(
  -- 100 MHz system clock
  clk_i                                    : in std_logic;
  rst_n_i                                  : in std_logic;

  -- Heartbeat pulse output
  heartbeat_o                              : out std_logic
);
end heartbeat;

architecture rtl of heartbeat is

  constant c_pps_counter_width             : natural := f_log2_size(g_clk_counts);
  signal hb                                : std_logic := '0';
  signal pps_counter                       : unsigned(c_pps_counter_width-1 downto 0) :=
                                               (others => '0');
begin

  p_heartbeat : process (clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' then
        pps_counter <= to_unsigned(0, pps_counter'length);
        hb <= '0';
      else
        if pps_counter = g_clk_counts-1 then
          pps_counter <= to_unsigned(0, pps_counter'length);
          hb <= not hb;
        else
         pps_counter <= pps_counter + 1;
        end if;
      end if;
    end if;
  end process;

  heartbeat_o <= hb;

end rtl;

