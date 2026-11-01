pragma ComponentBehavior: Bound
import QtQuick
import qs.services.theme
import qs.configuration.Hypr
import qs.configuration.Bar

Item {
    id: root

    property string title: ""
    property string description: ""
    property var keys: []

    default property alias content: group.entries
    readonly property bool dirty: HyprConfig.isDirty(keys)

    width: parent ? parent.width : 0
    height: col.implicitHeight

    component HeaderButton: Rectangle {
        id: btn

        property string label: ""
        property string glyph: ""
        property bool primary: false
        signal clicked

        readonly property color fg: primary ? Theme.onPrimaryColor : Theme.onSurfaceVariantColor

        width: 82
        height: 34
        radius: 17
        color: primary ? Theme.primary : Theme.surfaceContainerHighest
        scale: area.pressed ? 0.94 : 1

        Behavior on scale {
            SpringAnimation {
                spring: 5
                damping: 0.4
                epsilon: 0.005
            }
        }

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            visible: BarConfig.metallic

            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: btn.primary ? Qt.rgba(1, 1, 1, 0.32) : Qt.rgba(1, 1, 1, 0.12)
                }

                GradientStop {
                    position: 0.5
                    color: Qt.rgba(1, 1, 1, 0)
                }

                GradientStop {
                    position: 1.0
                    color: btn.primary ? Qt.rgba(0, 0, 0, 0.32) : Qt.rgba(0, 0, 0, 0.3)
                }
            }
        }

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: "transparent"
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.16)
            visible: BarConfig.metallic
        }

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: btn.fg
            opacity: area.pressed ? 0.16 : (area.containsMouse ? 0.08 : 0)
        }

        Row {
            anchors.centerIn: parent
            spacing: 6

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: btn.glyph
                font.pixelSize: 12
                color: btn.fg
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: btn.label
                font.pixelSize: 13
                font.weight: Font.DemiBold
                color: btn.fg
            }
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
        spacing: 0

        Item {
            id: head
            width: parent.width
            height: Math.max(actions.height, textCol.implicitHeight)
            Row {
                id: textCol
                x: 18
                anchors.verticalCenter: parent.verticalCenter
                width: Math.max(0, head.width - x - actions.width - 16)
                spacing: 10

                Text {
                    id: titleText
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.title
                    font.pixelSize: 24
                    font.weight: Font.DemiBold
                    font.capitalization: Font.MixedCase
                    color: root.dirty ? Theme.primary : Theme.onBackgroundColor

                    Behavior on color {
                        ColorAnimation {
                            duration: 180
                        }
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    width: Math.max(0, textCol.width - titleText.width - textCol.spacing)
                    visible: root.description !== ""
                    text: "[" + root.description + "]"
                    elide: Text.ElideRight
                    font.pixelSize: 15
                    color: Theme.onSurfaceVariantColor
                    opacity: 0.75
                }
            }
            Row {
                id: actions
                anchors.right: parent.right
                anchors.rightMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6
                opacity: root.dirty ? 1 : 0
                scale: 0.92 + 0.08 * opacity
                transformOrigin: Item.Right

                Behavior on opacity {
                    NumberAnimation {
                        duration: 160
                    }
                }

                HeaderButton {
                    label: "Undo"
                    glyph: "\uf0e2"
                    onClicked: HyprConfig.cancel(root.keys)
                }

                HeaderButton {
                    label: "Save"
                    glyph: "\uf00c"
                    primary: true
                    onClicked: HyprConfig.save(root.keys)
                }
            }
        }

        SettingsGroup {
            id: group
        }
    }
}
