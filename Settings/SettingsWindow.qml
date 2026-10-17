pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs.services.theme
import qs.configuration.Settings
import qs.Settings.pages

Scope {
    LazyLoader {
        active: SettingsConfig.open

        FloatingWindow {
            title: "Phoenix Settings"
            implicitWidth: 980
            implicitHeight: 700
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

                Loader {
                    anchors.left: sidebar.right
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    sourceComponent: widgetsPage
                }
            }
        }
    }
}
