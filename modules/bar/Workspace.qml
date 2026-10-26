pragma ComponentBehavior: Bound
import QtQuick
import qs.services.theme
import Quickshell.Hyprland

Item {
    id: root

    required property var screen
    property bool vertical: false

    readonly property int count: 10
    readonly property int activeId: Hyprland.monitorFor(screen)?.activeWorkspace?.id ?? 1
    readonly property var occupied: new Set(Hyprland.workspaces.values.map(w => w.id))

    implicitWidth: vertical ? strip.implicitHeight : strip.implicitWidth
    implicitHeight: vertical ? strip.implicitWidth : strip.implicitHeight

    function go(i) {
        Hyprland.dispatch(`hl.dsp.focus({workspace = ${i}})`);
    }

    Row {
        id: strip
        spacing: 5
        rotation: root.vertical ? 90 : 0
        transformOrigin: Item.TopLeft
        x: root.vertical ? strip.implicitHeight : 0

        Repeater {
            model: root.count
            Rectangle {
                id: pill
                required property int index

                readonly property int wsId: index + 1
                readonly property bool active: wsId === root.activeId
                readonly property bool filled: root.occupied.has(wsId)

                width: active ? 45 : 10
                height: 10
                radius: height / 2
                color: filled ? Theme.primary : Theme.onBackgroundColor

                Behavior on width {
                    SpringAnimation {
                        spring: 3
                        damping: 0.25
                        epsilon: 0.25
                    }
                }
                Behavior on color {
                    ColorAnimation {
                        duration: 200
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: root.go(pill.wsId)
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }
    }
}
