#######################################################################
##                      Artix 7 AMC V3                               ##
#######################################################################

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

# These pins are shared with the fmc2 pins,as they go to a I2C MUX
# SCL
#set_property PACKAGE_PIN P6 [get_ports fmc1_sm_scl_o]                   ;# FPGA_I2C_SCL (through I2C MUX)
#set_property IOSTANDARD LVCMOS25 [get_ports fmc1_sm_scl_o]
## SDA
#set_property PACKAGE_PIN R11 [get_ports fmc1_sm_sda_b]                  ;# FPGA_I2C_SDA (through I2C MUX)
#set_property IOSTANDARD LVCMOS25 [get_ports fmc1_sm_sda_b]
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
##                          Clocks                                   ##
#######################################################################

# DDR3 clock generated by IP
set clk_pll_ddr_period                             [get_property PERIOD [get_clocks clk_pll_i]]
set clk_pll_ddr_period_less                        [expr $clk_pll_ddr_period - 1.000]

# PCIE clock generated by IP
set clk_125mhz_period                             [get_property PERIOD [get_clocks clk_125mhz]]

#######################################################################
##                              CDC                                  ##
#######################################################################

# Use Distributed RAM, as these FIFOs are small and sparse through the module
# Cannot make this work with hierarchical matching... only by specifying the
# whole topology
set_property RAM_STYLE DISTRIBUTED [get_cells -hier -filter {NAME =~ */cmp_position_calc_cdc_fifo/mem_reg*}]

# Use Distributed RAMs for FMC ADC CDC FIFOs. They are small and sparse.
set_property RAM_STYLE DISTRIBUTED [get_cells -hier -filter {NAME =~ */cmp_fmc_adc_iface/*/cmp_adc_data_async_fifo/mem_reg*}]

#######################################################################
##                      Placement Constraints                        ##
#######################################################################

# Constrain the PCIe core elements placement, so that it won't fail
# timing analysis.
# Comment out because we use nonstandard GTP location
#create_pblock GRP_pcie_core
#add_cells_to_pblock [get_pblocks GRP_pcie_core] [get_cells -hier -filter {NAME =~ *pcie_core_i/*}]
#resize_pblock [get_pblocks GRP_pcie_core] -add {CLOCKREGION_X0Y4:CLOCKREGION_X0Y4}
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

## CIC MONIT 1 CE. Uses ce_fofb_cordic as CE
set monit1_ce_fanouts [get_cells -of_objects [ \
    filter -regexp [ \
        all_fanout -flat -endpoints_only -from [ \
            # Get from a known CE pin on CORDIC design: the PIN that is driving the NET
            # This is needed (really?) in our case as the CE driver, in the case of
            # the channel #0 get optimized out and replaced by another NET.
            get_pins -of_objects [ \
                get_nets -segments -of_objects [ \
                    get_pins -hierarchical  -filter { \
                        NAME =~ *position_calc*cmp_monit1_cic/*CE \
                    } \
                ] \
            ] -filter {IS_LEAF && (DIRECTION == "OUT")} \
        ] \
    ] \
    {NAME =~ .*cmp_monit1_cic/.*} \
]]

set_multicycle_path 4 -setup -from  $monit1_ce_fanouts
set_multicycle_path 3 -hold -from   $monit1_ce_fanouts

## CIC MONIT 2 CE. uses ce_monit1 as CE
set monit2_ce_fanouts [get_cells -of_objects [ \
    filter -regexp [ \
        all_fanout -flat -endpoints_only -from [ \
            # Get from a known CE pin on CORDIC design: the PIN that is driving the NET
            # This is needed (really?) in our case as the CE driver, in the case of
            # the channel #0 get optimized out and replaced by another NET.
            get_pins -of_objects [ \
                get_nets -segments -of_objects [ \
                    get_pins -hierarchical  -filter { \
                        NAME =~ *position_calc*cmp_monit2_cic/*CE \
                    } \
                ] \
            ] -filter {IS_LEAF && (DIRECTION == "OUT")} \
        ] \
    ] \
    {NAME =~ .*cmp_monit2_cic/.*} \
]]

set_multicycle_path 4 -setup -from  $monit2_ce_fanouts
set_multicycle_path 3 -hold -from   $monit2_ce_fanouts
