import Quickshell
import QtQuick
import Quickshell.Wayland
import Ryu.Widgets
import qs.configuration.Wallpaper
import qs.configuration.Widgets
import qs.components.menu

Variants {
    model: Quickshell.screens
    Scope {
        id: screenScope
        required property var modelData

        WlrLayershell {
            namespace: "phoenix-background"
            screen: screenScope.modelData
            layer: WlrLayer.Background
            exclusiveZone: -1
            color: "transparent"

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
            Item {
                id: wall
                anchors.fill: parent
                clip: true

                property real mouseNorm: 0.5
                readonly property real imgAspect: wallpaper.implicitHeight > 0 ? wallpaper.implicitWidth / wallpaper.implicitHeight : 0
                readonly property bool pannable: imgAspect > (width / height) * 1.1

                HoverHandler {
                    onPointChanged: if (hovered && wall.width > 0)
                        wall.mouseNorm = Math.max(0, Math.min(1, point.position.x / wall.width))
                }

                Image {
                    id: wallpaper
                    height: wall.height
                    width: wall.pannable ? implicitWidth * (wall.height / implicitHeight) : wall.width
                    source: WallpaperConfig.currentWallpaper
                    sourceSize.height: wall.height
                    fillMode: Image.PreserveAspectCrop
                    cache: false
                    asynchronous: true

                    x: wall.pannable ? -(width - wall.width) * wall.mouseNorm : 0

                    Behavior on x {
                        enabled: wall.pannable
                        NumberAnimation {
                            duration: 400
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                HomeMenu {
                    anchors.fill: parent
                }
            }
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
}
