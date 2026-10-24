import QtQuick
import qs.services.theme

Rectangle {
    id: root

    property bool open: false

    implicitWidth: 40
    implicitHeight: 40
    radius: height / 2
    color: Theme.background

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
