#!/bin/sh

. ./ci-vars.sh
. ./scripts/common-functions.sh

ROOT=$(pwd)
BUILD_DIR=${ROOT}/build
echo "${0}: BUILD_DIR - ${BUILD_DIR}"
CMAKE_DEFAULT_ARGS=$(get_cmake_default_args ${BUILD_DIR})
echo "CMAKE_DEFAULT_ARGS: ${CMAKE_DEFAULT_ARGS}"

### build openfhe-development
OPENFHE_REPO="https://github.com/openfheorg/openfhe-development.git"
OPENFHE_DIR="${BUILD_DIR}/openfhe-development"
OPENFHE_CMAKE_ARGS=${CMAKE_DEFAULT_ARGS}
OPENFHE_CMAKE_ARGS=${OPENFHE_CMAKE_ARGS}" -DBUILD_STATIC=OFF -DBUILD_SHARED=ON"
OPENFHE_CMAKE_ARGS=${OPENFHE_CMAKE_ARGS}" -DBUILD_BENCHMARKS=OFF -DBUILD_UNITTESTS=OFF -DBUILD_EXAMPLES=OFF"
# OPENFHE_CMAKE_ARGS=${OPENFHE_CMAKE_ARGS}" -DWITH_OPENMP=OFF"

clone ${OPENFHE_REPO} ${OPENFHE_DIR}
build_install_tag_with_args ${OPENFHE_DIR} ${OPENFHE_TAG} "${OPENFHE_CMAKE_ARGS}" ${PARALELLISM}

### build openfhe-python
OPENFHE_PYTHON_REPO="https://github.com/openfheorg/openfhe-python.git"
OPENFHE_PYTHON_DIR="${BUILD_DIR}/openfhe-python"
OPENFHE_PYTHON_CMAKE_ARGS=${CMAKE_DEFAULT_ARGS}

clone ${OPENFHE_PYTHON_REPO} ${OPENFHE_PYTHON_DIR}
build_install_tag_with_args ${OPENFHE_PYTHON_DIR} ${OPENFHE_PYTHON_TAG} "${OPENFHE_PYTHON_CMAKE_ARGS}" ${PARALELLISM}

separator

