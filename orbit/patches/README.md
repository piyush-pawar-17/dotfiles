# Orbit Source Patch

`remove-branding.patch` contains the local Orbit source fixes used when building
the user-local binary. This directory is excluded from Stow.

```sh
git clone https://github.com/LifeOfATitan/orbit.git /tmp/orbit
git -C /tmp/orbit apply ~/code/dotfiles/orbit/patches/remove-branding.patch
cargo build --release --manifest-path /tmp/orbit/Cargo.toml
install -Dm755 /tmp/orbit/target/release/orbit ~/.local/bin/orbit
systemctl --user restart orbit
```
