#######################################################################
##                          Clocks                                   ##
#######################################################################

# RTM FPGA 1 clock. 156.25 MHz
create_clock -period 6.400 -name rtm_fpga_clk1 [get_ports rtm_fpga_clk1_p_i]
set rtm_fpga_clk1_period                       [get_property PERIOD [get_clocks rtm_fpga_clk1]]

# RTM FPGA 2 clock. 156.25 MHz
create_clock -period 6.400 -name rtm_fpga_clk2 [get_ports rtm_fpga_clk2_p_i]
set rtm_fpga_clk2_period                       [get_property PERIOD [get_clocks rtm_fpga_clk2]]

# DCC GT clocks. On 7series we need to manually add them as per AR:
# https://www.xilinx.com/support/answers/64351.html
# CAUTION: We are groupin clocks from all DCCs (FMC, P2P and FP2 P2P) into a single variable.
# If they all have the same clock constraint it's fine, but if they are different
# there's a problem.

#################################
# TXOUTCLK
#################################

create_clock -period $rtm_fpga_clk1_period                     [get_pins -filter {REF_PIN_NAME =~ *TXOUTCLK} -of_objects \
                                                                [get_cells -hier -filter {NAME =~ *cmp_fofb_ctrl_wrapper_0*GT_IF/gtp7_if_gen[0]*gtpe2_i*}]]
create_clock -period $rtm_fpga_clk1_period                     [get_pins -filter {REF_PIN_NAME =~ *TXOUTCLK} -of_objects \
                                                                [get_cells -hier -filter {NAME =~ *cmp_fofb_ctrl_wrapper_0*GT_IF/gtp7_if_gen[1]*gtpe2_i*}]]
create_clock -period $rtm_fpga_clk1_period                     [get_pins -filter {REF_PIN_NAME =~ *TXOUTCLK} -of_objects \
                                                                [get_cells -hier -filter {NAME =~ *cmp_fofb_ctrl_wrapper_0*GT_IF/gtp7_if_gen[2]*gtpe2_i*}]]
create_clock -period $rtm_fpga_clk1_period                     [get_pins -filter {REF_PIN_NAME =~ *TXOUTCLK} -of_objects \
                                                                [get_cells -hier -filter {NAME =~ *cmp_fofb_ctrl_wrapper_0*GT_IF/gtp7_if_gen[3]*gtpe2_i*}]]
create_clock -period $rtm_fpga_clk1_period                     [get_pins -filter {REF_PIN_NAME =~ *TXOUTCLK} -of_objects \
                                                                [get_cells -hier -filter {NAME =~ *cmp_fofb_ctrl_wrapper_0*GT_IF/gtp7_if_gen[4]*gtpe2_i*}]]
create_clock -period $rtm_fpga_clk1_period                     [get_pins -filter {REF_PIN_NAME =~ *TXOUTCLK} -of_objects \
                                                                [get_cells -hier -filter {NAME =~ *cmp_fofb_ctrl_wrapper_0*GT_IF/gtp7_if_gen[5]*gtpe2_i*}]]
create_clock -period $rtm_fpga_clk1_period                     [get_pins -filter {REF_PIN_NAME =~ *TXOUTCLK} -of_objects \
                                                                [get_cells -hier -filter {NAME =~ *cmp_fofb_ctrl_wrapper_0*GT_IF/gtp7_if_gen[6]*gtpe2_i*}]]
create_clock -period $rtm_fpga_clk1_period                     [get_pins -filter {REF_PIN_NAME =~ *TXOUTCLK} -of_objects \
                                                                [get_cells -hier -filter {NAME =~ *cmp_fofb_ctrl_wrapper_0*GT_IF/gtp7_if_gen[7]*gtpe2_i*}]]

set gt_rtm_txoutclk_pins                                          [get_pins -filter {REF_PIN_NAME =~ *TXOUTCLK} -of_objects \
                                                                [get_cells -hier -filter {NAME =~ *cmp_fofb_ctrl_wrapper_0*GT_IF*gtpe2_i*}]]
set gt_rtm_txoutclk_clocks                                        [get_clocks -of_objects $gt_rtm_txoutclk_pins]

#################################
# TXOUTCLKFABRIC
#################################

create_clock -period $rtm_fpga_clk1_period                     [get_pins -filter {REF_PIN_NAME =~ *TXOUTCLKFABRIC} -of_objects \
                                                                [get_cells -hier -filter {NAME =~ *cmp_fofb_ctrl_wrapper_0*GT_IF/gtp7_if_gen[0]*gtpe2_i*}]]
create_clock -period $rtm_fpga_clk1_period                     [get_pins -filter {REF_PIN_NAME =~ *TXOUTCLKFABRIC} -of_objects \
                                                                [get_cells -hier -filter {NAME =~ *cmp_fofb_ctrl_wrapper_0*GT_IF/gtp7_if_gen[1]*gtpe2_i*}]]
create_clock -period $rtm_fpga_clk1_period                     [get_pins -filter {REF_PIN_NAME =~ *TXOUTCLKFABRIC} -of_objects \
                                                                [get_cells -hier -filter {NAME =~ *cmp_fofb_ctrl_wrapper_0*GT_IF/gtp7_if_gen[2]*gtpe2_i*}]]
create_clock -period $rtm_fpga_clk1_period                     [get_pins -filter {REF_PIN_NAME =~ *TXOUTCLKFABRIC} -of_objects \
                                                                [get_cells -hier -filter {NAME =~ *cmp_fofb_ctrl_wrapper_0*GT_IF/gtp7_if_gen[3]*gtpe2_i*}]]
create_clock -period $rtm_fpga_clk1_period                     [get_pins -filter {REF_PIN_NAME =~ *TXOUTCLKFABRIC} -of_objects \
                                                                [get_cells -hier -filter {NAME =~ *cmp_fofb_ctrl_wrapper_0*GT_IF/gtp7_if_gen[4]*gtpe2_i*}]]
create_clock -period $rtm_fpga_clk1_period                     [get_pins -filter {REF_PIN_NAME =~ *TXOUTCLKFABRIC} -of_objects \
                                                                [get_cells -hier -filter {NAME =~ *cmp_fofb_ctrl_wrapper_0*GT_IF/gtp7_if_gen[5]*gtpe2_i*}]]
create_clock -period $rtm_fpga_clk1_period                     [get_pins -filter {REF_PIN_NAME =~ *TXOUTCLKFABRIC} -of_objects \
                                                                [get_cells -hier -filter {NAME =~ *cmp_fofb_ctrl_wrapper_0*GT_IF/gtp7_if_gen[6]*gtpe2_i*}]]
create_clock -period $rtm_fpga_clk1_period                     [get_pins -filter {REF_PIN_NAME =~ *TXOUTCLKFABRIC} -of_objects \
                                                                [get_cells -hier -filter {NAME =~ *cmp_fofb_ctrl_wrapper_0*GT_IF/gtp7_if_gen[7]*gtpe2_i*}]]

set gt_rtm_txoutclkfabric_pins                                    [get_pins -filter {REF_PIN_NAME =~ *TXOUTCLKFABRIC} -of_objects \
                                                                [get_cells -hier -filter {NAME =~ *cmp_fofb_ctrl_wrapper_0*GT_IF*gtpe2_i*}]]
set gt_rtm_txoutclkfabric_clocks                                  [get_clocks -of_objects $gt_rtm_txoutclkfabric_pins]

#################################
# RXOUTCLK
#################################

create_clock -period $rtm_fpga_clk1_period                     [get_pins -filter {REF_PIN_NAME =~ *RXOUTCLK} -of_objects \
                                                                [get_cells -hier -filter {NAME =~ *cmp_fofb_ctrl_wrapper_0*GT_IF/gtp7_if_gen[0]*gtpe2_i*}]]
create_clock -period $rtm_fpga_clk1_period                     [get_pins -filter {REF_PIN_NAME =~ *RXOUTCLK} -of_objects \
                                                                [get_cells -hier -filter {NAME =~ *cmp_fofb_ctrl_wrapper_0*GT_IF/gtp7_if_gen[1]*gtpe2_i*}]]
create_clock -period $rtm_fpga_clk1_period                     [get_pins -filter {REF_PIN_NAME =~ *RXOUTCLK} -of_objects \
                                                                [get_cells -hier -filter {NAME =~ *cmp_fofb_ctrl_wrapper_0*GT_IF/gtp7_if_gen[2]*gtpe2_i*}]]
create_clock -period $rtm_fpga_clk1_period                     [get_pins -filter {REF_PIN_NAME =~ *RXOUTCLK} -of_objects \
                                                                [get_cells -hier -filter {NAME =~ *cmp_fofb_ctrl_wrapper_0*GT_IF/gtp7_if_gen[3]*gtpe2_i*}]]
create_clock -period $rtm_fpga_clk1_period                     [get_pins -filter {REF_PIN_NAME =~ *RXOUTCLK} -of_objects \
                                                                [get_cells -hier -filter {NAME =~ *cmp_fofb_ctrl_wrapper_0*GT_IF/gtp7_if_gen[4]*gtpe2_i*}]]
create_clock -period $rtm_fpga_clk1_period                     [get_pins -filter {REF_PIN_NAME =~ *RXOUTCLK} -of_objects \
                                                                [get_cells -hier -filter {NAME =~ *cmp_fofb_ctrl_wrapper_0*GT_IF/gtp7_if_gen[5]*gtpe2_i*}]]
create_clock -period $rtm_fpga_clk1_period                     [get_pins -filter {REF_PIN_NAME =~ *RXOUTCLK} -of_objects \
                                                                [get_cells -hier -filter {NAME =~ *cmp_fofb_ctrl_wrapper_0*GT_IF/gtp7_if_gen[6]*gtpe2_i*}]]
create_clock -period $rtm_fpga_clk1_period                     [get_pins -filter {REF_PIN_NAME =~ *RXOUTCLK} -of_objects \
                                                                [get_cells -hier -filter {NAME =~ *cmp_fofb_ctrl_wrapper_0*GT_IF/gtp7_if_gen[7]*gtpe2_i*}]]

set gt_rtm_rxoutclkfabric_pins                                    [get_pins -filter {REF_PIN_NAME =~ *RXOUTCLK} -of_objects \
                                                                [get_cells -hier -filter {NAME =~ *cmp_fofb_ctrl_wrapper_0*GT_IF*gtpe2_i*}]]
set gt_rtm_rxoutclkfabric_clocks                                  [get_clocks -of_objects $gt_rtm_rxoutclkfabric_pins]

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

set_max_delay -datapath_only -from               [get_clocks clk_sys] -to [get_clocks $gt_rtm_txoutclk_clocks]    $rtm_fpga_clk1_period
set_max_delay -datapath_only -from               [get_clocks $gt_rtm_txoutclk_clocks]    -to [get_clocks clk_sys] $clk_sys_period

# CDC between Clk Aux (trigger clock) and FS clocks
# These are using pulse_synchronizer2 which is a full feedback sync.
# Give it 1x destination clock.
set_max_delay -datapath_only -from               [get_clocks clk_aux] -to [get_clocks rtm_fpga_clk1]    $rtm_fpga_clk1_period
set_max_delay -datapath_only -from               [get_clocks clk_aux] -to [get_clocks rtm_fpga_clk2]    $rtm_fpga_clk2_period

set_max_delay -datapath_only -from               [get_clocks clk_aux] -to [get_clocks $gt_rtm_txoutclk_clocks]    $rtm_fpga_clk1_period
set_max_delay -datapath_only -from               [get_clocks $gt_rtm_txoutclk_clocks] -to [get_clocks clk_aux]    $clk_aux_period

# CDC between FS clocks and Clk Aux (trigger clock)
# These are using pulse_synchronizer2 which is a full feedback sync.
# Give it 1x destination clock.
set_max_delay -datapath_only -from               [get_clocks rtm_fpga_clk1] -to [get_clocks clk_aux]    $clk_aux_period
set_max_delay -datapath_only -from               [get_clocks rtm_fpga_clk2] -to [get_clocks clk_aux]    $clk_aux_period

# CDC between DCC GT and clk_pll_i (DDR core clock)
set_max_delay -datapath_only -from               [get_clocks clk_pll_i] -to [get_clocks $gt_rtm_txoutclk_clocks]    $afc_fp2_clk1_period

# CDC between clk_pll_i (DDR core clock) and DCC GT
set_max_delay -datapath_only -from               [get_clocks $gt_rtm_txoutclk_clocks] -to [get_clocks clk_pll_i]    $clk_pll_ddr_period
