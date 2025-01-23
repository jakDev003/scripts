# 1. Make sure the Microsoft App Installer is installed:
#    https://www.microsoft.com/en-us/p/app-installer/9nblggh4nns1
# 2. Edit the list of apps to install.
# 3. Run this script as administrator.

Write-Output "Installing Apps"
$apps = @(
    @{name = "7zip.7zip"},
    @{name = "Adobe.Acrobat.Reader.64-bit"},
    @{name = "Apache.Groovy.4"},
    @{name = "Amazon.AWSCLI"},
    # @{name = "Axosoft.GitKraken"},
    # @{name = "Devolutions.RemoteDesktopManagerFree"},
    # @{name = "Dropbox.Dropbox"},
    @{name = "Brave.Brave"},
    @{name = "DEVCOM.JetBrainsMonoNerdFont"},
    @{name = "Docker.DockerDesktop"},
    @{name = "Git.Git"},
    @{name = "GnuPG.Gpg4win"},
    @{name = "Google.Chrome"},
    @{name = "Greenshot.Greenshot"},
    # @{name = "Inkscape.Inkscape"},
    # @{name = "JanDeDobbeleer.OhMyPosh"},
    @{name = "JesseDuffield.lazygit"},
    @{name = "JetBrains.IntelliJIDEA.Community"},
    @{name = "JetBrains.PyCharm.Community"},
    @{name = "JetBrains.Rider"},
    @{name = "JetBrains.Toolbox"},
    @{name = "JetBrains.WebStorm"},
    @{name = "JohnMacFarlane.Pandoc"},
    # @{name = "KDE.KDiff3"},
    @{name = "Microsoft.AzureDataStudio"}, # Included with SSMS
    @{name = "Kitware.CMake"},
    @{name = "LLVM.LLVM"},
    @{name = "Microsoft.dotnet"},
    @{name = "Microsoft.PowerShell"},
    @{name = "Microsoft.PowerToys"},
    # @{name = "Microsoft.SQLServerManagementStudio"}, # Includes AzureDataStudio
    # @{name = "Microsoft.VisualStudio.2022.Community"},
    @{name = "Microsoft.VisualStudio.2022.BuildTools"},
    @{name = "Microsoft.VisualStudioCode"},
    # @{name = "Microsoft.WindowsTerminal"},
    # @{name = "Mozilla.Firefox"},
    @{name = "Neovim.Neovim"},
    @{name = "NickeManarin.ScreenToGif"},
    @{name = "Notepad++.Notepad++"},
    @{name = "OBSProject.OBSStudio"},
    @{name = "OpenJS.NodeJS.LTS"},
    @{name = "OpenShot.OpenShot"},
    @{name = "Spotify.Spotify"},
    @{name = "TimKosse.FileZilla.Client"},
    @{name = "VideoLAN.VLC"},
    @{name = "WinDirStat.WinDirStat"}
    # @{name = "Zoom.Zoom"}
);
Foreach ($app in $apps) {
    $listApp = winget list --exact -q $app.name
    if (![String]::Join("", $listApp).Contains($app.name)) {
        Write-host "Installing: " $app.name
        winget install -e -h --accept-source-agreements --accept-package-agreements --id $app.name 
    }
    else {
        Write-host "Skipping: " $app.name " (already installed)"
    }
}

# Install non-Winget apps
# Install LazyGit
$url = "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_Windows_x86_64.zip"
$output = "$env:TEMP\lazygit.zip"
Invoke-WebRequest -Uri $url -OutFile $output
$destination = "$env:ProgramFiles\lazygit"
Expand-Archive -Path $output -DestinationPath $destination
$path = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
$newPath = "$path;$destination"
[System.Environment]::SetEnvironmentVariable("Path", $newPath, [System.EnvironmentVariableTarget]::Machine)
lazygit --version
