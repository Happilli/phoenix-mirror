import QtQuick
import Ryu.Extraa
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
    readonly property var host: parent
    readonly property real avail: host?.limit ?? 352
    readonly property real labelWidth: 44
    readonly property real labelGap: 10

    signal moved

    width: Math.max(200, Math.min(avail, 360))
    height: slider.height

    MaterialSlider {
        id: slider
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: root.width - root.labelWidth - root.labelGap
        sizeStyle: MaterialSlider.Small
        outerRadius: 8
        handleGap: 3
        innerRadius: 2
        showStops: false
        showValueIndicator: true
        indicatorColor: Theme.primary
        indicatorTextColor: Theme.onPrimaryColor
        trackColor: Theme.surfaceContainerHighest
        color: Theme.primary
        handleColor: Theme.primary
        onMoved: root.moved()
    }

    Text {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: root.labelWidth
        horizontalAlignment: Text.AlignRight
        text: (root.value * root.displayScale).toFixed(root.decimals) + root.suffix
        font.pixelSize: 14
        font.weight: Font.Medium
        color: root.pressed ? Theme.primary : Theme.onSurfaceVariantColor

        Behavior on color {
            ColorAnimation {
                duration: 120
            }
        }
    }
}
