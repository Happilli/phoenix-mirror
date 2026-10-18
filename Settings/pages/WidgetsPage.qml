import QtQuick
import Quickshell
import qs.Settings.components

SettingsPage {
    header: DesktopPreview {
        readonly property real screenWidth: Quickshell.screens[0]?.width ?? 1920
        readonly property bool large: parent.width / screenWidth > 0.6

        width: large ? 800 : parent.width
    }
}
