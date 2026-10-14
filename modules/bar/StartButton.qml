import QtQuick
import qs.services.theme

Item {
    id: root

    property bool open: false

    implicitWidth: 40
    implicitHeight: 40

    Text {
        anchors.centerIn: parent
        text: "\ued16"
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
