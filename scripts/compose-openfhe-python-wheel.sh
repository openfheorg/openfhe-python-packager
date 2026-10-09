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
cp ${INSTALL_PATH}/*.so ${WHEEL_ROOT}/openfhe || abort "no openfhe python module (*.so) found in ${INSTALL_PATH}; the build likely failed"
# add __init__.py to the wheel
if [ "$OS_TYPE" = "Linux" ] && [ "$OS_NAME" = "Ubuntu" ] && [ "$OS_RELEASE" = "20.04" ]; then

# add an Ubuntu20 deprecation notice (override __init__.py for the wheel). the warning appears only once, as soon as the library is loaded,
# and users can also silence the message by setting "OPENFHE_SILENCE_DEPRECATION=1"
cat << EOF > ${WHEEL_ROOT}/openfhe/__init__.py
# --- Deprecation notice (shown once per process) ---
import os as _os
import warnings as _warnings

if not _os.environ.get("OPENFHE_SILENCE_DEPRECATION"):
    _flag = "_OPENFHE_DEPRECATION_SHOWN"
    if not globals().get(_flag):
        globals()[_flag] = True
        _warnings.warn("⚠️  Deprecation notice: This is the last OpenFHE wheel built for ${OS_NAME} ${OS_RELEASE}. "
                       "No new OpenFHE builds will be published for this OS.",
                       category=UserWarning,
                       stacklevel=2,
        )

EOF

    # --- Actual library import ---
    cat ${INSTALL_PATH}/__init__.py >> ${WHEEL_ROOT}/openfhe/__init__.py
else
    cp ${INSTALL_PATH}/__init__.py ${WHEEL_ROOT}/openfhe
fi
# files necessary for find_package()
# cp -r ${INSTALL_PATH}/lib/OpenFHE/ ${WHEEL_ROOT}/openfhe/lib
if [ "$OS_TYPE" = "Linux" ]; then
    # add libOPENFHE*.so to the wheel
    cp ${INSTALL_PATH}/lib/*.so.1 ${WHEEL_ROOT}/openfhe/lib || abort "no OpenFHE shared libraries (lib/*.so.1) found in ${INSTALL_PATH}; the build likely failed"
    # add the Intel HEXL shared library (e.g. libhexl.so.1.2.6) when built with HEXL.
    # The *.so.1 glob above does not match HEXL's version-suffixed soname, so copy
    # it explicitly (preserving symlinks) or the module fails to load libhexl at import.
    if [ "$BUILD_HEXL" = "ON" ]; then
        cp -a ${INSTALL_PATH}/lib/libhexl.so* ${WHEEL_ROOT}/openfhe/lib || abort "BUILD_HEXL=ON but no HEXL shared library (lib/libhexl.so*) found in ${INSTALL_PATH}"
    fi
elif [ "$OS_TYPE" = "Darwin" ]; then
    # add libOPENFHE*.dylib to the wheel
    cp ${INSTALL_PATH}/lib/*.1.dylib ${WHEEL_ROOT}/openfhe/lib || abort "no OpenFHE shared libraries (lib/*.1.dylib) found in ${INSTALL_PATH}; the build likely failed"
    if [ "$BUILD_HEXL" = "ON" ]; then
        cp -a ${INSTALL_PATH}/lib/libhexl*.dylib ${WHEEL_ROOT}/openfhe/lib || abort "BUILD_HEXL=ON but no HEXL shared library (lib/libhexl*.dylib) found in ${INSTALL_PATH}"
    fi
fi

############################################################################
### Make bundled libraries find their siblings relative to the wheel
############################################################################
# OpenFHE is built with CMAKE_INSTALL_RPATH set to the absolute build-time
# install dir (loc-install/lib) and CMAKE_INSTALL_RPATH_USE_LINK_PATH=TRUE, so
# the libOPENFHE*.so.1 libraries carry an absolute RPATH that does not exist on
# an end-user machine. For a plain build this is masked because the openfhe
# module itself has RUNPATH=$ORIGIN/lib and loads the OpenFHE libs directly. But
# libhexl.so.* is a TRANSITIVE dependency of libOPENFHEcore (not of the module),
# and RUNPATH is not inherited by transitive deps - so libOPENFHEcore must find
# libhexl via its own RPATH. Rewrite the bundled libraries' RPATH to $ORIGIN so
# every lib resolves its siblings from within openfhe/lib/ regardless of install
# location. Only needed on Linux HEXL builds.
if [ "$OS_TYPE" = "Linux" ] && [ "$BUILD_HEXL" = "ON" ]; then
    command -v patchelf >/dev/null 2>&1 || abort "patchelf is required for BUILD_HEXL=ON wheels but was not found; install it (e.g. apt-get install -y patchelf)"
    for lib in ${WHEEL_ROOT}/openfhe/lib/*.so*; do
        # skip symlinks; only rewrite real ELF files
        [ -L "$lib" ] && continue
        patchelf --set-rpath '$ORIGIN' "$lib" || abort "patchelf failed to set RPATH on $lib"
    done
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
python3 -m pip wheel . --use-pep517 -w ${BUILD_DIR}/dist

# python3 -m pip wheel . -w ${BUILD_DIR}/dist
# python3 -m pip sdist  . -d ${BUILD_DIR}/dist
# python3 -m build --wheel --outdir ${BUILD_DIR}/dist_temp
# python3 setup.py sdist --dist-dir ${BUILD_DIR}/dist bdist_wheel --dist-dir ${BUILD_DIR}/dist

echo
echo "Done."
