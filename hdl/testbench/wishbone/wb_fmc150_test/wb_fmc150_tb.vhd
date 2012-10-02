library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.wishbone_pkg.all;
use work.custom_wishbone_pkg.all;
use work.wb_stream_pkg.all;

entity wb_fmc150_tb is          
end wb_fmc150_tb;

architecture sim of wb_fmc150_tb is  
    -- Constants
	-- 100.00 MHz clock
	constant c_100mhz_clk_period		    : time := 10.00 ns;
    -- 200.00 MHz clock
    constant c_200mhz_clk_period		    : time := 5.00 ns;
	constant c_sim_time						: time := 10000.00 ns;
	
	signal g_end_simulation          		: boolean   := false; -- Set to true to halt the simulation
    
    -- Clock signals
    signal clk_100mhz                       : std_logic := '0';
    signal clk_200mhz                       : std_logic := '0';
    signal clk_sys                          : std_logic := '0';
    signal rst_n_i                          : std_logic := '0';
    
    -- Wishbone signals
    signal wb_slv_in                        : t_wishbone_slave_in := cc_dummy_slave_in;
    signal wb_slv_out                       : t_wishbone_slave_out;
    
    signal wbs_src_in                       : t_wbs_source_in := c_dummy_src_in;
    signal wbs_src_out                      : t_wbs_source_out;
    
    -- Dummy signals
    constant cc_dummy_bit                   : std_logic := '0';
    constant cc_dummy_slv                   : std_logic_vector := '0';
    
    -- Generate dummy (0) values
    function f_zeros(size : integer)
        return std_logic_vector is
    begin
        return std_logic_vector(to_unsigned(0, size));
    end f_zeros;
    
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
	
	p_main_simulation : process
	begin
        -- Generate reset signal
        rst_n_i <= '0';   
        wait for 3*c_100mhz_clk_period;
        rst_n_i <= '1';    

		wait for c_sim_time;
            g_end_simulation <= true;
		wait;
	end process;

    cmp_dut : xwb_fmc150 
    --generic map
    --(
        --g_interface_mode                        => PIPELINED,
        --g_address_granularity                   => WORD,
        --g_packet_size                           => 32
    --);      
    port map     
    (       
        rst_n_i                                      => rst_n_i,
        clk_sys_i                                    => clk_sys,
        clk_100Mhz_i                                 => clk_100Mhz,
        clk_200Mhz_i                                 => clk_200Mhz,
                
        -----------------------------       
        -- Wishbone signals     
        -----------------------------       
            
        wb_slv_i                                    => wb_slv_in,
        wb_slv_o                                    => wb_slv_out,
                
        -----------------------------       
        -- External ports       
        -----------------------------       
        --Clock/Data connection to ADC on FMC150 (ADS62P49)
        adc_clk_ab_p_i                              => '0',
        adc_clk_ab_n_i                              => '0',
        adc_cha_p_i                                 => f_zeros(7),
        adc_cha_n_i                                 => f_zeros(7),
        adc_chb_p_i                                 => f_zeros(7),
        adc_chb_n_i                                 => f_zeros(7),
            
        --Clock/Data connection to DAC on FMC150 (DAC3283)
        dac_dclk_p_o                                => open,
        dac_dclk_n_o                                => open,
        dac_data_p_o                                => open,
        dac_data_n_o                                => open,
        dac_frame_p_o                               => open,
        dac_frame_n_o                               => open,
        txenable_o                                  => open,
                
        --Clock/Trigger connection to FMC150        
        clk_to_fpga_p_i                             => '0',
        clk_to_fpga_n_i                             => '0',
        ext_trigger_p_i                             => '0',
        ext_trigger_n_i                             => '0',
                
        -- Control signals from/to FMC150       
        --Serial Peripheral Interface (SPI)     
        spi_sclk_o                                  => open, -- Shared SPI clock line
        spi_sdata_o                                 => open, -- Shared SPI data line
                        
        -- ADC specific signals             
        adc_n_en_o                                  => open, -- SPI chip select
        adc_sdo_i                                   => '0', -- SPI data out
        adc_reset_o                                 => open, -- SPI reset
                        
        -- CDCE specific signals                
        cdce_n_en_o                                 => open, -- SPI chip select
        cdce_sdo_i                                  =>'0', -- SPI data out
        cdce_n_reset_o                              => open,
        cdce_n_pd_o                                 => open,
        cdce_ref_en_o                               => open,
        cdce_pll_status_i                           => '0',
                        
        -- DAC specific signals             
        dac_n_en_o                                  => open, -- SPI chip select
        dac_sdo_i                                   => '0', -- SPI data out
                        
        -- Monitoring specific signals              
        mon_n_en_o                                  => open, -- SPI chip select
        mon_sdo_i                                   => '0', -- SPI data out
        mon_n_reset_o                               => open,
        mon_n_int_i                                 => '0',
                    
        --FMC Present status            
        prsnt_m2c_l_i                               => '0',
        
        -- Wishbone Streaming Interface Source
        wbs_source_i                                => wbs_src_in,
        wbs_source_o                                => wbs_src_out
    );
    
    clk_sys                                         <= clk_100Mhz;

end sim;
