------------------------------------------------------------------------------
-- Title      : Wishbone FMC150 ADC interface
------------------------------------------------------------------------------
-- Author     : Lucas Maziero Russo
-- Company    : CNPEM LNLS-DIG
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: Wishbone interface with FMC150 ADC board from 4DSP.
-------------------------------------------------------------------------------
-- Copyright (c) 2012 CNPEM
-- Licensed under GNU Lesser General Public License (LGPL) v3.0
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author                Description
-- 2012-10-17  1.0      lucas.russo           Created 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
-- Main Wishbone Definitions
use work.wishbone_pkg.all;
-- Custom Wishbone Modules
use work.custom_wishbone_pkg.all;
-- Wishbone Stream Interface
use work.wb_stream_pkg.all;
-- Register Bank
use work.fmc150_wbgen2_pkg.all;
-- Reset Synch
use work.custom_common_pkg.all;

entity wb_fmc150 is
generic
(
    g_interface_mode                        : t_wishbone_interface_mode      := CLASSIC;
    g_address_granularity                   : t_wishbone_address_granularity := WORD;
    g_packet_size                           : natural := 32;
    g_sim                                   : integer := 0
);
port
(
    rst_n_i                                 : in std_logic;
    clk_sys_i                               : in std_logic;
    --clk_100Mhz_i                            : in std_logic;
    clk_200Mhz_i                            : in std_logic;
    
    -----------------------------
    -- Wishbone signals
    -----------------------------

    wb_adr_i                                : in  std_logic_vector(c_wishbone_address_width-1 downto 0) := (others => '0');
    wb_dat_i                                : in  std_logic_vector(c_wishbone_data_width-1 downto 0) := (others => '0');
    wb_dat_o                                : out std_logic_vector(c_wishbone_data_width-1 downto 0);
    wb_sel_i                                : in  std_logic_vector(c_wishbone_data_width/8-1 downto 0) := (others => '0');
    wb_we_i                                 : in  std_logic := '0';
    wb_cyc_i                                : in  std_logic := '0';
    wb_stb_i                                : in  std_logic := '0';
    wb_ack_o                                : out std_logic;
    wb_err_o                                : out std_logic;
    wb_rty_o                                : out std_logic;
    wb_stall_o                              : out std_logic;
    
    -----------------------------
    -- Simulation Only ports
    -----------------------------
    sim_adc_clk_i                           : in std_logic;
    sim_adc_clk2x_i                         : in std_logic;
                
    sim_adc_cha_data_i                      : in std_logic_vector(13 downto 0);
    sim_adc_chb_data_i                      : in std_logic_vector(13 downto 0);
    sim_adc_data_valid                      : in std_logic;
    
    -----------------------------
    -- External ports
    -----------------------------
    --Clock/Data connection to ADC on FMC150 (ADS62P49)
    adc_clk_ab_p_i                          : in  std_logic;
    adc_clk_ab_n_i                          : in  std_logic;
    adc_cha_p_i                             : in  std_logic_vector(6 downto 0);
    adc_cha_n_i                             : in  std_logic_vector(6 downto 0);
    adc_chb_p_i                             : in  std_logic_vector(6 downto 0);
    adc_chb_n_i                             : in  std_logic_vector(6 downto 0);

    --Clock/Data connection to DAC on FMC150 (DAC3283)
    dac_dclk_p_o                            : out std_logic;
    dac_dclk_n_o                            : out std_logic;
    dac_data_p_o                            : out std_logic_vector(7 downto 0);
    dac_data_n_o                            : out std_logic_vector(7 downto 0);
    dac_frame_p_o                           : out std_logic;
    dac_frame_n_o                           : out std_logic;
    txenable_o                              : out std_logic;
    
    --Clock/Trigger connection to FMC150
    --clk_to_fpga_p_i                         : in  std_logic;
    --clk_to_fpga_n_i                         : in  std_logic;
    --ext_trigger_p_i                         : in  std_logic;
    --ext_trigger_n_i                         : in  std_logic;
    
    -- Control signals from/to FMC150
    --Serial Peripheral Interface (SPI)
    spi_sclk_o                              : out std_logic; -- Shared SPI clock line
    spi_sdata_o                             : out std_logic; -- Shared SPI data line
            
    -- ADC specific signals     
    adc_n_en_o                              : out std_logic; -- SPI chip select
    adc_sdo_i                               : in  std_logic; -- SPI data out
    adc_reset_o                             : out std_logic; -- SPI reset
            
    -- CDCE specific signals        
    cdce_n_en_o                             : out std_logic; -- SPI chip select
    cdce_sdo_i                              : in  std_logic; -- SPI data out
    cdce_n_reset_o                          : out std_logic;
    cdce_n_pd_o                             : out std_logic;
    cdce_ref_en_o                           : out std_logic;
    cdce_pll_status_i                       : in  std_logic;
            
    -- DAC specific signals     
    dac_n_en_o                              : out std_logic; -- SPI chip select
    dac_sdo_i                               : in  std_logic; -- SPI data out
            
    -- Monitoring specific signals      
    mon_n_en_o                              : out std_logic; -- SPI chip select
    mon_sdo_i                               : in  std_logic; -- SPI data out
    mon_n_reset_o                           : out std_logic;
    mon_n_int_i                             : in  std_logic;
                
    --FMC Present status            
    prsnt_m2c_l_i                           : in  std_logic;
    
    -- ADC output signals
    adc_dout_o                              : out std_logic_vector(31 downto 0);
    clk_adc_o                               : out std_logic;
    
    -- Wishbone Streaming Interface Source
    wbs_adr_o                               : out std_logic_vector(c_wbs_address_width-1 downto 0);
    wbs_dat_o                               : out std_logic_vector(c_wbs_data_width-1 downto 0);
    wbs_cyc_o                               : out std_logic;
    wbs_stb_o                               : out std_logic;
    wbs_we_o                                : out std_logic;
    wbs_sel_o                               : out std_logic_vector((c_wbs_data_width/8)-1 downto 0);
    
    wbs_ack_i                               : in std_logic;
    wbs_stall_i                             : in std_logic;
    wbs_err_i                               : in std_logic;
    wbs_rty_i                               : in std_logic
);

end wb_fmc150;

architecture rtl of wb_fmc150 is
    
    -- Constants
    constant c_counter_size                 : natural := f_packet_size(g_packet_size);
    
    -----------------------------------------------------------------------------------------------
    -- IP / user logic interface signals
    -----------------------------------------------------------------------------------------------
    -- wb_fmc150 reg structure
    signal regs_in                          : t_fmc150_out_registers;
    signal regs_out                         : t_fmc150_in_registers;
        
    -- Stream nterface structure    
    signal wbs_stream_out                   : t_wbs_source_out;
    signal wbs_stream_in                    : t_wbs_source_in;
        
    -- FMC 150 testbench signals    
    --signal cdce_pll_status                  : std_logic;
    signal s_mmcm_adc_locked                : std_logic;
        
    signal s_adc_dout                       : std_logic_vector(31 downto 0);
    signal s_clk_adc                        : std_logic;
    signal rst_n_adc                        : std_logic;
    signal s_fmc150_rst                     : std_logic;
        
    -- Streaming control signals    
    signal s_wbs_packet_counter             : unsigned(c_counter_size-1 downto 0);
    signal s_addr                           : std_logic_vector(c_wbs_address_width-1 downto 0);
    signal s_data                           : std_logic_vector(c_wbs_data_width-1 downto 0);
    signal s_dvalid                         : std_logic;
    signal s_sof                            : std_logic;
    signal s_eof                            : std_logic;  
    signal s_error                          : std_logic;
    signal s_bytesel                        : std_logic_vector((c_wbs_data_width/8)-1 downto 0);
    signal s_dreq                           : std_logic;
        
    -- Wishbone adapter structures    
    signal wb_out                           : t_wishbone_slave_out;
    signal wb_in                            : t_wishbone_slave_in;
    
    signal resized_addr                     : std_logic_vector(c_wishbone_address_width-1 downto 0);
    
    -- Components
    -- Bank Register / Wishbone Interface
    component wb_fmc150_port
      port (
        rst_n_i                             : in     std_logic;
        clk_sys_i                           : in     std_logic;
        wb_adr_i                            : in     std_logic_vector(2 downto 0);
        wb_dat_i                            : in     std_logic_vector(31 downto 0);
        wb_dat_o                            : out    std_logic_vector(31 downto 0);
        wb_cyc_i                            : in     std_logic;
        wb_sel_i                            : in     std_logic_vector(3 downto 0);
        wb_stb_i                            : in     std_logic;
        wb_we_i                             : in     std_logic;
        wb_ack_o                            : out    std_logic;
        wb_stall_o                          : out    std_logic;
        --clk_100Mhz_i                        : in     std_logic;
        --clk_wb_i                            : in     std_logic;
        regs_i                              : in     t_fmc150_in_registers;
        regs_o                              : out    t_fmc150_out_registers
      );
    end component;
    
    -- Top FMC150 component
    component fmc150_testbench
    generic(
        g_sim                               : integer := 0
    );                
    port                
    (               
        rst                                 : in  std_logic;
        clk_100Mhz                          : in  std_logic;
        clk_200Mhz                          : in  std_logic;
        adc_clk_ab_p                        : in  std_logic;
        adc_clk_ab_n                        : in  std_logic;
        -- Start Simulation Only!
        sim_adc_clk_i                       : in std_logic;
        sim_adc_clk2x_i                     : in std_logic;
        -- End of Simulation Only!
        adc_cha_p                           : in  std_logic_vector(6 downto 0);
        adc_cha_n                           : in  std_logic_vector(6 downto 0);
        adc_chb_p                           : in  std_logic_vector(6 downto 0);
        adc_chb_n                           : in  std_logic_vector(6 downto 0);
        -- Start Simulation Only!
        sim_adc_cha_data_i                  : in std_logic_vector(13 downto 0);
        sim_adc_chb_data_i                  : in std_logic_vector(13 downto 0);
        -- End of Simulation Only!
        dac_dclk_p                          : out std_logic;
        dac_dclk_n                          : out std_logic;
        dac_data_p                          : out std_logic_vector(7 downto 0);
        dac_data_n                          : out std_logic_vector(7 downto 0);
        dac_frame_p                         : out std_logic;
        dac_frame_n                         : out std_logic;
        txenable                            : out std_logic;
        --clk_to_fpga_p                       : in  std_logic;
        --clk_to_fpga_n                       : in  std_logic;
        --ext_trigger_p                       : in  std_logic;
        --ext_trigger_n                       : in  std_logic;
        spi_sclk                            : out std_logic;
        spi_sdata                           : out std_logic;
        rd_n_wr                             : in    std_logic;
        addr                                : in    std_logic_vector(15 downto 0);
        idata                               : in    std_logic_vector(31 downto 0);
        odata                               : out   std_logic_vector(31 downto 0);
        busy                                : out   std_logic;
        cdce72010_valid                     : in    std_logic;
        ads62p49_valid                      : in    std_logic;
        dac3283_valid                       : in    std_logic;
        amc7823_valid                       : in    std_logic;
        external_clock                      : in    std_logic;
        adc_n_en                            : out   std_logic;
        adc_sdo                             : in    std_logic;
        adc_reset                           : out   std_logic;
        cdce_n_en                           : out   std_logic;
        cdce_sdo                            : in    std_logic;
        cdce_n_reset                        : out   std_logic;
        cdce_n_pd                           : out   std_logic;
        ref_en                              : out   std_logic;
        pll_status                          : in    std_logic;
        dac_n_en                            : out   std_logic;
        dac_sdo                             : in    std_logic;
        mon_n_en                            : out   std_logic;
        mon_sdo                             : in    std_logic;
        mon_n_reset                         : out   std_logic;
        mon_n_int                           : in    std_logic;
        prsnt_m2c_l                         : in  std_logic;
        adc_delay_update_i                  : in  std_logic;
        adc_str_cntvaluein_i                : in  std_logic_vector(4 downto 0);
        adc_cha_cntvaluein_i                : in  std_logic_vector(4 downto 0);
        adc_chb_cntvaluein_i                : in  std_logic_vector(4 downto 0);
        adc_str_cntvalueout_o               : out std_logic_vector(4 downto 0);
        adc_dout_o                          : out std_logic_vector(31 downto 0);
        clk_adc_o                           : out std_logic;
        mmcm_adc_locked_o                   : out std_logic
    );
    end component;


    
begin
    -----------------------------------------------------------------------------------------------
    -- BUS / IP interface
    ----------------------------------------------------------------------------------------------- 

    cmp_fmc150_testbench: fmc150_testbench
    generic map(
        g_sim                               => g_sim
    )           
    port map            
    (           
        rst                                 => s_fmc150_rst,
        --clk_100Mhz                          => clk_100Mhz_i,
        clk_100Mhz                          => clk_sys_i,
        clk_200Mhz                          => clk_200Mhz_i,
            
        adc_clk_ab_p                        => adc_clk_ab_p_i,
        adc_clk_ab_n                        => adc_clk_ab_n_i,
        -- Start Simulation Only!
        sim_adc_clk_i                       => sim_adc_clk_i,  
        sim_adc_clk2x_i                     => sim_adc_clk2x_i,
        -- End of Simulation Only!
        adc_cha_p                           => adc_cha_p_i,   
        adc_cha_n                           => adc_cha_n_i,   
        adc_chb_p                           => adc_chb_p_i,   
        adc_chb_n                           => adc_chb_n_i, 
        -- Start Simulation Only!
        sim_adc_cha_data_i                  => sim_adc_cha_data_i,
        sim_adc_chb_data_i                  => sim_adc_chb_data_i,
        -- End of Simulation Only!  
        dac_dclk_p                          => dac_dclk_p_o, 
        dac_dclk_n                          => dac_dclk_n_o, 
        dac_data_p                          => dac_data_p_o, 
        dac_data_n                          => dac_data_n_o, 
        dac_frame_p                         => dac_frame_p_o,
        dac_frame_n                         => dac_frame_n_o,
        txenable                            => txenable_o,   
        --clk_to_fpga_p                       => clk_to_fpga_p_i,
        --clk_to_fpga_n                       => clk_to_fpga_n_i,
        --ext_trigger_p                       => ext_trigger_p_i,
        --ext_trigger_n                       => ext_trigger_n_i,
        spi_sclk                            => spi_sclk_o,    
        spi_sdata                           => spi_sdata_o,   
        adc_n_en                            => adc_n_en_o,    
        adc_sdo                             => adc_sdo_i,     
        adc_reset                           => adc_reset_o,   
        cdce_n_en                           => cdce_n_en_o,   
        cdce_sdo                            => cdce_sdo_i,    
        cdce_n_reset                        => cdce_n_reset_o,
        cdce_n_pd                           => cdce_n_pd_o,  
        ref_en                              => cdce_ref_en_o, 
        dac_n_en                            => dac_n_en_o,    
        dac_sdo                             => dac_sdo_i,     
        mon_n_en                            => mon_n_en_o,    
        mon_sdo                             => mon_sdo_i,     
        mon_n_reset                         => mon_n_reset_o, 
        mon_n_int                           => mon_n_int_i,   
            
        pll_status                          => cdce_pll_status_i, --cdce_pll_status,--regs_out.flgs_out_pll_status_i,
        mmcm_adc_locked_o                   => s_mmcm_adc_locked,--regs_out.flgs_out_adc_clk_locked_i,
        odata                               => regs_out.data_out_i,--s_odata,
        busy                                => regs_out.flgs_out_spi_busy_i,--s_busy,
        prsnt_m2c_l                         => prsnt_m2c_l_i,--regs_out.flgs_out_fmc_prst_i,--prsnt_m2c_l,
                  
        rd_n_wr                             => regs_in.flgs_in_spi_rw_o, --s_registers(FLAGS_IN_0)(FLAGS_IN_0_SPI_RW),
        addr                                => regs_in.addr_o, --s_registers(ADDR)(15 downto 0),
        idata                               => regs_in.data_in_o, --s_registers(DATAIN),
        cdce72010_valid                     => regs_in.cs_cdce72010_o,--s_registers(CHIPSELECT)(CHIPSELECT_CDCE72010),
        ads62p49_valid                      => regs_in.cs_ads62p49_o, --s_registers(CHIPSELECT)(CHIPSELECT_ADS62P49),
        dac3283_valid                       => regs_in.cs_dac3283_o, --s_registers(CHIPSELECT)(CHIPSELECT_DAC3283),
        amc7823_valid                       => regs_in.cs_amc7823_o, --s_registers(CHIPSELECT)(CHIPSELECT_AMC7823),
        external_clock                      => regs_in.flgs_in_ext_clk_o, --s_registers(FLAGS_IN_0)(FLAGS_IN_0_EXTERNAL_CLOCK),
        adc_delay_update_i                  => regs_in.flgs_pulse_o,--s_adc_delay_update,
        adc_str_cntvaluein_i                => regs_in.adc_dly_str_o,--s_registers(ADC_DELAY)(4 downto 0),
        adc_cha_cntvaluein_i                => regs_in.adc_dly_cha_o,--s_registers(ADC_DELAY)(12 downto 8),
        adc_chb_cntvaluein_i                => regs_in.adc_dly_chb_o,--s_registers(ADC_DELAY)(20 downto 16),
        adc_str_cntvalueout_o               => open,
            
        adc_dout_o                          => s_adc_dout,
        clk_adc_o                           => s_clk_adc
    );
    
    -- Export external signals to bus register bank
    regs_out.flgs_out_pll_status_i          <= cdce_pll_status_i;
    regs_out.flgs_out_adc_clk_locked_i      <= s_mmcm_adc_locked;
    regs_out.flgs_out_fmc_prst_i            <= prsnt_m2c_l_i;
    
    -- Connect to output ports
    adc_dout_o                              <= s_adc_dout;
    clk_adc_o                               <= s_clk_adc;
    
    -- Generate reset for fmc150_testbench module
    s_fmc150_rst                            <= not rst_n_i;
    
    --regs_out.flgs_out_pll_status_i                  <= cdce_pll_status;
    regs_out.flgs_out_adc_clk_locked_i      <= s_mmcm_adc_locked;
    
    -- Pipelined <--> Classic cycles / Word <--> Byte address granularity
    -- conversion
    cmp_adapter : wb_slave_adapter
    generic map (
        g_master_use_struct                 => true,
        g_master_mode                       => PIPELINED,
        g_master_granularity                => WORD,
        g_slave_use_struct                  => false,
        g_slave_mode                        => g_interface_mode,
        g_slave_granularity                 => g_address_granularity
    )
    port map (  
        clk_sys_i                           => clk_sys_i,
        rst_n_i                             => rst_n_i,
        master_i                            => wb_out,
        master_o                            => wb_in,
        sl_adr_i                            => resized_addr,--wb_adr_i,
        sl_dat_i                            => wb_dat_i,
        sl_sel_i                            => wb_sel_i,
        sl_cyc_i                            => wb_cyc_i,
        sl_stb_i                            => wb_stb_i,
        sl_we_i                             => wb_we_i,
        sl_dat_o                            => wb_dat_o,
        sl_ack_o                            => wb_ack_o,
        sl_stall_o                          => wb_stall_o
    );
    
    -- Decode only the LSB bits. In this case, at most, 5 LSB must be decoded
    -- (if byte addresses) or 3 LSB (if word addressed). We have to consider
    -- the biggest value in order not to mismatch register addresses.
    -- See wb_fmc150_port.vhd for register bank addresses.
    resized_addr(4 downto 0)                <= wb_adr_i(4 downto 0);
    resized_addr(c_wishbone_address_width-1 downto 5) 
                                            <= (others => '0');
    
    -- Register Bank / Wishbone Interface
    cmp_wb_fmc150_port : wb_fmc150_port 
    port map (
        rst_n_i                             => rst_n_i,
        clk_sys_i                           => clk_sys_i,
        wb_adr_i                            => wb_in.adr(2 downto 0),
        wb_dat_i                            => wb_in.dat,
        wb_dat_o                            => wb_out.dat,
        wb_cyc_i                            => wb_in.cyc,
        wb_sel_i                            => wb_in.sel,
        wb_stb_i                            => wb_in.stb,
        wb_we_i                             => wb_in.we,
        wb_ack_o                            => wb_out.ack,
        wb_stall_o                          => wb_out.stall,
        --clk_100Mhz_i                        => clk_100Mhz_i,
        --clk_wb_i                            => clk_sys_i,
        regs_i                              => regs_out,
        regs_o                              => regs_in
    );
    
    -- Reset synchronization with ADC clock domain
    cmp_reset_adc_synch : reset_synch
    port map(
      clk_i     		                        => s_clk_adc,
      arst_n_i		                          => rst_n_i,
      rst_n_o      		                      => rst_n_adc
    );
    
    -- This stream source is in ADC clock domain
    cmp_wb_source_if : xwb_stream_source
    port map(
        clk_i                               => s_clk_adc,
        --rst_n_i                             => rst_n_i,
        rst_n_i                             => rst_n_adc,
  
        -- Wishbone Fabric Interface I/O
        src_i                               => wbs_stream_in,
        src_o                               => wbs_stream_out,
        
        -- Decoded & buffered logic
        addr_i                              => s_addr,  
        data_i                              => s_data,  
        dvalid_i                            => s_dvalid,
        sof_i                               => s_sof,    
        eof_i                               => s_eof,    
        error_i                             => s_error, 
        -- For now, just pick the LSB bit of s_bytesel
        bytesel_i                           => s_bytesel,
        dreq_o                              => s_dreq   
    );
    
    -- Write always to addr 0
    s_addr                                  <= (others => '0');     
    
    -- Simulation / Syntesis Only consructs. Is there a better way to do it?
    s_data                                  <= s_adc_dout(c_wbs_data_width-1 downto 0);
    
    gen_stream_valid : if (g_sim = 0) generate
        s_dvalid                            <= cdce_pll_status_i and s_mmcm_adc_locked;
     end generate; 
     
    gen_stream_valid_sim : if (g_sim = 1) generate
        s_dvalid                            <= sim_adc_data_valid;
    end generate; 

    -- generate SOF and EOF signals
    p_gen_sof_eof : process(s_clk_adc, rst_n_adc)
    begin
        if rst_n_adc = '0' then
            --s_sof <= '0';
            --s_eof <= '0';
            s_wbs_packet_counter <= (others => '0');
        elsif rising_edge(s_clk_adc) then           
            -- Increment counter if data is valid
            if s_dvalid = '1' then
                s_wbs_packet_counter <= s_wbs_packet_counter + 1;
            end if;
        end if;   
    end process;
    
    -- Generate SOF and EOF signals based on counter
    s_sof <= '1' when s_wbs_packet_counter = to_unsigned(0, c_counter_size) else '0';
    s_eof <= '1' when s_wbs_packet_counter = g_packet_size-1 else '0';
    
    s_error                                 <= '0';
    s_bytesel                               <= (others => '1');
          
    wbs_adr_o                               <= wbs_stream_out.adr;
    wbs_dat_o                               <= wbs_stream_out.dat;
    wbs_cyc_o                               <= wbs_stream_out.cyc;
    wbs_stb_o                               <= wbs_stream_out.cyc;
    wbs_we_o                                <= wbs_stream_out.we;
    wbs_sel_o                               <= wbs_stream_out.sel;
    wb_err_o                                <= '0';
    wb_rty_o                                <= '0';
              
    wbs_stream_in.ack                       <= wbs_ack_i;  
    wbs_stream_in.stall                     <= wbs_stall_i;
    wbs_stream_in.err                       <= wbs_err_i;  
    wbs_stream_in.rty                       <= wbs_rty_i;  
end rtl;
