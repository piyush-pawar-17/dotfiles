alias v="nvim"
alias bat=batcat
alias lg=lazygit
alias t=tmux
alias install="sudo apt-get install"

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
alias gaa="git add -A"
alias gb="git branch"
alias gba="git branch -a"
alias gbd="git branch | fzf -m | xargs git branch -D"
alias gc="git commit"
alias gcf="git branch | fzf | xargs git checkout"
alias gco="git checkout"
alias gcp="git cherry-pick"
alias gd="git diff"
alias gf="git fetch --prune"
alias gg="git log --graph --abbrev-commit --date=relative --branches --pretty=format:'%C(bold yellow)%h%C(reset)%C(reset)%C(auto)%d%C(reset) - %C(white)%s%C(reset) %C(dim white)- %an (%ar)'"
alias gl="git pull"
alias glc='git pull origin $(git branch --show-current)'
alias glo="git log --oneline"
alias gp="git push"
alias gpc='git push origin $(git branch --show-current)'
alias grb="git rebase"
alias grf="git reflog"
alias grs="git reset"
alias gs="git status"
alias gsp='git reflog | grep ".*checkout: moving from.*to.*$(git branch --show-current)" | tail -n1 | sed "s/.*checkout: moving from \(.*\) to.*/\1/"'
alias gss="git status -s"
