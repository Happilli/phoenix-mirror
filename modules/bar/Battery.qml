pragma ComponentBehavior: Bound
import QtQuick
import qs.services.theme
import Quickshell.Services.UPower

Item {
    id: root
    readonly property var device: UPower.displayDevice
    readonly property real level: Math.max(0, Math.min(1, device.percentage))
    property real shown: level
    readonly property bool charging: device.state === UPowerDeviceState.Charging || device.state === UPowerDeviceState.FullyCharged
    readonly property bool critical: !charging && level <= 0.5
    width: 45
    height: 25

    Behavior on shown {
        NumberAnimation {
            duration: 200
            easing.type: Easing.InOutQuad
        }
    }

    component Layer: Item {
        id: layer
        property color base
        property color textColor

        width: root.width
        height: root.height

        Rectangle {
            width: root.width
            height: root.height
            radius: height / 2
            color: layer.base
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
                color: layer.textColor
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: Math.round(root.level * 100)
                font.pixelSize: 17
                font.bold: true
                color: layer.textColor
            }
        }
    }

    Layer {
        base: Theme.surfaceContainerHighest
        textColor: Theme.onSurfaceVariant
    }

    Item {
        width: root.width * root.shown
        height: root.height
        clip: true

        Layer {
            base: root.critical ? Theme.error : Theme.primary
            textColor: root.critical ? Theme.onError : Theme.onPrimary
        }
    }
}
