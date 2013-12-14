vlog wb_acq_core_tb.v +incdir+"." +incdir+../../../../../sim +incdir+../../../../../sim/regs
-- make -f Makefile
-- output log file to file "output.log", set siulation resolution to "fs"
vsim -l output.log -t fs -L unisim work.wb_acq_core_tb -voptargs="+acc"
set StdArithNoWarnings 1
set NumericStdNoWarnings 1
-- do wave.do
do wave_compl.do
radix -hexadecimal
-- run 250us
run 5000us
wave zoomfull
radix -hexadecimal
