------------------------------------------------------------------------------
-- dma_status_reg_synch.vhd - entity/architecture pair
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.dma_pkg.all;

------------------------------------------------------------------------------
-- Entity section
------------------------------------------------------------------------------

entity dma_status_reg_synch is
	generic
	(
		C_NUM_REG                      	: integer              := 10;
		C_SLV_DWIDTH                   	: integer              := 32;
		C_STATUS_REG_IDX				: natural	   		   := 1
	);
	port
	(
		bus_clk_i						: in  std_logic;
		bus_rst_n_i						: in  std_logic;
		bus_reg_read_sel_i				: in  std_logic_vector(C_NUM_REG-1 downto 0);   
		bus_reg_write_sel_i				: in  std_logic_vector(C_NUM_REG-1 downto 0);  
		bus_2_ip_data_i					: in  std_logic_vector(C_SLV_DWIDTH-1 downto 0);
		
		dma_complete_i					: in  std_logic;
		dma_ovf_i						: in  std_logic;
		
		dma_complete_synch_o			: out  std_logic;
		dma_ovf_synch_o					: out  std_logic
	);
end entity dma_status_reg_synch;

architecture IMP of dma_status_reg_synch is	
	-- DMA status synch regs	
	signal s_dma_complete_d1            : std_logic;
	signal s_dma_complete_d2            : std_logic;
	signal s_dma_complete_d3            : std_logic;
	signal s_dma_complete_status        : std_logic;
	
	signal s_dma_ovf_d1                 : std_logic;
	signal s_dma_ovf_d2                 : std_logic;
	signal s_dma_ovf_status             : std_logic;
	
	-- Glue logic
	signal dma_complete_synch_glue		: std_logic;
	signal dma_ovf_synch_glue			: std_logic;
begin		

	-- Glue logic
	dma_complete_synch_o				<= dma_complete_synch_glue;
    dma_ovf_synch_o						<= dma_ovf_synch_glue;

	p_dma_status_synch : process(bus_clk_i) is
	begin
	if rising_edge(bus_clk_i) then
		if bus_rst_n_i = '0' then
			s_dma_complete_d1 <= '0';
			s_dma_complete_d2 <= '0';	
			s_dma_complete_d3 <= '0';
			s_dma_complete_status <= '0';
			
			s_dma_ovf_d1 <= '0';	
			s_dma_ovf_d2 <= '0';
			s_dma_ovf_status <= '0';
		else
			s_dma_complete_d1 <= dma_complete_i;
			s_dma_complete_d2 <= s_dma_complete_d1;
			s_dma_complete_d3 <= s_dma_complete_d2;
			-- Every dma_complete toggle is recognized as a dma_complete
			s_dma_complete_status <= s_dma_complete_d3 xor s_dma_complete_d2;
				
			s_dma_ovf_d1 <= dma_ovf_i;
			s_dma_ovf_d2 <= s_dma_ovf_d1;
			s_dma_ovf_status <= s_dma_ovf_d2;
		end if;
	end if;
	end process p_dma_status_synch;
	
	-- DMA Status set and clear software accessible regs
	-- If a condition is detected, set the bit accordingly.
	-- Otherwise, wait for "user" to clear the bit.
	-- This is done in order to ensure that the user can detected 
	-- the condition.
	p_dma_status_reg : process(bus_clk_i) is
	begin
	if rising_edge(bus_clk_i) then	
		if bus_rst_n_i = '0' then
			dma_complete_synch_glue <= '0';
			dma_ovf_synch_glue	<= '0';
		else
			if s_dma_complete_status = '1' then
				dma_complete_synch_glue <= '1';
			elsif bus_reg_write_sel_i = std_logic_vector(to_unsigned(2**(C_NUM_REG-1-C_STATUS_REG_IDX), C_NUM_REG)) and dma_complete_synch_glue = '1' then
				dma_complete_synch_glue <= bus_2_ip_data_i(0);
			end if;
			
			if s_dma_ovf_status = '1' then
				dma_ovf_synch_glue <= '1';
			elsif bus_reg_write_sel_i = std_logic_vector(to_unsigned(2**(C_NUM_REG-1-C_STATUS_REG_IDX), C_NUM_REG)) and dma_ovf_synch_glue = '1' then
				dma_ovf_synch_glue <= bus_2_ip_data_i(1);
			end if;
		end if;
	end if;
	end process p_dma_status_reg;
	
end IMP;