pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs.components
import Quickshell.Wayland
import qs.services.theme
import qs.configuration.Picker

Item {
    id: mini

    property string wsName: ""

    readonly property var g: PickerConfig.groupMap[wsName] ?? null
    readonly property real mx: g?.mx ?? 0
    readonly property real my: g?.my ?? 0
    readonly property real mw: g?.mw ?? 1920
    readonly property real mh: g?.mh ?? 1080
    readonly property real k: width > 0 && mw > 0 ? width / mw : 0

    Rectangle {
        id: frame
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: mini.mh * mini.k
        color: Theme.background
        border.width: 2
        border.color: Theme.outlineVariant
        clip: true

        Repeater {
            model: ScriptModel {
                values: mini.g ? mini.g.wins.map(w => w.key) : []
            }

            Rectangle {
                id: box
                required property string modelData

                readonly property var win: mini.g?.wins.find(w => w.key === modelData) ?? null
                readonly property bool alive: win !== null && mini.visible && PickerConfig.open

                visible: win !== null
                x: win ? (win.x - mini.mx) * mini.k : 0
                y: win ? (win.y - mini.my) * mini.k : 0
                width: win ? Math.max(4, win.w * mini.k) : 0
                height: win ? Math.max(4, win.h * mini.k) : 0
                z: win?.floating ? 1 : 0
                color: Theme.surfaceContainerHigh
                clip: true
                FillScreencopy {
                    opacity: hasContent ? 1 : 0
                    captureSource: box.alive ? box.win.top.wayland : null
                    live: box.alive
                }
            }
        }
    }

    Text {
        anchors.centerIn: parent
        visible: !mini.g || mini.g.wins.length === 0
        text: "Empty"
        font.pixelSize: 12
        color: Theme.onSurfaceVariantColor
        opacity: 0.6
    }
}
