import QtQuick
import qs.services.theme

Rectangle {
    id: root

    property bool open: false

    readonly property bool hovered: hover.hovered

    implicitWidth: 40
    implicitHeight: 40
    radius: height / 2
    color: Theme.background

    HoverHandler {
        id: hover
    }

    Text {
        anchors.centerIn: parent
        text: "\uf40e"
        font.pixelSize: 24
        font.bold: true
        color: root.open ? Theme.primary : Theme.onSurfaceVariantColor

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        cursorShape: Qt.PointingHandCursor
    }
}
