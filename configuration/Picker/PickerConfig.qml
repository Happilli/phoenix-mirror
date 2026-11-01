pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.services.paths
import qs.configuration.Screenshot

Singleton {
    id: root

    property bool open: false
    property bool regioning: false
    property string raw: ""
    property int tab: 0
    property bool token: true

    readonly property string resultPath: PathService.runtime + "/phoenix-picker-result"
    readonly property string listPath: PathService.runtime + "/phoenix-picker-list"

    readonly property var windows: {
        const out = [];
        for (const e of raw.split("[HA>]")) {
            if (e.trim() === "")
                continue;
            const a = e.split("[HC>]");
            if (a.length < 2)
                continue;
            const b = a[1].split("[HT>]");
            if (b.length < 2)
                continue;
            const c = b[1].split("[HE>]");
            out.push({
                id: a[0],
                cls: b[0],
                title: c[0],
                addr: c.length > 1 ? c[1].trim() : ""
            });
        }
        return out;
    }

    readonly property var screenItems: Quickshell.screens.map(s => ({
                label: s.name + "  ·  " + s.width + "x" + s.height,
                kind: "screen",
                target: s.name,
                addr: "",
                screen: s
            }))

    readonly property var windowItems: windows.map(w => ({
                label: w.cls + "  ·  " + w.title,
                kind: "window",
                target: w.id,
                addr: w.addr,
                screen: null
            }))

    function toggle() {
        if (open)
            cancel();
        else
            show();
    }

    function show() {
        listFile.reload();
        try {
            raw = listFile.text();
        } catch (e) {
            raw = "";
        }
        tab = 0;
        token = true;
        regioning = false;
        open = true;
    }

    function startRegion() {
        regioning = true;
        regionDelay.restart();
    }

    function pick(kind, target) {
        finish("[SELECTION]" + (token ? "r" : "") + "/" + kind + ":" + target);
    }

    function cancel() {
        finish("");
    }

    function finish(text) {
        if (!open)
            return;
        open = false;
        writer.command = ["sh", "-c", 'printf "%s" "$1" > "$2.tmp" && mv "$2.tmp" "$2"', "sh", text, resultPath];
        writer.running = true;
    }

    Timer {
        id: regionDelay
        interval: 250
        onTriggered: {
            if (!ScreenshotConfig.captureRegionForShare())
                root.regioning = false;
        }
    }

    Connections {
        target: ScreenshotConfig

        function onSharePicked(screenName, rect) {
            if (!root.regioning)
                return;
            if (rect)
                root.pick("region", screenName + "@" + rect.x + "," + rect.y + "," + rect.w + "," + rect.h);
            root.regioning = false;
        }

        function onFinished() {
            if (root.regioning && !ScreenshotConfig.selecting && !regionDelay.running)
                root.regioning = false;
        }
    }

    FileView {
        id: listFile
        path: root.listPath
        blockLoading: true
        printErrors: false
    }

    Process {
        id: writer
    }
}
