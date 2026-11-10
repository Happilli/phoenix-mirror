import QtQuick
import Ryu.Wayland
import px.configuration.Screenshot

Item {
    id: root
    required property var screen
    property bool done: false
    ScreencopyView {
        id: view
        width: root.screen.width
        height: root.screen.height
        captureSource: root.screen
        live: false
        fullResolution: true
        onHasContentChanged: {
            if (!hasContent || root.done) {
                return;
            }
            root.done = true;
            const name = root.screen.name;
            const path = ScreenshotConfig.pathFor(name);
            const size = implicitWidth > 0 ? Qt.size(implicitWidth, implicitHeight) : Qt.size(width, height);
            view.grabToImage(result => {
                if (!result || !result.saveToFile(path)) {
                    ScreenshotConfig.report(name, "");
                    return;
                }
                ScreenshotConfig.report(name, path);
            }, size);
        }
    }
}
