import QtQuick
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell

Row {
    id: root
    spacing: 2
    Repeater {
        model: ToplevelManager.toplevels
        Item {
            required property var modelData
            readonly property bool focused: modelData.activated
            readonly property string iconSource: {
                DesktopEntries.applications.values;
                const name = DesktopEntries.heuristicLookup(modelData.appId)?.icon ?? modelData.appId.toLowerCase();
                return name.startsWith("/") ? "file://" + name : Quickshell.iconPath(name, true);
            }
            width: 32
            height: 32

            IconImage {
                anchors.centerIn: parent
                source: parent.iconSource
                implicitSize: 24
                opacity: parent.focused ? 1 : 0.5
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: parent.modelData.activate()
            }
        }
    }
}
