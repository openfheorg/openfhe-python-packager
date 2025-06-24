#!/bin/sh

. ./scripts/common-functions.sh

# find the directory where the script is and where we will run this script from
SCRIPT_PATH=$(readlink -f "$0")
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")
# echo "Script absolute path: $SCRIPT_DIR"
cd $SCRIPT_DIR

# create and/or activate the virtual environment for the build
. ./scripts/get-env.sh
separator
echo "Activated virtual environment: \"$(basename "$VIRTUAL_ENV")\""
separator

# print build configuration
echo "ci-vars.sh:"
separator
cat ./ci-vars.sh
separator

# build openfhe-development and openfhe-python
./scripts/build-binaries.sh

# build the wheel
./scripts/compose-openfhe-python-wheel.sh
