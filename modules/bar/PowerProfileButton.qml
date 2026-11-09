import QtQuick
import Ryu.Extraa
import Ryu.Power
import qs.services.theme

Item {
    id: root
    implicitWidth: 40
    implicitHeight: 40

    readonly property bool hovered: hover.hovered

    HoverHandler {
        id: hover
    }

    function iconOf(profile) {
        switch (profile) {
        case PowerProfiles.PowerSaver:
            return "\uf06c";
        case PowerProfiles.Performance:
            return "\uf0e7";
        }
        return "\uf24e";
    }

    MaterialIconButton {
        anchors.fill: parent
        type: MaterialIconButton.Standard
        shape: MaterialIconButton.Round
        iconText: root.iconOf(PowerProfiles.profile)
        iconSize: 24
        iconColor: PowerProfiles.profile === PowerProfiles.Performance ? Theme.primary : Theme.onSurfaceVariantColor
        onClicked: PowerProfiles.cycle()
        color: Theme.background
    }
}
