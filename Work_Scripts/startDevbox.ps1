# Define paths
$composeDir = "C:\Users\jkagiwada\Git-Repos\run_env\compose"
$dockerDir = "C:\Users\jkagiwada\Git-Repos\scripts\DockerContainers\buildev_work"
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
        if ($containerStatus -ne "true") {
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
Write-Host "Checking if Docker container exists..." -ForegroundColor Green
$containerExists = docker ps -a --format "{{.Names}}" | Select-String -Pattern $containerName

if (-not $containerExists) {
    Write-Host "Docker container not found. Building Docker container..." -ForegroundColor Green
    Push-Location $dockerDir
    try {
        if (-not (Test-Path ".\buildDocker.ps1")) {
            Write-Error "buildDocker.ps1 script not found in Docker directory"
            exit 1
        }
        & ".\buildDocker.ps1"
        Copy-Directories
    } catch {
        Write-Error "Failed to build Docker container: $_"
        exit 1
    } finally {
        Pop-Location
    }
} else {
    Write-Host "Docker container already exists. Skipping build." -ForegroundColor Yellow
}

Write-Host "Devbox startup completed successfully" -ForegroundColor Green