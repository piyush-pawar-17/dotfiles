#!/bin/sh
set -eu

version=0.12.6
tag=v$version
source_dir="${XDG_CACHE_HOME:-$HOME/.cache}/swaync-$version"
dotfiles_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
set -- \
    "$dotfiles_dir/swaync/patches/0001-smaller-empty-icon-and-pointer-cursors.patch" \
    "$dotfiles_dir/swaync/patches/0002-truncate-notification-bodies-and-remove-italics.patch"

if [ ! -d "$source_dir/.git" ]; then
    git clone --branch "$tag" --depth 1 https://github.com/ErikReider/SwayNotificationCenter.git "$source_dir"
elif ! git -C "$source_dir" rev-parse --verify HEAD >/dev/null 2>&1; then
    git -C "$source_dir" fetch --depth 1 origin "refs/tags/$tag"
    git -C "$source_dir" checkout --detach FETCH_HEAD
fi

for patch; do
    if git -C "$source_dir" apply --reverse --check "$patch" >/dev/null 2>&1; then
        git -C "$source_dir" apply --reverse "$patch"
    fi
done

for patch; do
    git -C "$source_dir" apply --check "$patch"
    git -C "$source_dir" apply "$patch"
done

meson setup "$source_dir/build" "$source_dir" --wipe --prefix="$HOME/.local" \
    -Dsystemd-service=false -Dman-pages=false
meson compile -C "$source_dir/build"
meson install -C "$source_dir/build"
