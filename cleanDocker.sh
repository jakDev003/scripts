#!/bin/bash

# containers
docker container stop $(docker container ls -aq)
docker container rm $(docker container ls -aq)

# images
docker rmi -f $(docker images -q)

# volumes
docker volume rm -f $(docker volume ls -q)

# networks
docker network rm -f $(docker network ls -q)

# anything else
docker system prune --all --force --volumes



