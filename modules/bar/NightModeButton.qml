import QtQuick
import Ryu.Extraa
import qs.services.theme
import qs.services.nightmode

Item {
    id: root
    implicitWidth: 40
    implicitHeight: 40

    readonly property bool hovered: hover.hovered

    HoverHandler {
        id: hover
    }

    MaterialIconButton {
        anchors.fill: parent
        type: MaterialIconButton.Standard
        shape: MaterialIconButton.Round
        iconText: NightModeService.active ? "\uf186" : "\udb81\udda8"
        iconSize: 22
        iconColor: NightModeService.active ? Theme.primary : Theme.onSurfaceVariantColor
        onClicked: NightModeService.toggle()
        color: Theme.background
    }
}
