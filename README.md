# This repo is a collection of scripts to build a wheel out of openfhe-python (Python wrapper for OpenFHE C++ library).


## How to create a new wheel

### Prerequisites

Before building, make sure you have installed all dependencies required by 

- [openfhe-development](https://github.com/openfheorg/openfhe-development)
- [openfhe-python](https://pybind11.readthedocs.io/en/stable/installing.html)

**Attention:** You DO NOT clone those repos, should install the packages required by them only.

### Building a new wheel

- Adjust settings in [ci-vars.sh](https://github.com/openfheorg/openfhe-python-packager/blob/main/ci-vars.sh) as needed
- Run [build_all.sh](https://github.com/openfheorg/openfhe-python-packager/blob/main/build_all.sh)

If the build is successfull, the wheel will be in **./build/dist**