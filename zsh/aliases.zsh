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
alias gc="git commit"
alias gcf="git branch | fzf | xargs git checkout"
alias gco="git checkout"
alias gcp="git cherry-pick"
alias gd="git diff"
alias gf="git fetch --prune"
alias gg="git log --graph --abbrev-commit --date=relative --branches --all --pretty=format:'%C(bold red)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)'"
alias gl="git pull"
alias glc='git pull origin $(git branch --show-current)'
alias gp="git push"
alias gpc='git push origin $(git branch --show-current)'
alias gr="git rebase"
alias gs="git status"
alias gsp='git reflog | grep ".*checkout: moving from.*to.*$(git branch --show-current)" | tail -n1 | sed "s/.*checkout: moving from \(.*\) to.*/\1/"'
alias gss="git status -s"
