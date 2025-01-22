<#
.SYNOPSIS
    This script manages the installation and uninstallation of Docker Desktop and WSL.

.DESCRIPTION
    This script checks if Docker Desktop is installed and performs actions based on the provided parameter.
    If the parameter 'action' is null, empty, or 'quick', it will uninstall Docker Desktop and reinstall it using winget.
    If the parameter 'action' is 'full', it will uninstall Docker Desktop and WSL if they are installed, or install them if they are not.

.PARAMETER action
    Specifies the action to perform. Valid values are 'quick' and 'full'.
    - 'quick': Uninstall Docker Desktop and reinstall it using winget.
    - 'full': Uninstall Docker Desktop and WSL if they are installed, or install them if they are not.

.EXAMPLE
    .\ReinstallDocker.ps1 -action quick
    This will uninstall Docker Desktop and reinstall it using winget.

    .\ReinstallDocker.ps1 -action full
    This will uninstall Docker Desktop and WSL if they are installed, or install them if they are not.
#>

param (
    [string]$action
)

# Check if Docker Desktop is installed
$dockerDesktop = Get-CimInstance -ClassName Win32_Product | Where-Object { $_.Name -like "Docker Desktop*" }

if (-not $action -or $action -eq "quick") {
    # Quick action: Uninstall and reinstall Docker Desktop
    if ($dockerDesktop) {
        Write-Output "Docker Desktop found. Uninstalling Docker Desktop..."
        winget uninstall --id Docker.DockerDesktop -e
    } else {
        Write-Output "Docker Desktop not found."
    }
    Write-Output "Installing Docker Desktop..."
    winget install --id Docker.DockerDesktop -e --source winget
} elseif ($action -eq "full") {
    if ($dockerDesktop) {
        Write-Output "Docker Desktop found. Uninstalling Docker Desktop and WSL..."
        winget uninstall --id Docker.DockerDesktop -e
        Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
    } else {
        Write-Output "Docker Desktop not found."
    }
    Write-Output "Enabling WSL and installing Docker Desktop..."
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -All
    winget install --id Docker.DockerDesktop -e --source winget
} else {
    Write-Output "Invalid action specified. Use 'quick' or 'full'."
}