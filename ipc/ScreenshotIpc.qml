import QtQuick
import Quickshell.Io
import qs.configuration.Screenshot
import qs.services.screenshot
import Quickshell

Scope {
    id: root

    property bool wantRegion: false

    function start(region) {
        wantRegion = region;
        if (ScreenshotService.active) {
            ScreenshotService.dismiss();
            delay.restart();
        } else {
            go();
        }
    }

    function go() {
        wantRegion ? ScreenshotConfig.captureRegion() : ScreenshotConfig.captureFocused();
    }

    Timer {
        id: delay
        interval: 250
        onTriggered: root.go()
    }

    IpcHandler {
        target: "screenshot"

        function full(): void {
            root.start(false);
        }

        function region(): void {
            root.start(true);
        }
    }
}
