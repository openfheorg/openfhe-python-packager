#!/bin/sh

rm -rf ./build
rm -rf ./dist

# build the docker and the wheel in that docker
docker build -f docker_files/ubuntu24_build.Dockerfile -t ubuntu:24_build .
# --progress=plain || abort "openfhe-python:build failed"

# copy the wheel to the local machine
docker create --name temp-container ubuntu:24_build
docker cp temp-container:/root/openfhe-python-packager/build/dist .
docker rm temp-container

