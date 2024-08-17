FROM ubuntu:24.04 
# Replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh
# Set debconf to run non-interactively
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt update -y

# Install base dependencies
RUN apt-get update && apt-get install -y -q --no-install-recommends \
        apt-transport-https \
        build-essential \
        ca-certificates \
        curl \
        git \
        libssl-dev \
        wget \
        gzip \
        wget \
        tar \
        xz-utils \
        python3 \
        python3-pip \
        python3-flake8 \
        python3-autopep8 \
        pylint \
        cmake \
        libtsl-hopscotch-map-dev \
        libfmt-dev \
        sudo \
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

ARG USER_NAME=dev
ARG USER_ID=1000
ARG GROUP_ID=1000
RUN useradd -l ${USER_NAME}
RUN usermod -aG ${GROUP_ID} ${USER_NAME}
RUN install -d -m 0755 -o ${USER_NAME} -g ${USER_NAME} /home/${USER_NAME}

# Install Node Version Manager
ARG NVM_DIR=/usr/local/nvm
RUN mkdir -p ${NVM_DIR}
ENV NVM_DIR ${NVM_DIR}
ENV NODE_VERSION v20.16.0
RUN touch ${NVM_DIR}/default-packages \
  && echo "webpack" >> ${NVM_DIR}/default-packages \
  && echo "webpack-cli" >> ${NVM_DIR}/default-packages \
  && echo "dotenv" >> ${NVM_DIR}/default-packages \
  && echo "prettier" >> ${NVM_DIR}/default-packages \
  && echo "@angular/cli" >> ${NVM_DIR}/default-packages
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
RUN /bin/bash -c "source $NVM_DIR/nvm.sh && nvm install $NODE_VERSION && nvm use --delete-prefix $NODE_VERSION"
# add node and npm to the PATH
ENV NODE_PATH $NVM_DIR/versions/node/$NODE_VERSION/bin
ENV PATH $NODE_PATH:$PATH
RUN npm -v
RUN node -v

# Get Java compiler & Maven
ARG JDK_VERSION=1.8.0
ARG MVN_VERSION=3.8.3
RUN apt -y install openjdk-8-jdk
RUN wget -O - https://archive.apache.org/dist/maven/maven-3/$MVN_VERSION/binaries/apache-maven-$MVN_VERSION-bin.tar.gz | tar -xzf -

# Add Environment Variables
ENV JAVA_HOME=/etc/alternatives/jre_$JDK_VERSION\_openjdk
ENV MAVEN_HOME=/apache-maven-$MVN_VERSION/bin
ENV NODE_HOME=/node-v$NODE_VERSION-linux-x64/bin
ENV PATH=$PATH:$JAVA_HOME:$MAVEN_HOME:$NODE_HOME

# Set up Sudoers
RUN echo "${USER_NAME} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN ssh-keygen -A
RUN echo "${USER_NAME}:password" | chpasswd

USER "${USER_NAME}"

RUN mkdir "/home/${USER_NAME}/code"
WORKDIR "/home/${USER_NAME}/code"
RUN sudo chown "${USER_NAME}:${USER_NAME}" "/home/${USER_NAME}/code"

# ssh port
EXPOSE 22

# Install Lazygit
RUN export LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*') \
  && curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
RUN tar -xvf lazygit.tar.gz lazygit
RUN sudo install lazygit /usr/local/bin

# Install Starship
RUN curl -sS https://starship.rs/install.sh | sh -s -- -y

# Install Helix Text Editor
RUN export HELIX_VERSION=$(curl -s "https://api.github.com/repos/helix-editor/helix/releases/latest" | grep -Po '"tag_name": "\K[0-9.]+') \
  && wget -qO helix.tar.xz https://github.com/helix-editor/helix/releases/latest/download/helix-$HELIX_VERSION-x86_64-linux.tar.xz
RUN sudo mkdir /opt/helix
RUN sudo tar xf helix.tar.xz --strip-components=1 -C /opt/helix
RUN sudo ln -s /opt/helix/hx /usr/local/bin/hx
RUN hx --version
RUN rm -rf helix.tar.xz

# Install RipGrep
RUN curl -LO https://github.com/BurntSushi/ripgrep/releases/download/14.1.0/ripgrep_14.1.0-1_amd64.deb
RUN sudo dpkg -i ripgrep_14.1.0-1_amd64.deb

# Avoid container exit.
CMD ["tail", "-f", "/dev/null"]
