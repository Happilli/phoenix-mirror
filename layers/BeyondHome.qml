pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Ryu.Wayland as Wl
import qs.components.screenshot
import qs.components.notifications
import qs.components.clipboard
import qs.components.polkit
import qs.configuration.Screenshot
import qs.configuration.Clipboard
import qs.services.polkit
import qs.services.theme

Variants {
    model: Quickshell.screens

    Scope {
        id: screenScope
        required property var modelData

        readonly property bool selecting: ScreenshotConfig.selecting && ScreenshotConfig.selectScreen === modelData.name
        readonly property bool clipOpen: ClipboardConfig.open && ClipboardConfig.screenName === modelData.name
        readonly property bool polkitOpen: PolkitService.shown && ScreenshotConfig.focusedName() === modelData.name
        property bool clipShown: false
        property bool clipGrab: false
        property bool polkitGrab: false

        onClipOpenChanged: {
            if (clipOpen) {
                clipShown = true;
                clipGrab = true;
                grabTimer.restart();
            } else {
                clipShown = false;
                clipGrab = false;
                grabTimer.stop();
            }
        }

        onPolkitOpenChanged: {
            if (polkitOpen) {
                polkitGrab = true;
                polkitTimer.restart();
            } else {
                polkitGrab = false;
                polkitTimer.stop();
            }
        }

        Timer {
            id: grabTimer
            interval: 200
            onTriggered: screenScope.clipGrab = false
        }

        Timer {
            id: polkitTimer
            interval: 200
            onTriggered: screenScope.polkitGrab = false
        }

        Wl.WlrLayershell {
            id: layer
            namespace: "phoenix-beyondHome"
            screen: screenScope.modelData
            layer: Wl.WlrLayer.Overlay
            exclusiveZone: -1
            color: "transparent"
            keyboardFocus: screenScope.polkitOpen ? (screenScope.polkitGrab ? Wl.WlrKeyboardFocus.Exclusive : Wl.WlrKeyboardFocus.OnDemand) : (screenScope.selecting ? Wl.WlrKeyboardFocus.Exclusive : (screenScope.clipOpen ? (screenScope.clipGrab ? Wl.WlrKeyboardFocus.Exclusive : Wl.WlrKeyboardFocus.OnDemand) : Wl.WlrKeyboardFocus.None))
            mask: Wl.Region {
                item: screenScope.selecting ? picker : shot

                Wl.Region {
                    item: clipLoader.item as Item
                }

                Wl.Region {
                    item: notif
                }

                Wl.Region {
                    item: polkitLoader.item as Item
                }
            }

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            Loader {
                anchors.fill: parent
                active: ScreenshotConfig.capturing && ScreenshotConfig.targets.includes(screenScope.modelData.name)

                sourceComponent: CaptureView {
                    screen: screenScope.modelData
                }
            }

            Loader {
                id: picker
                anchors.fill: parent
                active: screenScope.selecting
                sourceComponent: RegionSelector {}
            }

            Loader {
                id: clipLoader
                anchors.centerIn: parent
                active: screenScope.clipShown
                sourceComponent: ClipboardPopup {}
            }

            Loader {
                id: polkitLoader
                anchors.centerIn: parent
                active: screenScope.polkitOpen
                sourceComponent: PolkitCard {}
            }

            ScreenshotPopup {
                id: shot
                screenName: screenScope.modelData.name
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.bottomMargin: 76
                anchors.rightMargin: 16 - (1 - shot.progress) * 420
            }

            NotificationPopup {
                id: notif
                screenName: screenScope.modelData.name
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: 16
                anchors.rightMargin: 16
            }
        }
    }
}
