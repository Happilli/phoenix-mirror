import QtQuick
import qs.services.theme

Item {
    id: root

    property alias from: slider.from
    property alias to: slider.to
    property alias value: slider.value
    property alias stepSize: slider.stepSize
    property alias showStops: slider.showStops
    property real displayScale: 1
    property int decimals: 0
    property string suffix: ""

    readonly property bool pressed: slider.pressed
    readonly property real avail: parent?.limit ?? 352
    readonly property real labelWidth: 44
    readonly property real labelGap: 8

    signal moved

    width: Math.max(190, Math.min(avail, 352))
    height: slider.height

    SettingsSlider {
        id: slider
        anchors.verticalCenter: parent.verticalCenter
        width: root.width - root.labelWidth - root.labelGap
        showValueIndicator: false
        onMoved: root.moved()
    }

    Text {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: root.labelWidth
        horizontalAlignment: Text.AlignRight
        text: (root.value * root.displayScale).toFixed(root.decimals) + root.suffix
        font.pixelSize: 13
        font.weight: Font.DemiBold
        color: root.pressed ? Theme.primary : Theme.onSurfaceVariantColor

        Behavior on color {
            ColorAnimation {
                duration: 120
            }
        }
    }
}
