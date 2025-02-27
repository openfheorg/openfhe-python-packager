# Use Ubuntu 20.04 as the base image
FROM ubuntu:20.04

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
RUN apt-get update && pip3 install twine

# Set a working directory inside the container (optional)
WORKDIR /root

# clone openfhe-python-packager to /root
RUN git clone https://github.com/openfheorg/openfhe-python-packager.git

# Set the default command to run when the container starts
CMD ["/bin/bash"]

