import Quickshell
import QtQuick
import Quickshell.Wayland
import qs.services.theme
import qs.modules.bar
import qs.components.osd
import qs.configuration.Bar

Variants {
    model: Quickshell.screens
    Scope {
        id: screenScope
        required property var modelData
        property int gap: 2

        WlrLayershell {
            namespace: "phoenix-aboveHome"
            screen: screenScope.modelData
            layer: WlrLayer.Top
            exclusiveZone: BarConfig.thickness - BarConfig.radius + screenScope.gap
            color: "transparent"
            mask: Region {}

            anchors {
                top: BarConfig.edge !== "bottom"
                bottom: BarConfig.edge !== "top"
                left: BarConfig.edge !== "right"
                right: BarConfig.edge !== "left"
            }
        }
        WlrLayershell {
            namespace: "phoenix-aboveHome"
            screen: screenScope.modelData
            layer: WlrLayer.Top
            keyboardFocus: WlrKeyboardFocus.OnDemand
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
                radius: BarConfig.radius
                colour: Theme.background
                width: BarConfig.horizontal ? parent.width : BarConfig.thickness
                height: BarConfig.horizontal ? BarConfig.thickness : parent.height
                x: BarConfig.edge === "right" ? parent.width - width : 0
                y: BarConfig.edge === "bottom" ? parent.height - height : 0
            }
            Osd {
                x: BarConfig.horizontal ? (parent.width - width) / 2 : (BarConfig.edge === "left" ? bar.width + 8 : bar.x - width - 8)
                y: BarConfig.horizontal ? (BarConfig.edge === "top" ? bar.height + 8 : bar.y - height - 8) : (parent.height - height) / 2
            }
        }
    }
}
