#!/bin/bash

# Define our versions
NOD_VERSION=20.10.0

# Get our utilities
sudo yum update -y
sudo yum -y install git gzip wget tar xz python3 python-pip sudo vim procps make ant \
           openssh-server hostname iputils rsync dos2unix gcc gcc-c++ cmake lua
sudo dnf --enablerepo=crb install lua-devel libstdc++-static -y

# Install Node Version Manager
touch ~/.bashrc && chmod +x ~/.bashrc
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
source ~/.nvm/nvm.sh
source ~/.bashrc
nvm install $NOD_VERSION
nvm use $NOD_VERSION
npm install --global yarn cross-env webpack webpack-cli url-loader dotenv
yarn global add lerna@7.4.2

# Clone Ninja-build repository and install
git clone https://github.com/ninja-build/ninja.git /home/${USER_NAME}/ninja
cd /home/${USER_NAME}/ninja
git checkout release
cmake -Bbuild-cmake -H.
cmake --build build-cmake
sudo install build-cmake/ninja /usr/local/bin/ninja

# Clone and install Lazygit
export LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl --insecure -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar -xvf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin

# Clone and install lua-language-server
git clone https://github.com/sumneko/lua-language-server /home/${USER_NAME}/lua-language-server
cd /home/${USER_NAME}/lua-language-server
git submodule update --init --recursive
cd 3rd/luamake && ./compile/install.sh
cd ../..
./3rd/luamake/luamake rebuild
sudo mv /home/${USER_NAME}/lua-language-server/bin/lua-language-server /usr/local/bin/
sudo mv /home/${USER_NAME}/lua-language-server/main.lua /usr/local/bin/
echo '#!/bin/bash\n/usr/local/bin/lua-language-server -E /usr/local/bin/main.lua' | sudo tee /usr/local/bin/start-lua-language-server.sh > /dev/null
sudo chmod +x /usr/local/bin/start-lua-language-server.sh

# Install LuaRocks
wget --no-check-certificate https://luarocks.org/releases/luarocks-3.11.1.tar.gz
tar zxpf luarocks-3.11.1.tar.gz
cd /home/${USER_NAME}/luarocks-3.11.1/
./configure && make && sudo make install

# Install Neovim
wget --no-check-certificate https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
tar -xzf nvim-linux64.tar.gz
sudo mv nvim-linux64 /usr/local/bin/nvim

# Install Starship
curl --insecure -sS https://starship.rs/install.sh | sh -s -- -y

# Install Ripgrep
export RIPGREP_VERSION=$(curl -s "https://api.github.com/repos/BurntSushi/ripgrep/releases/latest" | grep -Po '"tag_name": "\K[0-9.]+')
curl --insecure -Lo ripgrep.tar.gz "https://github.com/BurntSushi/ripgrep/releases/download/${RIPGREP_VERSION}/ripgrep-${RIPGREP_VERSION}-x86_64-unknown-linux-musl.tar.gz"

# Remove existing docker if found
sudo dnf remove -y docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-selinux \
                  docker-engine-selinux \
                  docker-engine

# Install Docker
sudo dnf -y install dnf-plugins-core
sudo dnf-3 config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker
sudo groupadd docker
sudo usermod -aG docker $USER

