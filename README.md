# Dotfiles

Personal configuration for Linux, WSL, Windows, and macOS. On Linux and WSL,
configuration is linked into `~/.config`.

## Setup Guides

- [Arch Linux (Omarchy)](docs/arch.md): Terminal tools, shell, editor, and
  monitor settings on top of Omarchy
- [Ubuntu WSL](docs/ubuntu-wsl.md): Terminal, editor, shell, and tmux setup
- [Windows](docs/windows.md): GlazeWM tiling and Zebar status bar setup

## Repository Layout

- `zsh/`, `tmux/`, `nvim/`: Shell, terminal multiplexer, and Neovim configuration
- `starship.toml`, `tmux-sessionizer`, `.gitconfig`: Prompt, tmux project
  switcher, and Git configuration with delta
- `ghostty/`, `alacritty/`: Terminal configuration
- `bat/`, `fastfetch/`, `hunk/`: CLI tool settings
- `hypr/`: Omarchy Hyprland overrides (monitors, input, bindings, look and feel)
- `windows/`: GlazeWM and Zebar configuration
- `mac/`: AeroSpace configuration

Each guide explains which files need machine-specific changes before use.
