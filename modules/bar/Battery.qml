pragma ComponentBehavior: Bound
import QtQuick
import qs.services.theme
import Quickshell.Services.UPower

Rectangle {
    id: root
    readonly property var device: UPower.displayDevice
    readonly property real level: Math.max(0, Math.min(1, device.percentage))
    property real shown: level
    readonly property bool charging: device.state === UPowerDeviceState.Charging || device.state === UPowerDeviceState.FullyCharged
    readonly property bool critical: !charging && level <= 0.5
    readonly property real barWidth: 55
    readonly property real barHeight: 28
    color: Theme.surfaceContainer
    width: barWidth + 16
    radius: height / 2
    height: 40

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
            radius: height / 2
            color: batteryLayer.base
        }
        Row {
            spacing: 2
            anchors.centerIn: parent
            Text {
                visible: root.charging
                anchors.verticalCenter: parent.verticalCenter
                text: "\udb85\udc0b"
                font.pixelSize: 17
                font.bold: true
                color: batteryLayer.textColor
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: Math.round(root.level * 100)
                font.pixelSize: 17
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
            width: root.barWidth * root.shown
            height: root.barHeight
            clip: true

            Layer {
                base: root.critical ? Theme.error : Theme.primary
                textColor: root.critical ? Theme.onErrorColor : Theme.onPrimaryColor
            }
        }
    }
}
