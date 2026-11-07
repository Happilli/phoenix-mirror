pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Ryu.Extraa
import qs.services.theme
import qs.services.notifications
import qs.configuration.Notification

Item {
    id: root

    required property string screenName

    width: 380
    height: Math.min(column.implicitHeight, 1000)

    ListModel {
        id: notifications
    }

    Column {
        id: column

        spacing: 0

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }

        Repeater {
            model: notifications

            delegate: NotificationDelegate {}
        }
    }

    Connections {
        target: NotificationsService

        function onNotificationReady(n) {
            if (n.screenName !== root.screenName) {
                return;
            }
            notifications.insert(0, {
                "notifId": n.id,
                "summary": n.summary,
                "body": n.body,
                "appName": n.appName,
                "image": n.image,
                "appIcon": n.appIcon
            });
            while (notifications.count > NotificationConfig.maxVisible) {
                notifications.remove(notifications.count - 1);
            }
        }

        function onDismissNotification(id) {
            for (let i = 0; i < notifications.count; i++) {
                if (notifications.get(i).notifId === id) {
                    notifications.remove(i);
                    return;
                }
            }
        }
    }

    component NotificationDelegate: Item {
        id: tile

        required property int index
        required property int notifId
        required property string summary
        required property string body
        required property string appName
        required property string image
        required property string appIcon

        readonly property string displaySummary: summary || "Notification"
        readonly property string displayBody: body || ""
        readonly property string displayApp: appName || ""
        readonly property string iconSource: {
            if (image !== "") {
                return image;
            }
            if (appIcon === "") {
                return "";
            }
            return appIcon.startsWith("/") ? "file://" + appIcon : Quickshell.iconPath(appIcon, true);
        }
        readonly property bool isTop: index === 0
        readonly property bool overflows: ruler.implicitHeight > (13 * 1.4 * NotificationConfig.collapsedLines) + 2
        readonly property real naturalHeight: content.implicitHeight + 28

        property bool expanded: false
        property bool entering: true
        property bool exiting: false
        property bool collapsing: false
        property bool dismissed: false
        property real progress: 0

        property real slide: (entering || exiting) ? 0 : 1
        property real grow: (entering || collapsing) ? 0 : 1
        property real pop: (entering || exiting) ? 0 : 1
        readonly property real growClamped: Math.max(0, Math.min(1, grow))

        function tryEnter() {
            if (naturalHeight <= 28) {
                Qt.callLater(tryEnter);
                return;
            }
            entering = false;
            readyTimer.start();
        }

        function beginExit() {
            if (!exiting) {
                exiting = true;
            }
        }

        width: column.width
        height: (naturalHeight + 8) * growClamped
        visible: height > 0.5

        Component.onCompleted: Qt.callLater(tryEnter)

        onSlideChanged: {
            if (exiting && !collapsing && slide <= 0.02) {
                collapsing = true;
            }
        }

        onGrowChanged: {
            if (collapsing && !dismissed && grow <= 0.01) {
                dismissed = true;
                NotificationsService.dismiss(notifId);
            }
        }

        Behavior on slide {
            SpringAnimation {
                spring: 3.5
                damping: 0.28
                mass: 1
                epsilon: 0.002
            }
        }

        Behavior on grow {
            SpringAnimation {
                spring: 3.5
                damping: 0.6
                epsilon: 0.003
            }
        }

        Behavior on pop {
            SpringAnimation {
                spring: 4
                damping: 0.22
                epsilon: 0.002
            }
        }

        HoverHandler {
            id: hover
        }
        TapHandler {
            acceptedButtons: Qt.RightButton
            onTapped: tile.beginExit()
        }

        Item {
            id: slider

            width: tile.width
            height: tile.naturalHeight
            x: (1 - tile.slide) * 420
            scale: 0.9 + 0.1 * tile.pop
            transformOrigin: Item.Center

            Rectangle {
                id: card

                anchors.fill: parent
                radius: 18
                color: Theme.background
                border.width: 1
                border.color: Theme.outlineVariant

                Column {
                    id: content

                    spacing: 10

                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: 14
                    }

                    Item {
                        width: content.width
                        height: tile.isTop ? 2 : 0
                        visible: tile.isTop

                        Rectangle {
                            id: progressBar

                            width: parent.width * tile.progress
                            height: 2
                            radius: 1
                            color: Theme.primary
                        }
                    }

                    RowLayout {
                        width: content.width
                        spacing: 10
                        visible: tile.displayApp !== ""

                        Rectangle {
                            id: letterTile
                            Layout.preferredWidth: 36
                            Layout.preferredHeight: 36
                            Layout.alignment: Qt.AlignVCenter
                            radius: 10
                            color: Theme.surfaceContainerHighest
                            visible: tile.iconSource === ""
                            scale: 0.7 + 0.3 * tile.pop

                            Text {
                                anchors.centerIn: parent
                                text: tile.displayApp.charAt(0).toUpperCase()
                                color: Theme.primary
                                font.pixelSize: 17
                                font.bold: true
                            }
                        }

                        Image {
                            Layout.preferredWidth: 36
                            Layout.preferredHeight: 36
                            Layout.alignment: Qt.AlignVCenter
                            visible: tile.iconSource !== ""
                            source: tile.iconSource
                            fillMode: Image.PreserveAspectFit
                            asynchronous: true
                            cache: false
                            sourceSize.width: 72
                            sourceSize.height: 72
                            scale: 0.7 + 0.3 * tile.pop
                        }

                        Text {
                            Layout.alignment: Qt.AlignVCenter
                            text: tile.displayApp
                            color: Theme.onSurfaceVariantColor
                            opacity: 0.7
                            font.pixelSize: 11
                            font.weight: Font.Medium
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        MaterialIconButton {
                            Layout.preferredWidth: 30
                            Layout.preferredHeight: 30
                            Layout.alignment: Qt.AlignVCenter
                            visible: tile.overflows
                            type: MaterialIconButton.Standard
                            shape: MaterialIconButton.Round
                            iconText: "\uf054"
                            iconSize: 13
                            iconColor: Theme.onSurfaceVariantColor
                            rotation: tile.expanded ? 90 : 0
                            onClicked: tile.expanded = !tile.expanded

                            Behavior on rotation {
                                SpringAnimation {
                                    spring: 4
                                    damping: 0.22
                                    epsilon: 0.1
                                }
                            }
                        }
                    }

                    Text {
                        text: tile.displaySummary
                        width: content.width
                        color: Theme.primary
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                    }

                    Item {
                        width: content.width
                        height: bodyText.implicitHeight
                        visible: tile.displayBody !== ""
                        clip: true

                        Text {
                            id: bodyText

                            text: tile.displayBody
                            width: parent.width
                            font.pixelSize: 13
                            color: Theme.onSurfaceVariantColor
                            wrapMode: Text.Wrap
                            lineHeight: 1.4
                            maximumLineCount: tile.expanded ? 9999 : NotificationConfig.collapsedLines
                            elide: Text.ElideRight
                        }

                        Behavior on height {
                            SpringAnimation {
                                spring: 3.5
                                damping: 0.4
                                epsilon: 0.2
                            }
                        }
                    }
                }
            }
        }

        Text {
            id: ruler

            text: tile.displayBody
            width: tile.width - 28
            font.pixelSize: 13
            wrapMode: Text.Wrap
            lineHeight: 1.4
            visible: false
        }

        Timer {
            id: readyTimer

            interval: NotificationConfig.enterHeightDuration + NotificationConfig.enterSlideDuration
            onTriggered: NotificationsService.onItemEntered()
        }

        NumberAnimation {
            id: countdown
            target: tile
            property: "progress"
            from: 0
            to: 1
            duration: NotificationConfig.autoCloseDuration
            running: tile.isTop && !tile.entering && !tile.exiting
            onFinished: tile.beginExit()
        }

        Binding {
            target: countdown
            property: "paused"
            value: hover.hovered
            when: countdown.running
        }
    }
}
