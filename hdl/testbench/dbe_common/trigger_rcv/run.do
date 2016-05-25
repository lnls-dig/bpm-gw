vsim -l output.log -t 1ps -L unisim work.trigger_rcv_tb -voptargs="+acc"
assertion action -cond fail -exec exit
add wave sim:/trigger_rcv_tb/*

run 5000ns
