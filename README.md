# This repo is a collection of scripts to build a wheel out of openfhe-python (Python wrapper for OpenFHE C++ library).


## How to create a new wheel

### Prerequisites

Before building, make sure you have installed all dependencies **(do not clone these repos)**:

- for [openfhe-development](https://github.com/openfheorg/openfhe-development).
- for [openfhe-python](https://pybind11.readthedocs.io/en/stable/installing.html) you need to have only 2 packages installed: python3 and python3-pip.

### Building a new wheel

- Adjust settings in [ci-vars.sh](https://github.com/openfheorg/openfhe-python-packager/blob/main/ci-vars.sh) as needed.
- Run [build_openfhe_wheel.sh](https://github.com/openfheorg/openfhe-python-packager/blob/main/build_openfhe_wheel.sh).
- The package built for distribution will be available in **./build/dist**.
- The wheel includes a file **openfhe/build-config.txt** with all settings from ci-vars.sh used to build the wheel. 
