#!/bin/sh

# find the directory where the script is and where we will run this script from
SCRIPT_PATH=$(readlink -f "$0")
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")
# echo "Script absolute path: $SCRIPT_DIR"

cd $SCRIPT_DIR

# build all libs
./scripts/build-all-binaries.sh

# build the wheel
./scripts/compose-openfhe-python-wheel.sh