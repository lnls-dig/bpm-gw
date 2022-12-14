vsim -l output.log -t 1ps -L unisim work.fixed_dds_tb -voptargs="+acc"
add wave sim:/fixed_dds_tb/*
do wave.do
radix -hexadecimal
wave zoomfull
run -all
