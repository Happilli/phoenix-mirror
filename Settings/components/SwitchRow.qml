import QtQuick
import Ryu.Extraa
import qs.services.theme

SettingsRow {
    id: root

    property bool checked: false

    signal toggled(bool value)

    MaterialSwitch {
        id: sw
        checked: root.checked
        trackColor: Theme.surfaceContainerHighest
        checkedTrackColor: Theme.primary
        handleColor: Theme.onSurfaceVariantColor
        checkedHandleColor: Theme.onPrimaryColor
        borderColor: Qt.alpha(Theme.onSurfaceVariantColor, 0.6)
        onToggled: root.toggled(sw.checked)
    }
}
