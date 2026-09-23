import Quickshell
import QtQuick
import Quickshell.Wayland
import qs.services.shapes
import qs.configuration.Wallpaper
import qs.components.Wallpaper

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
            Image {
                anchors.fill: parent
                source: WallpaperConfig.currentWallpaper
                fillMode: Image.PreserveAspectCrop
                cache: false
                asynchronous: true
            }
            PopOut {
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                height: hoverHandler.hovered ? 220 : 0.1
                colour: "red"
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

                WallpaperCarousel {
                    anchors.fill: parent
                    anchors {
                        leftMargin: 30
                        rightMargin: 30
                        topMargin: 10
                        bottomMargin: 10
                    }
                }
            }
        }
    }
}
