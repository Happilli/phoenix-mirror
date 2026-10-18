import QtQuick
import qs.services.theme

Item {
    id: root

    property string title: ""

    default property alias content: body.data
    property alias header: headerSlot.data

    Column {
        id: topper
        x: 28
        y: 28
        width: parent.width - 56
        spacing: 18

        Text {
            text: root.title
            font.pixelSize: 26
            font.weight: Font.DemiBold
            color: Theme.onBackgroundColor
        }

        Item {
            id: headerSlot
            width: parent.width
            height: childrenRect.height
            visible: height > 0
        }
    }

    Flickable {
        anchors.top: topper.bottom
        anchors.topMargin: 18
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        contentWidth: width
        contentHeight: body.implicitHeight + 28
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: body
            x: 28
            width: parent.width - 56
            spacing: 14
        }
    }
}
