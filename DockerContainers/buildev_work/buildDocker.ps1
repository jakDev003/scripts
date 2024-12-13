Write-Host "Removing old image if found"
if (docker images -q jak/bd) {
    docker image rm jak/bd
}

if (-not (docker images -q ubuntu:24.04)) {
    Write-Host "Pulling image"
    docker pull ubuntu:24.04
}

Write-Host "Building Image"
#docker build -t jak/buildev .
docker build -f Dockerfile.jak -t jak/bd .

# Check if the image was built successfully
if (docker images -q jak/bd) {
    Write-Host "Image built successfully. Running Container"
    $CONTAINER_NETWORK = "a360i"

    # Check if the network exists, if not create it
    if (-not (docker network ls -q -f name=^$CONTAINER_NETWORK$)) {
        Write-Host "Network $CONTAINER_NETWORK not found. Creating network."
        docker network create $CONTAINER_NETWORK
    }

    # Check if the volumes exist, if not create them
    $volumes = @("publi.vol", "trans.vol", "codev.vol")
    foreach ($volume in $volumes) {
        if (-not (docker volume ls -q -f name=^$volume$)) {
            Write-Host "Volume $volume not found. Creating volume."
            docker volume create $volume
        }
    }

    $DEVBUILD_USER = $(docker inspect --format='{{.Config.User}}' jak/bd)
    docker run -d -it --name buildev2 --network $CONTAINER_NETWORK -h devbuild --network-alias devbuild `
        -e MAVEN_USERNAME=admin --rm -v "/home/dev/home_dev:/home/$DEVBUILD_USER" -v "publi.vol:/publish" `
        -v "trans.vol:/xfer" -v "codev.vol:/home/$DEVBUILD_USER/code" -p 1023:22 `
        jak/bd bash
} else {
    Write-Host "Image build failed. Container will not be run."
}