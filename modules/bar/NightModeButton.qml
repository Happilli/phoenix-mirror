import QtQuick
import qs.services.theme
import qs.services.nightmode

Item {
    id: root
    implicitWidth: 40
    implicitHeight: 40

    Text {
        anchors.centerIn: parent
        text: NightModeService.active ? "\uf186" : "\udb81\udda8"
        font.pixelSize: 22
        font.bold: true
        color: NightModeService.active ? Theme.primary : Theme.onSurfaceVariantColor

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: NightModeService.toggle()
    }
}
