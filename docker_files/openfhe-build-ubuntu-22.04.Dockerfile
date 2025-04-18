# Use Ubuntu 22.04 as the base image and set the correct OS description in ci-vars.sh below
FROM ubuntu:22.04

# Set environment variable to disable interactive prompts during package installs
ENV DEBIAN_FRONTEND=noninteractive

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
RUN sed -i '/^OS_RELEASE=/c\OS_RELEASE=22.04' /root/openfhe-python-packager/ci-vars.sh

# build the wheel
RUN /root/openfhe-python-packager/build_openfhe_wheel.sh

