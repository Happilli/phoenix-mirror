pragma Singleton
import QtQuick
import Quickshell
import qs.services.state
import qs.services.theme

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
            margin: 48
        })

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

    readonly property bool enabled: get("enabled")
    readonly property int size: get("size")
    readonly property int hAlign: get("hAlign")
    readonly property int vAlign: get("vAlign")
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
