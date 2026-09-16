pragma Singleton
import Quickshell
import qs.services.paths
import QtQuick

Singleton {
    id: root
    enum Role {
        Background,
        Accent,
        Surface,
        Text
    }
    ColorQuantizer {
        id: quantizer
        depth: 3
        rescaleSize: 64
        source: PathService.defaultWallpaper
        onColorsChanged: console.log(colors.length, colors)
    }
    readonly property var colors: quantizer.colors

    function colorFor(role) {
        return role < colors.length ? colors[role] : "transparent";
    }
    readonly property color background: colorFor(Theme.Background)
    readonly property color surface: colorFor(Theme.Surface)
    readonly property color accent: colorFor(Theme.Accent)
    readonly property color text: colorFor(Theme.Text)
}
