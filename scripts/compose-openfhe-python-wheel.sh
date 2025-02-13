#!/bin/sh

. ./ci-vars.sh
. ./scripts/common-functions.sh

# WHEEL [OUTPUT] VERSION
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
echo "OPENFHE_PYTHON module"
mkdir -p ${WHEEL_ROOT}
cp -r openfhe-python/openfhe/ ${WHEEL_ROOT}

echo "OPENFHE_PYTHON library"
INSTALL_PATH=$(get_install_path ${BUILD_DIR})
cp ${INSTALL_PATH}/*.so ${WHEEL_ROOT}/openfhe

############################################################################
### Adding all necessary libraries
############################################################################
echo "Adding libstdc++.so ..."
libstdc_path=$(${CXX_COMPILER} -print-file-name=libstdc++.so)
# Check if the returned string is a path (i.e., not just "libstdc++.so")
if [ "${libstdc_path}" != "libstdc++.so" ]; then
    echo "libstdc++ for ${CXX_COMPILER} found at: ${libstdc_path}"
else
    echo "ERROR: libstdc++ not found for ${CXX_COMPILER}."
    exit 1
fi
cp ${libstdc_path} ${WHEEL_ROOT}/openfhe
separator
############################################################################
echo "Adding libm.so ..."
libm_path=$(${CXX_COMPILER} -print-file-name=libm.so)
# Check if the returned string is a path (i.e., not just "libm.so")
if [ "${libm_path}" != "libm.so" ]; then
    echo "libm for ${CXX_COMPILER} found at: ${libm_path}"
else
    echo "ERROR: libm not found for ${CXX_COMPILER}."
    exit 1
fi
cp ${libm_path} ${WHEEL_ROOT}/openfhe
separator
############################################################################
echo "Adding libgomp.so ..."
libgomp_path=$(${CXX_COMPILER} -print-file-name=libgomp.so)
# Check if the returned string is a path (i.e., not just "libgomp.so")
if [ "${libgomp_path}" != "libgomp.so" ]; then
    echo "libgomp for ${CXX_COMPILER} found at: ${libgomp_path}"
else
    echo "ERROR: libgomp not found for ${CXX_COMPILER}."
    exit 1
fi
cp ${libgomp_path} ${WHEEL_ROOT}/openfhe
separator
############################################################################
echo "Adding libgcc_s.so ..."
libgcc_s_path=$(${CXX_COMPILER} -print-file-name=libgcc_s.so)
# Check if the returned string is a path (i.e., not just "libgcc_s.so")
if [ "${libgcc_s_path}" != "libgcc_s.so" ]; then
    echo "libgcc_s for ${CXX_COMPILER} found at: ${libgcc_s_path}"
else
    echo "ERROR: libgcc_s not found for ${CXX_COMPILER}."
    exit 1
fi
cp ${libgcc_s_path} ${WHEEL_ROOT}/openfhe
separator
############################################################################
echo "Adding libc.so ..."
libc_path=$(${CXX_COMPILER} -print-file-name=libc.so)
# Check if the returned string is a path (i.e., not just "libc.so")
if [ "${libc_path}" != "libc.so" ]; then
    echo "libc for ${CXX_COMPILER} found at: ${libc_path}"
else
    echo "ERROR: libc not found for ${CXX_COMPILER}."
    exit 1
fi
cp ${libc_path} ${WHEEL_ROOT}/openfhe
separator
############################################################################

echo "OPENFHE_PYTHON dist-info"
OPENFHE_PYTHON_DIST_INFO_DIR="openfhe-python-${WHEEL_VERSION}.dist-info"
mkdir -p ${WHEEL_ROOT}/${OPENFHE_PYTHON_DIST_INFO_DIR}
cat >${WHEEL_ROOT}/${OPENFHE_PYTHON_DIST_INFO_DIR}/METADATA <<EOF
Metadata-Version: 2.1
Name: openfhe-python
Version: ${WHEEL_VERSION}
Summary: openfhe-python
Home-page: https://dualitytech.com/
Author: Duality
Author-email: jdoe@dualitytech.com
Classifier: Programming Language :: Python :: 3
Classifier: License :: Other/Proprietary License
Classifier: Operating System :: OS Independent
Description-Content-Type: text/markdown
EOF

cat >${WHEEL_ROOT}/${OPENFHE_PYTHON_DIST_INFO_DIR}/WHEEL <<EOF
Wheel-Version: 1.0
Generator: bdist_wheel (0.42.0)
Root-Is-Purelib: true
Tag: py2-none-linux_x86_64
Tag: py3-none-linux_x86_64
EOF

cat >${WHEEL_ROOT}/${OPENFHE_PYTHON_DIST_INFO_DIR}/top_level.txt <<EOF
openfhe-python
EOF

cd ${WHEEL_ROOT}
chmod -R g-w .
RECORD_FILES=`find . -type f,l -print | sed -- 's/^.\///'`
for file in ${RECORD_FILES}; do
  HASH=`sha256sum $file | awk -- '{ print $1 }' | xxd -r -p | base64 | sed -- 's/=//'`
  LEN=`ls -l $file | awk -- '{ print $5 }'`
  echo $file,sha256=$HASH,$LEN >>${OPENFHE_PYTHON_DIST_INFO_DIR}/RECORD
done
echo "${OPENFHE_PYTHON_DIST_INFO_DIR}/RECORD,," >>${OPENFHE_PYTHON_DIST_INFO_DIR}/RECORD

echo
echo "emit wheel"
echo "create dist dir ${BUILD_DIR}/dist"
mkdir -p ${BUILD_DIR}/dist
WHEEL_FULLPATH=${BUILD_DIR}/dist/openfhe-python-${WHEEL_VERSION}-py2.py3-none-linux_x86_64.whl
echo "create wheel file ${WHEEL_FULLPATH}"
zip -r ${WHEEL_FULLPATH} *

echo
echo "Done."
