#######################################################################
##                      Artix 7 AMC V3                               ##
#######################################################################

#// FPGA_CLK1_P
set_property IOSTANDARD DIFF_SSTL15 [get_ports sys_clk_p_i]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports sys_clk_p_i]
#// FPGA_CLK1_N
set_property PACKAGE_PIN AL7 [get_ports sys_clk_n_i]
set_property IOSTANDARD DIFF_SSTL15 [get_ports sys_clk_n_i]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports sys_clk_n_i]

# LINK01_CLK1_P
set_property PACKAGE_PIN AG18 [get_ports aux_clk_p_i]
# LINK01_CLK1_N
set_property PACKAGE_PIN AH18 [get_ports aux_clk_n_i]

#// TXD     IO_25_34
set_property PACKAGE_PIN AB11 [get_ports rs232_txd_o]
set_property IOSTANDARD LVCMOS25 [get_ports rs232_txd_o]
#// VADJ1_RXD   IO_0_34
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
set_property PACKAGE_PIN K10 [get_ports {leds_o[2]}]
set_property IOSTANDARD LVCMOS25 [get_ports {leds_o[2]}]
# Led Green - IO_25_36
set_property PACKAGE_PIN L7 [get_ports {leds_o[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {leds_o[1]}]
# Led Blue - IO_0_36
set_property PACKAGE_PIN H12 [get_ports {leds_o[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {leds_o[0]}]

#######################################################################
##                           Trigger                                 ##
#######################################################################

set_property PACKAGE_PIN AM9 [get_ports {trig_b[0]}]
set_property IOSTANDARD LVCMOS15  [get_ports {trig_b[0]}]

set_property PACKAGE_PIN AP11 [get_ports {trig_b[1]}]
set_property IOSTANDARD LVCMOS15  [get_ports {trig_b[1]}]

set_property PACKAGE_PIN AP10 [get_ports {trig_b[2]}]
set_property IOSTANDARD LVCMOS15  [get_ports {trig_b[2]}]

set_property PACKAGE_PIN AM11 [get_ports {trig_b[3]}]
set_property IOSTANDARD LVCMOS15  [get_ports {trig_b[3]}]

set_property PACKAGE_PIN AN8 [get_ports {trig_b[4]}]
set_property IOSTANDARD LVCMOS15  [get_ports {trig_b[4]}]

set_property PACKAGE_PIN AP8 [get_ports {trig_b[5]}]
set_property IOSTANDARD LVCMOS15  [get_ports {trig_b[5]}]

set_property PACKAGE_PIN AL8 [get_ports {trig_b[6]}]
set_property IOSTANDARD LVCMOS15  [get_ports {trig_b[6]}]

set_property PACKAGE_PIN AL9 [get_ports {trig_b[7]}]
set_property IOSTANDARD LVCMOS15  [get_ports {trig_b[7]}]

set_property PACKAGE_PIN AJ10 [get_ports {trig_dir_o[0]}]
set_property IOSTANDARD LVCMOS15  [get_ports {trig_dir_o[0]}]

set_property PACKAGE_PIN AK11 [get_ports {trig_dir_o[1]}]
set_property IOSTANDARD LVCMOS15  [get_ports {trig_dir_o[1]}]

set_property PACKAGE_PIN AJ11 [get_ports {trig_dir_o[2]}]
set_property IOSTANDARD LVCMOS15  [get_ports {trig_dir_o[2]}]

set_property PACKAGE_PIN AL10 [get_ports {trig_dir_o[3]}]
set_property IOSTANDARD LVCMOS15  [get_ports {trig_dir_o[3]}]

set_property PACKAGE_PIN AM10 [get_ports {trig_dir_o[4]}]
set_property IOSTANDARD LVCMOS15  [get_ports {trig_dir_o[4]}]

set_property PACKAGE_PIN AN11 [get_ports {trig_dir_o[5]}]
set_property IOSTANDARD LVCMOS15  [get_ports {trig_dir_o[5]}]

set_property PACKAGE_PIN AN9 [get_ports {trig_dir_o[6]}]
set_property IOSTANDARD LVCMOS15  [get_ports {trig_dir_o[6]}]

set_property PACKAGE_PIN AP9 [get_ports {trig_dir_o[7]}]
set_property IOSTANDARD LVCMOS15  [get_ports {trig_dir_o[7]}]

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
##                      ADN4604ASVZ Contraints                      ##
#######################################################################

set_property PACKAGE_PIN U24 [get_ports adn4604_vadj2_clk_updt_n_o]
set_property IOSTANDARD LVCMOS25 [get_ports adn4604_vadj2_clk_updt_n_o]
set_property PULLUP true [get_ports adn4604_vadj2_clk_updt_n_o]

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
##                          PCIe constraints                        ##
#######################################################################

#PCIe clock
# MGT216_CLK1_N -> MGTREFCLK0N_216
set_property PACKAGE_PIN G18                     [get_ports pcie_clk_n_i]
# MGT216_CLK1_P -> MGTREFCLK0P_216
set_property PACKAGE_PIN H18                     [get_ports pcie_clk_p_i]

#XDC supplied by PCIe IP core generates
# GTP connection in reverse order, we have to swap it.
# Simply providing correct connections will generate
# errors "Cannot set LOC ... because the PACKAGE_PIN
# is occupied by ...".
# So, firstly set PCIe lanes to temporary locations
#PCIe lane 0
# TX213_0_P            -> MGTPTXP0_213
set_property PACKAGE_PIN AN19                    [get_ports {pci_exp_txp_o[0]}]
# TX213_0_N            -> MGTPTXN0_213
set_property PACKAGE_PIN AP19                    [get_ports {pci_exp_txn_o[0]}]
# RX213_0_P            -> MGTPRXP0_213
set_property PACKAGE_PIN AL18                    [get_ports {pci_exp_rxp_i[0]}]
# RX213_0_N            -> MGTPRXN0_213
set_property PACKAGE_PIN AM18                    [get_ports {pci_exp_rxn_i[0]}]
#PCIe lane 1
# TX213_1_P            -> MGTPTXP1_213
set_property PACKAGE_PIN AN21                    [get_ports {pci_exp_txp_o[1]}]
# TX213_1_N            -> MGTPTXN1_213
set_property PACKAGE_PIN AP21                    [get_ports {pci_exp_txn_o[1]}]
# RX213_1_P            -> MGTPRXP1_213
set_property PACKAGE_PIN AJ19                    [get_ports {pci_exp_rxp_i[1]}]
# RX213_1_N            -> MGTPRXN1_213
set_property PACKAGE_PIN AK19                    [get_ports {pci_exp_rxn_i[1]}]
#PCIe lane 2
# TX213_2_P            -> MGTPTXP2_213
set_property PACKAGE_PIN AL22                    [get_ports {pci_exp_txp_o[2]}]
# TX213_2_N            -> MGTPTXN2_213
set_property PACKAGE_PIN AM22                    [get_ports {pci_exp_txn_o[2]}]
# RX213_2_P            -> MGTPRXP2_213
set_property PACKAGE_PIN AL20                    [get_ports {pci_exp_rxp_i[2]}]
# RX213_2_N            -> MGTPRXN2_213
set_property PACKAGE_PIN AM20                    [get_ports {pci_exp_rxn_i[2]}]
#PCIe lane 3
# TX213_3_P            -> MGTPTXP3_213
set_property PACKAGE_PIN AN23                    [get_ports {pci_exp_txp_o[3]}]
# TX213_3_N            -> MGTPTXN3_213
set_property PACKAGE_PIN AP23                    [get_ports {pci_exp_txn_o[3]}]
# RX213_3_P            -> MGTPRXP3_213
set_property PACKAGE_PIN AJ21                    [get_ports {pci_exp_rxp_i[3]}]
# RX213_3_N            -> MGTPRXN3_213
set_property PACKAGE_PIN AK21                    [get_ports {pci_exp_rxn_i[3]}]

# Now assign the correct ones

#PCIe lane 0
# TX216_0_P            -> MGTPTXP0_216
set_property PACKAGE_PIN B23                     [get_ports {pci_exp_txp_o[0]}]
# TX216_0_N            -> MGTPTXN0_216
set_property PACKAGE_PIN A23                     [get_ports {pci_exp_txn_o[0]}]
# RX216_0_P            -> MGTPRXP0_216
set_property PACKAGE_PIN F21                     [get_ports {pci_exp_rxp_i[0]}]
# RX216_0_N            -> MGTPRXN0_216
set_property PACKAGE_PIN E21                     [get_ports {pci_exp_rxn_i[0]}]
#PCIe lane 1
# TX216_1_P            -> MGTPTXP1_216
set_property PACKAGE_PIN D22                     [get_ports {pci_exp_txp_o[1]}]
# TX216_1_N            -> MGTPTXN1_216
set_property PACKAGE_PIN C22                     [get_ports {pci_exp_txn_o[1]}]
# RX216_1_P            -> MGTPRXP1_216
set_property PACKAGE_PIN D20                     [get_ports {pci_exp_rxp_i[1]}]
# RX216_1_N            -> MGTPRXN1_216
set_property PACKAGE_PIN C20                     [get_ports {pci_exp_rxn_i[1]}]
#PCIe lane 2
# TX216_2_P            -> MGTPTXP2_216
set_property PACKAGE_PIN B21                     [get_ports {pci_exp_txp_o[2]}]
# TX216_2_N            -> MGTPTXN2_216
set_property PACKAGE_PIN A21                     [get_ports {pci_exp_txn_o[2]}]
# RX216_2_P            -> MGTPRXP2_216
set_property PACKAGE_PIN F19                     [get_ports {pci_exp_rxp_i[2]}]
# RX216_2_N            -> MGTPRXN2_216
set_property PACKAGE_PIN E19                     [get_ports {pci_exp_rxn_i[2]}]
#PCIe lane 3
# TX216_3_P            -> MGTPTXP3_216
set_property PACKAGE_PIN B19                     [get_ports {pci_exp_txp_o[3]}]
# TX216_3_N            -> MGTPTXN3_216
set_property PACKAGE_PIN A19                     [get_ports {pci_exp_txn_o[3]}]
# RX216_3_P            -> MGTPRXP3_216
set_property PACKAGE_PIN D18                     [get_ports {pci_exp_rxp_i[3]}]
# RX216_3_N            -> MGTPRXN3_216
set_property PACKAGE_PIN C18                     [get_ports {pci_exp_rxn_i[3]}]

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
set_property IDELAY_VALUE 0 [get_cells -hier -filter {NAME =~ *cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[*].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells -hier -filter {NAME =~ *cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[*].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells -hier -filter {NAME =~ *cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[*].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells -hier -filter {NAME =~ *cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[*].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells -hier -filter {NAME =~ *cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[*].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells -hier -filter {NAME =~ *cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[*].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells -hier -filter {NAME =~ *cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[*].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 0 [get_cells -hier -filter {NAME =~ *cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[*].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]

# Overrides default_delay hdl parameter
set_property IDELAY_VALUE 26 [get_cells -hier -filter {NAME =~ *cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_clock_chains[0].gen_clock_chains_check.cmp_fmc_adc_clk/gen_adc_clk_7series_iodelay.gen_adc_clk_var_load_iodelay.cmp_ibufds_clk_iodelay}]
set_property IDELAY_VALUE 26 [get_cells -hier -filter {NAME =~ *cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_clock_chains[0].gen_clock_chains_check.cmp_fmc_adc_clk/gen_adc_clk_7series_iodelay.gen_adc_clk_var_load_iodelay.cmp_ibufds_clk_iodelay}]
set_property IDELAY_VALUE 26 [get_cells -hier -filter {NAME =~ *cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_clock_chains[1].gen_clock_chains_check.cmp_fmc_adc_clk/gen_adc_clk_7series_iodelay.gen_adc_clk_var_load_iodelay.cmp_ibufds_clk_iodelay}]
set_property IDELAY_VALUE 27 [get_cells -hier -filter {NAME =~ *cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_clock_chains[1].gen_clock_chains_check.cmp_fmc_adc_clk/gen_adc_clk_7series_iodelay.gen_adc_clk_var_load_iodelay.cmp_ibufds_clk_iodelay}]
set_property IDELAY_VALUE 27 [get_cells -hier -filter {NAME =~ *cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_clock_chains[2].gen_clock_chains_check.cmp_fmc_adc_clk/gen_adc_clk_7series_iodelay.gen_adc_clk_var_load_iodelay.cmp_ibufds_clk_iodelay}]
set_property IDELAY_VALUE 27 [get_cells -hier -filter {NAME =~ *cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_clock_chains[2].gen_clock_chains_check.cmp_fmc_adc_clk/gen_adc_clk_7series_iodelay.gen_adc_clk_var_load_iodelay.cmp_ibufds_clk_iodelay}]
set_property IDELAY_VALUE 26 [get_cells -hier -filter {NAME =~ *cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_clock_chains[3].gen_clock_chains_check.cmp_fmc_adc_clk/gen_adc_clk_7series_iodelay.gen_adc_clk_var_load_iodelay.cmp_ibufds_clk_iodelay}]
set_property IDELAY_VALUE 26 [get_cells -hier -filter {NAME =~ *cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_clock_chains[3].gen_clock_chains_check.cmp_fmc_adc_clk/gen_adc_clk_7series_iodelay.gen_adc_clk_var_load_iodelay.cmp_ibufds_clk_iodelay}]

#######################################################################
##                          Clocks                                   ##
#######################################################################

# 125 MHz AMC TCLKB input clock
create_clock -period 8.000 -name sys_clk_p_i       [get_ports sys_clk_p_i]

# 64.440 MHz AMC TCLKB input clock
create_clock -period 14.400 -name aux_clk_p_i      [get_ports aux_clk_p_i]

## 100 MHz wihsbone clock
create_generated_clock -name clk_sys               [get_pins -hier -filter {NAME =~ *cmp_sys_pll_inst/cmp_sys_pll/CLKOUT0}]
set clk_sys_period                                 [get_property PERIOD [get_clocks clk_sys]]
# 200 MHz DDR3 and IDELAY CONTROL clock
create_generated_clock -name clk_200mhz            [get_pins -hier -filter {NAME =~ *cmp_sys_pll_inst/cmp_sys_pll/CLKOUT1}]
set clk_200mhz_period                              [get_property PERIOD [get_clocks clk_200mhz]]

## 64.440 MHz aux clock
create_generated_clock -name clk_aux               [get_pins -hier -filter {NAME =~ *cmp_aux_sys_pll_inst/cmp_sys_pll/CLKOUT0}]
set clk_aux_period                                 [get_property PERIOD [get_clocks clk_aux]]

# DDR3 clock generated by IP
set clk_pll_ddr_period                             [get_property PERIOD [get_clocks clk_pll_i]]
set clk_pll_ddr_period_less                        [expr $clk_pll_ddr_period - 1.000]

# PCIE clock generated by IP
set clk_125mhz_period                             [get_property PERIOD [get_clocks clk_125mhz]]

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

# ADC generated clocks
create_generated_clock -name fmc1_ref_clk          [get_pins -hier -filter {NAME =~ *cmp1_xwb_fmc*cmp_mmcm_adc_clk/CLKOUT0}]
set fmc1_ref_clk_period                            [get_property PERIOD [get_clocks fmc1_ref_clk]]
create_generated_clock -name fmc1_ref_clk_2x       [get_pins -hier -filter {NAME =~ *cmp1_xwb_fmc*cmp_mmcm_adc_clk/CLKOUT1}]
set fmc1_ref_clk_2x_period                         [get_property PERIOD [get_clocks fmc1_ref_clk_2x]]

create_generated_clock -name fmc2_ref_clk          [get_pins -hier -filter {NAME =~ *cmp2_xwb_fmc*cmp_mmcm_adc_clk/CLKOUT0}]
set fmc2_ref_clk_period                            [get_property PERIOD [get_clocks fmc2_ref_clk]]
create_generated_clock -name fmc2_ref_clk_2x       [get_pins -hier -filter {NAME =~ *cmp2_xwb_fmc*cmp_mmcm_adc_clk/CLKOUT1}]
set fmc2_ref_clk_2x_period                         [get_property PERIOD [get_clocks fmc2_ref_clk_2x]]

#######################################################################
##                              Clock                                ##
#######################################################################

# Reset synchronization path.
set_false_path -through                            [get_pins -hier -filter {NAME =~ *cmp_reset/master_rstn_reg/C}]
# Get the cell driving the corresponding net
set reset_ffs                                      [get_nets -hier -filter {NAME =~ *cmp_reset*/master_rstn*}]
set_property ASYNC_REG TRUE                        [get_cells [all_fanin -flat -only_cells -startpoints_only [get_pins -of_objects [get_nets $reset_ffs]]]]

# DDR 3 temperature monitor reset path
# chain of FFs synched with clk_sys.
#  We use asynchronous assertion and
#  synchronous deassertion
set_false_path -through                            [get_nets -hier -filter {NAME =~ *theTlpControl/Memory_Space/wb_FIFO_Rst}]
# DDR 3 temperature monitor reset path
set_max_delay -datapath_only -from                 [get_cells -hier -filter {NAME =~ *ddr3_infrastructure/rstdiv0_sync_r1_reg*}] -to [get_cells -hier -filter {NAME =~ *temp_mon_enabled.u_tempmon/xadc_supplied_temperature.rst_r1*}] 20.000

#######################################################################
##                                Data                               ##
#######################################################################

# Constraint all IDELAY blocks to the same IDELAY control as the DDR 3, so the tool will replicate it as needed
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells -hier -filter {NAME =~ *cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[*].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[*].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells -hier -filter {NAME =~ *cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_clock_chains[*].gen_clock_chains_check.cmp_fmc_adc_clk/gen_adc_clk_7series_iodelay.gen_adc_clk_var_load_iodelay.cmp_ibufds_clk_iodelay}]

set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells -hier -filter {NAME =~ *cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[*].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[*].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells -hier -filter {NAME =~ *cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_clock_chains[*].gen_clock_chains_check.cmp_fmc_adc_clk/gen_adc_clk_7series_iodelay.gen_adc_clk_var_load_iodelay.cmp_ibufds_clk_iodelay}]

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
##                              CDC                                  ##
#######################################################################

# From Wishbone To ADC/ADC2x. These are slow control registers taken care of synched by FFs.
set_max_delay -datapath_only -from               [get_clocks clk_sys] -to [get_clocks fmc1_ref_clk]    $clk_sys_period
set_max_delay -datapath_only -from               [get_clocks clk_sys] -to [get_clocks fmc2_ref_clk]    $clk_sys_period
set_max_delay -datapath_only -from               [get_clocks clk_sys] -to [get_clocks fmc1_ref_clk_2x] $clk_sys_period
set_max_delay -datapath_only -from               [get_clocks clk_sys] -to [get_clocks fmc2_ref_clk_2x] $clk_sys_period

# From ADC/ADC2x To Wishbone. These are status registers taken care of synched by FFs.
set_max_delay -datapath_only -from               [get_clocks fmc1_ref_clk]    -to [get_clocks clk_sys] $fmc1_ref_clk_period
set_max_delay -datapath_only -from               [get_clocks fmc2_ref_clk]    -to [get_clocks clk_sys] $fmc2_ref_clk_period
set_max_delay -datapath_only -from               [get_clocks fmc1_ref_clk_2x] -to [get_clocks clk_sys] $fmc1_ref_clk_2x_period
set_max_delay -datapath_only -from               [get_clocks fmc2_ref_clk_2x] -to [get_clocks clk_sys] $fmc2_ref_clk_2x_period

# This path happens only in the control path for setting control parameters
set_max_delay -datapath_only -from               [get_clocks fmc1_ref_clk] -to [get_clocks fmc1_ref_clk_2x] $fmc1_ref_clk_period
set_max_delay -datapath_only -from               [get_clocks fmc2_ref_clk] -to [get_clocks fmc2_ref_clk_2x] $fmc2_ref_clk_period

# FIFO CDC timimng. Using < faster clock period
set_max_delay -datapath_only -from               [get_clocks clk_pll_i]    -to [get_clocks fmc1_ref_clk]   $clk_pll_ddr_period_less
set_max_delay -datapath_only -from               [get_clocks fmc1_ref_clk] -to [get_clocks clk_pll_i]      $clk_pll_ddr_period_less

set_max_delay -datapath_only -from               [get_clocks clk_pll_i]    -to [get_clocks fmc2_ref_clk]   $clk_pll_ddr_period_less
set_max_delay -datapath_only -from               [get_clocks fmc2_ref_clk] -to [get_clocks clk_pll_i]      $clk_pll_ddr_period_less

# FIFO generated CDC. Xilinx recommends 2x the slower clock period delay. But let's be more strict and allow
# only 1x faster clock period delay
set_max_delay -datapath_only -from               [get_clocks clk_pll_i]    -to [get_clocks clk_userclk2]   $clk_pll_ddr_period
set_max_delay -datapath_only -from               [get_clocks clk_userclk2] -to [get_clocks clk_pll_i]      $clk_pll_ddr_period

# Wishbone <-> PCIe. Using 1x source clock
set_max_delay -datapath_only -from               [get_clocks clk_sys]     -to [get_clocks clk_125mhz]   $clk_sys_period
set_max_delay -datapath_only -from               [get_clocks clk_125mhz]  -to [get_clocks clk_sys]      $clk_125mhz_period

# PCIe <-> DDR3. Give 1x the source clock
set_max_delay -from                              [get_clocks clk_pll_i] -to [get_clocks clk_125mhz] $clk_pll_ddr_period

# Acquisition core <-> DDR3 clock. 1x source clock destination
set_max_delay -datapath_only -from               [get_clocks clk_sys]   -to [get_clocks clk_pll_i] $clk_sys_period
set_max_delay -datapath_only -from               [get_clocks clk_pll_i] -to [get_clocks clk_sys] $clk_pll_ddr_period

# DDR3 reset path. Copied from
# ddr_core.xdc and modified accordingly
set_max_delay -datapath_only -from               [get_pins -hier -filter {NAME =~ *cmp_pcie_cntr/user_lnk_up_int_i/C}] -to [get_cells -hier *rstdiv0_sync_r*] 5

# Constraint the asynchronous reset of the DDR3 module. It should be safe to declare it
# as a false path, but let's give it a 5 ns, as the constraint above.
# Here we want to get a valid startpoint from the NET name ddr_reset. So, we must:
# 1. Get the complete name of this NET
# 2. Get the pin name that is connected to this NET and filter it
#     so get only the OUT pins and the LEAF name of it (as opposed to
#     a hierarchical name)
# 3. This pin will be probably the Q pin of the driving FF, but for a timing,
#     analysis we want a valid startpoint. So, we get only this by using the all_fanin
#     command
# FIXME. This might not work if the tools change the name of the "ddr_reset" net.
# Instead, use the actual name of the driving "ddr_reset" net
#set pcie_user_ddr_reset                          [all_fanin -flat -only_cells -startpoints_only [get_pins -of_objects [get_nets -hier -filter {NAME =~ */theTlpControl/Memory_Space/ddr_reset}] -filter {IS_LEAF && (DIRECTION == "OUT")}]]
set pcie_user_ddr_reset                          [get_cells -hier -filter {NAME =~ */theTlpControl/Memory_Space/General_Control_i_reg[16]}]
set_max_delay -from                              [get_cells $pcie_user_ddr_reset] 5.000

# Constraint DDR <-> PCIe clocks CDC
set_max_delay -datapath_only -from               [get_clocks -include_generated_clocks pcie_clk] -to [get_clocks -include_generated_clocks clk_pll_i] 5.000
set_max_delay -datapath_only -from               [get_clocks -include_generated_clocks clk_pll_i] -to [get_clocks -include_generated_clocks pcie_clk] 5.000

# Acquisition core register CDC
set_max_delay -datapath_only -from               [get_pins -hier -filter {NAME =~ *acq_core/*acq_fc_fifo/lmt_*_pkt*/C}] -to [get_clocks clk_pll_i] $clk_pll_ddr_period
set_max_delay -datapath_only -from               [get_pins -hier -filter {NAME =~ *acq_core/*acq_fc_fifo/lmt_shots*/C}] -to [get_clocks clk_pll_i] $clk_pll_ddr_period
set_max_delay -datapath_only -from               [get_pins -hier -filter {NAME =~ *acq_core/*acq_fc_fifo/lmt_curr_chan*/C}] -to [get_clocks clk_pll_i] $clk_pll_ddr_period

set_max_delay -datapath_only -from               [get_pins -hier -filter {NAME =~ *acq_core/*acq_ddr3_iface/lmt_*_pkt*/C}] -to [get_clocks clk_pll_i] $clk_pll_ddr_period
set_max_delay -datapath_only -from               [get_pins -hier -filter {NAME =~ *acq_core/*acq_ddr3_iface/lmt_shots*/C}] -to [get_clocks clk_pll_i] $clk_pll_ddr_period
set_max_delay -datapath_only -from               [get_pins -hier -filter {NAME =~ *acq_core/*acq_ddr3_iface/lmt_curr_chan*/C}] -to [get_clocks clk_pll_i] $clk_pll_ddr_period

# This path is only valid after acq_start signal, which is controlled by software and
# is activated many many miliseconds after all of the other. So, give it 2x the clock
# period
set_max_delay -datapath_only -from [get_pins -hier -filter {NAME =~ *acq_core/*/regs_o_reg[acq_chan_ctl_which_o][*]/C}] -to [get_pins -hier -filter {NAME =~ *acq_core/*/acq_in_post_trig_reg/D}] 8.000
set_max_delay -datapath_only -from [get_pins -hier -filter {NAME =~ *acq_core/*/regs_o_reg[acq_chan_ctl_which_o][*]/C}] -to [get_clocks fmc1_ref_clk] 8.000
set_max_delay -datapath_only -from [get_pins -hier -filter {NAME =~ *acq_core/*/regs_o_reg[acq_chan_ctl_which_o][*]/C}] -to [get_clocks fmc2_ref_clk] 8.000

# This path is only valid after acq_start
# signal, which is controlled by software and
# is activated many many miliseconds after
# all of the other. So, give it 1x the
# destination clock period
set_max_delay -datapath_only -from               [get_pins -hier -filter {NAME =~ *acq_core/*acq_core_regs/*/C}] -to [get_clocks clk_sys] $clk_sys_period

# Aux clock to Sys clock. Path used to/from registers
set_max_delay -datapath_only -from               [get_clocks clk_sys] -to [get_clocks clk_aux]    $clk_sys_period
set_max_delay -datapath_only -from               [get_clocks clk_aux] -to [get_clocks clk_sys]    $clk_sys_period

# Use Distributed RAM, as these FIFOs are small and sparse through the module
# Cannot make this work with hierarchical matching... only by specifying the
# whole topology
set_property RAM_STYLE DISTRIBUTED [get_cells -hier -filter {NAME =~ */cmp_position_calc_cdc_fifo/mem_reg*}]

# Use Distributed RAMs for FMC ADC CDC FIFOs. They are small and sparse.
set_property RAM_STYLE DISTRIBUTED [get_cells -hier -filter {NAME =~ */cmp_fmc_adc_iface/*/cmp_adc_data_async_fifo/mem_reg*}]

# Use Distributed RAMs for FMC ACQ FIFOs. They are small and sparse.
set_property RAM_STYLE DISTRIBUTED [get_cells -hier -filter {NAME =~ */cmp_acq_fc_fifo/cmp_fc_source/*.*/*.*/mem_reg*}]

#######################################################################
##                      Placement Constraints                        ##
#######################################################################

# Constrain the PCIe core elements placement, so that it won't fail
# timing analysis.
# Comment out because we use nonstandard GTP location
create_pblock GRP_pcie_core
add_cells_to_pblock [get_pblocks GRP_pcie_core] [get_cells -hier -filter {NAME =~ *pcie_core_i/*}]
resize_pblock [get_pblocks GRP_pcie_core] -add {CLOCKREGION_X0Y4:CLOCKREGION_X0Y4}
#
## Place the DMA design not far from PCIe core, otherwise it also breaks timing
#create_pblock GRP_ddr_core
#add_cells_to_pblock [get_pblocks GRP_ddr_core] [get_cells -hier -filter  {NAME =~ *pcie_core_i/DDRs_ctrl_module/ddr_core_inst/*]]
#resize_pblock [get_pblocks GRP_ddr_core] -add {CLOCKREGION_X1Y0:CLOCKREGION_X1Y1}
#
## Place DDR core temperature monitor
#create_pblock GRP_ddr_core_temp_mon
#add_cells_to_pblock [get_pblocks GRP_ddr_core_temp_mon] [get_cells -quiet -hier -filter [NAME =~ *u_ddr_core/temp_mon_enabled.u_tempmon/*]]
#resize_pblock [get_pblocks GRP_ddr_core_temp_mon] -add {CLOCKREGION_X0Y2:CLOCKREGION_X0Y3}
#
## The FMC #1 is poor placed on PCB, so we constraint it to the rightmost clock regions of the FPGA
#create_pblock GRP_fmc1
#add_cells_to_pblock [get_pblocks GRP_fmc1] [get_cells -hier -filter {NAME =~ *cmp1_xwb_fmc250m_4ch/*}]
#resize_pblock [get_pblocks GRP_fmc1] -add {CLOCKREGION_X1Y2:CLOCKREGION_X1Y4}
#
#create_pblock GRP_fmc2
#add_cells_to_pblock [get_pblocks GRP_fmc2] [get_cells -hier -filter {NAME =~ *cmp2_xwb_fmc250m_4ch/*}]
#resize_pblock [get_pblocks GRP_fmc2] -add {CLOCKREGION_X0Y0:CLOCKREGION_X0Y2}
#
## Constraint Position Calc Cores
#create_pblock GRP_position_calc_core1
#add_cells_to_pblock [get_pblocks GRP_position_calc_core1] [get_cells -hier -filter {NAME =~ *cmp1_xwb_position_calc_core/cmp_wb_position_calc_core/*}]
#resize_pblock [get_pblocks GRP_position_calc_core1] -add {CLOCKREGION_X1Y2:CLOCKREGION_X1Y4}
#
#create_pblock GRP_position_calc_core2
#add_cells_to_pblock [get_pblocks GRP_position_calc_core2] [get_cells -hier -filter {NAME =~ *cmp2_xwb_position_calc_core/cmp_wb_position_calc_core/*}]
#resize_pblock [get_pblocks GRP_position_calc_core2] -add {CLOCKREGION_X0Y0:CLOCKREGION_X0Y2}
#
## Place acquisition core 0
#create_pblock GRP_acq_core_0
#add_cells_to_pblock [get_pblocks GRP_acq_core_0] [get_cells -hier -filter {NAME =~ */cmp_wb_facq_core_mux/gen_facq_core[0].*}]
#resize_pblock [get_pblocks GRP_acq_core_0] -add {CLOCKREGION_X0Y3:CLOCKREGION_X1Y3} -remove {CLOCKREGION_X0Y4:CLOCKREGION_X1Y4}

#######################################################################
##                         CE Constraints                            ##
#######################################################################

## Mixer CE
#set_multicycle_path 2 -setup -from  [all_fanout -endpoints_only -only_cells -from [get_pins * -hierarchical -filter {NAME =~ *position_calc/gen_ddc[?].*.cmp_mixer/*}]]
#set_multicycle_path 1 -hold -from  [all_fanout -endpoints_only -only_cells -from [get_pins * -hierarchical -filter {NAME =~ *position_calc/gen_ddc[?].*.cmp_mixer/*}]]

## CIC TBT CE
#set_multicycle_path 2 -setup -from  [all_fanout -endpoints_only -only_cells -from [get_pins * -hierarchical -filter {NAME =~ *position_calc/gen_ddc[?].*.cmp_tbt_cic/cmp_cic_decim*/*}]]
#set_multicycle_path 1 -hold -from  [all_fanout -endpoints_only -only_cells -from [get_pins * -hierarchical -filter {NAME =~ *position_calc/gen_ddc[?].*.cmp_tbt_cic/cmp_cic_decim*/*}]]

## TBT CORDIC CE
set_multicycle_path 4 -setup -from [all_fanout -endpoints_only -only_cells -from [get_pins * -hierarchical -filter {NAME =~ *position_calc/gen_ddc[?].*.cmp_tbt_cordic/cmp_cordic_core/*}]]
set_multicycle_path 3 -hold -from [all_fanout -endpoints_only -only_cells -from [get_pins * -hierarchical -filter {NAME =~ *position_calc/gen_ddc[?].*.cmp_tbt_cordic/cmp_cordic_core/*}]]

## CIC FOFB CE
#set_multicycle_path 2 -setup -from [all_fanout -endpoints_only -only_cells -from [get_pins * -hierarchical -filter {NAME =~ *position_calc/gen_ddc[?].*.cmp_fofb_cic/cmp_cic_decim*/*}]]
#set_multicycle_path 1 -hold -from [all_fanout -endpoints_only -only_cells -from [get_pins * -hierarchical -filter {NAME =~ *position_calc/gen_ddc[?].*.cmp_fofb_cic/cmp_cic_decim*/*}]]

## FOFB CORDIC CE
# FIXME: get CE from VHDL code
set_multicycle_path 4 -setup -from [all_fanout -endpoints_only -only_cells -from [get_pins * -hierarchical -filter {NAME =~ *position_calc/gen_ddc[?].*.cmp_fofb_cordic/cmp_cordic_core/*}]]
set_multicycle_path 3 -hold -from [all_fanout -endpoints_only -only_cells -from [get_pins * -hierarchical -filter {NAME =~ *position_calc/gen_ddc[?].*.cmp_fofb_cordic/cmp_cordic_core/*}]]

## CIC MONIT 1 CE
set_multicycle_path 8 -setup -from [all_fanout -endpoints_only -only_cells -from [get_pins * -hierarchical -filter {NAME =~ *position_calc/gen_ddc[?].cmp_monit1_cic/cmp_cic_decim/*}]]
set_multicycle_path 7 -hold -from [all_fanout -endpoints_only -only_cells -from [get_pins * -hierarchical -filter {NAME =~ *position_calc/gen_ddc[?].cmp_monit1_cic/cmp_cic_decim/*}]]

## CIC MONIT 2 CE
set_multicycle_path 8 -setup -from [all_fanout -endpoints_only -only_cells -from [get_pins * -hierarchical -filter {NAME =~ *position_calc/gen_ddc[?].cmp_monit2_cic/cmp_cic_decim/*}]]
set_multicycle_path 7 -hold -from [all_fanout -endpoints_only -only_cells -from [get_pins * -hierarchical -filter {NAME =~ *position_calc/gen_ddc[?].cmp_monit2_cic/cmp_cic_decim/*}]]

## Delta-Sigma CE (CE_ADC) = 2
#set_multicycle_path 2 -setup -from  [all_fanout -endpoints_only -only_cells -from [get_pins * -hierarchical -filter {NAME =~ *position_calc/cmp_fofb_ds/*}]]
#set_multicycle_path 1 -hold -from  [all_fanout -endpoints_only -only_cells -from [get_pins * -hierarchical -filter {NAME =~ *position_calc/cmp_fofb_ds/*}]]

#######################################################################
##                         Bitstream Settings                        ##
#######################################################################

set_property BITSTREAM.CONFIG.CONFIGRATE 12       [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES   [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4      [current_design]
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR YES  [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE      [current_design]
set_property CFGBVS VCCO                          [current_design]
set_property CONFIG_VOLTAGE 3.3                   [current_design]
