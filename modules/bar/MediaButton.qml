pragma ComponentBehavior: Bound
import QtQuick
import qs.services.theme
import qs.services.media

Item {
    id: root

    property bool open: false

    readonly property var ranges: [[0, 4], [4, 10], [10, 18], [18, 32]]

    implicitWidth: 40
    implicitHeight: 40

    function band(from, to) {
        let sum = 0;
        for (let i = from; i < to; i++)
            sum += MediaService.spectrum[i] ?? 0;
        return sum / (to - from);
    }

    VisualizerClient {
        enabled: MediaService.hasPlayer
    }

    Text {
        anchors.centerIn: parent
        visible: !MediaService.hasPlayer || !MediaService.visualizerEnabled
        text: "\uf001"
        font.pixelSize: 20
        font.bold: true
        color: Theme.onSurfaceVariantColor
    }

    Row {
        anchors.centerIn: parent
        spacing: 3
        visible: MediaService.hasPlayer && MediaService.visualizerEnabled

        Repeater {
            model: root.ranges

            Rectangle {
                id: barItem
                required property var modelData
                readonly property real level: Math.min(1, root.band(modelData[0], modelData[1]) * 1.15)

                width: 3
                height: 5 + 22 * level
                radius: 1.5
                anchors.verticalCenter: parent.verticalCenter
                color: (MediaService.isPlaying || root.open) ? Theme.primary : Theme.onSurfaceVariantColor
                opacity: MediaService.isPlaying ? 0.55 + 0.45 * level : 0.6

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 150
                    }
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: MediaService.togglePlaying()
    }
}
