import QtQuick
import px.services.theme

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
        text: "\udb86\udc42"
        font.pixelSize: 24
        font.bold: true
        color: root.open ? Theme.primary : Theme.onSurfaceVariantColor

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }
    }
}
