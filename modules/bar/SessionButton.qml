pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs.services.theme
import qs.configuration.Lock

Rectangle {
    id: root

    property bool vertical: false
    property bool open: false
    property bool expanded: false
    property real progress: expanded ? 1 : 0

    readonly property bool hovered: hover.hovered
    readonly property real cell: 34
    readonly property real cellGap: 6
    readonly property real inset: 6
    readonly property real collapsedWidth: 40
    readonly property real expandedWidth: cell * 3 + cellGap * 2 + inset * 2
    readonly property real expandedOpacity: Math.max(0, Math.min(1, (progress - 0.4) / 0.6))
    readonly property real alongSize: collapsedWidth + (expandedWidth - collapsedWidth) * progress

    readonly property var actions: [
        {
            action: "lock",
            icon: "\uf023",
            danger: false
        },
        {
            action: "restart",
            icon: "\uf2f9",
            danger: false
        },
        {
            action: "shutdown",
            icon: "\uf011",
            danger: true
        }
    ]

    function run(action) {
        expanded = false;
        switch (action) {
        case "lock":
            LockConfig.requestLock();
            break;
        case "restart":
            Quickshell.execDetached(["systemctl", "reboot"]);
            break;
        case "shutdown":
            Quickshell.execDetached(["systemctl", "poweroff"]);
            break;
        }
    }

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

    HoverHandler {
        id: hover
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: root.expanded ? Qt.ArrowCursor : Qt.PointingHandCursor
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
            text: "\uDBFC\uDDAE"
            font.pixelSize: 40
            color: root.open ? Theme.primary : Theme.onSurfaceVariantColor

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }
        }
    }

    Grid {
        anchors.centerIn: parent
        spacing: root.cellGap
        flow: root.vertical ? Grid.TopToBottom : Grid.LeftToRight
        columns: root.vertical ? 1 : 3
        opacity: root.expandedOpacity
        visible: opacity > 0.01

        Repeater {
            model: root.actions

            Item {
                id: btn
                required property var modelData

                width: root.cell
                height: root.cell
                scale: area.pressed ? 0.88 : 1

                Behavior on scale {
                    SpringAnimation {
                        spring: 5
                        damping: 0.4
                        epsilon: 0.005
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: btn.modelData.icon
                    font.pixelSize: 24
                    font.bold: true
                    color: area.containsMouse ? (btn.modelData.danger ? Theme.error : Theme.primary) : Theme.onSurfaceVariantColor

                    Behavior on color {
                        ColorAnimation {
                            duration: 120
                        }
                    }
                }

                MouseArea {
                    id: area
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.run(btn.modelData.action)
                }
            }
        }
    }
}
