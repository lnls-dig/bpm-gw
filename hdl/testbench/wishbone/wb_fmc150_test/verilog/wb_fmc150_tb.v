`include "defines.v"
`include "timescale.v"
`include "wishbone_test_master.v"
`include "xfmc150_regs_regs.vh"

module wb_fmc150_tb;

  // Clocks
  reg s_clk_sys = 0, s_clk_adc = 0, s_clk_adc2x = 0;
  reg s_clk_100mhz = 0, s_clk_200mhz = 0;
  // Reset
  reg rstn = 0;
  
  // Data generation
  reg [`ADC_DATA_WIDTH-1:0] adc_cha_data;
  reg [`ADC_DATA_WIDTH-1:0] adc_chb_data;
  reg adc_valid;
  
  // Local definitions
  localparam adc_data_max = (2**`ADC_DATA_WIDTH)-1;
  localparam adc_gen_threshold = 100;
  
  // Internal registers
  reg zero_bit = 1'b0;
  
  // Enable verbose mode
  verbose(1);
  // Enable monitor bus
  monitor_bus(1);
  
  // Clock and Reset
  clk_rst cmp_rst(
    .clk_sys_o(s_clk_sys),
    .clk_adc_o(s_clk_adc),
    .clk_adc2x_o(s_clk_adc2x),
    .clk_100mhz_o(s_clk_100mhz),
    .clk_200mhz_o(s_clk_200mhz),
    .rstn_o(rstn)
  );
  
  // Acessible register from WB_TEST_MASTER
  //reg [`WB_ADDRESS_BUS_WIDTH - 1 : 0] wb_addr = 0;
  //reg [`WB_DATA_BUS_WIDTH - 1 : 0]    wb_data_o = 0;
  //reg [`WB_BWSEL_WIDTH - 1 : 0]       wb_bwsel = 0;
  //wire [`WB_DATA_BUS_WIDTH -1 : 0]    wb_data_i;
  //wire                                wb_ack_i;
  //reg 	                              wb_cyc = 0;
  //reg 	                              wb_stb = 0;
  //reg 	                              wb_we = 0;
  //reg 	                              wb_rst = 0;
  //reg 	                              wb_clk = 1;
  
  // Wiswhbone Master
  WB_TEST_MASTER cmp_wb_master();
  
  // FMC150 device under test
  wb_fmc150  #(.g_sim(1)) cmp_wb_fmc150_dut
  (
    .rst_n_i                                  (rstn),                  
    .clk_sys_i                                (s_clk_sys),                   
    .clk_100Mhz_i                             (s_clk_100mhz),                
    .clk_200Mhz_i                             (s_clk_200mhz),               
    
    //-----------------------------
    //-- Wishbone signals
    //-----------------------------

    .wb_adr_i                                 (wb_addr),  //: in  std_logic_vector(c_wishbone_address_width-1 downto 0) := (others => '0');
    .wb_dat_i                                 (wb_data_o),  //: in  std_logic_vector(c_wishbone_data_width-1 downto 0) := (others => '0');
    .wb_dat_o                                 (wb_data_i),  //: out std_logic_vector(c_wishbone_data_width-1 downto 0);
    .wb_sel_i                                 (wb_bwsel),  //: in  std_logic_vector(c_wishbone_data_width/8-1 downto 0) := (others => '0');
    .wb_we_i                                  (wb_we),  //: in  std_logic := '0';
    .wb_cyc_i                                 (wb_cyc),  //: in  std_logic := '0';
    .wb_stb_i                                 (wb_stb),  //: in  std_logic := '0';
    .wb_ack_o                                 (wb_ack_i),  //: out std_logic;
    .wb_err_o                                 (),  //: out std_logic;
    .wb_rty_o                                 (),  //: out std_logic;
    .wb_stall_o                               (),  //: out std_logic;
    
    //-----------------------------
    //-- Simulation Only ports
    //-----------------------------
    .sim_adc_clk_i                            (s_clk_adc),   //: in std_logic;
    .sim_adc_clk2x_i                          (s_clk_adc2x),   //: in std_logic;
  
    .sim_adc_cha_data_i                       (adc_data_gen(adc_data_max)),   //: in std_logic_vector(13 downto 0);
    .sim_adc_chb_data_i                       (adc_data_gen(adc_data_max)),   //: in std_logic_vector(13 downto 0);
    .sim_adc_data_valid                       (adc_data_valid_gen(adc_gen_threshold)),   //: in std_logic;
    
    //-----------------------------
    //-- External ports
    //-----------------------------
    //--Clock/Data connection to ADC on FMC150 (ADS62P49)
    .adc_clk_ab_p_i                           (zero_bit),    //: in  std_logic;
    .adc_clk_ab_n_i                           (zero_bit),    //: in  std_logic;
    .adc_cha_p_i                              (zero_bit),    //: in  std_logic_vector(6 downto 0);
    .adc_cha_n_i                              (zero_bit),    //: in  std_logic_vector(6 downto 0);
    .adc_chb_p_i                              (zero_bit),    //: in  std_logic_vector(6 downto 0);
    .adc_chb_n_i                              (zero_bit),    //: in  std_logic_vector(6 downto 0);

    //--Clock/Data connection to DAC on FMC150 (DAC3283)
    .dac_dclk_p_o                             (),     //: out std_logic;
    .dac_dclk_n_o                             (),     //: out std_logic;
    .dac_data_p_o                             (),     //: out std_logic_vector(7 downto 0);
    .dac_data_n_o                             (),     //: out std_logic_vector(7 downto 0);
    .dac_frame_p_o                            (),     //: out std_logic;
    .dac_frame_n_o                            (),     //: out std_logic;
    .txenable_o                               (),     //: out std_logic;
    
    //--Clock/Trigger connection to FMC150
    //--clk_to_fpga_p_i                         : in  std_logic;
    //--clk_to_fpga_n_i                         : in  std_logic;
    //--ext_trigger_p_i                         : in  std_logic;
    //--ext_trigger_n_i                         : in  std_logic;
    
    //-- Control signals from/to FMC150
    //--Serial Peripheral Interface (SPI)
    .spi_sclk_o                               (),    // : out std_logic; -- Shared SPI clock line
    .spi_sdata_o                              (),    // : out std_logic; -- Shared SPI data line
                                            
    //-- ADC specific signals               
    .adc_n_en_o                               (),    // : out std_logic; -- SPI chip select
    .adc_sdo_i                                (zero_bit),    // : in  std_logic; -- SPI data out
    .adc_reset_o                              (),    // : out std_logic; -- SPI reset
                                                  
    //-- CDCE specific signals                
    .cdce_n_en_o                              (),    // : out std_logic; -- SPI chip select
    .cdce_sdo_i                               (zero_bit),    // : in  std_logic; -- SPI data out
    .cdce_n_reset_o                           (),    // : out std_logic;
    .cdce_n_pd_o                              (),    // : out std_logic;
    .cdce_ref_en_o                            (),    // : out std_logic;
    .cdce_pll_status_i                        (zero_bit),    // : in  std_logic;
  
    //-- DAC specific signals       
    .dac_n_en_o                               (),    // : out std_logic; -- SPI chip select
    .dac_sdo_i                                (zero_bit),    // : in  std_logic; -- SPI data out
  
    //-- Monitoring specific signals    
    .mon_n_en_o                               (),    // : out std_logic; -- SPI chip select
    .mon_sdo_i                                (zero_bit),    // : in  std_logic; -- SPI data out
    .mon_n_reset_o                            (),    // : out std_logic;
    .mon_n_int_i                              (zero_bit),    // : in  std_logic;
  
    //--FMC Present status                
    .prsnt_m2c_l_i                            (zero_bit),    // : in  std_logic;
  
    //-- Wishbone Streaming Interface Source  
    .wbs_adr_o                                (),    // : out std_logic_vector(c_wbs_address_width-1 downto 0);
    .wbs_dat_o                                (),    // : out std_logic_vector(c_wbs_data_width-1 downto 0);
    .wbs_cyc_o                                (),    // : out std_logic;
    .wbs_stb_o                                (),    // : out std_logic;
    .wbs_we_o                                 (),    // : out std_logic;
    .wbs_sel_o                                (),    // : out std_logic_vector((c_wbs_data_width/8)-1 downto 0);
  
    .wbs_ack_i                                (zero_bit),    // : in std_logic;
    .wbs_stall_i                              (zero_bit),    // : in std_logic;
    .wbs_err_i                                (zero_bit),    // : in std_logic;
    .wbs_rty_i                                (zero_bit)    // : in std_logic
  );
  
  
  // Functions
  function [`ADC_DATA_WIDTH-1:0] adc_data_gen;
    input integer max_size;
  begin
    // $random is surronded by the concat operator in order
    // to provide us with only unsigned (bit vector) data
    adc_data_gen = {$random} % max_size;   
  end
  endfunction

  function adc_data_valid_gen;
    input integer threshold;
  begin
    // $random is surronded by the concat operator in order
    // to provide us with only unsigned (bit vector) data
    temp = {$random} % threshold;   
    
    if (temp > threshold/2) 
      adc_data_valid_gen = 1'b1;
    else 
      adc_data_valid_gen = 1'b0;
  end
  endfunction

endmodule

