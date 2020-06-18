action = "simulation"
target = "xilinx"
syn_device = "xc7a200t"
sim_tool = "modelsim"
top_module = "wb_orbit_intlk_tb"
sim_top = "wb_orbit_intlk_tb"

modules = {
    "local" : [
               "../../modules/wb_orbit_intlk/",
                "../../ip_cores/general-cores",
                "../../ip_cores/infra-cores",
                "../../ip_cores/dsp-cores",
    ]
}

files = [
    "wb_orbit_intlk_tb.v",
    "clk_rst.v",
]

include_dirs = [
    ".",
    "../../sim",
    "../../sim/regs"
    "../../ip_cores/general-cores/modules/wishbone/wb_lm32/src",
    "../../ip_cores/general-cores/modules/wishbone/wb_lm32/platform/generic",
    "../../ip_cores/general-cores/modules/wishbone/wb_spi_bidir",
    "../../ip_cores/general-cores/modules/wishbone/wb_spi"
]

vlog_opt = "+incdir+../../sim/regs +incdir+../../sim  +incdir+."
