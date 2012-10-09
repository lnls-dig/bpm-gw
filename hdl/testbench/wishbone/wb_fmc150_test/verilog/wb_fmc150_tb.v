// Title          : Testbench for wb_fmc150.v
//
// File           : wb_fmc150_tb.v
// Author         : Lucas Russo <lucas.russo@lnls.br>
// Created        : Mon Oct 08 08:25 2012
// Standard       : Verilog 2001

// Common definitions
`include "defines.v"
// Simulation timescale
`include "timescale.v"
// Wishbone Master
`include "wishbone_test_master.v"
// fmc150 Register definitions
`include "xfmc150_regs_regs.vh"

module wb_fmc150_tb;

  // Clocks
  wire s_clk_sys, s_clk_adc, s_clk_adc2x;
  wire s_clk_100mhz, s_clk_200mhz;
  // Reset
  wire rstn;
  
  // Data generation
  reg [`ADC_DATA_WIDTH-1:0] s_adc_cha_data;
  reg [`ADC_DATA_WIDTH-1:0] s_adc_chb_data;
  reg s_adc_data_valid;
  
  // Wishbone signals
  
  // Local definitions
  localparam adc_data_max = (2**`ADC_DATA_WIDTH)-1;
  localparam adc_gen_threshold = 0.5;
  // Word (32-bit) granularity
  localparam g_granularity = 4;
  // After reset delay
  localparam g_after_reset_delay = 4;
  
  // Internal registers
  reg zero_bit = 1'b0;
  reg spi_busy;
  reg [`WB_ADDRESS_BUS_WIDTH-1:0] data_out;
  
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
  WB_TEST_MASTER cmp_wb_master(.wb_clk(s_clk_sys));
  
  initial begin
    // Enable cmp_wb_master verbosity and bus monitoring 
    // Enable verbose mode
    wb_fmc150_tb.cmp_wb_master.verbose(1);
    // Enable monitor bus
    wb_fmc150_tb.cmp_wb_master.monitor_bus(1);
    
    // Initial values for ADC data signals
    s_adc_cha_data <= 'h0;
    s_adc_chb_data <= 'h0;
    s_adc_data_valid <= 'h0; 
    
    // Wait next clock cycle
    @(posedge s_clk_sys);
    
    // Wait until reset is done
    while (!rstn) begin
      $display("@%0d: Waiting for reset completion.", $time);
      @(posedge s_clk_sys);
    end
    
    $display("@%0d: Reset done!", $time);

    // wait a few cycles before stimulus. Synchronizer chains needs to 
    // update...
    //#(g_after_reset_delay * `CLK_SYS_PERIOD);
    repeat (g_after_reset_delay) begin
      @(posedge s_clk_sys);
    end
    
    $display("@%0d: Initializing FMC150 chips...", $time);
    
    // Waits until FMC150 chips are done initializing
    fmc150_spi_busy(spi_busy);
    //#(`CLK_SYS_PERIOD);
    @(posedge s_clk_sys);
    
    while (spi_busy) begin
      fmc150_spi_busy(spi_busy);
      // Wait for chips to be initialized...
      repeat (128) begin
        @(posedge s_clk_sys);
      end
      //$display(".");
    end
    
    $display("@%0d, FMC150 chips initialized!", $time);

    // Wait next clock cycle
    @(posedge s_clk_sys);
    // Write some values to FMC150 registers
    $display("----------------------------------");
    $display("@%0d, Writing 32'h682C0290 to FMC150_CS_CDCE72010...", $time);
    $display("----------------------------------");
    write_fmc150_reg(`FMC150_CS_CDCE72010, 32'h0, 32'h682C0290);
    // Wait next clock cycle
    @(posedge s_clk_sys);
    // Read some values to FMC150 registers
    $display("----------------------------------");
    $display("@%0d, Reading FMC150_CS_CDCE72010...", $time);
    $display("----------------------------------");
    read_fmc150_reg(`FMC150_CS_CDCE72010, 32'h0, data_out);
  end
  
  // FMC150 device under test. Classic wishbone interface as the Wishbone Master
  // Interface does not talk PIPELINED cycles yet.
  wb_fmc150  #(.g_sim(1)) cmp_wb_fmc150_dut
  (
    .rst_n_i                                  (rstn),                  
    .clk_sys_i                                (s_clk_sys),                   
    .clk_100Mhz_i                             (s_clk_100mhz),                
    .clk_200Mhz_i                             (s_clk_200mhz),               
    
    //-----------------------------
    //-- Wishbone signals
    //-----------------------------

    .wb_adr_i                                 (wb_fmc150_tb.cmp_wb_master.wb_addr),  //: in  std_logic_vector(c_wishbone_address_width-1 downto 0) := (others => '0');
    .wb_dat_i                                 (wb_fmc150_tb.cmp_wb_master.wb_data_o),  //: in  std_logic_vector(c_wishbone_data_width-1 downto 0) := (others => '0');
    .wb_dat_o                                 (wb_fmc150_tb.cmp_wb_master.wb_data_i),  //: out std_logic_vector(c_wishbone_data_width-1 downto 0);
    .wb_sel_i                                 (wb_fmc150_tb.cmp_wb_master.wb_bwsel),  //: in  std_logic_vector(c_wishbone_data_width/8-1 downto 0) := (others => '0');
    .wb_we_i                                  (wb_fmc150_tb.cmp_wb_master.wb_we),  //: in  std_logic := '0';
    .wb_cyc_i                                 (wb_fmc150_tb.cmp_wb_master.wb_cyc),  //: in  std_logic := '0';
    .wb_stb_i                                 (wb_fmc150_tb.cmp_wb_master.wb_stb),  //: in  std_logic := '0';
    .wb_ack_o                                 (wb_fmc150_tb.cmp_wb_master.wb_ack_i),  //: out std_logic;
    .wb_err_o                                 (),  //: out std_logic;
    .wb_rty_o                                 (),  //: out std_logic;
    .wb_stall_o                               (),  //: out std_logic;
    
    //-----------------------------
    //-- Simulation Only ports
    //-----------------------------
    .sim_adc_clk_i                            (s_clk_adc),   //: in std_logic;
    .sim_adc_clk2x_i                          (s_clk_adc2x),   //: in std_logic;
  
    .sim_adc_cha_data_i                       (s_adc_cha_data),//adc_data_gen(adc_data_max)),   //: in std_logic_vector(13 downto 0);
    .sim_adc_chb_data_i                       (s_adc_chb_data),//(adc_data_gen(adc_data_max)),   //: in std_logic_vector(13 downto 0);
    .sim_adc_data_valid                       (s_adc_data_valid),//(adc_data_valid_gen(adc_gen_threshold)),   //: in std_logic;
    
    //-----------------------------
    //-- External ports
    //-----------------------------
    //--Clock/Data connection to ADC on FMC150 (ADS62P49)
    .adc_clk_ab_p_i                           (zero_bit),    //: in  std_logic;
    .adc_clk_ab_n_i                           (zero_bit),    //: in  std_logic;
    .adc_cha_p_i                              (7'h0),    //: in  std_logic_vector(6 downto 0);
    .adc_cha_n_i                              (7'h0),    //: in  std_logic_vector(6 downto 0);
    .adc_chb_p_i                              (7'h0),    //: in  std_logic_vector(6 downto 0);
    .adc_chb_n_i                              (7'h0),    //: in  std_logic_vector(6 downto 0);

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
  
  // Generate data and valid signals on positive edge of ADC clock
  always @(posedge s_clk_adc)
  begin
    s_adc_cha_data <= adc_data_gen(adc_data_max);
    s_adc_chb_data <= adc_data_gen(adc_data_max);
    s_adc_data_valid <= adc_data_valid_gen(adc_gen_threshold);
  end
  
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
    input real prob;
    real temp;
  begin
    // $random is surronded by the concat operator in order
    // to provide us with only unsigned (bit vector) data.
    // Generates valud in a 0..1 range
    temp = ({$random} % 100 + 1)/100.00;//threshold;   
    
    if (temp > prob) 
      adc_data_valid_gen = 1'b1;
    else 
      adc_data_valid_gen = 1'b0;
  end
  endfunction
  
  // Tasks
  
  // Write to an FMC150 register
  
  // C Code correspondent:
  //
  //    int write_fmc150_register(u32 chipselect, u32 addr, u32 value)
  //{
  //    volatile u32 aux_value;
  //
  //    aux_value = XIo_In32(FMC150_BASEADDR+OFFSET_FMC150_FLAGS_IN_0*0x4);
  //    XIo_Out32(FMC150_BASEADDR+OFFSET_FMC150_FLAGS_IN_0*0x4, aux_value & MASK_AND_FLAGSIN0_SPI_WRITE);
  //    XIo_Out32(FMC150_BASEADDR+OFFSET_FMC150_ADDR*0x4, addr);
  //    XIo_Out32(FMC150_BASEADDR+OFFSET_FMC150_DATAIN*0x4, value);
  //
  //    aux_value = XIo_In32(FMC150_BASEADDR+OFFSET_FMC150_CHIPSELECT*0x4) ^ chipselect;
  //    XIo_Out32(FMC150_BASEADDR+OFFSET_FMC150_CHIPSELECT*0x4, aux_value);
  //
  //    return SUCCESS;
  //}
     
  task write_fmc150_reg;
    input [`WB_DATA_BUS_WIDTH - 1 : 0] cs_i;
    input [`WB_DATA_BUS_WIDTH - 1 : 0] addr_i;
    input [`WB_DATA_BUS_WIDTH - 1 : 0] data_i;
  begin : write_fmc150_reg_body
    reg [`WB_DATA_BUS_WIDTH - 1 : 0] aux_val;
      // Read SPI RW bit
      wb_fmc150_tb.cmp_wb_master.read32(`ADDR_FMC150_FLGS_IN, aux_val);
      // This bits do not make sense for this register
      //aux_val[`WB_DATA_BUS_WIDTH - 1 : 2] = 'h0;
      //#(`CLK_SYS_PERIOD);
      @(posedge s_clk_sys);
      // Write SPI RW bit to write op
      wb_fmc150_tb.cmp_wb_master.write32(`ADDR_FMC150_FLGS_IN,
        aux_val & ~`FMC150_FLGS_IN_SPI_RW);
      // Write internal chip addr
      wb_fmc150_tb.cmp_wb_master.write32(`ADDR_FMC150_ADDR, addr_i);
      //#(`CLK_SYS_PERIOD);
      @(posedge s_clk_sys);
      // Write internal chip data
      wb_fmc150_tb.cmp_wb_master.write32(`ADDR_FMC150_DATA_IN, data_i);
      //#(`CLK_SYS_PERIOD);
      @(posedge s_clk_sys);
      
      // Read currently CS field
      wb_fmc150_tb.cmp_wb_master.read32(`ADDR_FMC150_CS, aux_val);
      // This bits do not make sense for this register
      //aux_val[`WB_DATA_BUS_WIDTH - 1 : 4] = 'h0;
      // Toggle Chipselect field
      aux_val = aux_val ^ cs_i;
      //#(`CLK_SYS_PERIOD);
      @(posedge s_clk_sys);
      // Write chipselect to correspondent field
      wb_fmc150_tb.cmp_wb_master.write32(`ADDR_FMC150_CS, aux_val);   
      //#(`CLK_SYS_PERIOD);
      @(posedge s_clk_sys);
  end
  endtask // write_fmc150_reg
  
  // Read to an FMC150 register
  
  // C Code correspondent:
  //
  //int read_fmc150_register(u32 chipselect, u32 addr, volatile u32* value)
  //{
  //    volatile u32 aux_value;
  //
  //    if ((XIo_In32(FMC150_BASEADDR+
  //        OFFSET_FMC150_FLAGS_OUT_0*0x4) & MASK_AND_FLAGSOUT0_SPI_BUSY) != MASK_AND_FLAGSOUT0_SPI_BUSY)
  //    {
  //        aux_value = XIo_In32(FMC150_BASEADDR+OFFSET_FMC150_FLAGS_IN_0*0x4);
  //        XIo_Out32(FMC150_BASEADDR+OFFSET_FMC150_FLAGS_IN_0*0x4, aux_value | MASK_OR_FLAGSIN0_SPI_READ);
  //        XIo_Out32(FMC150_BASEADDR+OFFSET_FMC150_ADDR*0x4, addr);
  //
  //        aux_value = XIo_In32(FMC150_BASEADDR+OFFSET_FMC150_CHIPSELECT*0x4) ^ chipselect;
  //        XIo_Out32(FMC150_BASEADDR+OFFSET_FMC150_CHIPSELECT*0x4, aux_value);
  //
  //        /* Should test in order to see if this delay could be less than 10 */
  //        delay(10);
  //
  //        *value = XIo_In32(FMC150_BASEADDR+OFFSET_FMC150_DATAOUT*0x4);
  //
  //        return SUCCESS;
  //    }
  //    else
  //        return ERROR;
  //}
  
  task read_fmc150_reg;
    input [`WB_DATA_BUS_WIDTH - 1 : 0] cs_i;
    input [`WB_DATA_BUS_WIDTH - 1 : 0] addr_i;
    output [`WB_DATA_BUS_WIDTH - 1 : 0] data_o;
  begin : read_fmc150_reg_body
    reg [`WB_DATA_BUS_WIDTH - 1 : 0] aux_val;
    reg spi_busy;

    //wb_fmc150_tb.cmp_wb_master.read32(`ADDR_FMC150_FLGS_OUT, aux_val);
    //aux_val = aux_val & `FMC150_FLGS_OUT_SPI_BUSY;
    //#(`CLK_SYS_PERIOD);
    // Verify if busy bit is set
    fmc150_spi_busy(spi_busy);
    //#(`CLK_SYS_PERIOD);
    @(posedge s_clk_sys);
    
    // Busy loop until spi is not busy
    //while (aux_val) begin
    //  wb_fmc150_tb.cmp_wb_master.read32(`ADDR_FMC150_FLGS_OUT, aux_val);
    //  aux_val = aux_val & `FMC150_FLGS_OUT_SPI_BUSY;
    //  #(`CLK_SYS_PERIOD);
    //end
    
    if (spi_busy) begin
      $display("SPI is busy!");
      $finish;
    end

    // Read SPI RW bit
    wb_fmc150_tb.cmp_wb_master.read32(`ADDR_FMC150_FLGS_IN, aux_val);
    //#(`CLK_SYS_PERIOD);
    @(posedge s_clk_sys);
    // Write SPI RW bit to read op
    wb_fmc150_tb.cmp_wb_master.write32(`ADDR_FMC150_FLGS_IN,
      aux_val | `FMC150_FLGS_IN_SPI_RW);
      
    // Write internal chip addr
    wb_fmc150_tb.cmp_wb_master.write32(`ADDR_FMC150_ADDR, addr_i);
    //#(`CLK_SYS_PERIOD);
    @(posedge s_clk_sys);
    
    // Read currently CS field
    wb_fmc150_tb.cmp_wb_master.read32(`ADDR_FMC150_CS, aux_val);
    // This bits do not make sense for this register
    //aux_val[`WB_DATA_BUS_WIDTH - 1 : 4] = 'h0;
    // Toggle Chipselect field
    aux_val = aux_val ^ cs_i;
    //#(`CLK_SYS_PERIOD);
    @(posedge s_clk_sys);
    // Write chipselect to correspondent field
    wb_fmc150_tb.cmp_wb_master.write32(`ADDR_FMC150_CS, aux_val);   
    //#(`CLK_SYS_PERIOD);
    @(posedge s_clk_sys);
    
    // Read data
    wb_fmc150_tb.cmp_wb_master.read32(`ADDR_FMC150_DATA_OUT, aux_val);   
    //#(`CLK_SYS_PERIOD);
    @(posedge s_clk_sys);
    
    data_o = aux_val;
  end
  endtask
  
  task fmc150_spi_busy;
    output reg spi_busy;
  begin : fmc150_spi_busy_body
    reg [`WB_DATA_BUS_WIDTH - 1 : 0] aux_val;
    // Verify if busy bit is set
    wb_fmc150_tb.cmp_wb_master.read32(`ADDR_FMC150_FLGS_OUT, aux_val);
    //aux_val = aux_val & `FMC150_FLGS_OUT_SPI_BUSY;
    //#(`CLK_SYS_PERIOD);
    @(posedge s_clk_sys);
    // output spi busy bit
    spi_busy = aux_val[`FMC150_FLGS_OUT_SPI_BUSY_OFFSET];
  end
  endtask
    
endmodule

