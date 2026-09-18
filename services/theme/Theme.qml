pragma Singleton
import Quickshell
import qs.configuration.Wallpaper
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
        depth: 2
        rescaleSize: 64
        source: WallpaperConfig.currentWallpaper
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
