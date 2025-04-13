# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

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



PS1='\[\e[0;32m\]\u@\h\[\e[m\]:\[\e[0;34m\]\w\[\e[m\]\$ '

# If this is an xterm set the title to user@host:dir

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

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



#NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PATH="/usr/bin:$PATH"


# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/marchlak/anaconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/marchlak/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/home/marchlak/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/marchlak/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

#polishlayout
setxkbmap -layout pl


. "$HOME/.cargo/env"

export EDITOR="nvim"

function yaz() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# if [ -z "$JAVA_HOME" ]; then
#   JAVA_PATH=$(readlink -f "$(which java)")
#   if [ -n "$JAVA_PATH" ]; then
#     JAVA_HOME=$(dirname "$(dirname "$JAVA_PATH")")
#     if [[ "$JAVA_HOME" == */jre ]]; then
#       JAVA_HOME=${JAVA_HOME%/jre}
#     fi
#     export JAVA_HOME
#   fi
# fi

# Set up fzf key bindings and fuzzy completion
eval "$(fzf --bash)"


if command -v fzf &>/dev/null; then
  # Don't source FZF shell integrations if version is older than 0.48 (Avoids `unknown option: --bash`)
  # Version comparison technique courtesy of Luciano Andress Martini:
  # https://unix.stackexchange.com/questions/285924/how-to-compare-a-programs-version-in-a-shell-script
  FZF_VERSION="$(fzf --version | cut -d' ' -f1)"
  if [[ -f ~/.fzf.bash && "$(printf '%s\n' 0.48 "$FZF_VERSION" | sort -V | head -n1)" = 0.48 ]]; then
    . ~/.fzf.bash
  fi
fi

export $(grep -v '^#' ~/.env | xargs)
eval "$(zoxide init bash)"

eval "$(starship init bash)"

export FZF_CTRL_T_OPTS="
  --walker-skip .git,node_modules,target
  --preview 'bat -n --color=always {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"


alias xcp="xclip -selection clipboard"
alias updis="bash /home/marchlak/Scripts/update-discord.sh"
alias nbrc="nvim ~/.bashrc"
alias nvimi3="cd ~/.config/i3; nvim"
alias sbrc="source ~/.bashrc"
alias cgit='echo "$GITHUB_TOKEN" | xclip -selection clipboard'
alias ls="lsd"
alias lso="ls"
alias ll='lsd -alF'
alias la='lsd -A'
alias l='lsd -CF'
alias fzfb='fzf --preview "bat --color=always --style=numbers --line-range=:500 {}"'
alias nvimf='nvim $(fzf -m --preview "bat --color=always --style=numbers --line-range=:500 {}")'
alias cd="z"
alias wifilist='nmcli device wifi list'
wificon() {
  nmcli device wifi connect "$1" password "$2"
}
