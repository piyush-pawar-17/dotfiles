#!/usr/bin/env python3
import subprocess
import sys
import time
from pathlib import Path
from urllib.parse import unquote, urlparse

import gi

gi.require_version("Gtk", "4.0")
from gi.repository import Gdk, Gio, GLib, Gtk

sys.path.insert(0, str(Path.home() / ".local" / "share" / "myui-popups" / "widgets"))

from myui.base_window import AppWindow


CSS = """
window.mpris-popup {
    background-color: #181825;
    border: 1px solid #45475a;
    border-radius: 16px;
}

window.mpris-popup label {
    font-family: "Geist Mono Nerd Font", "Symbols Nerd Font", sans-serif;
}

window.mpris-popup .mpris-art {
    background-color: #313244;
    border-radius: 10px;
}

window.mpris-popup .mpris-art-placeholder {
    color: #cba6f7;
    font-size: 38px;
}

window.mpris-popup .mpris-title {
    color: #cdd6f4;
    font-size: 14px;
    font-weight: 700;
}

window.mpris-popup .mpris-artist,
window.mpris-popup .mpris-player {
    color: #a6adc8;
    font-size: 11px;
}

window.mpris-popup button.mpris-control,
window.mpris-popup button.mpris-close {
    min-width: 48px;
    min-height: 48px;
    padding: 0;
    border: 0;
    border-radius: 10px;
    color: #cdd6f4;
    background-color: #313244;
    font-family: "Geist Mono Nerd Font", "Symbols Nerd Font", sans-serif;
    font-size: 18px;
}

window.mpris-popup button.mpris-control:hover,
window.mpris-popup button.mpris-close:hover {
    color: #cdd6f4;
    background-color: #24243a;
}

window.mpris-popup button.mpris-close {
    min-width: 32px;
    min-height: 32px;
    border-radius: 8px;
    font-size: 16px;
}

window.mpris-popup button.mpris-primary {
    min-width: 48px;
    min-height: 48px;
    border-radius: 24px;
    background-color: #89b4fa;
    font-size: 22px;
}

window.mpris-popup button.mpris-primary label {
    color: #1e1e2e;
}

window.mpris-popup button.mpris-primary:hover {
    background-color: #74a8e8;
}

window.mpris-popup .mpris-time {
    color: #a6adc8;
    font-size: 11px;
}

window.mpris-popup scale trough {
    min-height: 6px;
    background-color: #45475a;
}

window.mpris-popup scale highlight,
window.mpris-popup scale slider {
    background-color: #89b4fa;
}
"""


class MprisPopup(AppWindow):
    def __init__(self, app, **kwargs):
        kwargs.pop("window_tag", None)
        super().__init__(
            app=app,
            title="Media Control",
            width=390,
            close_on_focus_loss=True,
            window_tag="mpris",
        )
        self.add_css_class("mpris-popup")
        self.player = None
        self.syncing_progress = False
        self.seek_timeout = None
        self._suppress_focus_close_until = 0.0
        self._track_signature = None
        self._apply_css()
        self._build_ui()
        self._refresh()
        self.refresh_timer = GLib.timeout_add(1000, self._refresh)
        self.connect("destroy", self._on_destroy)

    def _apply_css(self):
        provider = Gtk.CssProvider()
        provider.load_from_string(CSS)
        Gtk.StyleContext.add_provider_for_display(
            Gdk.Display.get_default(),
            provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION + 1,
        )

    def _build_ui(self):
        self.main_box.set_spacing(14)

        header = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=14)
        art_overlay = Gtk.Overlay()
        art_overlay.set_size_request(76, 76)
        self.art = Gtk.Picture()
        self.art.add_css_class("mpris-art")
        self.art.set_can_shrink(True)
        self.art.set_content_fit(Gtk.ContentFit.COVER)
        art_overlay.set_child(self.art)
        self.art_placeholder = Gtk.Label(label="󰎈")
        self.art_placeholder.add_css_class("mpris-art-placeholder")
        art_overlay.add_overlay(self.art_placeholder)
        header.append(art_overlay)

        metadata = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=3)
        metadata.set_hexpand(True)
        metadata.set_valign(Gtk.Align.CENTER)
        self.title_label = Gtk.Label(label="No media playing", xalign=0)
        self.title_label.add_css_class("mpris-title")
        self.title_label.set_ellipsize(3)
        self.artist_label = Gtk.Label(label="Start playback to control it here", xalign=0)
        self.artist_label.add_css_class("mpris-artist")
        self.artist_label.set_ellipsize(3)
        self.player_label = Gtk.Label(label="MPRIS", xalign=0)
        self.player_label.add_css_class("mpris-player")
        metadata.append(self.title_label)
        metadata.append(self.artist_label)
        metadata.append(self.player_label)
        header.append(metadata)

        close_button = Gtk.Button(label="󰅖")
        close_button.add_css_class("mpris-close")
        close_button.set_size_request(32, 32)
        close_button.set_valign(Gtk.Align.START)
        close_button.set_halign(Gtk.Align.END)
        close_button.connect("clicked", lambda _button: self.close())
        header.append(close_button)
        self.main_box.append(header)

        controls = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        controls.set_halign(Gtk.Align.CENTER)
        self.previous_button = self._control_button("󰒮", "previous")
        self.play_button = self._control_button("󰐊", "play-pause", primary=True)
        self.next_button = self._control_button("󰒭", "next")
        controls.append(self.previous_button)
        controls.append(self.play_button)
        controls.append(self.next_button)
        self.main_box.append(controls)

        progress_row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        self.position_label = Gtk.Label(label="0:00")
        self.position_label.add_css_class("mpris-time")
        self.position_label.set_valign(Gtk.Align.CENTER)
        progress_row.append(self.position_label)
        self.progress_scale = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, 0, 1, 1)
        self.progress_scale.set_draw_value(False)
        self.progress_scale.set_hexpand(True)
        self.progress_scale.connect("change-value", self._seek_to)
        progress_row.append(self.progress_scale)
        self.duration_label = Gtk.Label(label="0:00")
        self.duration_label.add_css_class("mpris-time")
        progress_row.append(self.duration_label)
        self.progress_row = progress_row
        self.main_box.append(progress_row)

    def _control_button(self, icon, action, primary=False):
        button = Gtk.Button(label=icon)
        button.add_css_class("mpris-control")
        button.set_size_request(48, 48)
        if primary:
            button.add_css_class("mpris-primary")
        button.connect("clicked", lambda _button: self._run_action(action))
        return button

    def _playerctl(self, *args):
        try:
            result = subprocess.run(
                ["playerctl", *args],
                capture_output=True,
                text=True,
                timeout=1,
            )
        except subprocess.TimeoutExpired:
            return ""
        return result.stdout.strip() if result.returncode == 0 else ""

    def _select_player(self):
        players = self._playerctl("--list-all").splitlines()
        statuses = {name: self._playerctl("--player", name, "status") for name in players}
        player = next((name for name in players if statuses[name] == "Playing"), None)
        player = player or next((name for name in players if statuses[name] == "Paused"), None)
        return player, statuses.get(player, "")

    def _refresh(self):
        self.player, status = self._select_player()
        active = self.player is not None
        for button in (self.previous_button, self.play_button, self.next_button):
            button.set_sensitive(active)

        if not active:
            self.title_label.set_text("No media playing")
            self.artist_label.set_text("Start playback to control it here")
            self.player_label.set_text("MPRIS")
            self.art.set_visible(False)
            self.art_placeholder.set_visible(True)
            self.progress_row.set_visible(False)
            return GLib.SOURCE_CONTINUE

        metadata = self._playerctl(
            "--player",
            self.player,
            "metadata",
            "--format",
            "{{artist}}\t{{title}}\t{{mpris:artUrl}}",
        )
        artist, title, art_url = (metadata.split("\t") + ["", "", ""])[:3]
        signature = (self.player, title, artist)
        if signature != self._track_signature:
            self._track_signature = signature
            self._suppress_focus_close_until = time.monotonic() + 2
        self.title_label.set_text(title or self.player)
        self.artist_label.set_text(artist or "Unknown artist")
        self.player_label.set_text(f"{self.player} - {status.lower()}")
        self.play_button.set_label("󰏤" if status == "Playing" else "󰐊")
        self._set_art(art_url)
        self._refresh_progress()
        return GLib.SOURCE_CONTINUE

    def _set_art(self, art_url):
        parsed = urlparse(art_url)
        if parsed.scheme != "file":
            self.art.set_visible(False)
            self.art_placeholder.set_visible(True)
            return

        path = Path(unquote(parsed.path))
        if not path.is_file():
            self.art.set_visible(False)
            self.art_placeholder.set_visible(True)
            return

        self.art.set_file(Gio.File.new_for_path(str(path)))
        self.art.set_visible(True)
        self.art_placeholder.set_visible(False)

    def _refresh_progress(self):
        position_text = self._playerctl("--player", self.player, "position")
        length_text = self._playerctl(
            "--player", self.player, "metadata", "--format", "{{mpris:length}}"
        )
        try:
            position = float(position_text)
        except (TypeError, ValueError):
            position = 0.0
        try:
            length = int(length_text) / 1_000_000
            if length <= 0:
                raise ValueError
        except (TypeError, ValueError):
            self.progress_row.set_visible(False)
            return

        self.syncing_progress = True
        self.progress_scale.set_range(0, length)
        self.progress_scale.set_value(min(position, length))
        self.position_label.set_text(self._format_time(position))
        self.duration_label.set_text(self._format_time(length))
        self.syncing_progress = False
        self.progress_row.set_visible(True)

    def _seek_to(self, scale, _scroll, value):
        if self.syncing_progress or not self.player:
            return True
        if self.seek_timeout:
            GLib.source_remove(self.seek_timeout)
        self.seek_timeout = GLib.timeout_add(150, lambda: self._do_seek(value))
        return True

    def _do_seek(self, seconds):
        self.seek_timeout = None
        if self.player:
            subprocess.Popen(
                ["playerctl", "--player", self.player, "position", f"{seconds:.0f}"],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
        return GLib.SOURCE_REMOVE

    def _format_time(self, seconds):
        seconds = max(0, int(seconds))
        hours, rem = divmod(seconds, 3600)
        minutes, secs = divmod(rem, 60)
        if hours:
            return f"{hours}:{minutes:02d}:{secs:02d}"
        return f"{minutes}:{secs:02d}"

    def _run_action(self, action):
        if not self.player:
            return
        if action in ("next", "previous"):
            self._suppress_focus_close_until = time.monotonic() + 3
        subprocess.Popen(
            ["playerctl", "--player", self.player, action],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        GLib.timeout_add(100, self._refresh_once)

    def on_focus_leave(self, controller):
        if time.monotonic() < self._suppress_focus_close_until:
            return
        super().on_focus_leave(controller)

    def _refresh_once(self):
        self._refresh()
        return GLib.SOURCE_REMOVE

    def _on_destroy(self, _window):
        if self.seek_timeout:
            GLib.source_remove(self.seek_timeout)
            self.seek_timeout = None
        if self.refresh_timer:
            GLib.source_remove(self.refresh_timer)
            self.refresh_timer = None
