FROM rockylinux:9.3 
RUN yum update -y

# Define our versions
ARG JDK_VERSION=1.8.0
ARG MVN_VERSION=3.8.3
ARG SWF_VERSION=0.8.1
ARG NOD_VERSION=16.19.1
ARG NOD_VERSION_REACT=16.19.1
ARG NOD_VERSION_ANGULAR=20.10.0

# Get our utilities
RUN yum update -y
RUN yum -y install git gzip wget tar xz python3 python-pip sudo vim procps make ant \
           openssh-server hostname iputils rsync dos2unix

# goal:
#  - if host user builds and runs this container, it will use *that* user
#    inside the container and the container id for that user will match the
#    container id of the host user.
#  - inputs needed: host user name, host user id, host group id
#  - This section will create the user, but not set the user from this Dockerfile's perspective
#  - User management like this should be done when we're sure its not involved in any active processes.
#    safest to do it first.  Only really matters when we do any userland actions.
#  - docker file has default values that can be modified by the build cmd.

ARG USER_NAME=dev
ARG USER_ID=1000
ARG GROUP_ID=1000
RUN groupadd -g ${GROUP_ID} ${USER_NAME}
RUN useradd -l -u ${USER_ID} -g ${USER_NAME} ${USER_NAME}
RUN install -d -m 0755 -o ${USER_NAME} -g ${USER_NAME} /home/${USER_NAME}

# Get swf tools (legacy system)
RUN wget --no-check-certificate -O - http://www.swftools.org/swftools-$SWF_VERSION.tar.gz | tar -xzf -

# Get compiler & Maven
RUN yum -y install java-$JDK_VERSION-openjdk-devel
RUN wget --no-check-certificate -O - https://archive.apache.org/dist/maven/maven-3/$MVN_VERSION/binaries/apache-maven-$MVN_VERSION-bin.tar.gz | tar -xzf -

# Install Node Version Manager
RUN touch ~/.bashrc && chmod +x ~/.bashrc
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
RUN . ~/.nvm/nvm.sh && source ~/.bashrc \
    && nvm install $NOD_VERSION_REACT \
    && nvm use $NOD_VERSION_REACT \
    && npm install --global yarn cross-env webpack webpack-cli url-loader dotenv \
    && yarn global add lerna@7.4.2 

# Build Environment
ENV JAVA_HOME=/etc/alternatives/jre_$JDK_VERSION\_openjdk
ENV MAVEN_HOME=/apache-maven-$MVN_VERSION/bin
ENV NODE_HOME=/node-v$NOD_VERSION-linux-x64/bin
ENV PATH=$PATH:$JAVA_HOME:$MAVEN_HOME:$NODE_HOME

# jenkins.output is used to build flex code (not needed)
ENV jenkins.output=/home/flex
ENV SKIP_PREFLIGHT_CHECK=true

# Add environment content
RUN mkdir env
COPY content/env /env/.env

# Set up Sudoers
RUN echo "${USER_NAME} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN ssh-keygen -A
RUN echo "${USER_NAME}:password" | chpasswd

# Make yum ignore ssl
RUN echo "sslverify=false" >> /etc/yum.conf

USER "${USER_NAME}"

RUN mkdir "/home/${USER_NAME}/code"
WORKDIR "/home/${USER_NAME}/code"
RUN sudo chown "${USER_NAME}:${USER_NAME}" "/home/${USER_NAME}/code"

# build place for flex source code
RUN sudo mkdir /home/flex
RUN sudo chown "${USER_NAME}:${USER_NAME}" /home/flex
RUN sudo rmdir /opt
RUN sudo ln -s /home/flex /opt

ADD  content/flexsdk.tz /home/flex
RUN sudo ln -s /home/flex/flexsdkadobe /opt/flexadobe
RUN ln -s "/home/${USER_NAME}/code/aexflexmanager" "/home/flex/AgreementExpress"
RUN ln -s "/home/${USER_NAME}/code/aexflexinterface" "/home/flex/AgreementInterface"

# ssh port
EXPOSE 22

# args (most) expected from build cmd line
ARG GIT_REPO_URL
ARG GIT_HASH
ARG BUILD_HOST
ARG BUILD_USER
ARG BUILD_DIR
ARG BUILD_TIME

# labels
LABEL net.wealth-agreementexpress.build_repo=${GIT_REPO_URL}
LABEL net.wealth-agreementexpress.build_hash=${GIT_HASH}
LABEL net.wealth-agreementexpress.build_host=${BUILD_HOST}
LABEL net.wealth-agreementexpress.build_user=${BUILD_USER}
LABEL net.wealth-agreementexpress.build_user=${BUILD_DIR}
LABEL net.wealth-agreementexpress.build_time=${BUILD_TIME}

# Install Lazygit
RUN export LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*') \
  && curl --insecure -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
RUN tar -xvf lazygit.tar.gz lazygit
RUN sudo install lazygit /usr/local/bin

# Install Starship
RUN curl --insecure -sS https://starship.rs/install.sh | sh -s -- -y

# Install Ripgrep
#RUN export RIPGREP_VERSION=$(curl -s "https://api.github.com/repos/BurntSushi/ripgrep/releases/latest" | grep -Po '"tag_name": "\K[0-9.]+') \
#    && curl --insecure -Lo ripgrep.tar.gz "https://github.com/BurntSushi/ripgrep/releases/download/${RIPGREP_VERSION}/ripgrep-${RIPGREP_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
#    tar -xzf ripgrep.tar.gz --strip-components=1 -C /usr/local/bin ripgrep-${RIPGREP_VERSION}-x86_64-unknown-linux-musl/rg

RUN export RIPGREP_VERSION=$(curl -s "https://api.github.com/repos/BurntSushi/ripgrep/releases/latest" | grep -Po '"tag_name": "\K[0-9.]+') \
    && curl --insecure -Lo ripgrep.tar.gz "https://github.com/BurntSushi/ripgrep/releases/download/${RIPGREP_VERSION}/ripgrep-${RIPGREP_VERSION}-x86_64-unknown-linux-musl.tar.gz"

# Install Helix Text Editor
RUN export HELIX_VERSION=$(curl -s "https://api.github.com/repos/helix-editor/helix/releases/latest" | grep -Po '"tag_name": "\K[0-9.]+') \
  && wget --no-check-certificate -qO helix.tar.xz https://github.com/helix-editor/helix/releases/latest/download/helix-$HELIX_VERSION-x86_64-linux.tar.xz
RUN sudo mkdir /opt/helix
RUN sudo tar xf helix.tar.xz --strip-components=1 -C /opt/helix
RUN sudo ln -s /opt/helix/hx /usr/local/bin/hx
RUN hx --version
RUN rm -rf helix.tar.xz

# Install JDTLS
RUN wget --no-check-certificate -qO jdt-language-server-latest.tar.gz https://www.eclipse.org/downloads/download.php?file=/jdtls/snapshots/jdt-language-server-latest.tar.gz
RUN sudo mkdir /opt/jdtls
RUN sudo tar xf jdt-language-server-latest.tar.gz -C /opt/jdtls
RUN sudo ln -s /opt/jdtls /usr/local/bin/jdtls

# Cleanup
RUN sudo rm -rf *.gz

# Avoid container exit.
CMD ["tail", "-f", "/dev/null"]

