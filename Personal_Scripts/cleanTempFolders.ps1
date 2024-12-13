$tempfolders = @("C:\Windows\Temp\*", "C:\Windows\Prefetch\*", "C:\Documents and Settings\*\Local Settings\temp\*", "C:\Users\*\Appdata\Local\Temp\*")

foreach ($folder in $tempfolders) {
    try {
        Get-ChildItem -Path $folder -Recurse -Force -ErrorAction Stop | Remove-Item -Force -Recurse -ErrorAction Stop
        Write-Host "Successfully deleted contents of $folder"
    } catch {
        Write-Host "Failed to delete contents of $folder"
    }
}