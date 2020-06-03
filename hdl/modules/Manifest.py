files = [ "bpm_cores_pkg.vhd" ];

modules = { "local" : [
            "downconv",
            "hpf_adcinput",
            "input_gen",
            "fixed_dds",
            "machine",
            "sw_windowing",
            "position_calc",
            "wb_bpm_swap",
            "wb_position_calc",
         ] };
