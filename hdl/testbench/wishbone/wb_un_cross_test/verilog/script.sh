 #!/bin/bash
# export XILINX=/opt/Xilinx/13.4/ISE_DS

 hdlmake2 --make-isim
 make
 make fuse TOP_MODULE=wb_bpm_swap_tb
 ./isim_proj -tclbatch isim_cmd -gui#-view wave.wcfg -tclbatch isim_cmd -gui

# export XILINX=/opt/Xilinx/13.4/ISE_DS/ISE
