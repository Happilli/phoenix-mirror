import QtQuick
import Ryu.Extraa
import px.services.theme

MaterialButtonGroup {
    signal picked(int index)

    variant: MaterialButtonGroup.Connected
    sizeStyle: MaterialButtonGroup.ExtraSmall
    selectionMode: MaterialButtonGroup.Single
    color: Theme.surfaceContainerHighest
    checkedColor: Theme.primary
    textColor: Theme.onSurfaceVariantColor
    checkedTextColor: Theme.onPrimaryColor

    onToggled: (index, checked) => {
        if (checked)
            picked(index);
    }
}
