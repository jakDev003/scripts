FROM ubuntu:24.04 
# Replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh
# Set debconf to run non-interactively
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt-get update && \
    apt-get install -y software-properties-common sudo
# Add a new user
ARG USER_NAME=josh
ARG HOME_DIR=/home/$USER_NAME
RUN useradd --system --create-home --home-dir $HOME_DIR --shell /bin/bash --gid root --groups sudo --uid 1001 $USER_NAME
RUN passwd -d $USER_NAME
RUN sudo chown $USER_NAME /usr/local/bin -R && sudo chmod 777 /usr/local/bin -R
USER $USER_NAME
WORKDIR $HOME_DIR

# Install base dependencies
RUN sudo apt-get install -y -q --no-install-recommends \
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
#        && rm -rf /var/lib/apt/lists/* # uncomment to disable package manager

ARG NVM_DIR=/usr/local/nvm
RUN sudo mkdir -p ${NVM_DIR}
ENV NVM_DIR ${NVM_DIR}
ENV NODE_VERSION v20.16.0
RUN sudo chown $USER_NAME ${NVM_DIR}/ -R
COPY default-packages /usr/local/nvm/
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
RUN /bin/bash -c "source $NVM_DIR/nvm.sh"
# add node and npm to the PATH
ENV NODE_PATH $NVM_DIR/versions/node/$NODE_VERSION/bin
ENV PATH $NODE_PATH:$PATH
RUN npm -v
RUN node -v

# Get Java compiler & Maven
ARG JDK_VERSION=1.8.0
ARG MVN_VERSION=3.8.3
RUN sudo apt -y install openjdk-8-jdk
RUN wget -O - https://archive.apache.org/dist/maven/maven-3/$MVN_VERSION/binaries/apache-maven-$MVN_VERSION-bin.tar.gz | tar -xzf -

# Add Environment Variables
ENV JAVA_HOME=/etc/alternatives/jre_$JDK_VERSION\_openjdk
ENV MAVEN_HOME=/apache-maven-$MVN_VERSION/bin
ENV NODE_HOME=/node-v$NODE_VERSION-linux-x64/bin
ENV PATH=$PATH:$JAVA_HOME:$MAVEN_HOME:$NODE_HOME

# Install LazyGit
RUN export LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*') \
  && curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
RUN tar -xvf lazygit.tar.gz lazygit
RUN install lazygit /usr/local/bin
ENV PATH=$PATH:/usr/local/bin/lazygit

# Install Starship
RUN curl -sS https://starship.rs/install.sh | sh -s -- -y

# Install Helix Text Editor
RUN export HELIX_VERSION=$(curl -s "https://api.github.com/repos/helix-editor/helix/releases/latest" | grep -Po '"tag_name": "\K[0-9.]+') \
  && wget -qO helix.tar.xz https://github.com/helix-editor/helix/releases/latest/download/helix-$HELIX_VERSION-x86_64-linux.tar.xz
RUN sudo mkdir /opt/helix
RUN sudo tar xf helix.tar.xz --strip-components=1 -C /opt/helix
RUN ln -s /opt/helix/hx /usr/local/bin/hx
ENV PATH=$PATH:/opt/helix/hx
RUN hx --version
RUN rm -rf helix.tar.xz

# Install RipGrep
RUN curl -LO https://github.com/BurntSushi/ripgrep/releases/download/14.1.0/ripgrep_14.1.0-1_amd64.deb
RUN sudo dpkg -i ripgrep_14.1.0-1_amd64.deb

# Install JDTLS
RUN wget -qO jdt-language-server-latest.tar.gz https://www.eclipse.org/downloads/download.php?file=/jdtls/snapshots/jdt-language-server-latest.tar.gz
RUN sudo mkdir /opt/jdtls
RUN sudo tar xf jdt-language-server-latest.tar.gz -C /opt/jdtls
RUN sudo ln -s /opt/jdtls /usr/local/bin/jdtls

# Install dotnet
RUN sudo add-apt-repository ppa:dotnet/backports
RUN sudo apt update
RUN sudo apt install dotnet-sdk-8.0 -y
RUN dotnet --version

# Install Entity Framework
RUN dotnet tool install --global dotnet-ef --version 6.0.6
ENV PATH="${HOME_DIR}/.dotnet/tools:${PATH}"
RUN export PATH=$HOME_DIR/.dotnet/tools:$PATH; source $HOME_DIR/.bashrc

# Install a package like this from CLI
#dotnet add package Microsoft.EntityFrameworkCore.SqlServer

# Install Mono (Needed for Omnisharp)
RUN sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF \
  && echo "deb [arch=amd64] https://download.mono-project.com/repo/ubuntu stable-focal main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list
RUN sudo apt update
RUN sudo apt install mono-complete -y
RUN mono --version

# Install Omnisharp LSP
RUN wget https://github.com/OmniSharp/omnisharp-roslyn/releases/download/v1.39.12/omnisharp-linux-x64-net6.0.tar.gz
RUN cd omnisharp-roslyn/ && sh build.sh


# Avoid container exit.
CMD ["tail", "-f", "/dev/null"]
