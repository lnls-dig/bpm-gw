#!/bin/bash

TOP_DIR=../..
DEFAULT_SYN_PATH=${TOP_DIR}/hdl/syn
EXPECTED_ARGS=1

# Test for parameter presence
: ${1?"Usage: $0 <bistream_name>"}

BITSTREAM=$1

#Search for bistream
BITSTREAM_LOC=$(find ${DEFAULT_SYN_PATH} -regextype posix-extended -iregex ".*${BITSTREAM}.*\.bit" -print)

BITSTREAM_NUM=$(echo -e "${BITSTREAM_LOC}" | wc -w)

if [ "${BITSTREAM_NUM}" -eq 0 ]; then
	echo -e "There are no bitstreams that matches the description"
	exit 1
fi

if [ "${BITSTREAM_NUM}" -gt 1 ]; then
	echo -e "There are "${BITSTREAM_NUM}" bitstreams that matches the description:"
	echo "${BITSTREAM_LOC}"
	echo "You must specify a more verbose name"
	exit 1
fi

# Write the commands to a temporary file

cat > .impact_batch << EOF
setMode -bscan
setCable -port auto
identify
assignFile -p 2 -file ${BITSTREAM_LOC}
program -p 2
closeCable
quit
EOF

impact -batch .impact_batch
rm .impact_batch
