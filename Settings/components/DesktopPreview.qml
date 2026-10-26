import QtQuick
import Quickshell
import Quickshell.Widgets
import Ryu.Widgets
import qs.configuration.Wallpaper
import qs.configuration.Widgets
import qs.services.theme

ClippingRectangle {
    id: root

    readonly property var screenObj: Quickshell.screens[0] ?? null
    readonly property real sw: screenObj ? screenObj.width : 1920
    readonly property real sh: screenObj ? screenObj.height : 1080
    readonly property real aspect: sw / sh
    readonly property real k: width > 0 ? width / sw : 1

    height: sh * k
    radius: 14
    color: Theme.surfaceContainerHighest
    border.width: 1
    border.color: Theme.outlineVariant

    Image {
        anchors.fill: parent
        source: WallpaperConfig.currentWallpaper
        sourceSize.height: Math.ceil(root.height / 50) * 50
        cache: true
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }

    Item {
        width: root.sw
        height: root.sh
        scale: root.k
        transformOrigin: Item.TopLeft

        Loader {
            id: clock
            active: ClockConfig.enabled
            width: ClockConfig.size
            height: ClockConfig.orientation === 0 ? ClockConfig.size * 1.1 : ClockConfig.size * 0.45

            x: ClockConfig.place(ClockConfig.hPos, parent.width, width, ClockConfig.margin)
            y: ClockConfig.place(ClockConfig.vPos, parent.height, height, ClockConfig.margin)

            sourceComponent: DigitalClock {
                orientation: ClockConfig.orientation
                use24Hour: ClockConfig.use24Hour
                showAmPm: ClockConfig.showAmPm
                amPmStyle: ClockConfig.amPmStyle
                showSeparator: ClockConfig.showSeparator
                fontWeight: ClockConfig.fontWeight
                gap: ClockConfig.gap
                overlap: ClockConfig.overlap
                groupGap: ClockConfig.groupGap
                letterSpacing: ClockConfig.letterSpacing
                padding: ClockConfig.padding
                color: ClockConfig.tint
            }
        }
    }
}
