#######################################################################
##                      P2P RX/TX 12-15                              ##
#######################################################################

# RX_12

# RX213_0_N MGTPRXN0_213 AM18
# RX213_0_P MGTPRXP0_213 AL18
set_property PACKAGE_PIN AM18 [get_ports p2p_gt_rx_n_i[0]]
set_property PACKAGE_PIN AL18 [get_ports p2p_gt_rx_p_i[0]]

# RX_13

# RX213_2_N MGTPRXN2_213 AM20
# RX213_2_P MGTPRXP2_213 AL20
set_property PACKAGE_PIN AM20 [get_ports p2p_gt_rx_n_i[1]]
set_property PACKAGE_PIN AL20 [get_ports p2p_gt_rx_p_i[1]]

# RX_14

# RX213_1_N MGTPRXN1_213 AK19
# RX213_1_P MGTPRXP1_213 AJ19
set_property PACKAGE_PIN AK19 [get_ports p2p_gt_rx_n_i[2]]
set_property PACKAGE_PIN AJ19 [get_ports p2p_gt_rx_p_i[2]]

# RX_15

# RX213_3_N MGTPRXN3_213 AK21
# RX213_3_P MGTPRXP3_213 AJ21
set_property PACKAGE_PIN AK21 [get_ports p2p_gt_rx_n_i[3]]
set_property PACKAGE_PIN AJ21 [get_ports p2p_gt_rx_p_i[3]]

# TX_12

# TX213_0_N MGTPTXN0_213 AP19
# TX213_0_P MGTPTXP0_213 AN19
set_property PACKAGE_PIN AP19 [get_ports p2p_gt_tx_n_o[0]]
set_property PACKAGE_PIN AN19 [get_ports p2p_gt_tx_p_o[0]]

# TX_13

# TX213_2_N MGTPTXN2_213 AM22
# TX213_2_P MGTPTXP2_213 AL22
set_property PACKAGE_PIN AM22 [get_ports p2p_gt_tx_n_o[1]]
set_property PACKAGE_PIN AL22 [get_ports p2p_gt_tx_p_o[1]]

# TX_14

# TX213_1_N MGTPTXN1_213 AP21
# TX213_1_P MGTPTXP1_213 AN21
set_property PACKAGE_PIN AP21 [get_ports p2p_gt_tx_n_o[2]]
set_property PACKAGE_PIN AN21 [get_ports p2p_gt_tx_p_o[2]]

# TX_15

# TX213_3_N MGTPTXN3_213 AP23
# TX213_3_P MGTPTXP3_213 AN23
set_property PACKAGE_PIN AP23 [get_ports p2p_gt_tx_n_o[3]]
set_property PACKAGE_PIN AN23 [get_ports p2p_gt_tx_p_o[3]]

#######################################################################
##               Fat Pipe 2 (used as P2P RX/TX 8-12)                 ##
#######################################################################

# RX_8

# RX113_0_N MGTPRXN0_113 AK17
# RX113_0_P MGTPRXP0_113 AJ17
set_property PACKAGE_PIN AK17 [get_ports p2p_gt_rx_n_i[4]]
set_property PACKAGE_PIN AJ17 [get_ports p2p_gt_rx_p_i[4]]

# RX_9

# RX113_1_N MGTPRXN1_113 AM16
# RX113_1_P MGTPRXP1_113 AL16
set_property PACKAGE_PIN AM16 [get_ports p2p_gt_rx_n_i[5]]
set_property PACKAGE_PIN AL16 [get_ports p2p_gt_rx_p_i[5]]

# RX_10

# RX113_2_N MGTPRXN2_113 AK15
# RX113_2_P MGTPRXP2_113 AJ15
set_property PACKAGE_PIN AK15 [get_ports p2p_gt_rx_n_i[6]]
set_property PACKAGE_PIN AJ15 [get_ports p2p_gt_rx_p_i[6]]

# RX_11

# RX113_3_N MGTPRXN3_113 AK13
# RX113_3_P MGTPRXP3_113 AJ13
set_property PACKAGE_PIN AK13 [get_ports p2p_gt_rx_n_i[7]]
set_property PACKAGE_PIN AJ13 [get_ports p2p_gt_rx_p_i[7]]

# TX_8

# TX113_0_N MGTPTXN0_113 AP17
# TX113_0_P MGTPTXP0_113 AN17
set_property PACKAGE_PIN AP17 [get_ports p2p_gt_tx_n_o[4]]
set_property PACKAGE_PIN AN17 [get_ports p2p_gt_tx_p_o[4]]

# TX_9

# TX113_1_N MGTPTXN1_113 AP15
# TX113_1_P MGTPTXP1_113 AN15
set_property PACKAGE_PIN AP15 [get_ports p2p_gt_tx_n_o[5]]
set_property PACKAGE_PIN AN15 [get_ports p2p_gt_tx_p_o[5]]

# TX_10

# TX113_2_N MGTPTXN2_113 AM14
# TX113_2_P MGTPTXP2_113 AL14
set_property PACKAGE_PIN AM14 [get_ports p2p_gt_tx_n_o[6]]
set_property PACKAGE_PIN AL14 [get_ports p2p_gt_tx_p_o[6]]

# TX_11

# TX113_3_N MGTPTXN3_113 AP13
# TX113_3_P MGTPTXP3_113 AN13
set_property PACKAGE_PIN AP13 [get_ports p2p_gt_tx_n_o[7]]
set_property PACKAGE_PIN AN13 [get_ports p2p_gt_tx_p_o[7]]

#######################################################################
##                          Clocks                                   ##
#######################################################################

# FP2_CLK1 clock. 156.25 MHz
create_clock -period 6.400 -name afc_fp2_clk1 [get_ports afc_fp2_clk1_p_i]
set afc_fp2_clk1_period                       [get_property PERIOD [get_clocks afc_fp2_clk1]]

# DCC GT clocks. On 7series we need to manually add them as per AR:
# https://www.xilinx.com/support/answers/64351.html
# CAUTION: We are groupin clocks from all DCCs (FMC, P2P and FP2 P2P) into a single variable.
# If they all have the same clock constraint it's fine, but if they are different
# there's a problem.

#################################
# TXOUTCLK
#################################

create_clock -period $afc_fp2_clk1_period                     [get_pins -filter {REF_PIN_NAME =~ *TXOUTCLK} -of_objects \
                                                                [get_cells -hier -filter {NAME =~ *cmp_fofb_ctrl_wrapper_1*GT_IF/gtp7_if_gen[0]*gtpe2_i*}]]
create_clock -period $afc_fp2_clk1_period                     [get_pins -filter {REF_PIN_NAME =~ *TXOUTCLK} -of_objects \
                                                                [get_cells -hier -filter {NAME =~ *cmp_fofb_ctrl_wrapper_1*GT_IF/gtp7_if_gen[1]*gtpe2_i*}]]
create_clock -period $afc_fp2_clk1_period                     [get_pins -filter {REF_PIN_NAME =~ *TXOUTCLK} -of_objects \
                                                                [get_cells -hier -filter {NAME =~ *cmp_fofb_ctrl_wrapper_1*GT_IF/gtp7_if_gen[2]*gtpe2_i*}]]
create_clock -period $afc_fp2_clk1_period                     [get_pins -filter {REF_PIN_NAME =~ *TXOUTCLK} -of_objects \
                                                                [get_cells -hier -filter {NAME =~ *cmp_fofb_ctrl_wrapper_1*GT_IF/gtp7_if_gen[3]*gtpe2_i*}]]
create_clock -period $afc_fp2_clk1_period                     [get_pins -filter {REF_PIN_NAME =~ *TXOUTCLK} -of_objects \
                                                                [get_cells -hier -filter {NAME =~ *cmp_fofb_ctrl_wrapper_1*GT_IF/gtp7_if_gen[4]*gtpe2_i*}]]
create_clock -period $afc_fp2_clk1_period                     [get_pins -filter {REF_PIN_NAME =~ *TXOUTCLK} -of_objects \
                                                                [get_cells -hier -filter {NAME =~ *cmp_fofb_ctrl_wrapper_1*GT_IF/gtp7_if_gen[5]*gtpe2_i*}]]
create_clock -period $afc_fp2_clk1_period                     [get_pins -filter {REF_PIN_NAME =~ *TXOUTCLK} -of_objects \
                                                                [get_cells -hier -filter {NAME =~ *cmp_fofb_ctrl_wrapper_1*GT_IF/gtp7_if_gen[6]*gtpe2_i*}]]
create_clock -period $afc_fp2_clk1_period                     [get_pins -filter {REF_PIN_NAME =~ *TXOUTCLK} -of_objects \
                                                                [get_cells -hier -filter {NAME =~ *cmp_fofb_ctrl_wrapper_1*GT_IF/gtp7_if_gen[7]*gtpe2_i*}]]

set gt_p2p_txoutclk_pins                                          [get_pins -filter {REF_PIN_NAME =~ *TXOUTCLK} -of_objects \
                                                                [get_cells -hier -filter {NAME =~ *cmp_fofb_ctrl_wrapper_1*GT_IF*gtpe2_i*}]]
set gt_p2p_txoutclk_clocks                                        [get_clocks -of_objects $gt_p2p_txoutclk_pins]

#################################
# TXOUTCLKFABRIC
#################################

create_clock -period $afc_fp2_clk1_period                     [get_pins -filter {REF_PIN_NAME =~ *TXOUTCLKFABRIC} -of_objects \
                                                                [get_cells -hier -filter {NAME =~ *cmp_fofb_ctrl_wrapper_1*GT_IF/gtp7_if_gen[0]*gtpe2_i*}]]
create_clock -period $afc_fp2_clk1_period                     [get_pins -filter {REF_PIN_NAME =~ *TXOUTCLKFABRIC} -of_objects \
                                                                [get_cells -hier -filter {NAME =~ *cmp_fofb_ctrl_wrapper_1*GT_IF/gtp7_if_gen[1]*gtpe2_i*}]]
create_clock -period $afc_fp2_clk1_period                     [get_pins -filter {REF_PIN_NAME =~ *TXOUTCLKFABRIC} -of_objects \
                                                                [get_cells -hier -filter {NAME =~ *cmp_fofb_ctrl_wrapper_1*GT_IF/gtp7_if_gen[2]*gtpe2_i*}]]
create_clock -period $afc_fp2_clk1_period                     [get_pins -filter {REF_PIN_NAME =~ *TXOUTCLKFABRIC} -of_objects \
                                                                [get_cells -hier -filter {NAME =~ *cmp_fofb_ctrl_wrapper_1*GT_IF/gtp7_if_gen[3]*gtpe2_i*}]]
create_clock -period $afc_fp2_clk1_period                     [get_pins -filter {REF_PIN_NAME =~ *TXOUTCLKFABRIC} -of_objects \
                                                                [get_cells -hier -filter {NAME =~ *cmp_fofb_ctrl_wrapper_1*GT_IF/gtp7_if_gen[4]*gtpe2_i*}]]
create_clock -period $afc_fp2_clk1_period                     [get_pins -filter {REF_PIN_NAME =~ *TXOUTCLKFABRIC} -of_objects \
                                                                [get_cells -hier -filter {NAME =~ *cmp_fofb_ctrl_wrapper_1*GT_IF/gtp7_if_gen[5]*gtpe2_i*}]]
create_clock -period $afc_fp2_clk1_period                     [get_pins -filter {REF_PIN_NAME =~ *TXOUTCLKFABRIC} -of_objects \
                                                                [get_cells -hier -filter {NAME =~ *cmp_fofb_ctrl_wrapper_1*GT_IF/gtp7_if_gen[6]*gtpe2_i*}]]
create_clock -period $afc_fp2_clk1_period                     [get_pins -filter {REF_PIN_NAME =~ *TXOUTCLKFABRIC} -of_objects \
                                                                [get_cells -hier -filter {NAME =~ *cmp_fofb_ctrl_wrapper_1*GT_IF/gtp7_if_gen[7]*gtpe2_i*}]]

set gt_p2p_txoutclkfabric_pins                                    [get_pins -filter {REF_PIN_NAME =~ *TXOUTCLKFABRIC} -of_objects \
                                                                [get_cells -hier -filter {NAME =~ *cmp_fofb_ctrl_wrapper_1*GT_IF*gtpe2_i*}]]
set gt_p2p_txoutclkfabric_clocks                                  [get_clocks -of_objects $gt_p2p_txoutclkfabric_pins]

#################################
# RXOUTCLK
#################################

create_clock -period $afc_fp2_clk1_period                     [get_pins -filter {REF_PIN_NAME =~ *RXOUTCLK} -of_objects \
                                                                [get_cells -hier -filter {NAME =~ *cmp_fofb_ctrl_wrapper_1*GT_IF/gtp7_if_gen[0]*gtpe2_i*}]]
create_clock -period $afc_fp2_clk1_period                     [get_pins -filter {REF_PIN_NAME =~ *RXOUTCLK} -of_objects \
                                                                [get_cells -hier -filter {NAME =~ *cmp_fofb_ctrl_wrapper_1*GT_IF/gtp7_if_gen[1]*gtpe2_i*}]]
create_clock -period $afc_fp2_clk1_period                     [get_pins -filter {REF_PIN_NAME =~ *RXOUTCLK} -of_objects \
                                                                [get_cells -hier -filter {NAME =~ *cmp_fofb_ctrl_wrapper_1*GT_IF/gtp7_if_gen[2]*gtpe2_i*}]]
create_clock -period $afc_fp2_clk1_period                     [get_pins -filter {REF_PIN_NAME =~ *RXOUTCLK} -of_objects \
                                                                [get_cells -hier -filter {NAME =~ *cmp_fofb_ctrl_wrapper_1*GT_IF/gtp7_if_gen[3]*gtpe2_i*}]]
create_clock -period $afc_fp2_clk1_period                     [get_pins -filter {REF_PIN_NAME =~ *RXOUTCLK} -of_objects \
                                                                [get_cells -hier -filter {NAME =~ *cmp_fofb_ctrl_wrapper_1*GT_IF/gtp7_if_gen[4]*gtpe2_i*}]]
create_clock -period $afc_fp2_clk1_period                     [get_pins -filter {REF_PIN_NAME =~ *RXOUTCLK} -of_objects \
                                                                [get_cells -hier -filter {NAME =~ *cmp_fofb_ctrl_wrapper_1*GT_IF/gtp7_if_gen[5]*gtpe2_i*}]]
create_clock -period $afc_fp2_clk1_period                     [get_pins -filter {REF_PIN_NAME =~ *RXOUTCLK} -of_objects \
                                                                [get_cells -hier -filter {NAME =~ *cmp_fofb_ctrl_wrapper_1*GT_IF/gtp7_if_gen[6]*gtpe2_i*}]]
create_clock -period $afc_fp2_clk1_period                     [get_pins -filter {REF_PIN_NAME =~ *RXOUTCLK} -of_objects \
                                                                [get_cells -hier -filter {NAME =~ *cmp_fofb_ctrl_wrapper_1*GT_IF/gtp7_if_gen[7]*gtpe2_i*}]]

set gt_p2p_rxoutclkfabric_pins                                    [get_pins -filter {REF_PIN_NAME =~ *RXOUTCLK} -of_objects \
                                                                [get_cells -hier -filter {NAME =~ *cmp_fofb_ctrl_wrapper_1*GT_IF*gtpe2_i*}]]
set gt_p2p_rxoutclkfabric_clocks                                  [get_clocks -of_objects $gt_p2p_rxoutclkfabric_pins]

#######################################################################
##                              CDC                                  ##
#######################################################################

# CDC between Wishbone clock and Transceiver clocks
# These are slow control registers taken care of synched by FFs.
# Give it 1x destination clock. Could be 2x, but lets keep things tight.
set_max_delay -datapath_only -from               [get_clocks clk_sys] -to [get_clocks afc_fp2_clk1]    $afc_fp2_clk1_period
set_max_delay -datapath_only -from               [get_clocks afc_fp2_clk1]    -to [get_clocks clk_sys] $clk_sys_period

set_max_delay -datapath_only -from               [get_clocks clk_sys] -to [get_clocks $gt_p2p_txoutclk_clocks]    $afc_fp2_clk1_period
set_max_delay -datapath_only -from               [get_clocks $gt_p2p_txoutclk_clocks]    -to [get_clocks clk_sys] $clk_sys_period

# CDC between Clk Aux (trigger clock) and FS clocks
# These are using pulse_synchronizer2 which is a full feedback sync.
# Give it 1x destination clock.
set_max_delay -datapath_only -from               [get_clocks clk_aux] -to [get_clocks afc_fp2_clk1]    $afc_fp2_clk1_period

set_max_delay -datapath_only -from               [get_clocks clk_aux] -to [get_clocks $gt_p2p_txoutclk_clocks]    $afc_fp2_clk1_period
set_max_delay -datapath_only -from               [get_clocks $gt_p2p_txoutclk_clocks] -to [get_clocks clk_aux]    $clk_aux_period

# CDC between FS clocks and Clk Aux (trigger clock)
# These are using pulse_synchronizer2 which is a full feedback sync.
# Give it 1x destination clock.
set_max_delay -datapath_only -from               [get_clocks afc_fp2_clk1] -to [get_clocks clk_aux]    $clk_aux_period

# CDC between DCC GT and clk_pll_i (DDR core clock)
set_max_delay -datapath_only -from               [get_clocks clk_pll_i] -to [get_clocks $gt_p2p_txoutclk_clocks]    $afc_fp2_clk1_period

# CDC between clk_pll_i (DDR core clock) and DCC GT
set_max_delay -datapath_only -from               [get_clocks $gt_p2p_txoutclk_clocks] -to [get_clocks clk_pll_i]    $clk_pll_ddr_period
