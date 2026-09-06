#!/usr/bin/env python3
import datetime
import json
import os

CACHE_FILE = os.path.expanduser("~/.cache/waybar-ycal/events.json")


def load_events():
    if os.path.exists(CACHE_FILE):
        try:
            with open(CACHE_FILE) as file:
                return json.load(file)
        except (OSError, json.JSONDecodeError):
            pass
    return {}


now = datetime.datetime.now()
events = load_events()

print(json.dumps({
    "text": now.strftime('%a • %-d %b • %H:%M'),
    "tooltip": "",
    "class": "has-events" if events.get(now.date().isoformat()) else "",
}))
