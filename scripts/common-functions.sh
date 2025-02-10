#!/bin/sh

separator()
{
  echo
  echo "==============================================================================="
  echo
}

abort()
{
  MSG=$1
  separator
  echo "ERROR: $MSG"
  echo
  echo "abort."
  exit 1
}

clone()
{
  REPO=$1
  DIR=$2
  separator
  echo "clone $DIR"
  separator
  if [ ! -d $DIR ]; then
    git clone --recurse-submodules $REPO $DIR
  fi
  cd $DIR || abort "clone of $DIR failed"
  cd ..
}

# ATTN: get_install_path MUST NOT print anything else, but ${INSTALL_PATH} !!!
get_install_path()
{
  ROOT=${1}

  INSTALL_DIR="loc-install"
  INSTALL_PATH="$ROOT/$INSTALL_DIR"

  echo "${INSTALL_PATH}"
}

# ATTN: get_cmake_default_args MUST NOT print anything else, but ${CMAKE_DEFAULT_ARGS} !!!
get_cmake_default_args()
{
  ROOT=${1}
  CXX_COMPILER=${2}
  C_COMPILER=${3}

  INSTALL_PATH=$(get_install_path ${ROOT})

  CMAKE_DEFAULT_ARGS="-DCMAKE_INSTALL_PREFIX=$INSTALL_PATH -DCMAKE_PREFIX_PATH=$INSTALL_PATH"
  CMAKE_DEFAULT_ARGS=${CMAKE_DEFAULT_ARGS}" -DCMAKE_CXX_COMPILER=${CXX_COMPILER} -DCMAKE_C_COMPILER=${C_COMPILER}"

  echo "${CMAKE_DEFAULT_ARGS}"
}

build_install_tag_with_args()
{
  DIR=${1}
  TAG=${2}
  CMAKE_ARGS=${3}
  PARALELLISM=${4}

  cd $DIR || abort "unable to cd into $DIR"
    if [ ! -d build ]; then
      separator
      echo "checkout $DIR tag $TAG"
      separator
      git checkout $TAG || abort "unable to checkout $DIR tag $TAG"

      mkdir build || abort "unable to create build dir in $DIR"
      cd build || abort "unable to cd into build dir in $DIR"
        separator
        echo "cmake $DIR with cmake args $CMAKE_ARGS"
        separator
        cmake .. $CMAKE_ARGS || abort "cmake of $DIR failed"
      cd ..
    fi
    cd build || abort "unable to cd into build dir in $DIR"
      separator
      echo "make $DIR"
      separator
      VERBOSE=1 make -j$PARALELLISM || abort "make of $DIR failed"
      separator
      echo "make install $DIR"
      separator
      make install || abort "install of $DIR failed"
    cd ..
  cd ..
}
