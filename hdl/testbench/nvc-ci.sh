#!/bin/sh

set -e

if ls ./*/nvc/ 1> /dev/null 2>&1; then
	for tb in ./*/nvc/; do
		echo "Testbench ${tb}"
		cd "$tb"
		hdlmake
		make clean
		make
		cd ../../
	done
fi
