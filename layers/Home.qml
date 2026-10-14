import Quickshell
import QtQuick
import Quickshell.Wayland
import Ryu.Extraa
import qs.services.shapes
import qs.configuration.Wallpaper
import qs.components.Wallpaper
import qs.services.theme

Variants {
    model: Quickshell.screens
    Scope {
        id: screenScope
        required property var modelData
        readonly property bool open: hoverHandler.hovered || stripHover.hovered
        readonly property bool shown: open || popout.height > 0.5

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
            }
            PopOut {
                id: popout
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                height: screenScope.open ? 220 : 0.1
                colour: Theme.background
                width: 1080
                radius: 20

                Behavior on height {
                    SpringAnimation {
                        spring: 2.5
                        damping: 0.2
                        epsilon: 0.05
                    }
                }

                HoverHandler {
                    id: hoverHandler
                }

                Loader {
                    anchors.fill: parent
                    anchors.leftMargin: 30
                    anchors.rightMargin: 30
                    anchors.topMargin: 10
                    anchors.bottomMargin: 10
                    active: screenScope.shown
                    sourceComponent: WallpaperCarousel {}
                }
            }

            PopOut {
                id: strip
                anchors.top: popout.bottom
                anchors.topMargin: -1
                anchors.horizontalCenter: parent.horizontalCenter
                width: schemeGroup.implicitWidth + 80
                height: ((popout.height - 0.1) / 219.9) * 56 + 0.1
                colour: Theme.background
                radius: 20
                clip: true
                visible: height > 0.5

                HoverHandler {
                    id: stripHover
                }

                MaterialButtonGroup {
                    id: schemeGroup
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 8
                    labels: Theme.schemes.map(s => s.replace("scheme-", "").replace(/-/g, " "))
                    selectionMode: MaterialButtonGroup.Single
                    currentIndex: Theme.schemes.indexOf(Theme.scheme)
                    variant: MaterialButtonGroup.Connected
                    sizeStyle: MaterialButtonGroup.ExtraSmall
                    color: Theme.surfaceContainer
                    checkedColor: Theme.primary
                    textColor: Theme.onSurfaceVariantColor
                    checkedTextColor: Theme.onPrimaryColor

                    onToggled: (index, checked) => {
                        if (checked)
                            Theme.setScheme(Theme.schemes[index]);
                    }
                }
            }
        }
    }
}
