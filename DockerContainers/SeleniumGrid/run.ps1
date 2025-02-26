# Function to parse YAML file and extract image names
function Get-DockerImagesFromCompose {
    param (
        [string]$composeFilePath
    )

    $images = @()
    $yamlContent = Get-Content $composeFilePath -Raw

    $matches = [regex]::Matches($yamlContent, 'image:\s*(\S+)')
    foreach ($match in $matches) {
        $images += $match.Groups[1].Value
    }

    return $images
}

$composeFilePath = ".\docker-compose.yml"

# Get the list of images from the docker-compose.yml file
$images = Get-DockerImagesFromCompose -composeFilePath $composeFilePath

# Show the number of images found
Write-Host "   =====> Number of images found: $($images.Count)"


# Pull the images if they are not already present
foreach ($image in $images) {
    if (-not (docker images -q $image)) {
        Write-Host "   =====> Pulling image $image..."
        $pullProcess = Start-Process -FilePath "docker" -ArgumentList "pull", "$image" -NoNewWindow -PassThru -Wait
        if ($pullProcess.ExitCode -eq 0) {
            Write-Host "   =====> Successfully pulled image $image"
        } else {
            Write-Host "   =====> Failed to pull image $image" -ForegroundColor Red
        }
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