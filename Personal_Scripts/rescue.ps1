# Enable PowerShell script execution
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# Run the specified command
iwr -useb https://christitus.com/win | iex