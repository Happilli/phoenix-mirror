import Quickshell
import QtQuick
import Quickshell.Wayland
import qs.configuration.Wallpaper
import qs.components.menu
import qs.components.clock

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

            ConfiguredClock {}
        }
    }
}
