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
  local exts=() names=() extras=() args=() files=() ext name list=0

  if [[ $# -lt 1 ]]; then
    echo "Użycie: cgpt [-l] [-e ext ...] [-n nazwa ...] | bez flag: cgpt ext1 [ext2 ...]" >&2
    return 1
  fi

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -e)
        shift
        while [[ $# -gt 0 && "$1" != -* ]]; do exts+=("$1"); shift; done
        ;;
      -n)
        shift
        while [[ $# -gt 0 && "$1" != -* ]]; do names+=("$1"); shift; done
        ;;
      -l)
        list=1
        shift
        ;;
      *)
        extras+=("$1"); shift
        ;;
    esac
  done

  if [[ ${#exts[@]} -eq 0 && ${#names[@]} -eq 0 && ${#extras[@]} -gt 0 ]]; then
    exts=("${extras[@]}")
  fi

  if [[ ${#exts[@]} -eq 0 && ${#names[@]} -eq 0 ]]; then
    echo "Brak wzorców plików." >&2
    return 1
  fi

  for ext in "${exts[@]}"; do
    args+=( -name "*.$ext" -o )
  done
  for name in "${names[@]}"; do
    args+=( -name "$name" -o )
  done
  unset 'args[${#args[@]}-1]'

  mapfile -d '' files < <(find . -type f \( "${args[@]}" \) -print0)

  if [[ ${#files[@]} -eq 0 ]]; then
    echo "Skopiowano 0 plików." >&2
    return 0
  fi

  {
    for file in "${files[@]}"; do
      [[ $list -eq 1 ]] && echo "$file" >&2
      printf '%s\n' "$file"
      cat -- "$file"
    done
  } | xclip -selection clipboard

  echo "Skopiowano ${#files[@]} plików." >&2
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

sensor_uber() {
  local BASE="/home/marchlak/DS360/OPTIMAALL/OPTIMA"
  builtin cd "$BASE" || return 1
  ./gradlew SensorFileGenerator-uberJar --stacktrace || return 1
  local JAR
  JAR=$(ls -t "$BASE"/build/libs/SensorFileGenerator*.jar 2>/dev/null | head -n1)
  [ -n "$JAR" ] || return 1
  mv -f "$JAR" "$BASE/"
}

alias sensorjar='sensor_uber'

sensor_run() {
  local BASE="/home/marchlak/DS360/OPTIMAALL/OPTIMA"
  builtin cd "$BASE" || return 1
  ./gradlew SensorFileGenerator-uberJar --stacktrace || return 1
  local JAR
  JAR=$(ls -t "$BASE"/build/libs/SensorFileGenerator*.jar 2>/dev/null | head -n1)
  [ -n "$JAR" ] || return 1
  mv -f "$JAR" "$BASE/" || return 1
  java -Xmx20g -jar "$BASE/$(basename "$JAR")" -c setups/main.json -n test
}

alias sensorrun='sensor_run'

alias optimajar='optima_uber'

optima_run() {
  local BASE="/home/marchlak/DS360/OPTIMAALL/OPTIMA"
  builtin cd "$BASE" || return 1
  ./gradlew OPTIMA-uberJar --stacktrace || return 1
  local JAR
  JAR=$(ls -t "$BASE"/build/libs/OPTIMA*.jar 2>/dev/null | head -n1)
  [ -n "$JAR" ] || { echo "Nie znaleziono artefaktu JAR"; return 1; }
  mv -f "$JAR" "$BASE/" || return 1
  java -Xmx42g -jar "$BASE/$(basename "$JAR")" -c setups/main.json -n test "$@"
}

alias optimarun='optima_run'

alias watchlogs="tail -F /home/marchlak/logs/uberjar.log |  bat --paging=never -l log"

optima_test() {
  local BASE="/home/marchlak/DS360/OPTIMAALL/OPTIMA"
  local CFG="$BASE/setups/main.json"
  local LOG="$BASE/logs.log"
  local WPY="$HOME/Scripts/watcher.py"
  local VPY="$HOME/Scripts/venv/bin/python"
  local ROOT="/home/marchlak/simulations/test-simulations"
  local CWD="$PWD"

  for a in "$@"; do
    case "$a" in
      -h|--help)
        cat <<EOF
Użycie: optima_test [PLIK_TESTÓW]

Opis:
  Buduje OPTIMA-uber.jar, uruchamia po kolei symulacje z podanego pliku JSON
  i zapisuje linki do wyników w katalogu:
    ${ROOT}/<DATA>/<GODZINA>_<NAZWA_PLIKU_BEZ_ROZSZERZENIA>.txt
  Watcher uruchamiany jest raz na sesję. CTRL+C przerywa sesję, ubija procesy
  i przywraca oryginalny setups/main.json.

Argumenty:
  PLIK_TESTÓW   Nazwa/ścieżka do pliku JSON z listą testów. Gdy nie podano,
                używane są: ${ROOT}/main.json lub ${ROOT}/main-test.json.
                Rozpoznawanie ścieżki: najpierw katalog bieżący, potem ${ROOT}.

Format pliku testów (dwa warianty):
1) Tablica:
[
  { "scenario": 3205, "server": "optima-diehl", "description": "opcjonalny opis", "repeat": 2, "time": 8 },
  ...
]
2) Obiekt z kluczem "tests":
{ "tests": [ { ...jak wyżej... } ] }

Pola wpisu:
  scenario    (wymagane) numer scenariusza
  server      (wymagane) wartość dataSource.databaseName
  description (opcjonalne) opis testu; trafi do pliku wynikowego
  repeat      (opcjonalne) ile razy powtórzyć dany test, domyślnie 1
  time        (opcjonalne) wartość do main.maxTime i main.roundLength, domyślnie 8
EOF
        return 0
        ;;
    esac
  done

  local TEST_FILE_RAW="${1:-}"
  local TEST_FILE=""
  if [ -n "$TEST_FILE_RAW" ]; then
    if [ -r "$TEST_FILE_RAW" ]; then TEST_FILE="$CWD/$TEST_FILE_RAW"
    elif [ -r "./$TEST_FILE_RAW" ]; then TEST_FILE="$CWD/$TEST_FILE_RAW"
    elif [ -r "$ROOT/$TEST_FILE_RAW" ]; then TEST_FILE="$ROOT/$TEST_FILE_RAW"
    else echo "Brak pliku testów: $TEST_FILE_RAW"; return 1
    fi
  else
    if [ -r "$ROOT/main.json" ]; then TEST_FILE="$ROOT/main.json"
    elif [ -r "$ROOT/main-test.json" ]; then TEST_FILE="$ROOT/main-test.json"
    else echo "Brak domyślnego pliku testów w $ROOT"; return 1
    fi
  fi

  command -v readlink >/dev/null 2>&1 && TEST_FILE="$(readlink -f "$TEST_FILE")"
  [ -r "$TEST_FILE" ] || { echo "Brak pliku: $TEST_FILE"; return 1; }
  [ -r "$WPY" ] || { echo "Brak skryptu: $WPY"; return 1; }
  [ -x "$VPY" ] || VPY="$(command -v python3 || true)"
  [ -n "$VPY" ] || { echo "Brak Pythona"; return 1; }

  builtin cd "$BASE" || return 1
  ./gradlew OPTIMA-uberJar --stacktrace || return 1
  local JAR; JAR=$(ls -t "$BASE"/build/libs/OPTIMA*.jar 2>/dev/null | head -n1) || return 1
  mv -f "$JAR" "$BASE/OPTIMA-uber.jar" || return 1
  command -v jq >/dev/null 2>&1 || { echo "Zainstaluj jq"; return 1; }
  : > "$LOG"

  local BAK; BAK=$(mktemp) || return 1
  cp -f "$CFG" "$BAK" || return 1

  local CHILD_PIDS=()
  restore_cfg() { cp -f "$BAK" "$CFG" >/dev/null 2>&1; }
  cleanup_all() { local p; for p in "${CHILD_PIDS[@]}"; do kill -TERM "$p" 2>/dev/null; done; sleep 1; for p in "${CHILD_PIDS[@]}"; do kill -0 "$p" 2>/dev/null && kill -KILL "$p" 2>/dev/null; done; }
  on_exit() { cleanup_all; restore_cfg; }
  trap on_exit EXIT
  on_int() { echo; echo "Przerwano"; cleanup_all; restore_cfg; exit 130; }
  trap on_int INT
  trap on_exit TERM

  local len; len=$(jq 'if type=="array" then length elif (.tests|type?)=="array" then (.tests|length) else 0 end' "$TEST_FILE") || return 1
  [ "$len" -gt 0 ] || { echo "Pusty zestaw testów"; return 1; }

  local DATE_DIR; DATE_DIR="$(date +%F)"
  local TIME_TAG; TIME_TAG="$(date +%H-%M)"
  local SRC_NAME; SRC_NAME="$(basename "$TEST_FILE")"
  local OUT_DIR="$ROOT/$DATE_DIR"
  mkdir -p "$OUT_DIR"
  local OUT_TXT="$OUT_DIR/${TIME_TAG}_${SRC_NAME%.*}.txt"
  local EXTRA_FILE="$OUT_DIR/.current_extra"

  local G_BRANCH; G_BRANCH=$(git -C "$BASE" rev-parse --abbrev-ref HEAD 2>/dev/null)
  local G_HASH;   G_HASH=$(git -C "$BASE" rev-parse HEAD 2>/dev/null)
  local G_AUTH;   G_AUTH=$(git -C "$BASE" log -1 --pretty='%an <%ae>' 2>/dev/null)
  local G_DATE;   G_DATE=$(git -C "$BASE" log -1 --pretty='%ad' --date=iso-strict 2>/dev/null)
  local G_SUBJ;   G_SUBJ=$(git -C "$BASE" log -1 --pretty='%s' 2>/dev/null)
  local G_BODY;   G_BODY=$(git -C "$BASE" log -1 --pretty='%b' 2>/dev/null)

  {
    echo "started_at: $(date -Iseconds)"
    echo "repo: $BASE"
    echo "source_tests: $TEST_FILE"
    echo "branch: ${G_BRANCH:-unknown}"
    echo "commit: ${G_HASH:-unknown}"
    echo "author: ${G_AUTH:-unknown}"
    echo "commit_date: ${G_DATE:-unknown}"
    echo "subject: ${G_SUBJ:-}"
    [ -n "$G_BODY" ] && { echo "body:"; echo "$G_BODY"; }
    echo
    echo "links:"
  } > "$OUT_TXT"

  local had_m=0; case $- in *m*) had_m=1; set +m;; esac
  ( PYTHONUNBUFFERED=1 "$VPY" "$WPY" --delay-hour 0 --uber-logs off --tests-save-file "$OUT_TXT" --tests-extra-file "$EXTRA_FILE" --no-open 2>&1 | sed -u 's/^/[watcher] /' ) & local wpid=$!; CHILD_PIDS+=("$wpid")

  for ((i=0;i<len;i++)); do
    local SCEN DB DESC REPEAT TIMEV
    SCEN=$(jq -r 'if type=="array" then .[$i].scenario else .tests[$i].scenario end' --argjson i "$i" "$TEST_FILE")
    DB=$(jq -r 'if type=="array" then .[$i].server else .tests[$i].server end' --argjson i "$i" "$TEST_FILE")
    DESC=$(jq -r 'if type=="array" then (.[$i].description // "") else (.tests[$i].description // "") end' --argjson i "$i" "$TEST_FILE")
    REPEAT=$(jq -r 'if type=="array" then (.[$i].repeat // 1) else (.tests[$i].repeat // 1) end' --argjson i "$i" "$TEST_FILE")
    TIMEV=$(jq -r 'if type=="array" then (.[$i].time // 8) else (.tests[$i].time // 8) end' --argjson i "$i" "$TEST_FILE")

    [[ "$SCEN" =~ ^[0-9]+$ ]] || { echo "Nieprawidłowy scenario w pozycji $i"; return 1; }
    [ -n "$DB" ] || { echo "Brak databaseName w pozycji $i"; return 1; }
    [[ "$REPEAT" =~ ^[0-9]+$ ]] || REPEAT=1
    [ "$REPEAT" -ge 1 ] || REPEAT=1
    [[ "$TIMEV" =~ ^[0-9]+$ ]] || TIMEV=8

    if [ -n "$DESC" ] && [ "$DESC" != "null" ]; then
      printf 'description=%s time=%s\n' "$(printf '%s' "$DESC" | tr '\n' ' ')" "$TIMEV" > "$EXTRA_FILE"
    else
      printf 'time=%s\n' "$TIMEV" > "$EXTRA_FILE"
    fi

    jq --argjson s "$SCEN" --arg db "$DB" --argjson t "$TIMEV" \
       '.main.scenarioName=$s
        | .connectionPool["dataSource.databaseName"]=$db
        | .main.maxTime=$t
        | .main.roundLength=$t' \
       "$BAK" > "$CFG.tmp" || return 1
    mv -f "$CFG.tmp" "$CFG" || return 1

    for ((r=1;r<=REPEAT;r++)); do
      : > "$LOG"
      if [ "$REPEAT" -gt 1 ]; then
        echo "==> Uruchamiam symulację ${SCEN} (databaseName=${DB}, time=${TIMEV}) [powtórzenie ${r}/${REPEAT}]"
      else
        echo "==> Uruchamiam symulację ${SCEN} (databaseName=${DB}, time=${TIMEV})"
      fi
      [ -n "$DESC" ] && [ "$DESC" != "null" ] && echo "    Opis: $DESC"

      java -Xmx42g -jar "$BASE/OPTIMA-uber.jar" -c "$CFG" -n test >/dev/null 2>&1 & local jpid=$!; CHILD_PIDS+=("$jpid")
      ( tail -F -n0 "$LOG" | grep -m1 -E 'Finishing run' ) >/dev/null 2>&1 & local mpid=$!; CHILD_PIDS+=("$mpid")

      while :; do
        if ! kill -0 "$jpid" 2>/dev/null; then break; fi
        if ! kill -0 "$mpid" 2>/dev/null; then break; fi
        sleep 1
      done

      if kill -0 "$jpid" 2>/dev/null; then
        kill -TERM "$jpid" 2>/dev/null
        for _ in {1..30}; do kill -0 "$jpid" 2>/dev/null || break; sleep 1; done
        kill -0 "$jpid" 2>/dev/null && kill -KILL "$jpid" 2>/dev/null
        wait "$jpid" 2>/dev/null
      fi
      kill "$mpid" 2>/dev/null; wait "$mpid" 2>/dev/null
      echo "==> Zakończono symulację ${SCEN} ${REPEAT:+[${r}/${REPEAT}]}"
    done
  done

  kill "$wpid" 2>/dev/null; wait "$wpid" 2>/dev/null
  [ $had_m -eq 1 ] && set -m
  echo "Zapis: $OUT_TXT"
}

alias optima_tail='tail -n0 -F /home/marchlak/DS360/OPTIMAALL/OPTIMA/logs.log | bat --paging=never -l log'
export PATH="$HOME/.local/bin:$PATH"

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash)"
  alias cd='z'
fi

alias cdtest='cd /home/marchlak/simulations/test-simulations'


open_urls() {
  local src="${1:-/dev/stdin}"
  grep -Eo 'https?://[^[:space:]]+' "$src" | sort -u | xargs -r -n1 xdg-open >/dev/null 2>&1
}

alias ol='open_urls'
