#!/bin/bash

TOP=$(pwd)

TARGETS=()
TARGETS+=("dbe_bpm2_bo_sirius")
TARGETS+=("dbe_bpm2_sr_sirius")
TARGETS+=("dbe_bpm2_bo_sirius_with_dcc")
TARGETS+=("dbe_bpm2_sr_sirius_with_dcc")
TARGETS+=("dbe_pbpm")
TARGETS+=("dbe_pbpm_with_dcc")

for target in "${TARGETS[@]}"; do
  cd ${target} &&
  if [ -f "Makefile" ]; then
    make clean;
  fi &&
  ./build_bitstream_local.sh;

  cd ${TOP};
done
