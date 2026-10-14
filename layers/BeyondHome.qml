pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.components.screenshot
import qs.configuration.Screenshot

Variants {
    model: Quickshell.screens

    Scope {
        id: screenScope
        required property var modelData

        Loader {
            active: ScreenshotConfig.capturing && ScreenshotConfig.targets.includes(screenScope.modelData.name)

            sourceComponent: WlrLayershell {
                namespace: "phoenix-beyondHome"
                screen: screenScope.modelData
                layer: WlrLayer.Overlay
                exclusiveZone: -1
                color: "transparent"
                mask: Region {}

                anchors {
                    top: true
                    bottom: true
                    left: true
                    right: true
                }

                CaptureView {
                    anchors.fill: parent
                    screen: screenScope.modelData
                }
            }
        }
    }
}
