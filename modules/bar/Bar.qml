import QtQuick
import QtQuick.Shapes
import qs.services.theme

Item {
    id: root
    property real radius
    property color colour
    property var screen
    readonly property Item popupS: controls.popupItem

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            pathHints: ShapePath.PathSolid | ShapePath.PathNonIntersecting
            fillColor: root.colour
            strokeWidth: 0
            startX: 0
            startY: root.height

            PathLine {
                x: 0
                y: 0
            }
            PathQuad {
                controlX: 0
                controlY: root.radius
                x: root.radius
                y: root.radius
            }
            PathLine {
                x: root.width - root.radius
                y: root.radius
            }
            PathQuad {
                controlX: root.width
                controlY: root.radius
                x: root.width
                y: 0
            }
            PathLine {
                x: root.width
                y: root.height
            }
        }
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            width: 120
            height: 40
            color: Theme.primary
            radius: 20
            Text {
                text: Theme.isDark ? "light" : "dark"
                anchors.centerIn: parent
                color: Theme.onPrimaryColor
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Theme.toggleMode()
            }
        }
        Workspace {
            id: workspace
            screen: root.screen
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.verticalCenterOffset: root.radius / 2
            anchors.leftMargin: root.radius / 2 + 16
        }
        OpenedApp {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: workspace.right
            anchors.verticalCenterOffset: root.radius / 2
            anchors.leftMargin: root.radius / 2 + 16
        }

        Battery {
            id: battery
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.verticalCenterOffset: root.radius / 2
            anchors.rightMargin: root.radius / 2 + 16
        }
        Controls {
            id: controls
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: datetime.left
            anchors.verticalCenterOffset: root.radius / 2
            anchors.rightMargin: root.radius
        }
        DateTime {
            id: datetime
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: battery.left
            anchors.verticalCenterOffset: root.radius / 2
            anchors.rightMargin: root.radius
        }
        NotificationsIndicator {
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: datetime.left
            anchors.verticalCenterOffset: root.radius / 2
            anchors.rightMargin: root.radius
        }
    }
}
