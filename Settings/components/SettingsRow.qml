import QtQuick
import qs.services.theme

Item {
    id: root

    property string label: ""
    property string description: ""

    default property alias control: slot.data

    width: parent ? parent.width : 0
    height: Math.max(44, textCol.implicitHeight, slot.height)

    Column {
        id: textCol
        anchors.left: parent.left
        anchors.right: slot.left
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2
        opacity: root.enabled ? 1 : 0.4

        Text {
            width: parent.width
            text: root.label
            font.pixelSize: 14
            font.weight: Font.Medium
            color: Theme.onBackgroundColor
        }

        Text {
            width: parent.width
            visible: text !== ""
            text: root.description
            wrapMode: Text.Wrap
            font.pixelSize: 12
            color: Theme.onSurfaceVariantColor
            opacity: 0.7
        }
    }

    Item {
        id: slot
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: childrenRect.width
        height: childrenRect.height
    }
}
