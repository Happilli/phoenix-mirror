pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.components.screenshot
import qs.components.notifications
import qs.components.clipboard
import qs.components.polkit
import qs.configuration.Screenshot
import qs.configuration.Clipboard
import qs.services.polkit

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

        WlrLayershell {
            id: layer
            namespace: "phoenix-beyondHome"
            screen: screenScope.modelData
            layer: WlrLayer.Overlay
            exclusiveZone: -1
            color: "transparent"
            keyboardFocus: screenScope.polkitOpen ? (screenScope.polkitGrab ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.OnDemand) : (screenScope.selecting ? WlrKeyboardFocus.Exclusive : (screenScope.clipOpen ? (screenScope.clipGrab ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.OnDemand) : WlrKeyboardFocus.None))
            mask: Region {
                item: screenScope.selecting ? picker : shot

                Region {
                    item: clipLoader.item as Item
                }

                Region {
                    item: notif
                }

                Region {
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
