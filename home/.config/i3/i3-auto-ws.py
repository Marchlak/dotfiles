#!/usr/bin/env python3
import i3ipc, subprocess, re, threading, time, os

POLYBAR = os.path.expanduser("~/.config/i3/config.d/scripts/polybar-launch.sh")

def pick():
    xr = subprocess.check_output(["xrandr","--query"], text=True).splitlines()
    internal = external = None
    for ln in xr:
        if " connected " not in ln:
            continue
        out = ln.split()[0]
        if re.match(r"(eDP|LVDS|DSI)", out):
            internal = out
        elif re.match(r"(HDMI|DP|DisplayPort)", out) and external is None:
            external = out
    return internal, external

def width(out):
    xr = subprocess.check_output(["xrandr","--query"], text=True)
    m = re.search(rf"^{out}\sconnected.*\n\s+(\d+)x\d+.*\*", xr, re.M)
    return int(m.group(1)) if m else 1920

i3  = i3ipc.Connection()
INT, EXT = pick()

def set_layout():
    global INT, EXT
    INT, EXT = pick()
    subprocess.call(["xrandr","--output",INT,"--auto","--primary"])
    if EXT:
        subprocess.call(["xrandr","--output",EXT,"--off"])
        subprocess.call(["xrandr","--output",EXT,
                         "--auto","--pos",f"{width(INT)}x0"])
    fix_workspaces()
    if EXT:
        subprocess.Popen([POLYBAR])        # wznowienie polybar

def fix_workspaces():
    for ws in i3.get_workspaces():
        n, out = ws.num, ws.output
        if n in range(1,6) and out != INT:
            i3.command(f"move workspace number {n} to output {INT}")
        elif n in range(6,11) and EXT and out != EXT:
            i3.command(f"move workspace number {n} to output {EXT}")

def watchdog():
    while True:
        time.sleep(2)
        fix_workspaces()

set_layout()                               # przy starcie
i3.on("output", lambda *_: set_layout())   # hot-plug
threading.Thread(target=watchdog, daemon=True).start()
i3.main()
