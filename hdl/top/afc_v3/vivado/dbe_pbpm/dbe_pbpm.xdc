#######################################################################
##                      Artix 7 AMC V3                               ##
#######################################################################

# All timing constraint translations are rough conversions, intended to act as a template for further manual refinement. The translations should not be expected to produce semantically identical results to the original ucf. Each xdc timing constraint must be manually inspected and verified to ensure it captures the desired intent

# In xdc, all clocks are related by default. This differs from ucf, where clocks are unrelated unless specified otherwise. As a result, you may now see cross-clock paths that were previously unconstrained in ucf. Commented out xdc false path constraints have been generated and can be uncommented, should you wish to remove these new paths. These commands are located after the last clock definition

# FPGA_CLK1_P
set_property IOSTANDARD DIFF_SSTL15 [get_ports sys_clk_p_i]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports sys_clk_p_i]
# FPGA_CLK1_N
set_property PACKAGE_PIN AL7 [get_ports sys_clk_n_i]
set_property IOSTANDARD DIFF_SSTL15 [get_ports sys_clk_n_i]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports sys_clk_n_i]

# TXD		IO_25_34
set_property PACKAGE_PIN AB11 [get_ports rs232_txd_o]
set_property IOSTANDARD LVCMOS25 [get_ports rs232_txd_o]
# VADJ1_RXD	IO_0_34
set_property PACKAGE_PIN Y11 [get_ports rs232_rxd_i]
set_property IOSTANDARD LVCMOS25 [get_ports rs232_rxd_i]

# System Reset
# Bank 16 VCCO - VADJ_FPGA - IO_25_16. NET = FPGA_RESET_DN, PIN = IO_L19P_T3_13
set_false_path -through [get_nets sys_rst_button_n_i]
set_property PACKAGE_PIN AG26 [get_ports sys_rst_button_n_i]
set_property IOSTANDARD LVCMOS25 [get_ports sys_rst_button_n_i]
set_property PULLUP true [get_ports sys_rst_button_n_i]

# AFC LEDs
# LED Red - IO_L6P_T0_36
set_property PACKAGE_PIN K10 [get_ports {leds_o[2]}]
set_property IOSTANDARD LVCMOS25 [get_ports {leds_o[2]}]
# Led Green - IO_25_36
set_property PACKAGE_PIN L7 [get_ports {leds_o[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {leds_o[1]}]
# Led Blue - IO_0_36
set_property PACKAGE_PIN H12 [get_ports {leds_o[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {leds_o[0]}]

#######################################################################
##                           Trigger	                             ##
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
##                       FMC Connector HPC1                           #
#######################################################################

#CNV H10 LA04_P C2M
#SCK H11 LA04_N C2M
#SCK_RTRN G12 LA08_P M2C
#SDO1 H17 LA11_N M2C
#SDO2 H16 LA11_P M2C
#SDO3 H14 LA07_N M2C
#SDO4 H13 LA07_P M2C
#BUSY_CMN G13 LA08_N M2C

################################## ADC #################################

# CONV
set_property PACKAGE_PIN K1 [get_ports fmc1_adc_cnv_o]                  ;# LA1_LA04_P
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_adc_cnv_o]
# SCK
set_property PACKAGE_PIN J1 [get_ports fmc1_adc_sck_o]                  ;# LA1_LA04_N
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_adc_sck_o]
# SCK_RTRN
set_property PACKAGE_PIN F3 [get_ports fmc1_adc_sck_rtrn_i]             ;# LA1_LA08_P
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_adc_sck_rtrn_i]
# SDO1
set_property PACKAGE_PIN L2 [get_ports fmc1_adc_sdo1_i]                 ;# LA1_LA11_N
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_adc_sdo1_i]
# SDO2
set_property PACKAGE_PIN M2 [get_ports fmc1_adc_sdo2_i]                 ;# LA1_LA11_P
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_adc_sdo2_i]
# SDO3
set_property PACKAGE_PIN K2 [get_ports fmc1_adc_sdo3_i]                 ;# LA1_LA07_N
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_adc_sdo3_i]
# SDO4
set_property PACKAGE_PIN K3 [get_ports fmc1_adc_sdo4_i]                 ;# LA1_LA07_P
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_adc_sdo4_i]
# BUSY_CMN
set_property PACKAGE_PIN F2 [get_ports fmc1_adc_busy_cmn_i]             ;# LA1_LA08_N
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_adc_busy_cmn_i]

############################# Range Selection #########################

# R1
set_property PACKAGE_PIN G1 [get_ports fmc1_rng_r1_o]                   ;# LA1_LA03_N
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_rng_r1_o]
# R2
set_property PACKAGE_PIN H1 [get_ports fmc1_rng_r2_o]                   ;# LA1_LA03_P
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_rng_r2_o]
# R3
set_property PACKAGE_PIN G6 [get_ports fmc1_rng_r3_o]                   ;# LA1_LA02_N
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_rng_r3_o]
# R4
set_property PACKAGE_PIN G7 [get_ports fmc1_rng_r4_o]                   ;# LA1_LA02_P
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_rng_r4_o]

################################# Leds #############################

# Led1
set_property PACKAGE_PIN H4 [get_ports fmc1_led1_o]                     ;# LA1_LA05_P
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_led1_o]
# Led2
set_property PACKAGE_PIN H3 [get_ports fmc1_led2_o]                     ;# LA1_LA05_N
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_led2_o]

######################## System Managment EEPROM ####################

# SCL
set_property PACKAGE_PIN P6 [get_ports fmc1_sm_scl_o]                   ;# FPGA_I2C_SCL (through I2C MUX)
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_sm_scl_o]
# SDA
set_property PACKAGE_PIN R11 [get_ports fmc1_sm_sda_b]                  ;# FPGA_I2C_SDA (through I2C MUX)
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_sm_sda_b]
#
# GA0 and GA1 are directly connected to resistors
## GA0
#set_property PACKAGE_PIN ?? [get_ports fmc1_sm_ga0_o]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc1_sm_ga0_o]
## GA1
#set_property PACKAGE_PIN ?? [get_ports fmc1_sm_ga1_o]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc1_sm_ga1_o]

########################## Application EEPROM ######################

# SCL
set_property PACKAGE_PIN N3 [get_ports fmc1_a_scl_o]                    ;# LA1_LA23_P
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_a_scl_o]
# SDA
set_property PACKAGE_PIN N2 [get_ports fmc1_a_sda_b]                    ;# LA1_LA23_N
set_property IOSTANDARD LVCMOS25 [get_ports fmc1_a_sda_b]

#######################################################################
##                       FMC Connector HPC2                           #
#######################################################################

# CONV
set_property PACKAGE_PIN AC26 [get_ports fmc2_adc_cnv_o]                ;# LA2_LA04_P
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_adc_cnv_o]
# SCK
set_property PACKAGE_PIN AC27 [get_ports fmc2_adc_sck_o]                ;# LA2_LA04_N
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_adc_sck_o]
# SCK_RTRN
set_property PACKAGE_PIN AD25 [get_ports fmc2_adc_sck_rtrn_i]           ;# LA2_LA08_P
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_adc_sck_rtrn_i]
# SDO1
set_property PACKAGE_PIN AE30 [get_ports fmc2_adc_sdo1_i]               ;# LA2_LA11_N
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_adc_sdo1_i]
# SDO2
set_property PACKAGE_PIN AD30 [get_ports fmc2_adc_sdo2_i]               ;# LA2_LA11_P
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_adc_sdo2_i]
# SDO3
set_property PACKAGE_PIN AH27 [get_ports fmc2_adc_sdo3_i]               ;# LA2_LA07_N
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_adc_sdo3_i]
# SDO4
set_property PACKAGE_PIN AG27 [get_ports fmc2_adc_sdo4_i]               ;# LA2_LA07_P
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_adc_sdo4_i]
# BUSY_CMN
set_property PACKAGE_PIN AE25 [get_ports fmc2_adc_busy_cmn_i]           ;# LA2_LA08_N
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_adc_busy_cmn_i]

############################# Range Selection #########################

# R1
set_property PACKAGE_PIN AH24 [get_ports fmc2_rng_r1_o]                 ;# LA2_LA03_N
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_rng_r1_o]
# R2
set_property PACKAGE_PIN AG24 [get_ports fmc2_rng_r2_o]                 ;# LA2_LA03_P
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_rng_r2_o]
# R3
set_property PACKAGE_PIN AH31 [get_ports fmc2_rng_r3_o]                 ;# LA2_LA02_N
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_rng_r3_o]
# R4
set_property PACKAGE_PIN AG31 [get_ports fmc2_rng_r4_o]                 ;# LA2_LA02_P
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_rng_r4_o]

################################# Leds #############################

# Led1
set_property PACKAGE_PIN AH33 [get_ports fmc2_led1_o]                   ;# LA2_LA05_P
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_led1_o]
# Led2
set_property PACKAGE_PIN AH34 [get_ports fmc2_led2_o]                   ;# LA2_LA05_N
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_led2_o]

######################## System Managment EEPROM ####################

# These pins are shared with the fmc2 pins,as they go to a I2C MUX
# SCL
#set_property PACKAGE_PIN P6 [get_ports fmc2_sm_scl_o]                   ;# FPGA_I2C_SCL (through I2C MUX)
#set_property IOSTANDARD LVCMOS25 [get_ports fmc2_sm_scl_o]
## SDA
#set_property PACKAGE_PIN R11 [get_ports fmc2_sm_sda_b]                  ;# FPGA_I2C_SDA (through I2C MUX)
#set_property IOSTANDARD LVCMOS25 [get_ports fmc2_sm_sda_b]

## GA0 and GA1 are directly connected to resistors
## GA0
#set_property PACKAGE_PIN ?? [get_ports fmc2_sm_ga0_o]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc2_sm_ga0_o]
## GA1
#set_property PACKAGE_PIN ?? [get_ports fmc2_sm_ga1_o]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc2_sm_ga1_o]

########################## Application EEPROM ######################

# SCL
set_property PACKAGE_PIN W25 [get_ports fmc2_a_scl_o]                   ;# LA2_LA23_P
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_a_scl_o]
# SDA
set_property PACKAGE_PIN Y25 [get_ports fmc2_a_sda_b]                   ;# LA2_LA23_N
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_a_sda_b]

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

#######################################################################
##                    Timing constraints                             ##
#######################################################################

# Overrides default_delay hdl parameter for the VARIABLE mode.
# For Artix7: Average Tap Delay at 200 MHz = 78 ps, at 300 MHz = 52 ps ???

#######################################################################
##                          Clocks                                   ##
#######################################################################

# 125 MHz AMC TCLKB input clock
create_clock -period 8.000 -name sys_clk_p_i [get_ports sys_clk_p_i]

## 100 MHz wihsbone clock
# A PERIOD placed on an internal net will result in a clock defined with an internal source. Any upstream source clock latency will not be analyzed
create_clock -name clk_sys -period 10.000 [get_pins -hier -filter {NAME =~ */cmp_sys_pll_inst/cmp_clkout0_buf/O}]

# 200 MHz DDR3 and IDELAY CONTROL clock
# A PERIOD placed on an internal net will result in a clock defined with an internal source. Any upstream source clock latency will not be analyzed
create_clock -name clk_200mhz -period 5.000 [get_pins -hier -filter {NAME =~ */cmp_sys_pll_inst/cmp_clkout1_buf/O}]

# A PERIOD placed on an internal net will result in a clock defined with an internal source. Any upstream source clock latency will not be analyzed
create_clock -name clk_300mhz -period 3.333 [get_pins -hier -filter {NAME =~ */cmp_sys_pll_inst/cmp_clkout2_buf/O}]

set_clock_groups -asynchronous \
  -group [get_clocks -include_generated_clocks pcie_clk] \
  -group [get_clocks -include_generated_clocks clk_200mhz] \
  -group [get_clocks -include_generated_clocks clk_300mhz]

#######################################################################
##                         Cross Clock Constraints                   ##
#######################################################################

# Reset synchronization path
set_false_path -through [get_nets -hier -filter {NAME =~ *cmp_reset/master_rstn}]
# DDR 3 temperature monitor reset path
# chain of FFs synched with clk_sys. We use asynchronous assertion and
# synchronous deassertion
set_false_path -through [get_nets -hier -filter {NAME =~ *theTlpControl/Memory_Space/wb_FIFO_Rst}]
# DDR 3 temperature monitor reset path
set_max_delay -datapath_only -from [get_cells -hier -filter {NAME =~ *ddr3_infrastructure/rstdiv0_sync_r1_reg*}] -to [get_cells -hier -filter {NAME =~ *temp_mon_enabled.u_tempmon/xadc_supplied_temperature.rst_r1*}] 20.000

#######################################################################
##                                Data                               ##
#######################################################################

#######################################################################
##                          PCIe constraints                        ##
#######################################################################

#PCIe clock
# MGT216_CLK1_N -> MGTREFCLK0N_216
set_property PACKAGE_PIN G18 [get_ports pcie_clk_n_i]
# MGT216_CLK1_P -> MGTREFCLK0P_216
set_property PACKAGE_PIN H18 [get_ports pcie_clk_p_i]
#PCIe lane 0
# TX216_0_P            -> MGTPTXP0_216
set_property PACKAGE_PIN B23 [get_ports {pci_exp_txp_o[0]}]
# TX216_0_N            -> MGTPTXN0_216
set_property PACKAGE_PIN A23 [get_ports {pci_exp_txn_o[0]}]
# RX216_0_P            -> MGTPRXP0_216
set_property PACKAGE_PIN F21 [get_ports {pci_exp_rxp_i[0]}]
# RX216_0_N            -> MGTPRXN0_216
set_property PACKAGE_PIN E21 [get_ports {pci_exp_rxn_i[0]}]
#PCIe lane 1
# TX216_1_P            -> MGTPTXP1_216
set_property PACKAGE_PIN D22 [get_ports {pci_exp_txp_o[1]}]
# TX216_1_N            -> MGTPTXN1_216
set_property PACKAGE_PIN C22 [get_ports {pci_exp_txn_o[1]}]
# RX216_1_P            -> MGTPRXP1_216
set_property PACKAGE_PIN D20 [get_ports {pci_exp_rxp_i[1]}]
# RX216_1_N            -> MGTPRXN1_216
set_property PACKAGE_PIN C20 [get_ports {pci_exp_rxn_i[1]}]
#PCIe lane 2
# TX216_2_P            -> MGTPTXP2_216
set_property PACKAGE_PIN B21 [get_ports {pci_exp_txp_o[2]}]
# TX216_2_N            -> MGTPTXN2_216
set_property PACKAGE_PIN A21 [get_ports {pci_exp_txn_o[2]}]
# RX216_2_P            -> MGTPRXP2_216
set_property PACKAGE_PIN F19 [get_ports {pci_exp_rxp_i[2]}]
# RX216_2_N            -> MGTPRXN2_216
set_property PACKAGE_PIN E19 [get_ports {pci_exp_rxn_i[2]}]
#PCIe lane 3
# TX216_3_P            -> MGTPTXP3_216
set_property PACKAGE_PIN B19 [get_ports {pci_exp_txp_o[3]}]
# TX216_3_N            -> MGTPTXN3_216
set_property PACKAGE_PIN A19 [get_ports {pci_exp_txn_o[3]}]
# RX216_3_P            -> MGTPRXP3_216
set_property PACKAGE_PIN D18 [get_ports {pci_exp_rxp_i[3]}]
# RX216_3_N            -> MGTPRXN3_216
set_property PACKAGE_PIN C18 [get_ports {pci_exp_rxn_i[3]}]

#######################################################################
# Pinout and Related I/O Constraints
#######################################################################

#######################################################################
# Timing Constraints
#######################################################################
# The following cross clock domain false path constraints can be uncommented in order to mimic ucf constraints behavior (see message at the beginning of this file)
set_false_path -from [get_clocks sys_clk_p_i] -to [get_clocks [list clk_sys clk_200mhz pcie_clk clk_125mhz clk_userclk clk_userclk2 cmp_xwb_bpm_pcie/cmp_wb_bpm_pcie/cmp_bpm_pcie/DDRs_ctrl_module/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/iserdes_clk_1 cmp_xwb_bpm_pcie/cmp_wb_bpm_pcie/cmp_bpm_pcie/DDRs_ctrl_module/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/iserdes_clk_1 cmp_xwb_bpm_pcie/cmp_wb_bpm_pcie/cmp_bpm_pcie/DDRs_ctrl_module/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/iserdes_clk_1 cmp_xwb_bpm_pcie/cmp_wb_bpm_pcie/cmp_bpm_pcie/DDRs_ctrl_module/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/iserdes_clk_1]]
set_false_path -from [get_clocks clk_sys] -to [get_clocks [list sys_clk_p_i clk_200mhz pcie_clk clk_125mhz clk_userclk clk_userclk2 cmp_xwb_bpm_pcie/cmp_wb_bpm_pcie/cmp_bpm_pcie/DDRs_ctrl_module/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/iserdes_clk_1 cmp_xwb_bpm_pcie/cmp_wb_bpm_pcie/cmp_bpm_pcie/DDRs_ctrl_module/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/iserdes_clk_1 cmp_xwb_bpm_pcie/cmp_wb_bpm_pcie/cmp_bpm_pcie/DDRs_ctrl_module/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/iserdes_clk_1 cmp_xwb_bpm_pcie/cmp_wb_bpm_pcie/cmp_bpm_pcie/DDRs_ctrl_module/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/iserdes_clk_1]]
set_false_path -from [get_clocks clk_200mhz] -to [get_clocks [list sys_clk_p_i clk_sys pcie_clk clk_125mhz clk_userclk clk_userclk2 cmp_xwb_bpm_pcie/cmp_wb_bpm_pcie/cmp_bpm_pcie/DDRs_ctrl_module/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/iserdes_clk_1 cmp_xwb_bpm_pcie/cmp_wb_bpm_pcie/cmp_bpm_pcie/DDRs_ctrl_module/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/iserdes_clk_1 cmp_xwb_bpm_pcie/cmp_wb_bpm_pcie/cmp_bpm_pcie/DDRs_ctrl_module/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/iserdes_clk_1 cmp_xwb_bpm_pcie/cmp_wb_bpm_pcie/cmp_bpm_pcie/DDRs_ctrl_module/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/iserdes_clk_1]]
set_false_path -from [get_clocks pcie_clk] -to [get_clocks [list sys_clk_p_i clk_sys clk_200mhz cmp_xwb_bpm_pcie/cmp_wb_bpm_pcie/cmp_bpm_pcie/DDRs_ctrl_module/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/iserdes_clk_1 cmp_xwb_bpm_pcie/cmp_wb_bpm_pcie/cmp_bpm_pcie/DDRs_ctrl_module/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/iserdes_clk_1 cmp_xwb_bpm_pcie/cmp_wb_bpm_pcie/cmp_bpm_pcie/DDRs_ctrl_module/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/iserdes_clk_1 cmp_xwb_bpm_pcie/cmp_wb_bpm_pcie/cmp_bpm_pcie/DDRs_ctrl_module/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/iserdes_clk_1]]
set_false_path -from [get_clocks clk_125mhz] -to [get_clocks [list sys_clk_p_i clk_sys clk_200mhz cmp_xwb_bpm_pcie/cmp_wb_bpm_pcie/cmp_bpm_pcie/DDRs_ctrl_module/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/iserdes_clk_1 cmp_xwb_bpm_pcie/cmp_wb_bpm_pcie/cmp_bpm_pcie/DDRs_ctrl_module/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/iserdes_clk_1 cmp_xwb_bpm_pcie/cmp_wb_bpm_pcie/cmp_bpm_pcie/DDRs_ctrl_module/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/iserdes_clk_1 cmp_xwb_bpm_pcie/cmp_wb_bpm_pcie/cmp_bpm_pcie/DDRs_ctrl_module/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/iserdes_clk_1]]
set_false_path -from [get_clocks clk_userclk] -to [get_clocks [list sys_clk_p_i clk_sys clk_200mhz cmp_xwb_bpm_pcie/cmp_wb_bpm_pcie/cmp_bpm_pcie/DDRs_ctrl_module/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/iserdes_clk_1 cmp_xwb_bpm_pcie/cmp_wb_bpm_pcie/cmp_bpm_pcie/DDRs_ctrl_module/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/iserdes_clk_1 cmp_xwb_bpm_pcie/cmp_wb_bpm_pcie/cmp_bpm_pcie/DDRs_ctrl_module/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/iserdes_clk_1 cmp_xwb_bpm_pcie/cmp_wb_bpm_pcie/cmp_bpm_pcie/DDRs_ctrl_module/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/iserdes_clk_1]]
set_false_path -from [get_clocks clk_userclk2] -to [get_clocks [list sys_clk_p_i clk_sys clk_200mhz cmp_xwb_bpm_pcie/cmp_wb_bpm_pcie/cmp_bpm_pcie/DDRs_ctrl_module/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/iserdes_clk_1 cmp_xwb_bpm_pcie/cmp_wb_bpm_pcie/cmp_bpm_pcie/DDRs_ctrl_module/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/iserdes_clk_1 cmp_xwb_bpm_pcie/cmp_wb_bpm_pcie/cmp_bpm_pcie/DDRs_ctrl_module/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/iserdes_clk_1 cmp_xwb_bpm_pcie/cmp_wb_bpm_pcie/cmp_bpm_pcie/DDRs_ctrl_module/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/iserdes_clk_1]]

# FIFO generated CDC. Xilinx recommends 2x the slower clock period delay. But let's be more strict and allow
# only 1x faster clock period delay
set_max_delay -datapath_only -from [get_clocks clk_pll_i] -to [get_clocks clk_userclk2] 8.000
set_max_delay -datapath_only -from [get_clocks clk_userclk2] -to [get_clocks clk_pll_i] 8.000

# CDC FIFO from FMCPICO to CLK_SYS. Give it "faster clock period" ns
set_max_delay -datapath_only -from [get_clocks clk_300mhz] -to [get_clocks clk_sys] 3.333
set_max_delay -datapath_only -from [get_clocks clk_sys] -to [get_clocks clk_300mhz] 3.333

#######################################################################
##                      Placement Constraints                        ##
#######################################################################
set_max_delay -datapath_only -from [get_pins -hier -filter {NAME =~ *acq_core/*acq_fc_fifo/lmt_*_pkt*/C}] -to [get_clocks clk_pll_i] 10.000
set_max_delay -datapath_only -from [get_pins -hier -filter {NAME =~ *acq_core/*acq_fc_fifo/lmt_shots*/C}] -to [get_clocks clk_pll_i] 10.000
set_max_delay -datapath_only -from [get_pins -hier -filter {NAME =~ *acq_core/*acq_fc_fifo/lmt_curr_chan*/C}] -to [get_clocks clk_pll_i] 10.000

set_max_delay -datapath_only -from [get_pins -hier -filter {NAME =~ *acq_core/*acq_ddr3_iface/lmt_*_pkt*/C}] -to [get_clocks clk_pll_i] 10.000
set_max_delay -datapath_only -from [get_pins -hier -filter {NAME =~ *acq_core/*acq_ddr3_iface/lmt_shots*/C}] -to [get_clocks clk_pll_i] 10.000
#set_max_delay -datapath_only -from [get_pins -hier -filter {NAME =~ *acq_core/*acq_ddr3_iface/lmt_curr_chan*/C}] -to [get_clocks clk_pll_i] 10.000

# Use Distributed RAM, as these FIFOs are small and sparse through the module
# Cannot make this work with hierarchical matching... only by specifying the
# whole topology
set_property RAM_STYLE DISTRIBUTED [get_cells -hier -filter {NAME =~ */cmp_position_calc_cdc_fifo/mem_reg*}]

#######################################################################
##                      Placement Constraints                        ##

# Constrain the PCIe core elements placement, so that it won't fail
# timing analysis.
# Comment out because we use nonstandard GTP location
create_pblock GRP_pcie_core
add_cells_to_pblock [get_pblocks GRP_pcie_core] [get_cells -hier -filter {NAME =~ */cmp_xwb_bpm_pcie/cmp_wb_bpm_pcie/cmp_bpm_pcie/pcie_core_i/*}]
resize_pblock [get_pblocks GRP_pcie_core] -add {CLOCKREGION_X0Y4:CLOCKREGION_X0Y4}
#
## Place the DMA design not far from PCIe core, otherwise it also breaks timing
#create_pblock GRP_ddr_core
#add_cells_to_pblock [get_pblocks GRP_ddr_core] [get_cells -hier -filter  {NAME =~ */cmp_xwb_bpm_pcie/cmp_wb_bpm_pcie/cmp_bpm_pcie/pcie_core_i/DDRs_ctrl_module/ddr_core_inst/*]]
#resize_pblock [get_pblocks GRP_ddr_core] -add {CLOCKREGION_X1Y0:CLOCKREGION_X1Y1}
#
## Place DDR core temperature monitor
#create_pblock GRP_ddr_core_temp_mon
#add_cells_to_pblock [get_pblocks GRP_ddr_core_temp_mon] [get_cells -quiet [list cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/temp_mon_enabled.u_tempmon/*]]
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
### Constraint Position Calc Cores
#create_pblock GRP_position_calc_core1
#add_cells_to_pblock [get_pblocks GRP_position_calc_core_cdc_fifo1] [get_cells -quiet {list cmp1_xwb_position_calc_core/cmp_wb_position_calc_core/*cdc_fifo*}]
#resize_pblock [get_pblocks GRP_position_calc_core1] -add {CLOCKREGION_X1Y2:CLOCKREGION_X1Y4}
#create_pblock GRP_position_calc_core_cdc_fifo2
#add_cells_to_pblock [get_pblocks GRP_position_calc_core_cdc_fifo2] [get_cells -quiet {list cmp2_xwb_position_calc_core/cmp_wb_position_calc_core/*cdc_fifo*}]
#resize_pblock [get_pblocks GRP_position_calc_core_cdc_fifo2] -add {CLOCKREGION_X0Y0:CLOCKREGION_X0Y2}
#
## Place acquisition core 0
#create_pblock GRP_acq_core_0
#add_cells_to_pblock [get_pblocks GRP_acq_core_0] [get_cells -hier -filter {NAME =~ */cmp_wb_facq_core_mux/gen_facq_core[0].*}]
#resize_pblock [get_pblocks GRP_acq_core_0] -add {CLOCKREGION_X0Y3:CLOCKREGION_X1Y3} -remove {CLOCKREGION_X0Y4:CLOCKREGION_X1Y4}

#######################################################################
##                         CE Constraints                            ##
#######################################################################

## Mixer CE
#set_multicycle_path 2 -setup -from  [all_fanout -endpoints_only -only_cells -from [get_pins * -hierarchical -filter {NAME =~ *position_calc/gen_ddc[?].cmp_mixer/*}]]
#set_multicycle_path 1 -hold -from  [all_fanout -endpoints_only -only_cells -from [get_pins * -hierarchical -filter {NAME =~ *position_calc/gen_ddc[?].cmp_mixer/*}]]

## CIC TBT CE
#set_multicycle_path 2 -setup -from  [all_fanout -endpoints_only -only_cells -from [get_pins * -hierarchical -filter {NAME =~ *position_calc/gen_ddc[?].cmp_tbt_cic/cmp_cic_decim*/*}]]
#set_multicycle_path 1 -hold -from  [all_fanout -endpoints_only -only_cells -from [get_pins * -hierarchical -filter {NAME =~ *position_calc/gen_ddc[?].cmp_tbt_cic/cmp_cic_decim*/*}]]

## TBT CORDIC CE
#set_multicycle_path 4 -setup -from [all_fanout -endpoints_only -only_cells -from [get_pins * -hierarchical -filter {NAME =~ *position_calc/gen_ddc[?].cmp_tbt_cordic/cmp_cordic_core/*}]]
#set_multicycle_path 3 -hold -from [all_fanout -endpoints_only -only_cells -from [get_pins * -hierarchical -filter {NAME =~ *position_calc/gen_ddc[?].cmp_tbt_cordic/cmp_cordic_core/*}]]

## CIC FOFB CE
#set_multicycle_path 2 -setup -from [all_fanout -endpoints_only -only_cells -from [get_pins * -hierarchical -filter {NAME =~ *position_calc/gen_ddc[?].cmp_fofb_cic/cmp_cic_decim*/*}]]
#set_multicycle_path 1 -hold -from [all_fanout -endpoints_only -only_cells -from [get_pins * -hierarchical -filter {NAME =~ *position_calc/gen_ddc[?].cmp_fofb_cic/cmp_cic_decim*/*}]]

## FOFB CORDIC CE
# FIXME: get CE from VHDL code
#set_multicycle_path 4 -setup -from [all_fanout -endpoints_only -only_cells -from [get_pins * -hierarchical -filter {NAME =~ *position_calc/gen_ddc[?].cmp_fofb_cordic/cmp_cordic_core/*}]]
#set_multicycle_path 3 -hold -from [all_fanout -endpoints_only -only_cells -from [get_pins * -hierarchical -filter {NAME =~ *position_calc/gen_ddc[?].cmp_fofb_cordic/cmp_cordic_core/*}]]

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

#set_property BITSTREAM.Config.SPI_BUSWIDTH 1    [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 50       [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES   [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE      [current_design]
set_property CFGBVS VCCO                          [current_design]
set_property CONFIG_VOLTAGE 3.3                   [current_design]
