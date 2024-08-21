#!/bin/bash

docker stop buildev
docker image rm jak/buildev

#docker build -t jak/buildev .
docker build -f Dockerfile.jak -t jak/buildev .

CONTAINER_NETWORK=a360i

DEVBUILD_USER=$(docker inspect --format='{{.Config.User}}' jak/buildev);        \
docker run -d -it --name buildev --network $CONTAINER_NETWORK -h devbuild --network-alias devbuild   \
	-e MAVEN_USERNAME=admin --rm -v "/home/dev/home_dev:/home/$DEVBUILD_USER" -v "publi.vol:/publish" \
	-v "trans.vol:/xfer" -v "codev.vol:/home/$${DEVBUILD_USER}/code" -p 1022:22                        \
	jak/buildev bash

