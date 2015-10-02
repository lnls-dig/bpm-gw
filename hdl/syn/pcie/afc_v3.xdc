#################################################################
# KC705 
#################################################################

### IO constrainst ###
set_property IOSTANDARD LVCMOS25 [get_ports sys_rst_n]
set_property PULLUP true [get_ports sys_rst_n]
set_property PACKAGE_PIN AG26 [get_ports sys_rst_n]

set_property LOC IBUFDS_GTE2_X0Y3 [get_cells -hier -filter {name=~ */pcieclk_ibuf}]

set_property PACKAGE_PIN AK7 [get_ports ddr_sys_clk_p]
set_property IOSTANDARD DIFF_SSTL15 [get_ports ddr_sys_clk_p]                                                                                                                                                
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports ddr_sys_clk_p]

set_property PACKAGE_PIN AL7 [get_ports ddr_sys_clk_n]
set_property IOSTANDARD DIFF_SSTL15 [get_ports ddr_sys_clk_n]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports ddr_sys_clk_n]

#place DDR input PLL close input pins and DDR logic
set_property LOC PLLE2_ADV_X1Y1 [get_cells plle2_adv_inst]

### Timing constraints
create_clock -name pci_sys_clk -period 10 [get_ports pci_sys_clk_p]

create_clock -name ddr_sys_clk -period 8 [get_ports ddr_sys_clk_p]

set_clock_groups -asynchronous \
  -group [get_clocks -include_generated_clocks bpm_pcie_i/pcie_core_i/inst/inst/gt_top_i/pipe_wrapper_i/pipe_lane[0].gt_wrapper_i/gtp_channel.gtpe2_channel_i/TXOUTCLK] \
  -group [get_clocks -include_generated_clocks ddr_sys_clk]

set_false_path -from [get_ports sys_rst_n]

###### Bitstream settings ##################
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
