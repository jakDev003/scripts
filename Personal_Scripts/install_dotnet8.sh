#!/bin/bash

# Install DotNet8
sudo add-apt-repository ppa:dotnet/backports
sudo apt update
sudo apt install software-properties-common -y
sudo apt install dotnet-sdk-8.0

# Install Entity Framework
dotnet tool install --global dotnet-ef
export PATH=/root/.dotnet/tools:$PATH; source ~/.bashrc
export PATH=$HOME/.dotnet/tools:$PATH; source ~/.bashrc

# Install a package like this from CLI
#dotnet add package Microsoft.EntityFrameworkCore.SqlServer

# Install Omnisharp
sudo apt install curl -y
curl -sSL -o omnisharp-linux-x64-net6.0.tar.gz https://github.com/OmniSharp/omnisharp-roslyn/releases/download/v1.39.12/omnisharp-linux-x64-net6.0.tar.gz
sudo mkdir -p /usr/local/bin/OmniSharp
sudo tar -xvf omnisharp-linux-x64-net6.0.tar.gz -C /usr/local/bin/OmniSharp
sudo chmod +x /usr/local/bin/OmniSharp/OmniSharp
