#!/bin/bash

if [ ! $# -eq 1 ]
then
  echo "Wrong usage! $0 <SYN_PROJECT>"
  exit
fi

SYN_PROJECT=$1
AUX_FILES_PATH=../../..
SVF_TO_NSVF_BIN=svf_to_nsvf-linux-x86.bin

cd ${SYN_PROJECT}.runs/impl_1/
awk -v var=$SYN_PROJECT '{gsub(/SYN_PROJECT/,var); print}' \
  ${AUX_FILES_PATH}/bit_to_mcs_to_svf.cmd > bit_to_mcs_to_svf_${SYN_PROJECT}.cmd

# .bit to .svf
vivado -mode batch -source bit_to_mcs_to_svf_${SYN_PROJECT}.cmd

# prepends .svf with afc-scansta.svf
cat ${AUX_FILES_PATH}/afc-scansta.svf ${SYN_PROJECT}.svf > \
  ${SYN_PROJECT}_prepended.svf

# .svf to .nsvf
if command -v ${SVF_TO_NSVF_BIN} &> /dev/null
then
  ${SVF_TO_NSVF_BIN} ${SYN_PROJECT}_prepended.svf
else
  echo "${SVF_TO_NSVF_BIN} not found on PATH, .nsvf not generated"
fi
