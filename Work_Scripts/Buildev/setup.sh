#!/bin/bash

cd /home/dev

if [ ! -f "/home/dev/.vim/autoload/plug.vim" ]; then
    echo "Install Vimplug"
    curl -fLo /home/dev/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
else
    echo "Vimplug already installed"
fi

if [ ! -f "/usr/local/bin/starship" ]; then
    echo "Install Starship"
    curl -sS https://starship.rs/install.sh | sh -s -- -y
else
    echo "Starship already installed"
fi

if [ ! -d "/usr/local/nvim" ]; then
    echo "Install Neovim"
    sudo yum groupinstall "Development Tools"
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
    chmod u+x nvim.appimage
    ./nvim.appimage --appimage-extract
    sudo mv squashfs-root /
    sudo ln -s /squashfs-root/AppRun /usr/bin/nvim
    sudo chown dev:dev /opt/nvim/nvim
    sudo rm nvim.appimage
    sudo rm -rf squashfs-root/
    else
    echo "Neovim already installed"
fi

if [ ! -f "/usr/local/bin/lazygit" ]; then
    wget -O lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v0.41.0/lazygit_0.41.0_Linux_x86_64.tar.gz"
    tar -zvxf ./lazygit.tar.gz -C /usr/local/bin
    rm -rf ./lazygit.tar.gz
else
    echo "Lazygit already installed"
fi

echo "Setting up SSH Keys"
eval $(ssh-agent -s)
ssh-add /home/dev/.ssh/id_ed25519 
mkdir -p /home/dev/repos
git config --global user.name "Josh K"
git config --global user.email "jkagiwada@advisor360.com"
git config --global core.autocrlf input
echo "[safe]" >> /home/dev/.gitconfig
echo "        directory = *" >> /home/dev/.gitconfig

if [ ! -d "/home/dev/repos/scripts" ]; then
    echo "Scripts Repo Cloning"
    cd /home/dev/repos
    git clone git@gitlab.com:jkagidesigns1/scripts.git
else
    echo "Scripts Repo already cloned"
fi

if [ ! -d "/home/dev/repos/dotfiles" ]; then
    echo "Dotfiles Repo Cloning"
    cd /home/dev/repos
    git clone git@gitlab.com:jkagidesigns1/dotfiles.git
else
    echo "Dotfiles Repo already cloned"
fi

echo "Installing RipGrep"
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo=https://copr.fedorainfracloud.org/coprs/carlwgeorge/ripgrep/repo/epel-7/carlwgeorge-ripgrep-epel-7.repo
sudo yum install -y ripgrep

echo "Copying Config Files"
cp /home/dev/repos/scripts/Buildev/.bashrc /home/dev/
cp /home/dev/repos/scripts/Buildev/starship.toml /home/dev/.config
source /home/dev/.bashrc

echo "Installing NPM Dependencies"
npm i -g eslint prettier nx @angular/cli @johnnymorganz/stylua

cd /home/dev
