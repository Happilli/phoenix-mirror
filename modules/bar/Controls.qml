pragma ComponentBehavior: Bound
import QtQuick
import qs.services.theme
import Ryu.Extraa
import qs.services.controls

Rectangle {
    id: root

    property bool vertical: false

    readonly property bool hovered: hover.hovered
    readonly property var kinds: ["volume", "brightness", "mic"]

    color: Theme.background
    implicitWidth: vertical ? 40 : 120
    implicitHeight: vertical ? 120 : 40
    radius: Math.min(width, height) / 2

    HoverHandler {
        id: hover
    }

    function iconOf(key) {
        switch (key) {
        case "volume":
            if (AudioService.muted || AudioService.volume <= 0) {
                return "\uf026";
            }
            return AudioService.volume < 0.5 ? "\uf027" : "\uf028";
        case "brightness":
            return "\udb80\udce0";
        case "mic":
            return AudioService.micMuted ? "\uf131" : "\uf130";
        }
        return "";
    }
    function valueOf(key) {
        switch (key) {
        case "volume":
            return AudioService.volume;
        case "brightness":
            return BrightnessService.brightness;
        case "mic":
            return AudioService.micVolume;
        }
        return 0;
    }
    function toggleMute(key) {
        if (key === "volume")
            AudioService.toggleMute();
        else if (key === "mic")
            AudioService.toggleMicMute();
        OsdService.show(key);
    }
    function setValue(key, v) {
        switch (key) {
        case "volume":
            AudioService.setVolume(v);
            break;
        case "mic":
            AudioService.setMicVolume(v);
            break;
        case "brightness":
            BrightnessService.setBrightness(v);
            break;
        }
        OsdService.show(key);
    }
    Grid {
        anchors.centerIn: parent
        flow: root.vertical ? Grid.TopToBottom : Grid.LeftToRight
        columns: root.vertical ? 1 : 3

        Repeater {
            model: root.kinds
            Item {
                id: cell
                width: root.vertical ? root.width : 39
                height: root.vertical ? 39 : root.height
                required property var modelData

                WavyProgress {
                    id: ring
                    anchors.centerIn: parent
                    style: WavyProgress.Circular
                    amplitude: 0
                    strokeWidth: 3
                    trackColor: Theme.surfaceContainerHighest
                    color: Theme.primary
                    progress: root.valueOf(cell.modelData)
                    indeterminate: false
                    width: 35
                    height: 35
                }

                MouseArea {
                    anchors.fill: ring
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.toggleMute(cell.modelData)
                }

                Text {
                    anchors.centerIn: parent
                    text: root.iconOf(cell.modelData)
                    color: Theme.onSurfaceVariantColor
                    font.bold: true
                    font.pixelSize: 17
                }
            }
        }
    }
}
