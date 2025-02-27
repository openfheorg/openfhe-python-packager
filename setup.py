import os
import subprocess

def get_ci_vars(filepath):
    ci_vars = {}
    with open(filepath, 'r') as f:
        for line in f:
            # leading/trailing whitespace
            line = line.strip()
            # empty lines or comments
            if not line or line.startswith('#'):
                continue

            if '=' in line:
                key, value = line.split('=', 1)
                ci_vars[key.strip()] = value.strip()

    return ci_vars

# get values from ci-vars.sh
filepath = os.path.join(os.path.dirname(os.path.abspath(__file__)), "ci-vars.sh")
ci_vars = get_ci_vars(filepath)
###################################################################################

from setuptools import setup, find_packages

setup(
    name='openfhe',
    version=ci_vars["WHEEL_VERSION"],
    description='Python wrapper for OpenFHE C++ library.',
    author='OpenFHE Team',
    author_email='contact@openfhe.org',
    url='https://github.com/openfheorg/openfhe-python',
    license='BSD-2-Clause',
    packages=find_packages(where='build/wheel-root'),
    package_dir={'': 'build/wheel-root'},
    include_package_data=True,
    package_data={
        'openfhe': ['lib/*.so', 'lib/*.so.1', '*.so', 'build-config.txt'],
    },
    python_requires=">=" + ci_vars["PYTHON_VERSION"],
    classifiers=[
        "Operating System :: POSIX :: Linux",
        # add other classifiers as needed
    ],
    long_description=ci_vars["LONG_DESCRIPTION"],
    long_description_content_type='text/markdown',  # format

)

