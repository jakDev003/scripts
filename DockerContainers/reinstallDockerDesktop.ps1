# Function to uninstall Docker Desktop
function Uninstall-DockerDesktop {
    Write-Host "Uninstalling Docker Desktop..."
    $uninstallerPath = "C:\Program Files\Docker\Docker\Docker Desktop Installer.exe"
    if (Test-Path $uninstallerPath) {
        Start-Process -FilePath $uninstallerPath -ArgumentList "uninstall" -Wait -NoNewWindow
        Write-Host "Docker Desktop uninstalled successfully."
    } else {
        Write-Host "Docker Desktop is not installed."
    }
}

# Function to install Docker Desktop
function Install-DockerDesktop {
    Write-Host "Installing Docker Desktop..."
    $installerUrl = "https://desktop.docker.com/win/stable/Docker%20Desktop%20Installer.exe"
    $installerPath = "$env:TEMP\DockerDesktopInstaller.exe"
    
    # Check if the installer already exists
    if (-Not (Test-Path $installerPath)) {
        Write-Host "Downloading Docker Desktop installer..."
        # Download the installer
        Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath
    } else {
        Write-Host "Docker Desktop installer already exists. Skipping download."
    }
    
    # Run the installer
    Start-Process -FilePath $installerPath -Wait -NoNewWindow
    Write-Host "Docker Desktop installed successfully."
}

# Main script execution
Uninstall-DockerDesktop
Install-DockerDesktop