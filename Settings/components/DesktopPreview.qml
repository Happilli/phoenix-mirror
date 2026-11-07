import QtQuick
import Quickshell
import qs.configuration.Wallpaper
import qs.components.clock
import qs.services.theme

Rectangle {
    id: root

    readonly property var screenObj: Quickshell.screens[0] ?? null
    readonly property real sw: screenObj ? screenObj.width : 1920
    readonly property real sh: screenObj ? screenObj.height : 1080
    readonly property real aspect: sw / sh
    readonly property real bw: border.width
    readonly property real k: width > 0 ? (width - bw * 2) / sw : 1

    height: sh * k + bw * 2
    color: Theme.surfaceContainerHighest
    border.width: 2
    border.color: Theme.outlineVariant

    Image {
        anchors.fill: parent
        anchors.margins: root.bw
        source: WallpaperConfig.currentWallpaper
        sourceSize.height: Math.ceil(root.height / 50) * 50
        cache: true
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }

    Item {
        anchors.fill: parent
        anchors.margins: root.bw
        clip: true

        Item {
            width: root.sw
            height: root.sh
            scale: root.k
            transformOrigin: Item.TopLeft

            ConfiguredClock {}
        }
    }
}
