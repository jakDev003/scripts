#!/bin/bash

# Install DotNet8
sudo add-apt-repository ppa:dotnet/backports
sudo apt update
sudo apt install software-properties-common -y
sudo apt install dotnet-sdk-8.0

# Install Entity Framework
dotnet tool install --global dotnet-ef
export PATH=/root/.dotnet/tools:$PATH; source .bashrc
export PATH=$HOME/.dotnet/tools:$PATH; source .bashrc

# Install a package like this from CLI
#dotnet add package Microsoft.EntityFrameworkCore.SqlServer
