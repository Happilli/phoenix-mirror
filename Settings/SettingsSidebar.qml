import QtQuick
import Ryu.Extraa
import qs.services.theme
import qs.configuration.Settings

Item {
    Text {
        x: 28
        y: 28
        text: "Settings"
        font.pixelSize: 22
        font.weight: Font.DemiBold
        color: Theme.onBackgroundColor
    }

    MaterialList {
        x: 12
        y: 84
        width: parent.width - 24
        model: SettingsConfig.pages
        variant: MaterialList.Segmented
        selectionMode: MaterialList.Single
        currentIndex: SettingsConfig.pageIndex
        itemColor: Theme.surfaceContainer
        selectedColor: Qt.alpha(Theme.primary, 0.2)
        textColor: Theme.onBackgroundColor
        selectedTextColor: Theme.primary
        supportingColor: Theme.onSurfaceVariantColor
        onClicked: (index, item) => SettingsConfig.go(item.key)
    }
}
