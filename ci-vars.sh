OS_NAME=Ubuntu
OS_RELEASE=24.04
OPENFHE_TAG=v1.5.1
OPENFHE_PYTHON_TAG=v1.5.1.0

# Build OpenFHE with the Intel HEXL acceleration backend.
# Set BUILD_HEXL=ON to overlay the openfhe-hexl sources onto openfhe-development
# before building (mirrors what openfhe-configurator stages). Leave empty or set
# to OFF for a standard build.
# NOTE: Intel HEXL targets x86-64 CPUs with AVX-512. A HEXL-enabled wheel will not
# import on arm64 (e.g. Apple Silicon); build it for an x86-64 target.
BUILD_HEXL=OFF
# openfhe-hexl repository and tag used for the HEXL overlay. The tag should match
# the OPENFHE_TAG above (e.g. OPENFHE_TAG=v1.5.1 pairs with OPENFHE_HEXL_TAG=v1.5.1.0).
OPENFHE_HEXL_REPO=https://github.com/openfheorg/openfhe-hexl.git
OPENFHE_HEXL_TAG=v1.5.1.0
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
