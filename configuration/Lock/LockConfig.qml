pragma Singleton

import QtQuick
import Ryu.Io
import Ryu.Shell
import px.services.paths

QtObject {
    id: root

    property bool requested: false
    property bool active: false

    function backgroundFor(name) {
        return PathService.runtime + "/phoenix-lock-" + name + ".ppm";
    }

    function requestLock() {
        if (requested || active) {
            return;
        }
        const names = Screens.list.map(s => s.name);
        if (names.length === 0) {
            return;
        }
        requested = true;
        grim.command = ["sh", "-c", 'dir="$1"; shift; for o in "$@"; do grim -t ppm -o "$o" "$dir/phoenix-lock-$o.ppm" & done; wait', "sh", PathService.runtime].concat(names);
        grim.running = true;
        timeout.restart();
    }

    function engage() {
        if (!requested || active) {
            return;
        }
        timeout.stop();
        active = true;
    }

    function release() {
        timeout.stop();
        requested = false;
        active = false;
        Exec.detached(["sh", "-c", 'rm -f "$1"/phoenix-lock-*.ppm', "sh", PathService.runtime]);
    }

    property Process grim: Process {
        onExited: root.engage()
        onFailed: root.engage()
    }

    property Timer timeout: Timer {
        interval: 3000
        onTriggered: {
            root.grim.running = false;
            root.engage();
        }
    }
}
