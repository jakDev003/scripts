# Check if Docker Desktop is installed
$dockerDesktop = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "Docker Desktop*" }

if ($dockerDesktop) {
    # Docker Desktop found
    Write-Output "Docker Desktop found. Disabling WSL and uninstalling Docker Desktop..."
    
    # Disable WSL
    Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
    
    # Uninstall Docker Desktop using winget
    winget uninstall --id Docker.DockerDesktop -e
} else {
    # Docker Desktop not found
    Write-Output "Docker Desktop not found. Enabling WSL and installing Docker Desktop..."
    
    # Enable WSL
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -All
    
    # Install Docker Desktop using winget with specified source
    winget install --id Docker.DockerDesktop -e --source winget
}