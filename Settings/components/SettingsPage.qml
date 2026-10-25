import QtQuick
import Quickshell.Widgets
import qs.services.theme

Item {
    id: root

    property string title: ""
    readonly property real cardRadius: 14
    readonly property real margin: width < 720 ? 16 : 28
    readonly property real headerMaxHeight: height * 0.36

    default property alias content: body.data
    property alias header: headerSlot.data

    Column {
        id: topper
        x: root.margin
        y: root.margin
        width: parent.width - root.margin * 2
        spacing: 16

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
        anchors.topMargin: 16
        anchors.bottom: parent.bottom
        anchors.bottomMargin: root.margin
        anchors.left: parent.left
        anchors.leftMargin: root.margin
        anchors.right: parent.right
        anchors.rightMargin: root.margin
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
