pragma ComponentBehavior: Bound
import QtQuick
import qs.services.theme
import qs.configuration.Hypr

Item {
    id: root

    property string title: ""
    property string description: ""
    property var keys: []

    default property alias content: group.entries
    readonly property bool dirty: HyprConfig.isDirty(keys)

    width: parent ? parent.width : 0
    height: col.implicitHeight

    component FooterButton: Rectangle {
        id: btn

        property string label: ""
        property bool primary: false
        signal clicked

        width: 92
        height: 36
        radius: 18
        color: primary ? Theme.primary : "transparent"
        border.width: primary ? 0 : 1
        border.color: Theme.outlineVariant
        opacity: root.dirty ? 1 : 0.35

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: btn.primary ? Theme.onPrimaryColor : Theme.onSurfaceVariantColor
            opacity: area.pressed ? 0.16 : (area.containsMouse ? 0.08 : 0)
        }

        Text {
            anchors.centerIn: parent
            text: btn.label
            font.pixelSize: 13
            font.weight: Font.DemiBold
            color: btn.primary ? Theme.onPrimaryColor : Theme.onSurfaceVariantColor
        }

        MouseArea {
            id: area
            anchors.fill: parent
            enabled: root.dirty
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: btn.clicked()
        }
    }

    Column {
        id: col
        width: parent.width
        spacing: 10

        Column {
            x: 6
            width: parent.width - 12
            spacing: 2

            Row {
                spacing: 10

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.title.toUpperCase()
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                    font.letterSpacing: 1.2
                    color: Theme.primary
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: root.dirty
                    text: "unsaved"
                    font.pixelSize: 11
                    color: Theme.onSurfaceVariantColor
                    opacity: 0.7
                }
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

        SettingsGroup {
            id: group
        }

        Item {
            width: parent.width
            height: 36

            Row {
                anchors.right: parent.right
                spacing: 8

                FooterButton {
                    label: "Cancel"
                    onClicked: HyprConfig.cancel(root.keys)
                }

                FooterButton {
                    label: "Save"
                    primary: true
                    onClicked: HyprConfig.save(root.keys)
                }
            }
        }
    }
}
