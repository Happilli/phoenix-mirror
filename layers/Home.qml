import Quickshell
import QtQuick
import Quickshell.Wayland
import qs.services.theme
import qs.configuration.Wallpaper

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
            Rectangle {
                id: testColor
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.left: parent.left
                color: Theme.background
                height: 40
                width: 40
                border.color: "red"
                border.width: 2
            }
        }
    }
}
