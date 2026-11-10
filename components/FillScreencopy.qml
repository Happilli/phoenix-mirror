import QtQuick
import Ryu.Wayland

ScreencopyView {
    id: root

    readonly property real sw: root.implicitWidth > 0 ? root.implicitWidth : 16
    readonly property real sh: root.implicitHeight > 0 ? root.implicitHeight : 10
    readonly property real pw: root.parent ? root.parent.width : 0
    readonly property real ph: root.parent ? root.parent.height : 0
    readonly property real fill: Math.max(root.pw / root.sw, root.ph / root.sh)

    maxFps: 30
    width: Math.round(root.sw * root.fill)
    height: Math.round(root.sh * root.fill)
    x: Math.round((root.pw - root.width) / 2)
    y: Math.round((root.ph - root.height) / 2)
}
