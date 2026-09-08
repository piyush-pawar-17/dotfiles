#!/usr/bin/env python3
import sys
from pathlib import Path

import gi

gi.require_version("Adw", "1")
from gi.repository import Adw, Gdk, Gio, GLib, Gtk

sys.path.insert(0, str(Path.home() / ".local" / "share" / "myui-popups"))

from myui_brightness import BrightnessPopup as BaseBrightnessPopup
from popups.volume_popup import VolumePopup as BaseVolumePopup
from mpris_popup import MprisPopup as BaseMprisPopup


class FastFocusClose:
    def on_focus_leave(self, controller):
        if not self._can_close_on_focus_loss:
            return
        if self._close_timeout_id:
            GLib.source_remove(self._close_timeout_id)
        self._close_timeout_id = GLib.timeout_add(75, self._close_timeout)


class VolumePopup(FastFocusClose, BaseVolumePopup):
    VOLUME_CSS = """
        .volume-popup button:hover {
            background-color: #2a2a3c;
            color: #cdd6f4;
        }
        .volume-popup switch:checked {
            background-color: #f38ba8;
            border-color: #f38ba8;
        }
        .volume-popup switch:checked slider {
            background-color: #cdd6f4;
        }
    """

    def __init__(self, app, **kwargs):
        super().__init__(app, **kwargs)
        self.add_css_class("volume-popup")
        provider = Gtk.CssProvider()
        provider.load_from_string(self.VOLUME_CSS)
        Gtk.StyleContext.add_provider_for_display(
            Gdk.Display.get_default(),
            provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION + 1,
        )


class BrightnessPopup(FastFocusClose, BaseBrightnessPopup):
    pass


class MprisPopup(BaseMprisPopup):
    pass


class PopupManager(Adw.Application):
    def __init__(self):
        super().__init__(application_id="io.github.piyush.MyuiPopupManager")
        self.set_flags(Gio.ApplicationFlags.HANDLES_COMMAND_LINE)
        self.open_windows = {}

    def do_startup(self):
        Adw.Application.do_startup(self)
        self.hold()

    def do_command_line(self, command_line):
        args = command_line.get_arguments()
        if len(args) < 2:
            return 0

        popup_name = args[-1]
        if args[1] == "close":
            window = self.open_windows.get(popup_name)
            if window is not None:
                window.destroy()
                self.open_windows.pop(popup_name, None)
            return 0

        popup_map = {"brightness": BrightnessPopup, "mpris": MprisPopup, "volume": VolumePopup}
        if popup_name not in popup_map:
            return 1

        window = self.open_windows.get(popup_name)
        if window is not None:
            window.destroy()  # drop any stale hidden window before opening fresh
        window = popup_map[popup_name](app=self, window_tag=popup_name)
        self.open_windows[popup_name] = window
        window.connect("destroy", lambda _window: self.open_windows.pop(popup_name, None))
        window.present()
        return 0


if __name__ == "__main__":
    PopupManager().run(sys.argv)
