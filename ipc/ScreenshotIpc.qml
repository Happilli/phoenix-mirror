import QtQuick
import Ryu.Ipc
import px.configuration.Screenshot
import px.services.screenshot

QtObject {
    id: root

    property string mode: "full"

    function start(m) {
        mode = m;
        if (ScreenshotService.active) {
            ScreenshotService.dismiss();
            root.delayTimer.restart();
        } else {
            go();
        }
    }

    function go() {
        if (mode === "lasso")
            ScreenshotConfig.captureLasso();
        else if (mode === "region")
            ScreenshotConfig.grimRegion();
        else
            ScreenshotConfig.grimFull();
    }

    property Timer delayTimer: Timer {
        interval: 250
        onTriggered: root.go()
    }

    property IpcHandler handler: IpcHandler {
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
