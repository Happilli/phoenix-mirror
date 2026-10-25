import QtQuick
import Quickshell
import Ryu.Widgets
import qs.configuration.Wallpaper
import qs.configuration.Widgets
import qs.services.theme

Item {
    id: root

    readonly property var screenObj: Quickshell.screens[0] ?? null
    readonly property real sw: screenObj ? screenObj.width : 1920
    readonly property real sh: screenObj ? screenObj.height : 1080
    readonly property real aspect: sw / sh
    readonly property real k: width > 0 ? width / sw : 1

    height: sh * k
    clip: true

    Image {
        anchors.fill: parent
        source: WallpaperConfig.currentWallpaper
        sourceSize.height: 480
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: false
    }

    Rectangle {
        width: root.sw
        height: root.sh
        scale: root.k
        border.width: 5
        border.color: Theme.outlineVariant
        color: "transparent"
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
