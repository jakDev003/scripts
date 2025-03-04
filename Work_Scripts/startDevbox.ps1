# Define paths
$composeDir = "C:\Users\jkagiwada\Git-Repos\run_env\compose"
$dockerDir = "C:\Users\jkagiwada\Git-Repos\scripts\DockerContainers\buildev_work"

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
$containerName = "buildev2"
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