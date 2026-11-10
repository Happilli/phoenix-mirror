pragma Singleton

import QtQuick
import Ryu.Io
import Ryu.Shell
import px.services.paths
import px.configuration.Screenshot

QtObject {
    id: root

    property bool requested: false
    property bool active: false
    property int stamp: 0

    signal lockRequested

    function backgroundFor(name) {
        return ScreenshotConfig.pathFor(name);
    }

    function backgroundUrl(name) {
        return "file://" + backgroundFor(name) + "?" + stamp;
    }

    function requestLock() {
        if (requested || active) {
            return;
        }
        requested = true;
        stamp += 1;
        const started = ScreenshotConfig.begin(Screens.list.map(s => s.name), true);
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
        Exec.detached(["sh", "-c", `rm -f "${PathService.runtime}"/phoenix-capture-*.bmp`]);
    }

    property Connections screenshotWatch: Connections {
        target: ScreenshotConfig

        function onFinished() {
            if (root.requested && !root.active) {
                root.engage();
            }
        }
    }
}
