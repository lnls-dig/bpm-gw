#!/bin/sh

#TEST=sample_smoke_test0
TEST=tf64_pcie_axi

# compile all of the files
vlogcomp -work work -d SIMULATION -i . -i ../../sim/pcie --incremental -f board_vlog.f && \
vhpcomp -work work --incremental -f board.f && \
vlogcomp -work work $XILINX/verilog/src/glbl.v && \

# compile and link source files
fuse work.board work.glbl -L unisims_ver -L unimacro_ver -L unisim -L unimacro -L secureip -o tb_sim

# set BATCH_MODE=0 to run simulation in GUI mode
BATCH_MODE=0

if [ $BATCH_MODE == 1 ]; then

  # run the simulation in batch mode
  ./tb_sim -wdb wave_isim -tclbatch isim_cmd.tcl -testplusarg TESTNAME=$TEST

else

  # run the simulation in gui mode
  ./tb_sim -gui -view Test01.wcfg -wdb wave_isim -tclbatch isim_cmd.tcl -testplusarg TESTNAME=$TEST

fi
