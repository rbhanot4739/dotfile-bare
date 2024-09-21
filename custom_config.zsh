# vim: set filetype=sh:
export MANPAGER='nvim +Man! -c "set laststatus=0"'
export BAT_THEME="ansi"

# =================================== Fzf config ===================================

local HEADER_MSG="--preview-window :hidden --bind '?:change-preview-window(right|down|right,70%|hidden)' --color header:italic --header 'Press ? to toggle'"
local prev_win_opts="--preview-window :hidden --bind '?:change-preview-window(right|down|right,70%|hidden)' --color header:italic --header 'Press ? enable/toggle b/w preview modes'"
# paths to ignore in addition to ~/.ignore
local -a x_paths=("~/local-repo")
local xcludes=""
for xpath in $x_paths; do
  xcludes="$xcludes --exclude '$xpath' "
done

export FZF_COMPLETION_TRIGGER='**'
export FZF_DEFAULT_OPTS="-1 -0  --height 50% --tmux bottom,50% --layout=reverse --border top " # Starts fzf in lower half of the screen taking 40% height
export FZF_DEFAULT_COMMAND="fd --type file --follow . $xcludes"
# export FZF_DEFAULT_COMMAND="fd --type file --follow . --exclude '*.pyc' --exclude '*.pyi' --exclude '.vscode'"
export FZF_CTRL_R_OPTS=""

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'bat --style=full --color always {}' $prev_win_opts"

export FZF_ALT_C_COMMAND="fd --type directory --follow --exclude '.git' ."
export FZF_ALT_C_OPTS="--preview 'tree -C {}' $prev_win_opts"

export FZF_COMPLETION_TRIGGER="**"
_fzf_compgen_path() {
  fd --follow --exclude ".git" . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type d --follow --exclude ".git" . "$1"
}

# fuzzy searching functions

function frg() {
  #!/usr/bin/env bash

  # Switch between Ripgrep launcher mode (CTRL-R) and fzf filtering mode (CTRL-F)
  rm -f /tmp/rg-fzf-{r,f}
  RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case "
  INITIAL_QUERY="${*:-}"
  fzf --ansi --disabled --query "$INITIAL_QUERY" \
    --bind "start:reload($RG_PREFIX {q})+unbind(ctrl-r)" \
    --bind "change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
    --bind "ctrl-f:unbind(change,ctrl-f)+change-prompt(2. fzf> )+enable-search+rebind(ctrl-r)+transform-query(echo {q} > /tmp/rg-fzf-r; cat /tmp/rg-fzf-f)" \
    --bind "ctrl-r:unbind(ctrl-r)+change-prompt(1. ripgrep> )+disable-search+reload($RG_PREFIX {q} || true)+rebind(change,ctrl-f)+transform-query(echo {q} > /tmp/rg-fzf-f; cat /tmp/rg-fzf-r)" \
    --color "hl:-1:underline,hl+:-1:underline:reverse" \
    --prompt '1. ripgrep> ' \
    --delimiter : \
    --header '╱ CTRL-R (ripgrep mode) ╱ CTRL-F (fzf mode) ╱' \
    --preview 'bat --color=always {1} --highlight-line {2}' \
    --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
    --bind 'enter:become(vim {1} +{2})'
}

#  =================================== Functions ===================================

get_hidden_files() {
  if [[ $1 == "long" ]]; then
    if [[ $2 ]]; then
      OLDDIR=$(pwd)
      cd $2
      eza --group-directories-first -snew -dl .* 2>/dev/null
      cd $OLDDIR
    else
      eza --group-directories-first -snew -dl .* 2>/dev/null
    fi
  else
    if [[ $1 ]]; then
      OLDDIR=$(pwd)
      cd $1
      eza --group-directories-first -snew -d .* 2>/dev/null
      cd $OLDDIR
    else
      eza --group-directories-first -snew -d .* 2>/dev/null
    fi

  fi
}

# j() {
#     [ $# -gt 0 ] && [ `fasd -d "$@" |wc -l` -gt 0 ] && fasd_cd -d "$@" && return
#     local dir
#     dir="$(`echo $FZF_ALT_C_COMMAND` | fzf -1 -0 +m)" && $(fasd -A $dir) && cd "${dir}" || return 1
# }

debug_print() {
  if [[ "$DEBUG" -eq 1 ]]; then
    echo "DEBUG: $@"
  fi
}

add_to_zsh_history() {
  print -s $@
}

manage_tmux_sessions() {

  header="Press enter to create new session if one doesn't exist with same name, delete to kill existing session\n"
  fzf_binds='enter:accept-or-print-query,delete:become(tmux kill-session -t {})'
  fzf_cmd="fzf --height 50% --margin=10%,40%,10%,10% --reverse --border=rounded --border-label='Select session to manage'  --color=label:green:bold --color=border:green  --bind \"$fzf_binds\" --color=header:yellow:Italic --header \"$header\""

  inside_tmux() {
    if [[ -n "$1" ]]; then
      tmux switch-client -t "$1" 2>/dev/null || tmux new-session -d -s "$1" && tmux switch-client -t "$1"
      return
    else
      sess_list=$(tmux list-sessions -F "#{session_name}" 2>/dev/null)
      session=$(echo -n -e "$sess_list" | eval "$fzf_cmd")
      if [[ -n $session ]]; then
        # echo "WIll try to attach or create $session"
        tmux switch-client -t "$session" 2>/dev/null || tmux new-session -d -s "$session" && tmux switch-client -t "$session"
      fi
    fi
  }

  outside_tmux() {
    if [[ -n "$1" ]]; then
      # if an argument is supplied try attaching to that session if exists else create a new one but do NOT attach to it
      tmux attach-session -t "$1" 2>/dev/null || tmux new-session -s "$1"
      return
    else
      sess_list=$(tmux list-sessions -F "#{session_name}" 2>/dev/null)
      session=$(echo -n "$sess_list" | eval "$fzf_cmd")
      if [[ -n $session ]]; then
        # echo "WIll try to attach or create $session"
        tmux attach-session -t "$session" || tmux new-session -s "$session"
      else
        tmux new-session -s "default"
      fi

    fi

  }

  if [[ $# -gt 1 ]]; then
    echo "Invalid use of command, Usage: mx [session-name]"
    return
  fi

  if [[ -n "$TMUX" ]]; then
    inside_tmux $@
  else
    outside_tmux $@
  fi
}

mx() {
  # /bin/bash ~/.zsh/tmux-sessions.sh $@
  manage_tmux_sessions $@
}

make_fasd_dir_jump() {
  if [ $(fasd -d "$@" | wc -l) -gt 0 ]; then
    debug_print "$@ matched to $(fasd -d "$@" | head)"
    fasd_cd -d "$@"
  else
    debug_print "$@ not found it fasd"
    local dir
    dir="$($(echo $FZF_ALT_C_COMMAND) | fzf -1 -0 +m)" && $(fasd -A $dir) && cd "${dir}" || return 1
  fi
}

cd_up() {
  # some comment

  local num_dots=${#1}
  # build a path like ../../../ using a loop based on num_dots
  local path=""
  for ((i = 1; i <= num_dots; i++)); do
    path="../$path"
  done
  debug_print "moving up by $num_dots directories to PATH $path"
  cd $path
}

# open FZF prompt fuzzy jump to directory
ja() {
  local dir
  if [ -z "$1" ]; then
    SRC_DIR=$HOME
  else
    SRC_DIR=$1
  fi
  dir="$(fd --type directory --hidden --follow . $SRC_DIR | fzf -1 -0 +m)" && $(fasd -A $dir) && cd "${dir}" || return 1
}

unalias j 2>/dev/null
j() {
  if [[ $# -eq 0 ]]; then
    ja $PWD
  elif [[ $1 && "$1" =~ "^\.+$" ]]; then
    cd_up $1
  else
    make_fasd_dir_jump $@
  fi
}

# open file with vim if its in FASD cache else open FZF and then add to FASD
unalias v 2>/dev/null
v() {
  [ $# -gt 0 ] && [ $(fasd -f "$@" | wc -l) -gt 0 ] && file=$(fasd -f "$@" | head) && add_to_zsh_history "${EDITOR} ${file}" && ${EDITOR} "$file" && return
  local file
  file="$(fzf --select-1 --exit-0 +m)" && $(fasd -A $file) && add_to_zsh_history "${EDITOR} ${file}" && ${EDITOR} "${file}" || return 1
}

# same as ja but insted open file in vim
va() {
  local file
  if [ -z "$1" ]; then
    SRC_DIR=$HOME
  else
    SRC_DIR=$1
  fi
  file="$(fd --type file --hidden --follow . $SRC_DIR | fzf -1 -0 +m)" && $(fasd -A $file) && add_to_zsh_history "${EDITOR} ${file}" && ${EDITOR} "${file}" || return 1
}

gbf() {
  git checkout $(git branch | fzf | tr -d ‘[:space:]’)
}

gbfa() {
  git checkout $(git branch --all | fzf | tr -d ‘[:space:]’)
}

# Interactively ripgrep through files and open then at exact line
#ff() {
#    local file
#    local line
#    read -r file line <<< `rg --vimgrep --line-number --hidden "$@" |awk -F':' '{print $1,$2}'|fzf -0 -1 --height 100% --preview="rg --colors 'match:fg:red' --ignore-case --pretty '$@' {1}"`
#    if [[ -n $file ]]
#    then
#     vim $file +$line
#    fi
#}

#  =================================== Aliases ===================================

# if [ $(uname -s) = "Darwin" ]; then
#   alias ls='ls -G'
# fi

alias fman="fd -t f . --follow /usr/share/man/ /opt/homebrew/share/man/ | fzf --layout reverse --prompt '∷ ' --pointer ▶ --marker ⇒ --delimiter '/' --with-nth=-1 --height 40% --border=double | xargs man"
alias m="mint "
alias mf="mint format"
alias mb="mint build"
alias mbc="mint build-cfg"
alias mun="mint undeploy"
alias mbd="mint deploy"
alias rfmt="rexec mint format"
alias rbld="rexec mint build"
alias rbld="rexec mint test"
alias rcfg="rexec mint build-cfg"
alias rundep="rexec mint undeploy"
alias rdep="rexec mint deploy"
alias cat='/opt/homebrew/bin/bat --color always'

alias ls='eza --group-directories-first -snew -F -I "*pyc*"'
alias ll='ls  --icons -lg'
alias lst='ls -T -L=3'
alias lsd='ls -D'

alias lsa='ls -a'
alias lsh='get_hidden_files '
alias llh='get_hidden_files long '

alias grep='rg'
alias dud='du -d 1 -hc 2> /dev/null | grep -Ev "\.$"|sort -h'
alias h='history 0'

alias vim='nvim'
alias vi='nvim'
alias ssh='ssh '
alias xx='exit'
alias ee='$EDITOR ~/.zshrc'
alias c='clear'
alias r='source ~/.zshrc'
alias cp='cp -av'
alias md='mkdir'
alias hg="h | rg"
alias mux="tmuxinator "

# git aliases
alias g="git "
alias ga='git add '
alias gco='git checkout'
alias gcom='git checkout master'
alias gcm='git commit -a -m '
alias gcma='git commit --amend '
alias gs='git status'
alias gb='git branch '
alias gbl='gb -l'
alias gba='gb -a'
# diff commands
alias gd='git diff'
alias gdf='git diff --name-status'
alias gsd='git show --pretty="" --name-status ' # show changes for a commit

# push/pull
alias gpl='git pull'
alias gps='git push '

# log/reflog
alias glg='git log'
alias gl="git log --pretty=format:'%C(auto)%h%d%Creset %s %C(cyan) [%aN] %Creset %C(green)(%ci)%Creset'"
alias gla="git log --pretty=format:'%C(auto)%h%d%Creset %s %C(cyan) [%aN] %Creset %C(green)(%ci)%Creset' --graph --all"
alias grf='git reflog '
alias grfp='git reflog --date=local'

# rebase commmands
alias grb='git rebase '
alias grbi='git rebase -i '
alias grbm='git rebase master'
alias grbc='git rebase --continue '
alias grba='git rebase --abort '
# reset/revert
alias gdk='git restore '
alias grst='git reset '

# vagrant aliases
alias vsh='vagrant ssh'
alias vrel='vagrant reload'

alias dk=docker
alias dkc=docker-compose
alias .='j .'
alias ..='j ..'
alias ...='j ...'
alias ....='j .....'
alias .....='j .....'
