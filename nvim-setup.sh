#!/usr/bin/env bash
# =============================================================================
# Multi-tool installer for Neovim, Node.js (nvm + v20), Prettier, Biome,
# Python + Black, .NET 8 + EF Core, pylsp, Flutter, Docker + Compose
# Supports: Ubuntu 22.04/24.04 (Debian-based), Fedora 40/41 (RHEL-based)
# Tested on Ubuntu 24.04, Fedora 41
# Run as: curl -fsSL https://raw.githubusercontent.com/yourname/installer/main/install.sh | bash
# =============================================================================

set -euo pipefail

log() { echo -e "\033[1;34m[+] $*\033[0m"; }
error() { echo -e "\033[1;31m[!] $*\033[0m" >&2; exit 1; }

# Distro detection
if [ -f /etc/os-release ]; then
  . /etc/os-release
  OS_ID="${ID:-$(lsb_release -si 2>/dev/null || echo unknown)}"
  OS_VERSION_ID="${VERSION_ID:-$(lsb_release -sr 2>/dev/null || echo unknown)}"
else
  error "Unsupported OS: Could not detect /etc/os-release"
fi

if [[ "$OS_ID" == @(ubuntu|debian|pop|linuxmint|kali) ]]; then
  PKG_MGR="apt"
  PKG_UPDATE="sudo apt update && sudo apt upgrade -y"
  PKG_INSTALL="sudo apt install -y"
  PKG_REMOVE="sudo apt remove -y"
  DISTRO_CODENAME="$(lsb_release -cs 2>/dev/null || echo focal)"
elif [[ "$OS_ID" == @(fedora|rhel|centos) ]]; then
  PKG_MGR="dnf"
  PKG_UPDATE="sudo dnf upgrade --refresh -y"
  PKG_INSTALL="sudo dnf install -y"
  PKG_REMOVE="sudo dnf remove -y"
  DISTRO_CODENAME="$OS_ID"
else
  error "Unsupported distro: $OS_ID. Only Ubuntu/Debian-based or Fedora/RHEL-based supported."
fi

log "Detected $OS_ID $OS_VERSION_ID. Using $PKG_MGR..."

# Update package index
log "Updating system packages..."
eval "$PKG_UPDATE"

# ----------------------------- Neovim (latest AppImage + symlink) -----------------------------
log "Installing Neovim (latest AppImage + symlink)..."
if [ ! -f /usr/local/bin/nvim ] || ! nvim --version | grep -q "$(curl -s https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage --output /dev/null --write-out '%{url_effective}' | grep -o 'v[0-9.]*')"; then
  curl -Lo /tmp/nvim.appimage https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
  chmod +x /tmp/nvim.appimage
  $PKG_MGR install fuse  # For AppImage on Fedora
  sudo mv /tmp/nvim.appimage /usr/local/bin/nvim
  sudo ln -sf /usr/local/bin/nvim /usr/local/bin/vim 2>/dev/null || true
fi

# ----------------------------- Node Version Manager + Node 20 -----------------------------
log "Installing nvm and Node.js 20..."
export NVM_DIR="$HOME/.nvm"
if [ ! -d "$NVM_DIR" ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
fi

# Load nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

if ! nvm --version >/dev/null 2>&1; then
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
fi

nvm install 20 --latest-npm || true  # Idempotent
nvm alias default 20
nvm use 20

# Global npm packages
log "Installing Prettier and Biome globally..."
npm install -g prettier @biomejs/biome

# ----------------------------- Python + Black + pylsp -----------------------------
log "Installing Python, pip, Black and python-lsp-server..."
if [[ "$PKG_MGR" == "apt" ]]; then
  $PKG_INSTALL python3 python3-pip python3-venv
  pip3 install --user --upgrade pip
  pip3 install --user black python-lsp-server[all] rope
elif [[ "$PKG_MGR" == "dnf" ]]; then
  $PKG_INSTALL python3 python3-pip
  python3 -m pip install --user --upgrade pip
  python3 -m pip install --user black python-lsp-server[all] rope
fi

# ----------------------------- .NET 8 SDK + EF Core -----------------------------
log "Installing .NET 8 SDK..."
if [[ "$PKG_MGR" == "apt" ]]; then
  wget https://packages.microsoft.com/config/ubuntu/"$OS_VERSION_ID"/packages-microsoft-prod.deb -O /tmp/packages-microsoft-prod.deb
  sudo dpkg -i /tmp/packages-microsoft-prod.deb
  rm /tmp/packages-microsoft-prod.deb
  sudo apt update
  sudo apt install -y apt-transport-https
  sudo apt install -y dotnet-sdk-8.0
elif [[ "$PKG_MGR" == "dnf" ]]; then
  $PKG_INSTALL dotnet-sdk-8.0
fi

# Entity Framework Core tools
log "Installing EF Core tools..."
dotnet tool install --global dotnet-ef --version 8.0.* || true  # Idempotent
export PATH="$PATH:$HOME/.dotnet/tools"
echo 'export PATH="$PATH:$HOME/.dotnet/tools"' >> "$HOME/.bashrc"

# ----------------------------- Flutter ---------------------------------------
log "Installing Flutter (Linux stable channel)..."
if [[ "$PKG_MGR" == "apt" ]]; then
  $PKG_INSTALL curl git unzip xz-utils libglu1-mesa clang cmake ninja-build pkg-config libgtk-3-dev
elif [[ "$PKG_MGR" == "dnf" ]]; then
  $PKG_INSTALL curl git unzip xz zip mesa-libGLU clang cmake ninja-build pkg-config gtk3-devel
fi

cd /opt
if [ ! -d flutter ]; then
  sudo rm -rf flutter 2>/dev/null || true
  sudo git clone https://github.com/flutter/flutter.git -b stable
  sudo chown -R "$USER:" flutter
fi

echo 'export PATH="$PATH:/opt/flutter/bin"' >> "$HOME/.bashrc"
echo 'export PATH="$PATH:$HOME/.pub-cache/bin"' >> "$HOME/.bashrc"
export PATH="$PATH:/opt/flutter/bin"
export PATH="$PATH:$HOME/.pub-cache/bin"

flutter precache || true
flutter doctor --android-licenses --no-color || true

# ----------------------------- Docker + Docker Compose -----------------------------
log "Installing Docker Engine and Docker Compose..."
# Remove old versions
$PKG_REMOVE docker docker-engine docker.io containerd runc || true

if [[ "$PKG_MGR" == "apt" ]]; then
  # Official Docker install (Ubuntu/Debian)
  $PKG_INSTALL ca-certificates curl gnupg lsb-release
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu $DISTRO_CODENAME stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt update
  $PKG_INSTALL docker-ce docker-ce-cli containerd.io docker-compose-plugin
elif [[ "$PKG_MGR" == "dnf" ]]; then
  # Official Docker install (Fedora)
  $PKG_INSTALL dnf-plugins-core
  sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
  $PKG_INSTALL docker-ce docker-ce-cli containerd.io docker-compose-plugin
fi

# Add current user to docker group
sudo usermod -aG docker "$USER" || sudo usermod -a -G docker "$USER"

# Enable docker service
sudo systemctl enable docker
sudo systemctl enable containerd

log "Docker Compose (plugin) is now available as 'docker compose'"

# ----------------------------- Final steps ------------------------------------
log "Installation complete!"
log "Please log out and log back in (or reboot) for group changes (docker, PATH) to take effect."
log "Source ~/.bashrc or run 'source ~/.bashrc' for immediate PATH updates."

echo -e "\nQuick verification commands you can run now:"
echo "   nvim --version"
echo "   node -v"
echo "   npm -g list prettier @biomejs/biome"
echo "   python3 -m black --version"
echo "   dotnet --info"
echo "   dotnet ef --version"
echo "   flutter doctor"
echo "   docker version"
echo "   docker compose version"

log "All done! Happy coding! 🚀"
