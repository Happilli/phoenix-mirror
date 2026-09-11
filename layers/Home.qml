import Quickshell
import QtQuick
import Quickshell.Wayland
import qs.services.paths

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

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
            Image {
                source: PathService.defaultWallpaper
                fillMode: Image.PreserveAspectCrop
                cache: false
                asynchronous: true
            }
        }
    }
}
