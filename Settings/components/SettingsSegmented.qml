import QtQuick
import Ryu.Extraa
import qs.services.theme

MaterialSegmentedButton {
    signal picked(int index)

    selectionMode: MaterialSegmentedButton.Single
    color: "transparent"
    checkedColor: Theme.secondaryContainer
    textColor: Theme.onSurfaceVariantColor
    checkedTextColor: Theme.onSecondaryContainerColor
    borderColor: Theme.outline

    onToggled: (index, checked) => {
        if (checked)
            picked(index);
    }
}
