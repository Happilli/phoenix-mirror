import QtQuick
import Quickshell.Services.UPower
import Ryu.Extraa
import qs.services.theme

Item {
    id: root
    implicitWidth: 40
    implicitHeight: 40

    function iconOf(profile) {
        switch (profile) {
        case PowerProfile.PowerSaver:
            return "\uf06c";
        case PowerProfile.Performance:
            return "\uf0e7";
        }
        return "\uf24e";
    }

    function cycle() {
        const p = PowerProfiles.profile;
        if (p === PowerProfile.PowerSaver)
            PowerProfiles.profile = PowerProfile.Balanced;
        else if (p === PowerProfile.Balanced && PowerProfiles.hasPerformanceProfile)
            PowerProfiles.profile = PowerProfile.Performance;
        else
            PowerProfiles.profile = PowerProfile.PowerSaver;
    }

    MaterialIconButton {
        anchors.fill: parent
        type: MaterialIconButton.Standard
        shape: MaterialIconButton.Round
        iconText: root.iconOf(PowerProfiles.profile)
        iconSize: 24
        iconColor: PowerProfiles.profile === PowerProfile.Performance ? Theme.primary : Theme.onSurfaceVariantColor
        onClicked: root.cycle()
        color: Theme.surfaceContainerHighest
    }
}
