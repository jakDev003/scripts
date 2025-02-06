#!/bin/bash

sudo apt update
sudo apt install -y jq
HELIX_VERSION=$(curl -s "https://api.github.com/repos/helix-editor/helix/releases/latest" | jq -r ".tag_name")
wget --no-check-certificate -O helix.tar.xz https://github.com/helix-editor/helix/releases/latest/download/helix-$HELIX_VERSION-x86_64-linux.tar.xz
sudo rm -rf /opt/helix
sudo mkdir -p /opt/helix
sudo tar xf helix.tar.xz --strip-components=1 -C /opt/helix
ln -s /opt/helix/hx /usr/local/bin/hx
export PATH=$PATH:/opt/helix/hx
hx --version
rm -rf helix.tar.xz
