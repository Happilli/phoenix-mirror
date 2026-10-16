pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Widgets
import Ryu.Extraa
import qs.services.theme
import qs.configuration.Lock

Item {
    id: root

    required property bool active

    readonly property int columns: 2
    readonly property int maxRows: 7
    readonly property int cellW: 220
    readonly property int cellH: 48
    readonly property int gap: 8
    readonly property real searchScale: 0.8
    readonly property real controlHeight: Math.round(search.height * searchScale)

    property int hovered: -1
    property int shownIndex: 0

    readonly property bool searching: search.activeFocus

    readonly property var allApps: {
        const list = DesktopEntries.applications.values.filter(e => !e.noDisplay);
        return list.slice().sort((a, b) => a.name.localeCompare(b.name));
    }

    readonly property string query: search.text.trim().toLowerCase()

    readonly property var apps: query === "" ? allApps : allApps.filter(e => e.name.toLowerCase().includes(query))

    readonly property int rows: Math.max(1, Math.min(maxRows, Math.ceil(apps.length / columns)))

    function iconOf(entry) {
        const name = entry.icon ?? "";
        if (name.startsWith("/"))
            return "file://" + name;
        return Quickshell.iconPath(name, "application-x-executable");
    }

    function launchFirst() {
        if (apps.length > 0)
            apps[0].execute();
    }

    onHoveredChanged: if (hovered >= 0)
        shownIndex = hovered

    onAppsChanged: hovered = -1

    onActiveChanged: if (!active) {
        search.clear();
        hovered = -1;
    }

    implicitWidth: columns * cellW
    implicitHeight: column.implicitHeight
    visible: active

    Column {
        id: column
        spacing: root.gap

        Item {
            width: root.columns * root.cellW
            height: root.rows * root.cellH

            GridView {
                id: grid
                anchors.fill: parent
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                cellWidth: root.cellW
                cellHeight: root.cellH
                model: root.apps

                Rectangle {
                    id: pill
                    z: -1
                    x: (root.shownIndex % root.columns) * root.cellW + 2
                    y: Math.floor(root.shownIndex / root.columns) * root.cellH + 2
                    width: root.cellW - 4
                    height: root.cellH - 4
                    radius: 14
                    color: Theme.surfaceContainerHighest
                    opacity: root.hovered >= 0 && root.hovered < root.apps.length ? 1 : 0

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

                    readonly property bool selected: root.hovered === index

                    width: grid.cellWidth
                    height: grid.cellHeight

                    IconImage {
                        id: icon
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        implicitSize: 30
                        source: root.iconOf(cell.modelData)
                    }

                    Text {
                        anchors.left: icon.right
                        anchors.leftMargin: 12
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: cell.modelData.name
                        elide: Text.ElideRight
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        color: cell.selected ? Theme.primary : Theme.onSurfaceVariantColor
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                function indexAtMouse(m) {
                    const i = grid.indexAt(m.x + grid.contentX, m.y + grid.contentY);
                    return i >= 0 && i < root.apps.length ? i : -1;
                }

                onPositionChanged: m => root.hovered = indexAtMouse(m)
                onExited: root.hovered = -1
                onClicked: m => {
                    const i = indexAtMouse(m);
                    if (i >= 0)
                        root.apps[i].execute();
                }
            }

            Text {
                anchors.centerIn: parent
                visible: root.apps.length === 0
                text: "No apps found"
                font.pixelSize: 13
                color: Theme.onSurfaceVariantColor
                opacity: 0.7
            }
        }

        Item {
            id: controls
            width: root.columns * root.cellW
            height: root.controlHeight

            MaterialSearchBox {
                id: search
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: (controls.width - root.controlHeight - root.gap) / root.searchScale
                scale: root.searchScale
                transformOrigin: Item.Left
                placeholderText: "Search apps"
                color: Theme.surfaceContainerHighest
                textColor: Theme.onSurfaceVariantColor
                placeholderColor: Theme.onSurfaceVariantColor
                iconColor: Theme.onSurfaceVariantColor
                cursorColor: Theme.primary
                borderWidth: 2
                borderColor: "transparent"
                selectionColor: Qt.alpha(Theme.primary, 0.3)
                springStiffness: 650
                springDamping: 0.3
                onAccepted: root.launchFirst()
                Keys.onEscapePressed: root.forceActiveFocus()
            }

            MaterialIconButton {
                id: lock
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: root.controlHeight
                height: root.controlHeight
                type: MaterialIconButton.Tonal
                shape: MaterialIconButton.Round
                iconText: "\uf023"
                iconSize: Math.round(root.controlHeight * 0.45)
                color: Theme.surfaceContainerHighest
                iconColor: Theme.onSurfaceVariantColor
                springStiffness: 650
                springDamping: 0.3
                onClicked: LockConfig.requestLock()
            }
        }
    }
}
