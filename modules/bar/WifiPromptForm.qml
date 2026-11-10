pragma ComponentBehavior: Bound
import QtQuick
import Ryu.Extraa
import px.services.theme

Column {
    id: form

    required property var pop
    property bool titled: false

    readonly property color fieldColor: titled ? Theme.surfaceContainerHighest : Theme.background

    function focusFirst() {
        (pop.needUser ? userIn : passIn).input.forceActiveFocus();
    }

    width: parent ? parent.width : 0
    spacing: 8

    Component.onCompleted: focusTimer.start()

    component Input: Rectangle {
        id: inp

        property alias input: field
        property alias echoMode: field.echoMode
        property string initial: ""
        property string placeholder: ""

        signal typed(string value)
        signal accepted
        signal escaped

        implicitHeight: 40
        radius: 20
        color: form.fieldColor
        border.width: 2
        border.color: field.activeFocus ? Theme.primary : Theme.outlineVariant

        TextInput {
            id: field
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            verticalAlignment: TextInput.AlignVCenter
            clip: true
            font.pixelSize: 14
            color: Theme.onBackgroundColor
            selectionColor: Theme.primaryContainer
            selectedTextColor: Theme.onBackgroundColor
            Component.onCompleted: text = inp.initial
            onTextEdited: inp.typed(text)
            onAccepted: inp.accepted()
            Keys.onEscapePressed: inp.escaped()

            Text {
                anchors.verticalCenter: parent.verticalCenter
                visible: field.text === ""
                text: inp.placeholder
                font.pixelSize: 14
                color: Theme.onSurfaceVariantColor
                opacity: 0.5
            }
        }
    }

    Timer {
        id: focusTimer
        interval: 150
        onTriggered: form.focusFirst()
    }

    Rectangle {
        visible: form.titled
        width: parent.width
        height: 1
        color: Theme.outlineVariant
    }

    Text {
        visible: form.titled
        width: parent.width
        text: "Connect to " + form.pop.promptTitle
        elide: Text.ElideRight
        font.pixelSize: 14
        font.weight: Font.DemiBold
        color: Theme.primary
    }

    Input {
        id: userIn
        width: parent.width
        visible: form.pop.needUser
        placeholder: "Username"
        initial: form.pop.userText
        onTyped: value => form.pop.userText = value
        onAccepted: passIn.input.forceActiveFocus()
        onEscaped: form.pop.cancel()
    }

    Input {
        id: passIn
        width: parent.width
        echoMode: TextInput.Password
        placeholder: "Password"
        initial: form.pop.passText
        onTyped: value => form.pop.passText = value
        onAccepted: form.pop.submit()
        onEscaped: form.pop.cancel()
    }

    Item {
        width: parent.width
        height: 40

        Row {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            MaterialButton {
                anchors.verticalCenter: parent.verticalCenter
                label: "Cancel"
                sizeStyle: MaterialButton.ExtraSmall
                type: MaterialButton.Text
                contentColor: Theme.onSurfaceVariantColor
                onClicked: form.pop.cancel()
            }

            MaterialButton {
                anchors.verticalCenter: parent.verticalCenter
                label: "Connect"
                sizeStyle: MaterialButton.ExtraSmall
                color: Theme.primary
                contentColor: Theme.onPrimaryColor
                onClicked: form.pop.submit()
            }
        }
    }
}
