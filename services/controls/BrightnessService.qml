pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property real brightness: 1
    property bool available: false
    property real pending: -1

    function setBrightness(v) {
        brightness = Math.max(0.01, Math.min(1, v));
        pending = brightness;
        if (!setter.running)
            flush();
    }

    function flush() {
        if (pending < 0)
            return;
        const pct = Math.round(pending * 100);
        pending = -1;
        setter.command = ["brightnessctl", "-q", "set", pct + "%"];
        setter.running = true;
    }

    Process {
        id: setter
        onRunningChanged: if (!running)
            root.flush()
    }

    Process {
        id: reader
        command: ["brightnessctl", "-m"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                if (setter.running || root.pending >= 0)
                    return;
                const p = data.split(",");
                if (p.length < 5)
                    return;
                const cur = parseInt(p[2]);
                const max = parseInt(p[4]);
                if (max > 0) {
                    root.brightness = cur / max;
                    root.available = true;
                }
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: if (!reader.running && !setter.running)
            reader.running = true
    }
}
