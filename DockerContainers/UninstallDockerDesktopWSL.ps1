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

function UninstallWSL {
    Write-Host "Uninstalling Windows Subsystem for Linux Distributions..."
    Get-ChildItem HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss\ |
        ForEach-Object {
            (Get-ItemProperty $_.PSPATH) | Select-Object DistributionName,BasePath
        }

    Write-Host "Uninstalling Windows Subsystem for Linux..."
	(Get-WindowsOptionalFeature -Online -FeatureName '*linux*') | Select-Object FeatureName
	Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
}

# Main script execution
Uninstall-DockerDesktop
UninstallWSL