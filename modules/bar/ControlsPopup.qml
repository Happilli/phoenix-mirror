pragma ComponentBehavior: Bound
import QtQuick
import Ryu.Extraa
import qs.services.theme

Item {
    id: root

    required property var pill
    required property bool active

    readonly property int itemWidth: 50
    readonly property int trackWidth: 42
    readonly property int sliderLength: 400
    readonly property int sliderGap: 8

    anchors.centerIn: parent
    implicitWidth: sliders.implicitWidth - (itemWidth - trackWidth)
    implicitHeight: sliders.implicitHeight
    visible: active
    Row {
        id: sliders
        anchors.centerIn: parent
        spacing: -(root.itemWidth - root.trackWidth - root.sliderGap)
        Repeater {
            model: root.pill.controls
            MaterialSlider {
                required property var modelData
                orientation: MaterialSlider.Vertical
                sizeStyle: MaterialSlider.Medium
                value: root.pill.valueOf(modelData)
                showStops: false
                showValueIndicator: false
                outerRadius: 12
                innerRadius: 2
                trackColor: Theme.surfaceContainerHighest
                color: Theme.primary
                handleColor: Theme.primary

                onValueChanged: {
                    if (Math.abs(value - root.pill.valueOf(modelData)) > 0.005) {
                        root.pill.setValue(modelData, value);
                    }
                }

                Component.onCompleted: {
                    width = root.itemWidth;
                    height = root.sliderLength;
                }
            }
        }
    }
}
