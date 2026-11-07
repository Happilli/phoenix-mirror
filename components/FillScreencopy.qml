import QtQuick
import Quickshell.Wayland

ScreencopyView {
    readonly property real sw: implicitWidth > 0 ? implicitWidth : 16
    readonly property real sh: implicitHeight > 0 ? implicitHeight : 10
    readonly property real fill: Math.max(parent.width / sw, parent.height / sh)

    anchors.centerIn: parent
    width: sw * fill
    height: sh * fill
}
