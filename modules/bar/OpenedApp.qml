pragma ComponentBehavior: Bound
import QtQuick
import Ryu.Desktop
import Ryu.Sway
import Ryu.Ui
import px.services.theme

Grid {
    id: root
    property bool vertical: false
    property bool notched: false
    property real pushAmount: 6
    spacing: 2
    flow: vertical ? Grid.TopToBottom : Grid.LeftToRight
    columns: vertical ? 1 : Math.max(1, groups.length)
    property var hoveredCell: null
    property real lastM: 0
    property string lastAppId: ""
    readonly property var hoverGroup: groups.find(g => g.appId === lastAppId) ?? null
    readonly property int lastIndex: groups.findIndex(g => g.appId === lastAppId)
    onHoveredCellChanged: if (hoveredCell) {
        lastM = vertical ? hoveredCell.y : hoveredCell.x;
        lastAppId = hoveredCell.modelData.appId;
    }
    readonly property var groups: {
        const apps = DesktopEntries.applications.values;
        const list = Sway.toplevels.values;
        const order = [];
        const map = {};
        for (const t of list) {
            if (!t.mapped)
                continue;
            const id = t.appId;
            if (!map[id]) {
                const entry = apps.length > 0 ? DesktopEntries.heuristicLookup(id) : null;
                const name = entry?.icon || id.toLowerCase();
                map[id] = {
                    appId: id,
                    icon: DesktopIcons.path(name),
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
        model: ScriptModel {
            values: root.groups
            objectProp: "appId"
        }
        delegate: Rectangle {
            id: cell
            required property var modelData
            required property int index
            readonly property var instances: modelData.toplevels
            readonly property bool anyActive: instances.some(t => t.activated)
            readonly property real push: {
                if (!root.notched || root.lastIndex < 0 || index === root.lastIndex)
                    return 0;
                return index < root.lastIndex ? -root.pushAmount : root.pushAmount;
            }
            width: 40
            height: 40
            radius: height / 2
            color: Theme.background
            transform: Translate {
                x: root.vertical ? 0 : cell.push
                y: root.vertical ? cell.push : 0
            }
            IconImage {
                anchors.centerIn: parent
                source: cell.modelData.icon
                implicitSize: 22
                opacity: cell.anyActive ? 1 : 0.5
            }
            Repeater {
                model: cell.instances.length
                delegate: Text {
                    id: dot
                    required property int index
                    readonly property int total: cell.instances.length
                    readonly property real orbit: 16
                    readonly property real targetAngle: (Math.PI * 2 / Math.max(total, 1)) * index + Math.PI / 2
                    readonly property real birthAngle: index > 0 ? (Math.PI * 2 / Math.max(total - 1, 1)) * (index - 1) + Math.PI / 2 : targetAngle
                    property real angle: birthAngle
                    visible: cell.anyActive
                    text: "*"
                    font.pixelSize: 10
                    font.bold: true
                    color: Theme.primary
                    x: cell.width / 2 + Math.cos(angle) * orbit - width / 2
                    y: cell.height / 2 + Math.sin(angle) * orbit - height / 2
                    Component.onCompleted: angle = Qt.binding(() => dot.targetAngle)
                    Behavior on angle {
                        NumberAnimation {
                            duration: 320
                            easing.type: Easing.OutCubic
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
