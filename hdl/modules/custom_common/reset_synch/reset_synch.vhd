library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reset_synch is
	port 
	(
		clk_i     		        : in  std_logic;
		arst_n_i		        : in  std_logic;
		rst_n_o      		    : out std_logic
	);
end reset_synch;

architecture rtl of reset_synch is
	signal s_ff 		        : std_logic;
begin
    process(clk_i, arst_n_i)
	begin
		if arst_n_i = '0' then
            s_ff  			    <= '0';
            rst_n_o 			<= '0';
		elsif rising_edge(clk_i) then
            s_ff  			    <= '1';
            rst_n_o 			<= s_ff;
		end if;
	end process;
end rtl;
