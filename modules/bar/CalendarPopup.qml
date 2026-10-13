pragma ComponentBehavior: Bound
import QtQuick
import Ryu.Warsa
import qs.services.theme

Item {
    id: root

    required property bool active

    readonly property int cellSize: 38
    readonly property var dayLabels: ["Ai", "So", "Ma", "Bu", "Bi", "Su", "Sa"]
    readonly property int firstOffset: warsa.getFirstDayOfMonth(warsa.month)
    readonly property int monthLength: warsa.daysInCurrentMonth
    readonly property string title: warsa.monthName.charAt(0).toUpperCase() + warsa.monthName.slice(1) + " " + warsa.year

    Warsa {
        id: warsa
        Component.onCompleted: setToday()
    }

    onActiveChanged: if (!active)
        warsa.setToday()

    anchors.centerIn: parent
    implicitWidth: col.implicitWidth
    implicitHeight: col.implicitHeight
    visible: active

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        onWheel: wheel => wheel.angleDelta.y > 0 ? warsa.previousMonth() : warsa.nextMonth()
    }

    Column {
        id: col
        anchors.centerIn: parent
        spacing: 6

        Item {
            width: root.cellSize * 7
            height: root.cellSize

            Rectangle {
                width: root.cellSize
                height: root.cellSize
                radius: height / 2
                opacity: warsa.month > 1 ? 1 : 0.3
                color: prevArea.containsMouse ? Theme.surfaceContainerHighest : "transparent"
                Text {
                    anchors.centerIn: parent
                    text: "<"
                    font.pixelSize: 22
                    font.bold: true
                    color: Theme.onSurfaceVariantColor
                }
                MouseArea {
                    id: prevArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: warsa.previousMonth()
                }
            }

            Text {
                anchors.centerIn: parent
                text: root.title
                font.pixelSize: 16
                font.bold: true
                color: Theme.primary
            }

            Rectangle {
                anchors.right: parent.right
                width: root.cellSize
                height: root.cellSize
                radius: height / 2
                opacity: warsa.month < 12 ? 1 : 0.3
                color: nextArea.containsMouse ? Theme.surfaceContainerHighest : "transparent"
                Text {
                    anchors.centerIn: parent
                    text: ">"
                    font.pixelSize: 22
                    font.bold: true
                    color: Theme.onSurfaceVariantColor
                }
                MouseArea {
                    id: nextArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: warsa.nextMonth()
                }
            }
        }

        Row {
            Repeater {
                model: root.dayLabels
                Item {
                    id: label
                    required property string modelData
                    required property int index
                    width: root.cellSize
                    height: 24
                    Text {
                        anchors.centerIn: parent
                        text: label.modelData
                        font.pixelSize: 13
                        font.bold: true
                        color: label.index === 6 ? Theme.error : Theme.onSurfaceVariantColor
                        opacity: 0.7
                    }
                }
            }
        }

        Grid {
            columns: 7
            Repeater {
                model: 42
                Item {
                    id: cell
                    required property int index

                    readonly property int dayNumber: index - root.firstOffset + 1
                    readonly property bool valid: dayNumber >= 1 && dayNumber <= root.monthLength
                    readonly property bool isToday: valid && warsa.isToday(warsa.year, warsa.month, dayNumber)
                    readonly property bool isSaturday: index % 7 === 6

                    width: root.cellSize
                    height: root.cellSize

                    Rectangle {
                        anchors.centerIn: parent
                        width: root.cellSize - 4
                        height: width
                        radius: 10
                        color: Theme.primary
                        visible: cell.isToday
                    }
                    Text {
                        anchors.centerIn: parent
                        visible: cell.valid
                        text: cell.dayNumber
                        font.pixelSize: 15
                        font.bold: cell.isToday
                        color: cell.isToday ? Theme.onPrimaryColor : cell.isSaturday ? Theme.error : Theme.onSurfaceVariantColor
                    }
                }
            }
        }
    }
}
