pragma Singleton
import QtQuick
import Quickshell
import qs.services.state
import qs.services.theme
import qs.configuration.Wallpaper

Singleton {
    id: root

    readonly property var defaults: ({
            orientation: 0,
            use24Hour: true,
            showAmPm: false,
            amPmStyle: 0,
            showSeparator: true,
            fontWeight: 900,
            gap: 0.045,
            overlap: 0.03,
            groupGap: 0.14,
            letterSpacing: -0.04,
            padding: 0,
            colorKey: "primary",
            enabled: true,
            size: 260,
            hAlign: 1,
            vAlign: 1,
            margin: 48,
            randomizePosition: false
        })
    function place(pos, container, item, margin) {
        const a = margin;
        const b = (container - item) / 2;
        const c = container - item - margin;
        return pos <= 1 ? a + (b - a) * pos : b + (c - b) * (pos - 1);
    }
    property real hPos: hAlign
    property real vPos: vAlign

    Behavior on hPos {
        SpringAnimation {
            spring: 1.2
            damping: 0.22
            mass: 1.4
            epsilon: 0.001
        }
    }

    Behavior on vPos {
        SpringAnimation {
            spring: 1.2
            damping: 0.22
            mass: 1.4
            epsilon: 0.001
        }
    }
    readonly property var colorOptions: [
        {
            key: "primary",
            label: "Primary"
        },
        {
            key: "text",
            label: "Text"
        },
        {
            key: "muted",
            label: "Muted"
        },
        {
            key: "alert",
            label: "Alert"
        }
    ]

    readonly property var autoPositions: [[0, 0], [1, 0], [2, 0], [0, 1], [2, 1], [0, 2], [1, 2], [2, 2]]

    property var values: StateService.get("clock", {})

    function get(key) {
        return values[key] ?? defaults[key];
    }

    function set(key, value) {
        const next = Object.assign({}, values);
        next[key] = value;
        values = next;
        saveTimer.restart();
    }

    function reset() {
        values = {};
        saveTimer.restart();
    }

    function colorFor(key) {
        switch (key) {
        case "text":
            return Theme.onBackgroundColor;
        case "muted":
            return Theme.onSurfaceVariantColor;
        case "alert":
            return Theme.error;
        }
        return Theme.primary;
    }

    function hash(str) {
        let h = 5381;
        for (let i = 0; i < str.length; i++)
            h = ((h * 33) ^ str.charCodeAt(i)) >>> 0;
        return h;
    }

    readonly property bool randomizePosition: get("randomizePosition")
    readonly property var autoPosition: autoPositions[hash(WallpaperConfig.currentWallpaper.toString()) % autoPositions.length]

    readonly property bool enabled: get("enabled")
    readonly property int size: get("size")
    readonly property int hAlign: randomizePosition ? autoPosition[0] : get("hAlign")
    readonly property int vAlign: randomizePosition ? autoPosition[1] : get("vAlign")
    readonly property int margin: get("margin")
    readonly property int orientation: get("orientation")
    readonly property bool use24Hour: get("use24Hour")
    readonly property bool showAmPm: get("showAmPm")
    readonly property int amPmStyle: get("amPmStyle")
    readonly property bool showSeparator: get("showSeparator")
    readonly property int fontWeight: get("fontWeight")
    readonly property real gap: get("gap")
    readonly property real overlap: get("overlap")
    readonly property real groupGap: get("groupGap")
    readonly property real letterSpacing: get("letterSpacing")
    readonly property real padding: get("padding")
    readonly property string colorKey: get("colorKey")
    readonly property color tint: colorFor(colorKey)

    Timer {
        id: saveTimer
        interval: 400
        onTriggered: StateService.set("clock", root.values)
    }
}
