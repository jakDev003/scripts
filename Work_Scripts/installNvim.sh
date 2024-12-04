#!/bin/bash

# Install prebuild archive of Nvim
git clone "https://github.com/neovim/neovim.git"
cd /home/dev/neovim && sudo make CMAKE_BUILD_TYPE=Release && sudo make install
