#!/bin/bash

GOVERSION=1.19.5
curl -OLk https://golang.org/dl/go$GOVERSION.linux-amd64.tar.gz
sudo tar -C /usr/local -xvf go$GOVERSION.linux-amd64.tar.gz
source /home/dev/.bashrc
export PATH=$PATH:/usr/local/go/bin \
    && go version
source ~/.bashrc
go version
sudo rm -rf go*
 
LAZYGIT_VERSION=$(curl -sk "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
curl -Lok lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit -D -t /usr/local/bin/
sudo rm -rf lazygit*
