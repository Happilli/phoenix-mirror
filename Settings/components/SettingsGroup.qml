import QtQuick
import qs.services.theme

Item {
    id: root

    default property alias entries: col.data

    width: parent ? parent.width : 0
    height: col.implicitHeight

    component Entry: Item {
        id: entry

        property string title: ""
        property string description: ""
        property real minHeight: 0
        default property alias control: slot.data

        readonly property bool stacked: width < 560
        readonly property real pad: 20

        width: parent ? parent.width : 0
        height: Math.max(minHeight, stacked ? textCol.implicitHeight + slot.height + (slot.height > 0 ? 12 : 0) + 28 : Math.max(68, textCol.implicitHeight + 28, slot.height + 28))

        Column {
            id: textCol
            x: entry.pad
            y: entry.stacked ? 14 : (entry.height - height) / 2
            width: entry.stacked ? entry.width - entry.pad * 2 : Math.max(0, entry.width - entry.pad * 2 - slot.width - 16)
            spacing: 2

            Text {
                width: parent.width
                text: entry.title
                wrapMode: Text.Wrap
                font.pixelSize: 15
                font.weight: Font.Medium
                color: Theme.onBackgroundColor
            }

            Text {
                width: parent.width
                visible: text !== ""
                text: entry.description
                wrapMode: Text.Wrap
                font.pixelSize: 12
                color: Theme.onSurfaceVariantColor
                opacity: 0.75
            }
        }

        Item {
            id: slot

            readonly property real limit: entry.stacked ? entry.width - entry.pad * 2 : Math.max(160, (entry.width - entry.pad * 2) * 0.55)

            x: entry.stacked ? entry.pad : entry.width - entry.pad - width
            y: entry.stacked ? textCol.y + textCol.implicitHeight + 12 : (entry.height - height) / 2
            width: childrenRect.width
            height: childrenRect.height
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 14
        color: Theme.surfaceContainerLow
    }

    Column {
        id: col
        width: parent.width
    }
}
