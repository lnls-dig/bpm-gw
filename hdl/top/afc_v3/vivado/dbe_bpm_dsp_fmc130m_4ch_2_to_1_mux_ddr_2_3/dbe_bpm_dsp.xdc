#######################################################################
##                      Artix 7 AMC V3                               ##
#######################################################################

#// FPGA_CLK1_P
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:7
# The conversion of 'IOSTANDARD' constraint on 'net' object 'sys_clk_p_i' has been applied to the port object 'sys_clk_p_i'.
set_property IOSTANDARD DIFF_SSTL15 [get_ports sys_clk_p_i]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:8
# The conversion of 'IN_TERM' constraint on 'net' object 'sys_clk_p_i' has been applied to the port object 'sys_clk_p_i'.
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports sys_clk_p_i]
#// FPGA_CLK1_N
set_property PACKAGE_PIN AL7 [get_ports sys_clk_n_i]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:11
# The conversion of 'IOSTANDARD' constraint on 'net' object 'sys_clk_n_i' has been applied to the port object 'sys_clk_n_i'.
set_property IOSTANDARD DIFF_SSTL15 [get_ports sys_clk_n_i]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:12
# The conversion of 'IN_TERM' constraint on 'net' object 'sys_clk_n_i' has been applied to the port object 'sys_clk_n_i'.
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports sys_clk_n_i]

#// TXD		IO_25_34
set_property PACKAGE_PIN AB11 [get_ports rs232_txd_o]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:16
# The conversion of 'IOSTANDARD' constraint on 'net' object 'rs232_txd_o' has been applied to the port object 'rs232_txd_o'.
set_property IOSTANDARD LVCMOS25 [get_ports rs232_txd_o]
#// VADJ1_RXD	IO_0_34
set_property PACKAGE_PIN Y11 [get_ports rs232_rxd_i]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:19
# The conversion of 'IOSTANDARD' constraint on 'net' object 'rs232_rxd_i' has been applied to the port object 'rs232_rxd_i'.
set_property IOSTANDARD LVCMOS25 [get_ports rs232_rxd_i]

# System Reset
# Bank 16 VCCO - VADJ_FPGA - IO_25_16. NET = FPGA_RESET_DN, PIN = IO_L19P_T3_13
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:23
# The constraint 'NODELAY' is not supported in this version of software. It will not be converted.
#
#NET "sys_rst_button_n_i" NODELAY = "TRUE";


# All timing constraint translations are rough conversions, intended to act as a template for further manual refinement. The translations should not be expected to produce semantically identical results to the original ucf. Each xdc timing constraint must be manually inspected and verified to ensure it captures the desired intent

# In xdc, all clocks are related by default. This differs from ucf, where clocks are unrelated unless specified otherwise. As a result, you may now see cross-clock paths that were previously unconstrained in ucf. Commented out xdc false path constraints have been generated and can be uncommented, should you wish to remove these new paths. These commands are located after the last clock definition

# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:24
set_false_path -through [get_nets sys_rst_button_n_i]
set_property PACKAGE_PIN AG26 [get_ports sys_rst_button_n_i]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:26
# The conversion of 'IOSTANDARD' constraint on 'net' object 'sys_rst_button_n_i' has been applied to the port object 'sys_rst_button_n_i'.
set_property IOSTANDARD LVCMOS25 [get_ports sys_rst_button_n_i]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:27
# The conversion of 'PULL' constraint on 'net' object 'sys_rst_button_n_i' has been applied to the port object 'sys_rst_button_n_i'.
set_property PULLUP true [get_ports sys_rst_button_n_i]

# MMCM Status
###NET "fmc_mmcm_lock_led_o"                      LOC = "AP24"  |  IOSTANDARD = "LVCMOS25"; # GPIO_LED_C, DS16

# LMK clock distribution Status
###NET "fmc_pll_status_led_o"                     LOC = "AD21"  |  IOSTANDARD = "LVCMOS25"; # GPIO_LED_W, DS17

#NET "led_south_o"                                LOC = "AH28"  |  IOSTANDARD = "LVCMOS25"; # GPIO_LED_S, DS18
#NET "led_east_o"                                 LOC = "AE21"  |  IOSTANDARD = "LVCMOS25"; # GPIO_LED_E, DS19
#NET "led_north_o"                                LOC = "AH27"  |  IOSTANDARD = "LVCMOS25"; # GPIO_LED_N, DS20

#NET "board_led1_o"                               LOC = AC22 | IOSTANDARD = LVCMOS25 | DRIVE = 12 | SLEW = SLOW; // User led 0
#NET "board_led2_o"                               LOC = AC24 | IOSTANDARD = LVCMOS25 | DRIVE = 12 | SLEW = SLOW; // User led 1
#NET "board_led3_o"                               LOC = AE22 | IOSTANDARD = LVCMOS25 | DRIVE = 12 | SLEW = SLOW; // User led 2

###NET "clk_swap_o"                              LOC = V34  | IOSTANDARD = LVCMOS25; # USER_SMA_GPIO_P
###NET "clk_swap2x_o"                            LOC = L23  | IOSTANDARD = LVCMOS25; # USER_SMA_CLK_P
###NET "flag1_o"                                 LOC = W34  | IOSTANDARD = LVCMOS25; # USER_SMA_GPIO_N
###NET "flag2_o"                                 LOC = M22  | IOSTANDARD = LVCMOS25; # USER_SMA_CLK_N

#######################################################################
##                      Button/LEDs Contraints                       ##
#######################################################################

###NET "leds_o[0]"                               LOC = AC22 | IOSTANDARD = LVCMOS25 | DRIVE = 12 | SLEW = SLOW;
###NET "leds_o[1]"                               LOC = AC24 | IOSTANDARD = LVCMOS25 | DRIVE = 12 | SLEW = SLOW;
###NET "leds_o[2]"                               LOC = AE22 | IOSTANDARD = LVCMOS25 | DRIVE = 12 | SLEW = SLOW;
###NET "leds_o[3]"                               LOC = AE23 | IOSTANDARD = LVCMOS25 | DRIVE = 12 | SLEW = SLOW;
###NET "leds_o[4]"                               LOC = AB23 | IOSTANDARD = LVCMOS25 | DRIVE = 12 | SLEW = SLOW;
###NET "leds_o[5]"                               LOC = AG23 | IOSTANDARD = LVCMOS25 | DRIVE = 12 | SLEW = SLOW;
###NET "leds_o[6]"                               LOC = AE24 | IOSTANDARD = LVCMOS25 | DRIVE = 12 | SLEW = SLOW;
###NET "leds_o[7]"                               LOC = AD24 | IOSTANDARD = LVCMOS25 | DRIVE = 12 | SLEW = SLOW;

#######################################################################
##             Ethernet Contraints. MII 10/100 Mode                  ##
#######################################################################

###NET "mrstn_o"                                 LOC = AH13;
###NET "mcoll_pad_i"                             LOC = AK13;   ## 114 on U80
###NET "mcrs_pad_i"                              LOC = AL13;   ## 115 on U80
#### NET "PHY_INT"                               LOC = AH14;   ## 32  on U80
###NET "mdc_pad_o"                               LOC = AP14;   ## 35  on U80
###NET "md_pad_b"                                LOC = AN14;   ## 33  on U80
#### NET "PHY_RESET"                             LOC = AH13;   ## 36  on U80
###NET "mrx_clk_pad_i"                           LOC = AP11;   ## 7   on U80
###NET "mrxdv_pad_i"                             LOC = AM13;   ## 4   on U80
###NET "mrxd_pad_i[0]"                           LOC = AN13;   ## 3   on U80
###NET "mrxd_pad_i[1]"                           LOC = AF14;   ## 128 on U80
###NET "mrxd_pad_i[2]"                           LOC = AE14;   ## 126 on U80
###NET "mrxd_pad_i[3]"                           LOC = AN12;   ## 125 on U80
#### NET "PHY_RXD4"                              LOC = AM12;   ## 124 on U80
#### NET "PHY_RXD5"                              LOC = AD11;   ## 123 on U80
#### NET "PHY_RXD6"                              LOC = AC12;   ## 121 on U80
#### NET "PHY_RXD7"                              LOC = AC13;   ## 120 on U80
###NET "mrxerr_pad_i"                            LOC = AG12;   ## 9   on U80
###NET "mtx_clk_pad_i"                           LOC = AD12;   ## 10  on U80
###NET "mtxen_pad_o"                             LOC = AJ10;   ## 16  on U80
#### NET "PHY_TXC_GTXCLK"                        LOC = AH12;   ## 14  on U80
###NET "mtxd_pad_o[0]"                           LOC = AM11;   ## 18  on U80
###NET "mtxd_pad_o[1]"                           LOC = AL11;   ## 19  on U80
###NET "mtxd_pad_o[2]"                           LOC = AG10;   ## 20  on U80
###NET "mtxd_pad_o[3]"                           LOC = AG11;   ## 24  on U80
#### NET "PHY_TXD4"                              LOC = AL10;   ## 25  on U80
#### NET "PHY_TXD5"                              LOC = AM10;   ## 26  on U80
#### NET "PHY_TXD6"                              LOC = AE11;   ## 28  on U80
#### NET "PHY_TXD7"                              LOC = AF11;   ## 29  on U80
###NET "mtxerr_pad_o"                            LOC = AH10;   ## 13  on U80

#######################################################################
##                      FMC Connector HPC1                           ##
#######################################################################

###NET  "fmc1_prsnt_i"                            LOC =  | IOSTANDARD = "LVCMOS25";   // Connected to CPU
###NET  "fmc1_pg_m2c_i"                           LOC =  | IOSTANDARD = "LVCMOS25";   // Connected to CPU

#// Trigger
#// LA28_P
set_property PACKAGE_PIN T8 [get_ports fmc1_trig_dir_o]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:106
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_trig_dir_o' has been applied to the port object 'fmc1_trig_dir_o'.
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_trig_dir_o]
#// LA26_N
set_property PACKAGE_PIN T2 [get_ports fmc1_trig_term_o]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:109
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_trig_term_o' has been applied to the port object 'fmc1_trig_term_o'.
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_trig_term_o]
#// LA32_P
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:112
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_trig_val_p_b' has been applied to the port object 'fmc1_trig_val_p_b'.
set_property IOSTANDARD BLVDS_25 [get_ports fmc1_trig_val_p_b]
#// LA32_N
set_property PACKAGE_PIN P1 [get_ports fmc1_trig_val_n_b]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:115
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_trig_val_n_b' has been applied to the port object 'fmc1_trig_val_n_b'.
set_property IOSTANDARD BLVDS_25 [get_ports fmc1_trig_val_n_b]

#// Si571 clock gen
#// HA12_N
set_property PACKAGE_PIN G34 [get_ports fmc1_si571_scl_pad_b]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:120
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_si571_scl_pad_b' has been applied to the port object 'fmc1_si571_scl_pad_b'.
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_si571_scl_pad_b]
#// HA13_P
set_property PACKAGE_PIN K25 [get_ports fmc1_si571_sda_pad_b]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:123
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_si571_sda_pad_b' has been applied to the port object 'fmc1_si571_sda_pad_b'.
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_si571_sda_pad_b]
#// HA12_P
set_property PACKAGE_PIN H33 [get_ports fmc1_si571_oe_o]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:126
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_si571_oe_o' has been applied to the port object 'fmc1_si571_oe_o'.
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_si571_oe_o]

#// AD9510 clock distribution PLL
#// LA13_N
set_property PACKAGE_PIN G9 [get_ports fmc1_spi_ad9510_cs_o]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:131
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_spi_ad9510_cs_o' has been applied to the port object 'fmc1_spi_ad9510_cs_o'.
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_spi_ad9510_cs_o]
#// LA13_P
set_property PACKAGE_PIN G10 [get_ports fmc1_spi_ad9510_sclk_o]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:134
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_spi_ad9510_sclk_o' has been applied to the port object 'fmc1_spi_ad9510_sclk_o'.
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_spi_ad9510_sclk_o]
#// LA09_N
set_property PACKAGE_PIN J3 [get_ports fmc1_spi_ad9510_mosi_o]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:137
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_spi_ad9510_mosi_o' has been applied to the port object 'fmc1_spi_ad9510_mosi_o'.
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_spi_ad9510_mosi_o]
#// LA14_P
set_property PACKAGE_PIN H9 [get_ports fmc1_spi_ad9510_miso_i]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:140
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_spi_ad9510_miso_i' has been applied to the port object 'fmc1_spi_ad9510_miso_i'.
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_spi_ad9510_miso_i]
#// LA14_N
set_property PACKAGE_PIN H8 [get_ports fmc1_pll_function_o]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:143
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_pll_function_o' has been applied to the port object 'fmc1_pll_function_o'.
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_pll_function_o]
#// LA09_P
set_property PACKAGE_PIN J4 [get_ports fmc1_pll_status_i]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:146
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_pll_status_i' has been applied to the port object 'fmc1_pll_status_i'.
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_pll_status_i]

###NET "fmc1_fpga_clk_p_i"                        LOC = H7  | IOSTANDARD = "LVDS_25";  // CLK0_M2C_P
###NET "fmc1_fpga_clk_n_i"                        LOC = H6  | IOSTANDARD = "LVDS_25";  // CLK0_M2C_N

#// Clock reference selection (TS3USB221)
#// LA31_P
set_property PACKAGE_PIN U7 [get_ports fmc1_clk_sel_o]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:154
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_clk_sel_o' has been applied to the port object 'fmc1_clk_sel_o'.
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_clk_sel_o]

#// EEPROM (multiplexer PCA9548) (Connected to the CPU)
# FPGA I2C SCL
set_property PACKAGE_PIN P6 [get_ports fmc1_eeprom_scl_pad_b]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:159
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_eeprom_scl_pad_b' has been applied to the port object 'fmc1_eeprom_scl_pad_b'.
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_eeprom_scl_pad_b]
# FPGA I2C SDA
set_property PACKAGE_PIN R11 [get_ports fmc1_eeprom_sda_pad_b]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:162
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_eeprom_sda_pad_b' has been applied to the port object 'fmc1_eeprom_sda_pad_b'.
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_eeprom_sda_pad_b]

#// LM75 temperature monitor
#// LA27_P
set_property PACKAGE_PIN R3 [get_ports fmc1_lm75_scl_pad_b]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:167
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_lm75_scl_pad_b' has been applied to the port object 'fmc1_lm75_scl_pad_b'.
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_lm75_scl_pad_b]
#// LA27_N
set_property PACKAGE_PIN R2 [get_ports fmc1_lm75_sda_pad_b]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:170
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_lm75_sda_pad_b' has been applied to the port object 'fmc1_lm75_sda_pad_b'.
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_lm75_sda_pad_b]
#// LA28_N
set_property PACKAGE_PIN T7 [get_ports fmc1_lm75_temp_alarm_i]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:173
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_lm75_temp_alarm_i' has been applied to the port object 'fmc1_lm75_temp_alarm_i'.
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_lm75_temp_alarm_i]

#// LTC ADC control pins
#// LA06_P
set_property PACKAGE_PIN L5 [get_ports fmc1_adc_pga_o]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:178
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc_pga_o' has been applied to the port object 'fmc1_adc_pga_o'.
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_adc_pga_o]
#// LA10_N
set_property PACKAGE_PIN G2 [get_ports fmc1_adc_shdn_o]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:181
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc_shdn_o' has been applied to the port object 'fmc1_adc_shdn_o'.
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_adc_shdn_o]
#// LA10_P
set_property PACKAGE_PIN H2 [get_ports fmc1_adc_dith_o]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:184
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc_dith_o' has been applied to the port object 'fmc1_adc_dith_o'.
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_adc_dith_o]
#// LA06_N
set_property PACKAGE_PIN K5 [get_ports fmc1_adc_rand_o]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:187
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc_rand_o' has been applied to the port object 'fmc1_adc_rand_o'.
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_adc_rand_o]

#// LEDs
#// LA16_N
set_property PACKAGE_PIN L9 [get_ports fmc1_led1_o]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:192
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_led1_o' has been applied to the port object 'fmc1_led1_o'.
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_led1_o]
#// LA16_P
set_property PACKAGE_PIN L10 [get_ports fmc1_led2_o]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:195
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_led2_o' has been applied to the port object 'fmc1_led2_o'.
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_led2_o]
#// LA26_P
set_property PACKAGE_PIN T3 [get_ports fmc1_led3_o]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:198
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_led3_o' has been applied to the port object 'fmc1_led3_o'.
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_led3_o]

#######################################################################
##                      FMC Connector HPC2                           ##
#######################################################################

###NET  "fmc2_prsnt_i"                            LOC =  | IOSTANDARD = "LVCMOS25";//  Connected to CPU
###NET  "fmc2_pg_m2c_i"                           LOC =  | IOSTANDARD = "LVCMOS25";//  Connected to CPU

#// Trigger
#// LA28_P
set_property PACKAGE_PIN W28 [get_ports fmc2_trig_dir_o]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:210
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_trig_dir_o' has been applied to the port object 'fmc2_trig_dir_o'.
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_trig_dir_o]
#// LA26_N
set_property PACKAGE_PIN AC32 [get_ports fmc2_trig_term_o]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:213
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_trig_term_o' has been applied to the port object 'fmc2_trig_term_o'.
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_trig_term_o]
#// LA32_P
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:216
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_trig_val_p_b' has been applied to the port object 'fmc2_trig_val_p_b'.
set_property IOSTANDARD BLVDS_25 [get_ports fmc2_trig_val_p_b]
#// LA32_N
set_property PACKAGE_PIN AB34 [get_ports fmc2_trig_val_n_b]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:219
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_trig_val_n_b' has been applied to the port object 'fmc2_trig_val_n_b'.
set_property IOSTANDARD BLVDS_25 [get_ports fmc2_trig_val_n_b]

#// Si571 clock gen
#// HA12_N
set_property PACKAGE_PIN AN29 [get_ports fmc2_si571_scl_pad_b]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:224
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_si571_scl_pad_b' has been applied to the port object 'fmc2_si571_scl_pad_b'.
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_si571_scl_pad_b]
#// HA13_P
set_property PACKAGE_PIN AN28 [get_ports fmc2_si571_sda_pad_b]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:227
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_si571_sda_pad_b' has been applied to the port object 'fmc2_si571_sda_pad_b'.
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_si571_sda_pad_b]
#// HA12_P
set_property PACKAGE_PIN AM29 [get_ports fmc2_si571_oe_o]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:230
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_si571_oe_o' has been applied to the port object 'fmc2_si571_oe_o'.
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_si571_oe_o]

#// AD9510 clock distribution PLL
#// LA13_N
set_property PACKAGE_PIN AG34 [get_ports fmc2_spi_ad9510_cs_o]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:235
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_spi_ad9510_cs_o' has been applied to the port object 'fmc2_spi_ad9510_cs_o'.
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_spi_ad9510_cs_o]
#// LA13_P
set_property PACKAGE_PIN AF34 [get_ports fmc2_spi_ad9510_sclk_o]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:238
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_spi_ad9510_sclk_o' has been applied to the port object 'fmc2_spi_ad9510_sclk_o'.
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_spi_ad9510_sclk_o]
#// LA09_N
set_property PACKAGE_PIN AG25 [get_ports fmc2_spi_ad9510_mosi_o]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:241
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_spi_ad9510_mosi_o' has been applied to the port object 'fmc2_spi_ad9510_mosi_o'.
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_spi_ad9510_mosi_o]
#// LA14_P
set_property PACKAGE_PIN AE33 [get_ports fmc2_spi_ad9510_miso_i]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:244
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_spi_ad9510_miso_i' has been applied to the port object 'fmc2_spi_ad9510_miso_i'.
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_spi_ad9510_miso_i]
#// LA14_N
set_property PACKAGE_PIN AF33 [get_ports fmc2_pll_function_o]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:247
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_pll_function_o' has been applied to the port object 'fmc2_pll_function_o'.
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_pll_function_o]
#// LA09_P
set_property PACKAGE_PIN AF25 [get_ports fmc2_pll_status_i]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:250
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_pll_status_i' has been applied to the port object 'fmc2_pll_status_i'.
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_pll_status_i]

###NET "fmc2_fpga_clk_p_i"                       LOC = AA30 | IOSTANDARD = "LVDS_25";  // CLK0_M2C_P
###NET "fmc2_fpga_clk_n_i"                       LOC = AB30 | IOSTANDARD = "LVDS_25";  // CLK0_M2C_N

#// Clock reference selection (TS3USB221)
#// LA31_P
set_property PACKAGE_PIN V31 [get_ports fmc2_clk_sel_o]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:258
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_clk_sel_o' has been applied to the port object 'fmc2_clk_sel_o'.
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_clk_sel_o]

#// EEPROM (multiplexer PCA9548) (Connected to the CPU)
###NET "eeprom_scl_pad_b"                        LOC =  | IOSTANDARD ="LVCMOS25"; #  SCL C30
###NET "eeprom_sda_pad_b"                        LOC =  | IOSTANDARD ="LVCMOS25"; #  SDA C31

#// LM75 temperature monitor
#// LA27_P
set_property PACKAGE_PIN AA27 [get_ports fmc2_lm75_scl_pad_b]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:267
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_lm75_scl_pad_b' has been applied to the port object 'fmc2_lm75_scl_pad_b'.
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_lm75_scl_pad_b]
#// LA27_N
set_property PACKAGE_PIN AA28 [get_ports fmc2_lm75_sda_pad_b]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:270
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_lm75_sda_pad_b' has been applied to the port object 'fmc2_lm75_sda_pad_b'.
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_lm75_sda_pad_b]
#// LA28_N
set_property PACKAGE_PIN W29 [get_ports fmc2_lm75_temp_alarm_i]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:273
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_lm75_temp_alarm_i' has been applied to the port object 'fmc2_lm75_temp_alarm_i'.
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_lm75_temp_alarm_i]

#// LTC ADC control pins
#// LA06_P
set_property PACKAGE_PIN AE23 [get_ports fmc2_adc_pga_o]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:278
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc_pga_o' has been applied to the port object 'fmc2_adc_pga_o'.
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_adc_pga_o]
#// LA10_N
set_property PACKAGE_PIN AH32 [get_ports fmc2_adc_shdn_o]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:281
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc_shdn_o' has been applied to the port object 'fmc2_adc_shdn_o'.
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_adc_shdn_o]
#// LA10_P
set_property PACKAGE_PIN AG32 [get_ports fmc2_adc_dith_o]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:284
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc_dith_o' has been applied to the port object 'fmc2_adc_dith_o'.
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_adc_dith_o]
#// LA06_N
set_property PACKAGE_PIN AF23 [get_ports fmc2_adc_rand_o]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:287
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc_rand_o' has been applied to the port object 'fmc2_adc_rand_o'.
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_adc_rand_o]

#// LEDs
#// LA16_N
set_property PACKAGE_PIN AD34 [get_ports fmc2_led1_o]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:292
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_led1_o' has been applied to the port object 'fmc2_led1_o'.
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_led1_o]
#// LA16_P
set_property PACKAGE_PIN AD33 [get_ports fmc2_led2_o]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:295
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_led2_o' has been applied to the port object 'fmc2_led2_o'.
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_led2_o]
#// LA26_P
set_property PACKAGE_PIN AC31 [get_ports fmc2_led3_o]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:298
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_led3_o' has been applied to the port object 'fmc2_led3_o'.
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_led3_o]

#######################################################################
##                       FMC Connector HPC1                           #
##                         LTC ADC lines                              #
#######################################################################

#// ADC0
#// LA17_CC_P
set_property PACKAGE_PIN T5 [get_ports fmc1_adc0_clk_i]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:308
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc0_clk_i' has been applied to the port object 'fmc1_adc0_clk_i'.
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_adc0_clk_i]

#// LA24_P
set_property PACKAGE_PIN M11 [get_ports {fmc1_adc0_data_i[0]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:312
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc0_data_i[0]' has been applied to the port object 'fmc1_adc0_data_i[0]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc0_data_i[0]}]
#// LA24_N
set_property PACKAGE_PIN M10 [get_ports {fmc1_adc0_data_i[1]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:315
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc0_data_i[1]' has been applied to the port object 'fmc1_adc0_data_i[1]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc0_data_i[1]}]
#// LA25_P
set_property PACKAGE_PIN N8 [get_ports {fmc1_adc0_data_i[2]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:318
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc0_data_i[2]' has been applied to the port object 'fmc1_adc0_data_i[2]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc0_data_i[2]}]
#// LA25_N
set_property PACKAGE_PIN N7 [get_ports {fmc1_adc0_data_i[3]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:321
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc0_data_i[3]' has been applied to the port object 'fmc1_adc0_data_i[3]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc0_data_i[3]}]
#// LA21_P
set_property PACKAGE_PIN M7 [get_ports {fmc1_adc0_data_i[4]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:324
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc0_data_i[4]' has been applied to the port object 'fmc1_adc0_data_i[4]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc0_data_i[4]}]
#// LA21_N
set_property PACKAGE_PIN M6 [get_ports {fmc1_adc0_data_i[5]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:327
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc0_data_i[5]' has been applied to the port object 'fmc1_adc0_data_i[5]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc0_data_i[5]}]
#// LA22_P
set_property PACKAGE_PIN M5 [get_ports {fmc1_adc0_data_i[6]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:330
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc0_data_i[6]' has been applied to the port object 'fmc1_adc0_data_i[6]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc0_data_i[6]}]
#// LA22_N
set_property PACKAGE_PIN M4 [get_ports {fmc1_adc0_data_i[7]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:333
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc0_data_i[7]' has been applied to the port object 'fmc1_adc0_data_i[7]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc0_data_i[7]}]
#// LA23_N
set_property PACKAGE_PIN N2 [get_ports {fmc1_adc0_data_i[8]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:336
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc0_data_i[8]' has been applied to the port object 'fmc1_adc0_data_i[8]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc0_data_i[8]}]
#// LA19_N
set_property PACKAGE_PIN U4 [get_ports {fmc1_adc0_data_i[9]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:339
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc0_data_i[9]' has been applied to the port object 'fmc1_adc0_data_i[9]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc0_data_i[9]}]
#// LA18_CC_N
set_property PACKAGE_PIN P3 [get_ports {fmc1_adc0_data_i[10]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:342
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc0_data_i[10]' has been applied to the port object 'fmc1_adc0_data_i[10]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc0_data_i[10]}]
#// LA23_P
set_property PACKAGE_PIN N3 [get_ports {fmc1_adc0_data_i[11]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:345
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc0_data_i[11]' has been applied to the port object 'fmc1_adc0_data_i[11]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc0_data_i[11]}]
#// LA20_N
set_property PACKAGE_PIN P10 [get_ports {fmc1_adc0_data_i[12]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:348
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc0_data_i[12]' has been applied to the port object 'fmc1_adc0_data_i[12]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc0_data_i[12]}]
#// LA19_P
set_property PACKAGE_PIN U5 [get_ports {fmc1_adc0_data_i[13]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:351
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc0_data_i[13]' has been applied to the port object 'fmc1_adc0_data_i[13]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc0_data_i[13]}]
#// LA18_CC_P
set_property PACKAGE_PIN P4 [get_ports {fmc1_adc0_data_i[14]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:354
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc0_data_i[14]' has been applied to the port object 'fmc1_adc0_data_i[14]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc0_data_i[14]}]
#// LA20_P
set_property PACKAGE_PIN R10 [get_ports {fmc1_adc0_data_i[15]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:357
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc0_data_i[15]' has been applied to the port object 'fmc1_adc0_data_i[15]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc0_data_i[15]}]
#// LA29_P
set_property PACKAGE_PIN P9 [get_ports fmc1_adc0_of_i]
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_adc0_of_i]

#// ADC1
#// HA17_CC_P
set_property PACKAGE_PIN J28 [get_ports fmc1_adc1_clk_i]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:365
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc1_clk_i' has been applied to the port object 'fmc1_adc1_clk_i'.
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_adc1_clk_i]

#// HA10_P
set_property PACKAGE_PIN H32 [get_ports {fmc1_adc1_data_i[15]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:369
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc1_data_i[15]' has been applied to the port object 'fmc1_adc1_data_i[15]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc1_data_i[15]}]
#// HA11_P
set_property PACKAGE_PIN M25 [get_ports {fmc1_adc1_data_i[14]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:372
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc1_data_i[14]' has been applied to the port object 'fmc1_adc1_data_i[14]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc1_data_i[14]}]
#// HA10_N
set_property PACKAGE_PIN G32 [get_ports {fmc1_adc1_data_i[13]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:375
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc1_data_i[13]' has been applied to the port object 'fmc1_adc1_data_i[13]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc1_data_i[13]}]
#// HA11_N
set_property PACKAGE_PIN L25 [get_ports {fmc1_adc1_data_i[12]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:378
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc1_data_i[12]' has been applied to the port object 'fmc1_adc1_data_i[12]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc1_data_i[12]}]
#// HA15_P
set_property PACKAGE_PIN G29 [get_ports {fmc1_adc1_data_i[11]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:381
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc1_data_i[11]' has been applied to the port object 'fmc1_adc1_data_i[11]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc1_data_i[11]}]
#// HA14_P
set_property PACKAGE_PIN M24 [get_ports {fmc1_adc1_data_i[10]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:384
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc1_data_i[10]' has been applied to the port object 'fmc1_adc1_data_i[10]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc1_data_i[10]}]
#// HA15_N
set_property PACKAGE_PIN G30 [get_ports {fmc1_adc1_data_i[9]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:387
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc1_data_i[9]' has been applied to the port object 'fmc1_adc1_data_i[9]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc1_data_i[9]}]
#// HA14_N
set_property PACKAGE_PIN L24 [get_ports {fmc1_adc1_data_i[8]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:390
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc1_data_i[8]' has been applied to the port object 'fmc1_adc1_data_i[8]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc1_data_i[8]}]
#// HA18_N
set_property PACKAGE_PIN G27 [get_ports {fmc1_adc1_data_i[7]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:393
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc1_data_i[7]' has been applied to the port object 'fmc1_adc1_data_i[7]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc1_data_i[7]}]
#// HA18_P
set_property PACKAGE_PIN H27 [get_ports {fmc1_adc1_data_i[6]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:396
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc1_data_i[6]' has been applied to the port object 'fmc1_adc1_data_i[6]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc1_data_i[6]}]
#// HA19_N
set_property PACKAGE_PIN G26 [get_ports {fmc1_adc1_data_i[5]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:399
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc1_data_i[5]' has been applied to the port object 'fmc1_adc1_data_i[5]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc1_data_i[5]}]
#// HA21_P
set_property PACKAGE_PIN G24 [get_ports {fmc1_adc1_data_i[4]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:402
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc1_data_i[4]' has been applied to the port object 'fmc1_adc1_data_i[4]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc1_data_i[4]}]
#// HA22_P
set_property PACKAGE_PIN J24 [get_ports {fmc1_adc1_data_i[3]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:405
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc1_data_i[3]' has been applied to the port object 'fmc1_adc1_data_i[3]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc1_data_i[3]}]
#// HA21_N
set_property PACKAGE_PIN G25 [get_ports {fmc1_adc1_data_i[2]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:408
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc1_data_i[2]' has been applied to the port object 'fmc1_adc1_data_i[2]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc1_data_i[2]}]
#// HA23_P
set_property PACKAGE_PIN K23 [get_ports {fmc1_adc1_data_i[1]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:411
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc1_data_i[1]' has been applied to the port object 'fmc1_adc1_data_i[1]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc1_data_i[1]}]
#// HA22_N
set_property PACKAGE_PIN H24 [get_ports {fmc1_adc1_data_i[0]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:414
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc1_data_i[0]' has been applied to the port object 'fmc1_adc1_data_i[0]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc1_data_i[0]}]
#// HA23_N
set_property PACKAGE_PIN J23 [get_ports fmc1_adc1_of_i]
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_adc1_of_i]

#// ADC2
#// LA00_CC_P
set_property PACKAGE_PIN K7 [get_ports fmc1_adc2_clk_i]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:422
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc2_clk_i' has been applied to the port object 'fmc1_adc2_clk_i'.
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_adc2_clk_i]

#// LA01_CC_P
set_property PACKAGE_PIN J6 [get_ports {fmc1_adc2_data_i[15]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:426
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc2_data_i[15]' has been applied to the port object 'fmc1_adc2_data_i[15]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc2_data_i[15]}]
#// LA02_P
set_property PACKAGE_PIN G7 [get_ports {fmc1_adc2_data_i[14]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:429
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc2_data_i[14]' has been applied to the port object 'fmc1_adc2_data_i[14]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc2_data_i[14]}]
#// LA01_CC_N
set_property PACKAGE_PIN J5 [get_ports {fmc1_adc2_data_i[13]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:432
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc2_data_i[13]' has been applied to the port object 'fmc1_adc2_data_i[13]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc2_data_i[13]}]
#// LA02_N
set_property PACKAGE_PIN G6 [get_ports {fmc1_adc2_data_i[12]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:435
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc2_data_i[12]' has been applied to the port object 'fmc1_adc2_data_i[12]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc2_data_i[12]}]
#// LA03_N
set_property PACKAGE_PIN G1 [get_ports {fmc1_adc2_data_i[11]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:438
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc2_data_i[11]' has been applied to the port object 'fmc1_adc2_data_i[11]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc2_data_i[11]}]
#// LA03_P
set_property PACKAGE_PIN H1 [get_ports {fmc1_adc2_data_i[10]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:441
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc2_data_i[10]' has been applied to the port object 'fmc1_adc2_data_i[10]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc2_data_i[10]}]
#// LA04_N
set_property PACKAGE_PIN J1 [get_ports {fmc1_adc2_data_i[9]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:444
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc2_data_i[9]' has been applied to the port object 'fmc1_adc2_data_i[9]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc2_data_i[9]}]
#// LA04_P
set_property PACKAGE_PIN K1 [get_ports {fmc1_adc2_data_i[8]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:447
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc2_data_i[8]' has been applied to the port object 'fmc1_adc2_data_i[8]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc2_data_i[8]}]
#// LA05_N
set_property PACKAGE_PIN H3 [get_ports {fmc1_adc2_data_i[7]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:450
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc2_data_i[7]' has been applied to the port object 'fmc1_adc2_data_i[7]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc2_data_i[7]}]
#// LA05_P
set_property PACKAGE_PIN H4 [get_ports {fmc1_adc2_data_i[6]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:453
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc2_data_i[6]' has been applied to the port object 'fmc1_adc2_data_i[6]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc2_data_i[6]}]
#// LA08_N
set_property PACKAGE_PIN F2 [get_ports {fmc1_adc2_data_i[5]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:456
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc2_data_i[5]' has been applied to the port object 'fmc1_adc2_data_i[5]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc2_data_i[5]}]
#// LA08_P
set_property PACKAGE_PIN F3 [get_ports {fmc1_adc2_data_i[4]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:459
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc2_data_i[4]' has been applied to the port object 'fmc1_adc2_data_i[4]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc2_data_i[4]}]
#// LA07_N
set_property PACKAGE_PIN K2 [get_ports {fmc1_adc2_data_i[3]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:462
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc2_data_i[3]' has been applied to the port object 'fmc1_adc2_data_i[3]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc2_data_i[3]}]
#// LA07_P
set_property PACKAGE_PIN K3 [get_ports {fmc1_adc2_data_i[2]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:465
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc2_data_i[2]' has been applied to the port object 'fmc1_adc2_data_i[2]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc2_data_i[2]}]
#// LA12_N
set_property PACKAGE_PIN K8 [get_ports {fmc1_adc2_data_i[1]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:468
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc2_data_i[1]' has been applied to the port object 'fmc1_adc2_data_i[1]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc2_data_i[1]}]
#// LA12_P
set_property PACKAGE_PIN L8 [get_ports {fmc1_adc2_data_i[0]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:471
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc2_data_i[0]' has been applied to the port object 'fmc1_adc2_data_i[0]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc2_data_i[0]}]
#// LA11_P
set_property PACKAGE_PIN M2 [get_ports fmc1_adc2_of_i]
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_adc2_of_i]

#// ADC3
#// HA01_CC_P
set_property PACKAGE_PIN L28 [get_ports fmc1_adc3_clk_i]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:479
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc3_clk_i' has been applied to the port object 'fmc1_adc3_clk_i'.
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_adc3_clk_i]

#// HA00_CC_N
set_property PACKAGE_PIN H29 [get_ports {fmc1_adc3_data_i[15]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:483
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc3_data_i[15]' has been applied to the port object 'fmc1_adc3_data_i[15]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc3_data_i[15]}]
#// HA00_CC_P
set_property PACKAGE_PIN J29 [get_ports {fmc1_adc3_data_i[14]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:486
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc3_data_i[14]' has been applied to the port object 'fmc1_adc3_data_i[14]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc3_data_i[14]}]
#// HA05_N
set_property PACKAGE_PIN H34 [get_ports {fmc1_adc3_data_i[13]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:489
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc3_data_i[13]' has been applied to the port object 'fmc1_adc3_data_i[13]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc3_data_i[13]}]
#// HA05_P
set_property PACKAGE_PIN J33 [get_ports {fmc1_adc3_data_i[12]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:492
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc3_data_i[12]' has been applied to the port object 'fmc1_adc3_data_i[12]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc3_data_i[12]}]
#// HA04_N
set_property PACKAGE_PIN L34 [get_ports {fmc1_adc3_data_i[11]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:495
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc3_data_i[11]' has been applied to the port object 'fmc1_adc3_data_i[11]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc3_data_i[11]}]
#// HA04_P
set_property PACKAGE_PIN L33 [get_ports {fmc1_adc3_data_i[10]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:498
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc3_data_i[10]' has been applied to the port object 'fmc1_adc3_data_i[10]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc3_data_i[10]}]
#// HA09_N
set_property PACKAGE_PIN J31 [get_ports {fmc1_adc3_data_i[9]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:501
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc3_data_i[9]' has been applied to the port object 'fmc1_adc3_data_i[9]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc3_data_i[9]}]
#// HA09_P
set_property PACKAGE_PIN K31 [get_ports {fmc1_adc3_data_i[8]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:504
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc3_data_i[8]' has been applied to the port object 'fmc1_adc3_data_i[8]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc3_data_i[8]}]
#// HA03_N
set_property PACKAGE_PIN J30 [get_ports {fmc1_adc3_data_i[7]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:507
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc3_data_i[7]' has been applied to the port object 'fmc1_adc3_data_i[7]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc3_data_i[7]}]
#// HA03_P
set_property PACKAGE_PIN K30 [get_ports {fmc1_adc3_data_i[6]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:510
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc3_data_i[6]' has been applied to the port object 'fmc1_adc3_data_i[6]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc3_data_i[6]}]
#// HA08_P
set_property PACKAGE_PIN L29 [get_ports {fmc1_adc3_data_i[5]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:513
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc3_data_i[5]' has been applied to the port object 'fmc1_adc3_data_i[5]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc3_data_i[5]}]
#// HA02_P
set_property PACKAGE_PIN K33 [get_ports {fmc1_adc3_data_i[4]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:516
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc3_data_i[4]' has been applied to the port object 'fmc1_adc3_data_i[4]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc3_data_i[4]}]
#// HA07_P
set_property PACKAGE_PIN L32 [get_ports {fmc1_adc3_data_i[3]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:519
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc3_data_i[3]' has been applied to the port object 'fmc1_adc3_data_i[3]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc3_data_i[3]}]
#// HA02_N
set_property PACKAGE_PIN J34 [get_ports {fmc1_adc3_data_i[2]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:522
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc3_data_i[2]' has been applied to the port object 'fmc1_adc3_data_i[2]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc3_data_i[2]}]
#// HA06_P
set_property PACKAGE_PIN L27 [get_ports {fmc1_adc3_data_i[1]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:525
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc3_data_i[1]' has been applied to the port object 'fmc1_adc3_data_i[1]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc1_adc3_data_i[1]}]
#// HA07_N
set_property PACKAGE_PIN K32 [get_ports {fmc1_adc3_data_i[0]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:528
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc1_adc3_data_i[0]' has been applied to the port object 'fmc1_adc3_data_i[0]'.
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
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:541
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc0_clk_i' has been applied to the port object 'fmc2_adc0_clk_i'.
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_adc0_clk_i]

#// LA24_P
set_property PACKAGE_PIN Y32 [get_ports {fmc2_adc0_data_i[0]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:545
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc0_data_i[0]' has been applied to the port object 'fmc2_adc0_data_i[0]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc0_data_i[0]}]
#// LA24_N
set_property PACKAGE_PIN Y33 [get_ports {fmc2_adc0_data_i[1]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:548
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc0_data_i[1]' has been applied to the port object 'fmc2_adc0_data_i[1]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc0_data_i[1]}]
#// LA25_P
set_property PACKAGE_PIN AA29 [get_ports {fmc2_adc0_data_i[2]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:551
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc0_data_i[2]' has been applied to the port object 'fmc2_adc0_data_i[2]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc0_data_i[2]}]
#// LA25_N
set_property PACKAGE_PIN AB29 [get_ports {fmc2_adc0_data_i[3]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:554
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc0_data_i[3]' has been applied to the port object 'fmc2_adc0_data_i[3]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc0_data_i[3]}]
#// LA21_P
set_property PACKAGE_PIN AA32 [get_ports {fmc2_adc0_data_i[4]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:557
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc0_data_i[4]' has been applied to the port object 'fmc2_adc0_data_i[4]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc0_data_i[4]}]
#// LA21_N
set_property PACKAGE_PIN AA33 [get_ports {fmc2_adc0_data_i[5]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:560
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc0_data_i[5]' has been applied to the port object 'fmc2_adc0_data_i[5]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc0_data_i[5]}]
#// LA22_P
set_property PACKAGE_PIN AA24 [get_ports {fmc2_adc0_data_i[6]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:563
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc0_data_i[6]' has been applied to the port object 'fmc2_adc0_data_i[6]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc0_data_i[6]}]
#// LA22_N
set_property PACKAGE_PIN AA25 [get_ports {fmc2_adc0_data_i[7]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:566
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc0_data_i[7]' has been applied to the port object 'fmc2_adc0_data_i[7]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc0_data_i[7]}]
#// LA23_N
set_property PACKAGE_PIN Y25 [get_ports {fmc2_adc0_data_i[8]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:569
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc0_data_i[8]' has been applied to the port object 'fmc2_adc0_data_i[8]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc0_data_i[8]}]
#// LA19_N
set_property PACKAGE_PIN AB27 [get_ports {fmc2_adc0_data_i[9]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:572
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc0_data_i[9]' has been applied to the port object 'fmc2_adc0_data_i[9]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc0_data_i[9]}]
#// LA18_CC_N
set_property PACKAGE_PIN W31 [get_ports {fmc2_adc0_data_i[10]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:575
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc0_data_i[10]' has been applied to the port object 'fmc2_adc0_data_i[10]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc0_data_i[10]}]
#// LA23_P
set_property PACKAGE_PIN W25 [get_ports {fmc2_adc0_data_i[11]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:578
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc0_data_i[11]' has been applied to the port object 'fmc2_adc0_data_i[11]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc0_data_i[11]}]
#// LA20_N
set_property PACKAGE_PIN AB25 [get_ports {fmc2_adc0_data_i[12]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:581
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc0_data_i[12]' has been applied to the port object 'fmc2_adc0_data_i[12]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc0_data_i[12]}]
#// LA19_P
set_property PACKAGE_PIN AB26 [get_ports {fmc2_adc0_data_i[13]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:584
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc0_data_i[13]' has been applied to the port object 'fmc2_adc0_data_i[13]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc0_data_i[13]}]
#// LA18_CC_P
set_property PACKAGE_PIN W30 [get_ports {fmc2_adc0_data_i[14]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:587
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc0_data_i[14]' has been applied to the port object 'fmc2_adc0_data_i[14]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc0_data_i[14]}]
#// LA20_P
set_property PACKAGE_PIN AB24 [get_ports {fmc2_adc0_data_i[15]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:590
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc0_data_i[15]' has been applied to the port object 'fmc2_adc0_data_i[15]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc0_data_i[15]}]
#// LA29_P
set_property PACKAGE_PIN AC33 [get_ports fmc2_adc0_of_i]
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_adc0_of_i]

#// ADC1
#// HA17_CC_P
set_property PACKAGE_PIN AJ28 [get_ports fmc2_adc1_clk_i]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:598
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc1_clk_i' has been applied to the port object 'fmc2_adc1_clk_i'.
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_adc1_clk_i]

#// HA10_P
set_property PACKAGE_PIN AP25 [get_ports {fmc2_adc1_data_i[15]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:602
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc1_data_i[15]' has been applied to the port object 'fmc2_adc1_data_i[15]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc1_data_i[15]}]
#// HA11_P
set_property PACKAGE_PIN AK33 [get_ports {fmc2_adc1_data_i[14]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:605
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc1_data_i[14]' has been applied to the port object 'fmc2_adc1_data_i[14]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc1_data_i[14]}]
#// HA10_N
set_property PACKAGE_PIN AP26 [get_ports {fmc2_adc1_data_i[13]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:608
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc1_data_i[13]' has been applied to the port object 'fmc2_adc1_data_i[13]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc1_data_i[13]}]
#// HA11_N
set_property PACKAGE_PIN AL33 [get_ports {fmc2_adc1_data_i[12]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:611
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc1_data_i[12]' has been applied to the port object 'fmc2_adc1_data_i[12]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc1_data_i[12]}]
#// HA15_P
set_property PACKAGE_PIN AJ29 [get_ports {fmc2_adc1_data_i[11]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:614
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc1_data_i[11]' has been applied to the port object 'fmc2_adc1_data_i[11]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc1_data_i[11]}]
#// HA14_P
set_property PACKAGE_PIN AN34 [get_ports {fmc2_adc1_data_i[10]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:617
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc1_data_i[10]' has been applied to the port object 'fmc2_adc1_data_i[10]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc1_data_i[10]}]
#// HA15_N
set_property PACKAGE_PIN AK30 [get_ports {fmc2_adc1_data_i[9]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:620
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc1_data_i[9]' has been applied to the port object 'fmc2_adc1_data_i[9]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc1_data_i[9]}]
#// HA14_N
set_property PACKAGE_PIN AP34 [get_ports {fmc2_adc1_data_i[8]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:623
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc1_data_i[8]' has been applied to the port object 'fmc2_adc1_data_i[8]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc1_data_i[8]}]
#// HA18_N
set_property PACKAGE_PIN AP33 [get_ports {fmc2_adc1_data_i[7]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:626
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc1_data_i[7]' has been applied to the port object 'fmc2_adc1_data_i[7]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc1_data_i[7]}]
#// HA18_P
set_property PACKAGE_PIN AN33 [get_ports {fmc2_adc1_data_i[6]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:629
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc1_data_i[6]' has been applied to the port object 'fmc2_adc1_data_i[6]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc1_data_i[6]}]
#// HA19_N
set_property PACKAGE_PIN AK31 [get_ports {fmc2_adc1_data_i[5]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:632
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc1_data_i[5]' has been applied to the port object 'fmc2_adc1_data_i[5]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc1_data_i[5]}]
#// HA21_P
set_property PACKAGE_PIN AP29 [get_ports {fmc2_adc1_data_i[4]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:635
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc1_data_i[4]' has been applied to the port object 'fmc2_adc1_data_i[4]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc1_data_i[4]}]
#// HA22_P
set_property PACKAGE_PIN AL34 [get_ports {fmc2_adc1_data_i[3]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:638
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc1_data_i[3]' has been applied to the port object 'fmc2_adc1_data_i[3]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc1_data_i[3]}]
#// HA21_N
set_property PACKAGE_PIN AP30 [get_ports {fmc2_adc1_data_i[2]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:641
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc1_data_i[2]' has been applied to the port object 'fmc2_adc1_data_i[2]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc1_data_i[2]}]
#// HA23_P
set_property PACKAGE_PIN AJ33 [get_ports {fmc2_adc1_data_i[1]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:644
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc1_data_i[1]' has been applied to the port object 'fmc2_adc1_data_i[1]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc1_data_i[1]}]
#// HA22_N
set_property PACKAGE_PIN AM34 [get_ports {fmc2_adc1_data_i[0]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:647
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc1_data_i[0]' has been applied to the port object 'fmc2_adc1_data_i[0]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc1_data_i[0]}]
#// HA23_N
set_property PACKAGE_PIN AJ34 [get_ports fmc2_adc1_of_i]
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_adc1_of_i]

#// ADC2
#// LA00_CC_P
set_property PACKAGE_PIN AE28 [get_ports fmc2_adc2_clk_i]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:655
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc2_clk_i' has been applied to the port object 'fmc2_adc2_clk_i'.
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_adc2_clk_i]

#// LA01_CC_P
set_property PACKAGE_PIN AF29 [get_ports {fmc2_adc2_data_i[15]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:659
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc2_data_i[15]' has been applied to the port object 'fmc2_adc2_data_i[15]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc2_data_i[15]}]
#// LA02_P
set_property PACKAGE_PIN AG31 [get_ports {fmc2_adc2_data_i[14]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:662
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc2_data_i[14]' has been applied to the port object 'fmc2_adc2_data_i[14]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc2_data_i[14]}]
#// LA01_CC_N
set_property PACKAGE_PIN AF30 [get_ports {fmc2_adc2_data_i[13]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:665
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc2_data_i[13]' has been applied to the port object 'fmc2_adc2_data_i[13]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc2_data_i[13]}]
#// LA02_N
set_property PACKAGE_PIN AH31 [get_ports {fmc2_adc2_data_i[12]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:668
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc2_data_i[12]' has been applied to the port object 'fmc2_adc2_data_i[12]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc2_data_i[12]}]
#// LA03_N
set_property PACKAGE_PIN AH24 [get_ports {fmc2_adc2_data_i[11]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:671
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc2_data_i[11]' has been applied to the port object 'fmc2_adc2_data_i[11]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc2_data_i[11]}]
#// LA03_P
set_property PACKAGE_PIN AG24 [get_ports {fmc2_adc2_data_i[10]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:674
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc2_data_i[10]' has been applied to the port object 'fmc2_adc2_data_i[10]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc2_data_i[10]}]
#// LA04_N
set_property PACKAGE_PIN AC27 [get_ports {fmc2_adc2_data_i[9]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:677
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc2_data_i[9]' has been applied to the port object 'fmc2_adc2_data_i[9]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc2_data_i[9]}]
#// LA04_P
set_property PACKAGE_PIN AC26 [get_ports {fmc2_adc2_data_i[8]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:680
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc2_data_i[8]' has been applied to the port object 'fmc2_adc2_data_i[8]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc2_data_i[8]}]
#// LA05_N
set_property PACKAGE_PIN AH34 [get_ports {fmc2_adc2_data_i[7]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:683
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc2_data_i[7]' has been applied to the port object 'fmc2_adc2_data_i[7]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc2_data_i[7]}]
#// LA05_P
set_property PACKAGE_PIN AH33 [get_ports {fmc2_adc2_data_i[6]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:686
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc2_data_i[6]' has been applied to the port object 'fmc2_adc2_data_i[6]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc2_data_i[6]}]
#// LA08_N
set_property PACKAGE_PIN AE25 [get_ports {fmc2_adc2_data_i[5]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:689
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc2_data_i[5]' has been applied to the port object 'fmc2_adc2_data_i[5]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc2_data_i[5]}]
#// LA08_P
set_property PACKAGE_PIN AD25 [get_ports {fmc2_adc2_data_i[4]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:692
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc2_data_i[4]' has been applied to the port object 'fmc2_adc2_data_i[4]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc2_data_i[4]}]
#// LA07_N
set_property PACKAGE_PIN AH27 [get_ports {fmc2_adc2_data_i[3]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:695
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc2_data_i[3]' has been applied to the port object 'fmc2_adc2_data_i[3]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc2_data_i[3]}]
#// LA07_P
set_property PACKAGE_PIN AG27 [get_ports {fmc2_adc2_data_i[2]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:698
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc2_data_i[2]' has been applied to the port object 'fmc2_adc2_data_i[2]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc2_data_i[2]}]
#// LA12_N
set_property PACKAGE_PIN AF27 [get_ports {fmc2_adc2_data_i[1]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:701
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc2_data_i[1]' has been applied to the port object 'fmc2_adc2_data_i[1]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc2_data_i[1]}]
#// LA12_P
set_property PACKAGE_PIN AE27 [get_ports {fmc2_adc2_data_i[0]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:704
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc2_data_i[0]' has been applied to the port object 'fmc2_adc2_data_i[0]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc2_data_i[0]}]
#// LA11_P
set_property PACKAGE_PIN AD30 [get_ports fmc2_adc2_of_i]
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_adc2_of_i]

#// ADC3
#// HA01_CC_P
set_property PACKAGE_PIN AL28 [get_ports fmc2_adc3_clk_i]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:712
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc3_clk_i' has been applied to the port object 'fmc2_adc3_clk_i'.
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_adc3_clk_i]

#// HA00_CC_N
set_property PACKAGE_PIN AM30 [get_ports {fmc2_adc3_data_i[15]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:716
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc3_data_i[15]' has been applied to the port object 'fmc2_adc3_data_i[15]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc3_data_i[15]}]
#// HA00_CC_P
set_property PACKAGE_PIN AL30 [get_ports {fmc2_adc3_data_i[14]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:719
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc3_data_i[14]' has been applied to the port object 'fmc2_adc3_data_i[14]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc3_data_i[14]}]
#// HA05_N
set_property PACKAGE_PIN AM25 [get_ports {fmc2_adc3_data_i[13]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:722
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc3_data_i[13]' has been applied to the port object 'fmc2_adc3_data_i[13]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc3_data_i[13]}]
#// HA05_P
set_property PACKAGE_PIN AL25 [get_ports {fmc2_adc3_data_i[12]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:725
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc3_data_i[12]' has been applied to the port object 'fmc2_adc3_data_i[12]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc3_data_i[12]}]
#// HA04_N
set_property PACKAGE_PIN AK25 [get_ports {fmc2_adc3_data_i[11]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:728
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc3_data_i[11]' has been applied to the port object 'fmc2_adc3_data_i[11]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc3_data_i[11]}]
#// HA04_P
set_property PACKAGE_PIN AJ25 [get_ports {fmc2_adc3_data_i[10]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:731
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc3_data_i[10]' has been applied to the port object 'fmc2_adc3_data_i[10]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc3_data_i[10]}]
#// HA09_N
set_property PACKAGE_PIN AK26 [get_ports {fmc2_adc3_data_i[9]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:734
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc3_data_i[9]' has been applied to the port object 'fmc2_adc3_data_i[9]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc3_data_i[9]}]
#// HA09_P
set_property PACKAGE_PIN AJ26 [get_ports {fmc2_adc3_data_i[8]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:737
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc3_data_i[8]' has been applied to the port object 'fmc2_adc3_data_i[8]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc3_data_i[8]}]
#// HA03_N
set_property PACKAGE_PIN AN26 [get_ports {fmc2_adc3_data_i[7]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:740
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc3_data_i[7]' has been applied to the port object 'fmc2_adc3_data_i[7]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc3_data_i[7]}]
#// HA03_P
set_property PACKAGE_PIN AM26 [get_ports {fmc2_adc3_data_i[6]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:743
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc3_data_i[6]' has been applied to the port object 'fmc2_adc3_data_i[6]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc3_data_i[6]}]
#// HA08_P
set_property PACKAGE_PIN AM27 [get_ports {fmc2_adc3_data_i[5]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:746
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc3_data_i[5]' has been applied to the port object 'fmc2_adc3_data_i[5]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc3_data_i[5]}]
#// HA02_P
set_property PACKAGE_PIN AN31 [get_ports {fmc2_adc3_data_i[4]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:749
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc3_data_i[4]' has been applied to the port object 'fmc2_adc3_data_i[4]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc3_data_i[4]}]
#// HA07_P
set_property PACKAGE_PIN AM31 [get_ports {fmc2_adc3_data_i[3]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:752
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc3_data_i[3]' has been applied to the port object 'fmc2_adc3_data_i[3]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc3_data_i[3]}]
#// HA02_N
set_property PACKAGE_PIN AP31 [get_ports {fmc2_adc3_data_i[2]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:755
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc3_data_i[2]' has been applied to the port object 'fmc2_adc3_data_i[2]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc3_data_i[2]}]
#// HA06_P
set_property PACKAGE_PIN AL32 [get_ports {fmc2_adc3_data_i[1]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:758
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc3_data_i[1]' has been applied to the port object 'fmc2_adc3_data_i[1]'.
set_property IOSTANDARD LVCMOS25 [get_ports {fmc2_adc3_data_i[1]}]
#// HA07_N
set_property PACKAGE_PIN AN32 [get_ports {fmc2_adc3_data_i[0]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:761
# The conversion of 'IOSTANDARD' constraint on 'net' object 'fmc2_adc3_data_i[0]' has been applied to the port object 'fmc2_adc3_data_i[0]'.
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

## /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:781
## The conversion of 'DIFF_TERM' constraint on 'net' object 'sys_clk_p_i' has been applied to the port object 'sys_clk_p_i'.
#set_property DIFF_TERM TRUE [get_ports sys_clk_p_i]
## /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:782
## The conversion of 'DIFF_TERM' constraint on 'net' object 'sys_clk_n_i' has been applied to the port object 'sys_clk_n_i'.
#set_property DIFF_TERM TRUE [get_ports sys_clk_n_i]

# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:784
# The conversion of 'DIFF_TERM' constraint on 'net' object 'fmc1_trig_val_p_b' has been applied to the port object 'fmc1_trig_val_p_b'.
set_property DIFF_TERM TRUE [get_ports fmc1_trig_val_p_b]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:785
# The conversion of 'DIFF_TERM' constraint on 'net' object 'fmc1_trig_val_n_b' has been applied to the port object 'fmc1_trig_val_n_b'.
set_property DIFF_TERM TRUE [get_ports fmc1_trig_val_n_b]

# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:787
# The conversion of 'DIFF_TERM' constraint on 'net' object 'fmc2_trig_val_p_b' has been applied to the port object 'fmc2_trig_val_p_b'.
set_property DIFF_TERM TRUE [get_ports fmc2_trig_val_p_b]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:788
# The conversion of 'DIFF_TERM' constraint on 'net' object 'fmc2_trig_val_n_b' has been applied to the port object 'fmc2_trig_val_n_b'.
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
set_property IDELAY_VALUE 29 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[7].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 29 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[4].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 29 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[5].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 29 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[8].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 29 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[1].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 29 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[9].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 29 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[2].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 29 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[5].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 29 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[6].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 29 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[9].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 29 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[2].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 29 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[3].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 29 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[7].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 29 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[0].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 29 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[6].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 29 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[3].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 29 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[4].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 29 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[0].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 29 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[8].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 29 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[1].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 31 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[3].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 31 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[4].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 31 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[0].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 31 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[8].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 31 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[1].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 31 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[7].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 31 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[4].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 31 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[5].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 31 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[8].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 31 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[1].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 31 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[9].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 31 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[2].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 31 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[5].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 31 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[6].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 31 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[9].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 31 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[2].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 31 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[3].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 31 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[7].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 31 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[0].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 31 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[6].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 17 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[3].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 17 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[7].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 17 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[0].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 17 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[6].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 17 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[3].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 17 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[4].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 17 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[7].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 17 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[0].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 17 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[8].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 17 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[1].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 17 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[4].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 17 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[5].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 17 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[8].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 17 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[1].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 17 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[9].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 17 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[2].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 17 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[6].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 17 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[5].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 17 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[9].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 17 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[2].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 26 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[6].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 26 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[5].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 26 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[9].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 26 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[2].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 26 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[3].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 26 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[7].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 26 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[0].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 26 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[6].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 26 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[3].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 26 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[4].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 26 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[7].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 26 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[0].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 26 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[8].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 26 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[1].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 26 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[4].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 26 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[5].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 26 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[8].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 26 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[1].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 26 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[9].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IDELAY_VALUE 26 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[2].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]

# Overrides default_delay hdl parameter
set_property IDELAY_VALUE 0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_clock_chains[0].gen_clock_chains_check.cmp_fmc_adc_clk/gen_adc_clk_7series_iodelay.gen_adc_clk_var_load_iodelay.cmp_ibufds_clk_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_clock_chains[0].gen_clock_chains_check.cmp_fmc_adc_clk/gen_adc_clk_7series_iodelay.gen_adc_clk_var_load_iodelay.cmp_ibufds_clk_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_clock_chains[1].gen_clock_chains_check.cmp_fmc_adc_clk/gen_adc_clk_7series_iodelay.gen_adc_clk_var_load_iodelay.cmp_ibufds_clk_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_clock_chains[1].gen_clock_chains_check.cmp_fmc_adc_clk/gen_adc_clk_7series_iodelay.gen_adc_clk_var_load_iodelay.cmp_ibufds_clk_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_clock_chains[2].gen_clock_chains_check.cmp_fmc_adc_clk/gen_adc_clk_7series_iodelay.gen_adc_clk_var_load_iodelay.cmp_ibufds_clk_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_clock_chains[2].gen_clock_chains_check.cmp_fmc_adc_clk/gen_adc_clk_7series_iodelay.gen_adc_clk_var_load_iodelay.cmp_ibufds_clk_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_clock_chains[3].gen_clock_chains_check.cmp_fmc_adc_clk/gen_adc_clk_7series_iodelay.gen_adc_clk_var_load_iodelay.cmp_ibufds_clk_iodelay}]
set_property IDELAY_VALUE 0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_clock_chains[3].gen_clock_chains_check.cmp_fmc_adc_clk/gen_adc_clk_7series_iodelay.gen_adc_clk_var_load_iodelay.cmp_ibufds_clk_iodelay}]

#######################################################################
##                          Clocks                                   ##
#######################################################################

#### 200 MHz onboard input clock
###NET "sys_clk_p_i" TNM_NET = "TNM_clk125mhz";
###TIMESPEC "TS_TNM_clk125mhz" = PERIOD "TNM_clk125mhz" 5 ns HIGH 50%;

# 125 MHz AMC TCLKB input clock
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:823
create_clock -period 8.000 -name sys_clk_p_i [get_ports sys_clk_p_i]

## 100 MHz wihsbone clock
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:827
# A PERIOD placed on an internal net will result in a clock defined with an internal source. Any upstream source clock latency will not be analyzed
create_clock -name clk_sys -period 10.000 [get_pins cmp_sys_pll_inst/cmp_clkout0_buf/O]

# 200 MHz DDR3 and IDELAY CONTROL clock
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:831
# A PERIOD placed on an internal net will result in a clock defined with an internal source. Any upstream source clock latency will not be analyzed
create_clock -name clk_200mhz -period 5.000 [get_pins cmp_sys_pll_inst/cmp_clkout1_buf/O]

# 200 MHz DDR3 UI Clock
#NET "*/u_infrastructure/clk_pll" TNM_NET = "TNM_ddr_sys_clk";
#TIMESPEC "TS_ddr_sys_clk" = PERIOD "TNM_ddr_sys_clk" 5 ns HIGH 50%;
#NET "clk_sys" TNM_NET = "TNM_clk_sys_group_ffs";
#TIMESPEC TS_clk_sys_to_ddr3_ui_clk = FROM "TNM_clk_sys_group_ffs" TO "TNM_ddr_sys_clk" 10 ns DATAPATHONLY;

# real jitter is about 22ps peak-to-peak
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:841
create_clock -period 8.000 -name fmc1_adc0_clk_i [get_ports fmc1_adc0_clk_i]
set_input_jitter fmc1_adc0_clk_i 0.050
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:843
create_clock -period 8.000 -name fmc2_adc0_clk_i [get_ports fmc2_adc0_clk_i]
set_input_jitter fmc2_adc0_clk_i 0.050

#INST "cmp1_xwb_fmc130m_4ch/*/*/gen_clock_chains[0].*.*/gen_with_ref_clk.cmp_mmcm_adc_clk" LOC=MMCME2_ADV_X1Y3;

# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:848
create_clock -period 8.000 -name fmc1_adc1_clk_i [get_ports fmc1_adc1_clk_i]
set_input_jitter fmc1_adc1_clk_i 0.050
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:850
create_clock -period 8.000 -name fmc2_adc1_clk_i [get_ports fmc2_adc1_clk_i]
set_input_jitter fmc2_adc1_clk_i 0.050

# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:853
create_clock -period 8.000 -name fmc1_adc2_clk_i [get_ports fmc1_adc2_clk_i]
set_input_jitter fmc1_adc2_clk_i 0.050
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:855
create_clock -period 8.000 -name fmc2_adc2_clk_i [get_ports fmc2_adc2_clk_i]
set_input_jitter fmc2_adc2_clk_i 0.050

# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:858
create_clock -period 8.000 -name fmc1_adc3_clk_i [get_ports fmc1_adc3_clk_i]
set_input_jitter fmc1_adc3_clk_i 0.050
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:860
create_clock -period 8.000 -name fmc2_adc3_clk_i [get_ports fmc2_adc3_clk_i]
set_input_jitter fmc2_adc3_clk_i 0.050


#######################################################################
##                         Cross Clock Constraints		     ##
#######################################################################

# Reset synchronization path
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:870
set_false_path -through [get_nets cmp_reset/master_rstn]
###NET "cmp_reset/Mshreg_shifters_0_0" TNM_NET = "TNM_reset_clk_0";
#### We relax the reset path here, as we have several FFs pipelined.
#### Here, we are using 2 (125MHz) free_clk clock cycles as the maximum
#### allowed, which is large enough so as to not impose any difficulties by
#### the synthesis tools and still small enough so as to not extrapolate
#### the number of FFs pipelined.
###TIMESPEC "TS_from_reset_free_clk_to_reset_clk_0" = FROM "TNM_reset_free_clk" TO "TNM_reset_clk_0" 16 ns DATAPATHONLY;
set_max_delay -datapath_only -from [get_cells -hier -filter {NAME =~ *ddr3_infrastructure/rstdiv0_sync_r1_reg*}] -to [get_cells -hier -filter {NAME =~ *temp_mon_enabled.u_tempmon/xadc_supplied_temperature.rst_r1*}] 20.000

#######################################################################
##                                Data                               ##
#######################################################################

#INST "fmc_adc_130m_4ch_i/ltcInterface_adc0_i/IDELAYCTRL_adc0_inst" LOC = IDELAYCTRL_X0Y1;
#INST "fmc_adc_130m_4ch_i/ltcInterface_adc1_i/IDELAYCTRL_adc0_inst" LOC = IDELAYCTRL_X0Y2;
#INST "fmc_adc_130m_4ch_i/ltcInterface_adc2_i/IDELAYCTRL_adc0_inst" LOC = IDELAYCTRL_X0Y0;
#INST "fmc_adc_130m_4ch_i/ltcInterface_adc3_i/IDELAYCTRL_adc0_inst" LOC = IDELAYCTRL_X0Y1; // same as ADC1
#INST "cmp1_xwb_fmc130m_4ch_cmp_wb_fmc130m_4ch_cmp_fmc_adc_iface_cmp_idelayctrl" LOC = IDELAYCTRL_X0Y1;
#INST "cmp2_xwb_fmc130m_4ch_cmp_wb_fmc130m_4ch_cmp_fmc_adc_iface_cmp_idelayctrl" LOC = IDELAYCTRL_X0Y2;

###INST "cmp1_xwb_fmc130m_4ch/*/cmp_fmc_adc_iface/gen_idelayctrl.cmp_idelayctrl" IODELAY_GROUP = fmc1_iodelay_grp;
###INST "cmp2_xwb_fmc130m_4ch/*/cmp_fmc_adc_iface/gen_idelayctrl.cmp_idelayctrl" IODELAY_GROUP = fmc2_iodelay_grp;
###
###INST "cmp1_xwb_fmc130m_4ch/*/cmp_fmc_adc_iface/gen_adc_data_chains[?].*.*/gen_adc_data[?].*.*.cmp_adc_data_iodelay" IODELAY_GROUP = fmc1_iodelay_grp;
###INST "cmp1_xwb_fmc130m_4ch/*/cmp_fmc_adc_iface/gen_clock_chains[?].*.*/*.*.cmp_ibufds_clk_iodelay" IODELAY_GROUP = fmc1_iodelay_grp;
###
###INST "cmp2_xwb_fmc130m_4ch/*/cmp_fmc_adc_iface/gen_adc_data_chains[?].*.*/gen_adc_data[?].*.*.cmp_adc_data_iodelay" IODELAY_GROUP = fmc2_iodelay_grp;
###INST "cmp2_xwb_fmc130m_4ch/*/cmp_fmc_adc_iface/gen_clock_chains[?].*.*/*.*.cmp_ibufds_clk_iodelay" IODELAY_GROUP = fmc2_iodelay_grp;

# The above constraints does not wor with PCIe and DDR cores...
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[0].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[1].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[2].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[3].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[4].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[5].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[6].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[7].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[8].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[9].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[10].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[11].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[12].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[13].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[14].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[15].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[0].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[1].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[2].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[3].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[4].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[5].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[6].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[7].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[8].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[9].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[10].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[11].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[12].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[13].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[14].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[15].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[0].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[1].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[2].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[3].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[4].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[5].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[6].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[7].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[8].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[9].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[10].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[11].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[12].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[13].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[14].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[15].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[0].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[1].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[2].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[3].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[4].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[5].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[6].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[7].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[8].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[9].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[10].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[11].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[12].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[13].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[14].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[15].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_clock_chains[0].gen_clock_chains_check.cmp_fmc_adc_clk/gen_adc_clk_7series_iodelay.gen_adc_clk_var_load_iodelay.cmp_ibufds_clk_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_clock_chains[1].gen_clock_chains_check.cmp_fmc_adc_clk/gen_adc_clk_7series_iodelay.gen_adc_clk_var_load_iodelay.cmp_ibufds_clk_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_clock_chains[2].gen_clock_chains_check.cmp_fmc_adc_clk/gen_adc_clk_7series_iodelay.gen_adc_clk_var_load_iodelay.cmp_ibufds_clk_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp1_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_clock_chains[3].gen_clock_chains_check.cmp_fmc_adc_clk/gen_adc_clk_7series_iodelay.gen_adc_clk_var_load_iodelay.cmp_ibufds_clk_iodelay}]

set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[0].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[1].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[2].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[3].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[4].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[5].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[6].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[7].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[8].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[9].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[10].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[11].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[12].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[13].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[14].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[0].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[15].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[0].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[1].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[2].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[3].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[4].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[5].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[6].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[7].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[8].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[9].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[10].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[11].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[12].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[13].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[14].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[1].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[15].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[0].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[1].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[2].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[3].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[4].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[5].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[6].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[7].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[8].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[9].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[10].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[11].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[12].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[13].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[14].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[2].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[15].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[0].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[1].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[2].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[3].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[4].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[5].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[6].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[7].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[8].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[9].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[10].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[11].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[12].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[13].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[14].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_adc_data_chains[3].gen_adc_data_chains_check.cmp_fmc_adc_data/gen_adc_data[15].gen_adc_data_7series_iodelay.gen_adc_data_var_loadable_iodelay.cmp_adc_data_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_clock_chains[0].gen_clock_chains_check.cmp_fmc_adc_clk/gen_adc_clk_7series_iodelay.gen_adc_clk_var_load_iodelay.cmp_ibufds_clk_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_clock_chains[1].gen_clock_chains_check.cmp_fmc_adc_clk/gen_adc_clk_7series_iodelay.gen_adc_clk_var_load_iodelay.cmp_ibufds_clk_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_clock_chains[2].gen_clock_chains_check.cmp_fmc_adc_clk/gen_adc_clk_7series_iodelay.gen_adc_clk_var_load_iodelay.cmp_ibufds_clk_iodelay}]
set_property IODELAY_GROUP DDR_CORE_IODELAY_MIG0 [get_cells {cmp2_xwb_fmc130m_4ch/cmp_wb_fmc130m_4ch/cmp_fmc_adc_iface/gen_clock_chains[3].gen_clock_chains_check.cmp_fmc_adc_clk/gen_adc_clk_7series_iodelay.gen_adc_clk_var_load_iodelay.cmp_ibufds_clk_iodelay}]

#// including 50ps jitter, for 130MHz clock
#// since design uses copy of input ADC clock
#// there is additional delay for clock/ data (tC)


# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:915
set_input_delay -clock [get_clocks fmc1_adc0_clk_i] -max -add_delay 8.000 [get_ports {fmc1_adc0_data_i[10] fmc1_adc0_data_i[11] fmc1_adc0_data_i[12] fmc1_adc0_data_i[13] fmc1_adc0_data_i[14] fmc1_adc0_data_i[15] fmc1_adc0_data_i[0] fmc1_adc0_data_i[1] fmc1_adc0_data_i[2] fmc1_adc0_data_i[3] fmc1_adc0_data_i[4] fmc1_adc0_data_i[5] fmc1_adc0_data_i[6] fmc1_adc0_data_i[7] fmc1_adc0_data_i[8] fmc1_adc0_data_i[9]}]
set_input_delay -clock [get_clocks fmc1_adc0_clk_i] -min -add_delay 7.000 [get_ports {fmc1_adc0_data_i[10] fmc1_adc0_data_i[11] fmc1_adc0_data_i[12] fmc1_adc0_data_i[13] fmc1_adc0_data_i[14] fmc1_adc0_data_i[15] fmc1_adc0_data_i[0] fmc1_adc0_data_i[1] fmc1_adc0_data_i[2] fmc1_adc0_data_i[3] fmc1_adc0_data_i[4] fmc1_adc0_data_i[5] fmc1_adc0_data_i[6] fmc1_adc0_data_i[7] fmc1_adc0_data_i[8] fmc1_adc0_data_i[9]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:916
set_input_delay -clock [get_clocks fmc1_adc1_clk_i] -max -add_delay 8.000 [get_ports {fmc1_adc1_data_i[10] fmc1_adc1_data_i[11] fmc1_adc1_data_i[12] fmc1_adc1_data_i[13] fmc1_adc1_data_i[14] fmc1_adc1_data_i[15] fmc1_adc1_data_i[0] fmc1_adc1_data_i[1] fmc1_adc1_data_i[2] fmc1_adc1_data_i[3] fmc1_adc1_data_i[4] fmc1_adc1_data_i[5] fmc1_adc1_data_i[6] fmc1_adc1_data_i[7] fmc1_adc1_data_i[8] fmc1_adc1_data_i[9]}]
set_input_delay -clock [get_clocks fmc1_adc1_clk_i] -min -add_delay 7.000 [get_ports {fmc1_adc1_data_i[10] fmc1_adc1_data_i[11] fmc1_adc1_data_i[12] fmc1_adc1_data_i[13] fmc1_adc1_data_i[14] fmc1_adc1_data_i[15] fmc1_adc1_data_i[0] fmc1_adc1_data_i[1] fmc1_adc1_data_i[2] fmc1_adc1_data_i[3] fmc1_adc1_data_i[4] fmc1_adc1_data_i[5] fmc1_adc1_data_i[6] fmc1_adc1_data_i[7] fmc1_adc1_data_i[8] fmc1_adc1_data_i[9]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:917
set_input_delay -clock [get_clocks fmc1_adc2_clk_i] -max -add_delay 8.000 [get_ports {fmc1_adc2_data_i[10] fmc1_adc2_data_i[11] fmc1_adc2_data_i[12] fmc1_adc2_data_i[13] fmc1_adc2_data_i[14] fmc1_adc2_data_i[15] fmc1_adc2_data_i[0] fmc1_adc2_data_i[1] fmc1_adc2_data_i[2] fmc1_adc2_data_i[3] fmc1_adc2_data_i[4] fmc1_adc2_data_i[5] fmc1_adc2_data_i[6] fmc1_adc2_data_i[7] fmc1_adc2_data_i[8] fmc1_adc2_data_i[9]}]
set_input_delay -clock [get_clocks fmc1_adc2_clk_i] -min -add_delay 7.000 [get_ports {fmc1_adc2_data_i[10] fmc1_adc2_data_i[11] fmc1_adc2_data_i[12] fmc1_adc2_data_i[13] fmc1_adc2_data_i[14] fmc1_adc2_data_i[15] fmc1_adc2_data_i[0] fmc1_adc2_data_i[1] fmc1_adc2_data_i[2] fmc1_adc2_data_i[3] fmc1_adc2_data_i[4] fmc1_adc2_data_i[5] fmc1_adc2_data_i[6] fmc1_adc2_data_i[7] fmc1_adc2_data_i[8] fmc1_adc2_data_i[9]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:918
set_input_delay -clock [get_clocks fmc1_adc3_clk_i] -max -add_delay 8.000 [get_ports {fmc1_adc3_data_i[0] fmc1_adc3_data_i[1] fmc1_adc3_data_i[2] fmc1_adc3_data_i[3] fmc1_adc3_data_i[4] fmc1_adc3_data_i[5] fmc1_adc3_data_i[6] fmc1_adc3_data_i[7] fmc1_adc3_data_i[8] fmc1_adc3_data_i[9] fmc1_adc3_data_i[10] fmc1_adc3_data_i[11] fmc1_adc3_data_i[12] fmc1_adc3_data_i[13] fmc1_adc3_data_i[14] fmc1_adc3_data_i[15]}]
set_input_delay -clock [get_clocks fmc1_adc3_clk_i] -min -add_delay 7.000 [get_ports {fmc1_adc3_data_i[0] fmc1_adc3_data_i[1] fmc1_adc3_data_i[2] fmc1_adc3_data_i[3] fmc1_adc3_data_i[4] fmc1_adc3_data_i[5] fmc1_adc3_data_i[6] fmc1_adc3_data_i[7] fmc1_adc3_data_i[8] fmc1_adc3_data_i[9] fmc1_adc3_data_i[10] fmc1_adc3_data_i[11] fmc1_adc3_data_i[12] fmc1_adc3_data_i[13] fmc1_adc3_data_i[14] fmc1_adc3_data_i[15]}]


# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:925
set_input_delay -clock [get_clocks fmc2_adc0_clk_i] -max -add_delay 8.000 [get_ports {fmc2_adc0_data_i[10] fmc2_adc0_data_i[11] fmc2_adc0_data_i[12] fmc2_adc0_data_i[13] fmc2_adc0_data_i[14] fmc2_adc0_data_i[15] fmc2_adc0_data_i[0] fmc2_adc0_data_i[1] fmc2_adc0_data_i[2] fmc2_adc0_data_i[3] fmc2_adc0_data_i[4] fmc2_adc0_data_i[5] fmc2_adc0_data_i[6] fmc2_adc0_data_i[7] fmc2_adc0_data_i[8] fmc2_adc0_data_i[9]}]
set_input_delay -clock [get_clocks fmc2_adc0_clk_i] -min -add_delay 7.000 [get_ports {fmc2_adc0_data_i[10] fmc2_adc0_data_i[11] fmc2_adc0_data_i[12] fmc2_adc0_data_i[13] fmc2_adc0_data_i[14] fmc2_adc0_data_i[15] fmc2_adc0_data_i[0] fmc2_adc0_data_i[1] fmc2_adc0_data_i[2] fmc2_adc0_data_i[3] fmc2_adc0_data_i[4] fmc2_adc0_data_i[5] fmc2_adc0_data_i[6] fmc2_adc0_data_i[7] fmc2_adc0_data_i[8] fmc2_adc0_data_i[9]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:926
set_input_delay -clock [get_clocks fmc2_adc1_clk_i] -max -add_delay 8.000 [get_ports {fmc2_adc1_data_i[10] fmc2_adc1_data_i[11] fmc2_adc1_data_i[12] fmc2_adc1_data_i[13] fmc2_adc1_data_i[14] fmc2_adc1_data_i[15] fmc2_adc1_data_i[0] fmc2_adc1_data_i[1] fmc2_adc1_data_i[2] fmc2_adc1_data_i[3] fmc2_adc1_data_i[4] fmc2_adc1_data_i[5] fmc2_adc1_data_i[6] fmc2_adc1_data_i[7] fmc2_adc1_data_i[8] fmc2_adc1_data_i[9]}]
set_input_delay -clock [get_clocks fmc2_adc1_clk_i] -min -add_delay 7.000 [get_ports {fmc2_adc1_data_i[10] fmc2_adc1_data_i[11] fmc2_adc1_data_i[12] fmc2_adc1_data_i[13] fmc2_adc1_data_i[14] fmc2_adc1_data_i[15] fmc2_adc1_data_i[0] fmc2_adc1_data_i[1] fmc2_adc1_data_i[2] fmc2_adc1_data_i[3] fmc2_adc1_data_i[4] fmc2_adc1_data_i[5] fmc2_adc1_data_i[6] fmc2_adc1_data_i[7] fmc2_adc1_data_i[8] fmc2_adc1_data_i[9]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:927
set_input_delay -clock [get_clocks fmc2_adc2_clk_i] -max -add_delay 8.000 [get_ports {fmc2_adc2_data_i[10] fmc2_adc2_data_i[11] fmc2_adc2_data_i[12] fmc2_adc2_data_i[13] fmc2_adc2_data_i[14] fmc2_adc2_data_i[15] fmc2_adc2_data_i[0] fmc2_adc2_data_i[1] fmc2_adc2_data_i[2] fmc2_adc2_data_i[3] fmc2_adc2_data_i[4] fmc2_adc2_data_i[5] fmc2_adc2_data_i[6] fmc2_adc2_data_i[7] fmc2_adc2_data_i[8] fmc2_adc2_data_i[9]}]
set_input_delay -clock [get_clocks fmc2_adc2_clk_i] -min -add_delay 7.000 [get_ports {fmc2_adc2_data_i[10] fmc2_adc2_data_i[11] fmc2_adc2_data_i[12] fmc2_adc2_data_i[13] fmc2_adc2_data_i[14] fmc2_adc2_data_i[15] fmc2_adc2_data_i[0] fmc2_adc2_data_i[1] fmc2_adc2_data_i[2] fmc2_adc2_data_i[3] fmc2_adc2_data_i[4] fmc2_adc2_data_i[5] fmc2_adc2_data_i[6] fmc2_adc2_data_i[7] fmc2_adc2_data_i[8] fmc2_adc2_data_i[9]}]
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:928
set_input_delay -clock [get_clocks fmc2_adc3_clk_i] -max -add_delay 8.000 [get_ports {fmc2_adc3_data_i[0] fmc2_adc3_data_i[1] fmc2_adc3_data_i[2] fmc2_adc3_data_i[3] fmc2_adc3_data_i[4] fmc2_adc3_data_i[5] fmc2_adc3_data_i[6] fmc2_adc3_data_i[7] fmc2_adc3_data_i[8] fmc2_adc3_data_i[9] fmc2_adc3_data_i[10] fmc2_adc3_data_i[11] fmc2_adc3_data_i[12] fmc2_adc3_data_i[13] fmc2_adc3_data_i[14] fmc2_adc3_data_i[15]}]
set_input_delay -clock [get_clocks fmc2_adc3_clk_i] -min -add_delay 7.000 [get_ports {fmc2_adc3_data_i[0] fmc2_adc3_data_i[1] fmc2_adc3_data_i[2] fmc2_adc3_data_i[3] fmc2_adc3_data_i[4] fmc2_adc3_data_i[5] fmc2_adc3_data_i[6] fmc2_adc3_data_i[7] fmc2_adc3_data_i[8] fmc2_adc3_data_i[9] fmc2_adc3_data_i[10] fmc2_adc3_data_i[11] fmc2_adc3_data_i[12] fmc2_adc3_data_i[13] fmc2_adc3_data_i[14] fmc2_adc3_data_i[15]}]

#######################################################################
##                          PCIe constraints                        ##
#######################################################################
#

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
#set_false_path -from [get_clocks clk_sys] -to [get_clocks adc_clk2x_mmcm_out]
set_max_delay -datapath_only -from [get_clocks clk_sys] -to [get_clocks adc_clk2x_mmcm_out] 8.000

#set_false_path -from [get_clocks adc_clk_mmcm_out] -to [get_clocks clk_sys]
set_max_delay -datapath_only -from [get_clocks adc_clk_mmcm_out] -to [get_clocks clk_sys] 20.000
#set_false_path -from [get_clocks adc_clk2x_mmcm_out] -to [get_clocks clk_sys]
set_max_delay -datapath_only -from [get_clocks adc_clk2x_mmcm_out] -to [get_clocks clk_sys] 10.000

# This path happens only in the control path for setting control parameters
set_max_delay -datapath_only -from [get_clocks adc_clk_mmcm_out] -to [get_clocks adc_clk2x_mmcm_out] 8.000

# FIFO CDC timimng. Using faster clock period / 2
set_max_delay -datapath_only -from [get_clocks -of_objects [get_pins */*/*/u_ddr_core/ui_clk]] -to [get_clocks adc_clk_mmcm_out] 4.000
set_max_delay -datapath_only -from [get_clocks adc_clk_mmcm_out] -to [get_clocks -of_objects [get_pins */*/*/u_ddr_core/ui_clk]] 4.000

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
add_cells_to_pblock [get_pblocks GRP_position_calc_core1] [get_cells -quiet [list cmp1_xwb_position_calc_core_ns]]
resize_pblock [get_pblocks GRP_position_calc_core1] -add {CLOCKREGION_X1Y2:CLOCKREGION_X1Y4}
create_pblock GRP_position_calc_core2
add_cells_to_pblock [get_pblocks GRP_position_calc_core2] [get_cells -quiet [list cmp2_xwb_position_calc_core_ns]]
resize_pblock [get_pblocks GRP_position_calc_core2] -add {CLOCKREGION_X0Y0:CLOCKREGION_X0Y2}

#######################################################################
##                         CE Constraints                            ##
#######################################################################
#
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:38250
set_max_delay 8.000 -from [all_fanout -endpoints_only -only_cells -flat -from [get_nets * -hierarchical -filter {NAME =~ *position_calc_nosysgen/ce_adc*}]] -to [all_fanout -endpoints_only -flat -from [get_nets * -hierarchical -filter {NAME =~ *position_calc_nosysgen/ce_adc*}]]

# ADC/7
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:38254
set_max_delay 58.000 -from [all_fanout -endpoints_only -only_cells -flat -from [get_nets * -hierarchical -filter {NAME =~ *position_calc_nosysgen/ce_tbt1*}]] -to [all_fanout -endpoints_only -flat -from [get_nets * -hierarchical -filter {NAME =~ *position_calc_nosysgen/ce_tbt1*}]]

# TBT1/29
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:38258
set_max_delay 1000.000 -from [all_fanout -endpoints_only -only_cells -flat -from [get_nets * -hierarchical -filter {NAME =~ *position_calc_nosysgen/ce_tbt2*}]] -to [all_fanout -endpoints_only -flat -from [get_nets * -hierarchical -filter {NAME =~ *position_calc_nosysgen/ce_tbt2*}]]

# TBT2/5
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:38262
set_max_delay 8000.000 -from [all_fanout -endpoints_only -only_cells -flat -from [get_nets * -hierarchical -filter {NAME =~ *position_calc_nosysgen/ce_fofb*}]] -to [all_fanout -endpoints_only -flat -from [get_nets * -hierarchical -filter {NAME =~ *position_calc_nosysgen/ce_fofb*}]]

# FOFB/2049
# /home/lerwys/Repos/bpm-sw/hdl/syn/afc_v3/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_attempt_fix_2/project_2/project_2.runs/impl_1/.constrs/dbe_bpm_dsp.ucf:38266
set_max_delay 17000000.000 -from [all_fanout -endpoints_only -only_cells -flat -from [get_nets * -hierarchical -filter {NAME =~ *position_calc_nosysgen/ce_monit*}]] -to [all_fanout -endpoints_only -flat -from [get_nets * -hierarchical -filter {NAME =~ *position_calc_nosysgen/ce_monit*}]]

