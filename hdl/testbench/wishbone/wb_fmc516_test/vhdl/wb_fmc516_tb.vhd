library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library work;
-- Main Wishbone Definitions
use work.wishbone_pkg.all;
-- Custom Wishbone Modules
use work.custom_wishbone_pkg.all;
-- Wishbone Stream Interface
use work.wb_stream_pkg.all;
-- Register Bank
use work.fmc150_wbgen2_pkg.all;

entity wb_fmc516_tb is          
end wb_fmc516_tb;

architecture sim of wb_fmc516_tb is  
  -- Constants
  -- 100 MHz clock
  constant c_100mhz_clk_period							: time := 10.00 ns;
  -- 200.00 MHz clock
  constant c_200mhz_clk_period		    			: time := 5.00 ns;
  -- 250.00 MHz clock
  constant c_adc_clk_period		    					: time := 4.00 ns;
    
	constant c_sim_time												: time := 10000.00 ns;
	-- Specify clock chain 1 as 4.0 ns period = 250 MHz
	constant c_adc_clock_values								: t_clock_values_array(3 downto 0) :=
						(3 => 0.0, 2 => 0.0, 1 => 4.0, 0 => 0.0);
	
	signal g_end_simulation          					: boolean   := false; -- Set to true to halt the simulation
    
	-- Clock signals
	signal clk_100mhz                       	: std_logic := '0';
	signal clk_200mhz                       	: std_logic := '0';
	signal clk_sys                          	: std_logic := '0';
	signal clk_sys_n													: std_logic := '1';
	signal sys_rst_n                        	: std_logic := '0';
		
	-- Wishbone signals	
	signal wb_slv_in                        	: t_wishbone_slave_in := cc_dummy_slave_in;
	signal wb_slv_out                       	: t_wishbone_slave_out;
		
	signal wbs_src_in                       	: t_wbs_source_in := cc_dummy_src_in;
	signal wbs_src_out                      	: t_wbs_source_out;
		
	-- Dummy signals	
	constant cc_zero_bit                    	: std_logic := '0';
		
	-- Simulation signals	
	signal s_adc_clk                    			: std_logic := '0';
	signal s_adc_clk_n												: std_logic := '1';
	signal s_adc_ch0_data               			: std_logic_vector(7 downto 0);
	signal s_adc_ch1_data               			: std_logic_vector(7 downto 0);
	signal s_adc_ch2_data               			: std_logic_vector(7 downto 0);
	signal s_adc_ch3_data               			: std_logic_vector(7 downto 0);
	signal s_adc_valid                  			: std_logic;
	
	--------------------------------
	-- Functions and Procedures
	--------------------------------
	
	-- Generate dummy (0) values
	function f_zeros(size : integer)
			return std_logic_vector is
	begin
			return std_logic_vector(to_unsigned(0, size));
	end f_zeros;
	
	-- Generate bit with probability of '1' equals to 'prob'
	procedure gen_valid(prob : real; variable seed1, seed2 : inout positive; 
			signal result : out std_logic) 
	is
		variable rand: real;                           	-- Random real-number value in range 0 to 1.0
	begin
			uniform(seed1, seed2, rand);             			-- generate random number
			
			if (rand > prob) then
					result <= '1';
			else
					result <= '0';
			end if;        
	end procedure;
	
	-- Generate random std_logic_vector
	procedure gen_data(size : positive; variable seed1, seed2 : inout positive; 
			signal result : out std_logic_vector)
	is
		variable rand : real;                           -- Random real-number value in range 0 to 1.0
		variable int_rand : integer;                    -- Random integer value in range 0..2^(c_wbs_data_width/2)
		variable stim : std_logic_vector(c_wbs_data_width-1 downto 0);  -- Random c_wbs_data_width-1 bit stimulus
	begin
			uniform(seed1, seed2, rand);                                   -- generate random number
			int_rand := integer(trunc(rand*real(2**(c_wbs_data_width/2))));    -- rescale to 0..2^(c_wbs_data_width/2), find integer part
			stim := std_logic_vector(to_unsigned(int_rand, stim'length));  -- convert to std_logic_vector
			
			result <= stim(size-1 downto 0);
	end procedure;

	function toggle_bus(bus_in : std_logic_vector)
		return std_logic_vector
	is
		variable ret : std_logic_vector(bus_in'length-1 downto 0) := (others => '0');
	begin
		for i in 0 to bus_in'length-1 loop
			ret(i) := not bus_in(i);
		end loop;

		return ret;
	end function;
    
begin  -- sim

	p_100mhz_clk_gen : process
	begin
		while g_end_simulation = false loop
			wait for c_100mhz_clk_period/2;
			clk_100mhz <= not clk_100mhz;
			wait for c_100mhz_clk_period/2;
			clk_100mhz <= not clk_100mhz;	
		end loop;
		wait;  -- simulation stops here
	end process;

	p_200mhz_clk_gen : process
	begin
		while g_end_simulation = false loop
			wait for c_200mhz_clk_period/2;
			clk_200mhz <= not clk_200mhz;
			wait for c_200mhz_clk_period/2;
			clk_200mhz <= not clk_200mhz;	
		end loop;
		wait;  -- simulation stops here
	end process;
    
  -- ADC clock gen
	p_adc_clk_gen : process
	begin
		while g_end_simulation = false loop
			wait for c_adc_clk_period/2;
				s_adc_clk <= not s_adc_clk; 
			wait for c_adc_clk_period/2;
				s_adc_clk <= not s_adc_clk; 
		end loop;
		wait;  -- simulation stops here
	end process;
    
	p_gen_adc_valid : process
		variable seed1, seed2: positive;               -- Seed values for random generator
	begin
		seed1                                       := 67632;
		seed2                                       := 3234; 
		s_adc_valid                             		<= '0';
		-- Wait until reset completion (synch with adc clock domain)
		wait until sys_rst_n = '1' and rising_edge(s_adc_clk);
		l_generate_valid: loop 
				gen_valid(0.5, seed1, seed2, s_adc_valid);
				wait until rising_edge(s_adc_clk);
		end loop;                
	end process;
    
	p_gen_adc_data : process
		variable seed1, seed2: positive;               -- Seed values for random generator
	begin
		seed1                                       := 432566;
		seed2                                       := 211; 
		s_adc_ch0_data                          		<= (others => '0');
		s_adc_ch1_data                          		<= (others => '0');
		s_adc_ch2_data                          		<= (others => '0');
		s_adc_ch3_data                          		<= (others => '0');
		-- Wait until reset completion (synch with adc clock domain)
		wait until sys_rst_n = '1' and rising_edge(s_adc_clk);
		l_generate_data: loop 
				gen_data(s_adc_ch0_data'length, seed1, seed2, s_adc_ch0_data);
				gen_data(s_adc_ch1_data'length, seed1, seed2, s_adc_ch1_data);          
				gen_data(s_adc_ch2_data'length, seed1, seed2, s_adc_ch2_data);          
				gen_data(s_adc_ch3_data'length, seed1, seed2, s_adc_ch3_data);          
				wait until rising_edge(s_adc_clk);
		end loop;  
	end process;
	
	p_main_simulation : process
	begin
		-- Generate reset signal
		sys_rst_n <= '0';   
		wait for 4*c_100mhz_clk_period;
		sys_rst_n <= '1';    

		wait for c_sim_time;
		g_end_simulation <= true;
		wait;
	end process;

	cmp_wb_fmc516 : wb_fmc516
	generic map(
		--g_interface_mode                        : t_wishbone_interface_mode      := CLASSIC;
		--g_address_granularity                   : t_wishbone_address_granularity := WORD;
		g_adc_clock_period_values               => c_adc_clock_values,
		g_use_clock_chains                      => "0010",
		g_use_data_chains                       => "1111",
		--g_adc_bits															=> 16,
		--g_packet_size                           : natural := 32;
		g_sim                                   => 1
	)
	port map(
		sys_clk_i                               => clk_sys,
		sys_rst_n_i                             => sys_rst_n,
		sys_clk_200Mhz_i                        => clk_200mhz,
		
		-----------------------------
		-- Wishbone Control Interface signals
		-----------------------------
		
		wb_adr_i                                => f_zeros(c_wishbone_address_width),
		wb_dat_i                                => f_zeros(c_wishbone_data_width),
		wb_dat_o                                => open,
		wb_sel_i                                => f_zeros(c_wishbone_data_width/8),
		wb_we_i                                 => '0',
		wb_cyc_i                                => '0',
		wb_stb_i                                => '0',
		wb_ack_o                                => open,
		wb_err_o                                => open,
		wb_rty_o                                => open,
		wb_stall_o                              => open,
		
		-----------------------------
		-- External ports
		-----------------------------
		-- System I2C Bus. Slaves: Atmel AT24C512B Serial EEPROM, 
		-- AD7417 temperature diodes and AD7417 supply rails
		sys_i2c_scl_b                           => open,
		sys_i2c_sda_b                           => open,
		
		-- ADC clocks. One clock per ADC channel.
		-- Only ch1 clock is used as all data chains
		-- are sampled at the same frequency
		adc_clk0_p_i                         		=> s_adc_clk,
		adc_clk0_n_i                         		=> s_adc_clk_n,
		adc_clk1_p_i                         		=> s_adc_clk,
		adc_clk1_n_i                         		=> s_adc_clk_n,
		adc_clk2_p_i                         		=> clk_sys,
		adc_clk2_n_i                         		=> clk_sys_n,
		adc_clk3_p_i                         		=> clk_sys,
		adc_clk3_n_i                         		=> clk_sys_n,
		
		-- DDR ADC data channels.
		adc_data_ch0_p_i                      	=> s_adc_ch0_data,
		adc_data_ch0_n_i                      	=> toggle_bus(s_adc_ch0_data),
		adc_data_ch1_p_i                      	=> s_adc_ch1_data,
		adc_data_ch1_n_i                      	=> toggle_bus(s_adc_ch1_data),
		adc_data_ch2_p_i                      	=> s_adc_ch2_data,
		adc_data_ch2_n_i                      	=> toggle_bus(s_adc_ch2_data),
		adc_data_ch3_p_i                      	=> s_adc_ch3_data,
		adc_data_ch3_n_i                      	=> toggle_bus(s_adc_ch3_data),
		
		-- ADC clock (half of the sampling frequency) divider reset
		adc_clk_div_rst_p_o                     => open,
		adc_clk_div_rst_n_o                     => open,
		
		-- FMC Front leds. Typical uses: Over Range or Full Scale
		-- condition.
		fmc_leds_o                              => open,
		
		-- ADC SPI control interface. Three-wire mode. Tri-stated data pin
		sys_spi_clk_o                           => open,
		sys_spi_data_b                          => open,
		sys_spi_cs_adc1_n_o                     => open,  -- SPI ADC CS channel 0
		sys_spi_cs_adc2_n_o                     => open,  -- SPI ADC CS channel 1 
		sys_spi_cs_adc3_n_o                     => open,  -- SPI ADC CS channel 2 
		sys_spi_cs_adc4_n_o                     => open,  -- SPI ADC CS channel 3 
		
		-- External Trigger To/From FMC
		ext_trig_p_i                            => '0',
		ext_trig_n_i                            => '0',
		ext_trig_p_o                            => open,
		ext_trig_n_o                            => open,
		
		-- LMK (National Semiconductor) is the clock and distribution IC.
		-- SPI interface?
		lmk_lock_i                              => '0',
		lmk_sync_o                              => open,
		lmk_latch_en_o                          => open,
		lmk_data_o                              => open,
		lmk_clock_o                             => open,
		
		-- Programable VCXO via I2C?
		vcxo_sda_b                              => open,
		vcxo_scl_o                              => open,
		vcxo_pd_l_o                             => open,
		
		-- One-wire To/From DS2431 (VMETRO Data)
		fmc_id_dq_b                            	=> open,
		-- One-wire To/From DS2432 SHA-1 (SP-Devices key)
		fmc_key_dq_b                            => open,
		
		-- General board pins
		fmc_pwr_good_i                          => '0',
		-- Internal/External clock distribution selection
		fmc_clk_sel_o                          	=> open,
		-- Reset ADCs
		fmc_reset_adcs_n_o                      => open,
		--FMC Present status            
		fmc_prsnt_m2c_l_i                      	=> '0',
		
		-----------------------------
		-- ADC output signals. Continuous flow. Mostly used for debug
		-----------------------------
		--adc_out_data_o                          : out std_logic_vector(63 downto 0);
		--adc_out_clk_o                           : out std_logic;
		adc_clk_o                               => open,
		adc_data_ch0_o                          => open,
		adc_data_ch1_o                          => open,
		adc_data_ch2_o                          => open,
		adc_data_ch3_o                          => open,
		adc_data_valid_o                        => open,
		
		-----------------------------
		-- Wishbone Streaming Interface Source
		-----------------------------
		
		wbs_adr_o                               => open,
		wbs_dat_o                               => open,
		wbs_cyc_o                               => open,
		wbs_stb_o                               => open,
		wbs_we_o                                => open,
		wbs_sel_o                               => open,
		wbs_ack_i                               => '0',
		wbs_stall_i                             => '0',
		wbs_err_i                               => '0',
		wbs_rty_i                               => '0'
	);

  s_adc_clk_n																<= not s_adc_clk;
	clk_sys                                   <= clk_100mhz;
	clk_sys_n																	<= not clk_sys;

end sim;
