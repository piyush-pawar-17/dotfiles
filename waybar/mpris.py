#!/usr/bin/env python3
import json
import subprocess


def playerctl(*args):
    try:
        result = subprocess.run(
            ["playerctl", *args],
            capture_output=True,
            text=True,
            timeout=2,
        )
    except (OSError, subprocess.TimeoutExpired):
        return ""
    return result.stdout.strip() if result.returncode == 0 else ""


def main():
    players = playerctl("--list-all").splitlines()
    statuses = {player: playerctl("--player", player, "status") for player in players}
    player = next((name for name in players if statuses[name] == "Playing"), None)
    player = player or next((name for name in players if statuses[name] == "Paused"), None)

    if not player:
        print(json.dumps({"text": "", "class": "hidden"}))
        return

    metadata = playerctl("--player", player, "metadata", "--format", "{{artist}}\t{{title}}")
    artist, _, title = metadata.partition("\t")
    label = " - ".join(part for part in (title, artist) if part) or player
    if len(label) > 36:
        label = f"{label[:33]}..."

    icon = "󰏤" if statuses[player] == "Paused" else "󰐊"
    print(
        json.dumps(
            {
                "text": f"{icon} {label}",
                "tooltip": f"{title}\r{artist}\r{player}",
                "class": statuses[player].lower(),
            }
        )
    )


if __name__ == "__main__":
    main()
