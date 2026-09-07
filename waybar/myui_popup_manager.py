#!/usr/bin/env python3
import sys
from pathlib import Path

import gi

gi.require_version("Adw", "1")
from gi.repository import Adw, Gio, GLib

sys.path.insert(0, str(Path.home() / ".local" / "share" / "myui-popups"))

from myui_brightness import BrightnessPopup as BaseBrightnessPopup
from popups.volume_popup import VolumePopup as BaseVolumePopup


class FastFocusClose:
    def on_focus_leave(self, controller):
        if not self._can_close_on_focus_loss:
            return
        if self._close_timeout_id:
            GLib.source_remove(self._close_timeout_id)
        self._close_timeout_id = GLib.timeout_add(75, self._close_timeout)


class VolumePopup(FastFocusClose, BaseVolumePopup):
    def __init__(self, app, **kwargs):
        super().__init__(app, **kwargs)
        self.add_css_class("volume-popup")


class BrightnessPopup(FastFocusClose, BaseBrightnessPopup):
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

        popup_name = args[1]
        if popup_name in self.open_windows and self.open_windows[popup_name].is_visible():
            self.open_windows[popup_name].close()
            return 0

        popup_map = {"brightness": BrightnessPopup, "volume": VolumePopup}
        if popup_name not in popup_map:
            return 1

        window = popup_map[popup_name](app=self, window_tag=popup_name)
        self.open_windows[popup_name] = window
        window.connect("destroy", lambda _window: self.open_windows.pop(popup_name, None))
        window.present()
        return 0


if __name__ == "__main__":
    PopupManager().run(sys.argv)
