pragma ComponentBehavior: Bound
import QtQuick
import qs.services.theme
import qs.configuration.Settings

Item {
    id: root

    property int hoveredIndex: -1
    property int pillIndex: 0

    readonly property var pages: SettingsConfig.pages
    readonly property int current: SettingsConfig.pageIndex
    readonly property real rowHeight: 48
    readonly property real step: rowHeight + 4

    function indexAt(y) {
        const i = Math.floor(y / step);
        return i >= 0 && i < pages.length && y - i * step < rowHeight ? i : -1;
    }

    Text {
        x: 28
        y: 28
        text: "Settings"
        font.pixelSize: 22
        font.weight: Font.DemiBold
        color: Theme.onBackgroundColor
    }

    Item {
        id: list
        x: 12
        y: 84
        width: parent.width - 24
        height: root.pages.length * root.step

        Rectangle {
            id: hoverPill
            width: list.width
            height: root.rowHeight
            radius: 16
            y: root.pillIndex * root.step
            color: Theme.surfaceContainerHighest
            opacity: root.hoveredIndex >= 0 ? 1 : 0
            visible: opacity > 0.01

            Behavior on opacity {
                NumberAnimation {
                    duration: 120
                }
            }

            Behavior on y {
                enabled: hoverPill.visible
                SpringAnimation {
                    spring: 5
                    damping: 0.32
                    epsilon: 0.25
                }
            }
        }

        Rectangle {
            id: selectedPill
            width: list.width
            height: root.rowHeight
            radius: 16
            y: root.current * root.step
            color: Theme.primary

            Behavior on y {
                SpringAnimation {
                    spring: 4
                    damping: 0.3
                    epsilon: 0.25
                }
            }
        }

        Repeater {
            model: root.pages

            Item {
                id: row
                required property var modelData
                required property int index

                readonly property bool selected: root.current === index

                y: index * root.step
                width: list.width
                height: root.rowHeight

                Text {
                    id: icon
                    x: 16
                    width: 20
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: row.modelData.leadingIcon
                    font.pixelSize: 18
                    color: row.selected ? Theme.onPrimaryColor : Theme.onSurfaceVariantColor
                }

                Text {
                    anchors.left: icon.right
                    anchors.leftMargin: 14
                    anchors.verticalCenter: parent.verticalCenter
                    text: row.modelData.headline
                    font.pixelSize: 15
                    font.weight: row.selected ? Font.DemiBold : Font.Medium
                    color: row.selected ? Theme.onPrimaryColor : Theme.onBackgroundColor
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: root.hoveredIndex >= 0 ? Qt.PointingHandCursor : Qt.ArrowCursor

            onPositionChanged: mouse => {
                const i = root.indexAt(mouse.y);
                root.hoveredIndex = i;
                if (i >= 0)
                    root.pillIndex = i;
            }
            onExited: root.hoveredIndex = -1
            onClicked: mouse => {
                const i = root.indexAt(mouse.y);
                if (i >= 0)
                    SettingsConfig.go(root.pages[i].key);
            }
        }
    }
}
