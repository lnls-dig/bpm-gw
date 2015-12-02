library ieee;
use ieee.std_logic_1164.all;

library work;
use work.wishbone_pkg.all;
use work.wb_stream_pkg.all;
use work.wb_stream_generic_pkg.all;
use work.fmc_adc_pkg.all;
use work.wr_fabric_pkg.all;
use work.acq_core_pkg.all;
use work.ipcores_pkg.all;
use work.bpm_axi_pkg.all;

package dbe_wishbone_pkg is

  --------------------------------------------------------------------
  -- Components
  --------------------------------------------------------------------

  component wb_dma_interface
  generic(
    g_ovf_counter_width                     : natural := 10
  );
  port(
    -- Asynchronous Reset signal
    arst_n_i                                : in std_logic;

    -- Write Domain Clock
    dma_clk_i                               : in  std_logic;
    --dma_valid_o                             : out std_logic;
    --dma_data_o                              : out std_logic_vector(C_NBITS_DATA_INPUT-1 downto 0);
    --dma_be_o                                : out std_logic_vector(C_NBITS_DATA_INPUT/8 - 1 downto 0);
    --dma_last_o                              : out std_logic;
    --dma_ready_i                             : in  std_logic;

    -- Slave Data Flow port
    --dma_dflow_slave_i                       : in  t_wishbone_dflow_slave_in;
    --dma_dflow_slave_o                       : out t_wishbone_dflow_slave_out;
    wb_sel_i                                : in std_logic_vector(c_wishbone_data_width/8-1 downto 0);
    wb_cyc_i                                : in std_logic;
    wb_stb_i                                : in std_logic;
    wb_we_i                                 : in std_logic;
    wb_adr_i                                : in std_logic_vector(c_wishbone_data_width-1 downto 0);
    wb_dat_i                                : in std_logic_vector(c_wishbone_data_width-1 downto 0);
    wb_dat_o                                : out std_logic_vector(c_wishbone_data_width-1 downto 0);
    wb_ack_o                                : out std_logic;
    wb_stall_o                              : out std_logic;

    -- Slave Data Input Port
    --data_slave_i                            : in  t_wishbone_slave_in;
    --data_slave_o                            : out t_wishbone_slave_out;
    data_clk_i                              : in std_logic;
    data_i                                  : in std_logic_vector(c_wishbone_data_width-1 downto 0);
    data_valid_i                            : in std_logic;
    data_ready_o                            : out std_logic;

    -- Slave control port. use wbgen2 tool or not if it is simple.
    --control_slave_i                         : in  t_wishbone_slave_in;
    --control_slave_o                         : out t_wishbone_slave_out;
    capture_ctl_i                           : in std_logic_vector(c_wishbone_data_width-1 downto 0);
    dma_complete_o                          : out std_logic;
    dma_ovf_o                               : out std_logic

    -- Debug Signals
    --dma_debug_clk_o                         : out std_logic;
    --dma_debug_data_o                        : out std_logic_vector(255 downto 0);
    --dma_debug_trigger_o                     : out std_logic_vector(15 downto 0)
  );
  end component;

  component xwb_dma_interface
  generic(
    -- Three 32-bit data input. LSB bits are valid.
    --C_NBITS_VALID_INPUT                     : natural := 128;
    --C_NBITS_DATA_INPUT                      : natural := 128;
    --C_OVF_COUNTER_SIZE                      : natural := 10
    g_ovf_counter_width                     : natural := 10
  );
  port(
    -- Asynchronous Reset signal
    arst_n_i                                : in std_logic;

        -- Write Domain Clock
    dma_clk_i                               : in  std_logic;
    --dma_valid_o                             : out std_logic;
    --dma_data_o                              : out std_logic_vector(C_NBITS_DATA_INPUT-1 downto 0);
    --dma_be_o                                : out std_logic_vector(C_NBITS_DATA_INPUT/8 - 1 downto 0);
    --dma_last_o                              : out std_logic;
    --dma_ready_i                             : in  std_logic;

    -- Slave Data Flow port
    dma_slave_i                             : in  t_wishbone_slave_in;
    dma_slave_o                             : out t_wishbone_slave_out;

    -- Slave Data Input Port
    --data_slave_i                            : in  t_wishbone_slave_in;
    --data_slave_o                            : out t_wishbone_slave_out;
    data_clk_i                              : in std_logic;
    data_i                                  : in std_logic_vector(c_wishbone_data_width-1 downto 0);
    data_valid_i                            : in std_logic;
    data_ready_o                            : out std_logic;

    -- Slave control port. use wbgen2 tool or not if it is simple.
    --control_slave_i                         : in  t_wishbone_slave_in;
    --control_slave_o                         : out t_wishbone_slave_out;
    capture_ctl_i                           : in std_logic_vector(c_wishbone_data_width-1 downto 0);
    dma_complete_o                          : out std_logic;
    dma_ovf_o                               : out std_logic

    -- Debug Signals
    --dma_debug_clk_o                         : out std_logic;
    --dma_debug_data_o                        : out std_logic_vector(255 downto 0);
    --dma_debug_trigger_o                     : out std_logic_vector(15 downto 0)
  );
  end component;

  component wb_fmc150
  generic
  (
      g_interface_mode                        : t_wishbone_interface_mode      := PIPELINED;
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
      --clk_to_fpga_p           : in  std_logic;
      --clk_to_fpga_n           : in  std_logic;
      --ext_trigger_p           : in  std_logic;
      --ext_trigger_n           : in  std_logic;

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
  end component;

  component xwb_fmc150
  generic
  (
    g_interface_mode                          : t_wishbone_interface_mode      := PIPELINED;
    g_address_granularity                     : t_wishbone_address_granularity := WORD;
    g_packet_size                             : natural := 32;
    g_sim                                     : integer := 0
  );
  port
  (
    rst_n_i                                   : in std_logic;
    clk_sys_i                                 : in std_logic;
    --clk_100Mhz_i                              : in std_logic;
    clk_200Mhz_i                              : in std_logic;

    -----------------------------
    -- Wishbone signals
    -----------------------------

    wb_slv_i                                  : in t_wishbone_slave_in;
    wb_slv_o                                  : out t_wishbone_slave_out;

    -----------------------------
    -- Simulation Only ports
    -----------------------------
    sim_adc_clk_i                             : in std_logic;
    sim_adc_clk2x_i                           : in std_logic;

    sim_adc_cha_data_i                        : in std_logic_vector(13 downto 0);
    sim_adc_chb_data_i                        : in std_logic_vector(13 downto 0);
    sim_adc_data_valid                        : in std_logic;

    -----------------------------
    -- External ports
    -----------------------------
    --Clock/Data connection to ADC on FMC150 (ADS62P49)
    adc_clk_ab_p_i                            : in  std_logic;
    adc_clk_ab_n_i                            : in  std_logic;
    adc_cha_p_i                               : in  std_logic_vector(6 downto 0);
    adc_cha_n_i                               : in  std_logic_vector(6 downto 0);
    adc_chb_p_i                               : in  std_logic_vector(6 downto 0);
    adc_chb_n_i                               : in  std_logic_vector(6 downto 0);

    --Clock/Data connection to DAC on FMC150 (DAC3283)
    dac_dclk_p_o                              : out std_logic;
    dac_dclk_n_o                              : out std_logic;
    dac_data_p_o                              : out std_logic_vector(7 downto 0);
    dac_data_n_o                              : out std_logic_vector(7 downto 0);
    dac_frame_p_o                             : out std_logic;
    dac_frame_n_o                             : out std_logic;
    txenable_o                                : out std_logic;

    --Clock/Trigger connection to FMC150
    --clk_to_fpga_p           : in  std_logic;
    --clk_to_fpga_n           : in  std_logic;
    --ext_trigger_p           : in  std_logic;
    --ext_trigger_n           : in  std_logic;

    -- Control signals from/to FMC150
    --Serial Peripheral Interface (SPI)
    spi_sclk_o                                : out std_logic; -- Shared SPI clock line
    spi_sdata_o                               : out std_logic; -- Shared SPI data line

    -- ADC specific signals
    adc_n_en_o                                : out std_logic; -- SPI chip select
    adc_sdo_i                                 : in  std_logic; -- SPI data out
    adc_reset_o                               : out std_logic; -- SPI reset

    -- CDCE specific signals
    cdce_n_en_o                               : out std_logic; -- SPI chip select
    cdce_sdo_i                                : in  std_logic; -- SPI data out
    cdce_n_reset_o                            : out std_logic;
    cdce_n_pd_o                               : out std_logic;
    cdce_ref_en_o                             : out std_logic;
    cdce_pll_status_i                         : in  std_logic;

    -- DAC specific signals
    dac_n_en_o                                : out std_logic; -- SPI chip select
    dac_sdo_i                                 : in  std_logic; -- SPI data out

    -- Monitoring specific signals
    mon_n_en_o                                : out std_logic; -- SPI chip select
    mon_sdo_i                                 : in  std_logic; -- SPI data out
    mon_n_reset_o                             : out std_logic;
    mon_n_int_i                               : in  std_logic;

    --FMC Present status
    prsnt_m2c_l_i                             : in  std_logic;

    -- ADC output signals
    adc_dout_o                                : out std_logic_vector(31 downto 0);
    clk_adc_o                                 : out std_logic;

    -- Wishbone Streaming Interface Source
    wbs_source_i                              : in t_wbs_source_in;
    wbs_source_o                              : out t_wbs_source_out
  );
  end component;

  component wb_fmc516
  generic
  (
      -- The only supported values are VIRTEX6 and 7SERIES
    g_fpga_device                             : string := "VIRTEX6";
    g_delay_type                              : string := "VARIABLE";
    g_interface_mode                          : t_wishbone_interface_mode      := CLASSIC;
    g_address_granularity                     : t_wishbone_address_granularity := WORD;
    g_adc_clk_period_values                   : t_clk_values_array := default_adc_clk_period_values;
    g_use_clk_chains                          : t_clk_use_chain := dummy_clk_use_chain;
    g_use_data_chains                         : t_data_use_chain := dummy_data_use_chain;
    g_map_clk_data_chains                     : t_map_clk_data_chain := default_map_clk_data_chain;
    g_ref_clk                                 : t_ref_adc_clk := default_ref_adc_clk;
    g_packet_size                             : natural := 32;
    g_with_idelayctrl                         : boolean := true;
    g_sim                                     : integer := 0
  );
  port
  (
    sys_clk_i                                 : in std_logic;
    sys_rst_n_i                               : in std_logic;
    sys_clk_200Mhz_i                          : in std_logic;

    -----------------------------
    -- Wishbone Control Interface signals
    -----------------------------

    wb_adr_i                                  : in  std_logic_vector(c_wishbone_address_width-1 downto 0) := (others => '0');
    wb_dat_i                                  : in  std_logic_vector(c_wishbone_data_width-1 downto 0) := (others => '0');
    wb_dat_o                                  : out std_logic_vector(c_wishbone_data_width-1 downto 0);
    wb_sel_i                                  : in  std_logic_vector(c_wishbone_data_width/8-1 downto 0) := (others => '0');
    wb_we_i                                   : in  std_logic := '0';
    wb_cyc_i                                  : in  std_logic := '0';
    wb_stb_i                                  : in  std_logic := '0';
    wb_ack_o                                  : out std_logic;
    wb_err_o                                  : out std_logic;
    wb_rty_o                                  : out std_logic;
    wb_stall_o                                : out std_logic;

    -----------------------------
    -- External ports
    -----------------------------
    -- System I2C Bus. Slaves: Atmel AT24C512B Serial EEPROM,
    -- AD7417 temperature diodes and AD7417 supply rails
    sys_i2c_scl_b                             : inout std_logic;
    sys_i2c_sda_b                             : inout std_logic;

    -- ADC clocks. One clock per ADC channel.
    -- Only ch0 clock is used as all data chains
    -- are sampled at the same frequency
    adc_clk0_p_i                              : in std_logic;
    adc_clk0_n_i                              : in std_logic;
    adc_clk1_p_i                              : in std_logic;
    adc_clk1_n_i                              : in std_logic;
    adc_clk2_p_i                              : in std_logic;
    adc_clk2_n_i                              : in std_logic;
    adc_clk3_p_i                              : in std_logic;
    adc_clk3_n_i                              : in std_logic;

    -- DDR ADC data channels.
    adc_data_ch0_p_i                          : in std_logic_vector(7 downto 0);
    adc_data_ch0_n_i                          : in std_logic_vector(7 downto 0);
    adc_data_ch1_p_i                          : in std_logic_vector(7 downto 0);
    adc_data_ch1_n_i                          : in std_logic_vector(7 downto 0);
    adc_data_ch2_p_i                          : in std_logic_vector(7 downto 0);
    adc_data_ch2_n_i                          : in std_logic_vector(7 downto 0);
    adc_data_ch3_p_i                          : in std_logic_vector(7 downto 0);
    adc_data_ch3_n_i                          : in std_logic_vector(7 downto 0);

    -- ADC clock (half of the sampling frequency) divider reset
    adc_clk_div_rst_p_o                       : out std_logic;
    adc_clk_div_rst_n_o                       : out std_logic;

    -- FMC Front leds. Typical uses: Over Range or Full Scale
    -- condition.
    fmc_leds_o                                : out std_logic_vector(1 downto 0);

    -- ADC SPI control interface. Three-wire mode. Tri-stated data pin
    sys_spi_clk_o                             : out std_logic;
    sys_spi_data_b                            : inout std_logic;
    --sys_spi_dout_o                            : out std_logic;
    --sys_spi_din_i                             : in std_logic;
    sys_spi_cs_adc0_n_o                       : out std_logic;  -- SPI ADC CS channel 0
    sys_spi_cs_adc1_n_o                       : out std_logic;  -- SPI ADC CS channel 1
    sys_spi_cs_adc2_n_o                       : out std_logic;  -- SPI ADC CS channel 2
    sys_spi_cs_adc3_n_o                       : out std_logic;  -- SPI ADC CS channel 3
    --sys_spi_miosio_oe_n_o                     : out std_logic;

    -- External Trigger To/From FMC
    m2c_trig_p_i                              : in std_logic;
    m2c_trig_n_i                              : in std_logic;
    c2m_trig_p_o                              : out std_logic;
    c2m_trig_n_o                              : out std_logic;

    -- LMK (National Semiconductor) is the clock and distribution IC.
    -- SPI interface?
    lmk_lock_i                                : in std_logic;
    lmk_sync_o                                : out std_logic;
    lmk_uwire_latch_en_o                      : out std_logic;
    lmk_uwire_data_o                          : out std_logic;
    lmk_uwire_clock_o                         : out std_logic;

    -- Programable Si571 VCXO via I2C
    vcxo_i2c_sda_b                            : inout std_logic;
    vcxo_i2c_scl_b                            : inout std_logic;
    vcxo_pd_l_o                               : out std_logic;

    -- One-wire To/From DS2431 (VMETRO Data)
    fmc_id_dq_b                               : inout std_logic;
    -- One-wire To/From DS2432 SHA-1 (SP-Devices key)
    fmc_key_dq_b                              : inout std_logic;

    -- General board pins
    fmc_pwr_good_i                            : in std_logic;
    -- Internal/External clock distribution selection
    fmc_clk_sel_o                             : out std_logic;
    -- Reset ADCs
    fmc_reset_adcs_n_o                        : out std_logic;
    --FMC Present status
    fmc_prsnt_m2c_l_i                         : in  std_logic;

    -----------------------------
    -- Optional external reference clock ports
    -----------------------------
    fmc_ext_ref_clk_i                         : in std_logic := '0';
    fmc_ext_ref_clk2x_i                       : in std_logic := '0';
    fmc_ext_ref_mmcm_locked_i                 : in std_logic := '0';

    -----------------------------
    -- ADC output signals. Continuous flow
    -----------------------------
    adc_clk_o                                 : out std_logic_vector(c_num_adc_channels-1 downto 0);
    adc_clk2x_o                               : out std_logic_vector(c_num_adc_channels-1 downto 0);
    adc_rst_n_o                               : out std_logic_vector(c_num_adc_channels-1 downto 0);
    adc_data_o                                : out std_logic_vector(c_num_adc_channels*c_num_adc_bits-1 downto 0);
    adc_data_valid_o                          : out std_logic_vector(c_num_adc_channels-1 downto 0);

    -----------------------------
    -- General ADC output signals
    -----------------------------
    -- Trigger to other FPGA logic
    trig_hw_o                                 : out std_logic;
    trig_hw_i                                 : in std_logic;

    -- General board status
    fmc_mmcm_lock_o                           : out std_logic;
    fmc_lmk_lock_o                            : out std_logic;

    -----------------------------
    -- Wishbone Streaming Interface Source
    -----------------------------
    wbs_adr_o                                : out std_logic_vector(c_num_adc_channels*c_wbs_adr4_width-1 downto 0);
    wbs_dat_o                                : out std_logic_vector(c_num_adc_channels*c_wbs_dat16_width-1 downto 0);
    wbs_cyc_o                                : out std_logic_vector(c_num_adc_channels-1 downto 0);
    wbs_stb_o                                : out std_logic_vector(c_num_adc_channels-1 downto 0);
    wbs_we_o                                 : out std_logic_vector(c_num_adc_channels-1 downto 0);
    wbs_sel_o                                : out std_logic_vector(c_num_adc_channels*c_wbs_sel16_width-1 downto 0);
    wbs_ack_i                                : in std_logic_vector(c_num_adc_channels-1 downto 0) := (others => '0');
    wbs_stall_i                              : in std_logic_vector(c_num_adc_channels-1 downto 0) := (others => '0');
    wbs_err_i                                : in std_logic_vector(c_num_adc_channels-1 downto 0) := (others => '0');
    wbs_rty_i                                : in std_logic_vector(c_num_adc_channels-1 downto 0) := (others => '0');

    adc_dly_debug_o                          : out t_adc_fn_dly_array(c_num_adc_channels-1 downto 0);

    fifo_debug_valid_o                       : out std_logic_vector(c_num_adc_channels-1 downto 0);
    fifo_debug_full_o                        : out std_logic_vector(c_num_adc_channels-1 downto 0);
    fifo_debug_empty_o                       : out std_logic_vector(c_num_adc_channels-1 downto 0)
  );
  end component;

  component xwb_fmc516
  generic
  (
    -- The only supported values are VIRTEX6 and 7SERIES
    g_fpga_device                             : string := "VIRTEX6";
    g_delay_type                              : string := "VARIABLE";
    g_interface_mode                          : t_wishbone_interface_mode      := CLASSIC;
    g_address_granularity                     : t_wishbone_address_granularity := WORD;
    g_adc_clk_period_values                   : t_clk_values_array := default_adc_clk_period_values;
    g_use_clk_chains                          : t_clk_use_chain := dummy_clk_use_chain;
    g_use_data_chains                         : t_data_use_chain := dummy_data_use_chain;
    g_map_clk_data_chains                     : t_map_clk_data_chain := default_map_clk_data_chain;
    g_ref_clk                                 : t_ref_adc_clk := default_ref_adc_clk;
    g_packet_size                             : natural := 32;
    g_with_idelayctrl                         : boolean := true;
    g_sim                                     : integer := 0
  );
  port
  (
    sys_clk_i                                 : in std_logic;
    sys_rst_n_i                               : in std_logic;
    sys_clk_200Mhz_i                          : in std_logic;

    -----------------------------
    -- Wishbone Control Interface signals
    -----------------------------

    wb_slv_i                                  : in t_wishbone_slave_in;
    wb_slv_o                                  : out t_wishbone_slave_out;

    -----------------------------
    -- External ports
    -----------------------------
    -- System I2C Bus. Slaves: Atmel AT24C512B Serial EEPROM,
    -- AD7417 temperature diodes and AD7417 supply rails
    sys_i2c_scl_b                             : inout std_logic;
    sys_i2c_sda_b                             : inout std_logic;

    -- ADC clocks. One clock per ADC channel.
    -- Only ch1 clock is used as all data chains
    -- are sampled at the same frequency
    adc_clk0_p_i                              : in std_logic;
    adc_clk0_n_i                              : in std_logic;
    adc_clk1_p_i                              : in std_logic;
    adc_clk1_n_i                              : in std_logic;
    adc_clk2_p_i                              : in std_logic;
    adc_clk2_n_i                              : in std_logic;
    adc_clk3_p_i                              : in std_logic;
    adc_clk3_n_i                              : in std_logic;

    -- DDR ADC data channels.
    adc_data_ch0_p_i                          : in std_logic_vector(c_num_adc_bits/2-1 downto 0);
    adc_data_ch0_n_i                          : in std_logic_vector(c_num_adc_bits/2-1 downto 0);
    adc_data_ch1_p_i                          : in std_logic_vector(c_num_adc_bits/2-1 downto 0);
    adc_data_ch1_n_i                          : in std_logic_vector(c_num_adc_bits/2-1 downto 0);
    adc_data_ch2_p_i                          : in std_logic_vector(c_num_adc_bits/2-1 downto 0);
    adc_data_ch2_n_i                          : in std_logic_vector(c_num_adc_bits/2-1 downto 0);
    adc_data_ch3_p_i                          : in std_logic_vector(c_num_adc_bits/2-1 downto 0);
    adc_data_ch3_n_i                          : in std_logic_vector(c_num_adc_bits/2-1 downto 0);

    -- ADC clock (half of the sampling frequency) divider reset
    adc_clk_div_rst_p_o                       : out std_logic;
    adc_clk_div_rst_n_o                       : out std_logic;

    -- FMC Front leds. Typical uses: Over Range or Full Scale
    -- condition.
    fmc_leds_o                                : out std_logic_vector(1 downto 0);

    -- ADC SPI control interface. Three-wire mode. Tri-stated data pin
    sys_spi_clk_o                             : out std_logic;
    sys_spi_data_b                            : inout std_logic;
    --sys_spi_dout_o                            : out std_logic;
    --sys_spi_din_i                             : in std_logic;
    sys_spi_cs_adc0_n_o                       : out std_logic;  -- SPI ADC CS channel 0
    sys_spi_cs_adc1_n_o                       : out std_logic;  -- SPI ADC CS channel 1
    sys_spi_cs_adc2_n_o                       : out std_logic;  -- SPI ADC CS channel 2
    sys_spi_cs_adc3_n_o                       : out std_logic;  -- SPI ADC CS channel 3
    --sys_spi_miosio_oe_n_o                     : out std_logic;

    -- External Trigger To/From FMC
    m2c_trig_p_i                              : in std_logic;
    m2c_trig_n_i                              : in std_logic;
    c2m_trig_p_o                              : out std_logic;
    c2m_trig_n_o                              : out std_logic;

    -- LMK (National Semiconductor) is the clock and distribution IC,
    -- programmable via Microwire Interface
    lmk_lock_i                                : in std_logic;
    lmk_sync_o                                : out std_logic;
    lmk_uwire_latch_en_o                      : out std_logic;
    lmk_uwire_data_o                          : out std_logic;
    lmk_uwire_clock_o                         : out std_logic;

    -- Programable VCXO via I2C
    vcxo_i2c_sda_b                            : inout std_logic;
    vcxo_i2c_scl_b                            : inout std_logic;
    vcxo_pd_l_o                               : out std_logic;

    -- One-wire To/From DS2431 (VMETRO Data)
    fmc_id_dq_b                               : inout std_logic;
    -- One-wire To/From DS2432 SHA-1 (SP-Devices key)
    fmc_key_dq_b                              : inout std_logic;

    -- General board pins
    fmc_pwr_good_i                            : in std_logic;
    -- Internal/External clock distribution selection
    fmc_clk_sel_o                             : out std_logic;
    -- Reset ADCs
    fmc_reset_adcs_n_o                        : out std_logic;
    --FMC Present status
    fmc_prsnt_m2c_l_i                         : in  std_logic;

    -----------------------------
    -- Optional external reference clock ports
    -----------------------------
    fmc_ext_ref_clk_i                        : in std_logic := '0';
    fmc_ext_ref_clk2x_i                      : in std_logic := '0';
    fmc_ext_ref_mmcm_locked_i                : in std_logic := '0';

    -----------------------------
    -- ADC output signals. Continuous flow
    -----------------------------
    adc_clk_o                                 : out std_logic_vector(c_num_adc_channels-1 downto 0);
    adc_clk2x_o                               : out std_logic_vector(c_num_adc_channels-1 downto 0);
    adc_rst_n_o                               : out std_logic_vector(c_num_adc_channels-1 downto 0);
    adc_data_o                                : out std_logic_vector(c_num_adc_channels*c_num_adc_bits-1 downto 0);
    adc_data_valid_o                          : out std_logic_vector(c_num_adc_channels-1 downto 0);

    -----------------------------
    -- General ADC output signals and status
    -----------------------------
    -- Trigger to other FPGA logic
    trig_hw_o                                 : out std_logic;
    trig_hw_i                                 : in std_logic;

    -- General board status
    fmc_mmcm_lock_o                           : out std_logic;
    fmc_lmk_lock_o                            : out std_logic;

    -----------------------------
    -- Wishbone Streaming Interface Source
    -----------------------------
    wbs_source_i                              : in t_wbs_source_in16_array(c_num_adc_channels-1 downto 0);
    wbs_source_o                              : out t_wbs_source_out16_array(c_num_adc_channels-1 downto 0);

    adc_dly_debug_o                           : out t_adc_fn_dly_array(c_num_adc_channels-1 downto 0);

    fifo_debug_valid_o                        : out std_logic_vector(c_num_adc_channels-1 downto 0);
    fifo_debug_full_o                         : out std_logic_vector(c_num_adc_channels-1 downto 0);
    fifo_debug_empty_o                        : out std_logic_vector(c_num_adc_channels-1 downto 0)
  );
  end component;

  component wb_fmc130m_4ch
  generic
  (
    -- The only supported values are VIRTEX6 and 7SERIES
    g_fpga_device                             : string := "VIRTEX6";
    g_delay_type                              : string := "VARIABLE";
    g_interface_mode                          : t_wishbone_interface_mode      := CLASSIC;
    g_address_granularity                     : t_wishbone_address_granularity := WORD;
    g_with_extra_wb_reg                       : boolean := false;
    g_adc_clk_period_values                   : t_clk_values_array := default_adc_clk_period_values;
    g_use_clk_chains                          : t_clk_use_chain := default_clk_use_chain;
    g_with_bufio_clk_chains                   : t_clk_use_bufio_chain := default_clk_use_bufio_chain;
    g_with_bufr_clk_chains                    : t_clk_use_bufr_chain := default_clk_use_bufr_chain;
    g_with_idelayctrl                         : boolean := true;
    g_use_data_chains                         : t_data_use_chain := default_data_use_chain;
    g_map_clk_data_chains                     : t_map_clk_data_chain := default_map_clk_data_chain;
    g_ref_clk                                 : t_ref_adc_clk := default_ref_adc_clk;
    g_packet_size                             : natural := 32;
    g_sim                                     : integer := 0
  );
  port
  (
    sys_clk_i                                 : in std_logic;
    sys_rst_n_i                               : in std_logic;
    sys_clk_200Mhz_i                          : in std_logic;

    -----------------------------
    -- Wishbone Control Interface signals
    -----------------------------

    wb_adr_i                                  : in  std_logic_vector(c_wishbone_address_width-1 downto 0) := (others => '0');
    wb_dat_i                                  : in  std_logic_vector(c_wishbone_data_width-1 downto 0) := (others => '0');
    wb_dat_o                                  : out std_logic_vector(c_wishbone_data_width-1 downto 0);
    wb_sel_i                                  : in  std_logic_vector(c_wishbone_data_width/8-1 downto 0) := (others => '0');
    wb_we_i                                   : in  std_logic := '0';
    wb_cyc_i                                  : in  std_logic := '0';
    wb_stb_i                                  : in  std_logic := '0';
    wb_ack_o                                  : out std_logic;
    wb_err_o                                  : out std_logic;
    wb_rty_o                                  : out std_logic;
    wb_stall_o                                : out std_logic;

    -----------------------------
    -- External ports
    -----------------------------

    -- ADC LTC2208 interface
    fmc_adc_pga_o                             : out std_logic;
    fmc_adc_shdn_o                            : out std_logic;
    fmc_adc_dith_o                            : out std_logic;
    fmc_adc_rand_o                            : out std_logic;

    -- ADC0 LTC2208
    fmc_adc0_clk_i                            : in std_logic := '0';
    fmc_adc0_data_i                           : in std_logic_vector(c_num_adc_bits-1 downto 0) := (others => '0');
    fmc_adc0_of_i                             : in std_logic := '0'; -- Unused

    -- ADC1 LTC2208
    fmc_adc1_clk_i                            : in std_logic := '0';
    fmc_adc1_data_i                           : in std_logic_vector(c_num_adc_bits-1 downto 0) := (others => '0');
    fmc_adc1_of_i                             : in std_logic := '0'; -- Unused

    -- ADC2 LTC2208
    fmc_adc2_clk_i                            : in std_logic := '0';
    fmc_adc2_data_i                           : in std_logic_vector(c_num_adc_bits-1 downto 0) := (others => '0');
    fmc_adc2_of_i                             : in std_logic := '0'; -- Unused

    -- ADC3 LTC2208
    fmc_adc3_clk_i                            : in std_logic;
    fmc_adc3_data_i                           : in std_logic_vector(c_num_adc_bits-1 downto 0) := (others => '0');
    fmc_adc3_of_i                             : in std_logic := '0'; -- Unused

    -- FMC General Status
    fmc_prsnt_i                               : in std_logic := '0';
    fmc_pg_m2c_i                              : in std_logic := '0';
    --fmc_clk_dir_i                           : in std_logic;, -- not supported on Kintex7 KC705 board

    -- Trigger
    fmc_trig_dir_o                            : out std_logic;
    fmc_trig_term_o                           : out std_logic;
    fmc_trig_val_p_b                          : inout std_logic;
    fmc_trig_val_n_b                          : inout std_logic;

    -- Si571 clock gen
    si571_scl_pad_b                           : inout std_logic;
    si571_sda_pad_b                           : inout std_logic;
    fmc_si571_oe_o                            : out std_logic;

    -- AD9510 clock distribution PLL
    spi_ad9510_cs_o                           : out std_logic;
    spi_ad9510_sclk_o                         : out std_logic;
    spi_ad9510_mosi_o                         : out std_logic;
    spi_ad9510_miso_i                         : in std_logic := '0';

    fmc_pll_function_o                        : out std_logic;
    fmc_pll_status_i                          : in std_logic := '0';

    -- AD9510 clock copy
    fmc_fpga_clk_p_i                          : in std_logic := '0';
    fmc_fpga_clk_n_i                          : in std_logic := '0';

    -- Clock reference selection (TS3USB221)
    fmc_clk_sel_o                             : out std_logic;

    -- EEPROM
    eeprom_scl_pad_b                          : inout std_logic;
    eeprom_sda_pad_b                          : inout std_logic;

    -- Temperature monitor
    -- LM75AIMM
    lm75_scl_pad_b                            : inout std_logic;
    lm75_sda_pad_b                            : inout std_logic;

    fmc_lm75_temp_alarm_i                     : in std_logic := '0';

    -- FMC LEDs
    fmc_led1_o                                : out std_logic;
    fmc_led2_o                                : out std_logic;
    fmc_led3_o                                : out std_logic;

    -----------------------------
    -- Optional external reference clock ports
    -----------------------------
    fmc_ext_ref_clk_i                        : in std_logic := '0';
    fmc_ext_ref_clk2x_i                      : in std_logic := '0';
    fmc_ext_ref_mmcm_locked_i                : in std_logic := '0';

    -----------------------------
    -- ADC output signals. Continuous flow
    -----------------------------
    adc_clk_o                                 : out std_logic_vector(c_num_adc_channels-1 downto 0);
    adc_clk2x_o                               : out std_logic_vector(c_num_adc_channels-1 downto 0);
    adc_rst_n_o                               : out std_logic_vector(c_num_adc_channels-1 downto 0);
    adc_rst2x_n_o                             : out std_logic_vector(c_num_adc_channels-1 downto 0);
    adc_data_o                                : out std_logic_vector(c_num_adc_channels*c_num_adc_bits-1 downto 0);
    adc_data_valid_o                          : out std_logic_vector(c_num_adc_channels-1 downto 0);

    -----------------------------
    -- General ADC output signals and status
    -----------------------------
    -- Trigger to other FPGA logic
    trig_hw_o                                 : out std_logic;
    trig_hw_i                                 : in std_logic := '0';

    -- General board status
    fmc_mmcm_lock_o                           : out std_logic;
    fmc_pll_status_o                          : out std_logic;

    -----------------------------
    -- Wishbone Streaming Interface Source
    -----------------------------
    wbs_adr_o                                 : out std_logic_vector(c_num_adc_channels*c_wbs_adr4_width-1 downto 0);
    wbs_dat_o                                 : out std_logic_vector(c_num_adc_channels*c_wbs_dat16_width-1 downto 0);
    wbs_cyc_o                                 : out std_logic_vector(c_num_adc_channels-1 downto 0);
    wbs_stb_o                                 : out std_logic_vector(c_num_adc_channels-1 downto 0);
    wbs_we_o                                  : out std_logic_vector(c_num_adc_channels-1 downto 0);
    wbs_sel_o                                 : out std_logic_vector(c_num_adc_channels*c_wbs_sel16_width-1 downto 0);
    wbs_ack_i                                 : in std_logic_vector(c_num_adc_channels-1 downto 0) := (others => '0');
    wbs_stall_i                               : in std_logic_vector(c_num_adc_channels-1 downto 0) := (others => '0');
    wbs_err_i                                 : in std_logic_vector(c_num_adc_channels-1 downto 0) := (others => '0');
    wbs_rty_i                                 : in std_logic_vector(c_num_adc_channels-1 downto 0) := (others => '0');

    adc_dly_debug_o                           : out t_adc_fn_dly_array(c_num_adc_channels-1 downto 0);

    fifo_debug_valid_o                        : out std_logic_vector(c_num_adc_channels-1 downto 0);
    fifo_debug_full_o                         : out std_logic_vector(c_num_adc_channels-1 downto 0);
    fifo_debug_empty_o                        : out std_logic_vector(c_num_adc_channels-1 downto 0)
  );
  end component;

  component xwb_fmc130m_4ch
  generic
  (
    -- The only supported values are VIRTEX6 and 7SERIES
    g_fpga_device                             : string := "VIRTEX6";
    g_delay_type                              : string := "VARIABLE";
    g_interface_mode                          : t_wishbone_interface_mode      := CLASSIC;
    g_address_granularity                     : t_wishbone_address_granularity := WORD;
    g_with_extra_wb_reg                       : boolean := false;
    g_adc_clk_period_values                   : t_clk_values_array := default_adc_clk_period_values;
    g_use_clk_chains                          : t_clk_use_chain := default_clk_use_chain;
    g_with_bufio_clk_chains                   : t_clk_use_bufio_chain := default_clk_use_bufio_chain;
    g_with_bufr_clk_chains                    : t_clk_use_bufr_chain := default_clk_use_bufr_chain;
    g_with_idelayctrl                         : boolean := true;
    g_use_data_chains                         : t_data_use_chain := default_data_use_chain;
    g_map_clk_data_chains                     : t_map_clk_data_chain := default_map_clk_data_chain;
    g_ref_clk                                 : t_ref_adc_clk := default_ref_adc_clk;
    g_packet_size                             : natural := 32;
    g_sim                                     : integer := 0
  );
  port
  (
    sys_clk_i                                 : in std_logic;
    sys_rst_n_i                               : in std_logic;
    sys_clk_200Mhz_i                          : in std_logic;

    -----------------------------
    -- Wishbone Control Interface signals
    -----------------------------

    wb_slv_i                                  : in t_wishbone_slave_in;
    wb_slv_o                                  : out t_wishbone_slave_out;

    -----------------------------
    -- External ports
    -----------------------------

    -- ADC LTC2208 interface
    fmc_adc_pga_o                             : out std_logic;
    fmc_adc_shdn_o                            : out std_logic;
    fmc_adc_dith_o                            : out std_logic;
    fmc_adc_rand_o                            : out std_logic;

    -- ADC0 LTC2208
    fmc_adc0_clk_i                            : in std_logic;
    fmc_adc0_data_i                           : in std_logic_vector(c_num_adc_bits-1 downto 0);
    fmc_adc0_of_i                             : in std_logic; -- Unused

    -- ADC1 LTC2208
    fmc_adc1_clk_i                            : in std_logic;
    fmc_adc1_data_i                           : in std_logic_vector(c_num_adc_bits-1 downto 0);
    fmc_adc1_of_i                             : in std_logic; -- Unused

    -- ADC2 LTC2208
    fmc_adc2_clk_i                            : in std_logic;
    fmc_adc2_data_i                           : in std_logic_vector(c_num_adc_bits-1 downto 0);
    fmc_adc2_of_i                             : in std_logic; -- Unused

    -- ADC3 LTC2208
    fmc_adc3_clk_i                            : in std_logic;
    fmc_adc3_data_i                           : in std_logic_vector(c_num_adc_bits-1 downto 0);
    fmc_adc3_of_i                             : in std_logic; -- Unused

    -- FMC General Status
    fmc_prsnt_i                               : in std_logic;
    fmc_pg_m2c_i                              : in std_logic;
    --fmc_clk_dir_i                           : in std_logic;, -- not supported on Kintex7 KC705 board

    -- Trigger
    fmc_trig_dir_o                            : out std_logic;
    fmc_trig_term_o                           : out std_logic;
    fmc_trig_val_p_b                          : inout std_logic;
    fmc_trig_val_n_b                          : inout std_logic;

    -- Si571 clock gen
    si571_scl_pad_b                           : inout std_logic;
    si571_sda_pad_b                           : inout std_logic;
    fmc_si571_oe_o                            : out std_logic;

    -- AD9510 clock distribution PLL
    spi_ad9510_cs_o                           : out std_logic;
    spi_ad9510_sclk_o                         : out std_logic;
    spi_ad9510_mosi_o                         : out std_logic;
    spi_ad9510_miso_i                         : in std_logic;

    fmc_pll_function_o                        : out std_logic;
    fmc_pll_status_i                          : in std_logic;

    -- AD9510 clock copy
    fmc_fpga_clk_p_i                          : in std_logic;
    fmc_fpga_clk_n_i                          : in std_logic;

    -- Clock reference selection (TS3USB221)
    fmc_clk_sel_o                             : out std_logic;

    -- EEPROM
    eeprom_scl_pad_b                          : inout std_logic;
    eeprom_sda_pad_b                          : inout std_logic;

    -- Temperature monitor
    -- LM75AIMM
    lm75_scl_pad_b                            : inout std_logic;
    lm75_sda_pad_b                            : inout std_logic;

    fmc_lm75_temp_alarm_i                     : in std_logic;

    -- FMC LEDs
    fmc_led1_o                                : out std_logic;
    fmc_led2_o                                : out std_logic;
    fmc_led3_o                                : out std_logic;

    -----------------------------
    -- Optional external reference clock ports
    -----------------------------
    fmc_ext_ref_clk_i                        : in std_logic := '0';
    fmc_ext_ref_clk2x_i                      : in std_logic := '0';
    fmc_ext_ref_mmcm_locked_i                : in std_logic := '0';

    -----------------------------
    -- ADC output signals. Continuous flow
    -----------------------------
    adc_clk_o                                 : out std_logic_vector(c_num_adc_channels-1 downto 0);
    adc_clk2x_o                               : out std_logic_vector(c_num_adc_channels-1 downto 0);
    adc_rst_n_o                               : out std_logic_vector(c_num_adc_channels-1 downto 0);
    adc_rst2x_n_o                             : out std_logic_vector(c_num_adc_channels-1 downto 0);
    adc_data_o                                : out std_logic_vector(c_num_adc_channels*c_num_adc_bits-1 downto 0);
    adc_data_valid_o                          : out std_logic_vector(c_num_adc_channels-1 downto 0);

    -----------------------------
    -- General ADC output signals and status
    -----------------------------
    -- Trigger to other FPGA logic
    trig_hw_o                                 : out std_logic;
    trig_hw_i                                 : in std_logic := '0';

    -- General board status
    fmc_mmcm_lock_o                           : out std_logic;
    fmc_pll_status_o                          : out std_logic;

    -----------------------------
    -- Wishbone Streaming Interface Source
    -----------------------------
    wbs_source_i                              : in t_wbs_source_in16_array(c_num_adc_channels-1 downto 0);
    wbs_source_o                              : out t_wbs_source_out16_array(c_num_adc_channels-1 downto 0);

    adc_dly_debug_o                          : out t_adc_fn_dly_array(c_num_adc_channels-1 downto 0);

    fifo_debug_valid_o                       : out std_logic_vector(c_num_adc_channels-1 downto 0);
    fifo_debug_full_o                        : out std_logic_vector(c_num_adc_channels-1 downto 0);
    fifo_debug_empty_o                       : out std_logic_vector(c_num_adc_channels-1 downto 0)
  );
  end component;

  component xwb_ethmac_adapter
  port(
    clk_i                                     : in std_logic;
    rstn_i                                    : in std_logic;

    wb_slave_o                                : out t_wishbone_slave_out;
    wb_slave_i                                : in t_wishbone_slave_in;

    tx_ram_o                                  : out t_wishbone_master_out;
    tx_ram_i                                  : in t_wishbone_master_in;

    rx_ram_o                                  : out t_wishbone_master_out;
    rx_ram_i                                  : in t_wishbone_master_in;

    rx_eb_o                                   : out t_wrf_source_out;
    rx_eb_i                                   : in t_wrf_source_in;

    tx_eb_o                                   : out t_wrf_sink_out;
    tx_eb_i                                   : in t_wrf_sink_in;

    irq_tx_done_o                             : out std_logic;
    irq_rx_done_o                             : out std_logic
  );
  end component;

  component wb_dbe_periph
  generic(
    -- NOT used!
    g_interface_mode                          : t_wishbone_interface_mode      := CLASSIC;
    -- NOT used!
    g_address_granularity                     : t_wishbone_address_granularity := WORD;
    g_cntr_period                             : integer                        := 100000; -- 100MHz clock, ms granularity
    g_num_leds                                : natural                        := 8;
    g_num_buttons                             : natural                        := 8
  );
  port(
    clk_sys_i                                 : in std_logic;
    rst_n_i                                   : in std_logic;

    -- UART
    uart_rxd_i                                : in  std_logic;
    uart_txd_o                                : out std_logic;

    -- LEDs
    led_out_o                                 : out std_logic_vector(g_num_leds-1 downto 0);
    led_in_i                                  : in  std_logic_vector(g_num_leds-1 downto 0);
    led_oen_o                                 : out std_logic_vector(g_num_leds-1 downto 0);

    -- Buttons
    button_out_o                              : out std_logic_vector(g_num_buttons-1 downto 0);
    button_in_i                               : in  std_logic_vector(g_num_buttons-1 downto 0);
    button_oen_o                              : out std_logic_vector(g_num_buttons-1 downto 0);

    -- Wishbone
    wb_adr_i                                  : in  std_logic_vector(c_wishbone_address_width-1 downto 0) := (others => '0');
    wb_dat_i                                  : in  std_logic_vector(c_wishbone_data_width-1 downto 0) := (others => '0');
    wb_dat_o                                  : out std_logic_vector(c_wishbone_data_width-1 downto 0);
    wb_sel_i                                  : in  std_logic_vector(c_wishbone_data_width/8-1 downto 0) := (others => '0');
    wb_we_i                                   : in  std_logic := '0';
    wb_cyc_i                                  : in  std_logic := '0';
    wb_stb_i                                  : in  std_logic := '0';
    wb_ack_o                                  : out std_logic;
    wb_err_o                                  : out std_logic;
    wb_rty_o                                  : out std_logic;
    wb_stall_o                                : out std_logic
  );
  end component;

  component xwb_dbe_periph
  generic(
    -- NOT used!
    g_interface_mode                          : t_wishbone_interface_mode      := CLASSIC;
    -- NOT used!
    g_address_granularity                     : t_wishbone_address_granularity := WORD;
    g_cntr_period                             : integer                        := 100000; -- 100MHz clock, ms granularity
    g_num_leds                                : natural                        := 8;
    g_num_buttons                             : natural                        := 8
  );
  port(
    clk_sys_i                                 : in std_logic;
    rst_n_i                                   : in std_logic;

    -- UART
    uart_rxd_i                                : in  std_logic;
    uart_txd_o                                : out std_logic;

    -- LEDs
    led_out_o                                 : out std_logic_vector(g_num_leds-1 downto 0);
    led_in_i                                  : in  std_logic_vector(g_num_leds-1 downto 0);
    led_oen_o                                 : out std_logic_vector(g_num_leds-1 downto 0);

    -- Buttons
    button_out_o                              : out std_logic_vector(g_num_buttons-1 downto 0);
    button_in_i                               : in  std_logic_vector(g_num_buttons-1 downto 0);
    button_oen_o                              : out std_logic_vector(g_num_buttons-1 downto 0);

    -- Wishbone
    slave_i                                   : in  t_wishbone_slave_in;
    slave_o                                   : out t_wishbone_slave_out
  );
  end component;

  component wb_rs232_syscon
  generic (
    g_ma_interface_mode                       : t_wishbone_interface_mode      := PIPELINED;
    g_ma_address_granularity                  : t_wishbone_address_granularity := BYTE
  );
  port(
    -- WISHBONE common
    wb_clk_i                                  : in std_logic;
    wb_rstn_i                                 : in std_logic;

    -- External ports
    rs232_rxd_i                               : in std_logic;
    rs232_txd_o                               : out std_logic;

    -- Reset to FPGA logic
    rstn_o                                    : out std_logic;

    -- WISHBONE master
    m_wb_adr_o                                : out std_logic_vector(31 downto 0);
    m_wb_sel_o                                : out std_logic_vector(3 downto 0);
    m_wb_we_o                                 : out std_logic;
    m_wb_dat_o                                : out std_logic_vector(31 downto 0);
    m_wb_dat_i                                : in std_logic_vector(31 downto 0);
    m_wb_cyc_o                                : out std_logic;
    m_wb_stb_o                                : out std_logic;
    m_wb_ack_i                                : in std_logic;
    m_wb_err_i                                : in std_logic;
    m_wb_stall_i                              : in std_logic;
    m_wb_rty_i                                : in std_logic
  );
  end component;

  component xwb_rs232_syscon
  generic (
    g_ma_interface_mode                       : t_wishbone_interface_mode      := PIPELINED;
    g_ma_address_granularity                  : t_wishbone_address_granularity := BYTE
  );
  port(
    -- WISHBONE common
    wb_clk_i                                  : in std_logic;
    wb_rstn_i                                 : in std_logic;

    -- External ports
    rs232_rxd_i                               : in std_logic;
    rs232_txd_o                               : out std_logic;

    -- Reset to FPGA logic
    rstn_o                                    : out std_logic;

    -- WISHBONE master
    wb_master_i                               : in t_wishbone_master_in;
    wb_master_o                               : out t_wishbone_master_out
  );
  end component;

  component wb_acq_core
  generic
  (
    g_interface_mode                          : t_wishbone_interface_mode      := CLASSIC;
    g_address_granularity                     : t_wishbone_address_granularity := WORD;
    g_acq_addr_width                          : natural := 32;
    g_acq_num_channels                        : natural := c_default_acq_num_channels;
    g_acq_channels                            : t_acq_chan_param_array := c_default_acq_chan_param_array;
    g_ddr_payload_width                       : natural := 256;     -- be careful changing these!
    g_ddr_dq_width                            : natural := 64;      -- be careful changing these!
    g_ddr_addr_width                          : natural := 32;      -- be careful changing these!
    g_multishot_ram_size                      : natural := 2048;
    g_fifo_fc_size                            : natural := 64;
    g_sim_readback                            : boolean := false
  );
  port
  (
    fs_clk_i                                  : in std_logic;
    fs_ce_i                                   : in std_logic;
    fs_rst_n_i                                : in std_logic;

    sys_clk_i                                 : in std_logic;
    sys_rst_n_i                               : in std_logic;

    ext_clk_i                                 : in std_logic;
    ext_rst_n_i                               : in std_logic;

    -----------------------------
    -- Wishbone Control Interface signals
    -----------------------------

    wb_adr_i                                  : in  std_logic_vector(c_wishbone_address_width-1 downto 0) := (others => '0');
    wb_dat_i                                  : in  std_logic_vector(c_wishbone_data_width-1 downto 0) := (others => '0');
    wb_dat_o                                  : out std_logic_vector(c_wishbone_data_width-1 downto 0);
    wb_sel_i                                  : in  std_logic_vector(c_wishbone_data_width/8-1 downto 0) := (others => '0');
    wb_we_i                                   : in  std_logic := '0';
    wb_cyc_i                                  : in  std_logic := '0';
    wb_stb_i                                  : in  std_logic := '0';
    wb_ack_o                                  : out std_logic;
    wb_err_o                                  : out std_logic;
    wb_rty_o                                  : out std_logic;
    wb_stall_o                                : out std_logic;

    -----------------------------
    -- External Interface
    -----------------------------
    acq_val_low_i                             : in t_acq_val_half_array(g_acq_num_channels-1 downto 0);
    acq_val_high_i                            : in t_acq_val_half_array(g_acq_num_channels-1 downto 0);
    acq_dvalid_i                              : in std_logic_vector(g_acq_num_channels-1 downto 0);
    acq_trig_i                                : in std_logic_vector(g_acq_num_channels-1 downto 0);

    -----------------------------
    -- DRRAM Interface
    -----------------------------
    dpram_dout_o                              : out std_logic_vector(f_acq_chan_find_widest(g_acq_channels)-1 downto 0);
    dpram_valid_o                             : out std_logic;

    -----------------------------
    -- External Interface (w/ FLow Control)
    -----------------------------
    ext_dout_o                                : out std_logic_vector(g_ddr_payload_width-1 downto 0);
    ext_valid_o                               : out std_logic;
    ext_addr_o                                : out std_logic_vector(g_acq_addr_width-1 downto 0);
    ext_sof_o                                 : out std_logic;
    ext_eof_o                                 : out std_logic;
    ext_dreq_o                                : out std_logic; -- for debbuging purposes
    ext_stall_o                               : out std_logic; -- for debbuging purposes

    -----------------------------
    -- DDR3 SDRAM Interface
    -----------------------------
    ui_app_addr_o                             : out std_logic_vector(g_ddr_addr_width-1 downto 0);
    ui_app_cmd_o                              : out std_logic_vector(2 downto 0);
    ui_app_en_o                               : out std_logic;
    ui_app_rdy_i                              : in std_logic;

    ui_app_wdf_data_o                         : out std_logic_vector(g_ddr_payload_width-1 downto 0);
    ui_app_wdf_end_o                          : out std_logic;
    ui_app_wdf_mask_o                         : out std_logic_vector(g_ddr_payload_width/8-1 downto 0);
    ui_app_wdf_wren_o                         : out std_logic;
    ui_app_wdf_rdy_i                          : in std_logic;

    ui_app_rd_data_i                          : in std_logic_vector(g_ddr_payload_width-1 downto 0);
    ui_app_rd_data_end_i                      : in std_logic;
    ui_app_rd_data_valid_i                    : in std_logic;

    ui_app_req_o                              : out std_logic;
    ui_app_gnt_i                              : in std_logic;

    -----------------------------
    -- Debug Interface
    -----------------------------
    dbg_ddr_rb_start_p_i                      : in std_logic;
    dbg_ddr_rb_rdy_o                          : out std_logic;
    dbg_ddr_rb_data_o                         : out std_logic_vector(g_ddr_payload_width-1 downto 0);
    dbg_ddr_rb_addr_o                         : out std_logic_vector(g_acq_addr_width-1 downto 0);
    dbg_ddr_rb_valid_o                        : out std_logic
  );
  end component;

  component xwb_acq_core
  generic
  (
    g_interface_mode                          : t_wishbone_interface_mode      := CLASSIC;
    g_address_granularity                     : t_wishbone_address_granularity := WORD;
    g_acq_addr_width                          : natural := 32;
    g_acq_num_channels                        : natural := c_default_acq_num_channels;
    g_acq_channels                            : t_acq_chan_param_array := c_default_acq_chan_param_array;
    g_ddr_payload_width                       : natural := 256;     -- be careful changing these!
    g_ddr_dq_width                            : natural := 64;      -- be careful changing these!
    g_ddr_addr_width                          : natural := 32;      -- be careful changing these!
    g_multishot_ram_size                      : natural := 2048;
    g_fifo_fc_size                            : natural := 64;
    g_sim_readback                            : boolean := false
  );
  port
  (
    fs_clk_i                                  : in std_logic;
    fs_ce_i                                   : in std_logic;
    fs_rst_n_i                                : in std_logic;

    sys_clk_i                                 : in std_logic;
    sys_rst_n_i                               : in std_logic;

    ext_clk_i                                 : in std_logic;
    ext_rst_n_i                               : in std_logic;

    -----------------------------
    -- Wishbone Control Interface signals
    -----------------------------
    wb_slv_i                                  : in t_wishbone_slave_in;
    wb_slv_o                                  : out t_wishbone_slave_out;

    -----------------------------
    -- External Interface
    -----------------------------
    acq_chan_array_i                          : in t_acq_chan_array(g_acq_num_channels-1 downto 0);

    -----------------------------
    -- DRRAM Interface
    -----------------------------
    dpram_dout_o                              : out std_logic_vector(f_acq_chan_find_widest(g_acq_channels)-1 downto 0);
    dpram_valid_o                             : out std_logic;

    -----------------------------
    -- External Interface (w/ FLow Control)
    -----------------------------
    ext_dout_o                                : out std_logic_vector(g_ddr_payload_width-1 downto 0);
    ext_valid_o                               : out std_logic;
    ext_addr_o                                : out std_logic_vector(g_acq_addr_width-1 downto 0);
    ext_sof_o                                 : out std_logic;
    ext_eof_o                                 : out std_logic;
    ext_dreq_o                                : out std_logic; -- for debbuging purposes
    ext_stall_o                               : out std_logic; -- for debbuging purposes

    -----------------------------
    -- DDR3 SDRAM Interface
    -----------------------------
    ui_app_addr_o                             : out std_logic_vector(g_ddr_addr_width-1 downto 0);
    ui_app_cmd_o                              : out std_logic_vector(2 downto 0);
    ui_app_en_o                               : out std_logic;
    ui_app_rdy_i                              : in std_logic;

    ui_app_wdf_data_o                         : out std_logic_vector(g_ddr_payload_width-1 downto 0);
    ui_app_wdf_end_o                          : out std_logic;
    ui_app_wdf_mask_o                         : out std_logic_vector(g_ddr_payload_width/8-1 downto 0);
    ui_app_wdf_wren_o                         : out std_logic;
    ui_app_wdf_rdy_i                          : in std_logic;

    ui_app_rd_data_i                          : in std_logic_vector(g_ddr_payload_width-1 downto 0);
    ui_app_rd_data_end_i                      : in std_logic;
    ui_app_rd_data_valid_i                    : in std_logic;

    ui_app_req_o                              : out std_logic;
    ui_app_gnt_i                              : in std_logic;

    -----------------------------
    -- Debug Interface
    -----------------------------
    dbg_ddr_rb_start_p_i                      : in std_logic;
    dbg_ddr_rb_rdy_o                          : out std_logic;
    dbg_ddr_rb_data_o                         : out std_logic_vector(g_ddr_payload_width-1 downto 0);
    dbg_ddr_rb_addr_o                         : out std_logic_vector(g_acq_addr_width-1 downto 0);
    dbg_ddr_rb_valid_o                        : out std_logic
  );
  end component;

  component wb_acq_core_2_to_1_mux
  generic
  (
    g_interface_mode                          : t_wishbone_interface_mode      := CLASSIC;
    g_address_granularity                     : t_wishbone_address_granularity := WORD;
    g_acq_addr_width                          : natural := 32;
    g_acq_num_channels                        : natural := c_default_acq_num_channels;
    g_acq_channels                            : t_acq_chan_param_array := c_default_acq_chan_param_array;
    g_ddr_payload_width                       : natural := 256;     -- be careful changing these!
    g_ddr_dq_width                            : natural := 64;      -- be careful changing these!
    g_ddr_addr_width                          : natural := 32;      -- be careful changing these!
    g_multishot_ram_size                      : natural := 2048;
    g_fifo_fc_size                            : natural := 64;
    g_sim_readback                            : boolean := false
  );
  port
  (
    -- Clock signals for acquisition core 1
    fs1_clk_i                                 : in std_logic;
    fs1_ce_i                                  : in std_logic;
    fs1_rst_n_i                               : in std_logic;

    -- Clock signals for acquisition core 2
    fs2_clk_i                                 : in std_logic;
    fs2_ce_i                                  : in std_logic;
    fs2_rst_n_i                               : in std_logic;

    -- Clock signals for Wishbone
    sys_clk_i                                 : in std_logic;
    sys_rst_n_i                               : in std_logic;

    -- Clock signals for External Memory
    ext_clk_i                                 : in std_logic;
    ext_rst_n_i                               : in std_logic;

    -----------------------------
    -- Wishbone Control Interface signals
    -----------------------------

    wb0_adr_i                                 : in  std_logic_vector(c_wishbone_address_width-1 downto 0) := (others => '0');
    wb0_dat_i                                 : in  std_logic_vector(c_wishbone_data_width-1 downto 0) := (others => '0');
    wb0_dat_o                                 : out std_logic_vector(c_wishbone_data_width-1 downto 0);
    wb0_sel_i                                 : in  std_logic_vector(c_wishbone_data_width/8-1 downto 0) := (others => '0');
    wb0_we_i                                  : in  std_logic := '0';
    wb0_cyc_i                                 : in  std_logic := '0';
    wb0_stb_i                                 : in  std_logic := '0';
    wb0_ack_o                                 : out std_logic;
    wb0_err_o                                 : out std_logic;
    wb0_rty_o                                 : out std_logic;
    wb0_stall_o                               : out std_logic;

    wb1_adr_i                                 : in  std_logic_vector(c_wishbone_address_width-1 downto 0) := (others => '0');
    wb1_dat_i                                 : in  std_logic_vector(c_wishbone_data_width-1 downto 0) := (others => '0');
    wb1_dat_o                                 : out std_logic_vector(c_wishbone_data_width-1 downto 0);
    wb1_sel_i                                 : in  std_logic_vector(c_wishbone_data_width/8-1 downto 0) := (others => '0');
    wb1_we_i                                  : in  std_logic := '0';
    wb1_cyc_i                                 : in  std_logic := '0';
    wb1_stb_i                                 : in  std_logic := '0';
    wb1_ack_o                                 : out std_logic;
    wb1_err_o                                 : out std_logic;
    wb1_rty_o                                 : out std_logic;
    wb1_stall_o                               : out std_logic;

    -----------------------------
    -- External Interface
    -----------------------------
    acq0_val_low_i                            : in t_acq_val_half_array(g_acq_num_channels-1 downto 0);
    acq0_val_high_i                           : in t_acq_val_half_array(g_acq_num_channels-1 downto 0);
    acq0_dvalid_i                             : in std_logic_vector(g_acq_num_channels-1 downto 0);
    acq0_trig_i                               : in std_logic_vector(g_acq_num_channels-1 downto 0);

    acq1_val_low_i                            : in t_acq_val_half_array(g_acq_num_channels-1 downto 0);
    acq1_val_high_i                           : in t_acq_val_half_array(g_acq_num_channels-1 downto 0);
    acq1_dvalid_i                             : in std_logic_vector(g_acq_num_channels-1 downto 0);
    acq1_trig_i                               : in std_logic_vector(g_acq_num_channels-1 downto 0);

    -----------------------------
    -- DRRAM Interface
    -----------------------------
    dpram0_dout_o                             : out std_logic_vector(f_acq_chan_find_widest(g_acq_channels)-1 downto 0);
    dpram0_valid_o                            : out std_logic;

    dpram1_dout_o                             : out std_logic_vector(f_acq_chan_find_widest(g_acq_channels)-1 downto 0);
    dpram1_valid_o                            : out std_logic;

    -----------------------------
    -- External Interface (w/ FLow Control)
    -----------------------------
    ext0_dout_o                               : out std_logic_vector(g_ddr_payload_width-1 downto 0);
    ext0_valid_o                              : out std_logic;
    ext0_addr_o                               : out std_logic_vector(g_acq_addr_width-1 downto 0);
    ext0_sof_o                                : out std_logic;
    ext0_eof_o                                : out std_logic;
    ext0_dreq_o                               : out std_logic; -- for debbuging purposes
    ext0_stall_o                              : out std_logic; -- for debbuging purposes

    ext1_dout_o                               : out std_logic_vector(g_ddr_payload_width-1 downto 0);
    ext1_valid_o                              : out std_logic;
    ext1_addr_o                               : out std_logic_vector(g_acq_addr_width-1 downto 0);
    ext1_sof_o                                : out std_logic;
    ext1_eof_o                                : out std_logic;
    ext1_dreq_o                               : out std_logic; -- for debbuging purposes
    ext1_stall_o                              : out std_logic; -- for debbuging purposes

    -----------------------------
    -- DDR3 SDRAM Interface
    -----------------------------
    ui_app_addr_o                             : out std_logic_vector(g_ddr_addr_width-1 downto 0);
    ui_app_cmd_o                              : out std_logic_vector(2 downto 0);
    ui_app_en_o                               : out std_logic;
    ui_app_rdy_i                              : in std_logic;

    ui_app_wdf_data_o                         : out std_logic_vector(g_ddr_payload_width-1 downto 0);
    ui_app_wdf_end_o                          : out std_logic;
    ui_app_wdf_mask_o                         : out std_logic_vector(g_ddr_payload_width/8-1 downto 0);
    ui_app_wdf_wren_o                         : out std_logic;
    ui_app_wdf_rdy_i                          : in std_logic;

    ui_app_rd_data_i                          : in std_logic_vector(g_ddr_payload_width-1 downto 0);
    ui_app_rd_data_end_i                      : in std_logic;
    ui_app_rd_data_valid_i                    : in std_logic;

    ui_app_req_o                              : out std_logic;
    ui_app_gnt_i                              : in std_logic;

    -----------------------------
    -- Debug Interface
    -----------------------------
    dbg_ddr_rb0_start_p_i                     : in std_logic;
    dbg_ddr_rb0_rdy_o                         : out std_logic;
    dbg_ddr_rb0_data_o                        : out std_logic_vector(g_ddr_payload_width-1 downto 0);
    dbg_ddr_rb0_addr_o                        : out std_logic_vector(g_acq_addr_width-1 downto 0);
    dbg_ddr_rb0_valid_o                       : out std_logic;

    dbg_ddr_rb1_start_p_i                     : in std_logic;
    dbg_ddr_rb1_rdy_o                         : out std_logic;
    dbg_ddr_rb1_data_o                        : out std_logic_vector(g_ddr_payload_width-1 downto 0);
    dbg_ddr_rb1_addr_o                        : out std_logic_vector(g_acq_addr_width-1 downto 0);
    dbg_ddr_rb1_valid_o                       : out std_logic
  );
  end component;

  component xwb_acq_core_2_to_1_mux
  generic
  (
    g_interface_mode                          : t_wishbone_interface_mode      := CLASSIC;
    g_address_granularity                     : t_wishbone_address_granularity := WORD;
    g_acq_addr_width                          : natural := 32;
    g_acq_num_channels                        : natural := c_default_acq_num_channels;
    g_acq_channels                            : t_acq_chan_param_array := c_default_acq_chan_param_array;
    g_ddr_payload_width                       : natural := 256;     -- be careful changing these!
    g_ddr_dq_width                            : natural := 64;      -- be careful changing these!
    g_ddr_addr_width                          : natural := 32;      -- be careful changing these!
    g_multishot_ram_size                      : natural := 2048;
    g_fifo_fc_size                            : natural := 64;
    g_sim_readback                            : boolean := false
  );
  port
  (
    -- Clock signals for acquisition core 1
    fs1_clk_i                                 : in std_logic;
    fs1_ce_i                                  : in std_logic;
    fs1_rst_n_i                               : in std_logic;

    -- Clock signals for acquisition core 2
    fs2_clk_i                                 : in std_logic;
    fs2_ce_i                                  : in std_logic;
    fs2_rst_n_i                               : in std_logic;

    -- Clock signals for Wishbone
    sys_clk_i                                 : in std_logic;
    sys_rst_n_i                               : in std_logic;

    -- Clock signals for External Memory
    ext_clk_i                                 : in std_logic;
    ext_rst_n_i                               : in std_logic;

    -----------------------------
    -- Wishbone Control Interface signals
    -----------------------------
    wb0_slv_i                                 : in t_wishbone_slave_in;
    wb0_slv_o                                 : out t_wishbone_slave_out;

    wb1_slv_i                                 : in t_wishbone_slave_in;
    wb1_slv_o                                 : out t_wishbone_slave_out;

    -----------------------------
    -- External Interface
    -----------------------------
    acq0_chan_array_i                         : in t_acq_chan_array(g_acq_num_channels-1 downto 0);

    acq1_chan_array_i                         : in t_acq_chan_array(g_acq_num_channels-1 downto 0);

    -----------------------------
    -- DRRAM Interface
    -----------------------------
    dpram0_dout_o                             : out std_logic_vector(f_acq_chan_find_widest(g_acq_channels)-1 downto 0);
    dpram0_valid_o                            : out std_logic;

    dpram1_dout_o                             : out std_logic_vector(f_acq_chan_find_widest(g_acq_channels)-1 downto 0);
    dpram1_valid_o                            : out std_logic;

    -----------------------------
    -- External Interface (w/ FLow Control)
    -----------------------------
    ext0_dout_o                               : out std_logic_vector(g_ddr_payload_width-1 downto 0);
    ext0_valid_o                              : out std_logic;
    ext0_addr_o                               : out std_logic_vector(g_acq_addr_width-1 downto 0);
    ext0_sof_o                                : out std_logic;
    ext0_eof_o                                : out std_logic;
    ext0_dreq_o                               : out std_logic; -- for debbuging purposes
    ext0_stall_o                              : out std_logic; -- for debbuging purposes

    ext1_dout_o                               : out std_logic_vector(g_ddr_payload_width-1 downto 0);
    ext1_valid_o                              : out std_logic;
    ext1_addr_o                               : out std_logic_vector(g_acq_addr_width-1 downto 0);
    ext1_sof_o                                : out std_logic;
    ext1_eof_o                                : out std_logic;
    ext1_dreq_o                               : out std_logic; -- for debbuging purposes
    ext1_stall_o                              : out std_logic; -- for debbuging purposes

    -----------------------------
    -- DDR3 SDRAM Interface
    -----------------------------
    ui_app_addr_o                             : out std_logic_vector(g_ddr_addr_width-1 downto 0);
    ui_app_cmd_o                              : out std_logic_vector(2 downto 0);
    ui_app_en_o                               : out std_logic;
    ui_app_rdy_i                              : in std_logic;

    ui_app_wdf_data_o                         : out std_logic_vector(g_ddr_payload_width-1 downto 0);
    ui_app_wdf_end_o                          : out std_logic;
    ui_app_wdf_mask_o                         : out std_logic_vector(g_ddr_payload_width/8-1 downto 0);
    ui_app_wdf_wren_o                         : out std_logic;
    ui_app_wdf_rdy_i                          : in std_logic;

    ui_app_rd_data_i                          : in std_logic_vector(g_ddr_payload_width-1 downto 0);
    ui_app_rd_data_end_i                      : in std_logic;
    ui_app_rd_data_valid_i                    : in std_logic;

    ui_app_req_o                              : out std_logic;
    ui_app_gnt_i                              : in std_logic;

    -----------------------------
    -- Debug Interface
    -----------------------------
    dbg_ddr_rb0_start_p_i                     : in std_logic;
    dbg_ddr_rb0_rdy_o                         : out std_logic;
    dbg_ddr_rb0_data_o                        : out std_logic_vector(g_ddr_payload_width-1 downto 0);
    dbg_ddr_rb0_addr_o                        : out std_logic_vector(g_acq_addr_width-1 downto 0);
    dbg_ddr_rb0_valid_o                       : out std_logic;

    dbg_ddr_rb1_start_p_i                     : in std_logic;
    dbg_ddr_rb1_rdy_o                         : out std_logic;
    dbg_ddr_rb1_data_o                        : out std_logic_vector(g_ddr_payload_width-1 downto 0);
    dbg_ddr_rb1_addr_o                        : out std_logic_vector(g_acq_addr_width-1 downto 0);
    dbg_ddr_rb1_valid_o                       : out std_logic
  );
  end component;

  component wb_afc_diag
  generic
  (
    g_interface_mode                          : t_wishbone_interface_mode      := CLASSIC;
    g_address_granularity                     : t_wishbone_address_granularity := WORD
  );
  port
  (
    sys_clk_i                                 : in std_logic;
    sys_rst_n_i                               : in std_logic;

    -- Fast SPI clock
    spi_clk_i                                 : in std_logic;

    -----------------------------
    -- Wishbone Control Interface signals
    -----------------------------

    wb_adr_i                                  : in  std_logic_vector(c_wishbone_address_width-1 downto 0) := (others => '0');
    wb_dat_i                                  : in  std_logic_vector(c_wishbone_data_width-1 downto 0) := (others => '0');
    wb_dat_o                                  : out std_logic_vector(c_wishbone_data_width-1 downto 0);
    wb_sel_i                                  : in  std_logic_vector(c_wishbone_data_width/8-1 downto 0) := (others => '0');
    wb_we_i                                   : in  std_logic := '0';
    wb_cyc_i                                  : in  std_logic := '0';
    wb_stb_i                                  : in  std_logic := '0';
    wb_ack_o                                  : out std_logic;
    wb_err_o                                  : out std_logic;
    wb_rty_o                                  : out std_logic;
    wb_stall_o                                : out std_logic;

    dbg_spi_clk_o                             : out std_logic;
    dbg_spi_valid_o                           : out std_logic;
    dbg_en_o                                  : out std_logic;
    dbg_addr_o                                : out std_logic_vector(7 downto 0);
    dbg_serial_data_o                         : out std_logic_vector(31 downto 0);
    dbg_spi_data_o                            : out std_logic_vector(31 downto 0);

    -----------------------------
    -- SPI interface
    -----------------------------

    spi_cs                                    : in  std_logic;
    spi_si                                    : in  std_logic;
    spi_so                                    : out std_logic;
    spi_clk                                   : in  std_logic
  );
  end component;

  component xwb_afc_diag
  generic
  (
    g_interface_mode                          : t_wishbone_interface_mode      := CLASSIC;
    g_address_granularity                     : t_wishbone_address_granularity := WORD
  );
  port
  (
    sys_clk_i                                 : in std_logic;
    sys_rst_n_i                               : in std_logic;

    -- Fast SPI clock
    spi_clk_i                                 : in std_logic;

    -----------------------------
    -- Wishbone Control Interface signals
    -----------------------------
    wb_slv_i                                  : in t_wishbone_slave_in;
    wb_slv_o                                  : out t_wishbone_slave_out;

    dbg_spi_clk_o                             : out std_logic;
    dbg_spi_valid_o                           : out std_logic;
    dbg_en_o                                  : out std_logic;
    dbg_addr_o                                : out std_logic_vector(7 downto 0);
    dbg_serial_data_o                         : out std_logic_vector(31 downto 0);
    dbg_spi_data_o                            : out std_logic_vector(31 downto 0);

    -----------------------------
    -- SPI interface
    -----------------------------

    spi_cs                                    : in  std_logic;
    spi_si                                    : in  std_logic;
    spi_so                                    : out std_logic;
    spi_clk                                   : in  std_logic
  );
  end component;

  component wb_bpm_pcie
  generic (
    g_ma_interface_mode                       : t_wishbone_interface_mode := PIPELINED;
    g_ma_address_granularity                  : t_wishbone_address_granularity := BYTE;
    g_simulation                              : string  := "FALSE"
  );
  port (
    -- DDR3 memory pins
    ddr3_dq_b                                 : inout std_logic_vector(c_ddr_dq_width-1 downto 0);
    ddr3_dqs_p_b                              : inout std_logic_vector(c_ddr_dqs_width-1 downto 0);
    ddr3_dqs_n_b                              : inout std_logic_vector(c_ddr_dqs_width-1 downto 0);
    ddr3_addr_o                               : out   std_logic_vector(c_ddr_row_width-1 downto 0);
    ddr3_ba_o                                 : out   std_logic_vector(c_ddr_bank_width-1 downto 0);
    ddr3_cs_n_o                               : out   std_logic_vector(0 downto 0);
    ddr3_ras_n_o                              : out   std_logic;
    ddr3_cas_n_o                              : out   std_logic;
    ddr3_we_n_o                               : out   std_logic;
    ddr3_reset_n_o                            : out   std_logic;
    ddr3_ck_p_o                               : out   std_logic_vector(c_ddr_ck_width-1 downto 0);
    ddr3_ck_n_o                               : out   std_logic_vector(c_ddr_ck_width-1 downto 0);
    ddr3_cke_o                                : out   std_logic_vector(c_ddr_cke_width-1 downto 0);
    ddr3_dm_o                                 : out   std_logic_vector(c_ddr_dm_width-1 downto 0);
    ddr3_odt_o                                : out   std_logic_vector(c_ddr_odt_width-1 downto 0);

    -- PCIe transceivers
    pci_exp_rxp_i                             : in  std_logic_vector(c_pcielanes - 1 downto 0);
    pci_exp_rxn_i                             : in  std_logic_vector(c_pcielanes - 1 downto 0);
    pci_exp_txp_o                             : out std_logic_vector(c_pcielanes - 1 downto 0);
    pci_exp_txn_o                             : out std_logic_vector(c_pcielanes - 1 downto 0);

    -- Necessity signals
    ddr_clk_i                                 : in std_logic; --200 MHz DDR core clock (connect through BUFG or PLL)
    ddr_rst_i                                 : in std_logic; --200 MHz DDR core clock (connect through BUFG or PLL)
    pcie_clk_p_i                              : in std_logic; --100 MHz PCIe Clock (connect directly to input pin)
    pcie_clk_n_i                              : in std_logic; --100 MHz PCIe Clock
    pcie_rst_n_i                              : in std_logic; --Reset to PCIe core

    -- DDR memory controller interface --
    ddr_aximm_sl_aclk_o                       : out std_logic;
    ddr_aximm_sl_aresetn_o                    : out std_logic;
    ddr_aximm_w_sl_awid_i                     : in std_logic_vector (0 downto 0);
    ddr_aximm_w_sl_awaddr_i                   : in std_logic_vector (31 downto 0);
    ddr_aximm_w_sl_awlen_i                    : in std_logic_vector (7 downto 0);
    ddr_aximm_w_sl_awsize_i                   : in std_logic_vector (2 downto 0);
    ddr_aximm_w_sl_awburst_i                  : in std_logic_vector (1 downto 0);
    ddr_aximm_w_sl_awlock_i                   : in std_logic;
    ddr_aximm_w_sl_awcache_i                  : in std_logic_vector (3 downto 0);
    ddr_aximm_w_sl_awprot_i                   : in std_logic_vector (2 downto 0);
    ddr_aximm_w_sl_awqos_i                    : in std_logic_vector (3 downto 0);
    ddr_aximm_w_sl_awvalid_i                  : in std_logic;
    ddr_aximm_w_sl_awready_o                  : out std_logic;
    ddr_aximm_w_sl_wdata_i                    : in std_logic_vector (c_ddr_payload_width-1 downto 0);
    ddr_aximm_w_sl_wstrb_i                    : in std_logic_vector (c_ddr_payload_width/8-1 downto 0);
    ddr_aximm_w_sl_wlast_i                    : in std_logic;
    ddr_aximm_w_sl_wvalid_i                   : in std_logic;
    ddr_aximm_w_sl_wready_o                   : out std_logic;
    ddr_aximm_w_sl_bready_i                   : in std_logic;
    ddr_aximm_w_sl_bid_o                      : out std_logic_vector (0 downto 0);
    ddr_aximm_w_sl_bresp_o                    : out std_logic_vector (1 downto 0);
    ddr_aximm_w_sl_bvalid_o                   : out std_logic;
    ddr_aximm_r_sl_arid_i                     : in std_logic_vector (0 downto 0);
    ddr_aximm_r_sl_araddr_i                   : in std_logic_vector (31 downto 0);
    ddr_aximm_r_sl_arlen_i                    : in std_logic_vector (7 downto 0);
    ddr_aximm_r_sl_arsize_i                   : in std_logic_vector (2 downto 0);
    ddr_aximm_r_sl_arburst_i                  : in std_logic_vector (1 downto 0);
    ddr_aximm_r_sl_arlock_i                   : in std_logic;
    ddr_aximm_r_sl_arcache_i                  : in std_logic_vector (3 downto 0);
    ddr_aximm_r_sl_arprot_i                   : in std_logic_vector (2 downto 0);
    ddr_aximm_r_sl_arqos_i                    : in std_logic_vector (3 downto 0);
    ddr_aximm_r_sl_arvalid_i                  : in std_logic;
    ddr_aximm_r_sl_arready_o                  : out std_logic;
    ddr_aximm_r_sl_rready_i                   : in std_logic;
    ddr_aximm_r_sl_rid_o                      : out std_logic_vector (0 downto 0 );
    ddr_aximm_r_sl_rdata_o                    : out std_logic_vector (c_ddr_payload_width-1 downto 0);
    ddr_aximm_r_sl_rresp_o                    : out std_logic_vector (1 downto 0 );
    ddr_aximm_r_sl_rlast_o                    : out std_logic;
    ddr_aximm_r_sl_rvalid_o                   : out std_logic;

    -- Wishbone interface --
    wb_clk_i                                  : in std_logic;
    wb_rst_i                                  : in std_logic;
    wb_ma_adr_o                               : out std_logic_vector(c_wishbone_address_width-1 downto 0);
    wb_ma_dat_o                               : out std_logic_vector(c_wishbone_data_width-1 downto 0);
    wb_ma_sel_o                               : out std_logic_vector(c_wishbone_data_width/8-1 downto 0);
    wb_ma_cyc_o                               : out std_logic;
    wb_ma_stb_o                               : out std_logic;
    wb_ma_we_o                                : out std_logic;
    wb_ma_dat_i                               : in  std_logic_vector(c_wishbone_data_width-1 downto 0)    := cc_dummy_data;
    wb_ma_err_i                               : in  std_logic                                             := '0';
    wb_ma_rty_i                               : in  std_logic                                             := '0';
    wb_ma_ack_i                               : in  std_logic                                             := '0';
    wb_ma_stall_i                             : in  std_logic                                             := '0';
    -- Additional exported signals for instantiation
    wb_ma_pcie_rst_o                          : out std_logic
  );
  end component;

  component xwb_bpm_pcie
  generic (
    g_ma_interface_mode                       : t_wishbone_interface_mode := PIPELINED;
    g_ma_address_granularity                  : t_wishbone_address_granularity := BYTE;
    g_simulation                              : string  := "FALSE"
  );
  port (
    -- DDR3 memory pins
    ddr3_dq_b                                 : inout std_logic_vector(c_ddr_dq_width-1 downto 0);
    ddr3_dqs_p_b                              : inout std_logic_vector(c_ddr_dqs_width-1 downto 0);
    ddr3_dqs_n_b                              : inout std_logic_vector(c_ddr_dqs_width-1 downto 0);
    ddr3_addr_o                               : out   std_logic_vector(c_ddr_row_width-1 downto 0);
    ddr3_ba_o                                 : out   std_logic_vector(c_ddr_bank_width-1 downto 0);
    ddr3_cs_n_o                               : out   std_logic_vector(0 downto 0);
    ddr3_ras_n_o                              : out   std_logic;
    ddr3_cas_n_o                              : out   std_logic;
    ddr3_we_n_o                               : out   std_logic;
    ddr3_reset_n_o                            : out   std_logic;
    ddr3_ck_p_o                               : out   std_logic_vector(c_ddr_ck_width-1 downto 0);
    ddr3_ck_n_o                               : out   std_logic_vector(c_ddr_ck_width-1 downto 0);
    ddr3_cke_o                                : out   std_logic_vector(c_ddr_cke_width-1 downto 0);
    ddr3_dm_o                                 : out   std_logic_vector(c_ddr_dm_width-1 downto 0);
    ddr3_odt_o                                : out   std_logic_vector(c_ddr_odt_width-1 downto 0);

    -- PCIe transceivers
    pci_exp_rxp_i                             : in  std_logic_vector(c_pcielanes - 1 downto 0);
    pci_exp_rxn_i                             : in  std_logic_vector(c_pcielanes - 1 downto 0);
    pci_exp_txp_o                             : out std_logic_vector(c_pcielanes - 1 downto 0);
    pci_exp_txn_o                             : out std_logic_vector(c_pcielanes - 1 downto 0);

    -- Necessity signals
    ddr_clk_i                                 : in std_logic; --200 MHz DDR core clock (connect through BUFG or PLL)
    ddr_rst_i                                 : in std_logic; --200 MHz DDR core clock (connect through BUFG or PLL)
    pcie_clk_p_i                              : in std_logic; --100 MHz PCIe Clock (connect directly to input pin)
    pcie_clk_n_i                              : in std_logic; --100 MHz PCIe Clock
    pcie_rst_n_i                              : in std_logic; --Reset to PCIe core

    -- DDR memory controller interface --
    ddr_aximm_sl_aclk_o                       : out std_logic;
    ddr_aximm_sl_aresetn_o                    : out std_logic;
    -- AXIMM Read Channel
    ddr_aximm_r_sl_i                          : in t_aximm_r_slave_in := cc_dummy_aximm_r_slave_in;
    ddr_aximm_r_sl_o                          : out t_aximm_r_slave_out;
    -- AXIMM Write Channel
    ddr_aximm_w_sl_i                          : in t_aximm_w_slave_in := cc_dummy_aximm_w_slave_in;
    ddr_aximm_w_sl_o                          : out t_aximm_w_slave_out;

    -- Wishbone interface --
    wb_clk_i                                  : in std_logic;
    wb_rst_i                                  : in std_logic;
    wb_ma_i                                   : in  t_wishbone_master_in := cc_dummy_slave_out;
    wb_ma_o                                   : out t_wishbone_master_out;

    -- Additional exported signals for instantiation
    wb_ma_pcie_rst_o                          : out std_logic
  );
  end component;

  --------------------------------------------------------------------
  -- SDB Devices Structures
  --------------------------------------------------------------------

  -- Simple GPIO interface device
  constant c_xwb_gpio32_sdb : t_sdb_device := (
    abi_class     => x"0000",                 -- undocumented device
    abi_ver_major => x"01",
    abi_ver_minor => x"00",
    wbd_endian    => c_sdb_endian_big,
    wbd_width     => x"7",                     -- 8/16/32-bit port granularity (0111)
    sdb_component => (
    addr_first    => x"0000000000000000",
    addr_last     => x"00000000000000FF",     -- Max of 256 pins. Max of 8 32-bit registers
    product => (
    vendor_id     => x"0000000000000651",     -- GSI
    device_id     => x"35aa6b95",
    version       => x"00000001",
    date          => x"20120305",
    name          => "GSI_GPIO_32        ")));

  -- IRQ manager interface device
  constant c_xwb_irqmngr_sdb : t_sdb_device := (
    abi_class     => x"0000",                 -- undocumented device
    abi_ver_major => x"01",
    abi_ver_minor => x"00",
    wbd_endian    => c_sdb_endian_big,
    wbd_width     => x"7",                     -- 8/16/32-bit port granularity (0111)
    sdb_component => (
    addr_first    => x"0000000000000000",
    addr_last     => x"00000000000000FF",
    product => (
    vendor_id     => x"1000000000001215",     -- LNLS
    device_id     => x"15ff65e1",
    version       => x"00000001",
    date          => x"20120903",
    name          => "LNLS_IRQMNGR       ")));

  -- FMC150 Interface
  constant c_xwb_fmc150_sdb : t_sdb_device := (
    abi_class     => x"0000",                 -- undocumented device
    abi_ver_major => x"01",
    abi_ver_minor => x"00",
    wbd_endian    => c_sdb_endian_big,
    wbd_width     => x"7",                     -- 8/16/32-bit port granularity (0111)
    sdb_component => (
    addr_first    => x"0000000000000000",
    addr_last     => x"00000000000000FF",
    product => (
    vendor_id     => x"1000000000001215",     -- LNLS
    device_id     => x"f8c150c1",
    version       => x"00000001",
    date          => x"20121010",
    name          => "LNLS_FMC150        ")));

  -- FMC516 Interface
  --constant c_xwb_fmc516_sdb : t_sdb_device := (
  --  abi_class     => x"0000",                 -- undocumented device
  --  abi_ver_major => x"01",
  --  abi_ver_minor => x"00",
  --  wbd_endian    => c_sdb_endian_big,
  --  wbd_width     => x"7",                     -- 8/16/32-bit port granularity (0111)
  --  sdb_component => (
  --  addr_first    => x"0000000000000000",
  --  addr_last     => x"0000000000000FFF",   -- Too much addresses? Probably...
  --  product => (
  --  vendor_id     => x"1000000000001215",     -- LNLS
  --  device_id     => x"64f2a9ba",
  --  version       => x"00000001",
  --  date          => x"20121124",
  --  name          => "LNLS_FMC516        ")));

  -- UART Interface
  constant c_xwb_uart_sdb : t_sdb_device := (
    abi_class     => x"0000",                 -- undocumented device
    abi_ver_major => x"01",
    abi_ver_minor => x"00",
    wbd_endian    => c_sdb_endian_big,
    wbd_width     => x"1",                     -- 8-bit port granularity (0001)
    sdb_component => (
    addr_first    => x"0000000000000000",
    addr_last     => x"00000000000000FF",
    product => (
    vendor_id     => x"000000000000CE42",     -- CERN
    device_id     => x"8a5719ae",
    version       => x"00000001",
    date          => x"20121011",
    name          => "CERN_SIMPLE_UART   ")));

  -- SPI Opencores Interface
  constant c_xwb_spi_sdb : t_sdb_device := (
    abi_class     => x"0000",                 -- undocumented device
    abi_ver_major => x"01",
    abi_ver_minor => x"00",
    wbd_endian    => c_sdb_endian_big,
    wbd_width     => x"7",                     -- 8/16/32-bit port granularity (0111)
    sdb_component => (
    addr_first    => x"0000000000000000",
    addr_last     => x"00000000000000FF",
    product => (
    vendor_id     => x"100000004E2C05E5",     -- OpenCores
    device_id     => x"40286417",
    version       => x"00000001",
    date          => x"20121124",
    name          => "OCORES_SPI         ")));

  -- Simple TICs counter Interface
  constant c_xwb_tics_counter_sdb : t_sdb_device := (
    abi_class     => x"0000",                 -- undocumented device
    abi_ver_major => x"01",
    abi_ver_minor => x"00",
    wbd_endian    => c_sdb_endian_big,
    wbd_width     => x"4",                     -- 8/16/32-bit port granularity (0100)
    sdb_component => (
    addr_first    => x"0000000000000000",
    addr_last     => x"000000000000000F",
    product => (
    vendor_id     => x"000000000000CE42",     -- CERN
    device_id     => x"FDAFB9DD",
    version       => x"00000001",
    date          => x"20130225",
    name          => "CERN_TICS_COUNTER  ")));

  -- AFC Diagnostics interface device
  constant c_xwb_afc_diag_sdb : t_sdb_device := (
    abi_class     => x"0000",                 -- undocumented device
    abi_ver_major => x"01",
    abi_ver_minor => x"00",
    wbd_endian    => c_sdb_endian_big,
    wbd_width     => x"7",                     -- 8/16/32-bit port granularity (0111)
    sdb_component => (
    addr_first    => x"0000000000000000",
    addr_last     => x"00000000000000FF",
    product => (
    vendor_id     => x"1000000000001215",     -- LNLS
    device_id     => x"51954750",
    version       => x"00000001",
    date          => x"20150309",
    name          => "LNLS_AFCDIAG       ")));

end dbe_wishbone_pkg;
