import sys
import time
import subprocess
import dbus
import dbus.service
import dbus.mainloop.glib
from gi.repository import GLib

AGENT_PATH = "/bt/agent"
A2DP_SINK = "0000110b-0000-1000-8000-00805f9b34fb"
HFP_HF = "0000111e-0000-1000-8000-00805f9b34fb"
HSP_HS = "00001108-0000-1000-8000-00805f9b34fb"

class Agent(dbus.service.Object):
    def __init__(self, bus, device_mac):
        super().__init__(bus, AGENT_PATH)
        self.device_mac = device_mac.replace(":", "_")

    @dbus.service.method("org.bluez.Agent1", in_signature="", out_signature="")
    def Release(self):
        pass

    @dbus.service.method("org.bluez.Agent1", in_signature="o", out_signature="s")
    def RequestPinCode(self, device):
        return "0000"

    @dbus.service.method("org.bluez.Agent1", in_signature="o", out_signature="u")
    def RequestPasskey(self, device):
        return dbus.UInt32(0)

    @dbus.service.method("org.bluez.Agent1", in_signature="ou", out_signature="")
    def DisplayPasskey(self, device, passkey):
        pass

    @dbus.service.method("org.bluez.Agent1", in_signature="os", out_signature="")
    def DisplayPinCode(self, device, pincode):
        pass

    @dbus.service.method("org.bluez.Agent1", in_signature="ou", out_signature="")
    def RequestConfirmation(self, device, passkey):
        pass

    @dbus.service.method("org.bluez.Agent1", in_signature="o", out_signature="")
    def RequestAuthorization(self, device):
        pass

    @dbus.service.method("org.bluez.Agent1", in_signature="os", out_signature="")
    def AuthorizeService(self, device, uuid):
        if self.device_mac in device:
            return
        raise dbus.exceptions.DBusException("org.bluez.Error.Rejected", "Rejected")

    @dbus.service.method("org.bluez.Agent1", in_signature="", out_signature="")
    def Cancel(self):
        pass

def obj_manager(bus):
    return dbus.Interface(bus.get_object("org.bluez", "/"), "org.freedesktop.DBus.ObjectManager")

def find_adapter(bus):
    objects = obj_manager(bus).GetManagedObjects()
    for path, ifaces in objects.items():
        if "org.bluez.Adapter1" in ifaces:
            return path
    raise RuntimeError("No adapter")

def find_device(bus, mac):
    dev_suffix = mac.replace(":", "_")
    objects = obj_manager(bus).GetManagedObjects()
    for path, ifaces in objects.items():
        if "org.bluez.Device1" in ifaces and path.endswith(dev_suffix):
            return path
    return None

def power_on(bus, adapter_path):
    props = dbus.Interface(bus.get_object("org.bluez", adapter_path), "org.freedesktop.DBus.Properties")
    try:
        props.Set("org.bluez.Adapter1", "Powered", dbus.Boolean(True))
    except dbus.exceptions.DBusException:
        pass

def ensure_pairable(bus, adapter_path, pairable=True, timeout=0):
    props = dbus.Interface(bus.get_object("org.bluez", adapter_path), "org.freedesktop.DBus.Properties")
    try:
        props.Set("org.bluez.Adapter1", "Pairable", dbus.Boolean(pairable))
        if timeout:
            props.Set("org.bluez.Adapter1", "PairableTimeout", dbus.UInt32(timeout))
    except dbus.exceptions.DBusException:
        pass

def set_trust(bus, device_path):
    props = dbus.Interface(bus.get_object("org.bluez", device_path), "org.freedesktop.DBus.Properties")
    props.Set("org.bluez.Device1", "Trusted", dbus.Boolean(True))

def pair_if_needed(bus, device_path, attempts=2):
    dev = dbus.Interface(bus.get_object("org.bluez", device_path), "org.bluez.Device1")
    props = dbus.Interface(bus.get_object("org.bluez", device_path), "org.freedesktop.DBus.Properties")
    for _ in range(attempts):
        paired = False
        try:
            paired = bool(props.Get("org.bluez.Device1", "Paired"))
        except dbus.exceptions.DBusException:
            pass
        if paired:
            return
        try:
            dev.Pair()
            return
        except dbus.exceptions.DBusException as e:
            if "AlreadyExists" in str(e) or "Already Paired" in str(e):
                return
            time.sleep(1)
    raise

def connect_generic(bus, device_path):
    dev = dbus.Interface(bus.get_object("org.bluez", device_path), "org.bluez.Device1")
    dev.Connect()

def connect_profiles(bus, device_path, uuids):
    dev = dbus.Interface(bus.get_object("org.bluez", device_path), "org.bluez.Device1")
    last_err = None
    for u in uuids:
        try:
            dev.ConnectProfile(u)
            return
        except dbus.exceptions.DBusException as e:
            last_err = e
            time.sleep(0.3)
    if last_err:
        raise last_err

def remove_device(bus, adapter_path, device_path):
    ad = dbus.Interface(bus.get_object("org.bluez", adapter_path), "org.bluez.Adapter1")
    try:
        ad.RemoveDevice(device_path)
    except dbus.exceptions.DBusException:
        pass

def discover_until_found(bus, adapter_path, mac, timeout_s=20):
    ad = dbus.Interface(bus.get_object("org.bluez", adapter_path), "org.bluez.Adapter1")
    start = time.time()
    ad.StartDiscovery()
    try:
        while time.time() - start < timeout_s:
            path = find_device(bus, mac)
            if path:
                return path
            time.sleep(0.6)
    finally:
        try:
            ad.StopDiscovery()
        except dbus.exceptions.DBusException:
            pass
    return None

def is_connected(bus, device_path):
    props = dbus.Interface(bus.get_object("org.bluez", device_path), "org.freedesktop.DBus.Properties")
    try:
        return bool(props.Get("org.bluez.Device1", "Connected"))
    except dbus.exceptions.DBusException:
        return False

def get_device_alias(bus, device_path):
    props = dbus.Interface(bus.get_object("org.bluez", device_path), "org.freedesktop.DBus.Properties")
    try:
        alias = props.Get("org.bluez.Device1", "Alias")
        if alias:
            return str(alias)
    except dbus.exceptions.DBusException:
        pass
    try:
        name = props.Get("org.bluez.Device1", "Name")
        if name:
            return str(name)
    except dbus.exceptions.DBusException:
        pass
    return "Urządzenie BT"

def get_battery_percentage(bus, device_path):
    objects = obj_manager(bus).GetManagedObjects()
    for path, ifaces in objects.items():
        if path == device_path or path.startswith(device_path + "/"):
            bat = ifaces.get("org.bluez.Battery1")
            if bat and "Percentage" in bat:
                try:
                    p = int(bat["Percentage"])
                    if 0 <= p <= 100:
                        return p
                except Exception:
                    pass
    return None

def notify(summary, body="", urgency=None, icon=None):
    cmd = ["notify-send", summary]
    if body:
        cmd.append(body)
    if urgency:
        cmd.extend(["-u", urgency])
    if icon:
        cmd.extend(["-i", icon])
    try:
        subprocess.run(cmd, check=False)
    except Exception:
        pass

def robust_connect(bus, adapter_path, mac):
    dev_path = find_device(bus, mac)
    if dev_path is None:
        dev_path = discover_until_found(bus, adapter_path, mac, timeout_s=25)
        if dev_path is None:
            raise RuntimeError("device not found")
    pair_if_needed(bus, dev_path)
    set_trust(bus, dev_path)
    try:
        connect_generic(bus, dev_path)
        return dev_path
    except dbus.exceptions.DBusException as e:
        if any(s in str(e) for s in ["br-connection-unknown", "ConnectionAttemptFailed", "Failed"]):
            remove_device(bus, adapter_path, dev_path)
            dev_path = discover_until_found(bus, adapter_path, mac, timeout_s=25)
            if dev_path is None:
                raise RuntimeError("device not found after reset")
            pair_if_needed(bus, dev_path)
            set_trust(bus, dev_path)
            try:
                connect_generic(bus, dev_path)
                return dev_path
            except dbus.exceptions.DBusException:
                pass
        connect_profiles(bus, dev_path, [A2DP_SINK, HFP_HF, HSP_HS])
        return dev_path

def main():
    if len(sys.argv) < 2:
        print("usage: bt_autoagent.py MAC")
        sys.exit(1)
    mac = sys.argv[1]
    dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
    bus = dbus.SystemBus()
    adapter_path = find_adapter(bus)
    power_on(bus, adapter_path)
    ensure_pairable(bus, adapter_path, pairable=True, timeout=0)
    agent = Agent(bus, mac)
    manager = dbus.Interface(bus.get_object("org.bluez", "/org/bluez"), "org.bluez.AgentManager1")
    try:
        manager.RegisterAgent(AGENT_PATH, "NoInputNoOutput")
    except dbus.exceptions.DBusException:
        pass
    try:
        manager.RequestDefaultAgent(AGENT_PATH)
    except dbus.exceptions.DBusException:
        pass

    dev_path = None
    alias = mac
    try:
        dev_path = robust_connect(bus, adapter_path, mac)
        alias = get_device_alias(bus, dev_path)
        bp = get_battery_percentage(bus, dev_path)
        if is_connected(bus, dev_path):
            body = f"Połączono z {alias}"
            if bp is not None:
                body += f" • Bateria {bp}%"
            notify("Bluetooth", body, urgency="low", icon="bluetooth")
        else:
            notify("Bluetooth", f"Nie udało się połączyć z {alias}", urgency="normal", icon="dialog-error")
    except Exception as e:
        if dev_path:
            alias = get_device_alias(bus, dev_path)
        notify("Bluetooth", f"Błąd połączenia z {alias}: {e}", urgency="normal", icon="dialog-error")

    loop = GLib.MainLoop()
    def stop_if_connected():
        if dev_path and is_connected(bus, dev_path):
            loop.quit()
        return True
    GLib.timeout_add_seconds(3, stop_if_connected)
    GLib.timeout_add_seconds(30, loop.quit)
    loop.run()

if __name__ == "__main__":
    main()
