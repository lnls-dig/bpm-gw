library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reset_synch is
generic
(
  -- Select 1 for no pipeline, and greater than 1 to insert
  -- pipeline stages
  g_pipeline                               : natural := 4
);
port
(
  clk_i                                    : in  std_logic;
  arst_n_i                                 : in  std_logic;
  rst_n_o                                  : out std_logic
);
end reset_synch;

architecture rtl of reset_synch is
  signal s_ff                              : std_logic_vector(g_pipeline-1 downto 0) := (others => '0');

  -- force tool to not remove pipeline registers
  attribute equivalent_register_removal    : string;
  attribute equivalent_register_removal of s_ff
                                           : signal is "no";
  -- force tool to not infer shift-register
  attribute shreg_extract                  : string;
  attribute shreg_extract of s_ff          : signal is "no";
  -- force tool to keep register
  attribute keep                           : string;
  attribute keep of s_ff                   : signal is "true";
  -- try to reduce fanout of reset signal
  attribute max_fanout                     : string;
  attribute max_fanout of s_ff             : signal is "reduce";
begin

  assert (g_pipeline >= 1)
  report "[reset_synch] g_pipeline must be at least 1!"
  severity failure;

  p_rst_sync : process(clk_i, arst_n_i)
  begin
    if arst_n_i = '0' then
      s_ff(0) <= '0';
    elsif rising_edge(clk_i) then
      s_ff(0) <= '1';
    end if;
  end process;

  gen_pipe : if g_pipeline > 1 generate
    -- Shift reg
    p_rst_pipe : process (clk_i, arst_n_i)
    begin
      if arst_n_i = '0' then
        for i in 0 to g_pipeline-2 loop
          s_ff(i+1) <= '0';
        end loop;
      elsif rising_edge(clk_i) then
        for i in 0 to g_pipeline-2 loop
          s_ff(i+1) <= s_ff(i);
        end loop;

      end if;
    end process;
  end generate;

  rst_n_o <= s_ff(s_ff'left);

end rtl;
