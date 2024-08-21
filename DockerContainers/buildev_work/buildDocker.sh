#!/bin/bash

docker stop buildev2
docker image rm jak/bd

#docker build -t jak/buildev .
docker build -f Dockerfile.jak -t jak/bd .

CONTAINER_NETWORK=a360i

DEVBUILD_USER=$(docker inspect --format='{{.Config.User}}' jak/bd);        \
docker run -d -it --name buildev2 --network $CONTAINER_NETWORK -h devbuild --network-alias devbuild   \
	-e MAVEN_USERNAME=admin --rm -v "/home/dev/home_dev:/home/$DEVBUILD_USER" -v "publi.vol:/publish" \
	-v "trans.vol:/xfer" -v "codev.vol:/home/$${DEVBUILD_USER}/code" -p 1023:22                        \
	jak/bd bash

