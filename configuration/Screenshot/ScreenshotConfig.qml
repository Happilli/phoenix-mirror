pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.services.paths

Singleton {
    id: root

    property bool capturing: false
    property bool silent: false
    property var targets: []
    property int pending: 0

    readonly property string saveDir: PathService.home + "/Screenshots"

    signal captured(string screenName, string path)
    signal finished

    function pathFor(name) {
        return PathService.runtime + "/phoenix-capture-" + name + ".bmp";
    }

    function begin(names, quiet) {
        if (capturing || names.length === 0) {
            return false;
        }
        silent = quiet;
        targets = names;
        pending = names.length;
        capturing = true;
        timeout.restart();
        return true;
    }

    function report(name, path) {
        if (!capturing) {
            return;
        }
        if (path !== "") {
            captured(name, path);
        }
        pending -= 1;
        if (pending <= 0) {
            complete();
        }
    }

    function complete() {
        timeout.stop();
        capturing = false;
        targets = [];
        pending = 0;
        finished();
    }

    function captureFocused() {
        const name = Hyprland.focusedMonitor?.name ?? Quickshell.screens[0]?.name;
        if (!name) {
            return false;
        }
        return begin([name], false);
    }

    function captureAll() {
        return begin(Quickshell.screens.map(s => s.name), false);
    }

    onCaptured: (screenName, path) => {
        if (silent) {
            return;
        }
        const ts = Qt.formatDateTime(new Date(), "yyyy-MM-dd_hh-mm-ss");
        const dest = saveDir + "/screenshot_" + ts + "_" + screenName + ".jpg";
        saver.command = ["sh", "-c", 'mkdir -p "$(dirname "$2")" && magick "$1" -quality 90 "$2" && wl-copy -t image/jpeg < "$2" && notify-send -a Phoenix "Screenshot saved" "$2"; rm -f "$1"', "sh", path, dest];
        saver.running = true;
    }
    Timer {
        id: timeout
        interval: 2500
        onTriggered: root.complete()
    }

    Process {
        id: saver
    }
}
