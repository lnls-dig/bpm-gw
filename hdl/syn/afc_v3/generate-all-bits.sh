#!/bin/bash

for target in dbe_bpm2_bo_sirius \
    dbe_bpm2_sr_sirius \
    dbe_pbpm \
    dbe_bpm2_bo_sirius_with_dcc \
    dbe_bpm2_sr_sirius_with_dcc \
    dbe_pbpm_with_dcc; do
    TOP=$(pwd)
    cd ${target} && hdlmake makefile && make clean && ./build_bitstream_local.sh ; cd ${TOP};
done
