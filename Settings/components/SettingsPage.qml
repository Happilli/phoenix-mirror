import QtQuick
import px.configuration.Settings

Item {
    id: root

    property string title: ""
    readonly property real margin: 0
    readonly property real headerMaxHeight: height * 0.36

    default property alias content: body.data
    property alias header: headerSlot.data

    Column {
        id: topper
        x: root.margin
        y: root.margin
        width: parent.width - root.margin * 2
        spacing: 8

        Item {
            id: headerSlot
            width: parent.width
            height: childrenRect.height
            visible: height > 0
        }
    }

    Flickable {
        id: flick
        anchors.top: topper.bottom
        anchors.topMargin: 8
        anchors.bottom: parent.bottom
        anchors.bottomMargin: root.margin
        anchors.left: parent.left
        anchors.leftMargin: root.margin
        anchors.right: parent.right
        anchors.rightMargin: root.margin
        clip: true
        contentWidth: width
        contentHeight: body.implicitHeight
        boundsBehavior: Flickable.StopAtBounds

        Component.onCompleted: SettingsConfig.scroller = flick
        Component.onDestruction: if (SettingsConfig.scroller === flick)
            SettingsConfig.scroller = null

        Column {
            id: body
            width: parent.width
            spacing: 14
        }
    }
}
