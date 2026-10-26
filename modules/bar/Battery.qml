pragma ComponentBehavior: Bound
import QtQuick
import qs.services.theme
import Quickshell.Services.UPower

Rectangle {
    id: root

    property bool vertical: false

    readonly property var device: UPower.displayDevice
    readonly property real level: Math.max(0, Math.min(1, device.percentage))
    property real shown: level
    readonly property bool charging: device.state === UPowerDeviceState.Charging || device.state === UPowerDeviceState.FullyCharged
    readonly property bool critical: !charging && level <= 0.5
    readonly property real barWidth: vertical ? 28 : 55
    readonly property real barHeight: vertical ? 55 : 28
    color: Theme.surfaceContainer
    width: vertical ? 40 : barWidth + 16
    height: vertical ? barHeight + 16 : 40
    radius: Math.min(width, height) / 2

    Behavior on shown {
        NumberAnimation {
            duration: 200
            easing.type: Easing.InOutQuad
        }
    }

    component Layer: Item {
        id: batteryLayer
        property color base
        property color textColor

        width: root.barWidth
        height: root.barHeight

        Rectangle {
            width: root.barWidth
            height: root.barHeight
            radius: Math.min(width, height) / 2
            color: batteryLayer.base
        }
        Grid {
            spacing: 2
            anchors.centerIn: parent
            flow: root.vertical ? Grid.TopToBottom : Grid.LeftToRight
            columns: root.vertical ? 1 : 2
            horizontalItemAlignment: Grid.AlignHCenter
            verticalItemAlignment: Grid.AlignVCenter
            Text {
                visible: root.charging
                text: "\udb85\udc0b"
                font.pixelSize: root.vertical ? 13 : 17
                font.bold: true
                color: batteryLayer.textColor
            }

            Text {
                text: Math.round(root.level * 100)
                font.pixelSize: root.vertical ? 13 : 17
                font.bold: true
                color: batteryLayer.textColor
            }
        }
    }

    Item {
        anchors.centerIn: parent
        width: root.barWidth
        height: root.barHeight
        Layer {
            base: Theme.surfaceContainerHighest
            textColor: Theme.onSurfaceVariantColor
        }

        Item {
            width: root.vertical ? root.barWidth : root.barWidth * root.shown
            height: root.vertical ? root.barHeight * root.shown : root.barHeight
            y: root.vertical ? root.barHeight - height : 0
            clip: true

            Layer {
                y: root.vertical ? parent.height - root.barHeight : 0
                base: root.critical ? Theme.error : Theme.primary
                textColor: root.critical ? Theme.onErrorColor : Theme.onPrimaryColor
            }
        }
    }
}
