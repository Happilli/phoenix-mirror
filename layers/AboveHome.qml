import Quickshell
import QtQuick
import Ryu.Wayland as Wl
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
        readonly property real mL: BarConfig.floating ? BarConfig.marginLeft : 0
        readonly property real mR: BarConfig.floating ? BarConfig.marginRight : 0
        readonly property real mT: BarConfig.floating ? BarConfig.marginTop : 0
        readonly property real mB: BarConfig.floating ? BarConfig.marginBottom : 0

        Wl.WlrLayershell {
            namespace: "phoenix-aboveHome"
            screen: screenScope.modelData
            layer: Wl.WlrLayer.Top
            exclusiveZone: BarConfig.floating ? BarConfig.dockMargin + BarConfig.thickness + screenScope.gap : BarConfig.thickness - BarConfig.radius + screenScope.gap
            color: "transparent"
            mask: Wl.Region {}

            anchors {
                top: BarConfig.edge !== "bottom"
                bottom: BarConfig.edge !== "top"
                left: BarConfig.edge !== "right"
                right: BarConfig.edge !== "left"
            }
        }
        Wl.WlrLayershell {
            namespace: "phoenix-aboveHome"
            screen: screenScope.modelData
            layer: Wl.WlrLayer.Top
            keyboardFocus: Wl.WlrKeyboardFocus.OnDemand
            exclusiveZone: -1
            color: "transparent"
            mask: Wl.Region {
                item: bar.hitbox

                Wl.Region {
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
                width: BarConfig.horizontal ? parent.width - screenScope.mL - screenScope.mR : BarConfig.thickness
                height: BarConfig.horizontal ? BarConfig.thickness : parent.height - screenScope.mT - screenScope.mB
                x: BarConfig.horizontal ? screenScope.mL : (BarConfig.edge === "right" ? parent.width - width - screenScope.mR : screenScope.mL)
                y: BarConfig.horizontal ? (BarConfig.edge === "bottom" ? parent.height - height - screenScope.mB : screenScope.mT) : screenScope.mT
            }
            Osd {
                x: BarConfig.horizontal ? (parent.width - width) / 2 : (BarConfig.edge === "left" ? bar.x + bar.width + 8 : bar.x - width - 8)
                y: BarConfig.horizontal ? (BarConfig.edge === "top" ? bar.y + bar.height + 8 : bar.y - height - 8) : (parent.height - height) / 2
            }
        }
    }
}
