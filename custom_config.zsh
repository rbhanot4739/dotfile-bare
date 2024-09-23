# vim: set filetype=sh:
export MANPAGER='nvim +Man! -c "set laststatus=0"'
export BAT_THEME="ansi"

#  =================================== Functions ===================================
source $HOME/fzf_config.zsh

get_hidden_files() {
  if [[ $1 == "long" ]]; then
    local params=('--git' '--group' '--group-directories-first' '--time-style=long-iso' '--color-scale=all' '--icons' '--header')
    if [[ $2 ]]; then
      OLDDIR=$(pwd)
      cd $2
      eza $params --group-directories-first -snew -dl .* 2>/dev/null
      cd $OLDDIR
    else
      eza $params --group-directories-first -snew -dl .* 2>/dev/null
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
  fzf_cmd="fzf  --height 50% --margin=10%,40%,10%,10% --reverse --border=rounded --border-label='Select session to manage'  --color=label:green:bold --color=border:green  --bind \"$fzf_binds\" --color=header:yellow:Italic --header \"$header\""

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
  /bin/bash $HOME/tmux-sessions.sh $@
  # manage_tmux_sessions $@
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


gbf() {
  git checkout $(git branch | fzf | tr -d ‘[:space:]’)
}

gbfa() {
  git checkout $(git branch --all | fzf | tr -d ‘[:space:]’)
}

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
alias cat='bat --color always'

# create folowing aliases only if eza is installed else use ls
if [[ $(command -v eza) ]]; then
  local eza_params=('--git' '--group' '--group-directories-first' '--time-style=long-iso' '--color-scale=all' '--icons')
  alias ls='eza -I "*pyc*" $eza_params'
  alias lsa='ls --all'
  # alias l='ls --git-ignore'
  # print tree format
  alias lst='ls -T -L=3'
  alias ll='ls --header --long --sort=modified'
  alias l='ll'
  alias lla='ll --all'
  # sort by size
  alias lS='ll --sort=size'
  alias lSa='lla --sort=size'
  alias llA='eza -lbhHigUmuSa'
  alias lsd='ls -D'
  alias lsf='ls -F'
  alias llf='ll -F'
  alias lld='ll -D'
  alias lsh='get_hidden_files '
  alias llh='get_hidden_files long '
fi

alias grep='rg'
alias dud='du -d 1 -hc 2> /dev/null | grep -Ev "\.$"|sort -h'
alias h='history 0'

alias vim='nvim'
alias vi='nvim'
alias ssh='ssh '
alias xx='exit'
alias ee='$EDITOR ~/.zshrc'
alias c='clear'
alias r='exec zsh'
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
alias .='z .'
alias ..='z ..'
alias ...='z ...'
alias ....='z .....'
alias .....='z .....'
alias zz='z -'


local function za() {
local src_dir
[[ $# -eq 0 ]] && src_dir=$PWD || src_dir=$@
debug_print $src_dir
dir="$(eval $find_dirs_cmd $src_dir | fzf -1 -0 +m)" && cd "${dir}" || return 1
}


v() {
  local file
  if [[ $# -gt 0 ]]; then
    nvim $@
  else
    files="$(eval $find_files_cmd $PWD | fzf --select-1 --exit-0 +m)" && nvim "${files}" || return 1
      fi
  
}
