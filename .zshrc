# vim: ft=sh

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# bootstrap zinit
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

if [[ -f "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

zinit ice wait lucid
zinit ice depth=1; zinit load romkatv/powerlevel10k

zinit ice wait lucid
zinit load zdharma-continuum/fast-syntax-highlighting
zinit ice wait lucid
zinit load zsh-users/zsh-completions
zinit ice wait lucid
zinit load zsh-users/zsh-autosuggestions
zinit load zsh-users/zsh-history-substring-search

autoload -Uz compinit && compinit
# fpath=(~/zsh_functions $fpath);
# export export FPATH=$FPATH
# autoload -U $fpath[1]/*(.:t)

# Enable colors
autoload -U colors && colors

zinit ice wait lucid
zinit load Aloxaf/fzf-tab

# History
export HISTSIZE=100000
export HISTFILE=~/.zsh_history
export SAVEHIST=$HISTSIZE
export HISTDUP=erase

# Append history to the history file, rather than overwriting it
setopt append_history


setopt hist_ignore_space # Ignore commands that start with a space in the history
setopt hist_ignore_all_dups # remove older duplicate entries from history
setopt share_history # share history between different instances of the shell
setopt hist_reduce_blanks # remove blanks from history items
setopt inc_append_history # save history entries as soon as they are entered
setopt hist_save_no_dups # Do not save duplicate commands in the history
setopt hist_find_no_dups # Do not display duplicate commands when searching the history

if [[ `uname -a` == *Darwin* ]]; then
  eval $(gdircolors -b)
  else
    eval $(dircolors -b)
fi

# Completion styling
zstyle ':completion:::::' completer _expand _complete _ignored _approximate
# zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -T -L=3 --color=always $realpath'
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
# zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
# custom fzf flags
# NOTE: fzf-tab does not follow FZF_DEFAULT_OPTS
zstyle ':fzf-tab:*' fzf-flags --height ~40% --color=fg:1,fg+:2

# Change cursor shape to beam
echo -ne '\e[5 q'

bindkey -e
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
[[ $(command -v nvim) ]] && export EDITOR=nvim

# needed specifically for Lazygit and more generically this makes configs more Linux compatible
export XDG_CONFIG_HOME="$HOME/.config"
# load custom aliases and functions


# dotfiles management
# git init --bare $HOME/dotfiles
# alias dconf='/usr/bin/git --git-dir=$HOME/dotfiles/ --work-tree=$HOME'
# dconf config --local status.showUntrackedFiles no
# echo "alias dconf='/usr/bin/git --git-dir=$HOME/dotfiles/ --work-tree=$HOME'" >> $HOME/.bashrc
alias dconf='/usr/bin/git --git-dir=/Users/rbhanot/dotfiles/ --work-tree=$HOME'
# load tools
source ~/.temporal.zsh
source <(fzf --zsh)
eval "$(direnv hook zsh)"
eval "$(zoxide init zsh)"
alias zi=__zoxide_zi


[ -f "$HOME/fzf_config.zsh" ] && source "$HOME/"fzf_config.zsh
[ -f "$HOME/custom_config.zsh" ] && source "$HOME/custom_config.zsh"
export PATH="$PATH:/Users/rbhanot/.local/bin:/Users/Shared/DBngin/mysql/8.0.19/bin"
export VOLTA_HOME="$HOME/.volta"
export PATH="$PATH:$HOME/.cargo/bin:$VOLTA_HOME/bin:$HOME/.pixi/bin"

# added a comment

