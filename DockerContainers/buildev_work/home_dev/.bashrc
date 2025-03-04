case $- in
    *i*) ;;
      *) return;;
esac

HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s checkwinsize

[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
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

case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

show_my_info () {
    hostname=$(hostname -f 2>/dev/null)
    if [ $? -ne 0 ] || [ -z "$hostname" ]; then
        hostname=$(cat /etc/hostname 2>/dev/null)
    fi

    ip_address=$(hostname -I | awk '{print $1}')
    disk_usage=$(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 " used)"}')
    memory_usage=$(free -h | awk 'NR==2 {print $3 "/" $2 " (" $3/$2*100 "% used)"}')
    running_processes=$(ps aux | wc -l)
    model=$(command lscpu | grep 'Model name' | cut -f 2 -d ':' | awk '{$1=$1}1')
    distro=$(cat /etc/*-release | grep 'PRETTY_NAME' | sed 's/.*=//')
    kernel=$(uname -rms)

    clear

    printf "\n"
    printf "========================================\n"
    printf "           SYSTEM INFORMATION           \n"
    printf "========================================\n"
    [ -n "$(whoami)" ] && printf "   %-15s: %s\n" "USER" "$(whoami)"
    [ -n "$(date)" ] && printf "   %-15s: %s\n" "DATE" "$(date)"
    [ -n "$(uptime -p)" ] && printf "   %-15s: %s\n" "UPTIME" "$(uptime -p)"
    [ -n "$hostname" ] && printf "   %-15s: %s\n" "HOSTNAME" "$hostname"
    [ -n "$ip_address" ] && printf "   %-15s: %s\n" "IP ADDRESS" "$ip_address"
    [ -n "$disk_usage" ] && printf "   %-15s: %s\n" "DISK USAGE" "$disk_usage"
    [ -n "$memory_usage" ] && printf "   %-15s: %s\n" "MEMORY USAGE" "$memory_usage"
    [ -n "$running_processes" ] && printf "   %-15s: %s\n" "RUNNING PROCESSES" "$running_processes"
    [ -n "$model" ] && printf "   %-15s: %s\n" "MODEL" "$model"
    [ -n "$distro" ] && printf "   %-15s: %s\n" "DISTRO" "$distro"
    [ -n "$kernel" ] && printf "   %-15s: %s\n" "KERNEL" "$kernel"
    printf "========================================\n"
    printf "\n"
}

alias vi="vim"
alias nvim="/usr/local/bin/nvim/bin/nvim"
alias luamake="/home/josh/lua-language-server/3rd/luamake/luamake"

eval "$(starship init bash)"
clear

export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64
export PATH=$PATH:$JAVA_HOME/bin

export JDTLS_HOME=/usr/local/bin/jdtls
export PATH=$PATH:$JDTLS_HOME/bin

export M2_HOME=/usr/local/apache-maven
export M2=$M2_HOME/bin
export PATH=$M2:$PATH

export PATH=$PATH:/usr/local/bin/googleJavaFormat

show_my_info

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
