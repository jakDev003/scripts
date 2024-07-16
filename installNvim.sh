#!/bin/bash

# Update
sudo apt-get update

# Install base Neovim Dependancies
sudo apt-get install ninja-build gettext cmake unzip curl tar apt-utils -y
# Install extra dependencies needed for my configs but not specific to one package
sudo apt-get install xclip python3 python3-pip python3-urllib3 fzf software-properties-common -y
pip install --upgrade pip wheel setuptools requests black flake8 isort
wget -O google-java-format.jar "https://github.com/google/google-java-format/releases/download/v1.20.0/google-java-format-1.20.0-all-deps.jar"
mv ./google-java-format.jar /usr/local/bin/
sudo apt-get install chafa imagemagick poppler-utils -y

# Install stylua
npm i --global @johnnymorganz/stylua-bin

# Install RipGrep
wget -O ripgrep.deb "https://github.com/BurntSushi/ripgrep/releases/download/14.1.0/ripgrep_14.1.0-1_amd64.deb"
sudo apt-get install -y ./ripgrep.deb

# Install Java
sudo apt-get install -y openjdk-17-jdk openjdk-17-jre

# Install Java Language Server
wget -O jdt-language-server.tar.gz "https://www.eclipse.org/downloads/download.php?file=/jdtls/snapshots/jdt-language-server-latest.tar.gz"
mkdir /usr/local/bin/jdt-language-server && tar -zvxf jdt-language-server.tar.gz -C /usr/local/bin/jdt-language-server 

# Install Google Java Formatter
wget -O google-java-formatter.jar "https://github.com/google/google-java-format/releases/download/v1.20.0/google-java-format-1.20.0-all-deps.jar"
mkdir /usr/local/bin/google-java-formatter && mv ./google-java-formatter.jar /usr/local/bin/google-java-formatter 

# Install NPM Dependencies
npm i -g prettier eslint

# Install Lazygit
wget -O lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v0.40.2/lazygit_0.40.2_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
install lazygit /usr/local/bin

# Install prebuild archive of Nvim
git clone "https://github.com/neovim/neovim.git"
cd /home/dev/neovim && make CMAKE_BUILD_TYPE=Release && make install
