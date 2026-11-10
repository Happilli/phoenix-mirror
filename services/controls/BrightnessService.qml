pragma Singleton
import QtQuick
import Ryu.Display

QtObject {
    id: root

    readonly property real brightness: Backlight.brightness
    readonly property bool available: Backlight.available

    function refresh() {
        Backlight.refresh();
    }

    function setBrightness(v) {
        Backlight.setBrightness(v);
    }
}
