import QtQuick
import qs.services.media

QtObject {
    id: root

    property bool enabled: false
    property bool held: false

    function sync() {
        if (enabled && !held) {
            held = true;
            MediaService.acquire();
        } else if (!enabled && held) {
            held = false;
            MediaService.release();
        }
    }

    onEnabledChanged: sync()
    Component.onCompleted: sync()
    Component.onDestruction: {
        if (held)
            MediaService.release();
    }
}
