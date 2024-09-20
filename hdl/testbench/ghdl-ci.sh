#!/bin/sh

set -e

if ls ./*/ghdl/ 1> /dev/null 2>&1; then
	for tb in ./*/ghdl/; do
		echo "Testbench ${tb}"
		cd "$tb"
		hdlmake
		make clean
		make
		cd ../../
	done
fi
