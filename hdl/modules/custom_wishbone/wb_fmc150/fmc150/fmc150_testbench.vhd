library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

library work;
use work.fmc150_pkg.all;

entity fmc150_testbench is
generic(
    g_sim                   : integer := 0
);
port
(
    rst                     : in  std_logic;
    clk_100Mhz              : in  std_logic;
    clk_200Mhz              : in  std_logic;
    adc_clk_ab_p            : in  std_logic;
    adc_clk_ab_n            : in  std_logic;
    -- Start Simulation Only!
    sim_adc_clk_i           : in std_logic;
    sim_adc_clk2x_i         : in std_logic;
    -- End of Simulation Only!
    adc_cha_p               : in  std_logic_vector(6 downto 0);
    adc_cha_n               : in  std_logic_vector(6 downto 0);
    adc_chb_p               : in  std_logic_vector(6 downto 0);
    adc_chb_n               : in  std_logic_vector(6 downto 0);
    -- Start Simulation Only!
    sim_adc_cha_data_i      : in std_logic_vector(13 downto 0);
    sim_adc_chb_data_i      : in std_logic_vector(13 downto 0);
    -- End of Simulation Only!
    dac_dclk_p              : out std_logic;
    dac_dclk_n              : out std_logic;
    dac_data_p              : out std_logic_vector(7 downto 0);
    dac_data_n              : out std_logic_vector(7 downto 0);
    dac_frame_p             : out std_logic;
    dac_frame_n             : out std_logic;
    txenable                : out std_logic;
    --clk_to_fpga_p           : in  std_logic;
    --clk_to_fpga_n           : in  std_logic;
    --ext_trigger_p           : in  std_logic;
    --ext_trigger_n           : in  std_logic;
    spi_sclk                : out std_logic;
    spi_sdata               : out std_logic;
    rd_n_wr                 : in    std_logic;
    addr                    : in    std_logic_vector(15 downto 0);
    idata                   : in    std_logic_vector(31 downto 0);
    odata                   : out   std_logic_vector(31 downto 0);
    busy                    : out   std_logic;
    cdce72010_valid         : in    std_logic;
    ads62p49_valid          : in    std_logic;
    dac3283_valid           : in    std_logic;
    amc7823_valid           : in    std_logic;
    external_clock          : in    std_logic;
    adc_n_en                : out   std_logic;
    adc_sdo                 : in    std_logic;
    adc_reset               : out   std_logic;
    cdce_n_en               : out   std_logic;
    cdce_sdo                : in    std_logic;
    cdce_n_reset            : out   std_logic;
    cdce_n_pd               : out   std_logic;
    ref_en                  : out   std_logic;
    pll_status              : in    std_logic;
    dac_n_en                : out   std_logic;
    dac_sdo                 : in    std_logic;
    mon_n_en                : out   std_logic;
    mon_sdo                 : in    std_logic;
    mon_n_reset             : out   std_logic;
    mon_n_int               : in    std_logic;
    prsnt_m2c_l             : in  std_logic;
    adc_delay_update_i      : in  std_logic;
    adc_str_cntvaluein_i    : in  std_logic_vector(4 downto 0);
    adc_cha_cntvaluein_i    : in  std_logic_vector(4 downto 0);
    adc_chb_cntvaluein_i    : in  std_logic_vector(4 downto 0);
    adc_str_cntvalueout_o   : out std_logic_vector(4 downto 0);
    adc_dout_o              : out std_logic_vector(31 downto 0);
    clk_adc_o               : out std_logic;
    mmcm_adc_locked_o       : out std_logic

);
end fmc150_testbench;


architecture rtl of fmc150_testbench is

    ----------------------------------------------------------------------------------------------------
    -- Constant declaration
    ----------------------------------------------------------------------------------------------------
    constant ADC_STR_IDELAY : integer := 0; -- Initial number of delay taps on ADC clock input
    constant ADC_CHA_IDELAY : integer := 0; -- Initial number of delay taps on ADC data port A
    constant ADC_CHB_IDELAY : integer := 0; -- Initial number of delay taps on ADC data port B

    ----------------------------------------------------------------------------------------------------
    -- Signal declaration
    ----------------------------------------------------------------------------------------------------
    signal clk_ab_l             : std_logic;
    signal clk_ab_dly           : std_logic;
       
    signal adc_cha_ddr          : std_logic_vector(6 downto 0);  -- Double Data Rate
    signal adc_cha_ddr_dly      : std_logic_vector(6 downto 0);  -- Double Data Rate, Delayed
    signal adc_cha_sdr          : std_logic_vector(13 downto 0); -- Single Data Rate
       
    signal adc_chb_ddr          : std_logic_vector(6 downto 0);  -- Double Data Rate
    signal adc_chb_ddr_dly      : std_logic_vector(6 downto 0);  -- Double Data Rate, Delayed
    signal adc_chb_sdr          : std_logic_vector(13 downto 0); -- Single Data Rate
       
    signal adc_dout_a           : std_logic_vector(15 downto 0); -- Single Data Rate, Extended to 16-bit
    signal adc_dout_b           : std_logic_vector(15 downto 0); -- Single Data Rate, Extended to 16-bit
    
    signal adc_str              : std_logic;
    signal clk_adc              : std_logic;
    signal mmcm_adc_locked      : std_logic;

    signal fmc150_ctrl_in       : t_fmc150_ctrl_in;
    signal fmc150_ctrl_out      : t_fmc150_ctrl_out;
    
    signal clk_to_fpga          : std_logic;

    signal clk_adc_2x           : std_logic;
    signal dac_din_c            : std_logic_vector(15 downto 0);
    signal dac_din_d            : std_logic_vector(15 downto 0);
    
    signal adc_str_fbin, adc_str_out, adc_str_2x_out, adc_str_fbout    : std_logic;
    
    -- simulation only
    signal toggle_ff_q          : std_logic := '0';
    signal toggle_ff_d          : std_logic := '0';
begin

    -- Synthesis Only
    gen_clk : if (g_sim = 0) generate
        -- I/O delay control
        cmp_idelayctrl : idelayctrl
        port map
        (
            rst    => rst,
            refclk => clk_200MHz,
            rdy    => open
        );

        -- ADC Clock PLL
        cmp_mmcm_adc : MMCM_ADV
        generic map
        (
            BANDWIDTH            => "OPTIMIZED",
            CLKOUT4_CASCADE      => FALSE,
            CLOCK_HOLD           => FALSE,
            COMPENSATION         => "ZHOLD",
            STARTUP_WAIT         => FALSE,
            DIVCLK_DIVIDE        => 1,
            --CLKFBOUT_MULT_F      => 16.000,
            CLKFBOUT_MULT_F      => 8.000,
            CLKFBOUT_PHASE       => 0.000,
            CLKFBOUT_USE_FINE_PS => FALSE,
            --CLKOUT0_DIVIDE_F     => 16.000,
            CLKOUT0_DIVIDE_F     => 8.000,
            CLKOUT0_PHASE        => 0.000,
            CLKOUT0_DUTY_CYCLE   => 0.500,
            CLKOUT0_USE_FINE_PS  => FALSE,
            --CLKOUT1_DIVIDE       => 8,
            CLKOUT1_DIVIDE       => 4,
            CLKOUT1_PHASE        => 0.000,
            CLKOUT1_DUTY_CYCLE   => 0.500,
            CLKOUT1_USE_FINE_PS  => FALSE,
            -- 61.44 MHZ input clock
            --CLKIN1_PERIOD        => 16.276,
            -- 122.88 MHZ input clock
            CLKIN1_PERIOD        => 8.138,
            REF_JITTER1          => 0.010
        )
        port map
        (
            -- Output clocks
            CLKFBOUT            => adc_str_fbout,
            CLKFBOUTB           => open,
            CLKOUT0             => adc_str_out,
            CLKOUT0B            => open,
            CLKOUT1             => adc_str_2x_out,
            CLKOUT1B            => open,
            CLKOUT2             => open,
            CLKOUT2B            => open,
            CLKOUT3             => open,
            CLKOUT3B            => open,
            CLKOUT4             => open,
            CLKOUT5             => open,
            CLKOUT6             => open,
            -- Input clock control
            CLKFBIN             => adc_str_fbin,
            CLKIN1              => adc_str,
            CLKIN2              => '0',
            -- Tied to always select the primary input clock
            CLKINSEL            => '1',
            -- Ports for dynamic reconfiguration
            DADDR               => (others => '0'),
            DCLK                => '0',
            DEN                 => '0',
            DI                  => (others => '0'),
            DO                  => open,
            DRDY                => open,
            DWE                 => '0',
            -- Ports for dynamic phase shift
            PSCLK               => '0',
            PSEN                => '0',
            PSINCDEC            => '0',
            PSDONE              => open,
            -- Other control and status signals
            LOCKED              => mmcm_adc_locked,
            CLKINSTOPPED        => open,
            CLKFBSTOPPED        => open,
            PWRDWN              => '0',
            RST                 => rst
        );
        
        -- Global clock buffers for "cmp_mmcm_adc" instance
        cmp_clkf_bufg : BUFG
        port map
        (
            O => adc_str_fbin,
            I => adc_str_fbout
        );
        
        cmp_adc_str_out_bufg : BUFG
        port map
        (
            O => clk_adc,
            I => adc_str_out
        );
        
        cmp_adc_str_2x_out_bufg : BUFG
        port map
        (
            O => clk_adc_2x,
            I => adc_str_2x_out
        );
    end generate;
    
    -- Double clock circuit. only for SIMULATION!
    gen_clk_sim : if (g_sim = 1) generate
        clk_adc <= sim_adc_clk_i;
        clk_adc_2x <= sim_adc_clk2x_i;
    end generate;
    
    clk_adc_o <= clk_adc;--adc_str;
    
    -- ADC Interface
    cmp_adc_if : fmc150_adc_if
    generic map(
        g_sim               => g_sim
    )
    port map
    (
        clk_200MHz_i        => clk_200MHz,
        clk_100MHz_i        => clk_100MHz,
        rst_i               => mmcm_adc_locked,
        str_p_i             => adc_clk_ab_p,
        str_n_i             => adc_clk_ab_n,
        cha_p_i             => adc_cha_p,
        cha_n_i             => adc_cha_n,
        chb_p_i             => adc_chb_p,
        chb_n_i             => adc_chb_n,
        cha_data_o          => adc_cha_sdr,
        chb_data_o          => adc_chb_sdr,
        str_o               => adc_str,
		-- Not used for now. Should it be removed?
        clk_adc_i           => adc_str,--clk_adc,
        delay_update_i      => adc_delay_update_i,
        str_cntvalue_i      => adc_str_cntvaluein_i,
        cha_cntvalue_i      => adc_cha_cntvaluein_i,
        chb_cntvalue_i      => adc_chb_cntvaluein_i,
        str_cntvalue_o      => adc_str_cntvalueout_o
    );
    
-- Extend to 16-bit and register ADC data output
--    p_extend_adc_output : process (clk_adc)
--    begin
--        if (rising_edge(clk_adc)) then
    gen_data : if (g_sim = 0) generate
        p_extend_adc_output : process (adc_str)
        begin
            if (rising_edge(adc_str)) then
                -- Left justify the data of both channels on 16-bits
                adc_dout_a <= adc_cha_sdr(13) & adc_cha_sdr(13) & adc_cha_sdr;
                adc_dout_b <= adc_chb_sdr(13) & adc_chb_sdr(13) & adc_chb_sdr;

    --            adc_dout_a <= std_logic_vector(unsigned(adc_dout_a)+1);
    --            adc_dout_b <= std_logic_vector(unsigned(adc_dout_b)-1);
            end if;
        end process;
    end generate;
    
    gen_data_sim : if (g_sim = 1) generate
        adc_dout_a <= sim_adc_cha_data_i(13) & sim_adc_cha_data_i(13) & sim_adc_cha_data_i;
        adc_dout_b <= sim_adc_chb_data_i(13) & sim_adc_chb_data_i(13) & sim_adc_chb_data_i;
    end generate;  
    
    adc_dout_o <= adc_dout_a & adc_dout_b;
    --adc_dout_o <= dac_din_c & dac_din_d;
         
    -- DAC Interface
    cmp_dac_if : fmc150_dac_if
    port map
    (
        rst_i           => mmcm_adc_locked,
        clk_dac_i       => clk_adc,
        clk_dac_2x_i    => clk_adc_2x,
        dac_din_c_i     => dac_din_c,
        dac_din_d_i     => dac_din_d,
        dac_data_p_o    => dac_data_p,
        dac_data_n_o    => dac_data_n,
        dac_dclk_p_o    => dac_dclk_p,
        dac_dclk_n_o    => dac_dclk_n,
        dac_frame_p_o   => dac_frame_p,
        dac_frame_n_o   => dac_frame_n,
        txenable_o      => txenable
    );
    
    mmcm_adc_locked_o <= mmcm_adc_locked;

    -- Reference signal generation (need external netlist file)
--    cmp_sin_cos : sin_cos
--    port map
--    (
--        clk => clk_adc,
--        cosine => dac_din_c,
--        sine => dac_din_d,
--        phase_out => open
--    );
    
    -- FMC150 control (SPI and direct signals)
    cmp_fmc150_ctrl : fmc150_spi_ctrl
    generic map(
      g_sim                   => g_sim
    )
    port map
    (
        rst             => rst,
        clk             => clk_100MHz,
        rd_n_wr         => rd_n_wr,
        addr            => addr,
        idata           => idata,
        odata           => odata,
        busy            => busy,
        cdce72010_valid => cdce72010_valid,
        ads62p49_valid  => ads62p49_valid,
        dac3283_valid   => dac3283_valid,
        amc7823_valid   => amc7823_valid,
        external_clock  => external_clock,
        adc_n_en        => adc_n_en,
        adc_sdo         => adc_sdo,
        adc_reset       => adc_reset,
        cdce_n_en       => cdce_n_en,
        cdce_sdo        => cdce_sdo,
        cdce_n_reset    => cdce_n_reset,
        cdce_n_pd       => cdce_n_pd,
        ref_en          => ref_en,
        pll_status      => pll_status,
        dac_n_en        => dac_n_en,
        dac_sdo         => dac_sdo,
        mon_n_en        => mon_n_en,
        mon_sdo         => mon_sdo,
        mon_n_reset     => mon_n_reset,
        mon_n_int       => mon_n_int,
        spi_sclk        => spi_sclk,
        spi_sdata       => spi_sdata,
        prsnt_m2c_l     => prsnt_m2c_l
    );

end rtl;
