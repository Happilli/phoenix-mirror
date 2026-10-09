pragma ComponentBehavior: Bound
import QtQuick
import qs.services.theme
import Ryu.Extraa

Rectangle {
    id: root
    color: Theme.onBackground
    implicitWidth: 150
    implicitHeight: 44
    radius: height / 2

    readonly property var controls: [
        {
            value: 1,
            icon: "\uf027"
        },
        {
            value: 0.5,
            icon: "\udb80\udce0"
        },
        {
            value: 0.8,
            icon: "\uf130"
        }
    ]

    readonly property bool open: pillHover.hovered || popupHover.hovered
    property alias popupItem: panel
    readonly property int gap: 8
    readonly property int sliderLength: 400
    readonly property int itemWidth: 50
    readonly property int trackWidth: 42

    Item {
        id: panel
        width: root.open ? card.width : 0
        height: root.open ? card.height + root.y - 7 : 0

        y: -height
        x: Math.round((root.width - width) / 2)
        visible: root.open

        HoverHandler {
            id: popupHover
        }

        Rectangle {
            id: card
            width: sliders.implicitWidth + (root.gap * 2 - (root.itemWidth - root.trackWidth)) * 2
            height: sliders.implicitHeight + root.gap * 2
            radius: root.gap + 12
            color: Theme.background

            Row {
                id: sliders
                anchors.centerIn: parent
                spacing: -(root.itemWidth - root.trackWidth - root.gap)
                Repeater {
                    model: root.controls
                    MaterialSlider {
                        required property var modelData
                        orientation: MaterialSlider.Vertical
                        sizeStyle: MaterialSlider.Medium
                        value: modelData.value
                        showStops: false
                        showValueIndicator: false
                        outerRadius: 12
                        innerRadius: 2
                        trackColor: Theme.surfaceContainerHighest
                        color: Theme.primary
                        handleColor: Theme.primary

                        Component.onCompleted: {
                            width = root.itemWidth;
                            height = root.sliderLength;
                        }
                    }
                }
            }
        }
    }
    HoverHandler {
        id: pillHover
    }

    Row {
        anchors.centerIn: parent
        Repeater {
            model: root.controls
            Item {
                id: cell
                width: 50
                height: root.height
                required property var modelData
                WavyProgress {
                    anchors.centerIn: parent
                    anchors.verticalCenter: parent.verticalCenter
                    style: WavyProgress.Circular
                    amplitude: 0
                    strokeWidth: 3
                    trackColor: Theme.surfaceContainerHighest
                    color: Theme.primary
                    progress: cell.modelData.value
                    indeterminate: false
                    width: 32
                    height: 32
                }
                Text {
                    anchors.centerIn: parent
                    text: cell.modelData.icon
                    color: Theme.onSurfaceVariant
                    font.bold: true
                    font.pixelSize: 17
                }
            }
        }
    }
}
