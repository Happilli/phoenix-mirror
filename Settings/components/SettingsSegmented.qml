import QtQuick
import Ryu.Extraa
import px.services.theme

MaterialSegmentedButton {
    signal picked(int index)

    selectionMode: MaterialSegmentedButton.Single
    color: "transparent"
    checkedColor: Theme.primary
    textColor: Theme.onSurfaceVariantColor
    checkedTextColor: Theme.onPrimaryColor
    borderColor: Theme.outline

    onToggled: (index, checked) => {
        if (checked)
            picked(index);
    }
}
