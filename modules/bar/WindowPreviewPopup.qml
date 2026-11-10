pragma ComponentBehavior: Bound

import QtQuick
import Ryu.Ui
import Ryu.Sway
import qs.components
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
        Sway.refreshMonitors();
        Sway.refreshWorkspaces();
        Sway.refreshToplevels();
    }

    readonly property var miniatures: {
        const all = Sway.toplevels.values;
        const mons = Sway.monitors.values;
        const app = root.appId;
        const byWs = {};
        for (const t of all) {
            const o = t.lastIpcObject;
            if (!o || !o.at || !o.size || o.mapped === false)
                continue;
            const wsId = o.workspace ? o.workspace.id : 0;
            if (!byWs[wsId])
                byWs[wsId] = {
                    id: wsId,
                    key: wsId + ":" + app,
                    wins: [],
                    hasMine: false,
                    monitorId: o.monitor
                };
            byWs[wsId].wins.push({
                key: t.address,
                top: t,
                x: o.at[0],
                y: o.at[1],
                w: o.size[0],
                h: o.size[1],
                floating: o.floating === true,
                mine: o.class === app
            });
            if (o.class === app)
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
    readonly property real miniW: count > 0 ? Math.floor(Math.min(maxMiniW, (maxWidth - spacing * (count - 1)) / count)) : maxMiniW
    readonly property real miniH: {
        let h = 0;
        for (const m of miniatures)
            h = Math.max(h, Math.round(m.mh * (miniW / m.mw)));
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
        model: ScriptModel {
            values: root.miniatures
            objectProp: "key"
        }
        delegate: Item {
            id: mini
            required property var modelData
            required property int index
            readonly property real s: root.miniW / modelData.mw
            clip: true
            x: Math.round(index * (root.miniW + root.spacing))
            y: 0
            width: Math.round(root.miniW)
            height: Math.round(modelData.mh * s)

            Repeater {
                model: ScriptModel {
                    values: mini.modelData.wins
                    objectProp: "key"
                }
                delegate: ClippingRectangle {
                    id: win
                    required property var modelData
                    x: Math.round((modelData.x - mini.modelData.mx) * mini.s)
                    y: Math.round((modelData.y - mini.modelData.my) * mini.s)
                    width: Math.max(4, Math.round(modelData.w * mini.s))
                    height: Math.max(4, Math.round(modelData.h * mini.s))
                    clip: true
                    color: Theme.background
                    opacity: modelData.mine ? 1 : 0.55
                    z: modelData.floating ? 1 : 0
                    border.width: 1
                    border.color: Theme.outlineVariant

                    FillScreencopy {
                        captureSource: win.modelData.top
                        live: root.active
                        maxFps: 60
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: win.modelData.top.activate()
                    }
                }
            }
        }
    }
}
