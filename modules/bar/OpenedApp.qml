pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs.services.theme

Row {
    id: root
    spacing: 2

    property var hoveredCell: null
    property real lastX: 0
    property string lastAppId: ""
    readonly property var hoverGroup: groups.find(g => g.appId === lastAppId) ?? null

    onHoveredCellChanged: if (hoveredCell) {
        lastX = hoveredCell.x;
        lastAppId = hoveredCell.modelData.appId;
    }

    readonly property var groups: {
        DesktopEntries.applications.values;
        const list = ToplevelManager.toplevels.values;
        const order = [];
        const map = {};
        for (const t of list) {
            const id = t.appId;
            if (!map[id]) {
                const name = DesktopEntries.heuristicLookup(id)?.icon ?? id.toLowerCase();
                map[id] = {
                    appId: id,
                    icon: name.startsWith("/") ? "file://" + name : Quickshell.iconPath(name, true),
                    toplevels: []
                };
                order.push(map[id]);
            }
            map[id].toplevels.push(t);
        }
        return order;
    }

    function activateGroup(group) {
        const items = group.toplevels;
        const current = items.findIndex(t => t.activated);
        items[(current + 1) % items.length].activate();
    }

    Repeater {
        model: root.groups

        delegate: Item {
            id: cell
            required property var modelData

            readonly property var instances: modelData.toplevels
            readonly property bool anyActive: instances.some(t => t.activated)

            width: 40
            height: 40

            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: Theme.background
            }

            IconImage {
                id: appIcon
                anchors.centerIn: parent
                source: cell.modelData.icon
                implicitSize: 22
                opacity: cell.anyActive ? 1 : 0.5
                Behavior on opacity {
                    NumberAnimation {
                        duration: 150
                    }
                }
            }

            Repeater {
                model: cell.instances

                delegate: Rectangle {
                    id: dot
                    required property int index

                    readonly property int total: cell.instances.length
                    readonly property real angle: (Math.PI * 2 / Math.max(total, 1)) * index + Math.PI / 2
                    readonly property real orbit: 16

                    width: 4
                    height: 4
                    radius: 2
                    color: Theme.primary
                    opacity: cell.anyActive ? 1 : 0
                    x: cell.width / 2 + Math.cos(angle) * orbit - width / 2
                    y: cell.height / 2 + Math.sin(angle) * orbit - height / 2

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 150
                        }
                    }
                }
            }

            HoverHandler {
                onHoveredChanged: {
                    if (hovered)
                        root.hoveredCell = cell;
                    else if (root.hoveredCell === cell)
                        root.hoveredCell = null;
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.activateGroup(cell.modelData)
            }
        }
    }
}
