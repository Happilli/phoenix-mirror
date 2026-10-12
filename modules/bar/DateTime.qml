import QtQuick
import Quickshell
import qs.services.theme

Item {
    id: root
    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight
    SystemClock {
        id: sysClock
        precision: SystemClock.Minutes
    }
    Row {
        id: row
        spacing: 8
        anchors.centerIn: parent
        Text {
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.onSurfaceVariantColor
            text: Qt.formatDateTime(sysClock.date, "ddd, d MMM")
            font.pixelSize: 16
            font.bold: true
        }
        Rectangle {
            width: 4
            height: 4
            radius: 4
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.onSurfaceVariantColor
        }
        Text {
            color: Theme.primary
            text: Qt.formatDateTime(sysClock.date, "h:mm A")
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 16
            font.bold: true
        }
    }
}
