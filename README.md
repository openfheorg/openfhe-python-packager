# This repository contains scripts to build a python wheel for openfhe-python (Python wrapper for OpenFHE C++ library).


## How to build a new wheel

### Docker build

1. Edit [ci-vars.sh](https://github.com/openfheorg/openfhe-python-packager/blob/main/ci-vars.sh) to update repo tags or build settings as needed. These changes will be picked up automatically by the build script.
2. Run [build_openfhe_wheel_docker_ubu_24.sh](https://github.com/openfheorg/openfhe-python-packager/blob/main/build_openfhe_wheel_docker_ubu_24.sh) for Ubuntu 24.04 or use the corresponding script for your operating system (if available).  
   - The script builds a new docker image and generate the wheel.
   - Once the build is complete, the script will create a directory named `wheel_<os_name>` (e.g., `wheel_ubuntu_24.04` for Ubuntu 24.04) on your local machine and copy the generated wheel from the docker container to that directory.

### Local build

1. Prerequisites:  
   Before building, make sure the following dependencies are installed (**do not clone the repos manually**):
   - For [openfhe-development](https://github.com/openfheorg/openfhe-development): ensure all its dependencies are installed. 
   - For [openfhe-python](https://github.com/openfheorg/openfhe-python): only `python3` and `python3-pip` are required.
2. Build steps:  
   - Adjust the repo tags/settings in [ci-vars.sh](https://github.com/openfheorg/openfhe-python-packager/blob/main/ci-vars.sh) as needed.
   - Run [build_openfhe_wheel.sh](https://github.com/openfheorg/openfhe-python-packager/blob/main/build_openfhe_wheel.sh).
   - The built distribution package will be available in the `./build/dist` directory.
   - The resulting wheel includes an `openfhe/build-config.txt` file with all settings used from ci-vars.sh.

## Intel HEXL-enabled builds

To build a wheel with the Intel HEXL acceleration backend, set `BUILD_HEXL=ON` in
[ci-vars.sh](ci-vars.sh). When enabled, the build clones
[openfhe-hexl](https://github.com/openfheorg/openfhe-hexl) at `OPENFHE_HEXL_TAG`,
overlays its sources onto the `openfhe-development` tree, and configures OpenFHE with
`-DWITH_INTEL_HEXL=ON` — the same staging that
[openfhe-configurator](https://github.com/openfheorg/openfhe-configurator) performs.

Make sure `OPENFHE_HEXL_TAG` matches `OPENFHE_TAG` (e.g. `OPENFHE_TAG=v1.5.1` pairs
with `OPENFHE_HEXL_TAG=v1.5.1.0`).

> **Note:** Intel HEXL targets x86-64 CPUs with AVX-512. A HEXL-enabled wheel will
> not import on arm64 (e.g. Apple Silicon); build it for an x86-64 target, for
> example via the Docker build scripts.
