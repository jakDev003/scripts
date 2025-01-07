#!/bin/bash

REMOVE_OLD_IMAGE=false

while getopts "r" opt; do
	case $opt in
		r)
			REMOVE_OLD_IMAGE=true
			;;
		*)
			;;
	esac
done

TAG_NAME="jak/buildev"

echo "Removing old image if found"
if $REMOVE_OLD_IMAGE && [ "$(docker images -q $TAG_NAME)" ]; then
	docker image rm $TAG_NAME
fi

if [ -z "$(docker images -q rockylinux:9.3)" ]; then
	echo "Pulling image"
	docker pull rockylinux:9.3
fi

echo "Building Image"
docker build --no-cache -t $TAG_NAME .

# Check if the image was built successfully
if [ "$(docker images -q $TAG_NAME)" ]; then
	echo "Image built successfully. Running Container"
	CONTAINER_NETWORK="a360i"

	# Check if the network exists, if not create it
	if [ -z "$(docker network ls -q -f name=^${CONTAINER_NETWORK}$)" ]; then
		echo "Network $CONTAINER_NETWORK not found. Creating network."
		docker network create $CONTAINER_NETWORK
	fi
fi