# Arch Linux Setup

This guide sets up Arch Linux with the tools and desktop configuration in this
repository. It assumes a working Arch installation with networking and a user
account configured for `sudo`.

## Installation References

Use these videos for the base system and desktop installation:

- [Install Arch](https://www.youtube.com/watch?v=TS1ghG3c3xI)
- [Setup Hyprland](https://www.youtube.com/watch?v=PEgDssV0nW0)
- [Minimal status bar (Optional)](https://www.youtube.com/watch?v=T5Itsza4PhE)

## Install Yay

Update the system, install the build dependencies, then build the `yay` AUR
helper:

```sh
sudo pacman -Syu
sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
cd /tmp/yay-bin
makepkg -si
```

Return to the dotfiles repository after the build completes.

## Install Packages

Install the terminal tooling and development dependencies:

```sh
sudo pacman -S --needed \
  bat eza fd fzf git-delta go nodejs npm ripgrep stow tmux unzip \
  wl-clipboard xclip

npm install -g hunkdiff prettier
curl -fsSL https://get.pnpm.io/install.sh | sh -
curl -fsSL https://opencode.ai/install | bash
```

Install the desktop packages used by the Hyprland and Waybar configuration:

```sh
yay -S --needed \
  bibata-cursor-theme bluez bluez-utils brightnessctl hyprland hyprpaper hyprpolkitagent \
  networkmanager \
  hyprshot playerctl pipewire qt6ct rofi thunar waybar wireplumber \
  xdg-desktop-portal-gtk xdg-desktop-portal-hyprland

yay -S --needed ghostty google-chrome orbit-wifi waybar-ycal
```

The configuration uses `wpctl` for volume controls. It is provided by
`pipewire` and needs `wireplumber` running as the user session manager.

```sh
systemctl --user enable --now pipewire pipewire-pulse wireplumber
```

Install the remaining configured applications and font:

```sh
yay -S --needed neovim otf-geist-mono-nerd starship
fc-cache -fv
```

`fontconfig/fonts.conf` enables antialiasing and light hinting for Geist Mono
Nerd Font after the dotfiles are linked.

## Clone the Repository

Clone the repository into the directory used by the tmux sessionizer:

```sh
mkdir -p ~/code
git clone https://github.com/piyush-pawar-17/dotfiles.git ~/code/dotfiles
cd ~/code/dotfiles
```

## Link Dotfiles with Stow

The repository `.stowrc` targets `~/.config` and excludes non-configuration
directories such as `docs/`, `windows/`, `mac/`, and `systemd/`. Preview the
links first, resolve any conflicts with existing files, then create the
symlinks:

```sh
stow -n .
stow .
```

Stow links the shell, terminal, editor, Hyprland, Waybar, and fontconfig
configuration. Re-run `stow .` after pulling future changes.

Copy the Git configuration separately because it belongs at the home-directory
root rather than under `~/.config`:

```sh
cp .gitconfig ~/.gitconfig
```

Install the tmux sessionizer outside the Stow target and ensure its directory
is on `PATH`, then install the tmux plugin manager:

```sh
mkdir -p ~/.local/bin
cp tmux-sessionizer ~/.local/bin/tmux-sessionizer
chmod +x ~/.local/bin/tmux-sessionizer
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

The sessionizer opens projects under `~/code`. Arch provides `fd` under that
name, so no `fdfind` compatibility symlink is needed.

## Configure Zsh

Install Zsh and make it the login shell:

```sh
yay -S --needed zsh
chsh -s /usr/bin/zsh
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

Log out and back in, or start a new Zsh session, after changing the login
shell. The linked configuration loads Starship, fzf, pnpm, NVM when installed,
and the bundled Zsh plugins.

## Configure Hyprland

The linked Hyprland configuration is at `~/.config/hypr/hyprland.lua` and
starts Waybar, `hyprpolkitagent`, and the Bibata cursor.

Before starting Hyprland, update the monitor-specific settings for this
machine:

- Replace `eDP-1` and `HDMI-A-1` in `hypr/hyprland.lua` with the output names
  reported by `hyprctl monitors`
- Adjust the monitor positions, scale, `cursor.default_monitor`, workspace 1
  rule, and monitor workspace keybindings to match the display layout
- Update `AQ_DRM_DEVICES` only when the GPU device ordering differs from the
  configured `/dev/dri/card1:/dev/dri/card0`

The configured keybindings expect Ghostty, Thunar, Google Chrome, Rofi,
Hyprshot, PipeWire, Brightnessctl, and Playerctl to be installed.

## Configure Waybar Status Modules

The custom Wi-Fi and Bluetooth modules remain available while their radios are
off, so either can open the matching Orbit tab. The center calendar remains the
time and date control.

Orbit is the unified Wayland manager for Wi-Fi, Bluetooth, VPN, and Ethernet.
Link its user service, then enable it after installing `orbit-wifi`:

```sh
mkdir -p ~/.config/systemd/user
ln -sfn ~/code/dotfiles/systemd/user/orbit.service ~/.config/systemd/user/orbit.service
systemctl --user daemon-reload
systemctl --user enable --now orbit
```

If AUR installation is unavailable, build Orbit with the Rust toolchain and
install it to the user-local bin directory instead. The local patch is kept
outside Stow at `orbit/patches/`; its companion README explains the patch.

```sh
git clone https://github.com/LifeOfATitan/orbit.git /tmp/orbit
git -C /tmp/orbit apply ~/code/dotfiles/orbit/patches/remove-branding.patch
cargo build --release --manifest-path /tmp/orbit/Cargo.toml
install -Dm755 /tmp/orbit/target/release/orbit ~/.local/bin/orbit
systemctl --user restart orbit
```

The Orbit service uses the user-local binary when present and otherwise uses
the AUR-installed `/usr/bin/orbit` binary.

The Stow-managed `orbit/` directory provides Orbit's configuration and theme
files. Apply its configuration after pulling updates with:

```sh
stow .
orbit reload-config
orbit reload-theme
```

## Configure Waybar Calendar

Waybar uses [waybar-ycal](https://github.com/yagybaba/waybar-ycal) for a Google
Calendar, Tasks, and contact birthday popup. The repository provides local
popup and status-label overrides, so link them after Stow has created
`~/.config/waybar/ycal`:

```sh
mkdir -p ~/.config/waybar-ycal
ln -sfn ~/.config/waybar/ycal/bar.py ~/.config/waybar-ycal/bar.py
ln -sfn ~/.config/waybar/ycal/popup.py ~/.config/waybar-ycal/popup.py
```

Enable the Google Calendar API, Google Tasks API, and People API in a Google
Cloud project. Create a Desktop OAuth client and save its downloaded credentials
as `~/.config/waybar-ycal/credentials.json`. Do not add this file or the token
cache to the repository.

Link the local ycal service override, then enable the service:

```sh
mkdir -p ~/.config/systemd/user/waybar-ycal.service.d
ln -sfn ~/code/dotfiles/systemd/user/waybar-ycal.service.d/override.conf \
  ~/.config/systemd/user/waybar-ycal.service.d/override.conf
systemctl --user daemon-reload
systemctl --user enable --now waybar-ycal.service
```

Click the calendar in Waybar to complete the local OAuth flow. The token is
stored at `~/.cache/waybar-ycal/token.json`.

## Start the Session

Start Hyprland from the display manager or TTY. The configuration starts
Waybar automatically. After changing Waybar configuration, restart it with:

```sh
pkill -x waybar
waybar &
```

After changing the calendar popup, restart its user service:

```sh
systemctl --user restart waybar-ycal.service
```
