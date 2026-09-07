#!/usr/bin/env python3
import json
import subprocess


def status(module, fallback_icon):
    try:
        output = subprocess.check_output(["orbit", "waybar-status", module], text=True, timeout=2)
        data = json.loads(output)
        return data["text"].split(maxsplit=1)[0], data.get("tooltip", ""), True
    except (KeyError, OSError, subprocess.CalledProcessError, subprocess.TimeoutExpired, json.JSONDecodeError):
        return fallback_icon, f"{module.title()} unavailable", False


wifi_icon, wifi_tooltip, wifi_available = status("wifi", "󰖪")
bluetooth_icon, bluetooth_tooltip, bluetooth_available = status("bluetooth", "󰂲")
print(
    json.dumps(
        {
            "text": f"{wifi_icon}  {bluetooth_icon}",
            "tooltip": f"{wifi_tooltip}\n\n{bluetooth_tooltip}",
            "class": "disconnected" if not wifi_available or not bluetooth_available else "connected",
        }
    )
)
