#!/bin/bash

REMOVE_OLD_IMAGE=false

while getopts "r" opt; do
	case $opt in
		r)
			REMOVE_OLD_IMAGE=true
			;;
		\?)
			echo "Invalid option: -$OPTARG" >&2
			exit 1
			;;
	esac
done

TAG_NAME="jak/buildev"

if $REMOVE_OLD_IMAGE && [ "$(docker images -q $TAG_NAME)" ]; then
	echo "Removing old image if found"
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
	if [ -z "$(docker network ls -q -f name=^$CONTAINER_NETWORK$)" ]; then
		echo "Network $CONTAINER_NETWORK not found. Creating network."
		docker network create $CONTAINER_NETWORK
	fi

	# Check if the volumes exist, if not create them
	VOLUMES=("publi.vol" "trans.vol" "codev.vol")
	for VOLUME in "${VOLUMES[@]}"; do
		if [ -z "$(docker volume ls -q -f name=^$VOLUME$)" ]; then
			echo "Volume $VOLUME not found. Creating volume."
			docker volume create $VOLUME
		fi
	done

	DEVBUILD_USER=$(docker inspect --format='{{.Config.User}}' $TAG_NAME)
	docker run -d -it --name buildev2 --network $CONTAINER_NETWORK -h devbuild --network-alias devbuild \
		-e MAVEN_USERNAME=admin --rm -v "$HOME/home_dev:/home/$DEVBUILD_USER" -v "publi.vol:/publish" \
		-v "trans.vol:/xfer" -v "codev.vol:/home/$DEVBUILD_USER/code" -p 1023:22 \
		-v "$HOME/Git-Repos:/home/$DEVBUILD_USER/Git-Repos" \
		-v "$HOME/CustomCode:/home/$DEVBUILD_USER/CustomCode" \
		$TAG_NAME bash
else
	echo "Image build failed. Container will not be run."
fi