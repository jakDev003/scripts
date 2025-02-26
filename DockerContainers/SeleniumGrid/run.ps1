# Define the images to be pulled
$images = @(
    "selenium/node-chromium:latest",
    "selenium/node-firefox:latest",
    "selenium/node-edge:latest",
    "selenium/node-opera:latest",
    "selenium/node-safari:latest",
    "selenium/hub:latest"
)

# Pull the images if they are not already present
foreach ($image in $images) {
    if (-not (docker images -q $image)) {
        Write-Host "   =====> Pulling image $image..."
        docker pull --tls-verify=false $image
    } else {
        Write-Host "   =====> Image $image already exists."
    }
}

# Run docker-compose down
Write-Host "   =====> Running docker-compose down..."
docker-compose down

# Run docker-compose up with the specified options
Write-Host "   =====> Running docker-compose up -d --force-recreate --build..."
docker-compose up -d --force-recreate --build