target = "xilinx"
action = "synthesis"

syn_device = "xc7a200t"
syn_grade = "-1"
syn_package = "ffg1156"
syn_top = "dbe_bpm_dsp"
syn_project = "dbe_bpm_dsp"
syn_tool = "vivado"

files = ["project.vhd"];

machine_pkg = "uvx_130M"

modules = { "local" : [ "../../../../top/afc_v3/vivado/dbe_bpm_dsp_fmc130m_4ch_2_to_1_mux_ddr_2_3" ] };

