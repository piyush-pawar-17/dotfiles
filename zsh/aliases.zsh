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
alias gbdf="git branch | fzf -m | xargs git branch -D"
alias gcof="git branch | fzf | xargs git checkout"
alias glc='git pull origin $(git branch --show-current)'
alias glo="git log --oneline --pretty=format:'%C(bold yellow)%h%C(reset)%C(reset)%C(auto)%d%C(reset) - %C(white)%s%C(reset) %C(dim white)- %an (%ar)'"
alias gsp='git reflog | grep ".*checkout: moving from.*to.*$(git branch --show-current)" | tail -n1 | sed "s/.*checkout: moving from \(.*\) to.*/\1/"'
alias gss="git status -s"
