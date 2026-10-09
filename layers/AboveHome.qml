import Quickshell
import QtQuick
import Quickshell.Wayland
import qs.services.theme
import qs.modules.bar

Variants {
    model: Quickshell.screens
    Scope {
        id: screenScope
        required property var modelData
        property int barHeight: 55
        property int gap: 2
        property int radius: 15

        WlrLayershell {
            namespace: "phoenix-aboveHome"
            screen: screenScope.modelData
            layer: WlrLayer.Top
            exclusiveZone: screenScope.barHeight - screenScope.radius + screenScope.gap
            color: "transparent"
            mask: Region {}

            anchors {
                bottom: true
                left: true
                right: true
            }
        }
        WlrLayershell {
            namespace: "phoenix-aboveHome"
            screen: screenScope.modelData
            layer: WlrLayer.Top
            exclusiveZone: -1
            color: "transparent"
            mask: Region {
                item: bar
                Region {
                    item: bar.popupS
                }
            }

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
            Bar {
                id: bar
                screen: screenScope.modelData
                height: screenScope.barHeight
                radius: screenScope.radius
                colour: Theme.background
                anchors {
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                }
            }
        }
    }
}
