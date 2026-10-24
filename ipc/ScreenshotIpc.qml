import QtQuick
import Quickshell.Io
import qs.configuration.Screenshot
import qs.services.screenshot
import Quickshell

Scope {
    id: root

    property string mode: "full"

    function start(m) {
        mode = m;
        if (ScreenshotService.active) {
            ScreenshotService.dismiss();
            delay.restart();
        } else {
            go();
        }
    }

    function go() {
        if (mode === "lasso")
            ScreenshotConfig.captureLasso();
        else if (mode === "region")
            ScreenshotConfig.captureRegion();
        else
            ScreenshotConfig.captureFocused();
    }

    Timer {
        id: delay
        interval: 250
        onTriggered: root.go()
    }

    IpcHandler {
        target: "screenshot"

        function full(): void {
            root.start("full");
        }

        function region(): void {
            root.start("region");
        }

        function lasso(): void {
            root.start("lasso");
        }
    }
}
