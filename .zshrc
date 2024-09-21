# zmodload zsh/zprof

# Speeds up load time
DISABLE_UPDATE_PROMPT=false

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="false"

# History Settings
HISTFILE=$HOME/.zsh/history
HISTSIZE=10000
SAVEHIST=$HISTSIZE

# Ensure the history file exists and is writable
touch $HISTFILE
chmod 600 $HISTFILE

setopt hist_ignore_all_dups # remove older duplicate entries from history
setopt hist_reduce_blanks # remove blanks from history items
setopt share_history # share history between different instances of the shell
setopt inc_append_history # save history entries as soon as they are entered

up-line-or-history-reread() {
  [[ -z $BUFFER ]] && fc -R $HISTFILE
  zle up-line-or-history
}
zle -N up-line-or-history-reread
bindkey '^[[A' up-line-or-history-reread

setopt auto_cd # cd by typing directory name if its not a command
setopt +o nomatch

# Enable colors
autoload -U colors && colors


setopt auto_list # automatically list choices on ambiguous completion
setopt auto_menu # automatically use menu completion
setopt always_to_end # move cursor to end if word had one match

# Auto complete settings
autoload -U compinit; compinit

zstyle ':completion:*' menu select # select completions with arrow keys
zstyle ':completion:*' group-name '' # group results by category
zstyle ':completion:::::' completer _expand _complete _ignored _approximate # enable approximate matches for completion
## Auto complete with case insenstivity
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zmodload zsh/complist
_comp_options+=(globdots)		# Include hidden files.

# # disable sort when completing `git checkout`
# zstyle ':completion:*:git-checkout:*' sort false
# # set descriptions format to enable group support
# # NOTE: don't use escape sequences here, fzf-tab will ignore them
# zstyle ':completion:*:descriptions' format '[%d]'
# # set list-colors to enable filename colorizing
# zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# # force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
# zstyle ':completion:*' menu no
# # preview directory's content with eza when completing cd
# zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
# # switch group using `<` and `>`
# zstyle ':fzf-tab:*' switch-group '<' '>'

source $HOME/fzf-tab/fzf-tab.plugin.zsh

echo -ne '\e[5 q'  # Use beam shape cursor on startup.

local PLUGIN_DIR="$HOME/.zsh/plugins/"
local PLUGINS=(zsh-syntax-highlighting zsh-autosuggestions)
for plugin in $PLUGINS
do
  local plugin_path="${PLUGIN_DIR}${plugin}"
if [[ ! -d "$plugin_path" ]]; then
  git clone https://github.com/zsh-users/$plugin  "$plugin_path" 2>/dev/null
else
  # echo "$plugin is already installed..."
fi
done


# Load plugins
for plugin in ~/.zsh/plugins/*/*.plugin.zsh; do
  source $plugin
done
ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=244"

autoload -U promptinit; promptinit
# eval "$(starship init zsh)"

umask 0002
export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
# export TERM=xterm
typeset -U PATH
export PATH
export EDITOR=nvim
# Enable fasd
eval "$(fasd --init auto)"

# vi mode
bindkey -v
# export KEYTIMEOUT=1

# Change cursor shape for different vi modes.
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
    [[ $1 = 'block' ]]; then
      echo -ne '\e[1 q'
    elif [[ ${KEYMAP} == main ]] ||
      [[ ${KEYMAP} == viins ]] ||
      [[ ${KEYMAP} = '' ]] ||
      [[ $1 = 'beam' ]]; then
          echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select
zle-line-init() {
  zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
  echo -ne "\e[5 q"
}
zle -N zle-line-init
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.


bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Ctrl + U – delete from the cursor to the start of the line.
# Ctrl + K – delete from the cursor to the end of the line.
# Ctrl + W – delete from the cursor to the start of the preceding word.
# Alt + D – delete from the cursor to the end of the next word.


# zprof

export DB_URI=mysql+pymysql://deadpool_user:Password@127.0.0.1/deadpool_db

# Created by `pipx` on 2022-01-22 18:07:45
export GOPATH="/Users/rbhanot/.go"
export GOBIN=$GOPATH/bin
# export GUNICORN_CMD_ARGS="--bind=0.0.0.0:8889 --workers=4 --keyfile /export/content/lid/apps/deadpool-api/i001/var/identity.key --certfile /export/content/lid/apps/deadpool-api/i001/var/identity.cert --ca-certs /etc/riddler/ca-bundle.crt  --cert-reqs 1 --reload"
export VOLTA_HOME="$HOME/.volta"
export PATH="/opt/homebrew/bin:$PATH:/Users/rbhanot/.local/bin:/Users/Shared/DBngin/mysql/8.0.19/bin:$VOLTA_HOME/bin:$GOBIN:$PATH"
# Add /export/apps/python/*/bin to PATH
#for dir in /export/apps/python/*/bin; do
#  path+=("$dir")
#done
source ~/.temporal.zsh

# needed specifically for Lazygit and more generically this makes configs more Linux compatible
export XDG_CONFIG_HOME="$HOME/.config"
[ -f "$HOME/custom_config.zsh" ] && source "$HOME/custom_config.zsh"
source <(fzf --zsh)
# zprof

source ~/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
eval "$(direnv hook zsh)"

# dotfiles management
# git init --bare $HOME/dotfiles
# alias dconf='/usr/bin/git --git-dir=$HOME/dotfiles/ --work-tree=$HOME'
# dconf config --local status.showUntrackedFiles no
# echo "alias dconf='/usr/bin/git --git-dir=$HOME/dotfiles/ --work-tree=$HOME'" >> $HOME/.bashrc

alias dconf='/usr/bin/git --git-dir=/Users/rbhanot/dotfiles/ --work-tree=/Users/rbhanot'
