create_clock -period 8.000 -name sys_clk_p_i [get_ports sys_clk_p_i]


#// FPGA_CLK1_P
set_property IOSTANDARD DIFF_SSTL15 [get_ports sys_clk_p_i]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports sys_clk_p_i]
#// FPGA_CLK1_N
set_property PACKAGE_PIN AL7 [get_ports sys_clk_n_i]
set_property IOSTANDARD DIFF_SSTL15 [get_ports sys_clk_n_i]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports sys_clk_n_i]


#Signal
set_property PACKAGE_PIN AM9 [get_ports {trigger_i[0]}]
set_property IOSTANDARD LVCMOS15  [get_ports {trigger_i[0]}]

set_property PACKAGE_PIN AP11 [get_ports {trigger_i[1]}]
set_property IOSTANDARD LVCMOS15  [get_ports {trigger_i[1]}]

set_property PACKAGE_PIN AP10 [get_ports {trigger_i[2]}]
set_property IOSTANDARD LVCMOS15  [get_ports {trigger_i[2]}]

set_property PACKAGE_PIN AM11 [get_ports {trigger_i[3]}]
set_property IOSTANDARD LVCMOS15  [get_ports {trigger_i[3]}]

set_property PACKAGE_PIN AN8 [get_ports {trigger_i[4]}]
set_property IOSTANDARD LVCMOS15  [get_ports {trigger_i[4]}]

set_property PACKAGE_PIN AP8 [get_ports {trigger_i[5]}]
set_property IOSTANDARD LVCMOS15  [get_ports {trigger_i[5]}]

set_property PACKAGE_PIN AL8 [get_ports {trigger_i[6]}]
set_property IOSTANDARD LVCMOS15  [get_ports {trigger_i[6]}]

set_property PACKAGE_PIN AL9 [get_ports {trigger_i[7]}]
set_property IOSTANDARD LVCMOS15  [get_ports {trigger_i[7]}]

#Direction

# set_property PACKAGE_PIN AJ10 [get_ports {direction_o[0]}]
# set_property IOSTANDARD LVCMOS15  [get_ports {direction_o[0]}]

set_property PACKAGE_PIN AK11 [get_ports {direction_o[1]}]
set_property IOSTANDARD LVCMOS15  [get_ports {direction_o[1]}]

set_property PACKAGE_PIN AJ11 [get_ports {direction_o[2]}]
set_property IOSTANDARD LVCMOS15  [get_ports {direction_o[2]}]

set_property PACKAGE_PIN AL10 [get_ports {direction_o[3]}]
set_property IOSTANDARD LVCMOS15  [get_ports {direction_o[3]}]

set_property PACKAGE_PIN AM10 [get_ports {direction_o[4]}]
set_property IOSTANDARD LVCMOS15  [get_ports {direction_o[4]}]

set_property PACKAGE_PIN AN11 [get_ports {direction_o[5]}]
set_property IOSTANDARD LVCMOS15  [get_ports {direction_o[5]}]

set_property PACKAGE_PIN AN9 [get_ports {direction_o[6]}]
set_property IOSTANDARD LVCMOS15  [get_ports {direction_o[6]}]

set_property PACKAGE_PIN AP9 [get_ports {direction_o[7]}]
set_property IOSTANDARD LVCMOS15  [get_ports {direction_o[7]}]
