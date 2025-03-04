param (
    [switch]$RemoveOldImage
)

$tagName = "jak/buildev"

if ($RemoveOldImage -and (docker images -q $tagName))
{
    Write-Host "Removing old image if found"
    docker image rm $tagName
}

if (-not (docker images -q rockylinux:9.3))
{
    Write-Host "Pulling image"
    docker pull rockylinux:9.3
}

Write-Host "Building Image"
docker build --no-cache -t $tagName .

# Check if the image was built successfully
if (docker images -q $tagName)
{
    Write-Host "Image built successfully. Running Container"
    $CONTAINER_NETWORK = "a360i"

    # Check if the network exists, if not create it
    if (-not (docker network ls -q -f name=^$CONTAINER_NETWORK$))
    {
        Write-Host "Network $CONTAINER_NETWORK not found. Creating network."
        docker network create $CONTAINER_NETWORK
    }

    # Check if the volumes exist, if not create them
    $volumes = @("publi.vol", "trans.vol", "home_dev.vol")
    foreach ($volume in $volumes)
    {
        if (-not (docker volume ls -q -f name=^$volume$))
        {
            Write-Host "Volume $volume not found. Creating volume."
            docker volume create $volume
        }
    }

    $DEVBUILD_USER = $( docker inspect --format='{{.Config.User}}' $tagName )
    if (-not $DEVBUILD_USER)
    {
        $DEVBUILD_USER = "default_user" # Fallback to a default user if not found
    }

    $containerId = $(docker run -d -it --name buildev2 --network $CONTAINER_NETWORK -h devbuild --network-alias devbuild `
    -e MAVEN_USERNAME=admin --rm  `
    -v "home_dev.vol:/home/$DEVBUILD_USER" `
    -v "publi.vol:/publish" `
    -v "trans.vol:/xfer" `
    -p 1023:22 `
    -v "C:\Users\$env:USERNAME\.ssh:/home/$DEVBUILD_USER/.ssh" `
    $tagName bash)

    # Copy contents of home_dev directory to the container
    Write-Host "Copying contents of home_dev to the container"
    docker cp "DockerContainers/buildev_work/home_dev/." "${containerId}:/home/$DEVBUILD_USER"

    Write-Host "Container started and files copied successfully."
}
else
{
    Write-Host "Image build failed. Container will not be run."
}
