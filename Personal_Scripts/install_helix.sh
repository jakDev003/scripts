#!/bin/bash

FILENAME=helix.tar.xz
URL=https://github.com/helix-editor/helix/releases/download/24.07/helix-24.07-aarch64-linux.tar.xz

# Download File
wget -O $FILENAME $URL

# Extract to '/usr/local/bin' directory
sudo tar -C /usr/local/bin -xvf $FILENAME

# Update bashrc to make sure this is in the path
source ~/.bashrc

# Test the installation
hx --version

# Remove the downloaded file
sudo rm -rf $FILENAME
