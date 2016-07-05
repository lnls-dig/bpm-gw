#!/bin/bash

# Exit on error
set -e
# Check for uninitialized variables
set -u

./build_synthesis_sdb.sh

COMMAND="(time make; date) 2>&1 | tee make_output &"

echo $COMMAND
eval $COMMAND
