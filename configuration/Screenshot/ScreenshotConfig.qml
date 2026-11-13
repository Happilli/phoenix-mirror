pragma Singleton

import QtQuick
import px.services.theme
import Ryu.Sway
import Ryu.Io
import Ryu.Shell
import px.services.paths
import px.services.screenshot

QtObject {
    id: root

    property bool capturing: false
    property bool silent: false
    property bool regionMode: false
    property bool lassoMode: false
    property bool selecting: false
    property string selectScreen: ""
    property string selectSource: ""
    property var targets: []
    property int pending: 0
    property string shotScreen: ""
    property string shotPath: ""

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
        if (!selecting) {
            regionMode = false;
            lassoMode = false;
        }
        finished();
    }

    function focusedName() {
        return Sway.focusedMonitor?.name ?? Screens.list[0]?.name ?? "";
    }

    function startGrim(args) {
        if (grim.running || capturing || selecting) {
            return false;
        }
        const name = focusedName();
        if (name === "") {
            return false;
        }
        shotScreen = name;
        shotPath = PathService.runtime + "/phoenix-shot-" + Date.now() + ".png";
        grim.command = args(name, shotPath);
        grim.running = true;
        return true;
    }

    function grimFull() {
        return startGrim((name, out) => ["grim", "-o", name, out]);
    }

    function slurpArgs() {
        const accent = String(Theme.primary).replace("#", "").slice(0, 6);
        return ["-b", "#00000099", "-s", "#00000000", "-c", "#" + accent + "ff", "-w", "2"];
    }

    function grimRegion() {
        return startGrim((name, out) => ["sh", "-c", 'out="$1"; shift; g=$(slurp "$@") || exit 1; exec grim -g "$g" "$out"', "sh", out].concat(slurpArgs()));
    }

    function captureLasso() {
        const name = focusedName();
        if (name === "") {
            return false;
        }
        if (!begin([name], false)) {
            return false;
        }
        regionMode = true;
        lassoMode = true;
        return true;
    }

    function finishSelect(geom, rect) {
        const source = selectSource;
        selecting = false;
        regionMode = false;
        lassoMode = false;
        Exec.detached(["rm", "-f", source]);
    }

    function finishLasso(geom, poly) {
        const source = selectSource;
        const screen = selectScreen;
        selecting = false;
        regionMode = false;
        lassoMode = false;
        if (geom !== "" && poly !== "")
            ScreenshotService.present(screen, source, geom, poly);
        else
            Exec.detached(["rm", "-f", source]);
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
        Exec.detached(["rm", "-f", path]);
    }

    property Process grim: Process {
        onExited: code => {
            if (code === 0) {
                ScreenshotService.show(root.shotScreen, root.shotPath);
            } else {
                Exec.detached(["rm", "-f", root.shotPath]);
            }
        }
    }

    property Timer timeout: Timer {
        interval: 2500
        onTriggered: root.complete()
    }
}
