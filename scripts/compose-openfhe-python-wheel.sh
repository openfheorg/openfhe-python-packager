#!/bin/sh

. ./ci-vars.sh
. ./scripts/common-functions.sh

# WHEEL [OUTPUT] VERSION
WHEEL_VERSION=$(get_wheel_version ${OS_RELEASE} ${OPENFHE_TAG} ${WHEEL_MINOR_VERSION} ${WHEEL_TEST_VERSION})
if [ -z "$WHEEL_VERSION" ]; then
  abort "${0}: WHEEL_VERSION has not been specified."
fi

# =============================================================================
#
ROOT=$(pwd)
BUILD_DIR=${ROOT}/build
echo "${0}: BUILD_DIR - ${BUILD_DIR}"

separator
echo "OPENFHE_PYTHON WHEEL BUILD PARAMETERS"
echo
echo "WHEEL_VERSION      : " ${WHEEL_VERSION}
separator

# ASSEMBLE WHEEL ROOT FILESYSTEM
cd ${BUILD_DIR} # should be redundant
WHEEL_ROOT="${BUILD_DIR}/wheel-root"
rm -r ${WHEEL_ROOT}

mkdir -p ${WHEEL_ROOT}
mkdir -p ${WHEEL_ROOT}/openfhe
mkdir -p ${WHEEL_ROOT}/openfhe/lib

echo "OPENFHE_PYTHON module"
INSTALL_PATH=$(get_install_path ${BUILD_DIR})
# add libOPENFHE*.so to the wheel
cp ${INSTALL_PATH}/*.so ${WHEEL_ROOT}/openfhe
# add __init__.py to the wheel
cp ${ROOT}/__init__.py ${WHEEL_ROOT}/openfhe
# add ci-vars.sh as build-config.txt to the wheel for reference
cp ${ROOT}/ci-vars.sh ${WHEEL_ROOT}/openfhe/build-config.txt
chmod 644 ${WHEEL_ROOT}/openfhe/build-config.txt

echo "OPENFHE_PYTHON libraries"
cp ${INSTALL_PATH}/lib/*.so.1 ${WHEEL_ROOT}/openfhe/lib

############################################################################
### Adding all necessary libraries
############################################################################
echo "Adding libgomp.so ..."
CXX_COMPILER=$(get_compiler_version "g++")
libgomp_path=$(${CXX_COMPILER} -print-file-name=libgomp.so)
# Check if the returned string is a path (i.e., not just "libgomp.so")
if [ "${libgomp_path}" != "libgomp.so" ]; then
    echo "libgomp for ${CXX_COMPILER} found at: ${libgomp_path}"
else
    echo "ERROR: libgomp not found for ${CXX_COMPILER}."
    exit 1
fi
cp ${libgomp_path} ${WHEEL_ROOT}/openfhe/lib
separator

cd ${ROOT}
python3 setup.py sdist --dist-dir ${BUILD_DIR}/dist bdist_wheel --dist-dir ${BUILD_DIR}/dist

echo
echo "Done."
