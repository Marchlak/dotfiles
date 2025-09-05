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




export $(grep -v '^#' ~/.env | xargs)


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
alias cd='z'
alias fzfb='fzf --preview "bat --color=always --style=numbers --line-range=:500 {}"'
alias nvimf='nvim $(fzf -m --preview "bat --color=always --style=numbers --line-range=:500 {}")'
alias wifilist='nmcli device wifi list'
wificon() {
  nmcli device wifi connect "$1" password "$2"
}
export AWS_PROFILE=optima-sim-scenarios
cgpt() {
  if [ "$#" -lt 1 ]; then
    echo "Użycie: cgpt rozszerzenie1 [rozszerzenie2 ...]" >&2
    return 1
  fi
  local ext args
  args=()
  for ext in "$@"; do
    args+=( -name "*.$ext" -o )
  done
  unset 'args[${#args[@]}-1]'
  find . -type f \( "${args[@]}" \) -print0 |
  while IFS= read -r -d '' file; do
    printf '%s\n' "$file"
    cat "$file"
  done | xclip -selection clipboard
}
export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
export PATH=$JAVA_HOME/bin:$PATH

runwatcher() {
    local delay=8
    local require_truncate=true
    local limit=1
    local saveflag=false
    local savedir=""
    local uber_scenarios=()
    local vpy="/home/marchlak/Scripts/venv/bin/python"
    local script="/home/marchlak/Scripts/watcher.py"
    local jar="/home/marchlak/DS360/OPTIMAALL/OPTIMA/OPTIMA-uber.jar"
    local jdir="$(dirname "$jar")"
    local usage=$'Użycie: runwatcher [OPCJE]\n\nOpcje:\n  -d, --delay-hour N          opóźnienie (domyślnie 6)\n  -t, --require-truncate      wymuś truncate (domyślne)\n  -N, --no-truncate           wyłącz truncate\n  -n, --limit N               w trybie normalnym: limit po truncate; w -ub: uruchomień na scenariusz\n  -s, --save[=DIR]            zapisuj linki\n  -ub SCEN1 [SCEN2 ...]       tryb uberjaru z listą scenariuszy\n  -h, --help                  pomoc\n  --                          zakończ parsowanie i przekaż resztę do skryptu\n  Dodatkowe opcje są przekazywane bez zmian do watcher.py'

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -d|--delay-hour) delay="$2"; shift 2 ;;
            -t|--require-truncate) require_truncate=true; shift ;;
            -N|--no-truncate) require_truncate=false; shift ;;
            -n|--limit) limit="$2"; shift 2 ;;
            -s|--save)
                saveflag=true
                if [[ -n "$2" && "$2" != -* ]]; then
                    savedir="$2"; shift 2
                else
                    shift
                fi
                ;;
            -ub)
                shift
                while [[ -n "$1" && "$1" != -* ]]; do
                    uber_scenarios+=("$1"); shift
                done
                ;;
            -h|--help) printf "%s" "$usage"; return 0 ;;
            --) shift; break ;;
            *) break ;;
        esac
    done

    local cmd=("$vpy" "$script" --delay-hour "$delay" --limit-per-truncate "$limit" --jar "$jar")
    [ "$require_truncate" = true ] && cmd+=("--require-truncate")
    if [ "$saveflag" = true ]; then
        cmd+=("--save")
        [ -n "$savedir" ] && cmd+=("$savedir")
    fi
    if [ "${#uber_scenarios[@]}" -gt 0 ]; then
        cmd+=("-ub" "${uber_scenarios[@]}")
    fi
    cmd+=("$@")

    pushd "$jdir" >/dev/null || { echo "Nie mogę wejść do $jdir"; return 1; }
    "${cmd[@]}"
    local rc=$?
    popd >/dev/null
    return $rc
}

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

eval "$(starship init bash)"
eval "$(zoxide init bash)"
alias filecount="bash ~/Scripts/file_count.sh"

optima_uber() {
  local BASE="/home/marchlak/DS360/OPTIMAALL/OPTIMA"
  cd "$BASE" || return 1
  ./gradlew OPTIMA-uberJar --stacktrace || return 1
  local JAR
  JAR=$(ls -t "$BASE"/build/libs/*.jar 2>/dev/null | head -n1)
  [ -n "$JAR" ] || return 1
  mv -f "$JAR" "$BASE/"
}

alias optimajar='optima_uber'
alias watchlogs="tail -F /home/marchlak/logs/uberjar.log |  bat --paging=never -l log"
