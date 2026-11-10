import QtQuick
import Ryu.Extraa
import px.services.theme

MaterialChip {
    autoToggle: false
    color: elevated ? Theme.surfaceContainerLow : "transparent"
    contentColor: Theme.onSurfaceVariantColor
    iconColor: contentColor
    selectedColor: Theme.primary
    selectedContentColor: Theme.onPrimaryColor
    borderColor: Theme.outline
    avatarColor: Theme.primaryContainer
    avatarTextColor: Theme.onPrimaryContainerColor
}
