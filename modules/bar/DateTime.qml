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
    implicitHeight: vertical ? col.implicitHeight + 26 : 40

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
        spacing: 1
        anchors.centerIn: parent

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(sysClock.date, "ddd").toUpperCase()
            font.pixelSize: 10
            font.bold: true
            font.letterSpacing: 0.8
            color: Theme.onSurfaceVariantColor
            opacity: 0.7
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(sysClock.date, "d")
            font.pixelSize: 22
            font.bold: true
            color: root.showTime ? Theme.onSurfaceVariantColor : Theme.primary
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(sysClock.date, "MMM").toUpperCase()
            font.pixelSize: 10
            font.bold: true
            font.letterSpacing: 0.8
            color: Theme.onSurfaceVariantColor
            opacity: 0.7
        }

        Item {
            visible: root.showTime
            width: 1
            height: 7
        }
        Rectangle {
            visible: root.showTime
            anchors.horizontalCenter: parent.horizontalCenter
            width: 18
            height: 2
            radius: 1
            color: Theme.outlineVariant
        }
        Item {
            visible: root.showTime
            width: 1
            height: 7
        }

        Text {
            visible: root.showTime
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(sysClock.date, "h")
            font.pixelSize: 17
            font.bold: true
            color: Theme.primary
        }
        Text {
            visible: root.showTime
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(sysClock.date, "mm")
            font.pixelSize: 17
            font.bold: true
            color: Theme.primary
        }
        Text {
            visible: root.showTime
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(sysClock.date, "A")
            font.pixelSize: 9
            font.bold: true
            color: Theme.primary
            opacity: 0.7
        }
    }
}
