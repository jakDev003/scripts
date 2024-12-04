#/bin/bash

# INSTALL DOCKER PACKAGE
sudo -E apt update && sudo apt upgrade -y
sudo -E apt-get -qq install docker.io -y
# DOCKER DAEMON STARTUP (Substitute .bashrc for .zshrc or any other shell you use)
rcfile=~/.bashrc
echo '# Start Docker daemon automatically when logging in if not running.' >> $rcfile
echo 'RUNNING=`ps aux | grep dockerd | grep -v grep`' >> $rcfile
echo 'if [ -z "$RUNNING" ]; then' >> $rcfile
echo '    sudo dockerd > /dev/null 2>&1 &' >> $rcfile
echo '    disown' >> $rcfile
echo 'fi' >> $rcfile
# ENABLE CURRENT USER AS SUDO FOR DOCKER
echo $USER' ALL=(ALL) NOPASSWD: /usr/bin/dockerd' | sudo EDITOR='tee -a' visudo
sudo usermod -aG docker $USER
# REBOOT VM MACHINE
wsl.exe --shutdown
