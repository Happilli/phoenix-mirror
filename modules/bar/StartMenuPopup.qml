pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.services.theme

Item {
    id: root

    required property bool active

    readonly property var items: {
        const apps = DesktopEntries.applications.values.filter(e => !e.noDisplay).sort((a, b) => a.name.localeCompare(b.name));
        const out = [];
        let last = "";
        for (const e of apps) {
            const c = e.name.charAt(0).toUpperCase();
            const letter = /[A-Z]/.test(c) ? c : "#";
            if (letter !== last) {
                out.push({
                    key: "#" + letter,
                    header: true,
                    label: letter
                });
                last = letter;
            }
            out.push({
                key: e.id,
                header: false,
                entry: e
            });
        }
        return out;
    }

    implicitWidth: 300
    implicitHeight: 480
    visible: active

    onActiveChanged: if (!active) {
        list.positionViewAtBeginning();
        list.targetY = list.originY;
    }

    ListView {
        id: list
        anchors.fill: parent
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        cacheBuffer: 400

        property real targetY: 0

        Behavior on contentY {
            enabled: !list.dragging && !list.flicking
            SpringAnimation {
                spring: 3.2
                damping: 0.32
                mass: 0.9
                epsilon: 0.25
            }
        }

        onMovementStarted: targetY = contentY
        onMovementEnded: targetY = contentY

        WheelHandler {
            target: null
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            onWheel: event => {
                const delta = event.pixelDelta.y !== 0 ? event.pixelDelta.y * 1.4 : event.angleDelta.y * 0.9;
                const maxY = Math.max(list.originY, list.originY + list.contentHeight - list.height);
                list.targetY = Math.max(list.originY, Math.min(maxY, list.targetY - delta));
                list.contentY = list.targetY;
            }
        }

        model: ScriptModel {
            values: root.items
            objectProp: "key"
        }

        delegate: Item {
            id: row
            required property var modelData

            readonly property bool header: modelData.header
            readonly property var entry: modelData.entry

            width: list.width
            height: header ? 36 : 44

            Text {
                visible: row.header
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                text: row.modelData.label ?? ""
                font.pixelSize: 13
                font.weight: Font.DemiBold
                color: Theme.primary
            }

            Item {
                anchors.fill: parent
                visible: !row.header

                Rectangle {
                    id: pill
                    anchors.fill: parent
                    anchors.margins: 2
                    radius: 12
                    color: area.containsMouse ? Theme.surfaceContainerHighest : Qt.alpha(Theme.surfaceContainerHighest, 0)
                    scale: area.pressed ? 0.96 : 1.0

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                            easing.type: Easing.OutCubic
                        }
                    }

                    Behavior on scale {
                        SpringAnimation {
                            spring: 5
                            damping: 0.4
                            epsilon: 0.005
                        }
                    }
                }

                IconImage {
                    id: icon
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter
                    implicitSize: 28
                    source: {
                        const n = row.entry?.icon ?? "";
                        return n.startsWith("/") ? "file://" + n : Quickshell.iconPath(n, "application-x-executable");
                    }
                }

                Text {
                    anchors.left: icon.right
                    anchors.leftMargin: 14
                    anchors.right: parent.right
                    anchors.rightMargin: 14
                    anchors.verticalCenter: parent.verticalCenter
                    text: row.entry?.name ?? ""
                    elide: Text.ElideRight
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    color: area.containsMouse ? Theme.primary : Theme.onSurfaceVariantColor
                }

                MouseArea {
                    id: area
                    anchors.fill: pill
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: row.entry.runInTerminal ? Quickshell.execDetached(["kitty", "-e"].concat(Array.from(row.entry.command))) : row.entry.execute()
                }
            }
        }
    }
}
