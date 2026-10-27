import QtQuick
import qs.configuration.Hypr

SettingsGroup.Entry {
    id: row

    property string prop: ""

    SettingsSwitch {
        checked: !!HyprConfig.get(row.prop)
        onToggled: HyprConfig.set(row.prop, checked)
    }
}
