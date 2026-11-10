pragma Singleton
import QtQuick
import Quickshell
import Ryu.Sway
import Ryu.Io
import qs.services.paths
import qs.configuration.Screenshot

Singleton {
    id: root
    property bool open: false
    property bool regioning: false
    property string raw: ""
    property string wsRaw: ""
    property int tab: 0
    property bool token: true
    property var groups: []
    property var groupMap: ({})
    readonly property string resultPath: PathService.runtime + "/phoenix-picker-result"
    readonly property var windows: {
        const out = [];
        for (const e of raw.split("[HA>]")) {
            if (e.trim() === "")
                continue;
            const a = e.split("[HC>]");
            if (a.length < 2)
                continue;
            const b = a[1].split("[HT>]");
            if (b.length < 2)
                continue;
            const c = b[1].split("[HE>]");
            out.push({
                id: a[0],
                cls: b[0],
                title: c[0],
                addr: c.length > 1 ? c[1].trim() : ""
            });
        }
        return out;
    }
    readonly property var workspaces: parseWorkspaces(wsRaw)
    readonly property var screenItems: Quickshell.screens.map(s => ({
                key: "s:" + s.name,
                label: s.name + "  ·  " + s.width + "x" + s.height,
                kind: "screen",
                target: s.name,
                addr: "",
                screen: s
            }))
    readonly property var windowItems: windows.map(w => ({
                label: w.cls + "  ·  " + w.title,
                kind: "window",
                target: w.id,
                addr: w.addr,
                screen: null
            }))
    readonly property var windowByAddr: {
        const m = {};
        for (const w of windowItems)
            m[norm(w.addr)] = w;
        return m;
    }
    readonly property var workspaceItems: {
        const out = [];
        for (const g of groups) {
            if (g.id <= 0)
                continue;
            const cands = workspaces.filter(w => w.name === g.name);
            const m = cands.find(w => w.outputs.includes(g.monitorName)) ?? cands[0] ?? null;
            if (!m)
                continue;
            out.push({
                key: "w:" + g.id,
                sortId: g.id,
                label: "Workspace " + g.name + (g.monitorName !== "" ? "  ·  " + g.monitorName : ""),
                kind: "workspace",
                target: m.id,
                addr: "",
                screen: null,
                wsName: g.name
            });
        }
        return out.sort((a, b) => a.sortId - b.sortId);
    }
    function norm(addr) {
        const s = String(addr ?? "");
        const n = Number(s);
        return s === "" ? "" : isNaN(n) ? s.toLowerCase().replace(/^0x/, "") : n.toString(16);
    }
    function refresh() {
        Sway.refreshToplevels();
        Sway.refreshWorkspaces();
        Sway.refreshMonitors();
    }
    function rebuild() {
        const mons = Sway.monitors.values;
        const by = {};
        for (const t of Sway.toplevels.values) {
            const o = t.lastIpcObject;
            if (!o?.at || !o.size || o.mapped === false || o.title === "Share")
                continue;
            const ws = o.workspace;
            const name = ws?.name || String(ws?.id);
            const key = norm(t.address);
            const item = windowByAddr[key] ?? null;
            if (!by[name])
                by[name] = {
                    id: ws?.id ?? -9999,
                    name: name,
                    monitorId: o.monitor,
                    wins: []
                };
            by[name].wins.push({
                top: t,
                wl: t,
                item: item,
                shareable: item !== null,
                label: item ? item.label : (o.class + "  ·  " + o.title),
                key: key,
                x: o.at[0],
                y: o.at[1],
                w: o.size[0],
                h: o.size[1],
                floating: o.floating === true
            });
        }
        const out = Object.values(by);
        const map = {};
        for (const g of out) {
            const mon = mons.find(m => m.id === g.monitorId);
            const mo = mon?.lastIpcObject;
            const sc = mo?.scale || 1;
            const rs = mo?.reserved ?? [0, 0, 0, 0];
            g.monitorName = mon?.name ?? mo?.name ?? "";
            g.mx = (mo?.x ?? 0) + rs[0];
            g.my = (mo?.y ?? 0) + rs[1];
            g.mw = (mo?.width ? mo.width / sc : 1920) - rs[0] - rs[2];
            g.mh = (mo?.height ? mo.height / sc : 1080) - rs[1] - rs[3];
            map[g.name] = g;
        }
        out.sort((a, b) => (a.id > 0 ? 0 : 1) - (b.id > 0 ? 0 : 1) || a.id - b.id);
        groups = out;
        groupMap = map;
    }
    function parseWorkspaces(s) {
        const out = [];
        let i = 0;
        const take = n => {
            let j = i;
            let bytes = 0;
            while (j < s.length && bytes < n) {
                const c = s.codePointAt(j);
                bytes += c < 0x80 ? 1 : c < 0x800 ? 2 : c < 0x10000 ? 3 : 4;
                j += c >= 0x10000 ? 2 : 1;
            }
            if (bytes !== n)
                return null;
            const r = s.slice(i, j);
            i = j;
            return r;
        };
        const until = d => {
            const k = s.indexOf(d, i);
            if (k < 0)
                return null;
            const r = s.slice(i, k);
            i = k + d.length;
            return r;
        };
        const num = d => {
            const t = until(d);
            return t !== null && /^\d+$/.test(t) ? Number(t) : -1;
        };
        while (i < s.length) {
            const id = until("[HN>]");
            if (id === null || !/^\d+$/.test(id))
                break;
            const nl = num(":");
            if (nl < 0)
                break;
            const name = take(nl);
            if (name === null || !s.startsWith("[HM>]", i))
                break;
            i += 5;
            const cnt = num(":");
            if (cnt < 0)
                break;
            const outs = [];
            let bad = false;
            for (let k = 0; k < cnt; k++) {
                const l = num(":");
                const o = l < 0 ? null : take(l);
                if (o === null) {
                    bad = true;
                    break;
                }
                outs.push(o);
            }
            if (bad || !s.startsWith("[HE>]", i))
                break;
            i += 5;
            out.push({
                id: id,
                name: name,
                outputs: outs
            });
        }
        return out;
    }
    function toggle(windows, workspaces) {
        if (open)
            cancel();
        else
            show(windows, workspaces);
    }
    function show(windows, workspaces) {
        raw = windows;
        wsRaw = workspaces;
        tab = 0;
        token = true;
        regioning = false;
        refresh();
        openDelay.restart();
    }
    Timer {
        id: openDelay
        interval: 60
        onTriggered: {
            root.rebuild();
            root.open = true;
        }
    }
    function startRegion() {
        regioning = true;
        regionDelay.restart();
    }
    function pick(kind, target) {
        const k = kind === "workspace" ? "workspace-id" : kind;
        finish("[SELECTION]" + (token ? "r" : "") + "/" + k + ":" + target);
    }
    function cancel() {
        finish("");
    }
    function finish(text) {
        if (!open)
            return;
        open = false;
        writer.command = ["sh", "-c", '[ -p "$2" ] && printf "%s" "$1" | timeout 3 tee "$2" >/dev/null', "sh", text, resultPath];
        writer.running = true;
    }
    Timer {
        id: regionDelay
        interval: 250
        onTriggered: {
            if (!ScreenshotConfig.captureRegionForShare())
                root.regioning = false;
        }
    }
    Connections {
        target: ScreenshotConfig
        function onSharePicked(screenName, rect) {
            if (!root.regioning)
                return;
            if (rect)
                root.pick("region", screenName + "@" + rect.x + "," + rect.y + "," + rect.w + "," + rect.h);
            root.regioning = false;
        }
        function onFinished() {
            if (root.regioning && !ScreenshotConfig.selecting && !regionDelay.running)
                root.regioning = false;
        }
    }
    Process {
        id: writer
    }
}
