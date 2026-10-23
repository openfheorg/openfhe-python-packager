#!/bin/sh

. ./ci-vars.sh
. ./scripts/common-functions.sh

export PIP_USE_PEP517=1

OS_TYPE="$(uname)"

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
echo "OPENFHE module"
# add the python module to the wheel
cp ${INSTALL_PATH}/*.so ${WHEEL_ROOT}/openfhe
# add __init__.py to the wheel
cp ${INSTALL_PATH}/__init__.py ${WHEEL_ROOT}/openfhe
# files necessary for find_package()
# cp -r ${INSTALL_PATH}/lib/OpenFHE/ ${WHEEL_ROOT}/openfhe/lib
if [ "$OS_TYPE" = "Linux" ]; then
    # add libOPENFHE*.so to the wheel
    cp ${INSTALL_PATH}/lib/*.so.1 ${WHEEL_ROOT}/openfhe/lib
elif [ "$OS_TYPE" = "Darwin" ]; then
    # add libOPENFHE*.dylib to the wheel
    cp ${INSTALL_PATH}/lib/*.1.dylib ${WHEEL_ROOT}/openfhe/lib
fi
# add ci-vars.sh as build-config.txt to the wheel for reference
cp ${ROOT}/ci-vars.sh ${WHEEL_ROOT}/openfhe/build-config.txt
chmod 644 ${WHEEL_ROOT}/openfhe/build-config.txt

############################################################################
### Adding all necessary libraries
############################################################################
echo "Adding OpenMP library ..."
if [ "$OS_TYPE" = "Linux" ]; then
    CXX_COMPILER=$(get_compiler_version "g++")
    libomp_path=$(${CXX_COMPILER} -print-file-name=libgomp.so)
    # Check if the returned string is a path (i.e., not just "libgomp.so")
    if [ "${libomp_path}" != "libgomp.so" ]; then
        echo "libgomp for ${CXX_COMPILER} found at: ${libomp_path}"
    else
        echo "ERROR: libgomp not found for ${CXX_COMPILER}."
        exit 1
    fi
elif [ "$OS_TYPE" = "Darwin" ]; then
    CXX_COMPILER=$(get_compiler_version "clang++")
    libomp_path=$(brew --prefix libomp)/lib/libomp.dylib
    # Check if the returned string is a path (i.e., not just "libomp.dylib")
    if [ "${libomp_path}" != "/lib/libomp.dylib" ]; then
        echo "libomp for ${CXX_COMPILER} found at: ${libomp_path}"
    else
        echo "ERROR: libomp not found for ${CXX_COMPILER}."
        exit 1
    fi
fi
cp ${libomp_path} ${WHEEL_ROOT}/openfhe/lib
separator

cd ${ROOT}
# --no-deps: build only the openfhe wheel. Without it pip also downloads a wheel for
# every declared dependency into the output directory, which consumers that expect a
# single wheel there (the openfhe-python docs builder) reject. The dependencies stay
# recorded in the wheel's metadata and are resolved at install time.
python3 -m pip wheel . --use-pep517 --no-deps -w ${BUILD_DIR}/dist

# python3 -m pip wheel . -w ${BUILD_DIR}/dist
# python3 -m pip sdist  . -d ${BUILD_DIR}/dist
# python3 -m build --wheel --outdir ${BUILD_DIR}/dist_temp
# python3 setup.py sdist --dist-dir ${BUILD_DIR}/dist bdist_wheel --dist-dir ${BUILD_DIR}/dist

separator
# Install the wheel into a clean virtual environment and import it. This catches
# packaging bugs that the build itself cannot: missing runtime dependencies in the
# wheel metadata (the module imports its dependencies, e.g. numpy, at load time),
# missing bundled libraries, and broken module layout.
echo "Verifying the wheel in a clean virtual environment ..."
VENV_DIR="${BUILD_DIR}/wheel-verify-venv"
rm -rf "${VENV_DIR}"
python3 -m venv "${VENV_DIR}"
"${VENV_DIR}/bin/pip" install --quiet ${BUILD_DIR}/dist/openfhe-*.whl || abort "wheel install failed"
"${VENV_DIR}/bin/python" -c "import openfhe; print('wheel verification OK: openfhe', openfhe.__version__)" \
    || abort "importing openfhe from the installed wheel failed"

echo
echo "Done."
