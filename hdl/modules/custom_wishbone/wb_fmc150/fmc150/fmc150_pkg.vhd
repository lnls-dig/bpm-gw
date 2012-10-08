library ieee;
use ieee.std_logic_1164.all;

package fmc150_pkg is
    --------------------------------------------------------------------
    -- Type definition
    --------------------------------------------------------------------
    type cntvalueout_array is array(13 downto 0) of std_logic_vector(4 downto 0);

    type t_fmc150_ctrl_in is record
        -- Common for ADS62P49, CDCE72010, AMC7823
        rdwr                : std_logic;                  
        addr                : std_logic_vector(15 downto 0);
        data                : std_logic_vector(31 downto 0);
            
        -- ADS62P49 
        adc_sdo             : std_logic;
        ads62p49_valid      : std_logic;
            
        -- CDCE72010    
        cdce_sdo            : std_logic;
        cdce_pll_status     : std_logic;
        cdce_external_clock : std_logic;
        cdce72010_valid     : std_logic;
            
        -- DAC3283  
        dac_sdo             : std_logic;
        dac3283_valid       : std_logic;
            
        -- AMC7823  
        mon_sdo             : std_logic;
        mon_n_int           : std_logic;
        amc7823_valid       : std_logic;
    end record t_fmc150_ctrl_in;
    
    type t_fmc150_ctrl_out is record
        -- Common for ADS62P49, CDCE72010, AMC7823
        data                : std_logic_vector(31 downto 0);
        busy                : std_logic;
                
        -- ADS62P49     
        adc_en_n            : std_logic;
        rst_adc             : std_logic;
                
        -- CDCE72010        
        cdce_en_n           : std_logic;
        rst_cdce_n          : std_logic;
        cdce_n_pd           : std_logic;
        cdce_ref_en         : std_logic;
                
        -- DAC3283      
        dac_en_n            : std_logic;
                
        -- AMC7823      
        mon_en_n            : std_logic;
        rst_mon_n           : std_logic;
    end record t_fmc150_ctrl_out;

    --------------------------------------------------------------------
    -- Components
    --------------------------------------------------------------------
    component sin_cos
    port
    (
        clk: in std_logic;
        cosine: out std_logic_vector(15 downto 0);
        sine: out std_logic_vector(15 downto 0);
        phase_out: out std_logic_vector(15 downto 0)
    );
    end component;
    
    component fmc150_adc_if is
    generic (
        g_sim           : integer := 0
    );
    port
    (
        clk_200MHz_i    : in    std_logic;
        clk_100MHz_i    : in    std_logic;
        rst_i           : in    std_logic;
        cha_p_i         : in    std_logic_vector(6 downto 0);
        cha_n_i         : in    std_logic_vector(6 downto 0);
        chb_p_i         : in    std_logic_vector(6 downto 0);
        chb_n_i         : in    std_logic_vector(6 downto 0);
        clk_adc_i       : in    std_logic;
        str_p_i         : in    std_logic;
        str_n_i         : in    std_logic;
        str_o           : out   std_logic;
        cha_data_o      : out   std_logic_vector(13 downto 0);
        chb_data_o      : out   std_logic_vector(13 downto 0);
        delay_update_i  : in    std_logic;
        str_cntvalue_i  : in    std_logic_vector(4 downto 0);
        cha_cntvalue_i  : in    std_logic_vector(4 downto 0);
        chb_cntvalue_i  : in    std_logic_vector(4 downto 0);
        str_cntvalue_o  : out   std_logic_vector(4 downto 0)
    );
    end component fmc150_adc_if;

    component fmc150_dac_if is
    port
    (
        clk_dac_i       : in  std_logic;
        clk_dac_2x_i    : in  std_logic;
        rst_i           : in  std_logic;
        dac_din_c_i     : in  std_logic_vector(15 downto 0);
        dac_din_d_i     : in  std_logic_vector(15 downto 0);
        dac_data_p_o    : out std_logic_vector(7 downto 0);
        dac_data_n_o    : out std_logic_vector(7 downto 0);
        dac_dclk_p_o    : out std_logic;
        dac_dclk_n_o    : out std_logic;
        dac_frame_p_o   : out std_logic;
        dac_frame_n_o   : out std_logic;
        txenable_o      : out std_logic
    );
    end component fmc150_dac_if;

    component fmc150_testbench is
    generic(
        g_sim                   : integer := 0
    );
    port (
        rst                     : in    std_logic;
        clk_100Mhz              : in    std_logic;
        clk_200Mhz              : in    std_logic;
        
        --Clock/Data connection to ADC on FMC150 (ADS62P49)
        adc_clk_ab_p            : in    std_logic;
        adc_clk_ab_n            : in    std_logic;
        adc_cha_p               : in    std_logic_vector(6 downto 0);
        adc_cha_n               : in    std_logic_vector(6 downto 0);
        adc_chb_p               : in    std_logic_vector(6 downto 0);
        adc_chb_n               : in    std_logic_vector(6 downto 0);

        --Clock/Data connection to DAC on FMC150 (DAC3283)
        dac_dclk_p              : out   std_logic;
        dac_dclk_n              : out   std_logic;
        dac_data_p              : out   std_logic_vector(7 downto 0);
        dac_data_n              : out   std_logic_vector(7 downto 0);
        dac_frame_p             : out   std_logic;
        dac_frame_n             : out   std_logic;
        txenable                : out   std_logic;
        
        --Serial Peripheral Interface (SPI)
        spi_sclk                : out   std_logic; -- Shared SPI clock line
        spi_sdata               : out   std_logic; -- Shared SPI data line
    
        --Clock/Trigger connection to FMC150
        clk_to_fpga_p           : in    std_logic;
        clk_to_fpga_n           : in    std_logic;
        ext_trigger_p           : in    std_logic;
        ext_trigger_n           : in    std_logic;
        
        -- Control signals from/to FMC150
        rd_n_wr          : in    std_logic;
        addr             : in    std_logic_vector(15 downto 0);
        idata            : in    std_logic_vector(31 downto 0);
        odata            : out   std_logic_vector(31 downto 0);
        busy             : out   std_logic;
        cdce72010_valid  : in    std_logic;
        ads62p49_valid   : in    std_logic;
        dac3283_valid    : in    std_logic;
        amc7823_valid    : in    std_logic;
        external_clock   : in    std_logic;
        adc_n_en         : out   std_logic;
        adc_sdo          : in    std_logic;
        adc_reset        : out   std_logic;
        cdce_n_en        : out   std_logic;
        cdce_sdo         : in    std_logic;
        cdce_n_reset     : out   std_logic;
        cdce_n_pd        : out   std_logic;
        ref_en           : out   std_logic;
        pll_status       : in    std_logic;
        dac_n_en         : out   std_logic;
        dac_sdo          : in    std_logic;
        mon_n_en         : out   std_logic;
        mon_sdo          : in    std_logic;
        mon_n_reset      : out   std_logic;
        mon_n_int        : in    std_logic;

        --FMC Present status
        prsnt_m2c_l             : in    std_logic;
    
        adc_delay_update_i      : in  std_logic;
        adc_str_cntvaluein_i    : in  std_logic_vector(4 downto 0);
        adc_cha_cntvaluein_i    : in  std_logic_vector(4 downto 0);
        adc_chb_cntvaluein_i    : in  std_logic_vector(4 downto 0);

        adc_str_cntvalueout_o   : out std_logic_vector(4 downto 0);

        adc_dout_o              : out std_logic_vector(31 downto 0);
        clk_adc_o               : out std_logic;
        mmcm_adc_locked_o       : out std_logic
    );
    end component;
    
    --------------------
    -- THIRD-PARTY CODE 
    --------------------
    component fmc150_spi_ctrl is
    generic(
        g_sim                   : integer := 0
    );
    port
    (
        rd_n_wr          : in    std_logic;
        addr             : in    std_logic_vector(15 downto 0);
        idata            : in    std_logic_vector(31 downto 0);
        odata            : out   std_logic_vector(31 downto 0);
        busy             : out   std_logic;
        cdce72010_valid  : in    std_logic;
        ads62p49_valid   : in    std_logic;
        dac3283_valid    : in    std_logic;
        amc7823_valid    : in    std_logic;
        external_clock   : in    std_logic;
        rst              : in    std_logic;
        clk              : in    std_logic;
        spi_sclk         : out   std_logic;
        spi_sdata        : out   std_logic;
        adc_n_en         : out   std_logic;
        adc_sdo          : in    std_logic;
        adc_reset        : out   std_logic;
        cdce_n_en        : out   std_logic;
        cdce_sdo         : in    std_logic;
        cdce_n_reset     : out   std_logic;
        cdce_n_pd        : out   std_logic;
        ref_en           : out   std_logic;
        pll_status       : in    std_logic;
        dac_n_en         : out   std_logic;
        dac_sdo          : in    std_logic;
        mon_n_en         : out   std_logic;
        mon_sdo          : in    std_logic;
        mon_n_reset      : out   std_logic;
        mon_n_int        : in    std_logic;
        prsnt_m2c_l      : in    std_logic
    );
    end component fmc150_spi_ctrl;
    
    component cdce72010_ctrl is
    generic (
      START_ADDR      : std_logic_vector(27 downto 0) := x"0000000";
      STOP_ADDR       : std_logic_vector(27 downto 0) := x"00000FF";
      g_sim           : integer := 0
    );
    port (
      rst             : in  std_logic;
      clk             : in  std_logic;
      -- Sequence interface
      init_ena        : in  std_logic;
      init_done       : out std_logic;
      -- Command Interface
      clk_cmd         : in  std_logic;
      in_cmd_val      : in  std_logic;
      in_cmd          : in  std_logic_vector(63 downto 0);
      out_cmd_val     : out std_logic;
      out_cmd         : out std_logic_vector(63 downto 0);
      in_cmd_busy     : out std_logic;
      -- Direct control
      external_clock  : in  std_logic;
      cdce_n_reset    : out std_logic;
      cdce_n_pd       : out std_logic;
      ref_en          : out std_logic;
      pll_status      : in  std_logic;
      -- SPI control
      spi_n_oe        : out std_logic;
      spi_n_cs        : out std_logic;
      spi_sclk        : out std_logic;
      spi_sdo         : out std_logic;
      spi_sdi         : in  std_logic
    );
    end component;

    component ads62p49_ctrl is
    generic (
      START_ADDR      : std_logic_vector(27 downto 0) := x"0000000";
      STOP_ADDR       : std_logic_vector(27 downto 0) := x"00000FF";
      g_sim           : integer := 0
    );
    port (
      rst             : in  std_logic;
      clk             : in  std_logic;
      -- Sequence interface
      init_ena        : in  std_logic;
      init_done       : out std_logic;
      -- Command Interface
      clk_cmd         : in  std_logic;
      in_cmd_val      : in  std_logic;
      in_cmd          : in  std_logic_vector(63 downto 0);
      out_cmd_val     : out std_logic;
      out_cmd         : out std_logic_vector(63 downto 0);
      in_cmd_busy     : out std_logic;
      -- Direct control
      adc_reset       : out std_logic;
      -- SPI control
      spi_n_oe        : out std_logic;
      spi_n_cs        : out std_logic;
      spi_sclk        : out std_logic;
      spi_sdo         : out std_logic;
      spi_sdi         : in  std_logic
    );
    end component;

    component dac3283_ctrl is
    generic (
      START_ADDR      : std_logic_vector(27 downto 0) := x"0000000";
      STOP_ADDR       : std_logic_vector(27 downto 0) := x"00000FF";
      g_sim           : integer := 0
    );
    port (
      rst             : in  std_logic;
      clk             : in  std_logic;
      -- Sequence interface
      init_ena        : in  std_logic;
      init_done       : out std_logic;
      -- Command Interface
      clk_cmd         : in  std_logic;
      in_cmd_val      : in  std_logic;
      in_cmd          : in  std_logic_vector(63 downto 0);
      out_cmd_val     : out std_logic;
      out_cmd         : out std_logic_vector(63 downto 0);
      in_cmd_busy     : out std_logic;
      -- SPI control
      spi_n_oe        : out std_logic;
      spi_n_cs        : out std_logic;
      spi_sclk        : out std_logic;
      spi_sdo         : out std_logic;
      spi_sdi         : in  std_logic
    );
    end component;

    component amc7823_ctrl is
    generic (
      START_ADDR      : std_logic_vector(27 downto 0) := x"0000000";
      STOP_ADDR       : std_logic_vector(27 downto 0) := x"00000FF";
      g_sim           : integer := 0
    );
    port (
      rst             : in  std_logic;
      clk             : in  std_logic;
      -- Sequence interface
      init_ena        : in  std_logic;
      init_done       : out std_logic;
      -- Command Interface
      clk_cmd         : in  std_logic;
      in_cmd_val      : in  std_logic;
      in_cmd          : in  std_logic_vector(63 downto 0);
      out_cmd_val     : out std_logic;
      out_cmd         : out std_logic_vector(63 downto 0);
      in_cmd_busy     : out std_logic;
      -- Direct control
      mon_n_reset     : out std_logic;
      mon_n_int       : in  std_logic;
      -- SPI control
      spi_n_oe        : out std_logic;
      spi_n_cs        : out std_logic;
      spi_sclk        : out std_logic;
      spi_sdo         : out std_logic;
      spi_sdi         : in  std_logic
    );
    end component;

    component fmc150_stellar_cmd is
    generic
    (
      START_ADDR           : std_logic_vector(27 downto 0) := x"0000000";
      STOP_ADDR            : std_logic_vector(27 downto 0) := x"00000FF";
      g_sim           : integer := 0
    );
    port
    (
      reset                : in  std_logic;
      -- Command Interface
      clk_cmd              : in  std_logic;                     --cmd_in and cmd_out are synchronous to this clock;
      out_cmd              : out std_logic_vector(63 downto 0);
      out_cmd_val          : out std_logic;
      in_cmd               : in  std_logic_vector(63 downto 0);
      in_cmd_val           : in  std_logic;
      -- Register interface
      clk_reg              : in  std_logic;                     --register interface is synchronous to this clock
      out_reg              : out std_logic_vector(31 downto 0); --caries the out register data
      out_reg_val          : out std_logic;                     --the out_reg has valid data  (pulse)
      out_reg_addr         : out std_logic_vector(27 downto 0); --out register address
      in_reg               : in  std_logic_vector(31 downto 0); --requested register data is placed on this bus
      in_reg_val           : in  std_logic;                     --pulse to indicate requested register is valid
      in_reg_req           : out std_logic;                     --pulse to request data
      in_reg_addr          : out std_logic_vector(27 downto 0);  --requested address
      --mailbox interface
      mbx_in_reg           : in  std_logic_vector(31 downto 0); --value of the mailbox to send
      mbx_in_val           : in  std_logic                      --pulse to indicate mailbox is valid
    );
    end component fmc150_stellar_cmd;

    component  pulse2pulse
    port (
      rst      : in  std_logic;
      in_clk   : in  std_logic;
      out_clk  : in  std_logic;
      pulsein  : in  std_logic;
      pulseout : out std_logic;
      inbusy   : out std_logic
    );
    end component;    
    
end fmc150_pkg;
