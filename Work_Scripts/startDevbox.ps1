# Define paths
$composeDir = "C:\Users\jkagiwada\Git-Repos\run_env\compose"
$dockerDir = "C:\Users\jkagiwada\Git-Repos\build_dev\docker"
$containerName = "buildev2"

# Function to copy .ssh, .aws, and utils directory to home_dev
function Copy-Directories {
    $homeDevPath = "/home/dev"
    $sshSource = "${env:USERPROFILE}\.ssh"
    $awsSource = "${env:USERPROFILE}\.aws"
    $gitSource = "${env:USERPROFILE}\.gitconfig"
    $utilsSource = ".\home_dev"

    # Check if the container exists and is running
    try {
        $containerStatus = docker inspect -f '{{.State.Running}}' $containerName
        if ($containerstatus -ne "true") {
            Write-Host "    ==> Container $containerName is not running. Please start the container first."
            exit 1
        }
    }
    catch {
        Write-Host "    ==> Error inspecting the container. Please ensure Docker is running and the container exists."
        exit 1
    }

    # Copy .ssh directory
    docker cp $sshSource ${containerName}:${homeDevPath}

    # Copy .gitconfig file
    docker cp $gitSource ${containerName}:${homeDevPath}

    # Copy .aws directory
    docker cp $awsSource ${containerName}:${homeDevPath}

    # Copy utils directory contents
    docker cp $utilsSource\data.mk ${containerName}:${homeDevPath}
    docker cp $utilsSource\var.mk ${containerName}:${homeDevPath}
    docker cp $utilsSource\Makefile ${containerName}:${homeDevPath}
    docker cp $utilsSource\.bashrc ${containerName}:${homeDevPath}
    Write-Host "    ==> Copied .ssh, .gitconfig, .aws, and utils to the Docker volume"

    # Update permissions
    docker exec $containerName sudo chown -R dev:dev ${homeDevPath}
    docker exec $containerName sudo chmod -R 755 ${homeDevPath}
    docker exec $containerName sudo chmod -R 700 ${homeDevPath}/.ssh
    docker exec $containerName sudo chmod -R 700 ${homeDevPath}/.aws
    docker exec $containerName sudo chmod 600 ${homeDevPath}/.gitconfig

    Write-Host "    ==> Updated permissions"
}

# Check if paths exist
if (-not (Test-Path $composeDir)) {
    Write-Error "Compose directory not found: $composeDir"
    exit 1
}

if (-not (Test-Path $dockerDir)) {
    Write-Error "Docker build directory not found: $dockerDir"
    exit 1
}

# Start the compose environment
Write-Host "Starting compose environment..." -ForegroundColor Green
Push-Location $composeDir
try {
    if (-not (Test-Path ".\run.ps1")) {
        Write-Error "run.ps1 script not found in compose directory"
        exit 1
    }
    & ".\run.ps1" start
} catch {
    Write-Error "Failed to start compose environment: $_"
    exit 1
} finally {
    Pop-Location
}

# Build Docker container if not found
Write-Host "Starting buildev2 environment..." -ForegroundColor Green
# Build Docker container if not found
try {
   cd $dockerDir
    docker build -t buildev2:latest .

    # Run command
    docker run -d `
      --name buildev2 `
      --hostname devbuild2 `
      --network a360i `
      --memory="1g" `
      --cpus="0.3" `
      -e MAVEN_USERNAME=admin `
      -v home_dev.vol:/home/dev `
      -v publi.vol:/publish `
      -v trans.vol:/xfer `
      --restart unless-stopped `
      117076844353.dkr.ecr.us-east-2.amazonaws.com/devbuild:0.1.4 `
      /bin/sh -c "sudo chmod 777 /node-v16.19.1-linux-x64/ -R && sudo chown `$USER:`$USER . -R && tail -f /dev/null"
    Write-Host "Devbox startup completed successfully" -ForegroundColor Green
} catch {
    Write-Error "Failed to build and run Docker container: $_"
    exit 1
}

Write-Host "Devbox startup completed successfully" -ForegroundColor Green


Pause