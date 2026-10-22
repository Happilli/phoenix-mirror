import QtQuick
import qs.services.theme

Item {
    id: root

    property bool open: false

    implicitWidth: 40
    implicitHeight: 40

    Text {
        anchors.centerIn: parent
        text: "\udb86\udc42"
        font.pixelSize: 32
        font.bold: true
        color: root.open ? Theme.background : Theme.onSurfaceVariantColor

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }
    }
}
