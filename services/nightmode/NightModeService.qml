pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.services.state

Singleton {
    id: root

    readonly property var keys: ["temperature", "gamma"]
    readonly property real minTemp: 2000
    readonly property real maxTemp: 6500
    readonly property real minGamma: 0.2

    property bool active: StateService.get("nightActive", false)
    property real temperature: StateService.get("nightTemp", 4000)
    property real gamma: StateService.get("nightGamma", 1)

    property bool dirty: false
    property bool ready: false

    function valueOf(key) {
        if (key === "temperature")
            return (temperature - minTemp) / (maxTemp - minTemp);
        if (key === "gamma")
            return (gamma - minGamma) / (1 - minGamma);
        return 0;
    }

    function setValue(key, v) {
        const c = Math.max(0, Math.min(1, v));
        if (key === "temperature")
            temperature = minTemp + c * (maxTemp - minTemp);
        else if (key === "gamma")
            gamma = minGamma + c * (1 - minGamma);
        else
            return;
        active = true;
        changed();
    }

    function toggle() {
        active = !active;
        changed();
    }

    function start() {
        // only launch if not already running; survives shell exit
        Quickshell.execDetached(["sh", "-c", `pgrep -x hyprsunset >/dev/null || hyprsunset -t ${Math.round(temperature)} -g ${Math.round(gamma * 100)}`]);
        settle.restart();
    }

    function stop() {
        ready = false;
        Quickshell.execDetached(["pkill", "-x", "hyprsunset"]);
    }

    onActiveChanged: active ? start() : stop()

    Component.onCompleted: {
        if (active)
            start();
    }

    function changed() {
        dirty = true;
        flush();
        saveTimer.restart();
    }

    function flush() {
        if (!dirty || !active || !ready || proc.running)
            return;
        dirty = false;
        proc.command = ["sh", "-c", `hyprctl hyprsunset temperature ${Math.round(temperature)} && hyprctl hyprsunset gamma ${Math.round(gamma * 100)}`];
        proc.running = true;
    }

    Timer {
        id: settle
        interval: 300
        onTriggered: {
            root.ready = true;
            root.dirty = true;
            root.flush();
        }
    }

    Process {
        id: proc
        onRunningChanged: if (!running)
            root.flush()
    }

    Timer {
        id: saveTimer
        interval: 400
        onTriggered: {
            StateService.set("nightActive", root.active);
            StateService.set("nightTemp", root.temperature);
            StateService.set("nightGamma", root.gamma);
        }
    }
}
