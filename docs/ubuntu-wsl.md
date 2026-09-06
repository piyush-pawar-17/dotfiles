# Ubuntu WSL Setup

This guide configures the terminal-focused parts of this repository on Ubuntu
or WSL. The dotfiles are managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Clone the Repository

Clone the repository into the directory used by the tmux sessionizer:

```sh
mkdir -p ~/code
git clone https://github.com/piyush-pawar-17/dotfiles.git ~/code/dotfiles
cd ~/code/dotfiles
```

## Zsh

Install Zsh and make it the login shell:

```sh
sudo apt install zsh
chsh -s $(which zsh)
```

Restart the shell or WSL session after changing the login shell.

Configure Zsh to load the dotfiles from `~/.config/zsh`:

```sh
sudo vim /etc/zsh/zshenv
```

Add the following content:

```sh
if [[ -z "$XDG_CONFIG_HOME" ]]
then
        export XDG_CONFIG_HOME="$HOME/.config"
fi

if [[ -d "$XDG_CONFIG_HOME/zsh" ]]
then
        export ZDOTDIR="$XDG_CONFIG_HOME/zsh/"
fi
```

## Prerequisites

Install [Node.js](https://nodejs.org/en/download) and [Go](https://go.dev/doc/install),
then install the command-line dependencies:

```sh
sudo apt update
sudo apt install make gcc ripgrep unzip git xclip bat eza libfuse2 fd-find git-delta
sudo apt install wslu # Only when running Ubuntu in WSL
npm install -g hunkdiff # Better git diffs
curl -fsSL https://get.pnpm.io/install.sh | sh -
curl -fsSL https://opencode.ai/install | bash
mkdir -p ~/.local/bin
ln -s $(which fdfind) ~/.local/bin/fd # For Snacks.nvim search
```

## Git

Copy the repository `.gitconfig` file to `~/.gitconfig`, then install Prettier:

```sh
cp ~/code/dotfiles/.gitconfig ~/.gitconfig
npm install -g prettier
```

## Fzf

```sh
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
```

## Nerd Font

Install Geist Mono Nerd Font for terminal icons and Waybar glyphs:

```sh
wget -P ~/.local/share/fonts https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/GeistMono.zip \
&& cd ~/.local/share/fonts \
&& unzip GeistMono.zip \
&& rm GeistMono.zip \
&& fc-cache -fv
```

## Starship

```sh
curl -sS https://starship.rs/install.sh | sh
```

## Neovim

```sh
curl -LO https://github.com/neovim/neovim/releases/download/v0.11.0/nvim-linux-x86_64.appimage
chmod u+x nvim-linux-x86_64.appimage
./nvim-linux-x86_64.appimage
sudo mkdir -p /opt/nvim
sudo mv nvim-linux-x86_64.appimage /opt/nvim/nvim
```

## Tmux

```sh
sudo apt install tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

### Tmux Sessionizer

Copy `tmux-sessionizer` to `~/.local/bin/tmux-sessionizer`, then make it executable:

```sh
mkdir -p ~/.local/bin
cp ~/code/dotfiles/tmux-sessionizer ~/.local/bin/tmux-sessionizer
chmod +x ~/.local/bin/tmux-sessionizer
```

The sessionizer opens projects from `~/code`, which is created when cloning the
repository.

## Create Symlinks

Install Stow and apply the dotfiles from the repository root. The repository
`.stowrc` targets `~/.config` and excludes documentation and non-Linux configs.
Preview links first so existing configuration can be backed up or removed:

```sh
sudo apt-get install -y stow
cd ~/code/dotfiles
stow -n .
stow .
```

Re-run `stow .` after pulling configuration updates.
