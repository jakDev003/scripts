# Function to kill processes by multiple name patterns
function Kill-ProcessesByPatterns {
    param (
        [string[]]$patterns
    )

    foreach ($pattern in $patterns) {
        $processes = Get-Process | Where-Object { $_.Name -like $pattern }

        if ($processes) {
            foreach ($process in $processes) {
                try {
                    Stop-Process -Id $process.Id -Force
                    Write-Host "Killed process $($process.Name) with ID: $($process.Id)"
                } catch {
                    Write-Host "Failed to kill process $($process.Name) with ID: $($process.Id)"
                }
            }
        } else {
            Write-Host "No processes containing '$pattern' found."
        }
    }
}

# Kill processes containing 'conhost', 'docker', or 'Terminal' in their names
$patterns = @("*conhost*", "*docker*", "*Terminal*")
Kill-ProcessesByPatterns -patterns $patterns