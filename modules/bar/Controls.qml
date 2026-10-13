pragma ComponentBehavior: Bound
import QtQuick
import qs.services.theme
import Ryu.Extraa
import qs.services.controls

Rectangle {
    id: root
    color: Theme.background
    implicitWidth: 120
    implicitHeight: 40
    radius: height / 2

    readonly property var controls: ["volume", "brightness", "mic"]

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
            return 1;
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
    }
    function setValue(key, v) {
        switch (key) {
        case "volume":
            AudioService.setVolume(v);
            break;
        case "mic":
            AudioService.setMicVolume(v);
            break;
        }
    }

    Row {
        anchors.centerIn: parent
        Repeater {
            model: root.controls
            Item {
                id: cell
                width: 39
                height: root.height
                required property var modelData
                WavyProgress {
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
                    anchors.fill: parent
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
