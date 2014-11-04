action = "simulation"
target = "xilinx"
syn_device = "xc7a200t"

modules = {"local" : [
                    "../../../../../../modules/dbe_wishbone",
                    "../../../../../../modules/dbe_common",
                    "../../../../../../modules/rffe_top",
                    "../../../../../../modules/fabric",
                    "../../../../../../modules/fmc_adc_common",
                    "../../../../../../modules/pcie",
                    "../../../../../../ip_cores/general-cores",
                    "../../../../../../ip_cores/etherbone-core",
#                    "../../../../../../platform/virtex6/chipscope",
#                    "../../../../../../platform/virtex6/ip_cores",
                    "../../../../../../platform",
                    "../../../../../../sim/ddr_model",
#                    "../../../../../../ip_cores/pcie/7a200ffg1156/ddr_core_1_8/user_design/"]}
                     "../../../../../../ip_cores/pcie/7a200ffg1156/ddr_core/user_design/"]}

files = ["wb_acq_core_tb.v", "ddr_core_wrapper.vhd", "defines.v", "timescale.v",
			"clk_rst.v", "../../../../../../../../../../../opt/Xilinx/14.6/ISE_DS/ISE/verilog/src/glbl.v"]

vlog_opt = "+incdir+../../../../../../sim/regs +incdir+../../../../../../sim +incdir+../../../../../../sim/ddr_model +incdir+../../../../../../platform/artix7/ip_cores/axis_mux_2_to_1/hdl/verilog"
