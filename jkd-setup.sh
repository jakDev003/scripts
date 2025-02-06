#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Prompt the user for a password
echo "Please enter a password for the 'josh' user:"
read -s password

# Create the 'josh' user with a home directory and bash shell
useradd -m -s /bin/bash josh

# Add the 'josh' user to the sudo group
usermod -aG sudo josh

# Set the password for the 'josh' user
echo "josh:$password" | chpasswd

# Inform the user that the process is complete
echo "The 'josh' user has been created and assigned the provided password."

# Switch to the josh user
su - josh <<'EOF'

# Create .ssh directory
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Generate SSH key for josh
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""

# Print the public key
echo "SSH public key for josh:"
cat ~/.ssh/id_rsa.pub

EOF

echo "User josh created, SSH key generated"


# ------- Install Docker -------
echo "Installing Docker"
# Add Docker's official GPG key:
apt-get update
apt-get install -y ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update

apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

usermod -aG docker josh

# ------- Lazygit -------
echo "Installing Lazygit"
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit -D -t /usr/local/bin/
