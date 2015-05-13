#######################################################################
##                      Artix 7 AMC V3                               ##
#######################################################################

# All timing constraint translations are rough conversions, intended to act as a template for further manual refinement. The translations should not be expected to produce semantically identical results to the original ucf. Each xdc timing constraint must be manually inspected and verified to ensure it captures the desired intent

# In xdc, all clocks are related by default. This differs from ucf, where clocks are unrelated unless specified otherwise. As a result, you may now see cross-clock paths that were previously unconstrained in ucf. Commented out xdc false path constraints have been generated and can be uncommented, should you wish to remove these new paths. These commands are located after the last clock definition

#// FPGA_CLK1_P
set_property IOSTANDARD DIFF_SSTL15 [get_ports sys_clk_p_i]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports sys_clk_p_i]
#// FPGA_CLK1_N
set_property PACKAGE_PIN AL7 [get_ports sys_clk_n_i]
set_property IOSTANDARD DIFF_SSTL15 [get_ports sys_clk_n_i]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports sys_clk_n_i]

#// TXD		IO_25_34
set_property PACKAGE_PIN AB11 [get_ports rs232_txd_o]
set_property IOSTANDARD LVCMOS25 [get_ports rs232_txd_o]
#// VADJ1_RXD	IO_0_34
set_property PACKAGE_PIN Y11 [get_ports rs232_rxd_i]
set_property IOSTANDARD LVCMOS25 [get_ports rs232_rxd_i]

# System Reset
# Bank 16 VCCO - VADJ_FPGA - IO_25_16. NET = FPGA_RESET_DN, PIN = IO_L19P_T3_13
set_false_path -through [get_nets sys_rst_button_n_i]
set_property PACKAGE_PIN AG26 [get_ports sys_rst_button_n_i]
set_property IOSTANDARD LVCMOS25 [get_ports sys_rst_button_n_i]
set_property PULLUP true [get_ports sys_rst_button_n_i]

#######################################################################
##                      AFC Diagnostics Contraints                   ##
#######################################################################

set_property PACKAGE_PIN J9 [get_ports diag_spi_cs_i]
set_property IOSTANDARD LVCMOS25 [get_ports diag_spi_cs_i]

set_property PACKAGE_PIN V28 [get_ports diag_spi_si_i]
set_property IOSTANDARD LVCMOS25 [get_ports diag_spi_si_i]

set_property PACKAGE_PIN V29 [get_ports diag_spi_so_o]
set_property IOSTANDARD LVCMOS25 [get_ports diag_spi_so_o]

set_property PACKAGE_PIN J8 [get_ports diag_spi_clk_i]
set_property IOSTANDARD LVCMOS25 [get_ports diag_spi_clk_i]

#######################################################################
##                      FMC Connector HPC1                           ##
#######################################################################

###NET  "fmc1_prsnt_i"                            LOC =  | IOSTANDARD = "LVCMOS25";   // Connected to CPU
###NET  "fmc1_pg_m2c_i"                           LOC =  | IOSTANDARD = "LVCMOS25";   // Connected to CPU

#// Trigger
#// LA28_P
set_property PACKAGE_PIN T8 [get_ports fmc1_trig_dir_o]
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_trig_dir_o]
#// LA26_N
set_property PACKAGE_PIN T3 [get_ports fmc1_trig_term_o]
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_trig_term_o]
#// LA32_P
set_property PACKAGE_PIN R1 [get_ports fmc1_trig_val_p_b]
set_property IOSTANDARD BLVDS_25 [get_ports fmc1_trig_val_p_b]
#// LA32_N
set_property PACKAGE_PIN P1 [get_ports fmc1_trig_val_n_b]
set_property IOSTANDARD BLVDS_25 [get_ports fmc1_trig_val_n_b]

#// Si571 clock gen
#// HA12_N
set_property PACKAGE_PIN G34 [get_ports fmc1_si571_scl_pad_b]
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_si571_scl_pad_b]
#// HA13_P
set_property PACKAGE_PIN K25 [get_ports fmc1_si571_sda_pad_b]
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_si571_sda_pad_b]
#// HA12_P
set_property PACKAGE_PIN H33 [get_ports fmc1_si571_oe_o]
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_si571_oe_o]

#// AD9510 clock distribution PLL
#// LA13_N
set_property PACKAGE_PIN G9 [get_ports fmc1_spi_ad9510_cs_o]
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_spi_ad9510_cs_o]
#// LA13_P
set_property PACKAGE_PIN G10 [get_ports fmc1_spi_ad9510_sclk_o]
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_spi_ad9510_sclk_o]
#// LA09_N
set_property PACKAGE_PIN J3 [get_ports fmc1_spi_ad9510_mosi_o]
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_spi_ad9510_mosi_o]
#// LA14_P
set_property PACKAGE_PIN H9 [get_ports fmc1_spi_ad9510_miso_i]
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_spi_ad9510_miso_i]
#// LA14_N
set_property PACKAGE_PIN H8 [get_ports fmc1_pll_function_o]
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_pll_function_o]
#// LA09_P
set_property PACKAGE_PIN J4 [get_ports fmc1_pll_status_i]
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_pll_status_i]

#NET "fmc1_fpga_clk_p_i"                        LOC = H7  | IOSTANDARD = "LVDS_25";  // CLK0_M2C_P
#NET "fmc1_fpga_clk_n_i"                        LOC = H6  | IOSTANDARD = "LVDS_25";  // CLK0_M2C_N

#// Clock reference selection (TS3USB221)
#// LA31_P
set_property PACKAGE_PIN U7 [get_ports fmc1_clk_sel_o]
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_clk_sel_o]

#// EEPROM (multiplexer PCA9548) (Connected to the CPU)
# FPGA I2C SCL
set_property PACKAGE_PIN P6 [get_ports fmc1_eeprom_scl_pad_b]
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_eeprom_scl_pad_b]
# FPGA I2C SDA
set_property PACKAGE_PIN R11 [get_ports fmc1_eeprom_sda_pad_b]
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_eeprom_sda_pad_b]

#// LM75 temperature monitor
#// LA27_P
set_property PACKAGE_PIN R3 [get_ports fmc1_lm75_scl_pad_b]
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_lm75_scl_pad_b]
#// LA27_N
set_property PACKAGE_PIN R2 [get_ports fmc1_lm75_sda_pad_b]
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_lm75_sda_pad_b]
#// LA28_N
set_property PACKAGE_PIN T7 [get_ports fmc1_lm75_temp_alarm_i]
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_lm75_temp_alarm_i]

#// LTC ADC control pins
#// LA06_P
set_property PACKAGE_PIN L5 [get_ports fmc1_adc_pga_o]
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_adc_pga_o]
#// LA10_N
set_property PACKAGE_PIN G2 [get_ports fmc1_adc_shdn_o]
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_adc_shdn_o]
#// LA10_P
set_property PACKAGE_PIN H2 [get_ports fmc1_adc_dith_o]
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_adc_dith_o]
#// LA06_N
set_property PACKAGE_PIN K5 [get_ports fmc1_adc_rand_o]
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_adc_rand_o]

#// LEDs
#// LA16_N
set_property PACKAGE_PIN L9 [get_ports fmc1_led1_o]
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_led1_o]
#// LA16_P
set_property PACKAGE_PIN L10 [get_ports fmc1_led2_o]
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_led2_o]
#// LA26_P
set_property PACKAGE_PIN T2 [get_ports fmc1_led3_o]
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_led3_o]

#######################################################################
##                      FMC Connector HPC2                           ##
#######################################################################

#NET  "fmc2_prsnt_i"                            LOC =  | IOSTANDARD = "LVCMOS25";//  Connected to CPU
#NET  "fmc2_pg_m2c_i"                           LOC =  | IOSTANDARD = "LVCMOS25";//  Connected to CPU

#// Trigger
#// LA28_P
set_property PACKAGE_PIN W28 [get_ports fmc2_trig_dir_o]
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_trig_dir_o]
#// LA26_N
set_property PACKAGE_PIN AC31 [get_ports fmc2_trig_term_o]
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_trig_term_o]
#// LA32_P
set_property PACKAGE_PIN AA34 [get_ports fmc2_trig_val_p_b]
set_property IOSTANDARD BLVDS_25 [get_ports fmc2_trig_val_p_b]
#// LA32_N
set_property PACKAGE_PIN AB34 [get_ports fmc2_trig_val_n_b]
set_property IOSTANDARD BLVDS_25 [get_ports fmc2_trig_val_n_b]

#// Si571 clock gen
#// HA12_N
set_property PACKAGE_PIN AN29 [get_ports fmc2_si571_scl_pad_b]
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_si571_scl_pad_b]
#// HA13_P
set_property PACKAGE_PIN AN28 [get_ports fmc2_si571_sda_pad_b]
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_si571_sda_pad_b]
#// HA12_P
set_property PACKAGE_PIN AM29 [get_ports fmc2_si571_oe_o]
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_si571_oe_o]

#// AD9510 clock distribution PLL
#// LA13_N
set_property PACKAGE_PIN AG34 [get_ports fmc2_spi_ad9510_cs_o]
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_spi_ad9510_cs_o]
#// LA13_P
set_property PACKAGE_PIN AF34 [get_ports fmc2_spi_ad9510_sclk_o]
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_spi_ad9510_sclk_o]
#// LA09_N
set_property PACKAGE_PIN AG25 [get_ports fmc2_spi_ad9510_mosi_o]
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_spi_ad9510_mosi_o]
#// LA14_P
set_property PACKAGE_PIN AE33 [get_ports fmc2_spi_ad9510_miso_i]
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_spi_ad9510_miso_i]
#// LA14_N
set_property PACKAGE_PIN AF33 [get_ports fmc2_pll_function_o]
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_pll_function_o]
#// LA09_P
set_property PACKAGE_PIN AF25 [get_ports fmc2_pll_status_i]
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_pll_status_i]

#NET "fmc2_fpga_clk_p_i"                       LOC = AA30 | IOSTANDARD = "LVDS_25";  // CLK0_M2C_P
#NET "fmc2_fpga_clk_n_i"                       LOC = AB30 | IOSTANDARD = "LVDS_25";  // CLK0_M2C_N

#// Clock reference selection (TS3USB221)
#// LA31_P
set_property PACKAGE_PIN V31 [get_ports fmc2_clk_sel_o]
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_clk_sel_o]

#// EEPROM (multiplexer PCA9548) (Connected to the CPU)
# NET "eeprom_scl_pad_b"                        LOC =  | IOSTANDARD ="LVCMOS25"; #  SCL C30
# NET "eeprom_sda_pad_b"                        LOC =  | IOSTANDARD ="LVCMOS25"; #  SDA C31

#// LM75 temperature monitor
#// LA27_P
set_property PACKAGE_PIN AA27 [get_ports fmc2_lm75_scl_pad_b]
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_lm75_scl_pad_b]
#// LA27_N
set_property PACKAGE_PIN AA28 [get_ports fmc2_lm75_sda_pad_b]
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_lm75_sda_pad_b]
#// LA28_N
set_property PACKAGE_PIN W29 [get_ports fmc2_lm75_temp_alarm_i]
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_lm75_temp_alarm_i]

#// LTC ADC control pins
#// LA06_P
set_property PACKAGE_PIN AE23 [get_ports fmc2_adc_pga_o]
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_adc_pga_o]
#// LA10_N
set_property PACKAGE_PIN AH32 [get_ports fmc2_adc_shdn_o]
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_adc_shdn_o]
#// LA10_P
set_property PACKAGE_PIN AG32 [get_ports fmc2_adc_dith_o]
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_adc_dith_o]
#// LA06_N
set_property PACKAGE_PIN AF23 [get_ports fmc2_adc_rand_o]
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_adc_rand_o]

#// LEDs
#// LA16_N
set_property PACKAGE_PIN AD34 [get_ports fmc2_led1_o]
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_led1_o]
#// LA16_P
set_property PACKAGE_PIN AD33 [get_ports fmc2_led2_o]
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_led2_o]
#// LA26_P
set_property PACKAGE_PIN AC32 [get_ports fmc2_led3_o]
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_led3_o]

#######################################################################
##                       FMC Connector HPC1                           #
##                         LTC ADC lines                              #
#######################################################################

#// ADC0
#// LA17_CC_P
set_property PACKAGE_PIN T5 [get_ports fmc1_adc0_clk_i]
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_adc0_clk_i]

#// LA24_P
set_property PACKAGE_PIN M11 [get_ports {fmc1_adc0_data_i[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc0_data_i[0]}]
#// LA24_N
set_property PACKAGE_PIN M10 [get_ports {fmc1_adc0_data_i[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc0_data_i[1]}]
#// LA25_P
set_property PACKAGE_PIN N8 [get_ports {fmc1_adc0_data_i[2]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc0_data_i[2]}]
#// LA25_N
set_property PACKAGE_PIN N7 [get_ports {fmc1_adc0_data_i[3]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc0_data_i[3]}]
#// LA21_P
set_property PACKAGE_PIN M7 [get_ports {fmc1_adc0_data_i[4]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc0_data_i[4]}]
#// LA21_N
set_property PACKAGE_PIN M6 [get_ports {fmc1_adc0_data_i[5]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc0_data_i[5]}]
#// LA22_P
set_property PACKAGE_PIN M5 [get_ports {fmc1_adc0_data_i[6]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc0_data_i[6]}]
#// LA22_N
set_property PACKAGE_PIN M4 [get_ports {fmc1_adc0_data_i[7]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc0_data_i[7]}]
#// LA23_N
set_property PACKAGE_PIN N2 [get_ports {fmc1_adc0_data_i[8]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc0_data_i[8]}]
#// LA19_N
set_property PACKAGE_PIN U4 [get_ports {fmc1_adc0_data_i[9]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc0_data_i[9]}]
#// LA18_CC_N
set_property PACKAGE_PIN P3 [get_ports {fmc1_adc0_data_i[10]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc0_data_i[10]}]
#// LA23_P
set_property PACKAGE_PIN N3 [get_ports {fmc1_adc0_data_i[11]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc0_data_i[11]}]
#// LA20_N
set_property PACKAGE_PIN P10 [get_ports {fmc1_adc0_data_i[12]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc0_data_i[12]}]
#// LA19_P
set_property PACKAGE_PIN U5 [get_ports {fmc1_adc0_data_i[13]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc0_data_i[13]}]
#// LA18_CC_P
set_property PACKAGE_PIN P4 [get_ports {fmc1_adc0_data_i[14]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc0_data_i[14]}]
#// LA20_P
set_property PACKAGE_PIN R10 [get_ports {fmc1_adc0_data_i[15]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc0_data_i[15]}]
#// LA29_P
set_property PACKAGE_PIN P9 [get_ports fmc1_adc0_of_i]
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_adc0_of_i]

#// ADC1
#// HA17_CC_P
set_property PACKAGE_PIN J28 [get_ports fmc1_adc1_clk_i]
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_adc1_clk_i]

#// HA10_P
set_property PACKAGE_PIN H32 [get_ports {fmc1_adc1_data_i[15]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc1_data_i[15]}]
#// HA11_P
set_property PACKAGE_PIN M25 [get_ports {fmc1_adc1_data_i[14]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc1_data_i[14]}]
#// HA10_N
set_property PACKAGE_PIN G32 [get_ports {fmc1_adc1_data_i[13]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc1_data_i[13]}]
#// HA11_N
set_property PACKAGE_PIN L25 [get_ports {fmc1_adc1_data_i[12]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc1_data_i[12]}]
#// HA15_P
set_property PACKAGE_PIN G29 [get_ports {fmc1_adc1_data_i[11]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc1_data_i[11]}]
#// HA14_P
set_property PACKAGE_PIN M24 [get_ports {fmc1_adc1_data_i[10]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc1_data_i[10]}]
#// HA15_N
set_property PACKAGE_PIN G30 [get_ports {fmc1_adc1_data_i[9]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc1_data_i[9]}]
#// HA14_N
set_property PACKAGE_PIN L24 [get_ports {fmc1_adc1_data_i[8]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc1_data_i[8]}]
#// HA18_N
set_property PACKAGE_PIN G27 [get_ports {fmc1_adc1_data_i[7]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc1_data_i[7]}]
#// HA18_P
set_property PACKAGE_PIN H27 [get_ports {fmc1_adc1_data_i[6]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc1_data_i[6]}]
#// HA19_N
set_property PACKAGE_PIN G26 [get_ports {fmc1_adc1_data_i[5]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc1_data_i[5]}]
#// HA21_P
set_property PACKAGE_PIN G24 [get_ports {fmc1_adc1_data_i[4]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc1_data_i[4]}]
#// HA22_P
set_property PACKAGE_PIN J24 [get_ports {fmc1_adc1_data_i[3]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc1_data_i[3]}]
#// HA21_N
set_property PACKAGE_PIN G25 [get_ports {fmc1_adc1_data_i[2]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc1_data_i[2]}]
#// HA23_P
set_property PACKAGE_PIN K23 [get_ports {fmc1_adc1_data_i[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc1_data_i[1]}]
#// HA22_N
set_property PACKAGE_PIN H24 [get_ports {fmc1_adc1_data_i[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc1_data_i[0]}]
#// HA23_N
set_property PACKAGE_PIN J23 [get_ports fmc1_adc1_of_i]
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_adc1_of_i]

#// ADC2
#// LA00_CC_P
set_property PACKAGE_PIN K7 [get_ports fmc1_adc2_clk_i]
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_adc2_clk_i]

#// LA01_CC_P
set_property PACKAGE_PIN J6 [get_ports {fmc1_adc2_data_i[15]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc2_data_i[15]}]
#// LA02_P
set_property PACKAGE_PIN G7 [get_ports {fmc1_adc2_data_i[14]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc2_data_i[14]}]
#// LA01_CC_N
set_property PACKAGE_PIN J5 [get_ports {fmc1_adc2_data_i[13]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc2_data_i[13]}]
#// LA02_N
set_property PACKAGE_PIN G6 [get_ports {fmc1_adc2_data_i[12]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc2_data_i[12]}]
#// LA03_N
set_property PACKAGE_PIN G1 [get_ports {fmc1_adc2_data_i[11]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc2_data_i[11]}]
#// LA03_P
set_property PACKAGE_PIN H1 [get_ports {fmc1_adc2_data_i[10]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc2_data_i[10]}]
#// LA04_N
set_property PACKAGE_PIN J1 [get_ports {fmc1_adc2_data_i[9]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc2_data_i[9]}]
#// LA04_P
set_property PACKAGE_PIN K1 [get_ports {fmc1_adc2_data_i[8]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc2_data_i[8]}]
#// LA05_N
set_property PACKAGE_PIN H3 [get_ports {fmc1_adc2_data_i[7]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc2_data_i[7]}]
#// LA05_P
set_property PACKAGE_PIN H4 [get_ports {fmc1_adc2_data_i[6]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc2_data_i[6]}]
#// LA08_N
set_property PACKAGE_PIN F2 [get_ports {fmc1_adc2_data_i[5]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc2_data_i[5]}]
#// LA08_P
set_property PACKAGE_PIN F3 [get_ports {fmc1_adc2_data_i[4]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc2_data_i[4]}]
#// LA07_N
set_property PACKAGE_PIN K2 [get_ports {fmc1_adc2_data_i[3]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc2_data_i[3]}]
#// LA07_P
set_property PACKAGE_PIN K3 [get_ports {fmc1_adc2_data_i[2]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc2_data_i[2]}]
#// LA12_N
set_property PACKAGE_PIN K8 [get_ports {fmc1_adc2_data_i[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc2_data_i[1]}]
#// LA12_P
set_property PACKAGE_PIN L8 [get_ports {fmc1_adc2_data_i[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc2_data_i[0]}]
#// LA11_P
set_property PACKAGE_PIN M2 [get_ports fmc1_adc2_of_i]
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_adc2_of_i]

#// ADC3
#// HA01_CC_P
set_property PACKAGE_PIN L28 [get_ports fmc1_adc3_clk_i]
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_adc3_clk_i]

#// HA00_CC_N
set_property PACKAGE_PIN H29 [get_ports {fmc1_adc3_data_i[15]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc3_data_i[15]}]
#// HA00_CC_P
set_property PACKAGE_PIN J29 [get_ports {fmc1_adc3_data_i[14]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc3_data_i[14]}]
#// HA05_N
set_property PACKAGE_PIN H34 [get_ports {fmc1_adc3_data_i[13]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc3_data_i[13]}]
#// HA05_P
set_property PACKAGE_PIN J33 [get_ports {fmc1_adc3_data_i[12]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc3_data_i[12]}]
#// HA04_N
set_property PACKAGE_PIN L34 [get_ports {fmc1_adc3_data_i[11]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc3_data_i[11]}]
#// HA04_P
set_property PACKAGE_PIN L33 [get_ports {fmc1_adc3_data_i[10]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc3_data_i[10]}]
#// HA09_N
set_property PACKAGE_PIN J31 [get_ports {fmc1_adc3_data_i[9]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc3_data_i[9]}]
#// HA09_P
set_property PACKAGE_PIN K31 [get_ports {fmc1_adc3_data_i[8]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc3_data_i[8]}]
#// HA03_N
set_property PACKAGE_PIN J30 [get_ports {fmc1_adc3_data_i[7]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc3_data_i[7]}]
#// HA03_P
set_property PACKAGE_PIN K30 [get_ports {fmc1_adc3_data_i[6]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc3_data_i[6]}]
#// HA08_P
set_property PACKAGE_PIN L29 [get_ports {fmc1_adc3_data_i[5]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc3_data_i[5]}]
#// HA02_P
set_property PACKAGE_PIN K33 [get_ports {fmc1_adc3_data_i[4]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc3_data_i[4]}]
#// HA07_P
set_property PACKAGE_PIN L32 [get_ports {fmc1_adc3_data_i[3]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc3_data_i[3]}]
#// HA02_N
set_property PACKAGE_PIN J34 [get_ports {fmc1_adc3_data_i[2]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc3_data_i[2]}]
#// HA06_P
set_property PACKAGE_PIN L27 [get_ports {fmc1_adc3_data_i[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc3_data_i[1]}]
#// HA07_N
set_property PACKAGE_PIN K32 [get_ports {fmc1_adc3_data_i[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc3_data_i[0]}]
#// HA06_N
set_property PACKAGE_PIN K27 [get_ports fmc1_adc3_of_i]
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_adc3_of_i]

#######################################################################
##                       FMC Connector HPC2                           #
##                         LTC ADC lines                              #
#######################################################################

#// ADC0
#// LA17_CC_P
set_property PACKAGE_PIN AB31 [get_ports fmc2_adc0_clk_i]
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_adc0_clk_i]

#// LA24_P
set_property PACKAGE_PIN Y32 [get_ports {fmc2_adc0_data_i[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc0_data_i[0]}]
#// LA24_N
set_property PACKAGE_PIN Y33 [get_ports {fmc2_adc0_data_i[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc0_data_i[1]}]
#// LA25_P
set_property PACKAGE_PIN AA29 [get_ports {fmc2_adc0_data_i[2]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc0_data_i[2]}]
#// LA25_N
set_property PACKAGE_PIN AB29 [get_ports {fmc2_adc0_data_i[3]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc0_data_i[3]}]
#// LA21_P
set_property PACKAGE_PIN AA32 [get_ports {fmc2_adc0_data_i[4]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc0_data_i[4]}]
#// LA21_N
set_property PACKAGE_PIN AA33 [get_ports {fmc2_adc0_data_i[5]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc0_data_i[5]}]
#// LA22_P
set_property PACKAGE_PIN AA24 [get_ports {fmc2_adc0_data_i[6]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc0_data_i[6]}]
#// LA22_N
set_property PACKAGE_PIN AA25 [get_ports {fmc2_adc0_data_i[7]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc0_data_i[7]}]
#// LA23_N
set_property PACKAGE_PIN Y25 [get_ports {fmc2_adc0_data_i[8]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc0_data_i[8]}]
#// LA19_N
set_property PACKAGE_PIN AB27 [get_ports {fmc2_adc0_data_i[9]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc0_data_i[9]}]
#// LA18_CC_N
set_property PACKAGE_PIN W31 [get_ports {fmc2_adc0_data_i[10]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc0_data_i[10]}]
#// LA23_P
set_property PACKAGE_PIN W25 [get_ports {fmc2_adc0_data_i[11]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc0_data_i[11]}]
#// LA20_N
set_property PACKAGE_PIN AB25 [get_ports {fmc2_adc0_data_i[12]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc0_data_i[12]}]
#// LA19_P
set_property PACKAGE_PIN AB26 [get_ports {fmc2_adc0_data_i[13]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc0_data_i[13]}]
#// LA18_CC_P
set_property PACKAGE_PIN W30 [get_ports {fmc2_adc0_data_i[14]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc0_data_i[14]}]
#// LA20_P
set_property PACKAGE_PIN AB24 [get_ports {fmc2_adc0_data_i[15]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc0_data_i[15]}]
#// LA29_P
set_property PACKAGE_PIN AC33 [get_ports fmc2_adc0_of_i]
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_adc0_of_i]

#// ADC1
#// HA17_CC_P
set_property PACKAGE_PIN AJ28 [get_ports fmc2_adc1_clk_i]
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_adc1_clk_i]

#// HA10_P
set_property PACKAGE_PIN AP25 [get_ports {fmc2_adc1_data_i[15]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc1_data_i[15]}]
#// HA11_P
set_property PACKAGE_PIN AK33 [get_ports {fmc2_adc1_data_i[14]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc1_data_i[14]}]
#// HA10_N
set_property PACKAGE_PIN AP26 [get_ports {fmc2_adc1_data_i[13]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc1_data_i[13]}]
#// HA11_N
set_property PACKAGE_PIN AL33 [get_ports {fmc2_adc1_data_i[12]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc1_data_i[12]}]
#// HA15_P
set_property PACKAGE_PIN AJ29 [get_ports {fmc2_adc1_data_i[11]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc1_data_i[11]}]
#// HA14_P
set_property PACKAGE_PIN AN34 [get_ports {fmc2_adc1_data_i[10]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc1_data_i[10]}]
#// HA15_N
set_property PACKAGE_PIN AK30 [get_ports {fmc2_adc1_data_i[9]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc1_data_i[9]}]
#// HA14_N
set_property PACKAGE_PIN AP34 [get_ports {fmc2_adc1_data_i[8]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc1_data_i[8]}]
#// HA18_N
set_property PACKAGE_PIN AP33 [get_ports {fmc2_adc1_data_i[7]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc1_data_i[7]}]
#// HA18_P
set_property PACKAGE_PIN AN33 [get_ports {fmc2_adc1_data_i[6]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc1_data_i[6]}]
#// HA19_N
set_property PACKAGE_PIN AK31 [get_ports {fmc2_adc1_data_i[5]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc1_data_i[5]}]
#// HA21_P
set_property PACKAGE_PIN AP29 [get_ports {fmc2_adc1_data_i[4]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc1_data_i[4]}]
#// HA22_P
set_property PACKAGE_PIN AL34 [get_ports {fmc2_adc1_data_i[3]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc1_data_i[3]}]
#// HA21_N
set_property PACKAGE_PIN AP30 [get_ports {fmc2_adc1_data_i[2]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc1_data_i[2]}]
#// HA23_P
set_property PACKAGE_PIN AJ33 [get_ports {fmc2_adc1_data_i[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc1_data_i[1]}]
#// HA22_N
set_property PACKAGE_PIN AM34 [get_ports {fmc2_adc1_data_i[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc1_data_i[0]}]
#// HA23_N
set_property PACKAGE_PIN AJ34 [get_ports fmc2_adc1_of_i]
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_adc1_of_i]

#// ADC2
#// LA00_CC_P
set_property PACKAGE_PIN AE28 [get_ports fmc2_adc2_clk_i]
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_adc2_clk_i]

#// LA01_CC_P
set_property PACKAGE_PIN AF29 [get_ports {fmc2_adc2_data_i[15]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc2_data_i[15]}]
#// LA02_P
set_property PACKAGE_PIN AG31 [get_ports {fmc2_adc2_data_i[14]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc2_data_i[14]}]
#// LA01_CC_N
set_property PACKAGE_PIN AF30 [get_ports {fmc2_adc2_data_i[13]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc2_data_i[13]}]
#// LA02_N
set_property PACKAGE_PIN AH31 [get_ports {fmc2_adc2_data_i[12]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc2_data_i[12]}]
#// LA03_N
set_property PACKAGE_PIN AH24 [get_ports {fmc2_adc2_data_i[11]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc2_data_i[11]}]
#// LA03_P
set_property PACKAGE_PIN AG24 [get_ports {fmc2_adc2_data_i[10]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc2_data_i[10]}]
#// LA04_N
set_property PACKAGE_PIN AC27 [get_ports {fmc2_adc2_data_i[9]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc2_data_i[9]}]
#// LA04_P
set_property PACKAGE_PIN AC26 [get_ports {fmc2_adc2_data_i[8]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc2_data_i[8]}]
#// LA05_N
set_property PACKAGE_PIN AH34 [get_ports {fmc2_adc2_data_i[7]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc2_data_i[7]}]
#// LA05_P
set_property PACKAGE_PIN AH33 [get_ports {fmc2_adc2_data_i[6]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc2_data_i[6]}]
#// LA08_N
set_property PACKAGE_PIN AE25 [get_ports {fmc2_adc2_data_i[5]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc2_data_i[5]}]
#// LA08_P
set_property PACKAGE_PIN AD25 [get_ports {fmc2_adc2_data_i[4]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc2_data_i[4]}]
#// LA07_N
set_property PACKAGE_PIN AH27 [get_ports {fmc2_adc2_data_i[3]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc2_data_i[3]}]
#// LA07_P
set_property PACKAGE_PIN AG27 [get_ports {fmc2_adc2_data_i[2]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc2_data_i[2]}]
#// LA12_N
set_property PACKAGE_PIN AF27 [get_ports {fmc2_adc2_data_i[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc2_data_i[1]}]
#// LA12_P
set_property PACKAGE_PIN AE27 [get_ports {fmc2_adc2_data_i[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc2_data_i[0]}]
#// LA11_P
set_property PACKAGE_PIN AD30 [get_ports fmc2_adc2_of_i]
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_adc2_of_i]

#// ADC3
#// HA01_CC_P
set_property PACKAGE_PIN AL28 [get_ports fmc2_adc3_clk_i]
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_adc3_clk_i]

#// HA00_CC_N
set_property PACKAGE_PIN AM30 [get_ports {fmc2_adc3_data_i[15]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc3_data_i[15]}]
#// HA00_CC_P
set_property PACKAGE_PIN AL30 [get_ports {fmc2_adc3_data_i[14]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc3_data_i[14]}]
#// HA05_N
set_property PACKAGE_PIN AM25 [get_ports {fmc2_adc3_data_i[13]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc3_data_i[13]}]
#// HA05_P
set_property PACKAGE_PIN AL25 [get_ports {fmc2_adc3_data_i[12]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc3_data_i[12]}]
#// HA04_N
set_property PACKAGE_PIN AK25 [get_ports {fmc2_adc3_data_i[11]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc3_data_i[11]}]
#// HA04_P
set_property PACKAGE_PIN AJ25 [get_ports {fmc2_adc3_data_i[10]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc3_data_i[10]}]
#// HA09_N
set_property PACKAGE_PIN AK26 [get_ports {fmc2_adc3_data_i[9]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc3_data_i[9]}]
#// HA09_P
set_property PACKAGE_PIN AJ26 [get_ports {fmc2_adc3_data_i[8]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc3_data_i[8]}]
#// HA03_N
set_property PACKAGE_PIN AN26 [get_ports {fmc2_adc3_data_i[7]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc3_data_i[7]}]
#// HA03_P
set_property PACKAGE_PIN AM26 [get_ports {fmc2_adc3_data_i[6]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc3_data_i[6]}]
#// HA08_P
set_property PACKAGE_PIN AM27 [get_ports {fmc2_adc3_data_i[5]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc3_data_i[5]}]
#// HA02_P
set_property PACKAGE_PIN AN31 [get_ports {fmc2_adc3_data_i[4]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc3_data_i[4]}]
#// HA07_P
set_property PACKAGE_PIN AM31 [get_ports {fmc2_adc3_data_i[3]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc3_data_i[3]}]
#// HA02_N
set_property PACKAGE_PIN AP31 [get_ports {fmc2_adc3_data_i[2]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc3_data_i[2]}]
#// HA06_P
set_property PACKAGE_PIN AL32 [get_ports {fmc2_adc3_data_i[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc3_data_i[1]}]
#// HA07_N
set_property PACKAGE_PIN AN32 [get_ports {fmc2_adc3_data_i[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc3_data_i[0]}]
#// HA06_N
set_property PACKAGE_PIN AM32 [get_ports fmc2_adc3_of_i]
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_adc3_of_i]

#######################################################################
##               Pinout and Related I/O Constraints                  ##
#######################################################################

# On ML605 kit, all clock pins are assigned to MRCC pins. However, two of them
# (fmc_adc1_clk and fmc_adc3_clk) are located in the outer left/right column
# I/Os. These locations cannot connect to BUFG primitives, only inner (center)
# left/right column I/Os on the same half top/bottom can!
#
# For 7-series FPGAs there is no such impediment, apparently.

#######################################################################
##                         DIFF TERM                                 ##
#######################################################################

set_property DIFF_TERM TRUE [get_ports fmc1_trig_val_p_b]
set_property DIFF_TERM TRUE [get_ports fmc1_trig_val_n_b]

set_property DIFF_TERM TRUE [get_ports fmc2_trig_val_p_b]
set_property DIFF_TERM TRUE [get_ports fmc2_trig_val_n_b]

set_property DIFF_TERM TRUE [get_ports fmc1_fpga_clk_p_i]
set_property DIFF_TERM TRUE [get_ports fmc1_fpga_clk_n_i]

set_property DIFF_TERM TRUE [get_ports fmc2_fpga_clk_p_i]
set_property DIFF_TERM TRUE [get_ports fmc2_fpga_clk_n_i]

#######################################################################
##                    Timing constraints                             ##
#######################################################################

# Overrides default_delay hdl parameter for the VARIABLE mode.
# For Artix7: Average Tap Delay at 200 MHz = 78 ps, at 300 MHz = 52 ps ???
set_property IDELAY_VALUE 0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[7].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[4].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[5].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[8].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[1].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[9].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[2].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[5].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[6].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[9].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[2].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[3].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[7].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[0].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[6].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[3].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[4].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[0].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[8].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[1].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[3].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[4].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[0].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[8].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[1].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[7].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[4].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[5].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[8].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[1].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[9].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[2].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[5].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[6].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[9].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[2].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[3].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[7].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[0].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[6].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[3].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[7].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[0].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[6].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[3].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[4].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[7].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[0].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[8].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[1].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[4].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[5].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[8].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[1].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[9].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[2].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[6].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[5].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[9].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[2].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[6].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[5].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[9].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[2].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[3].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[7].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[0].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[6].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[3].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[4].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[7].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[0].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[8].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[1].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[4].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[5].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[8].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[1].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[9].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[2].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]

# Overrides default_delay hdl parameter
set_property IDELAY_VALUE 26 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_clock_chains[0].gen_clock_chains_check.cmp_fmc_adc_clk/gen_adc_clk_7series_iodelay.gen_adc_clk_var_load_iodelay.cmp_ibufds_clk_iodelay}]
set_property IDELAY_VALUE 26 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_clock_chains[0].gen_clock_chains_check.cmp_fmc_adc_clk/gen_adc_clk_7series_iodelay.gen_adc_clk_var_load_iodelay.cmp_ibufds_clk_iodelay}]
set_property IDELAY_VALUE 26 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_clock_chains[1].gen_clock_chains_check.cmp_fmc_adc_clk/gen_adc_clk_7series_iodelay.gen_adc_clk_var_load_iodelay.cmp_ibufds_clk_iodelay}]
set_property IDELAY_VALUE 27 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_clock_chains[1].gen_clock_chains_check.cmp_fmc_adc_clk/gen_adc_clk_7series_iodelay.gen_adc_clk_var_load_iodelay.cmp_ibufds_clk_iodelay}]
set_property IDELAY_VALUE 27 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_clock_chains[2].gen_clock_chains_check.cmp_fmc_adc_clk/gen_adc_clk_7series_iodelay.gen_adc_clk_var_load_iodelay.cmp_ibufds_clk_iodelay}]
set_property IDELAY_VALUE 27 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_clock_chains[2].gen_clock_chains_check.cmp_fmc_adc_clk/gen_adc_clk_7series_iodelay.gen_adc_clk_var_load_iodelay.cmp_ibufds_clk_iodelay}]
set_property IDELAY_VALUE 26 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_clock_chains[3].gen_clock_chains_check.cmp_fmc_adc_clk/gen_adc_clk_7series_iodelay.gen_adc_clk_var_load_iodelay.cmp_ibufds_clk_iodelay}]
set_property IDELAY_VALUE 26 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_clock_chains[3].gen_clock_chains_check.cmp_fmc_adc_clk/gen_adc_clk_7series_iodelay.gen_adc_clk_var_load_iodelay.cmp_ibufds_clk_iodelay}]

#######################################################################
##                          Clocks                                   ##
#######################################################################

# 125 MHz AMC TCLKB input clock
create_clock -period 8.000 -name sys_clk_p_i [get_ports sys_clk_p_i]

## 100 MHz wihsbone clock
# A PERIOD placed on an internal net will result in a clock defined with an internal source. Any upstream source clock latency will not be analyzed
create_clock -name clk_sys -period 10.000 [get_pins cmp_sys_pll_inst/cmp_clkout0_buf/O]

# 200 MHz DDR3 and IDELAY CONTROL clock
# A PERIOD placed on an internal net will result in a clock defined with an internal source. Any upstream source clock latency will not be analyzed
create_clock -name clk_200mhz -period 5.000 [get_pins cmp_sys_pll_inst/cmp_clkout1_buf/O]

# real jitter is about 22ps peak-to-peak
create_clock -period 8.000 -name fmc1_adc0_clk_i [get_ports fmc1_adc0_clk_i]
set_input_jitter fmc1_adc0_clk_i 0.050
create_clock -period 8.000 -name fmc2_adc0_clk_i [get_ports fmc2_adc0_clk_i]
set_input_jitter fmc2_adc0_clk_i 0.050

create_clock -period 8.000 -name fmc1_adc1_clk_i [get_ports fmc1_adc1_clk_i]
set_input_jitter fmc1_adc1_clk_i 0.050
create_clock -period 8.000 -name fmc2_adc1_clk_i [get_ports fmc2_adc1_clk_i]
set_input_jitter fmc2_adc1_clk_i 0.050

create_clock -period 8.000 -name fmc1_adc2_clk_i [get_ports fmc1_adc2_clk_i]
set_input_jitter fmc1_adc2_clk_i 0.050
create_clock -period 8.000 -name fmc2_adc2_clk_i [get_ports fmc2_adc2_clk_i]
set_input_jitter fmc2_adc2_clk_i 0.050

create_clock -period 8.000 -name fmc1_adc3_clk_i [get_ports fmc1_adc3_clk_i]
set_input_jitter fmc1_adc3_clk_i 0.050
create_clock -period 8.000 -name fmc2_adc3_clk_i [get_ports fmc2_adc3_clk_i]
set_input_jitter fmc2_adc3_clk_i 0.050


#######################################################################
##                         Cross Clock Constraints		     ##
#######################################################################

# Reset synchronization path
set_false_path -through [get_nets cmp_reset/master_rstn]
# DDR 3 temperature monitor reset path
set_max_delay -datapath_only -from [get_cells -hier -filter {NAME =~ *ddr3_infrastructure/rstdiv0_sync_r1_reg*}] -to [get_cells -hier -filter {NAME =~ *temp_mon_enabled.u_tempmon/xadc_supplied_temperature.rst_r1*}] 20.000

#######################################################################
##                                Data                               ##
#######################################################################

# Constraint all IDELAY blocks to the same IDELAY control as the DDR 3, so the tool will replicate it as needed
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[*].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[*].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_clock_chains[*].gen_clock_chains_check.cmp_fmc_adc_clk/gen_adc_clk_7series_iodelay.gen_adc_clk_var_load_iodelay.cmp_ibufds_clk_iodelay}]

set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[*].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[*].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_clock_chains[*].gen_clock_chains_check.cmp_fmc_adc_clk/gen_adc_clk_7series_iodelay.gen_adc_clk_var_load_iodelay.cmp_ibufds_clk_iodelay}]

# including 50ps jitter, for 130MHz clock
# since design uses copy of input ADC clock
# there is additional delay for clock/ data (tC)

set_input_delay -clock [get_clocks fmc1_adc0_clk_i] -max -add_delay -1.000 [get_ports {fmc1_adc0_data_i[*]}]
set_input_delay -clock [get_clocks fmc1_adc0_clk_i] -min -add_delay 7.000  [get_ports {fmc1_adc0_data_i[*]}]
set_input_delay -clock [get_clocks fmc1_adc1_clk_i] -max -add_delay -1.000 [get_ports {fmc1_adc1_data_i[*]}]
set_input_delay -clock [get_clocks fmc1_adc1_clk_i] -min -add_delay 7.000  [get_ports {fmc1_adc1_data_i[*]}]
set_input_delay -clock [get_clocks fmc1_adc2_clk_i] -max -add_delay -1.000 [get_ports {fmc1_adc2_data_i[*]}]
set_input_delay -clock [get_clocks fmc1_adc2_clk_i] -min -add_delay 7.000  [get_ports {fmc1_adc2_data_i[*]}]
set_input_delay -clock [get_clocks fmc1_adc3_clk_i] -max -add_delay -1.000 [get_ports {fmc1_adc3_data_i[*]}]
set_input_delay -clock [get_clocks fmc1_adc3_clk_i] -min -add_delay 7.000  [get_ports {fmc1_adc3_data_i[*]}]

set_input_delay -clock [get_clocks fmc2_adc0_clk_i] -max -add_delay -1.000 [get_ports {fmc2_adc0_data_i[*]}]
set_input_delay -clock [get_clocks fmc2_adc0_clk_i] -min -add_delay 7.000  [get_ports {fmc2_adc0_data_i[*]}]
set_input_delay -clock [get_clocks fmc2_adc1_clk_i] -max -add_delay -1.000 [get_ports {fmc2_adc1_data_i[*]}]
set_input_delay -clock [get_clocks fmc2_adc1_clk_i] -min -add_delay 7.000  [get_ports {fmc2_adc1_data_i[*]}]
set_input_delay -clock [get_clocks fmc2_adc2_clk_i] -max -add_delay -1.000 [get_ports {fmc2_adc2_data_i[*]}]
set_input_delay -clock [get_clocks fmc2_adc2_clk_i] -min -add_delay 7.000  [get_ports {fmc2_adc2_data_i[*]}]
set_input_delay -clock [get_clocks fmc2_adc3_clk_i] -max -add_delay -1.000 [get_ports {fmc2_adc3_data_i[*]}]
set_input_delay -clock [get_clocks fmc2_adc3_clk_i] -min -add_delay 7.000  [get_ports {fmc2_adc3_data_i[*]}]

# Pack all registers into IOBs for better timing
set_property IOB TRUE [get_ports {fmc1_adc0_data_i[*] fmc1_adc1_data_i[*] fmc1_adc2_data_i[*] fmc1_adc3_data_i[*] fmc2_adc0_data_i[*] fmc2_adc1_data_i[*] fmc2_adc2_data_i[*] fmc2_adc3_data_i[*]}]

#######################################################################
##                          PCIe constraints                        ##
#######################################################################

#PCIe clock
#// MGT216_CLK1_N	-> MGTREFCLK0N_216
set_property PACKAGE_PIN G18 [get_ports pcie_clk_n_i]
#// MGT216_CLK1_P	-> MGTREFCLK0P_216
set_property PACKAGE_PIN H18 [get_ports pcie_clk_p_i]
#PCIe lane 0
#// TX216_0_P            -> MGTPTXP0_216
set_property PACKAGE_PIN B23 [get_ports {pci_exp_txp_o[0]}]
#// TX216_0_N            -> MGTPTXN0_216
set_property PACKAGE_PIN A23 [get_ports {pci_exp_txn_o[0]}]
#// RX216_0_P            -> MGTPRXP0_216
set_property PACKAGE_PIN F21 [get_ports {pci_exp_rxp_i[0]}]
#// RX216_0_N            -> MGTPRXN0_216
set_property PACKAGE_PIN E21 [get_ports {pci_exp_rxn_i[0]}]
#PCIe lane 1
#// TX216_1_P            -> MGTPTXP1_216
set_property PACKAGE_PIN D22 [get_ports {pci_exp_txp_o[1]}]
#// TX216_1_N            -> MGTPTXN1_216
set_property PACKAGE_PIN C22 [get_ports {pci_exp_txn_o[1]}]
#// RX216_1_P            -> MGTPRXP1_216
set_property PACKAGE_PIN D20 [get_ports {pci_exp_rxp_i[1]}]
#// RX216_1_N            -> MGTPRXN1_216
set_property PACKAGE_PIN C20 [get_ports {pci_exp_rxn_i[1]}]
#PCIe lane 2
#// TX216_2_P            -> MGTPTXP2_216
set_property PACKAGE_PIN B21 [get_ports {pci_exp_txp_o[2]}]
#// TX216_2_N            -> MGTPTXN2_216
set_property PACKAGE_PIN A21 [get_ports {pci_exp_txn_o[2]}]
#// RX216_2_P            -> MGTPRXP2_216
set_property PACKAGE_PIN F19 [get_ports {pci_exp_rxp_i[2]}]
#// RX216_2_N            -> MGTPRXN2_216
set_property PACKAGE_PIN E19 [get_ports {pci_exp_rxn_i[2]}]
#PCIe lane 3
#// TX216_3_P            -> MGTPTXP3_216
set_property PACKAGE_PIN B19 [get_ports {pci_exp_txp_o[3]}]
#// TX216_3_N            -> MGTPTXN3_216
set_property PACKAGE_PIN A19 [get_ports {pci_exp_txn_o[3]}]
#// RX216_3_P            -> MGTPRXP3_216
set_property PACKAGE_PIN D18 [get_ports {pci_exp_rxp_i[3]}]
#// RX216_3_N            -> MGTPRXN3_216
set_property PACKAGE_PIN C18 [get_ports {pci_exp_rxn_i[3]}]

#######################################################################
# Pinout and Related I/O Constraints
#######################################################################

#######################################################################
# Timing Constraints
#######################################################################
# The following cross clock domain false path constraints can be uncommented in order to mimic ucf constraints behavior (see message at the beginning of this file)
set_false_path -from [get_clocks sys_clk_p_i] -to [get_clocks [list clk_sys clk_200mhz fmc1_adc0_clk_i fmc2_adc0_clk_i fmc1_adc1_clk_i fmc2_adc1_clk_i fmc1_adc2_clk_i fmc2_adc2_clk_i fmc1_adc3_clk_i fmc2_adc3_clk_i pcie_clk clk_125mhz clk_userclk clk_userclk2 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/iserdes_clk_1 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/iserdes_clk_1 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/iserdes_clk_1 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/iserdes_clk_1]]
set_false_path -from [get_clocks clk_sys] -to [get_clocks [list sys_clk_p_i clk_200mhz fmc1_adc0_clk_i fmc2_adc0_clk_i fmc1_adc1_clk_i fmc2_adc1_clk_i fmc1_adc2_clk_i fmc2_adc2_clk_i fmc1_adc3_clk_i fmc2_adc3_clk_i pcie_clk clk_125mhz clk_userclk clk_userclk2 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/iserdes_clk_1 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/iserdes_clk_1 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/iserdes_clk_1 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/iserdes_clk_1]]
set_false_path -from [get_clocks clk_200mhz] -to [get_clocks [list sys_clk_p_i clk_sys fmc1_adc0_clk_i fmc2_adc0_clk_i fmc1_adc1_clk_i fmc2_adc1_clk_i fmc1_adc2_clk_i fmc2_adc2_clk_i fmc1_adc3_clk_i fmc2_adc3_clk_i pcie_clk clk_125mhz clk_userclk clk_userclk2 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/iserdes_clk_1 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/iserdes_clk_1 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/iserdes_clk_1 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/iserdes_clk_1]]
set_false_path -from [get_clocks fmc1_adc0_clk_i] -to [get_clocks [list sys_clk_p_i clk_sys clk_200mhz fmc2_adc0_clk_i fmc1_adc1_clk_i fmc2_adc1_clk_i fmc1_adc2_clk_i fmc2_adc2_clk_i fmc1_adc3_clk_i fmc2_adc3_clk_i pcie_clk clk_125mhz clk_userclk clk_userclk2 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/iserdes_clk_1 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/iserdes_clk_1 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/iserdes_clk_1 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/iserdes_clk_1]]
set_false_path -from [get_clocks fmc2_adc0_clk_i] -to [get_clocks [list sys_clk_p_i clk_sys clk_200mhz fmc1_adc0_clk_i fmc1_adc1_clk_i fmc2_adc1_clk_i fmc1_adc2_clk_i fmc2_adc2_clk_i fmc1_adc3_clk_i fmc2_adc3_clk_i pcie_clk clk_125mhz clk_userclk clk_userclk2 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/iserdes_clk_1 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/iserdes_clk_1 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/iserdes_clk_1 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/iserdes_clk_1]]
set_false_path -from [get_clocks fmc1_adc1_clk_i] -to [get_clocks [list sys_clk_p_i clk_sys clk_200mhz fmc1_adc0_clk_i fmc2_adc0_clk_i fmc2_adc1_clk_i fmc1_adc2_clk_i fmc2_adc2_clk_i fmc1_adc3_clk_i fmc2_adc3_clk_i pcie_clk clk_125mhz clk_userclk clk_userclk2 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/iserdes_clk_1 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/iserdes_clk_1 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/iserdes_clk_1 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/iserdes_clk_1]]
set_false_path -from [get_clocks fmc2_adc1_clk_i] -to [get_clocks [list sys_clk_p_i clk_sys clk_200mhz fmc1_adc0_clk_i fmc2_adc0_clk_i fmc1_adc1_clk_i fmc1_adc2_clk_i fmc2_adc2_clk_i fmc1_adc3_clk_i fmc2_adc3_clk_i pcie_clk clk_125mhz clk_userclk clk_userclk2 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/iserdes_clk_1 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/iserdes_clk_1 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/iserdes_clk_1 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/iserdes_clk_1]]
set_false_path -from [get_clocks fmc1_adc2_clk_i] -to [get_clocks [list sys_clk_p_i clk_sys clk_200mhz fmc1_adc0_clk_i fmc2_adc0_clk_i fmc1_adc1_clk_i fmc2_adc1_clk_i fmc2_adc2_clk_i fmc1_adc3_clk_i fmc2_adc3_clk_i pcie_clk clk_125mhz clk_userclk clk_userclk2 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/iserdes_clk_1 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/iserdes_clk_1 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/iserdes_clk_1 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/iserdes_clk_1]]
set_false_path -from [get_clocks fmc2_adc2_clk_i] -to [get_clocks [list sys_clk_p_i clk_sys clk_200mhz fmc1_adc0_clk_i fmc2_adc0_clk_i fmc1_adc1_clk_i fmc2_adc1_clk_i fmc1_adc2_clk_i fmc1_adc3_clk_i fmc2_adc3_clk_i pcie_clk clk_125mhz clk_userclk clk_userclk2 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/iserdes_clk_1 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/iserdes_clk_1 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/iserdes_clk_1 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/iserdes_clk_1]]
set_false_path -from [get_clocks fmc1_adc3_clk_i] -to [get_clocks [list sys_clk_p_i clk_sys clk_200mhz fmc1_adc0_clk_i fmc2_adc0_clk_i fmc1_adc1_clk_i fmc2_adc1_clk_i fmc1_adc2_clk_i fmc2_adc2_clk_i fmc2_adc3_clk_i pcie_clk clk_125mhz clk_userclk clk_userclk2 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/iserdes_clk_1 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/iserdes_clk_1 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/iserdes_clk_1 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/iserdes_clk_1]]
set_false_path -from [get_clocks fmc2_adc3_clk_i] -to [get_clocks [list sys_clk_p_i clk_sys clk_200mhz fmc1_adc0_clk_i fmc2_adc0_clk_i fmc1_adc1_clk_i fmc2_adc1_clk_i fmc1_adc2_clk_i fmc2_adc2_clk_i fmc1_adc3_clk_i pcie_clk clk_125mhz clk_userclk clk_userclk2 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/iserdes_clk_1 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/iserdes_clk_1 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/iserdes_clk_1 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/iserdes_clk_1]]
set_false_path -from [get_clocks pcie_clk] -to [get_clocks [list sys_clk_p_i clk_sys clk_200mhz fmc1_adc0_clk_i fmc2_adc0_clk_i fmc1_adc1_clk_i fmc2_adc1_clk_i fmc1_adc2_clk_i fmc2_adc2_clk_i fmc1_adc3_clk_i fmc2_adc3_clk_i cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/iserdes_clk_1 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/iserdes_clk_1 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/iserdes_clk_1 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/iserdes_clk_1]]
set_false_path -from [get_clocks clk_125mhz] -to [get_clocks [list sys_clk_p_i clk_sys clk_200mhz fmc1_adc0_clk_i fmc2_adc0_clk_i fmc1_adc1_clk_i fmc2_adc1_clk_i fmc1_adc2_clk_i fmc2_adc2_clk_i fmc1_adc3_clk_i fmc2_adc3_clk_i cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/iserdes_clk_1 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/iserdes_clk_1 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/iserdes_clk_1 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/iserdes_clk_1]]
set_false_path -from [get_clocks clk_userclk] -to [get_clocks [list sys_clk_p_i clk_sys clk_200mhz fmc1_adc0_clk_i fmc2_adc0_clk_i fmc1_adc1_clk_i fmc2_adc1_clk_i fmc1_adc2_clk_i fmc2_adc2_clk_i fmc1_adc3_clk_i fmc2_adc3_clk_i cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/iserdes_clk_1 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/iserdes_clk_1 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/iserdes_clk_1 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/iserdes_clk_1]]
set_false_path -from [get_clocks clk_userclk2] -to [get_clocks [list sys_clk_p_i clk_sys clk_200mhz fmc1_adc0_clk_i fmc2_adc0_clk_i fmc1_adc1_clk_i fmc2_adc1_clk_i fmc1_adc2_clk_i fmc2_adc2_clk_i fmc1_adc3_clk_i fmc2_adc3_clk_i cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/iserdes_clk_1 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/iserdes_clk_1 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/iserdes_clk_1 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/iserdes_clk_1]]
set_false_path -from [get_clocks [list cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/iserdes_clk_1 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/iserdes_clk_1 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/iserdes_clk_1 cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/iserdes_clk_1]] -to [get_clocks [list sys_clk_p_i clk_sys clk_200mhz fmc1_adc0_clk_i fmc2_adc0_clk_i fmc1_adc1_clk_i fmc2_adc1_clk_i fmc1_adc2_clk_i fmc2_adc2_clk_i fmc1_adc3_clk_i fmc2_adc3_clk_i pcie_clk clk_125mhz clk_userclk clk_userclk2]]

# To/From Wishbone To/From ADC/ADC2x. These are just for slow control and don't need to be analyzed
#set_false_path -from [get_clocks clk_sys] -to [get_clocks adc_clk_mmcm_out]
set_max_delay -datapath_only -from [get_clocks clk_sys] -to [get_clocks adc_clk_mmcm_out] 16.000
set_max_delay -datapath_only -from [get_clocks clk_sys] -to [get_clocks adc_clk_mmcm_out_1] 16.000
#set_false_path -from [get_clocks clk_sys] -to [get_clocks adc_clk2x_mmcm_out]
set_max_delay -datapath_only -from [get_clocks clk_sys] -to [get_clocks adc_clk2x_mmcm_out] 8.000
set_max_delay -datapath_only -from [get_clocks clk_sys] -to [get_clocks adc_clk2x_mmcm_out_1] 8.000

#set_false_path -from [get_clocks adc_clk_mmcm_out] -to [get_clocks clk_sys]
set_max_delay -datapath_only -from [get_clocks adc_clk_mmcm_out] -to [get_clocks clk_sys] 20.000
set_max_delay -datapath_only -from [get_clocks adc_clk_mmcm_out_1] -to [get_clocks clk_sys] 20.000
#set_false_path -from [get_clocks adc_clk2x_mmcm_out] -to [get_clocks clk_sys]
set_max_delay -datapath_only -from [get_clocks adc_clk2x_mmcm_out] -to [get_clocks clk_sys] 10.000
set_max_delay -datapath_only -from [get_clocks adc_clk2x_mmcm_out_1] -to [get_clocks clk_sys] 10.000

# This path happens only in the control path for setting control parameters
set_max_delay -datapath_only -from [get_clocks adc_clk_mmcm_out] -to [get_clocks adc_clk2x_mmcm_out] 8.000
set_max_delay -datapath_only -from [get_clocks adc_clk_mmcm_out_1] -to [get_clocks adc_clk2x_mmcm_out_1] 8.000

# FIFO CDC timimng. Using faster clock period / 2
set_max_delay -datapath_only -from [get_clocks -of_objects [get_pins */*/*/u_ddr_core/ui_clk]] -to [get_clocks adc_clk_mmcm_out] 4.000
set_max_delay -datapath_only -from [get_clocks adc_clk_mmcm_out] -to [get_clocks -of_objects [get_pins */*/*/u_ddr_core/ui_clk]] 4.000

set_max_delay -datapath_only -from [get_clocks -of_objects [get_pins */*/*/u_ddr_core/ui_clk]] -to [get_clocks adc_clk_mmcm_out_1] 4.000
set_max_delay -datapath_only -from [get_clocks adc_clk_mmcm_out_1] -to [get_clocks -of_objects [get_pins */*/*/u_ddr_core/ui_clk]] 4.000

# FIFO generated CDC. Xilinx recommends 2x the slower clock period delay. But let's be more strict and allow
# only 1x faster clock period delay
set_max_delay -datapath_only -from [get_clocks -of_objects [get_pins */*/*/u_ddr_core/ui_clk]] -to [get_clocks clk_userclk2] 8.000
set_max_delay -datapath_only -from [get_clocks clk_userclk2] -to [get_clocks -of_objects [get_pins */*/*/u_ddr_core/ui_clk]] 8.000

#######################################################################
##                      Placement Constraints                        ##
#######################################################################

# Constrain the PCIe core elements placement, so that it won't fail
# timing analysis.
# Comment out because we use nonstandard GTP location
create_pblock GRP_pcie_core
add_cells_to_pblock [get_pblocks GRP_pcie_core] [get_cells -quiet cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/pcie_core_i/*]
add_cells_to_pblock [get_pblocks GRP_pcie_core] [get_cells cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/pcie_core_i]
resize_pblock [get_pblocks GRP_pcie_core] -add {CLOCKREGION_X0Y4:CLOCKREGION_X0Y4}
### Place the DMA design not far from PCIe core, otherwise it also breaks timing
create_pblock GRP_tlpControl
add_cells_to_pblock [get_pblocks GRP_tlpControl] [get_cells -quiet cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/theTlpControl/*]
add_cells_to_pblock [get_pblocks GRP_tlpControl] [get_cells cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/theTlpControl]
resize_pblock [get_pblocks GRP_tlpControl] -add {CLOCKREGION_X0Y2:CLOCKREGION_X0Y4}
#create_pblock GRP_ddr_core
#add_cells_to_pblock [get_pblocks GRP_ddr_core] [get_cells -quiet [list cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/*]]
#resize_pblock [get_pblocks GRP_ddr_core] -add {CLOCKREGION_X1Y0:CLOCKREGION_X1Y1}
#create_pblock GRP_ddr_core_temp_mon
#add_cells_to_pblock [get_pblocks GRP_ddr_core_temp_mon] [get_cells -quiet [list cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/temp_mon_enabled.u_tempmon/*]]
#resize_pblock [get_pblocks GRP_ddr_core_temp_mon] -add {CLOCKREGION_X0Y2:CLOCKREGION_X0Y3}
## The FMC #1 is poor placed on PCB, so we constraint it to the rightmost clock regions of the FPGA
#INST "cmp1_xwb_fmc130m_4ch/*" AREA_GROUP = "GRP_fmc1";
#AREA_GROUP "GRP_fmc1" RANGE = CLOCKREGION_X1Y2:CLOCKREGION_X1Y4;
#INST "cmp2_xwb_fmc130m_4ch" AREA_GROUP = "GRP_fmc2";
#AREA_GROUP "GRP_fmc2" RANGE = CLOCKREGION_X0Y0:CLOCKREGION_X0Y2;
create_pblock GRP_position_calc_core1
add_cells_to_pblock [get_pblocks GRP_position_calc_core1] [get_cells -quiet [list cmp1_xwb_position_calc_core/cmp_wb_position_calc_core/cmp_position_calc]]
resize_pblock [get_pblocks GRP_position_calc_core1] -add {CLOCKREGION_X1Y2:CLOCKREGION_X1Y4}
create_pblock GRP_position_calc_core2
add_cells_to_pblock [get_pblocks GRP_position_calc_core2] [get_cells -quiet [list cmp2_xwb_position_calc_core/cmp_wb_position_calc_core/cmp_position_calc]]
resize_pblock [get_pblocks GRP_position_calc_core2] -add {CLOCKREGION_X0Y0:CLOCKREGION_X0Y2}

#######################################################################
##                         CE Constraints                            ##
#######################################################################

## Mixer CE (CE_ADC) = 2
set_multicycle_path 2 -setup -from  [all_fanout -endpoints_only -only_cells -from [get_pins * -hierarchical -filter {NAME =~ *position_calc/gen_ddc[?].cmp_mixer/*}]]
set_multicycle_path 1 -hold -from  [all_fanout -endpoints_only -only_cells -from [get_pins * -hierarchical -filter {NAME =~ *position_calc/gen_ddc[?].cmp_mixer/*}]]

# CIC TBT CE (CE_ADC) = 2
set_multicycle_path 2 -setup -from  [all_fanout -endpoints_only -only_cells -from [get_pins * -hierarchical -filter {NAME =~ *position_calc/gen_ddc[?].cmp_tbt_cic/cmp_cic_decim*/*}]]
set_multicycle_path 1 -hold -from  [all_fanout -endpoints_only -only_cells -from [get_pins * -hierarchical -filter {NAME =~ *position_calc/gen_ddc[?].cmp_tbt_cic/cmp_cic_decim*/*}]]
#
# TBT CORDIC CE (CE_TBT) = CE_ADC * 35
set_multicycle_path 70 -setup -from [all_fanout -endpoints_only -only_cells -from [get_pins * -hierarchical -filter {NAME =~ *position_calc/gen_ddc[?].cmp_tbt_cordic/*}]]
set_multicycle_path 69 -hold -from [all_fanout -endpoints_only -only_cells -from [get_pins * -hierarchical -filter {NAME =~ *position_calc/gen_ddc[?].cmp_tbt_cordic/*}]]

# CIC FOFB CE (CE_TBT) = CE_ADC * 35
set_multicycle_path 70 -setup -from [all_fanout -endpoints_only -only_cells -from [get_pins * -hierarchical -filter {NAME =~ *position_calc/gen_ddc[?].cmp_fofb_cic/cmp_cic_decim*/*}]]
set_multicycle_path 69 -hold -from [all_fanout -endpoints_only -only_cells -from [get_pins * -hierarchical -filter {NAME =~ *position_calc/gen_ddc[?].cmp_fofb_cic/cmp_cic_decim*/*}]]

# FOFB CORDIC CE (CE_FOFB) = CE_TBT * 28
set_multicycle_path 1960 -setup -from [all_fanout -endpoints_only -only_cells -from [get_pins * -hierarchical -filter {NAME =~ *position_calc/gen_ddc[?].cmp_fofb_cordic/*}]]
set_multicycle_path 1959 -hold -from [all_fanout -endpoints_only -only_cells -from [get_pins * -hierarchical -filter {NAME =~ *position_calc/gen_ddc[?].cmp_fofb_cordic/*}]]

# CIC MONIT 1 CE (CE_FOFB) = CE_TBT * 28
set_multicycle_path 1960 -setup -from [all_fanout -endpoints_only -only_cells -from [get_pins * -hierarchical -filter {NAME =~ *position_calc/gen_ddc[?].cmp_monit1_cic/cmp_cic_decim/*}]]
set_multicycle_path 1959 -hold -from [all_fanout -endpoints_only -only_cells -from [get_pins * -hierarchical -filter {NAME =~ *position_calc/gen_ddc[?].cmp_monit1_cic/cmp_cic_decim/*}]]

# CIC MONIT 2 CE (CE_MONI1) = CE_FOFB * 100
set_multicycle_path 196000 -setup -from [all_fanout -endpoints_only -only_cells -from [get_pins * -hierarchical -filter {NAME =~ *position_calc/gen_ddc[?].cmp_monit2_cic/cmp_cic_decim/*}]]
set_multicycle_path 195999 -hold -from [all_fanout -endpoints_only -only_cells -from [get_pins * -hierarchical -filter {NAME =~ *position_calc/gen_ddc[?].cmp_monit2_cic/cmp_cic_decim/*}]]

# Delta-Sigma CE (CE_ADC) = 2
set_multicycle_path 2 -setup -from  [all_fanout -endpoints_only -only_cells -from [get_pins * -hierarchical -filter {NAME =~ *position_calc/cmp_fofb_ds/*}]]
set_multicycle_path 1 -hold -from  [all_fanout -endpoints_only -only_cells -from [get_pins * -hierarchical -filter {NAME =~ *position_calc/cmp_fofb_ds/*}]]

#######################################################################
##                         Bitstream Settings                        ##
#######################################################################

#set_property BITSTREAM.Config.SPI_BUSWIDTH 1    [current_design]
#set_property BITSTREAM.CONFIG.CONFIGRATE 50     [current_design]
