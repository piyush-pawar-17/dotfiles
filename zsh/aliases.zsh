alias v="nvim"
alias bat=batcat
alias lg=lazygit
alias t=tmux

# Listing files
alias ls="eza -F --color=always --group-directories-first"
alias ll="eza -l -F --color=always --group-directories-first"
alias lt="eza --tree --level=2 --long --icons --git"

# Dirs
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

function take {
	mkdir -p $1
	cd $1
}

# Git
alias g="git"
alias ga="git add"
alias gb="git branch"
alias gbd="git branch | fzf -m | xargs git branch -D"
alias gc="git commit -m"
alias gcb="git checkout -b "
alias gco="git branch | fzf | xargs git checkout"
alias gcp="git cherry-pick"
alias gd="git diff"
alias gf="git fetch --prune"
alias gl="git pull"
alias glc='git pull origin $(git branch --show-current)'
alias glg='git log --graph --decorate --pretty="oneline"'
alias gp="git push"
alias gpc='git push origin $(git branch --show-current)'
alias gs="git status"
alias gss="git status -s"
