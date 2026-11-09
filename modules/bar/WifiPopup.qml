pragma ComponentBehavior: Bound
import QtQuick
import Ryu.Ui
import Ryu.Extraa
import Ryu.Shapes
import qs.services.theme
import qs.services.network

Item {
    id: root
    required property bool active
    readonly property var wifi: NetworkService.client
    readonly property real contentWidth: 340
    readonly property real maxListHeight: 340
    readonly property real emptyHeight: 72
    readonly property real hostPad: 8
    readonly property var rowDelegate: Qt.createComponent(Qt.resolvedUrl("WifiRowContent.qml"))
    property int tab: 0
    property string selPath: ""
    property string localMode: ""
    property var picked: null
    property string userText: ""
    property string passText: ""
    property var listRows: []
    property string lastKey: ""
    readonly property Item holder: parent ? parent.parent : null
    readonly property string hostEdge: holder?.parent?.edge ?? "bottom"
    readonly property string mode: wifi.requestPending ? "agent" : localMode
    readonly property bool pinned: mode !== ""
    readonly property bool needUser: mode === "agent" ? wifi.requestKind === "userAndPassword" : (mode === "net" && picked?.type === "8021x")
    readonly property string promptTitle: mode === "agent" ? wifi.requestNetwork : (picked?.name ?? "")
    readonly property string agentRowPath: listRows.find(r => r.headline === wifi.requestNetwork)?.path ?? ""
    readonly property string promptPath: mode === "net" ? (picked?.path ?? "") : (mode === "agent" ? agentRowPath : "")
    readonly property bool orphanPrompt: mode !== "" && !listRows.some(r => r.path === promptPath)
    readonly property var rows: {
        const avail = tab === 0;
        return (avail ? wifi.networks : wifi.knownNetworks).map(n => {
            const connected = n.connected ?? false;
            const known = avail ? n.known : true;
            const auto = n.autoConnect ?? false;
            const type = NetworkService.typeLabel(n.type);
            const locked = n.type !== "open" && !known;
            return {
                path: n.path,
                raw: n,
                connected: connected,
                known: known,
                autoConnect: auto,
                expandable: true,
                headline: n.name,
                supporting: avail ? (connected ? "Connected  /  " : "") + type + (known ? "  /  Saved" : "") : type + (auto ? "  /  Auto-connect" : ""),
                leadingIcon: avail ? strengthIcon(n.strength ?? 0) : "\uf1eb",
                trailingIcon: avail ? (connected ? "\uf00c" : (locked ? "\uf023" : "")) : "",
                trailingText: avail ? (n.strength ?? 0) + "%" : ""
            };
        });
    }
    function strengthIcon(s) {
        if (s > 75)
            return "\udb82\udd28";
        if (s > 50)
            return "\udb82\udd25";
        if (s > 25)
            return "\udb82\udd22";
        return "\udb82\udd1f";
    }
    function refreshModel() {
        if (pinned)
            return;
        const key = JSON.stringify(rows);
        if (key === lastKey)
            return;
        lastKey = key;
        listRows = rows.map(r => Object.assign({}, r, {
                expanded: r.path === selPath,
                popup: root
            }));
    }
    function syncSel() {
        const idx = listRows.findIndex(r => r.path === selPath);
        list.currentIndex = idx;
        list.expandedIndices = idx >= 0 ? [idx] : [];
    }
    function pin() {
        if (!holder)
            return;
        col.parent = holder;
        col.anchors.horizontalCenter = holder.horizontalCenter;
        if (hostEdge === "top")
            col.anchors.top = holder.top;
        else
            col.anchors.bottom = holder.bottom;
        col.anchors.topMargin = hostPad;
        col.anchors.bottomMargin = hostPad;
    }
    function clearPrompt() {
        localMode = "";
        picked = null;
    }
    function cancel() {
        if (wifi.requestPending)
            wifi.cancelRequest();
        clearPrompt();
        passText = "";
        userText = "";
    }
    function submit() {
        if (mode === "agent") {
            if (wifi.requestKind === "userAndPassword")
                wifi.submitCredentials(userText, passText);
            else
                wifi.submitPassphrase(passText);
        } else if (mode === "net" && picked) {
            NetworkService.connectTo(picked.path, passText, userText);
            clearPrompt();
        }
        passText = "";
    }
    function connectRow(n) {
        if (n.known || n.type === "open") {
            NetworkService.connectTo(n.path, "", "");
            return;
        }
        picked = n;
        localMode = "net";
    }
    function switchTab(index) {
        tab = index;
        selPath = "";
        forceActiveFocus();
    }
    onRowsChanged: refreshModel()
    onPinnedChanged: if (!pinned)
        refreshModel()
    onSelPathChanged: {
        syncSel();
        if (mode !== "" && selPath !== promptPath)
            cancel();
    }
    onModeChanged: {
        if (mode === "") {
            passText = "";
            userText = "";
            return;
        }
        userText = mode === "agent" ? wifi.requestUser : "";
        passText = "";
        if (selPath !== promptPath)
            selPath = promptPath;
    }
    onActiveChanged: {
        if (active) {
            NetworkService.scanIfStale();
        } else if (!wifi.requestPending) {
            clearPrompt();
            selPath = "";
        }
    }
    Component.onCompleted: {
        pin();
        refreshModel();
    }
    Keys.onEscapePressed: event => {
        event.accepted = mode !== "" || selPath !== "";
        if (mode !== "")
            cancel();
        else
            selPath = "";
    }
    anchors.centerIn: parent
    implicitWidth: contentWidth
    implicitHeight: col.implicitHeight
    visible: active
    Component {
        id: orphanForm
        WifiPromptForm {
            pop: root
            titled: true
        }
    }
    Column {
        id: col
        width: root.contentWidth
        spacing: 10
        visible: root.active
        Item {
            width: parent.width
            height: 40
            MaterialShape {
                id: shape
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: 36
                height: 36
                shape: MaterialShape.Cookie9Sided
                loading: NetworkService.busy
                contained: true
                containedScale: 0.7
                color: Theme.onPrimaryColor
                containerColor: Theme.primary
            }
            Column {
                anchors.left: shape.right
                anchors.leftMargin: 10
                anchors.right: scanBtn.left
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                Text {
                    width: parent.width
                    text: "Wi-Fi"
                    font.pixelSize: 15
                    font.weight: Font.DemiBold
                    color: Theme.onBackgroundColor
                }
                Text {
                    width: parent.width
                    text: NetworkService.statusText
                    elide: Text.ElideRight
                    font.pixelSize: 12
                    color: Theme.onSurfaceVariantColor
                }
            }
            MaterialIconButton {
                id: scanBtn
                anchors.right: toggle.left
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                type: MaterialIconButton.Tonal
                shape: MaterialIconButton.Round
                sizeStyle: MaterialIconButton.ExtraSmall
                iconText: "\uf021"
                iconSize: 16
                color: Theme.surfaceContainerHighest
                iconColor: Theme.onSurfaceVariantColor
                enabled: root.wifi.powered && !root.wifi.scanning
                onClicked: root.wifi.scan()
            }
            MaterialSwitch {
                id: toggle
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                checked: root.wifi.powered
                enabled: root.wifi.available && root.wifi.deviceName !== ""
                trackColor: Theme.surfaceContainerHighest
                checkedTrackColor: Theme.primary
                handleColor: Theme.onSurfaceVariantColor
                checkedHandleColor: Theme.onPrimaryColor
                borderColor: Theme.outline
                onToggled: root.wifi.powered = checked
            }
        }
        Item {
            width: parent.width
            height: root.listRows.length === 0 ? root.emptyHeight : Math.min(root.maxListHeight, list.height)
            ClippingRectangle {
                anchors.fill: parent
                visible: root.listRows.length > 0
                radius: 16
                color: "transparent"
                Flickable {
                    id: flick
                    anchors.fill: parent
                    contentWidth: width
                    contentHeight: list.height
                    boundsBehavior: Flickable.StopAtBounds
                    MaterialList {
                        id: list
                        width: flick.width
                        height: implicitHeight
                        contentDelegate: root.rowDelegate
                        model: root.listRows
                        variant: MaterialList.Segmented
                        selectionMode: MaterialList.Single
                        expandTrigger: MaterialList.Header
                        singleExpand: true
                        contentPadding: 16
                        itemColor: Theme.surfaceContainer
                        selectedColor: Theme.surfaceContainer
                        selectedTextColor: Theme.onSurfaceColor
                        textColor: Theme.onBackgroundColor
                        supportingColor: Theme.onSurfaceVariantColor
                        dividerColor: Theme.outlineVariant
                        showChevron: false
                        onModelChanged: root.syncSel()
                        onExpandedChanged: (index, expanded) => {
                            const p = root.listRows[index]?.path ?? "";
                            if (expanded)
                                root.selPath = p;
                            else if (root.selPath === p)
                                root.selPath = "";
                        }
                    }
                }
            }
            Text {
                anchors.centerIn: parent
                visible: root.listRows.length === 0
                text: root.tab === 1 ? "No saved networks" : (root.wifi.powered ? "No networks found" : "Wi-Fi is off")
                font.pixelSize: 13
                color: Theme.onSurfaceVariantColor
                opacity: 0.6
            }
        }
        Loader {
            width: parent.width
            active: root.orphanPrompt
            visible: active
            sourceComponent: orphanForm
        }
        Text {
            width: parent.width
            visible: NetworkService.message !== ""
            text: NetworkService.message
            wrapMode: Text.Wrap
            font.pixelSize: 11
            color: Theme.error
        }
        MaterialSegmentedButton {
            width: parent.width
            labels: ["Available", "Saved"]
            fillWidth: true
            showCheck: false
            currentIndex: root.tab
            color: "transparent"
            checkedColor: Theme.primary
            textColor: Theme.onSurfaceVariantColor
            checkedTextColor: Theme.onPrimaryColor
            borderColor: Theme.outline
            onToggled: (index, checked) => {
                if (checked)
                    root.switchTab(index);
            }
        }
    }
}
