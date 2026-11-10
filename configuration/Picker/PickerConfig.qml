pragma Singleton
import QtQuick
import Ryu.Sway
import Ryu.Io
import qs.services.paths

QtObject {
    id: root

    property bool open: false
    property int tab: 0

    readonly property string resultPath: PathService.runtime + "/phoenix-picker-result"

    readonly property var screenItems: {
        const screens = Qt.application.screens;
        return screens.map(s => ({
                    key: "s:" + s.name,
                    label: s.name + "  ·  " + s.width + "x" + s.height,
                    kind: "screen",
                    target: s.name,
                    source: s
                }));
    }

    readonly property var windowItems: {
        const list = Sway.toplevels.values;
        return list.filter(t => t.mapped && t.foreignId !== "" && t.appId !== "org.quickshell").map(t => ({
                    key: "w:" + t.foreignId,
                    label: t.appId + "  ·  " + t.title,
                    kind: "window",
                    target: t.foreignId,
                    source: t
                }));
    }

    property Process writer: Process {}

    function toggle() {
        if (open)
            cancel();
        else
            show();
    }

    function show() {
        tab = 0;
        Sway.refreshToplevels();
        open = true;
    }

    function pick(kind, target) {
        finish((kind === "window" ? "Window: " : "Monitor: ") + target);
    }

    function cancel() {
        finish("");
    }

    function finish(text) {
        if (!open)
            return;
        open = false;
        root.writer.command = ["sh", "-c", '[ -p "$2" ] && printf "%s" "$1" | timeout 3 tee "$2" >/dev/null', "sh", text, root.resultPath];
        root.writer.running = true;
    }
}
