#!/usr/bin/env python3
import json
import subprocess
import sys
import time
from pathlib import Path


POPUPS = {
    "volume": "Volume Control",
    "brightness": "Brightness Control",
    "mpris": "Media Control",
}
MANAGER = Path.home() / ".config/waybar/myui_popup_manager.py"
ANCHOR_FILE = Path.home() / ".cache/myui-mpris-anchor.json"


def hyprctl_json(*args):
    return json.loads(subprocess.check_output(["hyprctl", *args, "-j"], text=True))


def existing_popup(title):
    return next((client for client in hyprctl_json("clients") if client.get("title") == title), None)


def hypr_eval(expression):
    subprocess.run(["hyprctl", "eval", expression], check=False, stdout=subprocess.DEVNULL)


def read_chip_anchor():
    try:
        return json.loads(ANCHOR_FILE.read_text())
    except (FileNotFoundError, ValueError):
        return None


def save_chip_anchor(cursor, monitor):
    ANCHOR_FILE.parent.mkdir(parents=True, exist_ok=True)
    ANCHOR_FILE.write_text(json.dumps({"x": cursor["x"], "monitor": monitor["name"]}))


def measure_chip(monitor):
    """Locate the Waybar mpris label (blue #89b4fa text) in the bar strip."""
    try:
        strip = subprocess.check_output(
            ["grim", "-t", "ppm", "-g", f"{monitor['x']},{monitor['y']} {monitor['width']}x40", "-"],
            stderr=subprocess.DEVNULL,
        )
    except (subprocess.CalledProcessError, FileNotFoundError):
        return None
    parts = strip.split(b"\n", 3)
    if len(parts) != 4:
        return None
    try:
        w, h = map(int, parts[1].split())
    except ValueError:
        return None
    px = parts[3]
    cols = [False] * w
    for row in range(h):
        base = row * w * 3
        for c in range(w):
            i = base + c * 3
            r, g, b = px[i], px[i + 1], px[i + 2]
            if abs(r - 0x89) < 20 and abs(g - 0xB4) < 20 and abs(b - 0xFA) < 24:
                cols[c] = True
    groups = []
    cur = None
    for c, hit in enumerate(cols):
        if hit:
            if cur is None or c - cur[1] > 40:
                groups.append([c, c])
                cur = groups[-1]
            else:
                cur[1] = c
    groups = [g for g in groups if g[1] - g[0] >= 40]
    if not groups:
        return None
    s, e = max(groups, key=lambda g: g[1] - g[0])
    return monitor["x"] + (s + e) // 2


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


def focus_popup(address):
    hypr_eval(
        "return hl.dispatch(hl.dsp.focus({ "
        f"window = \"address:{address}\" "
        "}))"
    )


def main():
    keybind = "--keybind" in sys.argv
    if len(sys.argv) not in (2, 3) or sys.argv[1] not in POPUPS:
        raise SystemExit("usage: myui-popup-toggle.py <volume|brightness|mpris> [--keybind]")

    popup_name = sys.argv[1]
    popup = existing_popup(POPUPS[popup_name])
    if popup:
        subprocess.run(["python3", str(MANAGER), "close", popup_name], check=False)
        return

    cursor, monitor = popup_anchor()
    if popup_name == "mpris":
        if keybind:
            anchor = read_chip_anchor()
            if anchor is not None:
                monitor = next(
                    (m for m in hyprctl_json("monitors") if m["name"] == anchor["monitor"]),
                    monitor,
                )
            chip = measure_chip(monitor)
            if chip is None and anchor is not None:
                chip = anchor["x"]
            if chip is None:
                chip = monitor["x"] + monitor["width"] - 670
            cursor = {"x": chip, "y": cursor["y"]}
        else:
            save_chip_anchor(cursor, monitor)

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
                focus_popup(popup["address"])
                return
            time.sleep(0.05)
    finally:
        hypr_eval("myuiNoAnimRule:set_enabled(false)")


if __name__ == "__main__":
    main()
