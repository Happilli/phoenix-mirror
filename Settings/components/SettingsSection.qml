import QtQuick
import qs.services.theme

Rectangle {
    id: root

    property string title: ""

    default property alias content: body.data

    width: parent ? parent.width : 0
    implicitHeight: col.implicitHeight + 36
    radius: 22
    color: Theme.surfaceContainer

    Column {
        id: col
        x: 18
        y: 18
        width: parent.width - 36
        spacing: 14

        Text {
            visible: root.title !== ""
            text: root.title.toUpperCase()
            font.pixelSize: 11
            font.weight: Font.DemiBold
            font.letterSpacing: 1.2
            color: Theme.primary
            opacity: 0.8
        }

        Column {
            id: body
            width: parent.width
            spacing: 14
        }
    }
}
