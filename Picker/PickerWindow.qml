pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Ryu.Extraa
import qs.services.theme
import qs.configuration.Picker
import qs.configuration.Bar
import qs.components.metal

Scope {
    component PickGrid: GridView {
        id: grid

        property var items: []
        property bool shown: false
        property var lookup: null
        property int hoveredIndex: -1

        readonly property real inset: 6
        readonly property real labelHeight: 28

        clip: true
        visible: shown
        cellWidth: Math.floor(width / 2)
        cellHeight: Math.round((cellWidth - 12) * 9 / 16) + 40
        boundsBehavior: Flickable.StopAtBounds
        keyNavigationEnabled: false
        highlightFollowsCurrentItem: false
        currentIndex: -1
        model: items

        onShownChanged: {
            hoveredIndex = -1;
            currentIndex = -1;
        }

        highlight: Rectangle {
            id: pill

            readonly property bool tracking: grid.hoveredIndex >= 0 && grid.currentItem !== null

            z: 2
            x: grid.currentItem ? grid.currentItem.x + grid.inset : 0
            y: grid.currentItem ? grid.currentItem.y + grid.inset : 0
            width: grid.cellWidth - grid.inset * 2
            height: grid.cellHeight - grid.inset * 2 - grid.labelHeight
            color: "transparent"
            border.width: 2
            border.color: Theme.primary
            opacity: tracking ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 120
                }
            }

            Behavior on x {
                enabled: pill.opacity > 0.01
                SpringAnimation {
                    spring: 5
                    damping: 0.32
                    epsilon: 0.25
                }
            }

            Behavior on y {
                enabled: pill.opacity > 0.01
                SpringAnimation {
                    spring: 5
                    damping: 0.32
                    epsilon: 0.25
                }
            }
        }

        delegate: Item {
            id: cell
            required property var modelData
            required property int index

            readonly property bool hovered: grid.hoveredIndex === index

            width: grid.cellWidth
            height: grid.cellHeight

            HoverHandler {
                onHoveredChanged: {
                    if (hovered) {
                        grid.hoveredIndex = cell.index;
                        grid.currentIndex = cell.index;
                    } else if (grid.hoveredIndex === cell.index) {
                        grid.hoveredIndex = -1;
                    }
                }
            }

            Item {
                anchors.fill: parent
                anchors.margins: grid.inset

                Rectangle {
                    id: card
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    height: parent.height - grid.labelHeight
                    color: Theme.surfaceContainerHighest
                    clip: true

                    Metal {
                        anchors.fill: parent
                        kind: "soft"
                    }

                    ScreencopyView {
                        id: sc
                        readonly property real sw: implicitWidth > 0 ? implicitWidth : 16
                        readonly property real sh: implicitHeight > 0 ? implicitHeight : 10
                        readonly property real fill: Math.max(card.width / sw, card.height / sh)

                        anchors.centerIn: parent
                        width: sw * fill
                        height: sh * fill
                        live: PickerConfig.open && grid.shown
                        captureSource: cell.modelData.kind === "screen" ? cell.modelData.screen : grid.lookup(cell.modelData.addr)
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: !sc.hasContent
                        text: "No preview"
                        font.pixelSize: 12
                        color: Theme.onSurfaceVariantColor
                        opacity: 0.6
                    }

                    Metal {
                        anchors.fill: parent
                        kind: "rim"
                    }
                }

                Text {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: card.bottom
                    anchors.topMargin: 6
                    horizontalAlignment: Text.AlignHCenter
                    text: cell.modelData.label
                    elide: Text.ElideRight
                    font.pixelSize: 12
                    color: cell.hovered ? Theme.primary : Theme.onBackgroundColor
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: PickerConfig.pick(cell.modelData.kind, cell.modelData.target)
                }
            }
        }
    }

    FloatingWindow {
        id: win

        function toplevelFor(addr) {
            if (addr === "")
                return null;
            const n = Number(addr);
            const hex = isNaN(n) ? addr.toLowerCase().replace(/^0x/, "") : n.toString(16);
            for (const t of Hyprland.toplevels.values) {
                if (t.address.toLowerCase().replace(/^0x/, "") === hex)
                    return t.wayland;
            }
            return null;
        }

        title: "Share"
        color: Theme.background
        implicitWidth: 760
        implicitHeight: 560
        minimumSize: Qt.size(implicitWidth, implicitHeight)
        maximumSize: Qt.size(implicitWidth, implicitHeight)
        visible: PickerConfig.open && !PickerConfig.regioning

        onVisibleChanged: {
            if (visible)
                Hyprland.refreshToplevels();
            else if (!PickerConfig.regioning)
                PickerConfig.cancel();
        }

        Shortcut {
            sequence: "Escape"
            enabled: PickerConfig.open
            onActivated: PickerConfig.cancel()
        }

        Metal {
            anchors.fill: parent
            kind: "backdrop"
        }

        Loader {
            anchors.fill: parent
            active: PickerConfig.open

            sourceComponent: Column {
                id: layout
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                MaterialSegmentedButton {
                    id: tabs
                    labels: ["Screen", "Window", "Region"]
                    currentIndex: PickerConfig.tab
                    selectionMode: MaterialSegmentedButton.Single
                    color: "transparent"
                    checkedColor: Theme.secondaryContainer
                    textColor: Theme.onSurfaceVariantColor
                    checkedTextColor: Theme.onSecondaryContainerColor
                    borderColor: Theme.outline

                    onToggled: (index, checked) => {
                        if (checked)
                            PickerConfig.tab = index;
                    }
                }

                Item {
                    width: parent.width
                    height: layout.height - tabs.height - restoreBox.height - layout.spacing * 2

                    PickGrid {
                        anchors.fill: parent
                        items: PickerConfig.screenItems
                        shown: PickerConfig.tab === 0
                        lookup: win.toplevelFor
                    }

                    PickGrid {
                        anchors.fill: parent
                        items: PickerConfig.windowItems
                        shown: PickerConfig.tab === 1
                        lookup: win.toplevelFor
                    }
                    Item {
                        anchors.fill: parent
                        visible: PickerConfig.tab === 2

                        Column {
                            anchors.centerIn: parent
                            spacing: 16

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "Drag over any part of the screen to share it"
                                font.pixelSize: 14
                                color: Theme.onSurfaceVariantColor
                            }

                            Rectangle {
                                id: selectBtn
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: 180
                                height: 44
                                radius: 22
                                color: Theme.primary
                                scale: pick.pressed ? 0.94 : 1

                                Behavior on scale {
                                    SpringAnimation {
                                        spring: 5
                                        damping: 0.4
                                        epsilon: 0.005
                                    }
                                }

                                Metal {
                                    anchors.fill: parent
                                    kind: "gloss"
                                    radius: selectBtn.radius
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: "Select region"
                                    font.pixelSize: 14
                                    font.weight: Font.DemiBold
                                    color: Theme.onPrimaryColor
                                }

                                MouseArea {
                                    id: pick
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: PickerConfig.startRegion()
                                }
                            }
                        }
                    }
                }

                MaterialCheckbox {
                    id: restoreBox
                    text: "Allow a restore token"
                    checked: PickerConfig.token
                    color: Theme.primary
                    uncheckedColor: Theme.onSurfaceVariantColor
                    checkmarkColor: Theme.onPrimaryColor
                    textColor: Theme.onBackgroundColor
                    errorColor: Theme.error
                    onToggled: PickerConfig.token = checked
                }
            }
        }
    }
}
