
vsim -novopt +TESTNAME=tf64_pcie_axi -t fs +notimingchecks -L work \
    -L unisims_ver -L secureip -L unimacro_ver work.board glbl

log -r /*

radix hex

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

#add signals to wave window
do wave.do

run -all
