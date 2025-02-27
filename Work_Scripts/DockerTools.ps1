# ReinstallDockerCli.ps1
# This script provides functionality to uninstall and install Docker CLI components on a Windows system.
# It uses the Windows Package Manager (winget) to manage Docker installations and Windows Subsystem for Linux (WSL) for Docker Desktop.

param(
    [switch]$Uninstall, # Use this switch to uninstall Docker and Wsl and Wsl Containers
    [switch]$Install, # Use this switch to install Docker components
    [switch]$Clean # Use this switch to clean Docker components
)

function Clean
{

    # Remove all unused containers, networks, images (both dangling and unreferenced), and optionally volumes.
    # The --all flag removes all unused images not just dangling ones.
    # The --force flag bypasses confirmation prompts.
    # The --volumes flag removes all unused volumes.
    docker system prune --all --force --volumes

    # Stop all running containers.
    docker stop $( docker ps -q -a )

    # Remove all containers.
    docker rm $( docker ps -q -a )

    # Remove all images.
    docker rmi $( docker images -qa )

    # Remove dangling images.
    docker image prune -f

    # Remove all volumes.
    docker volume rm $( docker volume ls -q )

    # Remove dangling volumes.
    docker volume prune

    # Remove all networks.
    docker network rm $( docker network ls -q )

    # Remove dangling networks.
    docker network prune
}

function Install
{
    # This script will install WSL2, set Ubuntu as the default distribution, and install Docker Desktop on Windows 10 using winget

    # Enable the WSL feature
    Write-Output "Enabling WSL feature..."
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

    # Enable the Virtual Machine Platform feature
    Write-Output "Enabling Virtual Machine Platform feature..."
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

    # Download and install the WSL2 kernel update
    Write-Output "Downloading and installing the WSL2 kernel update..."
    $wslUpdateUrl = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"
    $wslUpdateInstaller = "$env:TEMP\wsl_update_x64.msi"
    Invoke-WebRequest -Uri $wslUpdateUrl -OutFile $wslUpdateInstaller
    Start-Process -FilePath msiexec.exe -ArgumentList "/i $wslUpdateInstaller /quiet /norestart" -NoNewWindow -Wait

    # Set WSL2 as the default version
    Write-Output "Setting WSL2 as the default version..."
    wsl --set-default-version 2

    # Install Ubuntu using winget
    Write-Output "Installing Ubuntu using winget..."
    winget install -e --id Canonical.Ubuntu

    # Set Ubuntu as the default WSL distribution
    Write-Output "Setting Ubuntu as the default WSL distribution..."
    wsl --set-default Ubuntu

    # Install Docker Desktop using winget
    Write-Output "Installing Docker Desktop using winget..."
    winget install -e --id Docker.DockerDesktop

    Write-Output "Installation complete. Please restart your computer to apply all changes."
}

function Uninstall
{
    # Uninstall Docker Desktop using winget
    Write-Output "Uninstalling Docker Desktop using winget..."
    winget uninstall -e --id Docker.DockerDesktop

    # Uninstall Ubuntu using winget
    Write-Output "Uninstalling Ubuntu using winget..."
    winget uninstall -e --id Canonical.Ubuntu

    # Remove the WSL2 kernel update
    Write-Output "Removing the WSL2 kernel update..."
    $wslUpdateInstaller = "$env:TEMP\wsl_update_x64.msi"
    if (Test-Path $wslUpdateInstaller) {
        Remove-Item $wslUpdateInstaller
    }

    # Disable the Virtual Machine Platform feature
    Write-Output "Disabling Virtual Machine Platform feature..."
    dism.exe /online /disable-feature /featurename:VirtualMachinePlatform /norestart

    # Disable the WSL feature
    Write-Output "Disabling WSL feature..."
    dism.exe /online /disable-feature /featurename:Microsoft-Windows-Subsystem-Linux /norestart

    Write-Output "Uninstallation complete. Please restart your computer to apply all changes."
}

# Display help menu
function Show-Help
{
    Write-Host "Usage: .\DockerTools.ps1 [-Uninstall] [-Install]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -Uninstall                   Uninstall Docker CLI, Docker Desktop, Docker Compose, Wsl and it's containers."
    Write-Host "  -Install                     Install Docker CLI, Docker Desktop, and Docker Compose."
    Write-Host "  -Clean                       Remove all containers, images, volumes and networks."
    Write-Host ""
    Write-Host "Example:"
    Write-Host "  .\DockerTools.ps1 -Uninstall"
    Write-Host "  .\DockerTools.ps1 -Install"
    Write-Host "  .\DockerTools.ps1 -Clean"
}

# Main script logic
if ($Uninstall)
{
    Uninstall
}
elseif ($Install)
{
    Install
}
elseif ($Clean)
{
    Clean
}
else
{
    Show-Help
}
