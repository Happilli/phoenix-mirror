pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.services.paths

Singleton {
    id: root

    readonly property var live: ({
            gaps_in: ["general", "gaps_in"],
            gaps_out: ["general", "gaps_out"],
            border_size: ["general", "border_size"],
            layout: ["general", "layout"],
            rounding: ["decoration", "rounding"],
            active_opacity: ["decoration", "active_opacity"],
            inactive_opacity: ["decoration", "inactive_opacity"],
            dim_inactive: ["decoration", "dim_inactive"],
            shadow_enabled: ["decoration", "shadow", "enabled"],
            blur_enabled: ["decoration", "blur", "enabled"],
            blur_size: ["decoration", "blur", "size"],
            blur_passes: ["decoration", "blur", "passes"],
            animations_enabled: ["animations", "enabled"]
        })

    readonly property var layouts: ["dwindle", "master", "scrolling"]
    readonly property var layoutLabels: ["Dwindle", "Master", "Scrolling"]

    property var saved: ({})
    property var values: ({})
    property var pending: ({})
    property bool ready: false
    property bool needsReload: false

    function get(key) {
        return values[key];
    }

    function isDirty(keys) {
        return keys.some(k => values[k] !== saved[k]);
    }

    function parse(raw) {
        const out = {};
        for (const line of raw.split("\n")) {
            const i = line.indexOf("=");
            if (i <= 0)
                continue;
            const k = line.slice(0, i).trim();
            const v = line.slice(i + 1).trim();
            if (v === "true")
                out[k] = true;
            else if (v === "false")
                out[k] = false;
            else
                out[k] = v !== "" && !isNaN(Number(v)) ? Number(v) : v;
        }
        return out;
    }

    function luaFor(path, value) {
        let s = typeof value === "string" ? JSON.stringify(value) : String(value);
        for (let i = path.length - 1; i >= 0; i--)
            s = "{ " + path[i] + " = " + s + " }";
        return "hl.config(" + s + ")";
    }

    function queueLive(key, value) {
        if (!live[key])
            return;
        const p = Object.assign({}, pending);
        p[key] = value;
        pending = p;
    }

    function set(key, value) {
        if (!ready || values[key] === value)
            return;
        const next = Object.assign({}, values);
        next[key] = value;
        values = next;
        queueLive(key, value);
        flushLive();
    }

    function cancel(keys) {
        if (!ready)
            return;
        const next = Object.assign({}, values);
        for (const k of keys) {
            next[k] = saved[k];
            queueLive(k, saved[k]);
        }
        values = next;
        flushLive();
    }

    function save(keys) {
        if (!ready)
            return;
        const next = Object.assign({}, saved);
        for (const k of keys) {
            if (next[k] !== values[k] && !live[k])
                needsReload = true;
            next[k] = values[k];
        }
        saved = next;
        file.setText(Object.entries(saved).map(([k, v]) => k + "=" + v).join("\n") + "\n");
    }

    function revertAll() {
        cancel(Object.keys(saved));
    }

    function flushLive() {
        if (evalProc.running)
            return;
        const keys = Object.keys(pending);
        if (keys.length === 0)
            return;
        const lua = keys.map(k => luaFor(live[k], pending[k])).join("; ");
        pending = {};
        evalProc.command = ["hyprctl", "eval", lua];
        evalProc.running = true;
    }

    Process {
        id: evalProc
        onRunningChanged: if (!running)
            root.flushLive()
    }

    FileView {
        id: file
        path: PathService.home + "/.config/hypr/ergonDumbah"
        blockLoading: true
        atomicWrites: true
        onLoaded: {
            const parsed = root.parse(text());
            root.saved = parsed;
            root.values = Object.assign({}, parsed);
            root.ready = true;
        }
        onSaved: {
            if (root.needsReload) {
                root.needsReload = false;
                Quickshell.execDetached(["hyprctl", "reload"]);
            }
        }
    }
}
