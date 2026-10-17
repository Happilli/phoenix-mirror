import QtQuick
import Quickshell
import qs.services.theme
import qs.configuration.Widgets

Rectangle {
    id: root
    readonly property bool showTime: !ClockConfig.enabled

    color: Theme.background
    radius: height / 2
    implicitWidth: row.implicitWidth + 10
    implicitHeight: 40

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
            color: root.showTime ? Theme.onSurfaceVariantColor : Theme.primary
            text: Qt.formatDateTime(sysClock.date, "ddd, d MMM")
            font.pixelSize: 16
            font.bold: true
        }
        Rectangle {
            visible: root.showTime
            width: 4
            height: 4
            radius: 4
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.onSurfaceVariantColor
        }
        Text {
            visible: root.showTime
            color: Theme.primary
            text: Qt.formatDateTime(sysClock.date, "h:mm A")
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 16
            font.bold: true
        }
    }
}
