pragma Singleton
import QtQuick
import Quickshell
import qs.services.theme
import Ryu.Sway
import Ryu.Io
import qs.services.paths
import qs.services.screenshot

Singleton {
    id: root

    property bool capturing: false
    property bool silent: false
    property bool regionMode: false
    property bool lassoMode: false
    property bool selecting: false
    property string selectScreen: ""
    property string selectSource: ""
    property string selectPurpose: "screenshot"
    property var targets: []
    property int pending: 0
    property string shotScreen: ""
    property string shotPath: ""

    signal captured(string screenName, string path)
    signal sharePicked(string screenName, var rect)
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
        return Sway.focusedMonitor?.name ?? Quickshell.screens[0]?.name ?? "";
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
        regionMode = true;
        lassoMode = true;
        selectPurpose = "screenshot";
        return name !== "" && begin([name], false);
    }

    function captureRegionForShare() {
        const name = focusedName();
        regionMode = true;
        lassoMode = false;
        selectPurpose = "share";
        return name !== "" && begin([name], false);
    }

    function finishSelect(geom, rect) {
        const source = selectSource;
        const purpose = selectPurpose;
        const screen = selectScreen;
        selecting = false;
        regionMode = false;
        lassoMode = false;
        selectPurpose = "screenshot";
        Exec.detached(["rm", "-f", source]);
        if (purpose === "share") {
            sharePicked(screen, geom !== "" ? rect : null);
        }
    }

    function finishLasso(geom, poly) {
        const source = selectSource;
        const screen = selectScreen;
        selecting = false;
        regionMode = false;
        lassoMode = false;
        selectPurpose = "screenshot";
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

    Process {
        id: grim
        onExited: code => {
            if (code === 0) {
                ScreenshotService.show(root.shotScreen, root.shotPath);
            } else {
                Exec.detached(["rm", "-f", root.shotPath]);
            }
        }
    }

    Timer {
        id: timeout
        interval: 2500
        onTriggered: root.complete()
    }
}
