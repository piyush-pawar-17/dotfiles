#!/bin/sh

if pgrep -x wf-recorder >/dev/null; then
    printf '%s\n' '{"text":"","tooltip":"Screen recording in progress","class":"recording"}'
else
    printf '%s\n' '{"text":"","class":"hidden"}'
fi
