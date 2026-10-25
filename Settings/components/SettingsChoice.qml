import QtQuick
import Ryu.Extraa
import qs.services.theme

MaterialButtonGroup {
    signal picked(int index)

    selectionMode: MaterialButtonGroup.Single
    variant: MaterialButtonGroup.Connected
    sizeStyle: MaterialButtonGroup.ExtraSmall
    color: Theme.surfaceContainerHighest
    checkedColor: Theme.primary
    textColor: Theme.onSurfaceVariantColor
    checkedTextColor: Theme.onPrimaryColor

    onToggled: (index, checked) => {
        if (checked)
            picked(index);
    }
}
