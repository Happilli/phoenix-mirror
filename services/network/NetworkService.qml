pragma Singleton

import QtQuick
import Ryu.Network

QtObject {
    id: root

    readonly property var client: iwd
    property bool connecting: false
    property string message: ""
    property double lastScan: 0

    readonly property bool busy: iwd.scanning || connecting || iwd.state === "connecting"

    readonly property string statusText: {
        if (!iwd.available)
            return "iwd not running";
        if (!iwd.powered)
            return "Off";
        if (iwd.connectedSsid !== "")
            return iwd.connectedSsid;
        if (iwd.scanning)
            return "Scanning";
        return iwd.state.length > 0 ? iwd.state.charAt(0).toUpperCase() + iwd.state.slice(1) : "";
    }

    function typeLabel(t) {
        if (t === "open")
            return "Open";
        if (t === "psk")
            return "WPA";
        if (t === "wep")
            return "WEP";
        return "Enterprise";
    }

    function scanIfStale() {
        if (!iwd.powered || iwd.scanning)
            return;
        const now = Date.now();
        if (now - lastScan < 15000)
            return;
        lastScan = now;
        iwd.scan();
    }

    function connectTo(path, pass, user) {
        connecting = true;
        iwd.connectToNetwork(path, pass ?? "", user ?? "");
    }

    function flash(text) {
        message = text;
        clear.restart();
    }

    property Timer clear: Timer {
        interval: 5000
        onTriggered: root.message = ""
    }

    property Iwd iwd: Iwd {
        onError: msg => {
            root.connecting = false;
            root.flash(msg);
        }

        onConnectResult: (path, ok, msg) => {
            root.connecting = false;
            root.flash(ok ? "" : "Failed: " + msg);
        }
    }
}
