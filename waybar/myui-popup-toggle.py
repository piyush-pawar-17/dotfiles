#!/usr/bin/env python3
import json
import subprocess
import sys
import time
from pathlib import Path


POPUPS = {
    "volume": "Volume Control",
    "brightness": "Brightness Control",
}
MANAGER = Path.home() / ".config/waybar/myui_popup_manager.py"


def hyprctl_json(*args):
    return json.loads(subprocess.check_output(["hyprctl", *args, "-j"], text=True))


def existing_popup(title):
    return next((client for client in hyprctl_json("clients") if client.get("title") == title), None)


def hypr_eval(expression):
    subprocess.run(["hyprctl", "eval", expression], check=False, stdout=subprocess.DEVNULL)


def popup_anchor():
    cursor = hyprctl_json("cursorpos")
    monitor = next(
        monitor
        for monitor in hyprctl_json("monitors")
        if monitor["x"] <= cursor["x"] < monitor["x"] + monitor["width"]
        and monitor["y"] <= cursor["y"] < monitor["y"] + monitor["height"]
    )
    return cursor, monitor


def popup_position(cursor, monitor, width):
    left = monitor["x"] + 8
    right = monitor["x"] + monitor["width"] - width - 8
    return max(left, min(cursor["x"] - width // 2, right)), monitor["y"] + 44, monitor["y"]


def move_popup(address, x, y):
    hypr_eval(
        "return hl.dispatch(hl.dsp.window.move({ "
        f"x = {x}, y = {y}, window = \"address:{address}\" "
        "}))"
    )


def main():
    if len(sys.argv) != 2 or sys.argv[1] not in POPUPS:
        raise SystemExit("usage: myui-popup-toggle.py <volume|brightness>")

    popup_name = sys.argv[1]
    popup = existing_popup(POPUPS[popup_name])
    if popup:
        expression = (
            "return hl.dispatch(hl.dsp.window.close({ "
            f"window = \"address:{popup['address']}\" "
            "}))"
        )
        subprocess.run(
            ["hyprctl", "eval", expression], check=False
        )
        return

    cursor, monitor = popup_anchor()
    hypr_eval("myuiNoAnimRule:set_enabled(true)")
    subprocess.Popen(["python3", MANAGER, popup_name], start_new_session=True)
    deadline = time.monotonic() + 5
    try:
        while time.monotonic() < deadline:
            popup = existing_popup(POPUPS[popup_name])
            if popup:
                x, y, monitor_top = popup_position(cursor, monitor, popup["size"][0])
                move_popup(popup["address"], x, monitor_top - popup["size"][1])
                hypr_eval("myuiNoAnimRule:set_enabled(false)")
                move_popup(popup["address"], x, y)
                return
            time.sleep(0.05)
    finally:
        hypr_eval("myuiNoAnimRule:set_enabled(false)")


if __name__ == "__main__":
    main()
