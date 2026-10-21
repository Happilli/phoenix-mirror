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
        default property alias control: slot.data

        width: parent ? parent.width : 0
        height: Math.max(68, textCol.implicitHeight + 28, slot.height + 28)

        Column {
            id: textCol
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.right: slot.left
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter
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
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            width: childrenRect.width
            height: childrenRect.height
        }
    }

    Column {
        id: col
        width: parent.width
    }
}
