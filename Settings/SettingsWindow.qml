pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.services.theme
import qs.configuration.Settings
import qs.configuration.Hypr
import qs.Settings.pages

Scope {
    LazyLoader {
        active: SettingsConfig.open

        FloatingWindow {
            id: win

            readonly property var screenObj: Quickshell.screens[0] ?? null
            readonly property real maxWidth: (win.screenObj ? win.screenObj.width : 1920) * 0.97
            readonly property real maxHeight: (win.screenObj ? win.screenObj.height : 1080) * 0.9

            title: "Phoenix Settings"
            color: Theme.background
            implicitWidth: Math.min(1920, win.maxWidth)
            implicitHeight: Math.min(1080, win.maxHeight)
            minimumSize: Qt.size(win.implicitWidth, win.implicitHeight)
            maximumSize: Qt.size(win.implicitWidth, win.implicitHeight)

            onVisibleChanged: if (!win.visible) {
                HyprConfig.revertAll();
                SettingsConfig.open = false;
            }

            Shortcut {
                sequence: "Escape"
                enabled: !header.searching
                onActivated: SettingsConfig.open = false
            }

            Component {
                id: widgetsPage
                WidgetsPage {}
            }

            Component {
                id: generalPage
                GeneralPage {}
            }
            Component {
                id: hyprPage
                HyprPage {}
            }

            Item {
                id: content
                anchors.fill: parent

                SettingsSidebar {
                    id: sidebar
                    width: Math.max(200, Math.min(260, win.width * 0.22))
                    height: content.height
                }

                Item {
                    id: main
                    anchors.left: sidebar.right
                    anchors.right: content.right
                    anchors.top: content.top
                    anchors.bottom: content.bottom

                    SettingsHeader {
                        id: header
                        z: 10
                        anchors.left: main.left
                        anchors.right: main.right
                        anchors.top: main.top
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16

                        onDismissed: main.forceActiveFocus()
                        onPicked: (key, page) => {
                            SettingsConfig.reveal(key, page);
                            main.forceActiveFocus();
                        }
                    }

                    ClippingRectangle {
                        id: stage

                        property bool ready: false

                        anchors.left: main.left
                        anchors.right: main.right
                        anchors.top: header.bottom
                        anchors.bottom: main.bottom
                        anchors.rightMargin: 12
                        anchors.bottomMargin: 12
                        radius: 28
                        color: Theme.surfaceContainer

                        Component.onCompleted: settle.restart()
                        onWidthChanged: if (!stage.ready)
                            settle.restart()
                        onHeightChanged: if (!stage.ready)
                            settle.restart()

                        Timer {
                            id: settle
                            interval: 80
                            onTriggered: stage.ready = true
                        }

                        Loader {
                            anchors.fill: parent
                            visible: stage.ready
                            active: stage.width > 0 && stage.height > 0
                            sourceComponent: {
                                switch (SettingsConfig.page) {
                                case "general":
                                    return generalPage;
                                case "hyprland":
                                    return hyprPage;
                                }
                                return widgetsPage;
                            }
                        }
                    }

                    MouseArea {
                        z: 5
                        anchors.fill: main
                        enabled: header.searching
                        onPressed: mouse => {
                            main.forceActiveFocus();
                            mouse.accepted = true;
                        }
                    }
                }
            }
        }
    }
}
