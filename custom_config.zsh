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
  # build a pth like ../../../ using a loop based on num_dots
  local pth=""
  for ((i = 1; i <= num_dots; i++)); do
    pth="../$pth"
  done
  debug_print $(which cd)
  debug_print "moving up by $num_dots directories to pth $pth"
  cd $pth
}

gbf() {
  local branch=$(git branch | fzf --bind "enter:accept-or-print-query" | tr -d ' ')
  git checkout $branch 2>/dev/null || git checkout -b $branch
}

gbfa() {
  git checkout $(git branch --all | fzf)
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

# some utility aliases
alias dud='du -d 1 -hc 2> /dev/null | grep -Ev "\.$"|sort -h'
alias h='history 0'
alias ssh='ssh '
alias xx='exit'
alias ee='$EDITOR ~/.zshrc'
alias c='clear'
alias r='exec zsh'
alias cp='cp -av'
alias md='mkdir'
alias hg="h | rg"
alias wh='which '
alias wich='which '
[[ $(command -v nvim) ]] && alias vim='nvim'
[[ $(command -v rg) ]] && alias grep='rg'
[[ $(command -v tmuxinator) ]] && alias mux="tmuxinator "
if [[ $(command -v eza) ]]; then
  alias less='bat'
  alias cat='bat --color always'
fi
if [[ $(command -v gh) ]]; then
  alias ghc='gh copilot explain '
  alias ghcs='gh copilot suggest '
fi

# git aliases
alias lg='lazygit'
alias g="git "
alias ga='git add '
alias gco='git co '
alias gcb='git cb '
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
alias .='cd_up .'
alias ..='cd_up ..'
alias ...='cd_up ...'
alias ....='cd_up .....'
alias .....='cd_up .....'
alias zz='z -'

# local function za() {
# local src_dir
# [[ $# -eq 0 ]] && src_dir=$PWD || src_dir=$@
# debug_print $src_dir
# dir="$(eval $find_dirs_cmd $src_dir | fzf -1 -0 +m)" && cd "${dir}" || return 1
# }
#

v() {
  # Opens files or directories using the default editor.
  #
  # If arguments are provided, it checks if they are files or directories.
  # If all arguments are files, it opens them directly.
  # If all arguments are directories, it uses `fd` to find files in those directories and then pipe it through to  `fzf` to select files
  # If no arguments are provided, it uses `fzf` to select files from the current directory.
  #
  # Arguments:
  #   $@ - List of files or directories to open.
  #
  # Returns:
  #   0 if files are successfully opened, 1 otherwise.
  #
  # Example usage:
  #   v file1.txt file2.txt
  #   v /path/to/directory1 /path/to/directory2 /path/to/directory3 ...
  #   v
  #
  # Note: The function uses:
  #   - `fd` to find files
  #   - `fzf` for fuzzy file selection.
  #   - adds the opened files to the zsh history.
  #  - opens the files using the default editor.
  #

  local selected_files

  local all_dirs=true
  local all_files=true

  for arg in "$@"; do
    if [[ -f "$arg" ]]; then
      all_dirs=false
    elif [[ -d "$arg" ]] || [[ -L "$arg" ]]; then
      all_files=false
    fi
  done

  if [[ $# -gt 0 ]]; then
    local args=$@
    if $all_files; then
      ${EDITOR} $@
      return 0
    elif $all_dirs; then
      selected_files="$(eval $find_files_cmd $args | fzf --select-1 --exit-0 +m)"
    else
      echo "Arguments must of same type i.e. either all files or directories"
      return 1
    fi
  else
    selected_files="$(eval $find_files_cmd $PWD | fzf --select-1 --exit-0 +m)"
  fi

  [[ ! -z $selected_files ]] && echo $selected_files && add_to_zsh_history "${EDITOR} ${selected_files}" && ${EDITOR} "${selected_files}" || return 1
}
