import QtQuick
import qs.services.theme
import qs.services.controls

Rectangle {
    id: root

    readonly property var erm: {
        switch (OsdService.key) {
        case "volume":
            {
                const v = AudioService.volume;
                const off = AudioService.muted || v <= 0;
                return {
                    value: AudioService.muted ? 0 : v,
                    icon: off ? "\uf026" : v < 0.5 ? "\uf027" : "\uf028"
                };
            }
        case "mic":
            {
                const m = AudioService.micMuted;
                return {
                    value: m ? 0 : AudioService.micVolume,
                    icon: m ? "\uf131" : "\uf130"
                };
            }
        default:
            return {
                value: BrightnessService.brightness,
                icon: "\udb80\udce0"
            };
        }
    }

    readonly property real value: Math.max(0, Math.min(1, erm.value))

    width: 300
    height: 56
    radius: height / 2
    color: Theme.background
    opacity: OsdService.shown ? 1 : 0
    visible: opacity > 0.01

    Behavior on opacity {
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutCubic
        }
    }

    Row {
        anchors.centerIn: parent
        spacing: 14

        Text {
            width: 24
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: Text.AlignHCenter
            text: root.erm.icon
            font.pixelSize: 20
            font.bold: true
            color: Theme.onSurfaceVariantColor
        }

        Rectangle {
            width: 160
            height: 10
            radius: height / 2
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.surfaceContainerHighest

            Rectangle {
                width: parent.width * root.value
                height: parent.height
                radius: parent.radius
                color: Theme.primary

                Behavior on width {
                    NumberAnimation {
                        duration: 80
                    }
                }
            }
        }

        Text {
            width: 40
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: Text.AlignRight
            text: Math.round(root.value * 100)
            font.pixelSize: 17
            font.bold: true
            color: Theme.primary
        }
    }
}
