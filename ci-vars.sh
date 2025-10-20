OS_NAME=Ubuntu
OS_RELEASE=24.04
OPENFHE_TAG=v1.4.0.2
OPENFHE_PYTHON_TAG=v1.4.0.1.3
# subsequent release number for the given OPENFHE_TAG.
WHEEL_MINOR_VERSION=0
# Example of a wheel version based on the vars values in this file:
# OS_RELEASE=20.04
# OPENFHE_TAG=v1.2.3
# WHEEL_MINOR_VERSION=9
# then the wheel version will be: 1.2.3.9.20.04

# DO NOT set WHEEL_TEST_VERSION unless you are building a test/dev wheel.
# if WHEEL_TEST_VERSION=5 then the wheel version will be: 1.2.3.9.20.04.dev5
WHEEL_TEST_VERSION=

# Additional arguments to cmake.
# Be careful with this option as it is supposed to be used to pass compiler flags for manual workflow only. Example:
# ADDL_CMAKE_FLAGS="-DCMAKE_CXX_COMPILER=/usr/bin/g++-14 -DCMAKE_C_COMPILER=/usr/bin/gcc-14"
ADDL_CMAKE_FLAGS=

# PARALELLISM is used to expedite the build process in ./scripts/common-functions.sh
PARALELLISM=11
