#################################################################
# KC705 
#################################################################

### IO constrainst ###
set_property IOSTANDARD LVCMOS25 [get_ports sys_rst_n]
set_property PULLUP true [get_ports sys_rst_n]
set_property PACKAGE_PIN G25 [get_ports sys_rst_n]

set_property LOC IBUFDS_GTE2_X0Y1 [get_cells -hier -filter {name=~ */pcieclk_ibuf}]

set_property PACKAGE_PIN AD12 [get_ports ddr_sys_clk_p]
set_property IOSTANDARD DIFF_SSTL15 [get_ports ddr_sys_clk_p]
set_property VCCAUX_IO DONTCARE [get_ports ddr_sys_clk_p]                                                                                                                                            

set_property PACKAGE_PIN AD11 [get_ports ddr_sys_clk_n]
set_property IOSTANDARD DIFF_SSTL15 [get_ports ddr_sys_clk_n]
set_property VCCAUX_IO DONTCARE [get_ports ddr_sys_clk_n]

### Timing constraints
create_clock -name pci_sys_clk -period 10 [get_ports pci_sys_clk_p]

create_clock -name ddr_sys_clk -period 5 [get_ports ddr_sys_clk_p]

set_clock_groups -asynchronous \
  -group [get_clocks -include_generated_clocks bpm_pcie_i/pcie_core_i/inst/inst/gt_top_i/pipe_wrapper_i/pipe_lane[0].gt_wrapper_i/gtx_channel.gtxe2_channel_i/TXOUTCLK] \
  -group [get_clocks -include_generated_clocks ddr_sys_clk]

set_false_path -from [get_ports sys_rst_n]

###### Bitstream settings ##################
set_property BITSTREAM.CONFIG.BPI_SYNC_MODE Type2 [current_design]
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN div-2 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN Pullup [current_design]
set_property CONFIG_MODE BPI16 [current_design]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 2.5 [current_design]
