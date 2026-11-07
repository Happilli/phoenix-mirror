pragma ComponentBehavior: Bound
import QtQuick
import qs.services.theme
import qs.services.dailywar

Item {
    id: root

    required property bool active

    readonly property int contentWidth: 300

    property real enter: 0

    function difficultyColor(d) {
        switch (d.toLowerCase()) {
        case "easy":
            return Theme.primary;
        case "medium":
            return Theme.tertiary;
        case "hard":
            return Theme.error;
        }
        return Theme.onSurfaceVariantColor;
    }

    anchors.centerIn: parent
    implicitWidth: contentWidth
    implicitHeight: column.implicitHeight
    visible: active

    Component.onCompleted: enter = 1

    Behavior on enter {
        NumberAnimation {
            duration: 260
            easing.type: Easing.OutCubic
        }
    }

    Column {
        id: column
        x: 0
        y: (1 - root.enter) * 8
        width: root.contentWidth
        spacing: 12
        opacity: root.enter

        Item {
            width: parent.width
            height: heading.implicitHeight

            Text {
                id: heading
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: "DAILY WAR"
                font.pixelSize: 11
                font.weight: Font.DemiBold
                font.letterSpacing: 1.2
                color: Theme.primary
                opacity: 0.8
            }

            Text {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                visible: text !== ""
                text: DailyWarService.date
                font.pixelSize: 11
                color: Theme.onSurfaceVariantColor
                opacity: 0.55
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: Theme.outlineVariant
        }

        Column {
            width: parent.width
            spacing: 6

            Text {
                width: parent.width
                text: DailyWarService.loaded ? DailyWarService.challengeTitle : "No pick yet"
                wrapMode: Text.Wrap
                font.pixelSize: 17
                font.weight: Font.DemiBold
                color: Theme.onBackgroundColor
            }

            Text {
                width: parent.width
                visible: text !== ""
                text: DailyWarService.challengeDetail
                wrapMode: Text.Wrap
                maximumLineCount: 5
                elide: Text.ElideRight
                lineHeight: 1.35
                font.pixelSize: 13
                color: Theme.onSurfaceVariantColor
                opacity: 0.85
            }
        }

        Row {
            spacing: 8
            visible: DailyWarService.languageName !== "" || DailyWarService.difficulty !== ""

            Rectangle {
                visible: DailyWarService.languageName !== ""
                width: langText.implicitWidth + 24
                height: 30
                radius: 10
                color: Theme.surfaceContainerHighest
                border.width: 1
                border.color: Theme.outlineVariant

                Text {
                    id: langText
                    anchors.centerIn: parent
                    text: DailyWarService.languageName
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                    color: Theme.primary
                }
            }

            Rectangle {
                id: diffChip
                readonly property color tone: root.difficultyColor(DailyWarService.difficulty)
                visible: DailyWarService.difficulty !== ""
                width: diffText.implicitWidth + 24
                height: 30
                radius: 10
                color: Theme.surfaceContainerHighest
                border.width: 1
                border.color: tone

                Text {
                    id: diffText
                    anchors.centerIn: parent
                    text: DailyWarService.difficulty
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                    color: diffChip.tone
                }
            }
        }
    }
}
