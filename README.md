# Dotfiles

The dot files are symlinked with [Stow](https://www.gnu.org/software/stow/)

## Setup

### Pre-req packages

```sh
sudo apt update
sudo apt install make gcc ripgrep unzip git xclip bat eza libfuse2
```

### fzf

```sh
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
```

### Nerd font

```sh
wget -P ~/.local/share/fonts https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip \
&& cd ~/.local/share/fonts \
&& unzip JetBrainsMono.zip \
&& rm JetBrainsMono.zip \
&& fc-cache -fv
```

### zsh

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

### Starship

```sh
curl -sS https://starship.rs/install.sh | sh
```

### NeoVim

```sh
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod u+x nvim.appimage
./nvim.appimage
sudo mkdir -p /opt/nvim
sudo mv nvim.appimage /opt/nvim/nvim
```

### tmux

```sh
sudo apt install tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

#### tmux-sessionizer

- Save the script on `~/.local/bin/tmux-sessionizer`

```sh
#!/usr/bin/env bash

if [[ $# -eq 1 ]]; then
    selected=$1
else
    selected=$(find ~/code -mindepth 1 -maxdepth 1 -type d | fzf)
fi

if [[ -z $selected ]]; then
    exit 0
fi

selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
    tmux new-session -s $selected_name -c $selected
    exit 0
fi

if ! tmux has-session -t=$selected_name 2> /dev/null; then
    tmux new-session -ds $selected_name -c $selected

fi

if [[ -z $TMUX ]]; then
    tmux attach -t $selected_name
else
    tmux switch-client -t $selected_name
fi
```

- Update permissions for the script

```sh
chmod +x ~/.local/bin/tmux-sessionizer
```

## Create symlinks

```sh
sudo apt-get install -y stow
stow --target ~/.config .
```
