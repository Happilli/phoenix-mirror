import QtQuick
import qs.services.notifications
import qs.services.theme
import Quickshell
import Quickshell.Widgets

Row {
    id: root
    readonly property var list: NotificationsService.list.values.slice(-1)[0]
    spacing: 8
    IconImage {
        source: root.list ? Quickshell.iconPath(root.list.appIcon, true) : ""
        implicitSize: 24
        anchors.verticalCenter: parent.verticalCenter
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: root.list ? root.list.summary : ""
        font.pixelSize: 17
        color: Theme.onSurfaceVariantColor
    }
}
