#!/bin/sh
. ./ci-vars.sh

OS_NAME=ubuntu
OS_RELEASE=22.04

LOCAL_DIR=./wheel_${OS_NAME}_${OS_RELEASE}
rm -rf ${LOCAL_DIR}

# build the docker and the wheel in that docker
CONTAINER_NAME=openfhe-build:${OS_NAME}_${OS_RELEASE}
DOCKER_FILE=openfhe-build-${OS_NAME}-${OS_RELEASE}.Dockerfile
echo "===== Building ${CONTAINER_NAME} from ${DOCKER_FILE}"

# build arguments are to override ci-vars.sh with values from your local ci-vars.sh
docker build                                                   \
    -f docker_files/${DOCKER_FILE}                             \
    -t ${CONTAINER_NAME}                                       \
    --build-arg OPENFHE_TAG_ARG=${OPENFHE_TAG}                 \
    --build-arg OPENFHE_PYTHON_TAG_ARG=${OPENFHE_PYTHON_TAG}   \
    --build-arg WHEEL_MINOR_VERSION_ARG=${WHEEL_MINOR_VERSION} \
    --build-arg WHEEL_TEST_VERSION_ARG=${WHEEL_TEST_VERSION}   \
    --build-arg PARALELLISM_ARG=${PARALELLISM}                 \
    . --progress=plain || abort "${CONTAINER_NAME} failed"

# copy the wheel to the local machine
mkdir -m 777 ${LOCAL_DIR}
docker create --name temp-container ${CONTAINER_NAME}
docker cp temp-container:/root/openfhe-python-packager/build/dist ${LOCAL_DIR}

# cleanup
docker rm temp-container

# change the owner of all files in the current directory from root to the local user
chown -R "$SUDO_USER" "${LOCAL_DIR}"
