# This repository contains scripts to build a python wheel for openfhe-python (Python wrapper for OpenFHE C++ library).


## How to build a new wheel

### Docker build

1. Edit [ci-vars.sh](https://github.com/openfheorg/openfhe-python-packager/blob/main/ci-vars.sh) to update repo versions or build settings as needed. These changes will be picked up automatically by the build script.
2. Run [build_openfhe_wheel_docker_ubu_24.sh](https://github.com/openfheorg/openfhe-python-packager/blob/main/build_openfhe_wheel_docker_ubu_24.sh) for Ubuntu 24.04 or use the appropriate script for your operating system (if available).  
   - The script builds a new docker image and generate the wheel inside it.
   - Once the build is complete, the script will create a directory named `wheel_<os_name>` (e.g., `wheel_ubuntu_24.04` for Ubuntu 24.04) on your local machine and copy the generated `*.whl` and `*.tar.gz` files from the docker container to that directory.

### Manual build

1. Prerequisites:  
   Before building, make sure the following dependencies are installed (**do not clone the repos manually**):
   - For [openfhe-development](https://github.com/openfheorg/openfhe-development): ensure all its dependencies are installed. 
   - For [openfhe-python](https://github.com/openfheorg/openfhe-python): only `python3` and `python3-pip` are required.
2. Build steps:  
   - Adjust the repo versions/settings in [ci-vars.sh](https://github.com/openfheorg/openfhe-python-packager/blob/main/ci-vars.sh) as needed.
   - Run [build_openfhe_wheel.sh](https://github.com/openfheorg/openfhe-python-packager/blob/main/build_openfhe_wheel.sh).
   - The built distribution package will be available in the `./build/dist` directory.
   - The resulting wheel includes an `openfhe/build-config.txt` file with all settings used from ci-vars.sh.
