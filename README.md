# This repository contains scripts to build a python wheel for openfhe-python (Python wrapper for OpenFHE C++ library).


## How to build a new wheel

### Python version

`PYTHON_VERSION` in [ci-vars.sh](https://github.com/openfheorg/openfhe-python-packager/blob/main/ci-vars.sh) is the single setting that controls the wheel's Python version:

- Set it to the desired `<major>.<minor>` version to build with that interpreter. Ubuntu local and Docker builds install the matching interpreter, venv module, and development headers from the [deadsnakes PPA](https://launchpad.net/~deadsnakes/+archive/ubuntu/ppa). A local build requires root or `sudo` access if those packages are not installed; a Docker build installs them only inside the image.
- Leave it empty or remove it to use the machine's default `python3`. Docker builds then use Ubuntu's default Python. For local builds, the default interpreter must have venv support and development headers available.

The build environment is recreated automatically when its Python major/minor version does not match the selected interpreter.

### Docker build

1. Edit [ci-vars.sh](https://github.com/openfheorg/openfhe-python-packager/blob/main/ci-vars.sh) to update repo tags or build settings as needed. These changes will be picked up automatically by the build script.
2. Run [build_openfhe_wheel_docker_ubu_24.sh](https://github.com/openfheorg/openfhe-python-packager/blob/main/build_openfhe_wheel_docker_ubu_24.sh) for Ubuntu 24.04 or use the corresponding script for your operating system (if available).  
   - The script builds a new Docker image and generates the wheel.
   - Once the build is complete, the script will create a directory named `wheel_<os_name>` (e.g., `wheel_ubuntu_24.04` for Ubuntu 24.04) on your local machine and copy the generated wheel from the docker container to that directory.

### Local build

1. Prerequisites:  
   Before building, make sure the following dependencies are installed (**do not clone the repos manually**):
   - For [openfhe-development](https://github.com/openfheorg/openfhe-development): ensure all its dependencies are installed. 
   - For [openfhe-python](https://github.com/openfheorg/openfhe-python): ensure the Python prerequisites described above are available.
2. Build steps:  
   - Adjust the repo tags/settings in [ci-vars.sh](https://github.com/openfheorg/openfhe-python-packager/blob/main/ci-vars.sh) as needed.
   - Run [build_openfhe_wheel.sh](https://github.com/openfheorg/openfhe-python-packager/blob/main/build_openfhe_wheel.sh).
   - The built distribution package will be available in the `./build/dist` directory.
   - The resulting wheel includes an `openfhe/build-config.txt` file with all settings used from ci-vars.sh.
