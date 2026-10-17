import QtQuick
import Ryu.Extraa
import qs.services.theme

SettingsRow {
    id: root

    property real from: 0
    property real to: 1
    property real step: 0
    property real value: 0
    property int decimals: 2
    property string unit: ""

    signal moved(real value)

    Row {
        spacing: 12

        Text {
            width: 56
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: Text.AlignRight
            text: root.value.toFixed(root.decimals) + root.unit
            font.pixelSize: 13
            font.weight: Font.DemiBold
            color: Theme.primary
        }

        MaterialSlider {
            width: 220
            sizeStyle: MaterialSlider.Medium
            from: root.from
            to: root.to
            stepSize: root.step
            value: root.value
            showStops: false
            showValueIndicator: false
            outerRadius: 12
            innerRadius: 2
            trackColor: Theme.surfaceContainerHighest
            color: Theme.primary
            handleColor: Theme.primary
            onMoved: root.moved(value)
        }
    }
}
