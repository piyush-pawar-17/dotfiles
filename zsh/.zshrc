export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

[[ -r ${ZDOTDIR:-$HOME}/aliases.zsh ]] && source ${ZDOTDIR:-$HOME}/aliases.zsh
[[ -r ${ZDOTDIR:-$HOME}/history.zsh ]] && source ${ZDOTDIR:-$HOME}/history.zsh

# Autocomplete
zstyle :compinstall filename '/home/piyush/.zshrc'

autoload -Uz compinit
compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' # Case insensitive tab completion
zstyle ':completion:*' list-colors "${(s.:.)--color=auto}"                        # Colored completion (different colors for dirs/files/etc)
zmodload zsh/complist
compinit
_comp_options+=(globdots)

# Plugins
source "${ZDOTDIR}/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "${ZDOTDIR}/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"

set -o ignoreeof

bindkey -v
export KEYTIMEOUT=1

bindkey '^R' history-incremental-search-backward
bindkey -v '^?' backward-delete-char
bindkey '^e' autosuggest-accept
bindkey '^u' autosuggest-toggle
bindkey -s '^f' "tmux-sessionizer\n"

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
    zle -K viins                # Initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q'               # Use beam shape cursor on startup.
precmd() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

# Starship
eval "$(starship init zsh)"

# End of lines added by compinstall
fpath+=${ZDOTDIR:-~}/.zsh_functions

# Exports
export PATH="$PATH:/opt/nvim/"
export PATH="$PATH:$HOME/.local/bin/"
export PATH="$PATH:/usr/local/go/bin"
export VISUAL=nvim
export EDITOR=nvim
export MANPAGER="nvim +Man!"

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

