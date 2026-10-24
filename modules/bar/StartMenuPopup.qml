pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.services.theme

Item {
    id: root

    required property bool active

    readonly property int listWidth: 300
    readonly property int listHeight: 480
    readonly property int rowHeight: 44
    readonly property int headerHeight: 36

    property int hovered: -1

    readonly property var allApps: {
        const list = DesktopEntries.applications.values.filter(e => !e.noDisplay);
        return list.slice().sort((a, b) => a.name.localeCompare(b.name));
    }

    readonly property var items: {
        const out = [];
        let last = "";
        for (const e of allApps) {
            const c = e.name.charAt(0).toUpperCase();
            const letter = /[A-Z]/.test(c) ? c : "#";
            if (letter !== last) {
                out.push({
                    header: true,
                    label: letter
                });
                last = letter;
            }
            out.push({
                header: false,
                entry: e
            });
        }
        return out;
    }

    function iconOf(entry) {
        const name = entry.icon ?? "";
        if (name.startsWith("/"))
            return "file://" + name;
        return Quickshell.iconPath(name, "application-x-executable");
    }

    function launch(entry) {
        if (entry.runInTerminal)
            Quickshell.execDetached(["kitty", "-e"].concat(Array.from(entry.command)));
        else
            entry.execute();
    }

    onActiveChanged: if (!active) {
        hovered = -1;
        list.positionViewAtBeginning();
    }

    implicitWidth: listWidth
    implicitHeight: listHeight
    visible: active

    ListView {
        id: list
        anchors.fill: parent
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        keyNavigationEnabled: false
        highlightFollowsCurrentItem: false
        currentIndex: -1
        model: root.items

        highlight: Rectangle {
            id: pill

            x: 2
            y: list.currentItem ? list.currentItem.y + 2 : 0
            width: list.width - 4
            height: list.currentItem ? list.currentItem.height - 4 : 0
            radius: 12
            color: Theme.surfaceContainerHighest
            opacity: root.hovered >= 0 && list.currentItem !== null ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 120
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

            Behavior on height {
                enabled: pill.opacity > 0.01
                SpringAnimation {
                    spring: 5
                    damping: 0.32
                    epsilon: 0.25
                }
            }
        }

        delegate: Item {
            id: row
            required property var modelData
            required property int index

            readonly property bool isHeader: modelData.header === true
            readonly property bool selected: root.hovered === index

            width: list.width
            height: isHeader ? root.headerHeight : root.rowHeight

            HoverHandler {
                enabled: !row.isHeader
                onHoveredChanged: {
                    if (hovered) {
                        root.hovered = row.index;
                        list.currentIndex = row.index;
                    } else if (root.hovered === row.index) {
                        root.hovered = -1;
                    }
                }
            }

            Text {
                visible: row.isHeader
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                text: row.isHeader ? row.modelData.label : ""
                font.pixelSize: 13
                font.weight: Font.DemiBold
                color: Theme.primary
            }

            IconImage {
                id: icon
                visible: !row.isHeader
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                implicitSize: 28
                source: row.isHeader ? "" : root.iconOf(row.modelData.entry)
            }

            Text {
                visible: !row.isHeader
                anchors.left: icon.right
                anchors.leftMargin: 14
                anchors.right: parent.right
                anchors.rightMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                text: row.isHeader ? "" : row.modelData.entry.name
                elide: Text.ElideRight
                font.pixelSize: 13
                font.weight: Font.Medium
                color: row.selected ? Theme.primary : Theme.onSurfaceVariantColor
            }

            MouseArea {
                anchors.fill: parent
                enabled: !row.isHeader
                hoverEnabled: true
                cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: root.launch(row.modelData.entry)
            }
        }
    }
}
