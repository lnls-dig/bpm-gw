files = [ "dbe_bpm_dsp.vhd",
          "sys_pll.vhd",
          "clk_gen.vhd",
          "dbe_bpm_dsp.ucf",
          "position_calc_core.ucf",
          "dbe_bpm_dsp.xcf" ];

modules = { "local" :
             ["../../..",
              "../../../ip_cores/pcie/ml605"
             ]
          };

