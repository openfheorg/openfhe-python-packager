#!/bin/sh

. ./ci-vars.sh

# Usage:
#   ./ubuntu.sh <OS_RELEASE>
# Example:
#   ./ubuntu.sh 22.04
#
OS_NAME="ubuntu"
if [ $# -eq 0 ]; then
    echo "Usage: $0 <OS_RELEASE>  e.g. 22.04, 24.04" >&2
#   echo "Or create symplinks and call via symlink named ubuntu20.sh / ubuntu22.sh / ubuntu24.sh ..." >&2
    exit 2
fi
OS_RELEASE="$1"

LOCAL_DIR="./wheel_${OS_NAME}_${OS_RELEASE}"
rm -rf "${LOCAL_DIR}"

# build the docker and the wheel in that docker
CONTAINER_NAME="openfhe-build:${OS_NAME}_${OS_RELEASE}"
DOCKER_FILE="openfhe-build-${OS_NAME}-${OS_RELEASE}.Dockerfile"
echo "===== Building ${CONTAINER_NAME} from ${DOCKER_FILE}"

# Build image (override with values from your local ci-vars)
docker build                                                     \
    -f "docker_files/${DOCKER_FILE}"                             \
    -t "${CONTAINER_NAME}"                                       \
    --build-arg OPENFHE_TAG_ARG="${OPENFHE_TAG}"                 \
    --build-arg OPENFHE_PYTHON_TAG_ARG="${OPENFHE_PYTHON_TAG}"   \
    --build-arg WHEEL_MINOR_VERSION_ARG="${WHEEL_MINOR_VERSION}" \
    --build-arg WHEEL_TEST_VERSION_ARG="${WHEEL_TEST_VERSION}"   \
    --build-arg ADDL_CMAKE_FLAGS_ARG="${ADDL_CMAKE_FLAGS}"       \
    --build-arg PARALELLISM_ARG="${PARALELLISM}"                 \
    . --progress=plain || abort "${CONTAINER_NAME} failed"

# copy the wheel to the local machine
mkdir -m 777 "${LOCAL_DIR}"

# Unique temp container name to avoid collisions
TMP_CONT="temp-container-${OS_NAME}-${OS_RELEASE}-$(date +%s)"
docker create --name "${TMP_CONT}" "${CONTAINER_NAME}" >/dev/null
# copy the wheel to the local machine
docker cp "${TMP_CONT}:/root/openfhe-python-packager/build/dist" "${LOCAL_DIR}"

# cleanup
docker rm "${TMP_CONT}" >/dev/null

# change the owner (fix the ownership) of all files in the current directory from root to the local user
chown -R "$SUDO_USER" "${LOCAL_DIR}"

echo "The wheel copied to: ${LOCAL_DIR}/dist"
