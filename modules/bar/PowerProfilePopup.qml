import QtQuick
import Quickshell.Services.UPower
import Ryu.Extraa
import qs.services.theme

Item {
    id: root

    required property bool active

    readonly property var profiles: PowerProfiles.hasPerformanceProfile ? [PowerProfile.PowerSaver, PowerProfile.Balanced, PowerProfile.Performance] : [PowerProfile.PowerSaver, PowerProfile.Balanced]
    readonly property var profileIcons: ["\uf06c", "\uf24e", "\uf0e7"].slice(0, profiles.length)

    anchors.centerIn: parent
    implicitWidth: group.implicitWidth
    implicitHeight: group.implicitHeight
    visible: active

    MaterialButtonGroup {
        id: group
        anchors.centerIn: parent
        icons: root.profileIcons
        selectionMode: MaterialButtonGroup.Single
        currentIndex: root.profiles.indexOf(PowerProfiles.profile)
        variant: MaterialButtonGroup.Connected
        sizeStyle: MaterialButtonGroup.ExtraSmall
        color: Theme.surfaceContainerHighest
        checkedColor: Theme.primary
        textColor: Theme.onSurfaceVariantColor
        checkedTextColor: Theme.onPrimaryColor

        onToggled: (index, checked) => PowerProfiles.profile = root.profiles[index]
    }
}
