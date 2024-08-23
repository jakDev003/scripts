sudo apt-get update && \
    apt-get install -y software-properties-common sudo
sudo apt-get install -y -q --no-install-recommends \
        apt-transport-https \
        build-essential \
        ca-certificates \
        software-properties-common \
        dirmngr \
        gnupg \
        curl \
        git \
        libssl-dev \
        wget \
        gzip \
        wget \
        gcc \
        tar \
        xz-utils \
        python3 \
        python3-pip \
        python3-flake8 \
        python3-autopep8 \
        pylint \
        python3-pylsp \
        cmake \
        libtsl-hopscotch-map-dev \
        libfmt-dev \
        vim \
        procps \
        make \
        ant \
        openssh-server \
        hostname \
        net-tools \
        rsync \
        dos2unix

NVM_DIR=/usr/local/nvm
sudo mkdir -p ${NVM_DIR}

USER_NAME=$(whoami)
NODE_VERSION=v20.16.0
sudo chown $USER_NAME ${NVM_DIR}/ -R
sudo cp default-packages /usr/local/nvm/
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
source $NVM_DIR/nvm.sh
NODE_PATH $NVM_DIR/versions/node/$NODE_VERSION/bin
export PATH=$NODE_PATH:$PATH
npm -v
node -v

JDK_VERSION=1.8.0
MVN_VERSION=3.8.3
sudo apt -y install openjdk-8-jdk
wget -O - https://archive.apache.org/dist/maven/maven-3/$MVN_VERSION/binaries/apache-maven-$MVN_VERSION-bin.tar.gz | tar -xzf -

export JAVA_HOME=/etc/alternatives/jre_$JDK_VERSION\_openjdk
export MAVEN_HOME=/apache-maven-$MVN_VERSION/bin
export NODE_HOME=/node-v$NODE_VERSION-linux-x64/bin
export PATH=$PATH:$JAVA_HOME:$MAVEN_HOME:$NODE_HOME

export LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*') \
  && curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar -xvf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
export PATH=$PATH:/usr/local/bin/lazygit

curl -sS https://starship.rs/install.sh | sh -s -- -y

curl -LO https://github.com/BurntSushi/ripgrep/releases/download/14.1.0/ripgrep_14.1.0-1_amd64.deb
sudo dpkg -i ripgrep_14.1.0-1_amd64.deb

wget -qO jdt-language-server-latest.tar.gz https://www.eclipse.org/downloads/download.php?file=/jdtls/snapshots/jdt-language-server-latest.tar.gz
sudo mkdir /opt/jdtls
sudo tar xf jdt-language-server-latest.tar.gz -C /opt/jdtls
sudo ln -s /opt/jdtls /usr/local/bin/jdtls

sudo add-apt-repository ppa:dotnet/backports
sudo apt update
sudo apt install dotnet-sdk-8.0 -y
dotnet --version

dotnet tool install --global dotnet-ef --version 6.0.6
export PATH="${HOME_DIR}/.dotnet/tools:${PATH}"
export PATH=$HOME_DIR/.dotnet/tools:$PATH; source $HOME_DIR/.bashrc

sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF \
  && echo "deb [arch=amd64] https://download.mono-project.com/repo/ubuntu stable-focal main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list
sudo apt update
sudo apt install mono-complete -y
mono --version

OMNISHARP_VER=0.19.8
wget -qO csharp-language-server-protocol.tar.gz "https://github.com/OmniSharp/csharp-language-server-protocol/archive/refs/tags/v$OMNISHARP_VER.tar.gz"
sudo tar xf csharp-language-server-protocol.tar.gz
cd csharp-language-server-protocol-$OMNISHARP_VER/ && sh build.sh

