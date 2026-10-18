pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import qs.services.theme

Item {
    id: root

    required property bool active
    required property var group
    property real maxWidth: 800

    readonly property real spacing: 10
    readonly property real maxMiniW: 340
    readonly property string appId: group ? group.appId : ""

    function refresh() {
        Hyprland.refreshMonitors();
        Hyprland.refreshWorkspaces();
        Hyprland.refreshToplevels();
    }

    readonly property var miniatures: {
        const all = Hyprland.toplevels.values;
        const mons = Hyprland.monitors.values;
        const byWs = {};

        for (const t of all) {
            const o = t.lastIpcObject;
            if (!o || !o.at || !o.size || o.mapped === false)
                continue;
            const wsId = o.workspace ? o.workspace.id : 0;
            const cls = t.wayland ? t.wayland.appId : o.class;
            if (!byWs[wsId])
                byWs[wsId] = {
                    id: wsId,
                    wins: [],
                    hasMine: false,
                    monitorId: o.monitor
                };
            byWs[wsId].wins.push({
                top: t,
                x: o.at[0],
                y: o.at[1],
                w: o.size[0],
                h: o.size[1],
                floating: o.floating === true,
                mine: cls === root.appId
            });
            if (cls === root.appId)
                byWs[wsId].hasMine = true;
        }

        const out = [];
        for (const k in byWs) {
            const ws = byWs[k];
            if (!ws.hasMine)
                continue;
            const mon = mons.find(m => m.id === ws.monitorId);
            const mo = mon ? mon.lastIpcObject : null;
            const scale = mo && mo.scale ? mo.scale : 1;
            const rs = mo && mo.reserved ? mo.reserved : [0, 0, 0, 0];
            ws.mx = (mo && mo.x !== undefined ? mo.x : 0) + rs[0];
            ws.my = (mo && mo.y !== undefined ? mo.y : 0) + rs[1];
            ws.mw = (mo && mo.width ? mo.width / scale : 1920) - rs[0] - rs[2];
            ws.mh = (mo && mo.height ? mo.height / scale : 1080) - rs[1] - rs[3];
            out.push(ws);
        }
        out.sort((a, b) => a.id - b.id);
        return out;
    }

    readonly property int count: miniatures.length
    readonly property real miniW: count > 0 ? Math.min(maxMiniW, (maxWidth - spacing * (count - 1)) / count) : maxMiniW
    readonly property real miniH: {
        let h = 0;
        for (const m of miniatures)
            h = Math.max(h, m.mh * (miniW / m.mw));
        return h;
    }

    onActiveChanged: if (active)
        refresh()
    Component.onCompleted: refresh()

    anchors.centerIn: parent
    implicitWidth: count > 0 ? count * miniW + (count - 1) * spacing : 0
    implicitHeight: miniH
    visible: active

    Repeater {
        model: root.miniatures

        delegate: Item {
            id: mini
            required property var modelData
            required property int index

            readonly property real s: root.miniW / modelData.mw
            clip: true
            x: index * (root.miniW + root.spacing)
            y: 0
            width: root.miniW
            height: modelData.mh * s

            Repeater {
                model: mini.modelData.wins

                delegate: ClippingRectangle {
                    id: win
                    required property var modelData

                    x: (modelData.x - mini.modelData.mx) * mini.s
                    y: (modelData.y - mini.modelData.my) * mini.s
                    width: Math.max(4, modelData.w * mini.s)
                    height: Math.max(4, modelData.h * mini.s)
                    color: Theme.background
                    opacity: modelData.mine ? 1 : 0.55
                    z: modelData.floating ? 1 : 0
                    border.width: 1
                    border.color: Theme.outlineVariant

                    ScreencopyView {
                        readonly property real sw: implicitWidth > 0 ? implicitWidth : 16
                        readonly property real sh: implicitHeight > 0 ? implicitHeight : 10
                        readonly property real fill: Math.max(win.width / sw, win.height / sh)
                        anchors.centerIn: parent
                        width: sw * fill
                        height: sh * fill
                        captureSource: win.modelData.top.wayland
                        live: root.active
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (win.modelData.top.wayland)
                            win.modelData.top.wayland.activate()
                    }
                }
            }
        }
    }
}
