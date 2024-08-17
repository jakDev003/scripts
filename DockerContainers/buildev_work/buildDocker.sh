#!/bin/bash

docker stop buildev
docker image rm jak/buildev

#docker build -t jak/buildev .
docker build -f Dockerfile.jak -t jak/buildev .
