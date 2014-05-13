target = "xilinx"
action = "synthesis"

syn_device = "xc7a200t"
syn_grade = "-1"
syn_package = "ffg1156"
syn_top = "dbe_bpm_dsp"
syn_project = "dbe_bpm_dsp.xise"
syn_tool = "ise"

modules = { "local" : [ "../../../top/afc_v1/dbe_bpm_dsp_fmc130m_4ch" ] };
