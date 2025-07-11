OS_NAME=Ubuntu
OS_RELEASE=24.04
OPENFHE_TAG=v1.3.1
OPENFHE_PYTHON_TAG=v1.3.1.0
# subsequent release number for the given OPENFHE_TAG.
WHEEL_MINOR_VERSION=0
# Example of a wheel version based on the vars values in this file:
# OS_RELEASE=20.04
# OPENFHE_TAG=v1.2.3
# WHEEL_MINOR_VERSION=9
# then the wheel version will be: 1.2.3.9.20.04

# DO NOT set WHEEL_TEST_VERSION unless you are building a test/dev wheel.
# if WHEEL_TEST_VERSION=5 then the wheel version will be: 1.2.3.9.20.04.dev5
WHEEL_TEST_VERSION=

# PARALELLISM is used to expedite the build process in ./scripts/common-functions.sh
PARALELLISM=11
