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
    property bool lassoMode: false
    property bool selecting: false
    property bool direct: false
    property bool afterSelect: false
    property bool forRecord: false
    property string selectScreen: ""
    property string prefix: "phoenix-capture-"
    property string ext: "bmp"
    property string pendingScreen: ""
    property var pendingRect: null
    property var pendingPoly: null
    property real imageWidth: 0
    property var targets: []
    property int pending: 0

    signal captured(string screenName, string path)
    signal regionPicked(string screenName, var rect)
    signal finished

    function pathFor(name) {
        return PathService.runtime + "/" + prefix + name + "." + ext;
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
        direct = false;
        afterSelect = false;
        prefix = "phoenix-capture-";
        ext = "bmp";
        finished();
    }

    function focusedName() {
        return Sway.focusedMonitor?.name ?? Screens.list[0]?.name ?? "";
    }

    function captureFull() {
        const name = focusedName();
        if (name === "" || !begin([name], false)) {
            return false;
        }
        direct = true;
        return true;
    }

    function startSelect(lasso) {
        const name = focusedName();
        if (name === "" || capturing || selecting) {
            return false;
        }
        selectScreen = name;
        lassoMode = lasso;
        selecting = true;
        return true;
    }

    function captureRegion() {
        return startSelect(false);
    }

    function captureLasso() {
        return startSelect(true);
    }

    function pickRegion() {
        if (!startSelect(false)) {
            return false;
        }
        forRecord = true;
        return true;
    }

    function finishSelect(geom, rect) {
        const screen = selectScreen;
        const record = forRecord;
        selecting = false;
        lassoMode = false;
        forRecord = false;
        pendingPoly = null;
        if (record) {
            regionPicked(screen, rect);
            return;
        }
        if (!rect) {
            return;
        }
        pendingRect = rect;
        pendingScreen = screen;
        afterTimer.restart();
    }

    function finishLasso(rect, pts) {
        const screen = selectScreen;
        selecting = false;
        lassoMode = false;
        forRecord = false;
        pendingRect = rect;
        pendingPoly = pts;
        pendingScreen = screen;
        afterTimer.restart();
    }

    onCaptured: (screenName, path) => {
        if (silent) {
            return;
        }
        if (direct) {
            direct = false;
            ScreenshotService.present(screenName, path, "", "");
            return;
        }
        if (afterSelect) {
            afterSelect = false;
            const r = pendingRect;
            const k = r && r.sw > 0 && imageWidth > 0 ? imageWidth / r.sw : 1;
            const geom = Math.round(r.w * k) + "x" + Math.round(r.h * k) + "+" + Math.round(r.x * k) + "+" + Math.round(r.y * k);
            const poly = pendingPoly ? pendingPoly.map(p => Math.round(p.x * k) + "," + Math.round(p.y * k)).join(" ") : "";
            pendingPoly = null;
            ScreenshotService.present(screenName, path, geom, poly);
            return;
        }
        Exec.detached(["rm", "-f", path]);
    }

    property Timer afterTimer: Timer {
        interval: 140
        onTriggered: {
            if (root.begin([root.pendingScreen], false)) {
                root.afterSelect = true;
            }
        }
    }

    property Timer timeout: Timer {
        interval: 2500
        onTriggered: root.complete()
    }
}
