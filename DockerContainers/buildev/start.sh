#!/bin/bash

docker compose down

#docker image rm buildev_jak

docker compose up -d --build --force-recreate

docker exec -it buildev_jak bash
