import QtQuick
import Quickshell.Widgets
import qs.services.theme

Item {
    id: root

    property string title: ""
    readonly property real cardRadius: 14

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

    ClippingRectangle {
        anchors.top: topper.bottom
        anchors.topMargin: 18
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 28
        anchors.right: parent.right
        anchors.rightMargin: 28
        radius: root.cardRadius
        color: "transparent"

        Flickable {
            anchors.fill: parent
            contentWidth: width
            contentHeight: body.implicitHeight
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: body
                width: parent.width
                spacing: 14
            }
        }
    }
}
