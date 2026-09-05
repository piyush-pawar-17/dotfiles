# Dotfiles

The dot files are symlinked with [Stow](https://www.gnu.org/software/stow/)

## Installing Arch

If installing arch in a new machine follow these videos

- [Install Arch](https://www.youtube.com/watch?v=TS1ghG3c3xI)
- [Setup Hyprland](https://www.youtube.com/watch?v=PEgDssV0nW0)
- [Minimal status bar (Optional)](https://www.youtube.com/watch?v=T5Itsza4PhE)

## Setup

For Arch, install `yay`

```sh
sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay-bin.git && cd yay-bin && makepkg -si
```

### Zsh

For Arch

```sh
yay -S zsh
chsh -s /usr/bin/zsh # Make zsh as default shell
```

For Ubuntu

```sh
sudo apt install zsh
chsh -s $(which zsh) # Make zsh as default shell
```

> Restart to see the effects

- Update `zshenv` to point to `~/.config/zsh`

```sh
sudo vim /etc/zsh/zshenv
```

```bash
if [[ -z "$XDG_CONFIG_HOME" ]]
then
        export XDG_CONFIG_HOME="$HOME/.config"
fi

if [[ -d "$XDG_CONFIG_HOME/zsh" ]]
then
        export ZDOTDIR="$XDG_CONFIG_HOME/zsh/"
fi
```

### Setup zsh

```sh
sudo apt install zsh
chsh -s $(which zsh) # Make zsh as default shell
```

- Update `zshenv` to point to `~/.config/zsh`

```sh
sudo vim /etc/zsh/zshenv
```

```bash
if [[ -z "$XDG_CONFIG_HOME" ]]
then
        export XDG_CONFIG_HOME="$HOME/.config"
fi

if [[ -d "$XDG_CONFIG_HOME/zsh" ]]
then
        export ZDOTDIR="$XDG_CONFIG_HOME/zsh/"
fi
```

### Pre-req packages

- Install [Node.js](https://nodejs.org/en/download) and [Go](https://go.dev/doc/install)

For Arch

```sh
sudo pacman -Syu
yay -S base-devel ripgrep unzip git xclip bat eza fuse2 fd git-delta
yay -S wslu # Only when installing Arch in WSL
npm install -g hunkdiff # Better git diffs
curl -fsSL https://get.pnpm.io/install.sh | sh -
curl -fsSL https://opencode.ai/install | bash
ln -s $(which fdfind) ~/.local/bin/fd # (for snacks.nvim search)
```

For Ubuntu

```sh
sudo apt update
sudo apt install make gcc ripgrep unzip git xclip bat eza libfuse2 fd-find git-delta
sudo apt install wslu # Only when installing Ubuntu in WSL
npm install -g hunkdiff # Better git diffs
curl -fsSL https://get.pnpm.io/install.sh | sh -
curl -fsSL https://opencode.ai/install | bash
ln -s $(which fdfind) ~/.local/bin/fd # (for snacks.nvim search)
```

### Git

Copy `.gitconfig` file to `~/.gitconfig`

```sh
npm install -g prettier
```

### fzf

For Arch

```sh
yay -S fzf
```

For Ubuntu

```sh
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
```

### Nerd font

For Arch

```sh
yay -S otf-geist-mono-nerd
fc-cache -fv
```

For Ubuntu

```sh
wget -P ~/.local/share/fonts https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/GeistMono.zip \
&& cd ~/.local/share/fonts \
&& unzip GeistMono.zip \
&& rm GeistMono.zip \
&& fc-cache -fv
```

### Starship

```sh
curl -sS https://starship.rs/install.sh | sh
```

### NeoVim

For Arch

```sh
yay -S neovim
```

For Ubuntu

```sh
curl -LO https://github.com/neovim/neovim/releases/download/v0.11.0/nvim-linux-x86_64.appimage
chmod u+x nvim-linux-x86_64.appimage
./nvim-linux-x86_64.appimage
sudo mkdir -p /opt/nvim
sudo mv nvim-linux-x86_64.appimage /opt/nvim/nvim
```

### tmux

For Arch

```sh
yay -S tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

For Ubuntu

```sh
sudo apt install tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

#### tmux-sessionizer

- Copy the `tmux-sessionizer` script to `~/.local/bin/tmux-sessionizer`

- Update permissions for the script

```sh
chmod +x ~/.local/bin/tmux-sessionizer
```

## Create symlinks

For Arch

```sh
yay -S stow
stow .
```

For Ubuntu

```sh
sudo apt-get install -y stow
stow .
```

## For windows

### Tiling manager

- GlazeWM and Zebar

```sh
winget install GlazeWM
```

- Copy the Glaze and Zebar config into [config folder](https://github.com/glzr-io/glazewm?tab=readme-ov-file#config-documentation). Usually in `C:\Users\<username>\.glzr\(glazewm|zebar)`

- Go to Zebar folder and install dependencies (Note: Use the windows version of `pnpm`)

```sh
pnpm install
```

- Build Zebar UI

```sh
pnpm build
```
