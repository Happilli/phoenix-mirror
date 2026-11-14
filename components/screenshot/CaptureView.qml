import QtQuick
import Ryu.Wayland
import px.configuration.Screenshot

Item {
    id: root

    required property var screen
    property bool done: false

    ScreencopyView {
        id: view
        width: root.screen.size.width
        height: root.screen.size.height
        captureSource: root.screen
        live: false
        fullResolution: true

        onHasContentChanged: {
            if (!view.hasContent || root.done) {
                return;
            }
            root.done = true;
            const name = root.screen.name;
            const path = ScreenshotConfig.pathFor(name);
            const size = view.implicitWidth > 0 ? Qt.size(view.implicitWidth, view.implicitHeight) : Qt.size(view.width, view.height);
            ScreenshotConfig.imageWidth = size.width;
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
