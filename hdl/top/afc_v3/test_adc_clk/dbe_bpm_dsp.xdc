#######################################################################
##                      Artix 7 AMC V3                               ##
#######################################################################

#######################################################################
##                      FMC Connector HPC1                           ##
#######################################################################

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

#######################################################################
##                       FMC Connector HPC2                           #
##                         LTC ADC lines                              #
#######################################################################

#// ADC0
#// LA17_CC_P
set_property PACKAGE_PIN AB31 [get_ports fmc2_adc0_clk_i]
set_property IOSTANDARD LVCMOS25 [get_ports fmc2_adc0_clk_i]

#######################################################################
##                          Clocks                                   ##
#######################################################################

# real jitter is about 22ps peak-to-peak
create_clock -period 8.000 -name fmc1_adc0_clk_i [get_ports fmc1_adc0_clk_i]
set_input_jitter fmc1_adc0_clk_i 0.050
create_clock -period 8.000 -name fmc2_adc0_clk_i [get_ports fmc2_adc0_clk_i]
set_input_jitter fmc2_adc0_clk_i 0.050

