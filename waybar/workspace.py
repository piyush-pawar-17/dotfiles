#!/usr/bin/env python3
import json
import os
import socket
import subprocess
import sys
import time


WORKSPACE = sys.argv[1]
OUTPUT = os.environ["WAYBAR_OUTPUT_NAME"]


def hyprctl_json(command):
    result = subprocess.run(
        ["hyprctl", command, "-j"], capture_output=True, check=True, text=True
    )
    return json.loads(result.stdout)


def workspace_state():
    workspaces = hyprctl_json("workspaces")
    monitors = hyprctl_json("monitors")
    workspace = next((item for item in workspaces if item["name"] == WORKSPACE), None)
    monitor = next((item for item in monitors if item["name"] == OUTPUT), None)
    active = monitor and monitor["activeWorkspace"]["name"] == WORKSPACE
    visible = workspace and workspace["monitor"] == OUTPUT and (active or workspace["windows"])
    return bool(active), bool(visible)


def emit(state):
    active, visible = state
    print(
        json.dumps(
            {
                "text": WORKSPACE if visible else "",
                "class": "active" if active else "inactive" if visible else "empty",
            }
        ),
        flush=True,
    )


def needs_refresh(event):
    return event.split(">>", 1)[0] in {
        "workspace",
        "workspacev2",
        "focusedmon",
        "focusedmonv2",
        "createworkspace",
        "createworkspacev2",
        "destroyworkspace",
        "destroyworkspacev2",
        "openwindow",
        "closewindow",
        "movewindow",
        "movewindowv2",
        "moveworkspace",
        "moveworkspacev2",
    }


while True:
    try:
        state = workspace_state()
        emit(state)

        socket_path = os.path.join(
            os.environ["XDG_RUNTIME_DIR"],
            "hypr",
            os.environ["HYPRLAND_INSTANCE_SIGNATURE"],
            ".socket2.sock",
        )
        with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as hypr_socket:
            hypr_socket.connect(socket_path)
            buffer = ""
            while True:
                buffer += hypr_socket.recv(4096).decode()
                events = buffer.split("\n")
                buffer = events.pop()
                for event in events:
                    if needs_refresh(event):
                        updated_state = workspace_state()
                        if updated_state != state:
                            state = updated_state
                            emit(state)
    except (KeyError, OSError, StopIteration, subprocess.CalledProcessError, json.JSONDecodeError):
        time.sleep(1)
