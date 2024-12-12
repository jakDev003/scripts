# PowerShell script

Write-Host "Stopping current container if running"
if (docker ps -q -f name=buildev2) {
    docker stop buildev2
}

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
docker build --no-cache -f Dockerfile.jak -t jak/bd .

$CONTAINER_NETWORK = "a360i"

Write-Host "Running Container"
$DEVBUILD_USER = $(docker inspect --format='{{.Config.User}}' jak/bd)
docker run -d -it --name buildev2 --network $CONTAINER_NETWORK -h devbuild --network-alias devbuild `
    -e MAVEN_USERNAME=admin --rm -v "/home/dev/home_dev:/home/$DEVBUILD_USER" -v "publi.vol:/publish" `
    -v "trans.vol:/xfer" -v "codev.vol:/home/$DEVBUILD_USER/code" -p 1023:22 `
    jak/bd bash
