pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.services.theme
import qs.configuration.Settings
import qs.Settings.pages

Scope {
    LazyLoader {
        active: SettingsConfig.open

        FloatingWindow {
            id: win

            readonly property var screenObj: Quickshell.screens[0] ?? null
            readonly property real maxW: (screenObj ? screenObj.width : 1920) * 0.9
            readonly property real maxH: (screenObj ? screenObj.height : 1080) * 0.9

            title: "Phoenix Settings"
            color: Theme.background
            implicitWidth: Math.min(1920, maxW)
            implicitHeight: Math.min(1080, maxH)
            minimumSize: Qt.size(implicitWidth, implicitHeight)
            maximumSize: Qt.size(implicitWidth, implicitHeight)

            onVisibleChanged: if (!visible)
                SettingsConfig.open = false

            Shortcut {
                sequence: "Escape"
                onActivated: SettingsConfig.open = false
            }

            Component {
                id: widgetsPage
                WidgetsPage {}
            }

            Component {
                id: wallpaperPage
                WallpaperPage {}
            }

            Item {
                anchors.fill: parent

                SettingsSidebar {
                    id: sidebar
                    width: Math.max(200, Math.min(260, win.width * 0.22))
                    height: parent.height
                }

                ClippingRectangle {
                    id: stage
                    anchors.left: sidebar.right
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.topMargin: 12
                    anchors.rightMargin: 12
                    anchors.bottomMargin: 12
                    radius: 28
                    color: Theme.surfaceContainer

                    property bool ready: false

                    onWidthChanged: if (!ready)
                        settle.restart()
                    onHeightChanged: if (!ready)
                        settle.restart()

                    Component.onCompleted: settle.restart()

                    Timer {
                        id: settle
                        interval: 80
                        onTriggered: stage.ready = true
                    }

                    Loader {
                        id: pageLoader
                        anchors.fill: parent
                        visible: stage.ready
                        active: stage.width > 0 && stage.height > 0
                        sourceComponent: SettingsConfig.page === "wallpaper" ? wallpaperPage : widgetsPage
                    }
                }
            }
        }
    }
}
