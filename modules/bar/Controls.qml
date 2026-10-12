pragma ComponentBehavior: Bound
import QtQuick
import qs.services.theme
import Ryu.Extraa
import qs.services.controls

Rectangle {
    id: root
    color: Theme.surfaceContainer
    implicitWidth: 150
    implicitHeight: 38
    radius: height / 2

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
    readonly property var controls: ["volume", "brightness", "mic"]

    readonly property bool open: pillHover.hovered || popupHover.hovered
    property alias popupItem: panel
    readonly property int gap: 8
    readonly property int sliderLength: 400
    readonly property int itemWidth: 50
    readonly property int trackWidth: 42

    Item {
        id: panel
        width: root.open ? card.width : 0
        height: root.open ? card.height + root.y - 7 : 0

        y: -height
        x: Math.round((root.width - width) / 2)
        visible: root.open

        HoverHandler {
            id: popupHover
        }

        Rectangle {
            id: card
            width: sliders.implicitWidth + root.gap * 2 - (root.itemWidth - root.trackWidth)
            height: sliders.implicitHeight + root.gap * 2
            radius: root.gap + 12
            color: Theme.background

            Row {
                id: sliders
                anchors.centerIn: parent
                spacing: -(root.itemWidth - root.trackWidth - root.gap)
                Repeater {
                    model: root.controls
                    MaterialSlider {
                        required property var modelData
                        orientation: MaterialSlider.Vertical
                        sizeStyle: MaterialSlider.Medium
                        value: root.valueOf(modelData)
                        showStops: false
                        showValueIndicator: false
                        outerRadius: 12
                        innerRadius: 2
                        trackColor: Theme.surfaceContainerHighest
                        color: Theme.primary
                        handleColor: Theme.primary

                        onValueChanged: {
                            if (Math.abs(value - root.valueOf(modelData)) > 0.005) {
                                root.setValue(modelData, value);
                            }
                        }

                        Component.onCompleted: {
                            width = root.itemWidth;
                            height = root.sliderLength;
                        }
                    }
                }
            }
        }
    }
    HoverHandler {
        id: pillHover
    }

    Row {
        anchors.centerIn: parent
        Repeater {
            model: root.controls
            Item {
                id: cell
                width: 50
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
                    width: 32
                    height: 32
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
