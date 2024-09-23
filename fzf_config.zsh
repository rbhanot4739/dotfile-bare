
# =================================== Fzf config ===================================

# local HEADER_MSG="--preview-window :hidden --bind '?:change-preview-window(right|down|right,70%|hidden)' --header-first --header 'Press ? to toggle'"
local prev_win_opts="--preview-window :hidden --bind '?:change-preview-window(right|down|right,70%|hidden)' --header-first --header 'Press ? enable/toggle b/w preview modes'"
# paths to ignore in addition to ~/.ignore
local -a x_paths=("~/local-repo")
local xcludes=""
for xpath in $x_paths; do
  xcludes="$xcludes --exclude '$xpath' "
done
local find_all_cmd="fd --follow . $xcludes "
local find_files_cmd="$find_all_cmd --type file "
local find_dirs_cmd="$find_all_cmd --type directory "

export FZF_DEFAULT_OPTS=" -1 -0 --height 50% --tmux center,70%,60% --layout=reverse --border rounded --multi '--bind=shift-tab:up,tab:down,ctrl-space:toggle' " # Starts fzf in lower half of the screen taking 40% height

# if [[ $TMUX ]]; then
#   export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --tmux bottom,50%"
# fi
export FZF_DEFAULT_COMMAND="$find_all_cmd"
# export FZF_DEFAULT_COMMAND="fd --type file --follow . --exclude '*.pyc' --exclude '*.pyi' --exclude '.vscode'"
export FZF_CTRL_R_OPTS=""

export FZF_CTRL_T_COMMAND="$find_files_cmd"
export FZF_CTRL_T_OPTS="--preview-label='File preview' --preview 'bat --style=full --color always {}' $prev_win_opts"

# export FZF_ALT_C_COMMAND="fd --type directory --follow --exclude '.git' ."
export FZF_ALT_C_COMMAND="$find_dirs_cmd"
export FZF_ALT_C_OPTS="--preview-label='Files' --preview 'tree -C {}' $prev_win_opts"

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
  INITIAL_QUERY="${*:-}"
  RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case "
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

