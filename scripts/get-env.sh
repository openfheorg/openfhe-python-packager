#!/bin/sh

. ./ci-vars.sh

if [ -z "${PYTHON_VERSION:-}" ]; then
    SYSTEM_PYTHON=python3
else
    SYSTEM_PYTHON="/usr/bin/python${PYTHON_VERSION}"
    PYTHON_PACKAGES="python${PYTHON_VERSION} python${PYTHON_VERSION}-venv python${PYTHON_VERSION}-dev"
    if [ ! -x "${SYSTEM_PYTHON}" ] || ! dpkg-query -W ${PYTHON_PACKAGES} >/dev/null 2>&1; then
        SUDO=
        [ "$(id -u)" -eq 0 ] || SUDO=sudo
        echo "Installing Python ${PYTHON_VERSION} from the deadsnakes PPA ..."
        ${SUDO} apt-get update
        ${SUDO} apt-get install -y software-properties-common
        ${SUDO} add-apt-repository -y ppa:deadsnakes/ppa
        ${SUDO} apt-get update
        ${SUDO} apt-get install -y ${PYTHON_PACKAGES}
    fi
fi

# create and/or activate the virtual environment for the build
VENV_DIR="./env_for_openfhe_wheel"
if [ -d ${VENV_DIR} ] && \
   [ "$(${VENV_DIR}/bin/python -c 'import sys; print(".".join(map(str, sys.version_info[:2])))' 2>/dev/null)" != \
     "$(${SYSTEM_PYTHON} -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')" ]; then
    echo "Recreating ${VENV_DIR}: it does not use ${SYSTEM_PYTHON}"
    rm -rf ${VENV_DIR}
fi

if [ ! -d ${VENV_DIR} ]; then
    ${SYSTEM_PYTHON} -m venv ${VENV_DIR}
    . ${VENV_DIR}/bin/activate

    # install all necessary packages
    python3 -m pip install "pybind11[global]"
    # pip install pybind11-stubgen
    python3 -m pip install --upgrade pip setuptools wheel build
    python3 -m pip install twine
else
    # source ${VENV_DIR}/bin/activate
    . ${VENV_DIR}/bin/activate
fi

PYTHON_EXE="${VIRTUAL_ENV}/bin/python"
export PYTHON_EXE
