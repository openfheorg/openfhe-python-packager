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

# Check out a specific tag/branch in an already-cloned repository. Idempotent:
# safe to call before build_install_tag_with_args (which also checks out the tag).
checkout_tag()
{
  DIR=$1
  TAG=$2
  separator
  echo "checkout $DIR tag $TAG"
  separator
  cd "$DIR" || abort "checkout_tag: unable to cd into $DIR"
    git checkout "$TAG" || abort "checkout_tag: unable to checkout $DIR tag $TAG"
  cd - > /dev/null || abort "checkout_tag: unable to return from $DIR"
}

# Overlay the openfhe-hexl sources onto a staged openfhe-development tree to
# produce a HEXL-enabled build. Mirrors the staging performed by
# openfhe-configurator (openfhe-hexl ships replacement/addition files that are
# copied over openfhe-development before building).
overlay_hexl()
{
  HEXL_SRC=$1    # path to the checked-out openfhe-hexl tree
  OPENFHE_DST=$2 # path to the staged openfhe-development tree

  [ -d "$HEXL_SRC" ] || abort "overlay_hexl: openfhe-hexl source $HEXL_SRC not found"
  [ -d "$OPENFHE_DST" ] || abort "overlay_hexl: openfhe-development tree $OPENFHE_DST not found"

  separator
  echo "overlay openfhe-hexl ($HEXL_SRC) onto openfhe-development ($OPENFHE_DST)"
  separator

  # Files and directories openfhe-hexl overlays onto openfhe-development.
  for item in CMakeLists.txt CMakeLists.User.txt OpenFHEConfig.cmake.in \
              benchmark configure src third-party; do
    if [ -e "$HEXL_SRC/$item" ]; then
      cp -R "$HEXL_SRC/$item" "$OPENFHE_DST/" || abort "overlay_hexl: failed to copy $item"
    else
      echo "overlay_hexl: WARNING - $item not present in openfhe-hexl, skipping"
    fi
  done

  # The openfhe-hexl CMakeLists.txt hardcodes its own OPENFHE_VERSION_* (e.g. at
  # tag v1.5.1.0 the patch is stale at 0, yielding version 1.5.0). Overlaying it
  # downgrades the version openfhe-development reports, so the generated
  # OpenFHEConfig.cmake no longer satisfies openfhe-python's
  # find_package(OpenFHE <OPENFHE_TAG without v> REQUIRED) and no .so is built.
  # Rewrite the version in the overlaid CMakeLists.txt to match OPENFHE_TAG.
  # (OPENFHE_VERSION on the following line recomputes from these, and
  # OpenFHEConfig.cmake.in consumes @OPENFHE_VERSION@, so only these need patching.)
  OVERLAID_CMAKE="$OPENFHE_DST/CMakeLists.txt"
  VERSION="${OPENFHE_TAG#v}"
  V_MAJOR=$(echo "$VERSION" | cut -d. -f1)
  V_MINOR=$(echo "$VERSION" | cut -d. -f2)
  V_PATCH=$(echo "$VERSION" | cut -d. -f3)
  if [ -n "$V_MAJOR" ] && [ -n "$V_MINOR" ] && [ -n "$V_PATCH" ]; then
    echo "overlay_hexl: setting OPENFHE_VERSION to $V_MAJOR.$V_MINOR.$V_PATCH (from OPENFHE_TAG=$OPENFHE_TAG) in overlaid CMakeLists.txt"
    sed -i "s|^set(OPENFHE_VERSION_MAJOR .*)|set(OPENFHE_VERSION_MAJOR ${V_MAJOR})|" "$OVERLAID_CMAKE" || abort "overlay_hexl: failed to patch OPENFHE_VERSION_MAJOR"
    sed -i "s|^set(OPENFHE_VERSION_MINOR .*)|set(OPENFHE_VERSION_MINOR ${V_MINOR})|" "$OVERLAID_CMAKE" || abort "overlay_hexl: failed to patch OPENFHE_VERSION_MINOR"
    sed -i "s|^set(OPENFHE_VERSION_PATCH .*)|set(OPENFHE_VERSION_PATCH ${V_PATCH})|" "$OVERLAID_CMAKE" || abort "overlay_hexl: failed to patch OPENFHE_VERSION_PATCH"
  else
    echo "overlay_hexl: WARNING - OPENFHE_TAG='$OPENFHE_TAG' did not yield a 3-component version; leaving overlaid CMakeLists.txt version unchanged"
  fi
}

# ATTN: get_install_path MUST NOT print anything else, but ${INSTALL_PATH} !!!
get_install_path()
{
  ROOT=${1}

  INSTALL_DIR="loc-install"
  INSTALL_PATH="$ROOT/$INSTALL_DIR"

  echo "${INSTALL_PATH}"
}

# ATTN: get_wheel_version MUST NOT print anything else, but ${VERSION} !!!
get_wheel_version()
{
  OS_RELEASE=${1}
  OPENFHE_TAG=${2}
  WHEEL_MINOR_VERSION=${3}
  WHEEL_TEST_VERSION=${4}

  VERSION="${OPENFHE_TAG#v}.${WHEEL_MINOR_VERSION}.${OS_RELEASE}"
  if [ -n "${WHEEL_TEST_VERSION}" ]; then
    VERSION="${VERSION}.dev${WHEEL_TEST_VERSION}"
  fi

  echo ${VERSION}
}

# ATTN: get_long_description MUST NOT print anything else, but ${LONG_DESCRIPTION} !!!
get_long_description()
{
  OS_NAME=${1}
  OS_RELEASE=${2}

  LONG_DESCRIPTION="This release requires ${OS_NAME} ${OS_RELEASE}"

  echo ${LONG_DESCRIPTION}
}

get_compiler_version()
{
  COMPILER="$1"
  # get major compiler version
  compiler_version=$("$COMPILER" --version | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)

  if [ -z "$compiler_version" ]; then
      echo "ERROR: Could not determine version for compiler '$COMPILER'" >&2
      exit 1
  fi

  major_version=$(echo "$compiler_version" | cut -d. -f1)
  echo "${COMPILER}-${major_version}"
}

# ATTN: get_cmake_default_args MUST NOT print anything else, but ${CMAKE_DEFAULT_ARGS} !!!
get_cmake_default_args()
{
  ROOT=${1}
  INSTALL_PATH=$(get_install_path ${ROOT})
  # # we have to pass the location of OpenFHE as an argument
  # OpenFHE_DIR=$(python3 -c "import openfhe; print(openfhe.__path__[0] + '/lib/OpenFHE')")

  # CMAKE_DEFAULT_ARGS="-DCMAKE_INSTALL_PREFIX=$INSTALL_PATH -DCMAKE_PREFIX_PATH=$OpenFHE_DIR"

  CMAKE_DEFAULT_ARGS="-DCMAKE_INSTALL_PREFIX=$INSTALL_PATH -DCMAKE_PREFIX_PATH=$INSTALL_PATH"
  echo "${CMAKE_DEFAULT_ARGS}"
}

build_install_tag_with_args()
{
  DIR=${1}
  TAG=${2}
  CMAKE_ARGS=${3}
  PARALELLISM=${4}
  OS_TYPE="$(uname)"

  cd $DIR || abort "unable to cd into $DIR"
    if [ ! -d build ]; then
      # Skip the checkout if HEAD is already at the requested tag. This matters
      # for the HEXL overlay path, where the tag is checked out and overlay files
      # are copied in beforehand; a redundant `git checkout` would revert them.
      if [ "$(git rev-parse --verify HEAD)" = "$(git rev-parse --verify "$TAG")" ]; then
        separator
        echo "$DIR already at tag $TAG, skipping checkout"
        separator
      else
        separator
        echo "checkout $DIR tag $TAG"
        separator
        git checkout $TAG || abort "unable to checkout $DIR tag $TAG"
      fi

      mkdir build || abort "unable to create build dir in $DIR"
      cd build || abort "unable to cd into build dir in $DIR"
        separator
        echo "cmake $DIR with cmake args $CMAKE_ARGS"
        separator
        cmake .. $CMAKE_ARGS || abort "cmake of $DIR failed"
        if [ "$OS_TYPE" = "Darwin" ]; then
            cmake .. || abort "cmake#2 of $DIR failed"
        fi
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
