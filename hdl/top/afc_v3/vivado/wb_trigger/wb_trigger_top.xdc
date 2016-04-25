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


# System Reset
# Bank 16 VCCO - VADJ_FPGA - IO_25_16. NET = FPGA_RESET_DN, PIN = IO_L19P_T3_13
#set_false_path -through [get_nets sys_rst_button_n_i]
#set_property PACKAGE_PIN AG26 [get_ports sys_rst_button_n_i]
#set_property IOSTANDARD LVCMOS25 [get_ports sys_rst_button_n_i]
#set_property PULLUP true [get_ports sys_rst_button_n_i]


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



#######################################################################
##                         Cross Clock Constraints		     ##
#######################################################################

# Reset synchronization path
#set_false_path -through [get_nets cmp_reset/master_rstn]
set_false_path -through [get_pins -hier -filter {name=~ cmp_reset/master_rstn_reg/C}]
# This reset is synched with PCIe user_clk but we decouple it with a
# chain of FFs synched with clk_sys. We use asynchronous assertion and
# synchronous deassertion
set_false_path -through [get_nets cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/theTlpControl/Memory_Space/wb_FIFO_Rst_i0]
# DDR 3 temperature monitor reset path
set_max_delay -datapath_only -from [get_cells -hier -filter {NAME =~ *ddr3_infrastructure/rstdiv0_sync_r1_reg*}] -to [get_cells -hier -filter {NAME =~ *temp_mon_enabled.u_tempmon/xadc_supplied_temperature.rst_r1*}] 20.000


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


#######################################################################
##                           Direction	                             ##
#######################################################################

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












##################################################################################################
##
##  Xilinx, Inc. 2010            www.xilinx.com
##  sáb fev 21 11:40:05 2015
##  Generated by MIG Version 2.3
##
##################################################################################################
##  File name :       ddr_core.xdc
##  Details :     Constraints file
##                    FPGA Family:       ARTIX7
##                    FPGA Part:         XC7A200T-FFG1156
##                    Speedgrade:        -1
##                    Design Entry:      VHDL
##                    Frequency:         0 MHz
##                    Time Period:       2500 ps
##################################################################################################

##################################################################################################
## Controller 0
## Memory Device: DDR3_SDRAM->Components->MT41J512M8XX-125
## Data Width: 32
## Time Period: 2500
## Data Mask: 1
##################################################################################################

#create_clock -period -2.14748e+06 [get_ports sys_clk_i]
#set_propagated_clock sys_clk_i

############## NET - IOSTANDARD ##################


# PadFunction: IO_L22P_T3_33
set_property SLEW FAST [get_ports {ddr3_dq_b[0]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {ddr3_dq_b[0]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_dq_b[0]}]
set_property PACKAGE_PIN AD11 [get_ports {ddr3_dq_b[0]}]

# PadFunction: IO_L24N_T3_33
set_property SLEW FAST [get_ports {ddr3_dq_b[1]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {ddr3_dq_b[1]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_dq_b[1]}]
set_property PACKAGE_PIN AE10 [get_ports {ddr3_dq_b[1]}]

# PadFunction: IO_L20P_T3_33
set_property SLEW FAST [get_ports {ddr3_dq_b[2]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {ddr3_dq_b[2]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_dq_b[2]}]
set_property PACKAGE_PIN AF12 [get_ports {ddr3_dq_b[2]}]

# PadFunction: IO_L23P_T3_33
set_property SLEW FAST [get_ports {ddr3_dq_b[3]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {ddr3_dq_b[3]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_dq_b[3]}]
set_property PACKAGE_PIN AG11 [get_ports {ddr3_dq_b[3]}]

# PadFunction: IO_L22N_T3_33
set_property SLEW FAST [get_ports {ddr3_dq_b[4]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {ddr3_dq_b[4]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_dq_b[4]}]
set_property PACKAGE_PIN AE11 [get_ports {ddr3_dq_b[4]}]

# PadFunction: IO_L23N_T3_33
set_property SLEW FAST [get_ports {ddr3_dq_b[5]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {ddr3_dq_b[5]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_dq_b[5]}]
set_property PACKAGE_PIN AH11 [get_ports {ddr3_dq_b[5]}]

# PadFunction: IO_L20N_T3_33
set_property SLEW FAST [get_ports {ddr3_dq_b[6]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {ddr3_dq_b[6]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_dq_b[6]}]
set_property PACKAGE_PIN AG12 [get_ports {ddr3_dq_b[6]}]

# PadFunction: IO_L19P_T3_33
set_property SLEW FAST [get_ports {ddr3_dq_b[7]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {ddr3_dq_b[7]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_dq_b[7]}]
set_property PACKAGE_PIN AH9 [get_ports {ddr3_dq_b[7]}]

# PadFunction: IO_L13P_T2_MRCC_33
set_property SLEW FAST [get_ports {ddr3_dq_b[8]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {ddr3_dq_b[8]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_dq_b[8]}]
set_property PACKAGE_PIN AD6 [get_ports {ddr3_dq_b[8]}]

# PadFunction: IO_L14N_T2_SRCC_33
set_property SLEW FAST [get_ports {ddr3_dq_b[9]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {ddr3_dq_b[9]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_dq_b[9]}]
set_property PACKAGE_PIN AG7 [get_ports {ddr3_dq_b[9]}]

# PadFunction: IO_L18P_T2_33
set_property SLEW FAST [get_ports {ddr3_dq_b[10]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {ddr3_dq_b[10]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_dq_b[10]}]
set_property PACKAGE_PIN AF9 [get_ports {ddr3_dq_b[10]}]

# PadFunction: IO_L17P_T2_33
set_property SLEW FAST [get_ports {ddr3_dq_b[11]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {ddr3_dq_b[11]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_dq_b[11]}]
set_property PACKAGE_PIN AH7 [get_ports {ddr3_dq_b[11]}]

# PadFunction: IO_L16P_T2_33
set_property SLEW FAST [get_ports {ddr3_dq_b[12]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {ddr3_dq_b[12]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_dq_b[12]}]
set_property PACKAGE_PIN AE8 [get_ports {ddr3_dq_b[12]}]

# PadFunction: IO_L18N_T2_33
set_property SLEW FAST [get_ports {ddr3_dq_b[13]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {ddr3_dq_b[13]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_dq_b[13]}]
set_property PACKAGE_PIN AF8 [get_ports {ddr3_dq_b[13]}]

# PadFunction: IO_L16N_T2_33
set_property SLEW FAST [get_ports {ddr3_dq_b[14]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {ddr3_dq_b[14]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_dq_b[14]}]
set_property PACKAGE_PIN AE7 [get_ports {ddr3_dq_b[14]}]

# PadFunction: IO_L14P_T2_SRCC_33
set_property SLEW FAST [get_ports {ddr3_dq_b[15]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {ddr3_dq_b[15]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_dq_b[15]}]
set_property PACKAGE_PIN AF7 [get_ports {ddr3_dq_b[15]}]

# PadFunction: IO_L7P_T1_33
set_property SLEW FAST [get_ports {ddr3_dq_b[16]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {ddr3_dq_b[16]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_dq_b[16]}]
set_property PACKAGE_PIN AF4 [get_ports {ddr3_dq_b[16]}]

# PadFunction: IO_L12N_T1_MRCC_33
set_property SLEW FAST [get_ports {ddr3_dq_b[17]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {ddr3_dq_b[17]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_dq_b[17]}]
set_property PACKAGE_PIN AF5 [get_ports {ddr3_dq_b[17]}]

# PadFunction: IO_L10P_T1_33
set_property SLEW FAST [get_ports {ddr3_dq_b[18]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {ddr3_dq_b[18]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_dq_b[18]}]
set_property PACKAGE_PIN AD3 [get_ports {ddr3_dq_b[18]}]

# PadFunction: IO_L11N_T1_SRCC_33
set_property SLEW FAST [get_ports {ddr3_dq_b[19]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {ddr3_dq_b[19]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_dq_b[19]}]
set_property PACKAGE_PIN AG5 [get_ports {ddr3_dq_b[19]}]

# PadFunction: IO_L8P_T1_33
set_property SLEW FAST [get_ports {ddr3_dq_b[20]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {ddr3_dq_b[20]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_dq_b[20]}]
set_property PACKAGE_PIN AD5 [get_ports {ddr3_dq_b[20]}]

# PadFunction: IO_L11P_T1_SRCC_33
set_property SLEW FAST [get_ports {ddr3_dq_b[21]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {ddr3_dq_b[21]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_dq_b[21]}]
set_property PACKAGE_PIN AG6 [get_ports {ddr3_dq_b[21]}]

# PadFunction: IO_L8N_T1_33
set_property SLEW FAST [get_ports {ddr3_dq_b[22]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {ddr3_dq_b[22]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_dq_b[22]}]
set_property PACKAGE_PIN AD4 [get_ports {ddr3_dq_b[22]}]

# PadFunction: IO_L10N_T1_33
set_property SLEW FAST [get_ports {ddr3_dq_b[23]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {ddr3_dq_b[23]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_dq_b[23]}]
set_property PACKAGE_PIN AE3 [get_ports {ddr3_dq_b[23]}]

# PadFunction: IO_L1P_T0_33
set_property SLEW FAST [get_ports {ddr3_dq_b[24]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {ddr3_dq_b[24]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_dq_b[24]}]
set_property PACKAGE_PIN AG1 [get_ports {ddr3_dq_b[24]}]

# PadFunction: IO_L5N_T0_33
set_property SLEW FAST [get_ports {ddr3_dq_b[25]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {ddr3_dq_b[25]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_dq_b[25]}]
set_property PACKAGE_PIN AG2 [get_ports {ddr3_dq_b[25]}]

# PadFunction: IO_L2N_T0_33
set_property SLEW FAST [get_ports {ddr3_dq_b[26]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {ddr3_dq_b[26]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_dq_b[26]}]
set_property PACKAGE_PIN AE1 [get_ports {ddr3_dq_b[26]}]

# PadFunction: IO_L5P_T0_33
set_property SLEW FAST [get_ports {ddr3_dq_b[27]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {ddr3_dq_b[27]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_dq_b[27]}]
set_property PACKAGE_PIN AF3 [get_ports {ddr3_dq_b[27]}]

# PadFunction: IO_L4P_T0_33
set_property SLEW FAST [get_ports {ddr3_dq_b[28]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {ddr3_dq_b[28]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_dq_b[28]}]
set_property PACKAGE_PIN AE2 [get_ports {ddr3_dq_b[28]}]

# PadFunction: IO_L6P_T0_33
set_property SLEW FAST [get_ports {ddr3_dq_b[29]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {ddr3_dq_b[29]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_dq_b[29]}]
set_property PACKAGE_PIN AH3 [get_ports {ddr3_dq_b[29]}]

# PadFunction: IO_L2P_T0_33
set_property SLEW FAST [get_ports {ddr3_dq_b[30]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {ddr3_dq_b[30]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_dq_b[30]}]
set_property PACKAGE_PIN AD1 [get_ports {ddr3_dq_b[30]}]

# PadFunction: IO_L4N_T0_33
set_property SLEW FAST [get_ports {ddr3_dq_b[31]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {ddr3_dq_b[31]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_dq_b[31]}]
set_property PACKAGE_PIN AF2 [get_ports {ddr3_dq_b[31]}]

# PadFunction: IO_L5N_T0_32
set_property SLEW FAST [get_ports {ddr3_addr_o[15]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_addr_o[15]}]
set_property PACKAGE_PIN AP3 [get_ports {ddr3_addr_o[15]}]

# PadFunction: IO_L15N_T2_DQS_32
set_property SLEW FAST [get_ports {ddr3_addr_o[14]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_addr_o[14]}]
set_property PACKAGE_PIN AK8 [get_ports {ddr3_addr_o[14]}]

# PadFunction: IO_L14P_T2_SRCC_32
set_property SLEW FAST [get_ports {ddr3_addr_o[13]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_addr_o[13]}]
set_property PACKAGE_PIN AM7 [get_ports {ddr3_addr_o[13]}]

# PadFunction: IO_L9N_T1_DQS_32
set_property SLEW FAST [get_ports {ddr3_addr_o[12]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_addr_o[12]}]
set_property PACKAGE_PIN AP5 [get_ports {ddr3_addr_o[12]}]

# PadFunction: IO_L15P_T2_DQS_32
set_property SLEW FAST [get_ports {ddr3_addr_o[11]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_addr_o[11]}]
set_property PACKAGE_PIN AJ8 [get_ports {ddr3_addr_o[11]}]

# PadFunction: IO_L3N_T0_DQS_32
set_property SLEW FAST [get_ports {ddr3_addr_o[10]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_addr_o[10]}]
set_property PACKAGE_PIN AN2 [get_ports {ddr3_addr_o[10]}]

# PadFunction: IO_L10P_T1_32
set_property SLEW FAST [get_ports {ddr3_addr_o[9]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_addr_o[9]}]
set_property PACKAGE_PIN AL4 [get_ports {ddr3_addr_o[9]}]

# PadFunction: IO_L12N_T1_MRCC_32
set_property SLEW FAST [get_ports {ddr3_addr_o[8]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_addr_o[8]}]
set_property PACKAGE_PIN AK6 [get_ports {ddr3_addr_o[8]}]

# PadFunction: IO_L9P_T1_DQS_32
set_property SLEW FAST [get_ports {ddr3_addr_o[7]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_addr_o[7]}]
set_property PACKAGE_PIN AP6 [get_ports {ddr3_addr_o[7]}]

# PadFunction: IO_L8N_T1_32
set_property SLEW FAST [get_ports {ddr3_addr_o[6]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_addr_o[6]}]
set_property PACKAGE_PIN AK5 [get_ports {ddr3_addr_o[6]}]

# PadFunction: IO_L6P_T0_32
set_property SLEW FAST [get_ports {ddr3_addr_o[5]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_addr_o[5]}]
set_property PACKAGE_PIN AK3 [get_ports {ddr3_addr_o[5]}]

# PadFunction: IO_L7P_T1_32
set_property SLEW FAST [get_ports {ddr3_addr_o[4]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_addr_o[4]}]
set_property PACKAGE_PIN AN4 [get_ports {ddr3_addr_o[4]}]

# PadFunction: IO_L14N_T2_SRCC_32
set_property SLEW FAST [get_ports {ddr3_addr_o[3]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_addr_o[3]}]
set_property PACKAGE_PIN AM6 [get_ports {ddr3_addr_o[3]}]

# PadFunction: IO_L10N_T1_32
set_property SLEW FAST [get_ports {ddr3_addr_o[2]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_addr_o[2]}]
set_property PACKAGE_PIN AM4 [get_ports {ddr3_addr_o[2]}]

# PadFunction: IO_L12P_T1_MRCC_32
set_property SLEW FAST [get_ports {ddr3_addr_o[1]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_addr_o[1]}]
set_property PACKAGE_PIN AJ6 [get_ports {ddr3_addr_o[1]}]

# PadFunction: IO_L7N_T1_32
set_property SLEW FAST [get_ports {ddr3_addr_o[0]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_addr_o[0]}]
set_property PACKAGE_PIN AP4 [get_ports {ddr3_addr_o[0]}]

# PadFunction: IO_L2N_T0_32
set_property SLEW FAST [get_ports {ddr3_ba_o[2]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_ba_o[2]}]
set_property PACKAGE_PIN AK1 [get_ports {ddr3_ba_o[2]}]

# PadFunction: IO_L2P_T0_32
set_property SLEW FAST [get_ports {ddr3_ba_o[1]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_ba_o[1]}]
set_property PACKAGE_PIN AK2 [get_ports {ddr3_ba_o[1]}]

# PadFunction: IO_L3P_T0_DQS_32
set_property SLEW FAST [get_ports {ddr3_ba_o[0]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_ba_o[0]}]
set_property PACKAGE_PIN AM2 [get_ports {ddr3_ba_o[0]}]

# PadFunction: IO_L1P_T0_32
set_property SLEW FAST [get_ports ddr3_ras_n_o]
set_property IOSTANDARD SSTL15 [get_ports ddr3_ras_n_o]
set_property PACKAGE_PIN AN1 [get_ports ddr3_ras_n_o]

# PadFunction: IO_L4P_T0_32
set_property SLEW FAST [get_ports ddr3_cas_n_o]
set_property IOSTANDARD SSTL15 [get_ports ddr3_cas_n_o]
set_property PACKAGE_PIN AL2 [get_ports ddr3_cas_n_o]

# PadFunction: IO_L4N_T0_32
set_property SLEW FAST [get_ports ddr3_we_n_o]
set_property IOSTANDARD SSTL15 [get_ports ddr3_we_n_o]
set_property PACKAGE_PIN AM1 [get_ports ddr3_we_n_o]

# PadFunction: IO_0_32
set_property SLEW FAST [get_ports ddr3_reset_n_o]
set_property IOSTANDARD LVCMOS15 [get_ports ddr3_reset_n_o]
set_property PACKAGE_PIN AJ9 [get_ports ddr3_reset_n_o]

# PadFunction: IO_L8P_T1_32
set_property SLEW FAST [get_ports {ddr3_cke_o[0]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_cke_o[0]}]
set_property PACKAGE_PIN AJ5 [get_ports {ddr3_cke_o[0]}]

# PadFunction: IO_L1N_T0_32
set_property SLEW FAST [get_ports {ddr3_odt_o[0]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_odt_o[0]}]
set_property PACKAGE_PIN AP1 [get_ports {ddr3_odt_o[0]}]

# PadFunction: IO_L5P_T0_32
set_property SLEW FAST [get_ports {ddr3_cs_n_o[0]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_cs_n_o[0]}]
set_property PACKAGE_PIN AN3 [get_ports {ddr3_cs_n_o[0]}]

# PadFunction: IO_L24P_T3_33
set_property SLEW FAST [get_ports {ddr3_dm_o[0]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_dm_o[0]}]
set_property PACKAGE_PIN AD10 [get_ports {ddr3_dm_o[0]}]

# PadFunction: IO_L17N_T2_33
set_property SLEW FAST [get_ports {ddr3_dm_o[1]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_dm_o[1]}]
set_property PACKAGE_PIN AH6 [get_ports {ddr3_dm_o[1]}]

# PadFunction: IO_L7N_T1_33
set_property SLEW FAST [get_ports {ddr3_dm_o[2]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_dm_o[2]}]
set_property PACKAGE_PIN AG4 [get_ports {ddr3_dm_o[2]}]

# PadFunction: IO_L1N_T0_33
set_property SLEW FAST [get_ports {ddr3_dm_o[3]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_dm_o[3]}]
set_property PACKAGE_PIN AH1 [get_ports {ddr3_dm_o[3]}]

# PadFunction: IO_L21P_T3_DQS_33
set_property SLEW FAST [get_ports {ddr3_dqs_p_b[0]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {ddr3_dqs_p_b[0]}]
set_property IOSTANDARD DIFF_SSTL15 [get_ports {ddr3_dqs_p_b[0]}]

# PadFunction: IO_L21N_T3_DQS_33
set_property SLEW FAST [get_ports {ddr3_dqs_n_b[0]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {ddr3_dqs_n_b[0]}]
set_property IOSTANDARD DIFF_SSTL15 [get_ports {ddr3_dqs_n_b[0]}]
set_property PACKAGE_PIN AG9 [get_ports {ddr3_dqs_n_b[0]}]

# PadFunction: IO_L15P_T2_DQS_33
set_property SLEW FAST [get_ports {ddr3_dqs_p_b[1]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {ddr3_dqs_p_b[1]}]
set_property IOSTANDARD DIFF_SSTL15 [get_ports {ddr3_dqs_p_b[1]}]

# PadFunction: IO_L15N_T2_DQS_33
set_property SLEW FAST [get_ports {ddr3_dqs_n_b[1]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {ddr3_dqs_n_b[1]}]
set_property IOSTANDARD DIFF_SSTL15 [get_ports {ddr3_dqs_n_b[1]}]
set_property PACKAGE_PIN AD8 [get_ports {ddr3_dqs_n_b[1]}]

# PadFunction: IO_L9P_T1_DQS_33
set_property SLEW FAST [get_ports {ddr3_dqs_p_b[2]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {ddr3_dqs_p_b[2]}]
set_property IOSTANDARD DIFF_SSTL15 [get_ports {ddr3_dqs_p_b[2]}]

# PadFunction: IO_L9N_T1_DQS_33
set_property SLEW FAST [get_ports {ddr3_dqs_n_b[2]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {ddr3_dqs_n_b[2]}]
set_property IOSTANDARD DIFF_SSTL15 [get_ports {ddr3_dqs_n_b[2]}]
set_property PACKAGE_PIN AJ4 [get_ports {ddr3_dqs_n_b[2]}]

# PadFunction: IO_L3P_T0_DQS_33
set_property SLEW FAST [get_ports {ddr3_dqs_p_b[3]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {ddr3_dqs_p_b[3]}]
set_property IOSTANDARD DIFF_SSTL15 [get_ports {ddr3_dqs_p_b[3]}]

# PadFunction: IO_L3N_T0_DQS_33
set_property SLEW FAST [get_ports {ddr3_dqs_n_b[3]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {ddr3_dqs_n_b[3]}]
set_property IOSTANDARD DIFF_SSTL15 [get_ports {ddr3_dqs_n_b[3]}]
set_property PACKAGE_PIN AJ1 [get_ports {ddr3_dqs_n_b[3]}]

# PadFunction: IO_L11P_T1_SRCC_32
set_property SLEW FAST [get_ports {ddr3_ck_p_o[0]}]
set_property IOSTANDARD DIFF_SSTL15 [get_ports {ddr3_ck_p_o[0]}]

# PadFunction: IO_L11N_T1_SRCC_32
set_property SLEW FAST [get_ports {ddr3_ck_n_o[0]}]
set_property IOSTANDARD DIFF_SSTL15 [get_ports {ddr3_ck_n_o[0]}]
set_property PACKAGE_PIN AM5 [get_ports {ddr3_ck_n_o[0]}]



set_property LOC PHASER_OUT_PHY_X1Y3 [get_cells cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_1.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/phaser_out]
set_property LOC PHASER_OUT_PHY_X1Y2 [get_cells cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_1.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/phaser_out]
set_property LOC PHASER_OUT_PHY_X1Y1 [get_cells cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_1.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/phaser_out]
set_property LOC PHASER_OUT_PHY_X1Y7 [get_cells cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/phaser_out]
set_property LOC PHASER_OUT_PHY_X1Y6 [get_cells cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/phaser_out]
set_property LOC PHASER_OUT_PHY_X1Y5 [get_cells cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/phaser_out]
set_property LOC PHASER_OUT_PHY_X1Y4 [get_cells cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/phaser_out]

## set_property LOC PHASER_IN_PHY_X1Y3 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_1.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/phaser_in_gen.phaser_in}]
## set_property LOC PHASER_IN_PHY_X1Y2 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_1.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/phaser_in_gen.phaser_in}]
## set_property LOC PHASER_IN_PHY_X1Y1 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_1.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/phaser_in_gen.phaser_in}]
set_property LOC PHASER_IN_PHY_X1Y7 [get_cells cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/phaser_in_gen.phaser_in]
set_property LOC PHASER_IN_PHY_X1Y6 [get_cells cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/phaser_in_gen.phaser_in]
set_property LOC PHASER_IN_PHY_X1Y5 [get_cells cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/phaser_in_gen.phaser_in]
set_property LOC PHASER_IN_PHY_X1Y4 [get_cells cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/phaser_in_gen.phaser_in]



set_property LOC OUT_FIFO_X1Y3 [get_cells cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_1.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/out_fifo]
set_property LOC OUT_FIFO_X1Y2 [get_cells cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_1.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/out_fifo]
set_property LOC OUT_FIFO_X1Y1 [get_cells cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_1.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/out_fifo]
set_property LOC OUT_FIFO_X1Y7 [get_cells cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/out_fifo]
set_property LOC OUT_FIFO_X1Y6 [get_cells cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/out_fifo]
set_property LOC OUT_FIFO_X1Y5 [get_cells cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/out_fifo]
set_property LOC OUT_FIFO_X1Y4 [get_cells cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/out_fifo]

set_property LOC IN_FIFO_X1Y7 [get_cells cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/in_fifo_gen.in_fifo]
set_property LOC IN_FIFO_X1Y6 [get_cells cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/in_fifo_gen.in_fifo]
set_property LOC IN_FIFO_X1Y5 [get_cells cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/in_fifo_gen.in_fifo]
set_property LOC IN_FIFO_X1Y4 [get_cells cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/in_fifo_gen.in_fifo]

set_property LOC PHY_CONTROL_X1Y0 [get_cells cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_1.u_ddr_phy_4lanes/phy_control_i]
set_property LOC PHY_CONTROL_X1Y1 [get_cells cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/phy_control_i]

set_property LOC PHASER_REF_X1Y0 [get_cells cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_1.u_ddr_phy_4lanes/phaser_ref_i]
set_property LOC PHASER_REF_X1Y1 [get_cells cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/phaser_ref_i]

set_property LOC OLOGIC_X1Y93 [get_cells cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/ddr_byte_group_io/slave_ts.oserdes_slave_ts]
set_property LOC OLOGIC_X1Y81 [get_cells cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/ddr_byte_group_io/slave_ts.oserdes_slave_ts]
set_property LOC OLOGIC_X1Y69 [get_cells cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/ddr_byte_group_io/slave_ts.oserdes_slave_ts]
set_property LOC OLOGIC_X1Y57 [get_cells cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_memc_ui_top_std/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/ddr_byte_group_io/slave_ts.oserdes_slave_ts]

set_property LOC PLLE2_ADV_X1Y0 [get_cells cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_ddr3_infrastructure/plle2_i]
set_property LOC MMCME2_ADV_X1Y0 [get_cells cmp_xwb_bpm_pcie_a7/cmp_wb_bpm_pcie_a7/cmp_bpm_pcie_a7/u_ddr_core/u_ddr_core_mig/u_ddr3_infrastructure/gen_mmcm.mmcm_i]


set_multicycle_path -setup -from [get_cells -hier -filter {NAME =~ */mc0/mc_read_idle_r_reg}] -to [get_cells -hier -filter {NAME =~ */input_[?].iserdes_dq_.iserdesdq}] 6

set_multicycle_path -hold -from [get_cells -hier -filter {NAME =~ */mc0/mc_read_idle_r_reg}] -to [get_cells -hier -filter {NAME =~ */input_[?].iserdes_dq_.iserdesdq}] 5

#set_multicycle_path -from [get_cells -hier -filter {NAME =~ */mc0/mc_read_idle_r*}] #                    -to   [get_cells -hier -filter {NAME =~ */input_[?].iserdes_dq_.iserdesdq}] #                    -setup 6

#set_multicycle_path -from [get_cells -hier -filter {NAME =~ */mc0/mc_read_idle_r*}] #                    -to   [get_cells -hier -filter {NAME =~ */input_[?].iserdes_dq_.iserdesdq}] #                    -hold 5

#set_max_delay -from [get_cells -hier -filter {NAME =~ */u_phase_detector && IS_SEQUENTIAL}] -to [get_cells -hier -filter {NAME =~ *neg_edge_samp*}] 2.500000
#set_max_delay -from [get_cells -hier -filter {NAME =~ */u_phase_detector && IS_SEQUENTIAL}] -to [get_cells -hier -filter {NAME =~ *pos_edge_samp*}] 2.500000

set_false_path -through [get_pins -filter {NAME =~ */DQSFOUND} -of [get_cells -hier -filter {REF_NAME == PHASER_IN_PHY}]]

set_multicycle_path -setup -start -through [get_pins -filter {NAME =~ */OSERDESRST} -of [get_cells -hier -filter {REF_NAME == PHASER_OUT_PHY}]] 2
set_multicycle_path -hold -start -through [get_pins -filter {NAME =~ */OSERDESRST} -of [get_cells -hier -filter {REF_NAME == PHASER_OUT_PHY}]] 1

set_max_delay -datapath_only -from [get_cells -hier -filter {NAME =~ *temp_mon_enabled.u_tempmon/* && IS_SEQUENTIAL}] -to [get_cells -hier -filter {NAME =~ *temp_mon_enabled.u_tempmon/device_temp_sync_r1*}] 20.000
set_max_delay -datapath_only -from [get_cells -hier *rstdiv0_sync_r1_reg*] -to [get_pins -filter {NAME =~ */RESET} -of [get_cells -hier -filter {REF_NAME == PHY_CONTROL}]] 5.000
#set_max_delay -datapath_only -from [get_cells -hier -filter {NAME =~ *temp_mon_enabled.u_tempmon/*}] -to [get_cells -hier -filter {NAME =~ *temp_mon_enabled.u_tempmon/device_temp_sync_r1*}] 20
#set_max_delay -from [get_cells -hier rstdiv0_sync_r1*] -to [get_pins -filter {NAME =~ */RESET} -of [get_cells -hier -filter {REF_NAME == PHY_CONTROL}]] -datapath_only 5

set_max_delay -datapath_only -from [get_cells -hier -filter {NAME =~ *ddr3_infrastructure/rstdiv0_sync_r1_reg*}] -to [get_cells -hier -filter {NAME =~ *temp_mon_enabled.u_tempmon/xadc_supplied_temperature.rst_r1*}] 20.000
#set_max_delay -datapath_only -from [get_cells -hier -filter {NAME =~ *ddr3_infrastructure/rstdiv0_sync_r1*}] -to [get_cells -hier -filter {NAME =~ *temp_mon_enabled.u_tempmon/*rst_r1*}] 20
