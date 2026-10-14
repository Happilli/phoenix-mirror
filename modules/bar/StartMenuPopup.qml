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
    readonly property int cellH: 52
    readonly property int gap: 8
    readonly property int controlHeight: 56

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

    onActiveChanged: if (!active)
        search.clear()

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

                delegate: Item {
                    id: cell
                    required property var modelData

                    width: grid.cellWidth
                    height: grid.cellHeight

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 2
                        radius: 14
                        color: area.containsMouse ? Theme.surfaceContainerHighest : "transparent"
                    }

                    IconImage {
                        id: icon
                        anchors.left: parent.left
                        anchors.leftMargin: 14
                        anchors.verticalCenter: parent.verticalCenter
                        implicitSize: 32
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
                        color: area.containsMouse ? Theme.primary : Theme.onSurfaceVariantColor
                    }

                    MouseArea {
                        id: area
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: cell.modelData.execute()
                    }
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

        Row {
            spacing: root.gap

            MaterialSearchBox {
                id: search
                width: root.implicitWidth - lock.width - root.gap
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
                type: MaterialIconButton.Tonal
                shape: MaterialIconButton.Round
                sizeStyle: MaterialIconButton.Medium
                iconText: "\uf023"
                iconSize: 22
                color: Theme.surfaceContainerHighest
                iconColor: Theme.onSurfaceVariantColor
                springStiffness: 650
                springDamping: 0.3
                onClicked: LockConfig.requestLock()
            }
        }
    }
}
