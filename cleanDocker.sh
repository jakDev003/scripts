#!/bin/bash

# stop and remove all containers (ignoring portainer)
docker stop $(docker ps -a | grep -v "portainer" | awk 'NR>1 {print $1}')

# remove all unused containers, networks, images, and optionally volumes
docker system prune --all --force --volumes

# remove volumes that remain
docker volume rm $(docker volume ls -q --filter dangling=true)
