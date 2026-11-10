pragma ComponentBehavior: Bound
import QtQuick
import Ryu.Shapes
import px.services.theme
import px.services.polkit

Rectangle {
    id: card

    readonly property var flow: PolkitService.flow
    readonly property bool failed: flow?.failed ?? false
    readonly property bool busy: PolkitService.pending
    readonly property bool verified: PolkitService.verified
    readonly property bool locked: busy || verified
    readonly property bool bad: failed && !verified
    readonly property color accent: bad ? Theme.error : Theme.primary
    readonly property string liveMessage: flow?.message ?? ""

    property string message: ""
    property bool reveal: false
    property real enter: 0

    function submit() {
        if (input.text === "" || locked)
            return;
        PolkitService.submit(input.text);
        input.text = "";
    }

    function cancel() {
        if (!verified)
            flow?.cancelAuthenticationRequest();
    }

    onLiveMessageChanged: if (liveMessage !== "")
        message = liveMessage

    width: 380
    height: col.implicitHeight + 56
    radius: 28
    color: Theme.background
    border.width: 1
    border.color: verified ? Theme.primary : (bad ? Theme.error : Theme.outlineVariant)
    opacity: Math.min(1, enter * 1.5)
    scale: 0.92 + 0.08 * enter
    transformOrigin: Item.Center
    transform: Translate {
        id: shake
    }

    Behavior on enter {
        SpringAnimation {
            spring: 4
            damping: 0.3
            epsilon: 0.002
        }
    }

    Behavior on border.color {
        ColorAnimation {
            duration: 180
        }
    }

    Component.onCompleted: {
        message = liveMessage;
        enter = 1;
        input.forceActiveFocus();
    }

    onFailedChanged: {
        if (!failed)
            return;
        input.text = "";
        input.forceActiveFocus();
        shake.x = 14;
        shakeSpring.restart();
    }

    SpringAnimation {
        id: shakeSpring
        target: shake
        property: "x"
        to: 0
        spring: 6
        damping: 0.2
        epsilon: 0.5
    }

    Column {
        id: col
        x: 28
        y: 28
        width: parent.width - 56
        spacing: 22

        Column {
            width: parent.width
            spacing: 8

            Item {
                width: parent.width
                height: 56

                MaterialShape {
                    anchors.centerIn: parent
                    width: 56
                    height: 56
                    shape: card.busy ? MaterialShape.SoftBurst : (card.verified ? MaterialShape.Sunny : (card.bad ? MaterialShape.Pentagon : MaterialShape.Cookie9Sided))
                    loading: card.busy
                    contained: true
                    containedScale: 0.8
                    color: card.accent
                    containerColor: (card.bad ? Theme.errorContainer : Theme.primaryContainer)
                    springStiffness: 360
                    springDamping: 0.45
                }
            }

            Text {
                width: parent.width
                topPadding: 8
                horizontalAlignment: Text.AlignHCenter
                text: card.verified ? "Verified" : "Authentication required"
                font.pixelSize: 18
                font.weight: Font.DemiBold
                color: Theme.onBackgroundColor
            }

            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                visible: text !== ""
                text: card.verified ? "Success" : (card.busy ? "Verifying…" : (card.bad ? "Wrong password, try again" : card.message))
                wrapMode: Text.Wrap
                lineHeight: 1.25
                font.pixelSize: 13
                color: (card.verified || card.busy) ? Theme.primary : (card.bad ? Theme.error : Theme.onSurfaceVariantColor)
                opacity: (card.verified || card.busy || card.bad) ? 1 : 0.75
            }
        }

        Rectangle {
            id: field
            width: parent.width
            height: 50
            radius: 25
            color: Theme.surfaceContainerHighest
            border.width: 2
            border.color: card.bad ? Theme.error : (input.activeFocus ? Theme.primary : "transparent")
            opacity: card.locked ? 0.55 : 1

            Behavior on border.color {
                ColorAnimation {
                    duration: 150
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                }
            }

            TapHandler {
                onTapped: input.forceActiveFocus()
            }

            TextInput {
                id: input
                anchors.left: parent.left
                anchors.leftMargin: 22
                anchors.right: eye.left
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                readOnly: card.locked
                echoMode: (card.flow?.responseVisible || card.reveal) ? TextInput.Normal : TextInput.Password
                passwordCharacter: "•"
                font.pixelSize: 15
                color: Theme.onBackgroundColor
                selectionColor: Theme.primaryContainer
                selectedTextColor: Theme.onBackgroundColor
                cursorDelegate: Rectangle {
                    width: 2
                    radius: 1
                    color: card.accent
                }
                clip: true

                onAccepted: card.submit()
                Keys.onEscapePressed: card.cancel()

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: input.text === ""
                    text: card.flow?.inputPrompt || "Password"
                    font.pixelSize: 14
                    color: Theme.onSurfaceVariantColor
                    opacity: 0.5
                }
            }

            MouseArea {
                anchors.left: parent.left
                anchors.right: eye.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                acceptedButtons: Qt.NoButton
                cursorShape: Qt.IBeamCursor
            }

            Rectangle {
                id: eye
                anchors.right: parent.right
                anchors.rightMargin: 9
                anchors.verticalCenter: parent.verticalCenter
                width: 32
                height: 32
                radius: 16
                color: eyeArea.containsMouse ? Theme.surfaceContainerHigh : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: card.reveal ? "\uf070" : "\uf06e"
                    font.pixelSize: 14
                    color: Theme.onSurfaceVariantColor
                }

                MouseArea {
                    id: eyeArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        card.reveal = !card.reveal;
                        input.forceActiveFocus();
                    }
                }
            }
        }

        Row {
            width: parent.width
            spacing: 10

            Rectangle {
                id: cancelBtn
                readonly property bool on: !card.verified
                width: (parent.width - 10) * 0.42
                height: 44
                radius: 22
                color: "transparent"
                opacity: on ? 1 : 0.4

                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: Theme.onSurfaceVariantColor
                    opacity: cancelArea.pressed ? 0.16 : (cancelArea.containsMouse ? 0.08 : 0)
                }

                Text {
                    anchors.centerIn: parent
                    text: "Cancel"
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                    color: Theme.onSurfaceVariantColor
                }

                MouseArea {
                    id: cancelArea
                    anchors.fill: parent
                    enabled: cancelBtn.on
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: card.cancel()
                }
            }

            Rectangle {
                id: okBtn
                readonly property bool on: input.text !== "" && !card.locked
                width: (parent.width - 10) * 0.58
                height: 44
                radius: 22
                color: Theme.primary
                opacity: on ? 1 : 0.4

                Behavior on opacity {
                    NumberAnimation {
                        duration: 150
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: Theme.onPrimaryColor
                    opacity: okArea.pressed ? 0.16 : (okArea.containsMouse ? 0.08 : 0)
                }

                Text {
                    anchors.centerIn: parent
                    text: "Authenticate"
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                    color: Theme.onPrimaryColor
                }

                MouseArea {
                    id: okArea
                    anchors.fill: parent
                    enabled: okBtn.on
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: card.submit()
                }
            }
        }
    }
}
