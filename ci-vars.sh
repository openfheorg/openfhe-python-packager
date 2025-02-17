OPENFHE_TAG=v1.2.3
OPENFHE_PYTHON_TAG=v0.8.10
# WHEEL_VERSION is OPENFHE_PYTHON_TAG's version without letters.
# The suffix "2x.04" indicates the Ubuntu release which this wheel is built for.
# For Ubuntu 22.04 it is "22.04" and for Ubuntu 24.04 it is "24.04".
WHEEL_VERSION=1.2.3.0.24.04
# additional wheel description
LONG_DESCRIPTION="This release requires Ubuntu 24.04."
# python version for openfhe-python. should be installed by the user
PYTHON_VERSION=3.12
# c/c++ compiler version to build openfhe-development and openfhe-python. should be installed by the user
CXX_COMPILER=g++-14
C_COMPILER=gcc-14
# PARALELLISM is used to expedite the build process in ./scripts/common-functions.sh
PARALELLISM=11
