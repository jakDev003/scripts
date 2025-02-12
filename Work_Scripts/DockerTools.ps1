# ReinstallDockerCli.ps1
# This script provides functionality to uninstall and install Docker CLI components on a Windows system.
# It uses the Windows Package Manager (winget) to manage Docker installations and Windows Subsystem for Linux (WSL) for Docker Desktop.

param(
    [switch]$Uninstall,              # Use this switch to uninstall Docker and Wsl and Wsl Containers
    [switch]$Install,                # Use this switch to install Docker components
    [switch]$UninstallDocker,        # Use this switch to uninstall Docker components
    [switch]$UninstallWsl,           # Use this switch to uninstall Wsl
    [switch]$UninstallWslContainers  # Use this switch to uninstall Wsl Containers
)

function CleanDocker {

    # Remove all unused containers, networks, images (both dangling and unreferenced), and optionally volumes.
    # The --all flag removes all unused images not just dangling ones.
    # The --force flag bypasses confirmation prompts.
    # The --volumes flag removes all unused volumes.
    docker system prune --all --force --volumes

    # Stop all running containers.
    docker stop $(docker ps -q -a)

    # Remove all containers.
    docker rm $(docker ps -q -a)

    # Remove all images.
    docker rmi $(docker images -qa)

    # Remove dangling images.
    docker image prune -f

    # Remove all volumes.
    docker volume rm $(docker volume ls -q)

    # Remove dangling volumes.
    docker volume prune

    # Remove all networks.
    docker network rm $(docker network ls -q)

    # Remove dangling networks.
    docker network prune
}

function Uninstall-Wsl-Containers {
        # Get the list of all installed WSL distributions with details
    $wslDistributions = wsl --list --verbose
    
    # Output the found distributions
    Write-Host "Found WSL distributions:"
    Write-Host $wslDistributions
    
    # Extract distribution names
    $distributionNames = $wslDistributions -split "`n" | Select-Object -Skip 1 | ForEach-Object { ($_ -split '\s{2,}')[0] }
    
    # Check if there are any distributions installed
    if ($distributionNames) {
        # Loop through each distribution and unregister it
        foreach ($distro in $distributionNames) {
            if ($distro -ne "") {
                Write-Host "Unregistering WSL distribution: $distro"
                try {
                    wsl --unregister $distro
                    Write-Host "Unregistered: $distro"
                } catch {
                Write-Host "Failed to unregister: $distro"
                }
            }
        }
        Write-Host "All WSL distributions have been processed."
    } else {
        Write-Host "No WSL distributions found."
    }
}

function Uninstall-Wsl {
    Write-Host "Uninstalling WSL and WSL2..."
    Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
    Disable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform
}

# Function to uninstall Docker components
function Uninstall-DockerComponents {
    Write-Host "Checking for Docker CLI..."
    if (Get-Command docker -ErrorAction SilentlyContinue) {
        Write-Host "Uninstalling Docker CLI..."
        winget uninstall --id Docker.DockerCli -e
    } else {
        Write-Host "Docker CLI not found."
    }

    Write-Host "Checking for Docker Desktop..."
    if (Get-WmiObject -Query "SELECT * FROM Win32_Product WHERE Name LIKE 'Docker Desktop%'") {
        Write-Host "Uninstalling Docker Desktop..."
        winget uninstall --id Docker.DockerDesktop -e
    } else {
        Write-Host "Docker Desktop not found."
    }

    Write-Host "Checking for Docker Compose..."
    if (Get-Command docker-compose -ErrorAction SilentlyContinue) {
        Write-Host "Uninstalling Docker Compose..."
        winget uninstall --id Docker.DockerCompose -e
    } else {
        Write-Host "Docker Compose not found."
    }

}

# Function to install Docker components
function Install-DockerComponents {
    Write-Host "Checking for WSL..."
    if (-Not (Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux).State -eq "Enabled") {
        Write-Host "Installing WSL..."
        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
        Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform
    } else {
        Write-Host "WSL is already installed."
    }

    Write-Host "Checking for Docker CLI..."
    if (-Not (Get-Command docker -ErrorAction SilentlyContinue)) {
        Write-Host "Installing Docker CLI..."
        winget install --id Docker.DockerCli -e
    } else {
        Write-Host "Docker CLI is already installed."
    }

    Write-Host "Checking for Docker Compose..."
    if (-Not (Get-Command docker-compose -ErrorAction SilentlyContinue)) {
        Write-Host "Installing Docker Compose..."
        winget install --id Docker.DockerCompose -e
    } else {
        Write-Host "Docker Compose is already installed."
    }
}

# Display help menu
function Show-Help {
    Write-Host "Usage: .\ReinstallDockerCli.ps1 [-Uninstall] [-Install]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -Uninstall                   Uninstall Docker CLI, Docker Desktop, Docker Compose, Wsl and it's containers."
    Write-Host "  -Install                     Install Docker CLI, Docker Desktop, and Docker Compose."
    Write-Host "  -UninstallDocker             Uninstall Docker CLI, Docker Desktop, and Docker Compose."
    Write-Host "  -UninstallWsl                Uninstall Wsl."
    Write-Host "  -UninstallWslContainers      Uninstall Wsl Containers."
    Write-Host ""
    Write-Host "Example:"
    Write-Host "  .\ReinstallDockerCli.ps1 -Uninstall"
    Write-Host "  .\ReinstallDockerCli.ps1 -Install"
}

# Main script logic
if ($Uninstall) {
    Uninstall-DockerComponents
    Uninstall-Wsl-Containers
    Uninstall-Wsl
} elseif ($Install) {
    Install-DockerComponents
} elseif ($UninstallWsl) {
    Uninstall-Wsl
} elseif ($UninstallWslContainers) {
    Uninstall-Wsl-Containers
} elseif ($UninstallDocker) {
    Uninstall-DockerComponents
} else {
    Show-Help
}