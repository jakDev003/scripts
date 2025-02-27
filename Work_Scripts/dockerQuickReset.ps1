 Write-Host "   ===> Uninstalling Docker CLI"
 winget uninstall --id Docker.DockerCLI
 Write-Host "   ===> Uninstalling Docker Desktop"
 winget uninstall --id Docker.DockerDesktop
 Write-Host "   ===> Unregistering WSL Containers"
 wsl --unregister docker-desktop
 Write-Host "   ===> Shutting Down WSL"
 wsl --shutdown
 Write-Host "   ===> Uninstalling WSL"
 wsl --uninstall
 Write-Host "   ===> Installing Docker Desktop"
 winget install --id Docker.DockerDesktop
 Write-Host "   ===> Done!"