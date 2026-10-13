pragma ComponentBehavior: Bound
import QtQuick
import qs.services.theme
import Quickshell.Hyprland

Rectangle {
    id: root

    required property var screen

    readonly property int count: 10
    readonly property int activeId: Hyprland.monitorFor(screen)?.activeWorkspace?.id ?? 1
    readonly property var occupied: new Set(Hyprland.workspaces.values.map(w => w.id))

    color: Theme.background
    radius: height / 2
    implicitHeight: 40
    implicitWidth: row.implicitWidth + 24

    function go(i) {
        Hyprland.dispatch(`hl.dsp.focus({workspace = ${i}})`);
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 5

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
