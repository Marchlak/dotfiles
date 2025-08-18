#!/usr/bin/env python3
import sys
import subprocess
import os
import dbus
import dbus.service
import dbus.mainloop.glib
from gi.repository import GLib

AGENT_PATH = "/bt/agent_menu"
THEME = os.environ.get("ROFI_THEME", os.path.expanduser("~/.config/i3/rofi/dark1.rasi"))

class Agent(dbus.service.Object):
    def __init__(self, bus, mac_allow=None):
        super().__init__(bus, AGENT_PATH)
        self.mac_allow = mac_allow.replace(":", "_") if mac_allow else None

    @dbus.service.method("org.bluez.Agent1", in_signature="", out_signature="")
    def Release(self): pass
    @dbus.service.method("org.bluez.Agent1", in_signature="o", out_signature="s")
    def RequestPinCode(self, device): return "0000"
    @dbus.service.method("org.bluez.Agent1", in_signature="o", out_signature="u")
    def RequestPasskey(self, device): return dbus.UInt32(0)
    @dbus.service.method("org.bluez.Agent1", in_signature="ou", out_signature="")
    def DisplayPasskey(self, device, passkey): pass
    @dbus.service.method("org.bluez.Agent1", in_signature="os", out_signature="")
    def DisplayPinCode(self, device, pincode): pass
    @dbus.service.method("org.bluez.Agent1", in_signature="ou", out_signature="")
    def RequestConfirmation(self, device, passkey): pass
    @dbus.service.method("org.bluez.Agent1", in_signature="o", out_signature="")
    def RequestAuthorization(self, device): pass
    @dbus.service.method("org.bluez.Agent1", in_signature="os", out_signature="")
    def AuthorizeService(self, device, uuid):
        if not self.mac_allow: return
        if self.mac_allow in device: return
        raise dbus.exceptions.DBusException("org.bluez.Error.Rejected", "Rejected")
    @dbus.service.method("org.bluez.Agent1", in_signature="", out_signature="")
    def Cancel(self): pass

def mngr(bus):
    return dbus.Interface(bus.get_object("org.bluez", "/"), "org.freedesktop.DBus.ObjectManager")

def list_paired(bus):
    objs = mngr(bus).GetManagedObjects()
    out = []
    for path, ifaces in objs.items():
        dev = ifaces.get("org.bluez.Device1")
        if not dev: continue
        if dev.get("Paired") or dev.get("Trusted"):
            name = dev.get("Alias") or dev.get("Name") or "Unknown"
            mac = path.split("/")[-1].replace("_", ":")
            connected = dev.get("Connected", False)
            out.append((name, mac, path, connected))
    out.sort(key=lambda x: x[0].lower())
    return out

def find_adapter(bus):
    objs = mngr(bus).GetManagedObjects()
    for path, ifaces in objs.items():
        if "org.bluez.Adapter1" in ifaces: return path
    raise RuntimeError("No adapter")

def power_on(bus, adapter_path):
    props = dbus.Interface(bus.get_object("org.bluez", adapter_path), "org.freedesktop.DBus.Properties")
    props.Set("org.bluez.Adapter1", "Powered", dbus.Boolean(True))

def set_trust(bus, device_path):
    props = dbus.Interface(bus.get_object("org.bluez", device_path), "org.freedesktop.DBus.Properties")
    props.Set("org.bluez.Device1", "Trusted", dbus.Boolean(True))

def pair_if_needed(bus, device_path):
    dev = dbus.Interface(bus.get_object("org.bluez", device_path), "org.bluez.Device1")
    props = dbus.Interface(bus.get_object("org.bluez", device_path), "org.freedesktop.DBus.Properties")
    paired = props.Get("org.bluez.Device1", "Paired")
    if not paired:
        try: dev.Pair()
        except dbus.exceptions.DBusException as e:
            if "AlreadyExists" not in str(e): raise

def connect_device(bus, device_path):
    dev = dbus.Interface(bus.get_object("org.bluez", device_path), "org.bluez.Device1")
    try: dev.Connect()
    except dbus.exceptions.DBusException as e:
        if "AlreadyConnected" not in str(e): raise

def rofi_pick(options):
    txt = "\n".join(options).encode()
    try:
        p = subprocess.run(["rofi","-dmenu","-i","-p","BT","-theme",THEME], input=txt, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
    except FileNotFoundError:
        p = subprocess.run(["dmenu","-p","BT"], input=txt, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
    return p.stdout.decode().strip()

def main():
    dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
    bus = dbus.SystemBus()
    adapter = find_adapter(bus)
    power_on(bus, adapter)
    devices = list_paired(bus)
    if not devices: sys.exit(1)

    # Dodaj (connected) do nazw połączonych urządzeń
    options = []
    for name, mac, _, connected in devices:
        label = f"{name}  ({mac})"
        if connected:
            label += " (connected)"
        options.append(label)

    chosen = rofi_pick(options)
    if not chosen: sys.exit(0)

    mac = chosen.split("(")[1].split(")")[0].strip()
    dev = next((d for d in devices if d[1] == mac), None)
    if not dev: sys.exit(1)

    agent = Agent(bus, mac_allow=mac)
    mgr = dbus.Interface(bus.get_object("org.bluez", "/org/bluez"), "org.bluez.AgentManager1")
    try: mgr.RegisterAgent(AGENT_PATH, "NoInputNoOutput")
    except dbus.exceptions.DBusException: pass
    try: mgr.RequestDefaultAgent(AGENT_PATH)
    except dbus.exceptions.DBusException: pass

    dev_path = dev[2]
    pair_if_needed(bus, dev_path)
    set_trust(bus, dev_path)
    connect_device(bus, dev_path)

    loop = GLib.MainLoop()
    def stop_if_connected():
        props = dbus.Interface(bus.get_object("org.bluez", dev_path), "org.freedesktop.DBus.Properties")
        try:
            if props.Get("org.bluez.Device1", "Connected"):
                loop.quit()
        except dbus.exceptions.DBusException:
            pass
        return True

    GLib.timeout_add_seconds(5, stop_if_connected)
    GLib.timeout_add_seconds(30, loop.quit)
    loop.run()

if __name__ == "__main__":
    main()
