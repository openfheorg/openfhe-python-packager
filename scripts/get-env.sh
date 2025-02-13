#!/bin/sh

# create and/or activate the virtual environment for the build
VENV_DIR="./env_for_openfhe_wheel"
if [ ! -d ${VENV_DIR} ]; then
    python3 -m venv ${VENV_DIR}
    . ${VENV_DIR}/bin/activate

    # install all necessary packages
    python3 -m pip install "pybind11[global]"
    # pip install pybind11-stubgen
    python3 -m pip install --upgrade pip setuptools wheel build
else
    # source ${VENV_DIR}/bin/activate
    . ${VENV_DIR}/bin/activate
fi

