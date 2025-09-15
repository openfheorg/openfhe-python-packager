# Use Ubuntu 20.04 as the base image and set the correct OS description in ci-vars.sh below
FROM ubuntu:20.04

# Set environment variable to disable interactive prompts during package installs
ENV DEBIAN_FRONTEND=noninteractive

# ci-vars.sh overrides
ARG OPENFHE_TAG_ARG
ARG OPENFHE_PYTHON_TAG_ARG
ARG WHEEL_MINOR_VERSION_ARG
ARG WHEEL_TEST_VERSION_ARG
ARG PARALLELISM_ARG

# Update package lists and install essential utilities (optional)
RUN apt-get update && apt-get install -y \
        git \
        vim \
        && rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y \
        build-essential \
        cmake \
        && rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y \
        python3 \
        python3-pip \
        && rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y \
        python3-venv \
        && rm -rf /var/lib/apt/lists/*

# Set a working directory inside the container (optional)
WORKDIR /root

# clone openfhe-python-packager to /root
RUN git clone https://github.com/openfheorg/openfhe-python-packager.git

# Set the default command to run when the container starts
### CMD ["/bin/bash"]

# prepare to build the wheel
WORKDIR /root/openfhe-python-packager

# for testing purposes:
# # # RUN git fetch origin; git pull origin; git status
# # # RUN git checkout docker-build

# override ci-vars.sh with the correct os name and release
RUN sed -i '/^OS_NAME=/c\OS_NAME=Ubuntu' /root/openfhe-python-packager/ci-vars.sh
RUN sed -i '/^OS_RELEASE=/c\OS_RELEASE=20.04' /root/openfhe-python-packager/ci-vars.sh
# other ci-vars.sh overrides
RUN sed -i '/^OPENFHE_TAG=/c\OPENFHE_TAG='${OPENFHE_TAG_ARG} /root/openfhe-python-packager/ci-vars.sh &&                         \
    sed -i '/^OPENFHE_PYTHON_TAG=/c\OPENFHE_PYTHON_TAG='${OPENFHE_PYTHON_TAG_ARG} /root/openfhe-python-packager/ci-vars.sh &&    \
    sed -i '/^WHEEL_MINOR_VERSION=/c\WHEEL_MINOR_VERSION='${WHEEL_MINOR_VERSION_ARG} /root/openfhe-python-packager/ci-vars.sh && \
    sed -i '/^WHEEL_TEST_VERSION=/c\WHEEL_TEST_VERSION='${WHEEL_TEST_VERSION_ARG} /root/openfhe-python-packager/ci-vars.sh &&    \
    sed -i '/^PARALLELISM=/c\PARALLELISM='${PARALLELISM_ARG} /root/openfhe-python-packager/ci-vars.sh

# build the wheel
RUN /root/openfhe-python-packager/build_openfhe_wheel.sh

