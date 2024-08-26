#!/bin/bash

#sudo apt-get update
#sudo apt-get install curl -y
curl -sSL -o omnisharp-linux-x64-net6.0.tar.gz https://github.com/OmniSharp/omnisharp-roslyn/releases/download/v1.39.12/omnisharp-linux-x64-net6.0.tar.gz
sudo mkdir -p /usr/local/bin/OmniSharp
sudo tar -xvf omnisharp-linux-x64-net6.0.tar.gz -C /usr/local/bin/OmniSharp
#sudo mv /usr/local/bin/omnisharp /usr/local/bin/OmniSharp
sudo chmod +x /usr/local/bin/OmniSharp/OmniSharp
