#!/bin/bash

for target in dbe_bpm2_bo_sirius dbe_bpm2_sr_sirius dbe_bpm2_sr_uvx dbe_pbpm; do
    TOP=$(pwd)
    cd ${target} && make clean && ./build_bitstream_local.sh ; cd ${TOP};
done
