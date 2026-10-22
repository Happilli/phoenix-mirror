pragma ComponentBehavior: Bound
import QtQuick
import Ryu.Extraa
import qs.services.theme
import qs.services.ryuski

Item {
    id: root

    required property bool active

    readonly property int contentWidth: 320
    readonly property int pad: 14
    readonly property int maxReplyHeight: 320
    readonly property string shown: RyuskiService.busy ? "..." : (reply !== "" ? reply : RyuskiService.notice)

    property string reply: ""
    property bool replyOk: true
    property real enter: 0

    signal closeRequested

    function send() {
        const t = input.text.trim();
        if (t === "" || !RyuskiService.ready || RyuskiService.busy)
            return;
        RyuskiService.submit(t);
        input.text = "";
    }

    anchors.centerIn: parent
    implicitWidth: contentWidth + pad * 2
    implicitHeight: column.implicitHeight + pad * 2
    visible: active

    Component.onCompleted: {
        enter = 1;
        input.forceActiveFocus();
        RyuskiService.warm();
    }

    Component.onDestruction: RyuskiService.cool()

    onActiveChanged: if (active)
        input.forceActiveFocus()

    Behavior on enter {
        NumberAnimation {
            duration: 260
            easing.type: Easing.OutCubic
        }
    }

    Connections {
        target: RyuskiService

        function onReplied(text, ok) {
            root.reply = text;
            root.replyOk = ok;
            flick.contentY = 0;
        }
    }

    Column {
        id: column
        x: root.pad
        y: root.pad + (1 - root.enter) * 8
        width: root.contentWidth
        spacing: 12
        opacity: root.enter

        Flickable {
            id: flick
            width: parent.width
            height: Math.min(replyText.implicitHeight, root.maxReplyHeight)
            visible: root.shown !== ""
            contentWidth: width
            contentHeight: replyText.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            Text {
                id: replyText
                width: flick.width
                text: root.shown
                wrapMode: Text.Wrap
                lineHeight: 1.35
                font.pixelSize: 14
                color: root.replyOk ? Theme.onBackgroundColor : Theme.error
            }
        }

        Item {
            width: parent.width
            height: 44

            Rectangle {
                anchors.left: parent.left
                anchors.right: sendButton.left
                anchors.rightMargin: 8
                height: parent.height
                radius: 14
                color: Theme.surfaceContainerHighest
                border.width: 1
                border.color: input.activeFocus ? Theme.primary : Qt.alpha(Theme.primary, 0.12)

                Behavior on border.color {
                    ColorAnimation {
                        duration: 150
                    }
                }

                TextInput {
                    id: input
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    verticalAlignment: TextInput.AlignVCenter
                    clip: true
                    maximumLength: 200
                    font.pixelSize: 14
                    color: Theme.onSurfaceVariantColor
                    selectionColor: Qt.alpha(Theme.primary, 0.3)
                    selectedTextColor: Theme.onSurfaceVariantColor
                    onAccepted: root.send()
                    Keys.onEscapePressed: root.closeRequested()

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: input.text === ""
                        text: "Ask ryuSki"
                        font.pixelSize: 14
                        color: Theme.onSurfaceVariantColor
                        opacity: 0.5
                    }
                }
            }

            MaterialIconButton {
                id: sendButton
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                enabled: input.text.trim() !== "" && RyuskiService.ready && !RyuskiService.busy
                type: MaterialIconButton.Tonal
                sizeStyle: MaterialIconButton.Small
                iconText: "\uf1d8"
                iconSize: 18
                color: Theme.primary
                iconColor: Theme.onPrimaryColor
                onClicked: root.send()
            }
        }
    }
}
