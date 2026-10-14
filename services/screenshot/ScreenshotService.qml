pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.services.paths

Singleton {
    id: root

    property string path: ""
    property string screenName: ""
    property string savedPath: ""
    property string target: ""
    property string pendingOut: ""
    property string pendingScreen: ""
    property string pendingSource: ""
    property bool copied: false
    readonly property bool active: path !== ""
    readonly property string dir: PathService.home + "/Screenshots"

    function show(name, file) {
        if (path !== "" && path !== file) {
            Quickshell.execDetached(["rm", "-f", path]);
        }
        savedPath = "";
        copied = false;
        screenName = name;
        path = file;
    }

    function present(name, source, crop) {
        if (mover.running || convert.running) {
            return;
        }
        pendingScreen = name;
        pendingSource = source;
        pendingOut = PathService.runtime + "/phoenix-shot-" + Date.now() + ".bmp";
        if (crop === "") {
            mover.command = ["mv", "-f", source, pendingOut];
            mover.running = true;
        } else {
            convert.command = ["magick", source, "-crop", crop, "+repage", pendingOut];
            convert.running = true;
        }
    }

    function save() {
        if (!active || savedPath !== "" || store.running) {
            return;
        }
        target = dir + "/screenshot_" + Qt.formatDateTime(new Date(), "yyyy-MM-dd_hh-mm-ss") + ".jpg";
        store.command = ["sh", "-c", 'mkdir -p "$(dirname "$2")" && magick "$1" -quality 90 "$2"', "sh", path, target];
        store.running = true;
    }

    function copy() {
        if (!active || copier.running) {
            return;
        }
        copier.command = ["sh", "-c", 'magick "$1" png:- | wl-copy -t image/png', "sh", path];
        copier.running = true;
    }

    function dismiss() {
        if (path !== "") {
            Quickshell.execDetached(["rm", "-f", path]);
        }
        path = "";
    }

    Process {
        id: mover
        onExited: code => {
            if (code === 0) {
                root.show(root.pendingScreen, root.pendingOut);
            }
        }
    }

    Process {
        id: convert
        onExited: code => {
            Quickshell.execDetached(["rm", "-f", root.pendingSource]);
            if (code === 0) {
                root.show(root.pendingScreen, root.pendingOut);
            }
        }
    }

    Process {
        id: store
        onExited: code => {
            if (code === 0) {
                root.savedPath = root.target;
            }
        }
    }

    Process {
        id: copier
        onExited: code => root.copied = code === 0
    }
}
