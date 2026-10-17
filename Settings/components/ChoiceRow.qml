import QtQuick
import Ryu.Extraa
import qs.services.theme

SettingsRow {
    id: root

    property var labels: []
    property int currentIndex: 0

    signal picked(int index)

    MaterialButtonGroup {
        labels: root.labels
        selectionMode: MaterialButtonGroup.Single
        currentIndex: root.currentIndex
        variant: MaterialButtonGroup.Connected
        sizeStyle: MaterialButtonGroup.ExtraSmall
        color: Theme.surfaceContainerHighest
        checkedColor: Theme.primary
        textColor: Theme.onSurfaceVariantColor
        checkedTextColor: Theme.onPrimaryColor
        onToggled: (index, checked) => {
            if (checked)
                root.picked(index);
        }
    }
}
