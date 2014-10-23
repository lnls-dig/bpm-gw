library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pulse2level is
port
(
  clk_i                                    : in std_logic;
  rst_n_i                                  : in std_logic;

  -- Pulse input
  pulse_i                                  : in std_logic;
  -- Clear level
  clr_i                                    : in std_logic;
  -- Level output
  level_o                                  : out std_logic
);
end pulse2level;

architecture rtl of pulse2level is
  signal level                             : std_logic := '0';
begin

  -- Convert from pulse to level signal
  p_pulse_to_level : process (clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' then
        level <= '0';
      else
        if clr_i = '1'then
          level <= '0';
        elsif pulse_i = '1' then
          level <= '1';
        end if;
      end if;
    end if;
  end process;

  level_o <= level;

end rtl;

