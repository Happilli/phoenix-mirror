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
            title: "Phoenix Settings"
            implicitWidth: 1200
            implicitHeight: 1000
            minimumSize: Qt.size(implicitWidth, implicitHeight)
            maximumSize: Qt.size(implicitWidth, implicitHeight)
            color: Theme.background

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

            Item {
                anchors.fill: parent

                SettingsSidebar {
                    id: sidebar
                    width: 260
                    height: parent.height
                }

                ClippingRectangle {
                    anchors.left: sidebar.right
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.topMargin: 12
                    anchors.rightMargin: 12
                    anchors.bottomMargin: 12
                    radius: 28
                    color: Theme.surfaceContainer

                    Loader {
                        anchors.fill: parent
                        sourceComponent: widgetsPage
                    }
                }
            }
        }
    }
}
