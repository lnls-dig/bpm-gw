#################################################################
# KC705 
#################################################################

### IO constrainst ###
set_property IOSTANDARD LVCMOS25 [get_ports sys_rst_n]
set_property PULLUP true [get_ports sys_rst_n]
set_property LOC G25 [get_ports sys_rst_n]

set_property LOC IBUFDS_GTE2_X0Y1 [get_cells -hier -filter {name=~ */pcieclk_ibuf}]

### Timing constraints
create_clock -name sys_clk -period 10 [get_ports sys_clk_p]

set_clock_groups -asynchronous \
  -group [get_clocks -include_generated_clocks bpm_pcie_i/pcie_core_i/inst/inst/gt_top_i/pipe_wrapper_i/pipe_lane[0].gt_wrapper_i/gtx_channel.gtxe2_channel_i/TXOUTCLK] \
  -group [get_clocks -include_generated_clocks ddr_sys_clk_p]

set_false_path -from [get_ports sys_rst_n]
