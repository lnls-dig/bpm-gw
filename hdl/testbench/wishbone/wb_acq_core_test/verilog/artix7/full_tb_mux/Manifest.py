action = "simulation"
target = "xilinx"
syn_device = "xc7a200t"
sim_tool = "modelsim"
top_module = "wb_acq_core_tb.v"

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
                    "../../../../../../sim",
                    "../../../../../../sim/ddr_model",
#                    "../../../../../../ip_cores/pcie/7a200ffg1156/ddr_core_1_8/user_design/"]}
#                     "../../../../../../ip_cores/pcie/7a200ffg1156/ddr_core/user_design/"]}
                     "../../../../../../ip_cores/pcie/7a200ffg1156/ddr_core_2_3/user_design/"]}

files = ["wb_acq_core_tb.v", "ddr_core_wrapper.vhd", "defines.v", "timescale.v",
			"clk_rst.v", "../../../../../../sim/wishbone_test_master.v",
            "../../../../../../../../../../../opt/Xilinx/14.7/ISE_DS/ISE/verilog/src/glbl.v"]

include_dirs = ["../../../../../../sim", "../../../../../../sim/regs", "../../../../../../sim/ddr_model",
            "../../../../../../platform/artix7/ip_cores/axis_mux_2_to_1/hdl/verilog"]

vlog_opt = "+incdir+../../../../../../sim/regs +incdir+../../../../../../sim +incdir+../../../../../../sim/ddr_model +incdir+../../../../../../platform/artix7/ip_cores/axis_mux_2_to_1/hdl/verilog"
