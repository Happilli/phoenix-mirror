pragma ComponentBehavior: Bound
import QtQuick
import Ryu.Extraa
import px.services.theme
import px.configuration.Settings

Item {
    id: root

    readonly property bool searching: search.activeFocus

    signal dismissed
    signal picked(string key, string page)

    implicitHeight: 64

    Text {
        id: title
        anchors.left: root.left
        anchors.verticalCenter: root.verticalCenter
        text: SettingsConfig.currentTitle
        font.pixelSize: 26
        font.weight: Font.DemiBold
        color: Theme.onBackgroundColor
    }

    Item {
        id: slot

        readonly property real searchScale: 0.85
        readonly property real avail: Math.max(160, root.width - title.implicitWidth - 48)
        readonly property real restWidth: Math.min(240, slot.avail)
        readonly property real focusWidth: Math.min(380, slot.avail)

        property real wantWidth: root.searching ? slot.focusWidth : slot.restWidth

        anchors.right: root.right
        anchors.verticalCenter: root.verticalCenter
        width: slot.wantWidth
        height: 56 * slot.searchScale

        Behavior on wantWidth {
            SpringAnimation {
                spring: 3.5
                damping: 0.2
                epsilon: 0.25
            }
        }

        MaterialSearchBox {
            id: search
            anchors.right: slot.right
            anchors.verticalCenter: slot.verticalCenter
            anchors.leftMargin: 10
            width: slot.width / slot.searchScale
            scale: slot.searchScale
            transformOrigin: Item.Right

            placeholderText: "Search settings"
            text: SettingsConfig.query

            springStiffness: 700
            springDamping: 0.3

            color: Theme.surfaceContainerHighest
            textColor: Theme.onSurfaceVariantColor
            placeholderColor: Theme.onSurfaceVariantColor
            iconColor: Theme.onSurfaceVariantColor
            cursorColor: Theme.primary
            borderWidth: 2
            borderColor: "transparent"
            selectionColor: Theme.primaryContainer

            onTextEdited: SettingsConfig.query = search.text
            onAccepted: view.triggerCurrent()

            Keys.onDownPressed: view.moveCurrent(1)
            Keys.onUpPressed: view.moveCurrent(-1)
            Keys.onEscapePressed: root.dismissed()
        }
    }

    MaterialSearchView {
        id: view
        z: 20

        property real shownHeight: view.contentHeight

        anchors.right: root.right
        anchors.top: root.bottom
        width: Math.min(440, root.width)
        height: Math.max(0, view.shownHeight)

        open: root.searching
        model: SettingsConfig.results
        emptyText: "No matching settings"

        color: Theme.background
        textColor: Theme.onBackgroundColor
        supportingColor: Theme.onSurfaceVariantColor
        iconColor: Theme.onSurfaceVariantColor
        highlightColor: Theme.surfaceContainerHighest
        borderWidth: 1
        borderColor: Theme.outlineVariant

        Behavior on shownHeight {
            SpringAnimation {
                spring: 3.5
                damping: 0.3
                epsilon: 0.25
            }
        }

        onTriggered: (index, item) => root.picked(item.key, item.page)
    }
}
