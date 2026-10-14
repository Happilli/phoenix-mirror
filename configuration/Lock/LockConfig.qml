pragma Singleton
import QtQuick
import Quickshell
import qs.configuration.Screenshot
import qs.services.paths

Singleton {
    id: root

    property bool requested: false
    property bool active: false

    signal lockRequested

    function backgroundFor(name) {
        return ScreenshotConfig.pathFor(name);
    }

    function requestLock() {
        if (requested || active) {
            return;
        }
        requested = true;
        const started = ScreenshotConfig.begin(Quickshell.screens.map(s => s.name), true);
        if (!started) {
            engage();
        }
    }

    function engage() {
        active = true;
        lockRequested();
    }

    function release() {
        requested = false;
        active = false;
        Quickshell.execDetached(["sh", "-c", `rm -f "${PathService.runtime}"/phoenix-capture-*.bmp`]);
    }
    Connections {
        target: ScreenshotConfig
        function onFinished() {
            if (root.requested && !root.active) {
                root.engage();
            }
        }
    }
}
