pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland
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

    signal captured(string screenName, string path)
    signal regionPicked(string screenName, var rect)
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
        return Hyprland.focusedMonitor?.name ?? Quickshell.screens[0]?.name ?? "";
    }

    function captureFocused() {
        const name = focusedName();
        regionMode = false;
        lassoMode = false;
        selectPurpose = "screenshot";
        return name !== "" && begin([name], false);
    }

    function captureRegion() {
        const name = focusedName();
        regionMode = true;
        lassoMode = false;
        selectPurpose = "screenshot";
        return name !== "" && begin([name], false);
    }

    function captureLasso() {
        const name = focusedName();
        regionMode = true;
        lassoMode = true;
        selectPurpose = "screenshot";
        return name !== "" && begin([name], false);
    }

    function captureRegionForRecording() {
        const name = focusedName();
        regionMode = true;
        lassoMode = false;
        selectPurpose = "record";
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
        if (purpose === "record" || purpose === "share") {
            Exec.detached(["rm", "-f", source]);
            if (purpose === "share")
                sharePicked(screen, geom !== "" ? rect : null);
            else if (geom !== "" && rect)
                regionPicked(screen, rect);
        } else if (geom !== "") {
            ScreenshotService.present(screen, source, geom, "");
        } else {
            Exec.detached(["rm", "-f", source]);
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
        ScreenshotService.present(screenName, path, "", "");
    }

    Timer {
        id: timeout
        interval: 2500
        onTriggered: root.complete()
    }
}
