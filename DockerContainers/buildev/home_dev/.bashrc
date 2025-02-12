# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

[ -f ~/.fzf.bash ] && source ~/.fzf.bash


# Custom Info
show_my_info () {
    output=$(curl https://ifconfig.me/)
    
    clear
    
    printf "\n"
    printf "   %s\n" "IP ADDR: $output"
    printf "   %s\n" "USER: $(whoami)"
    printf "   %s\n" "DATE: $(date)"
    printf "   %s\n" "UPTIME: $(uptime -p)"
    printf "   %s\n" "HOSTNAME: $(hostname -f)"
    printf "   %s\n" "MODEL: $(command lscpu | grep 'Model name' | cut -f 2 -d ":" | awk '{$1=$1}1')"
    printf "   %s\n" "DISTRO: $(cat /etc/*-release | grep "PRETTY_NAME" | sed 's/.*=//')"
    #printf "   %s\n" "CPU: $(awk -F: '/model name/{print $2}' | head -1)"
    printf "   %s\n" "KERNEL: $(uname -rms)"
    printf "   %s\n" "PACKAGES: $(dpkg --get-selections | wc -l)"
    #printf "   %s\n" "RESOLUTION: $(xrandr | awk '/\*/{printf $1" "}')"
    #printf "   %s\n" "MEMORY: $(free -m -h | awk '/Mem/{print $3"/"$2}')"
    printf "\n"
}

alias vi="vim"



# Install SDKMan if not found ( For Java )
if [[  $(source "$HOME/.sdkman/bin/sdkman-init.sh" && sdk version) == *sdk* ]]; then
    # Install required packages
    packagesNeeded=(curl wget unzip zip)
    if [ -x "$(command -v apk)" ];
    then
        sudo apk add --no-cache "${packagesNeeded[@]}"
    elif [ -x "$(command -v apt-get)" ];
    then
        sudo apt-get install "${packagesNeeded[@]}"
    elif [ -x "$(command -v dnf)" ];
    then
        sudo dnf install "${packagesNeeded[@]}"
    elif [ -x "$(command -v zypper)" ];
    then
        sudo zypper install "${packagesNeeded[@]}"
    else
        echo "FAILED TO INSTALL PACKAGE: Package manager not found. You must manually install: "${packagesNeeded[@]}"">&2;
    fi
    # Install SDK Man
    curl -s "https://get.sdkman.io" | bash -s -- -y
    source "$HOME/.sdkman/bin/sdkman-init.sh"
    # Install Java Stuff
    sdk install ant
    sdk install java 21.0.4-tem
    sdk install java 8.0.422-tem
    sdk install maven
fi

# Install NVM if not found
if [[ $(nvm --version) ]]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
    mkdir -p /usr/local/nvm
    touch /usr/local/nvm/default-packages
    cat << EOF > /usr/local/nvm/default-packages
webpack
webpack-cli
dotenv
prettier
@angular/cli
cspell
typescript-language-server
yaml-language-server
vscode-languageserver
vscode-html-languageservice
vscode-json-languageservice
vscode-css-languageservice
vscode-languageserver-types
dockerfile-language-server-nodejs
bash-language-server"
@angular/language-server
cssmodules-language-server
css-variables-language-server
eslint"
stylelint
stylelint-scss
eslint-webpack-plugin
eslint-plugin-html
markdownlint
EOF
fi
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm
nvm install 20

# Install Starship if not found
if [[ $(whereis starship) == *starship* ]]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash -s -- -y
fi
eval "$(starship init bash)" 
clear

export PATH=$PATH:/usr/local/bin/OmniSharp

# Java setup
#export JAVA_HOME=/usr/lib/jvm/java
#export JRE_HOME=/usr/lib/jvm/jre
#export PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin
#export JAVA_HOME=/etc/alternatives/jre_1.8.0_openjdk
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64
export PATH=$PATH:$JAVA_HOME/bin

export JDTLS_HOME=/usr/local/bin/jdtls
export PATH=$PATH:$JDTLS_HOME/bin

export M2_HOME=/usr/local/apache-maven
export M2=$M2_HOME/bin
export PATH=$M2:$PATH

. "$HOME/.cargo/env"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# My Custom neofetch substitution
show_my_info

source "$HOME/.sdkman/bin/sdkman-init.sh"
