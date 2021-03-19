#######################################################################
##                      Artix 7 AMC V3                               ##
#######################################################################
#
#######################################################################
##                          Clocks                                   ##
#######################################################################

# RTM FPGA 1 clock. 156.25 MHz
create_clock -period 6.400 -name rtm_fpga_clk1 [get_ports rtm_fpga_clk1_p_i]
set rtm_fpga_clk1_period                       [get_property PERIOD [get_clocks rtm_fpga_clk1]]

# RTM FPGA 2 clock. 156.25 MHz
create_clock -period 6.400 -name rtm_fpga_clk2 [get_ports rtm_fpga_clk2_p_i]
set rtm_fpga_clk2_period                       [get_property PERIOD [get_clocks rtm_fpga_clk2]]

#######################################################################
##                          DELAYS                                   ##
#######################################################################

#######################################################################
##                          DELAY values                             ##
#######################################################################

## Overrides default_delay hdl parameter for the VARIABLE mode.
## For Artix7: Average Tap Delay at 200 MHz = 78 ps, at 300 MHz = 52 ps ???

#######################################################################
##                              CDC                                  ##
#######################################################################

# CDC between Wishbone clock and Transceiver clocks
# These are slow control registers taken care of synched by FFs.
# Give it 1x destination clock. Could be 2x, but lets keep things tight.
set_max_delay -datapath_only -from               [get_clocks clk_sys] -to [get_clocks rtm_fpga_clk1]    $rtm_fpga_clk1_period
set_max_delay -datapath_only -from               [get_clocks clk_sys] -to [get_clocks rtm_fpga_clk2]    $rtm_fpga_clk2_period

set_max_delay -datapath_only -from               [get_clocks rtm_fpga_clk1]    -to [get_clocks clk_sys] $clk_sys_period
set_max_delay -datapath_only -from               [get_clocks rtm_fpga_clk2]    -to [get_clocks clk_sys] $clk_sys_period

# CDC between Clk Aux (trigger clock) and FS clocks
# These are using pulse_synchronizer2 which is a full feedback sync.
# Give it 1x destination clock.
set_max_delay -datapath_only -from               [get_clocks clk_aux] -to [get_clocks rtm_fpga_clk1]    $rtm_fpga_clk1_period
set_max_delay -datapath_only -from               [get_clocks clk_aux] -to [get_clocks rtm_fpga_clk2]    $rtm_fpga_clk2_period

# CDC between FS clocks and Clk Aux (trigger clock)
# These are using pulse_synchronizer2 which is a full feedback sync.
# Give it 1x destination clock.
set_max_delay -datapath_only -from               [get_clocks rtm_fpga_clk1] -to [get_clocks clk_aux]    $clk_aux_period
set_max_delay -datapath_only -from               [get_clocks rtm_fpga_clk2] -to [get_clocks clk_aux]    $clk_aux_period

#######################################################################
##                      Placement Constraints                        ##
#######################################################################
