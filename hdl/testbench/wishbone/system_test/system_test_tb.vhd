library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library work;
-- Main Wishbone Definitions
use work.wishbone_pkg.all;
-- Custom Wishbone Modules
use work.dbe_wishbone_pkg.all;
-- Wishbone Stream Interface
use work.wb_stream_pkg.all;
-- Register Bank
use work.fmc150_wbgen2_pkg.all;

library UNISIM;  
use UNISIM.Vcomponents.all;

entity system_test_tb is          
end system_test_tb;

architecture sim of system_test_tb is  
  -- Constants
  -- 100.00 MHz clock
  constant c_100mhz_clk_period		    : time := 10.00 ns;
  -- 200.00 MHz clock
  constant c_200mhz_clk_period		    : time := 5.00 ns;
  -- 61.44 MHz clock
  constant c_sim_adc_clk_period		    : time := 16.00 ns;
  -- 128.88 MHz clock
  constant c_sim_adc_clk2x_period		: time := 8.00 ns;
    
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
    
    signal wbs_src_in                       : t_wbs_source_in := cc_dummy_src_in;
    signal wbs_src_out                      : t_wbs_source_out;
    
    -- Dummy signals
    constant cc_zero_bit                    : std_logic := '0';
    
    -- Simulation signals
    signal s_sim_adc_clk                    : std_logic := '0';
    signal s_sim_adc_clk2x                  : std_logic := '0';
    signal s_sim_adc_cha_data               : std_logic_vector(6 downto 0);
    signal s_sim_adc_chb_data               : std_logic_vector(6 downto 0);
    signal s_sim_adc_valid                  : std_logic;
    
    -----------------------------------------
    -- Components
    -----------------------------------------
    
    component dbe_bpm_simple_top
    port(
      -----------------------------------------
      -- Clocking pins
      -----------------------------------------
      --clk100_i 						          : in std_logic;
      sys_clk_p_i						          : in std_logic;
      sys_clk_n_i						          : in std_logic;
      
      -----------------------------------------
      -- Reset Button
      -----------------------------------------
      sys_rst_button_i                : in std_logic;
      
      -----------------------------------------
      -- FMC150 pins
      -----------------------------------------
      --Clock/Data connection to ADC on FMC150 (ADS62P49)
      adc_clk_ab_p_i                  : in  std_logic;
      adc_clk_ab_n_i                  : in  std_logic;
      adc_cha_p_i                     : in  std_logic_vector(6 downto 0);
      adc_cha_n_i                     : in  std_logic_vector(6 downto 0);
      adc_chb_p_i                     : in  std_logic_vector(6 downto 0);
      adc_chb_n_i                     : in  std_logic_vector(6 downto 0);

      --Clock/Data connection to DAC on FMC150 (DAC3283)
      dac_dclk_p_o                    : out std_logic;
      dac_dclk_n_o                    : out std_logic;
      dac_data_p_o                    : out std_logic_vector(7 downto 0);
      dac_data_n_o                    : out std_logic_vector(7 downto 0);
      dac_frame_p_o                   : out std_logic;
      dac_frame_n_o                   : out std_logic;
      txenable_o                      : out std_logic;
      
      --Clock/Trigger connection to FMC150
      --clk_to_fpga_p_i                 : in  std_logic;
      --clk_to_fpga_n_i                 : in  std_logic;
      --ext_trigger_p_i                 : in  std_logic;
      --ext_trigger_n_i                 : in  std_logic;
            
      -- Control signals from/to FMC150
      --Serial Peripheral Interface (SPI)
      spi_sclk_o                      : out std_logic; -- Shared SPI clock line
      spi_sdata_o                     : out std_logic; -- Shared SPI data line
              
      -- ADC specific signals     
      adc_n_en_o                      : out std_logic; -- SPI chip select
      adc_sdo_i                       : in  std_logic; -- SPI data out
      adc_reset_o                     : out std_logic; -- SPI reset
              
      -- CDCE specific signals        
      cdce_n_en_o                     : out std_logic; -- SPI chip select
      cdce_sdo_i                      : in  std_logic; -- SPI data out
      cdce_n_reset_o                  : out std_logic;
      cdce_n_pd_o                     : out std_logic;
      cdce_ref_en_o                   : out std_logic;
      cdce_pll_status_i               : in  std_logic;
              
      -- DAC specific signals     
      dac_n_en_o                      : out std_logic; -- SPI chip select
      dac_sdo_i                       : in  std_logic; -- SPI data out
                
      -- Monitoring specific signals  
      mon_n_en_o                      : out std_logic; -- SPI chip select
      mon_sdo_i                       : in  std_logic; -- SPI data out
      mon_n_reset_o                   : out std_logic;
      mon_n_int_i                     : in  std_logic;
                    
      --FMC Present status            
      prsnt_m2c_l_i                   : in  std_logic;
      
      -----------------------------------------
      -- UART pins
      -----------------------------------------
      
      uart_txd_o                      : out std_logic;
      uart_rxd_i                      : in std_logic;
      
      -----------------------------------------
      -- Button pins
      -----------------------------------------
      buttons_i						            : in std_logic_vector(7 downto 0);
      
      -----------------------------------------
      -- User LEDs
      -----------------------------------------
      leds_o							            : out std_logic_vector(7 downto 0)
    );
    end component;
    
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
      variable rand: real;                           -- Random real-number value in range 0 to 1.0
    begin
        uniform(seed1, seed2, rand);                                   -- generate random number
        
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
    
    -- Sim ADC clock gen
    p_sim_adc_clk_gen : process
	begin
		while g_end_simulation = false loop
			wait for c_sim_adc_clk_period/2;
            s_sim_adc_clk <= not s_sim_adc_clk; 
			wait for c_sim_adc_clk_period/2;
            s_sim_adc_clk <= not s_sim_adc_clk; 
		end loop;
		wait;  -- simulation stops here
	end process;
    
    -- Sim ADC clock gen
    p_sim_adc_clk_2x_gen : process
	begin
		while g_end_simulation = false loop
			wait for c_sim_adc_clk2x_period/2;
            s_sim_adc_clk2x <= not s_sim_adc_clk2x; 
			wait for c_sim_adc_clk2x_period/2;
            s_sim_adc_clk2x <= not s_sim_adc_clk2x; 
		end loop;
		wait;  -- simulation stops here
	end process;
    
    p_gen_adc_valid : process
        variable seed1, seed2: positive;               -- Seed values for random generator
    begin
        seed1                                       := 67632;
        seed2                                       := 3234; 
        s_sim_adc_valid                             <= '0';
        -- Wait until reset completion (synch with adc clock domain)
        wait until rst_n_i = '1' and rising_edge(s_sim_adc_clk);
        l_generate_valid: loop 
            gen_valid(0.5, seed1, seed2, s_sim_adc_valid);
            wait until rising_edge(s_sim_adc_clk);
        end loop;                
    end process;
    
    p_gen_adc_data : process
        variable seed1, seed2: positive;               -- Seed values for random generator
    begin
        seed1                                       := 432566;
        seed2                                       := 211; 
        s_sim_adc_cha_data                          <= (others => '0');
        s_sim_adc_chb_data                          <= (others => '0');
        -- Wait until reset completion (synch with adc clock domain)
        wait until rst_n_i = '1' and rising_edge(s_sim_adc_clk);
        l_generate_data: loop 
            gen_data(s_sim_adc_cha_data'length, seed1, seed2, s_sim_adc_cha_data);
            gen_data(s_sim_adc_chb_data'length, seed1, seed2, s_sim_adc_chb_data);          
            wait until rising_edge(s_sim_adc_clk);
        end loop;  
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

    cmp_dut : dbe_bpm_simple_top 
    --generic map
    --(
        --g_interface_mode                        => PIPELINED,
        --g_address_granularity                   => WORD,
        --g_packet_size                           => 32
        --g_sim                                        => 1
    --)      
    port map     
    (       
        sys_clk_p_i						                      => clk_100mhz,
        sys_clk_n_i						                      => clk_100mhz,
            
        sys_rst_button_i                            => '0',
                
        -----------------------------       
        -- External ports       
        -----------------------------       
        --Clock/Data connection to ADC on FMC150 (ADS62P49)
        adc_clk_ab_p_i                              => s_sim_adc_clk,--s_adc_clk_ab_p,
        adc_clk_ab_n_i                              => s_sim_adc_clk,--s_adc_clk_ab_n,
        adc_cha_p_i                                 => s_sim_adc_cha_data,
        adc_cha_n_i                                 => s_sim_adc_cha_data,
        adc_chb_p_i                                 => s_sim_adc_chb_data,
        adc_chb_n_i                                 => s_sim_adc_chb_data,
            
        --Clock/Data connection to DAC on FMC150 (DAC3283)
        dac_dclk_p_o                                => open,
        dac_dclk_n_o                                => open,
        dac_data_p_o                                => open,
        dac_data_n_o                                => open,
        dac_frame_p_o                               => open,
        dac_frame_n_o                               => open,
        txenable_o                                  => open,
                
        --Clock/Trigger connection to FMC150        
        --clk_to_fpga_p_i                             => cc_zero_bit,
        --clk_to_fpga_n_i                             => cc_zero_bit,
        --ext_trigger_p_i                             => cc_zero_bit,
        --ext_trigger_n_i                             => cc_zero_bit,
                
        -- Control signals from/to FMC150       
        --Serial Peripheral Interface (SPI)     
        spi_sclk_o                                  => open, -- Shared SPI clock line
        spi_sdata_o                                 => open, -- Shared SPI data line
                        
        -- ADC specific signals             
        adc_n_en_o                                  => open, -- SPI chip select
        adc_sdo_i                                   => cc_zero_bit, -- SPI data out
        adc_reset_o                                 => open, -- SPI reset
                        
        -- CDCE specific signals                
        cdce_n_en_o                                 => open, -- SPI chip select
        cdce_sdo_i                                  => cc_zero_bit, -- SPI data out
        cdce_n_reset_o                              => open,
        cdce_n_pd_o                                 => open,
        cdce_ref_en_o                               => open,
        cdce_pll_status_i                           => cc_zero_bit,
                        
        -- DAC specific signals             
        dac_n_en_o                                  => open, -- SPI chip select
        dac_sdo_i                                   => cc_zero_bit, -- SPI data out
                        
        -- Monitoring specific signals              
        mon_n_en_o                                  => open, -- SPI chip select
        mon_sdo_i                                   => cc_zero_bit, -- SPI data out
        mon_n_reset_o                               => open,
        mon_n_int_i                                 => cc_zero_bit,
                    
        --FMC Present status            
        prsnt_m2c_l_i                               => cc_zero_bit,
        
        -----------------------------------------
        -- Wishbone Streaming Interface Source
        -----------------------------------------
        uart_txd_o                                  => open,
        uart_rxd_i                                  => '0',
    
        -----------------------------------------
        -- Button pins
        -----------------------------------------
        buttons_i						                        => f_zeros(8),
        
        -----------------------------------------
        -- User LEDs
        -----------------------------------------
        leds_o							                        => open
    );
  

end sim;
