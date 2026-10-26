import QtQuick
import Quickshell
import qs.services.theme
import qs.configuration.Widgets

Rectangle {
    id: root

    property bool vertical: false
    readonly property bool showTime: !ClockConfig.enabled

    color: Theme.background
    radius: Math.min(width, height) / 2
    implicitWidth: vertical ? 40 : row.implicitWidth + 10
    implicitHeight: vertical ? col.implicitHeight + 20 : 40

    SystemClock {
        id: sysClock
        precision: SystemClock.Minutes
    }
    Row {
        id: row
        visible: !root.vertical
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
    Column {
        id: col
        visible: root.vertical
        spacing: 2
        anchors.centerIn: parent
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            color: root.showTime ? Theme.onSurfaceVariantColor : Theme.primary
            text: Qt.formatDateTime(sysClock.date, "ddd")
            font.pixelSize: 14
            font.bold: true
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            color: root.showTime ? Theme.onSurfaceVariantColor : Theme.primary
            text: Qt.formatDateTime(sysClock.date, "d")
            font.pixelSize: 14
            font.bold: true
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            color: root.showTime ? Theme.onSurfaceVariantColor : Theme.primary
            text: Qt.formatDateTime(sysClock.date, "MMM")
            font.pixelSize: 14
            font.bold: true
        }
        Rectangle {
            visible: root.showTime
            anchors.horizontalCenter: parent.horizontalCenter
            width: 4
            height: 4
            radius: 4
            color: Theme.onSurfaceVariantColor
        }
        Text {
            visible: root.showTime
            anchors.horizontalCenter: parent.horizontalCenter
            color: Theme.primary
            text: Qt.formatDateTime(sysClock.date, "h:mm")
            font.pixelSize: 14
            font.bold: true
        }
        Text {
            visible: root.showTime
            anchors.horizontalCenter: parent.horizontalCenter
            color: Theme.primary
            text: Qt.formatDateTime(sysClock.date, "A")
            font.pixelSize: 12
            font.bold: true
        }
    }
}
