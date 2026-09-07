#!/usr/bin/env python3
import re
import shutil
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path.home() / ".local" / "share" / "myui-popups"))

from widgets.myui import AppWindow, InfoRow, QuickApp, SliderRow


def current_brightness():
    output = subprocess.check_output(["brightnessctl", "-m"], text=True)
    return int(output.split(",")[3].removesuffix("%"))


class BrightnessPopup(AppWindow):
    def __init__(self, app, **kwargs):
        window_tag = kwargs.pop("window_tag", "brightness")
        super().__init__(
            app=app,
            title="Brightness Control",
            width=320,
            window_tag=window_tag,
            close_on_focus_loss=True,
            **kwargs,
        )
        self.add_css_class("brightness-popup")
        self.add_title("Display Brightness", "Adjust the laptop display")
        self.slider = SliderRow(
            icon="󰃟",
            text="Brightness",
            initial_value=current_brightness(),
            callback=self.set_brightness,
            show_value=True,
        )
        self.add_widget(self.slider)

        self.external_max = None
        external_brightness = self.current_external_brightness()
        if external_brightness is None:
            self.add_widget(
                InfoRow(
                    icon="󰍹",
                    title="BenQ EX271Q",
                    subtitle="Install ddcutil and enable DDC/CI to control brightness",
                )
            )
        else:
            self.external_slider = SliderRow(
                icon="󰍹",
                text="BenQ EX271Q",
                initial_value=external_brightness,
                on_release_callback=self.set_external_brightness,
                show_value=True,
            )
            self.add_widget(self.external_slider)

    def set_brightness(self, slider):
        subprocess.run(
            ["brightnessctl", "set", f"{int(slider.get_value())}%"],
            check=False,
            stdout=subprocess.DEVNULL,
        )

    def current_external_brightness(self):
        if not shutil.which("ddcutil"):
            return None
        try:
            output = subprocess.check_output(
                ["ddcutil", "getvcp", "10", "--display", "1"], text=True, stderr=subprocess.DEVNULL
            )
            match = re.search(r"current value =\s+(\d+), max value =\s+(\d+)", output)
            if match is None:
                return None
            current, self.external_max = map(int, match.groups())
            return round(current * 100 / self.external_max)
        except subprocess.CalledProcessError:
            return None

    def set_external_brightness(self, slider):
        if self.external_max is None:
            return
        value = round(slider.get_value() * self.external_max / 100)
        subprocess.run(
            ["ddcutil", "setvcp", "10", str(value), "--display", "1"],
            check=False,
            stdout=subprocess.DEVNULL,
        )


if __name__ == "__main__":
    QuickApp(
        application_id="io.github.piyush.BrightnessControl",
        window_class=BrightnessPopup,
        window_tag="brightness",
    ).run_quick()
