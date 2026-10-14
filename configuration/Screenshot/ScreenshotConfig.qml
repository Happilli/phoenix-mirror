pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.services.paths
import qs.services.screenshot

Singleton {
    id: root

    property bool capturing: false
    property bool silent: false
    property bool regionMode: false
    property bool selecting: false
    property string selectScreen: ""
    property string selectSource: ""
    property var targets: []
    property int pending: 0

    signal captured(string screenName, string path)
    signal finished

    function pathFor(name) {
        return PathService.runtime + "/phoenix-capture-" + name + ".bmp";
    }

    function begin(names, quiet) {
        if (capturing || selecting || names.length === 0) {
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

    function focusedName() {
        return Hyprland.focusedMonitor?.name ?? Quickshell.screens[0]?.name ?? "";
    }

    function captureFocused() {
        const name = focusedName();
        regionMode = false;
        return name !== "" && begin([name], false);
    }

    function captureRegion() {
        const name = focusedName();
        regionMode = true;
        return name !== "" && begin([name], false);
    }

    function finishSelect(geom) {
        const source = selectSource;
        selecting = false;
        regionMode = false;
        if (geom !== "") {
            ScreenshotService.present(selectScreen, source, geom);
        } else {
            Quickshell.execDetached(["rm", "-f", source]);
        }
    }

    onCaptured: (screenName, path) => {
        if (silent) {
            return;
        }
        if (regionMode) {
            selectScreen = screenName;
            selectSource = path;
            selecting = true;
            return;
        }
        ScreenshotService.present(screenName, path, "");
    }

    Timer {
        id: timeout
        interval: 2500
        onTriggered: root.complete()
    }
}
