#!/bin/bash

# Add dependencies
sudo dnf check-update
sudo dnf install dnf-utils

# Pull Go Tarball
wget https://go.dev/dl/go1.19.5.linux-amd64.tar.gz

# Extract to /usr/local
tar -zxvf go1.19.5.linux-amd64.tar.gz -C /usr/local

# Export to .bashrc
echo 'export GOROOT=/usr/local/go' | tee -a /home/dev/.bashrc
echo 'export PATH=$PATH:/usr/local/go/bin' | tee -a /home/dev/.bashrc

# Source .bashrc
source /home/dev/.bashrc

# Install Lazygit
git clone https://github.com/jesseduffield/lazygit.git
cd lazygit
go install

