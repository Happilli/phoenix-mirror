pragma ComponentBehavior: Bound
import QtQuick
import Ryu.Extraa
import qs.services.theme
import qs.services.media

Rectangle {
    id: root

    property bool vertical: false
    property bool open: false
    property bool expanded: false
    property real progress: expanded ? 1 : 0

    readonly property bool hovered: hover.hovered
    readonly property real collapsedWidth: 40
    readonly property real expandedWidth: 112
    readonly property real expandedOpacity: Math.max(0, Math.min(1, (progress - 0.4) / 0.6))
    readonly property real alongSize: collapsedWidth + (expandedWidth - collapsedWidth) * progress
    readonly property var ranges: [[0, 4], [4, 10], [10, 18], [18, 32]]

    implicitWidth: vertical ? 40 : alongSize
    implicitHeight: vertical ? alongSize : 40
    radius: Math.min(width, height) / 2
    color: Theme.background
    clip: true

    onOpenChanged: if (!open)
        expanded = false

    Behavior on progress {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutCubic
        }
    }

    function band(from, to) {
        let sum = 0;
        for (let i = from; i < to; i++)
            sum += MediaService.spectrum[i] ?? 0;
        return sum / (to - from);
    }

    HoverHandler {
        id: hover
    }

    VisualizerClient {
        enabled: MediaService.hasPlayer
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.expanded = !root.expanded
    }

    Item {
        x: 0
        y: 0
        width: root.vertical ? root.width : root.collapsedWidth
        height: root.vertical ? root.collapsedWidth : root.height
        opacity: 1 - root.expandedOpacity
        visible: opacity > 0.01

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
    }

    Grid {
        anchors.centerIn: parent
        spacing: 4
        flow: root.vertical ? Grid.TopToBottom : Grid.LeftToRight
        columns: root.vertical ? 1 : 3
        opacity: root.expandedOpacity
        visible: opacity > 0.01
        MaterialIconButton {
            width: 32
            height: 32
            enabled: MediaService.player?.canGoPrevious ?? false
            type: MaterialIconButton.Standard
            shape: MaterialIconButton.Round
            iconText: "\uf04a"
            iconSize: 13
            iconColor: Theme.onSurfaceVariantColor
            color: Theme.background
            onClicked: MediaService.previous()
        }

        MaterialIconButton {
            width: 32
            height: 32
            enabled: MediaService.hasPlayer
            type: MaterialIconButton.Filled
            shape: MaterialIconButton.Round
            iconText: MediaService.isPlaying ? "\uf04c" : "\uf04b"
            iconSize: 13
            iconColor: Theme.onPrimaryColor
            color: Theme.primary
            onClicked: MediaService.togglePlaying()
        }

        MaterialIconButton {
            width: 32
            height: 32
            enabled: MediaService.player?.canGoNext ?? false
            type: MaterialIconButton.Standard
            shape: MaterialIconButton.Round
            iconText: "\uf04e"
            iconSize: 13
            iconColor: Theme.onSurfaceVariantColor
            color: Theme.background
            onClicked: MediaService.next()
        }
    }
}
