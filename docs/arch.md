# Arch Linux (Omarchy) Setup

This guide layers the terminal and editor configuration in this repository on
top of an [Omarchy](https://omarchy.org/) installation. Omarchy provides the
Hyprland desktop, bar, notifications, launcher, lock screen, and theming, so
only selected directories from this repository are linked.

## Install Packages

Install the terminal tooling and development dependencies:

```sh
omarchy pkg add \
  bat eza fastfetch fd fzf git-delta go neovim nodejs npm otf-geist-mono-nerd \
  ripgrep starship stow tmux unzip wl-clipboard xclip zsh
fc-cache -f

npm install -g prettier
curl -fsSL https://get.pnpm.io/install.sh | sh -
curl -fsSL https://opencode.ai/install | bash
curl -fsSL https://claude.ai/install.sh | bash
```

Omarchy provides `hunk` through mise, which installs it the first time it is
run. On other systems, install it with `npm install -g hunkdiff`.

## Clone the Repository

Clone the repository into the directory used by the tmux sessionizer:

```sh
mkdir -p ~/code
git clone https://github.com/piyush-pawar-17/dotfiles.git ~/code/dotfiles
cd ~/code/dotfiles
```

## Link Dotfiles

Do not run `stow .` on Omarchy. It links the contents of each directory
directly into `~/.config` and would also link `ghostty/` over Omarchy's
configuration. Instead, move any existing configuration aside and link each
directory individually:

```sh
for dir in bat fastfetch hunk hypr nvim tmux zsh; do
  [ -e ~/.config/$dir ] && mv ~/.config/$dir ~/.config/$dir.bak
  ln -s ~/code/dotfiles/$dir ~/.config/$dir
done

mv ~/.config/starship.toml ~/.config/starship.toml.bak
ln -s ~/code/dotfiles/starship.toml ~/.config/starship.toml
ln -s ~/code/dotfiles/.gitconfig ~/.gitconfig
bat cache --build
```

The `.gitconfig` sets delta as the Git pager and is read alongside
Omarchy's `~/.config/git/config`, which keeps the Git user name and email.

Install the tmux sessionizer and the tmux plugin manager:

```sh
mkdir -p ~/.local/bin
cp tmux-sessionizer ~/.local/bin/tmux-sessionizer
chmod +x ~/.local/bin/tmux-sessionizer
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
tmux source-file ~/.config/tmux/tmux.conf
~/.tmux/plugins/tpm/bin/install_plugins
```

The sessionizer opens projects under `~/code`.

## Configure Ghostty

`ghostty/config` holds the font, colors, padding, and keybindings. Copy its
settings into Omarchy's `~/.config/ghostty/config` rather than replacing the
file, so the Omarchy keybindings, cursor, and Hyprland performance settings
are kept.

Ghostty loads `config-file` includes after the main file, so Omarchy's theme
include overrides the background and cursor colors set here. Comment out the
`config-file` line to keep these colors, at the cost of Ghostty no longer
following Omarchy theme changes.

## Configure Zsh

Fetch the Zsh plugins. The repository pins their commits, but has no
`.gitmodules` file, so `git submodule update` does not work:

```sh
cd ~/code/dotfiles/zsh/plugins
rmdir zsh-autosuggestions fast-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions
git -C zsh-autosuggestions checkout 85919cd1ffa7d2d5412f6d3fe437ebdbeeec4fc5
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting
git -C fast-syntax-highlighting checkout 4672ad5dd9ad68a7effc1476d65afb7c584ce2b3
```

Configure the system Zsh environment to load the linked configuration from
`~/.config/zsh`:

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

Make Zsh the login shell, then log out and back in. Terminals and tmux servers
started before the change keep running Bash.

```sh
chsh -s /usr/bin/zsh
```

The linked configuration loads Starship, fzf, mise, pnpm, NVM when installed,
and the Zsh plugins.

## Configure Hyprland

`hypr/` holds Omarchy's user Hyprland files. `hyprland.lua` loads Omarchy's
defaults, then the personal overrides in the other files:

- `monitors.lua`: monitor layout, the cursor's start monitor, and the workspace
  1 rule. Replace `eDP-1` and `HDMI-A-1` with the output names reported by
  `hyprctl monitors`, and adjust the positions and scale for the machine.
- `input.lua`: keyboard layout, key repeat, click-to-focus, and touchpad
  scrolling and gestures
- `bindings.lua`, `looknfeel.lua`, `autostart.lua`: keybinding, appearance,
  and startup overrides

Omarchy commands such as `omarchy refresh hyprland` write through the link
into this repository, so review their changes with `git diff`. The backups
they create (`*.bak.*`) are ignored by Git.

After editing, check for errors:

```sh
hyprctl reload
hyprctl configerrors
```

## Configure Middle-Click Autoscroll

Windows-style middle-click autoscrolling is provided by the
[hypr-autoscroll](https://github.com/estebanhiram/hypr-autoscroll) plugin:
press the middle button and move the pointer away from the activation point to
scroll, with speed and direction following the pointer distance. A short
middle click still behaves normally, and any click or wheel input ends the
scroll.

The hyprpm dependency check also requires `cmake`, so install it first:

```sh
omarchy pkg add cmake
```

Install and enable the plugin, then reload the configuration:

```sh
hyprpm add https://github.com/estebanhiram/hypr-autoscroll
hyprpm enable hypr-autoscroll
hyprctl reload
```

The plugin must be rebuilt after Hyprland updates because plugins are ABI
sensitive. Run `hyprpm update` and reload again.

To load the plugin at login, add `hyprpm reload` to `hypr/autostart.lua` and
allow hyprpm to load plugins in `hypr/hyprland.lua`:

```lua
hl.permission("/usr/(bin|sbin|local/bin)/hyprpm", "plugin", "allow")
```
