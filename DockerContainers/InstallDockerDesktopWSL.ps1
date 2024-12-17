# Function to install Docker Desktop
function Install-DockerDesktop {
    Write-Host "Installing Docker Desktop..."
    $installerUrl = "https://desktop.docker.com/win/stable/Docker%20Desktop%20Installer.exe"
    $installerPath = "$env:USERPROFILE\Temp\DockerDesktopInstaller.exe"
    
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

function InstallWSL {
    Write-Host "Installing Windows Subsystem for Linux..."
	Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
}

# Main script execution
InstallWSL
Install-DockerDesktop