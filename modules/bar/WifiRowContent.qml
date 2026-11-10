pragma ComponentBehavior: Bound
import QtQuick
import Ryu.Extraa
import px.services.theme
import px.services.network

Column {
    id: body

    required property int index
    required property var modelData

    readonly property var pop: modelData.popup
    readonly property var row: pop.rows.find(r => r.path === modelData.path) ?? modelData
    readonly property bool prompting: pop.mode !== "" && pop.promptPath === modelData.path

    topPadding: 12
    spacing: 8

    Column {
        width: parent.width
        spacing: 8
        visible: !body.prompting

        Item {
            width: parent.width
            height: 40
            visible: body.row.known

            MaterialCheckbox {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: "Auto-connect"
                checked: body.row.autoConnect ?? false
                color: Theme.primary
                checkmarkColor: Theme.onPrimaryColor
                uncheckedColor: Theme.onSecondaryContainerColor
                textColor: Theme.onSecondaryContainerColor
                onToggled: body.pop.wifi.setAutoConnect(body.row.path, checked)
            }

            MaterialButton {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                label: "Forget"
                sizeStyle: MaterialButton.ExtraSmall
                type: MaterialButton.Text
                contentColor: Theme.error
                onClicked: {
                    body.pop.wifi.forget(body.row.path);
                    body.pop.selPath = "";
                }
            }
        }

        MaterialButton {
            width: parent.width
            visible: body.pop.tab === 0 && !body.row.connected
            label: "Connect"
            sizeStyle: MaterialButton.Small
            color: Theme.primary
            contentColor: Theme.onPrimaryColor
            enabled: !NetworkService.connecting
            onClicked: body.pop.connectRow(body.row.raw)
        }

        MaterialButton {
            width: parent.width
            visible: body.pop.tab === 0 && body.row.connected
            label: "Disconnect"
            sizeStyle: MaterialButton.Small
            type: MaterialButton.Tonal
            color: Theme.background
            contentColor: Theme.onBackgroundColor
            onClicked: body.pop.wifi.disconnectNetwork()
        }
    }

    Loader {
        width: parent.width
        active: body.prompting
        visible: active
        sourceComponent: Component {
            WifiPromptForm {
                pop: body.pop
            }
        }
    }
}
