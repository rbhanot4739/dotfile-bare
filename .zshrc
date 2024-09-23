if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# bootstrap zinit
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

if [[ -f "/opt/homebrew/bin/brew" ]] then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# setup prompt
zinit ice depth=1; zinit light romkatv/powerlevel10k

zinit light zdharma-continuum/fast-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-history-substring-search

zinit ice as"completion"
zinit snippet $HOME/_rg

autoload -Uz compinit && compinit

zinit light Aloxaf/fzf-tab
# Enable colors
autoload -U colors && colors

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# History
HISTSIZE=10000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase

# Append history to the history file, rather than overwriting it
setopt append_history


setopt hist_ignore_space # Ignore commands that start with a space in the history
setopt hist_ignore_all_dups # remove older duplicate entries from history
setopt share_history # share history between different instances of the shell
setopt hist_reduce_blanks # remove blanks from history items
setopt inc_append_history # save history entries as soon as they are entered
setopt hist_save_no_dups # Do not save duplicate commands in the history
setopt hist_find_no_dups # Do not display duplicate commands when searching the history

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -T -L=3 --color=always $realpath'
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
# zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup

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
export EDITOR=nvim

# needed specifically for Lazygit and more generically this makes configs more Linux compatible
export XDG_CONFIG_HOME="$HOME/.config"
# load custom aliases and functions
[ -f "$HOME/custom_config.zsh" ] && source "$HOME/custom_config.zsh"


# dotfiles management
# git init --bare $HOME/dotfiles
# alias dconf='/usr/bin/git --git-dir=$HOME/dotfiles/ --work-tree=$HOME'
# dconf config --local status.showUntrackedFiles no
# echo "alias dconf='/usr/bin/git --git-dir=$HOME/dotfiles/ --work-tree=$HOME'" >> $HOME/.bashrc
alias dconf='/usr/bin/git --git-dir=/Users/rbhanot/dotfiles/ --work-tree=$HOME'

# load tools
source ~/.temporal.zsh
source <(fzf --zsh)
# eval "$(fasd --init auto)"
eval "$(direnv hook zsh)"
eval "$(zoxide init zsh)"
alias zi=__zoxide_zi

export PATH="$PATH:/Users/rbhanot/.local/bin:/Users/Shared/DBngin/mysql/8.0.19/bin"
