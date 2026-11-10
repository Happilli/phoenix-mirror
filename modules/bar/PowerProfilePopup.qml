import QtQuick
import Ryu.Extraa
import Ryu.Power
import px.services.theme

Item {
    id: root

    required property bool active

    readonly property var iconTable: ["\uf06c", "\uf24e", "\uf0e7"]
    readonly property var profiles: PowerProfiles.profiles
    readonly property var profileIcons: profiles.map(p => iconTable[p])

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

        onToggled: (index, checked) => {
            if (checked)
                PowerProfiles.profile = root.profiles[index];
        }
    }
}
