# Dotfiles

Personal configuration for Linux, WSL, and Windows. Linux and WSL
configuration is linked into `~/.config` with [GNU Stow](https://www.gnu.org/software/stow/).

## Setup Guides

- [Arch Linux](docs/arch.md): Hyprland desktop, terminal tools, Waybar, and Google Calendar
- [Ubuntu WSL](docs/ubuntu-wsl.md): Terminal, editor, shell, and tmux setup
- [Windows](docs/windows.md): GlazeWM tiling and Zebar status bar setup

## Repository Layout

- `hypr/`: Hyprland Lua configuration
- `waybar/`: Waybar modules, styles, workspace watcher, and calendar overrides
- `zsh/`, `tmux/`, `nvim/`: Shell, terminal multiplexer, and Neovim configuration
- `windows/`: GlazeWM and Zebar configuration

Each guide explains which files need machine-specific changes before use.
