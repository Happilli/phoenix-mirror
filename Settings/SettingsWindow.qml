import QtQuick
import Quickshell
import qs.services.theme
import qs.configuration.Settings

Scope {
    LazyLoader {
        active: SettingsConfig.open

        FloatingWindow {
            title: "Phoenix Settings"
            implicitWidth: 900
            implicitHeight: 640
            color: Theme.background

            onVisibleChanged: if (!visible)
                SettingsConfig.open = false

            Text {
                anchors.centerIn: parent
                text: "Settings"
                font.pixelSize: 20
                color: Theme.onSurfaceVariantColor
            }
        }
    }
}
