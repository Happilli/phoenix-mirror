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

    function backgroundFor(name) {
        return PathService.runtime + "/phoenix-lock-" + name + ".ppm";
    }

    function requestLock() {
        if (requested || active) {
            return;
        }
        const names = Screens.list.map(s => s.name);
        if (names.length === 0) {
            return;
        }
        requested = true;
        ScreenshotConfig.prefix = "phoenix-lock-";
        ScreenshotConfig.ext = "ppm";
        if (!ScreenshotConfig.begin(names, true)) {
            ScreenshotConfig.prefix = "phoenix-capture-";
            ScreenshotConfig.ext = "bmp";
            engage();
            return;
        }
        timeout.restart();
    }

    function engage() {
        if (!requested || active) {
            return;
        }
        timeout.stop();
        active = true;
    }

    function release() {
        timeout.stop();
        requested = false;
        active = false;
        Exec.detached(["sh", "-c", 'rm -f "$1"/phoenix-lock-*.ppm', "sh", PathService.runtime]);
    }

    property Connections capture: Connections {
        target: ScreenshotConfig

        function onFinished() {
            if (root.requested && !root.active) {
                root.engage();
            }
        }
    }

    property Timer timeout: Timer {
        interval: 3000
        onTriggered: root.engage()
    }
}
