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

echo "==============================================================================="
echo
echo "OPENFHE_PYTHON WHEEL BUILD PARAMETERS"
echo
echo "WHEEL_VERSION      : " ${WHEEL_VERSION}
echo

# =============================================================================
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
### echo "=========================="
### echo "WHEEL_ROOT  : ${WHEEL_ROOT}"
### echo "INSTALL_PATH: ${INSTALL_PATH}"
### echo "=========================="

echo "GNU OMP library"
cp /usr/lib/x86_64-linux-gnu/libgomp.so.1 ${WHEEL_ROOT}

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
