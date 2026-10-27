import QtQuick
import Ryu.Extraa
import qs.services.theme

MaterialCheckbox {
    color: Theme.primary
    uncheckedColor: Theme.onSurfaceVariantColor
    checkmarkColor: Theme.onPrimaryColor
    textColor: Theme.onBackgroundColor
    errorColor: Theme.error
}
