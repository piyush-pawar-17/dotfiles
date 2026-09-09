#!/usr/bin/env bash
set -euo pipefail

if (( EUID != 0 )); then
    printf '%s\n' 'Run this installer with sudo.' >&2
    exit 1
fi

login_user=${SUDO_USER:?Run this installer from your regular user account with sudo.}
root_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
build_dir=$(mktemp -d /tmp/regreet-catppuccin.XXXXXX)

if ! sudo -u "$login_user" cargo --version >/dev/null || ! sudo -u "$login_user" rustc --version >/dev/null; then
    printf '%s\n' 'Install Rust with rustup before running this installer.' >&2
    exit 1
fi

pacman -S --needed --noconfirm base-devel greetd greetd-regreet
chown "$login_user:$login_user" "$build_dir"
sudo -u "$login_user" git clone --depth 1 --branch 0.5.0 https://github.com/rharish101/ReGreet.git "$build_dir"
sudo -u "$login_user" git -C "$build_dir" apply "$root_dir/greetd/regreet-layout.patch"
sudo -u "$login_user" cargo build --release --manifest-path "$build_dir/Cargo.toml"
install -m 0755 "$build_dir/target/release/regreet" /usr/local/bin/regreet
install -d -m 0755 /etc/greetd /usr/share/backgrounds
install -m 0644 "$root_dir/greetd/config.toml" /etc/greetd/config.toml
install -m 0644 "$root_dir/greetd/hyprland.lua" /etc/greetd/hyprland.lua
install -m 0644 "$root_dir/greetd/regreet.toml" /etc/greetd/regreet.toml
install -m 0644 "$root_dir/greetd/regreet.css" /etc/greetd/regreet.css
install -m 0644 "$root_dir/assets/lofi-cat.png" /usr/share/backgrounds/lofi-cat.png

# ReGreet uses this cache to select the regular user and Hyprland initially.
install -d -m 0755 -o greeter -g greeter /var/lib/regreet
printf 'last_user = "%s"\n\n[user_to_last_sess]\n"%s" = "Hyprland"\n' "$login_user" "$login_user" > /var/lib/regreet/state.toml
chown greeter:greeter /var/lib/regreet/state.toml
chmod 0644 /var/lib/regreet/state.toml

systemctl enable greetd.service
