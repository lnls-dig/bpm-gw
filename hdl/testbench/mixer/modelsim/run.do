vsim -l output.log -t 1ps -L unisim work.mixer_tb -voptargs="+acc"
add wave sim:/mixer_tb/*
do wave.do
radix -hexadecimal
wave zoomfull
run -all
