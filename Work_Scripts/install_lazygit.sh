#!/bin/bash

VERSION=1.19.5

wget https://go.dev/dl/
sudo tar -C /usr/local -xvf go$VERSION.linux-amd64.tar.gz
source /home/dev/.bashrc
export PATH=$PATH:/usr/local/go/bin \
    && go version
