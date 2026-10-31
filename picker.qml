pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import Ryu.Extraa
import qs.services.theme

ShellRoot {
    id: root

    property int tab: 0
    property bool token: true

    readonly property var windows: {
        const raw = Quickshell.env("XDPH_WINDOW_SHARING_LIST") ?? "";
        const out = [];
        for (const e of raw.split("[HA>]")) {
            if (e.trim() === "")
                continue;
            const a = e.split("[HC>]");
            if (a.length < 2)
                continue;
            const b = a[1].split("[HT>]");
            if (b.length < 2)
                continue;
            const c = b[1].split("[HE>]");
            out.push({
                id: a[0],
                cls: b[0],
                title: c[0],
                addr: c.length > 1 ? c[1].trim() : ""
            });
        }
        return out;
    }

    readonly property var screenItems: Quickshell.screens.map(s => ({
                label: s.name + "  ·  " + s.width + "x" + s.height,
                kind: "screen",
                target: s.name,
                addr: "",
                screen: s
            }))

    readonly property var windowItems: windows.map(w => ({
                label: w.cls + "  ·  " + w.title,
                kind: "window",
                target: w.id,
                addr: w.addr,
                screen: null
            }))

    function pick(kind, target) {
        result.setText("[SELECTION]" + (token ? "r" : "") + "/" + kind + ":" + target);
    }

    function toplevelFor(addr) {
        if (addr === "")
            return null;
        const n = Number(addr);
        const hex = isNaN(n) ? addr.toLowerCase().replace(/^0x/, "") : n.toString(16);
        for (const t of Hyprland.toplevels.values) {
            if (t.address.toLowerCase().replace(/^0x/, "") === hex)
                return t.wayland;
        }
        return null;
    }

    Component.onCompleted: Hyprland.refreshToplevels()

    FileView {
        id: result
        path: (Quickshell.env("XDG_RUNTIME_DIR") || "/tmp") + "/phoenix-picker-result"
        onSaved: Qt.quit()
    }

    FloatingWindow {
        id: win
        title: "Share"
        color: Theme.background
        implicitWidth: 760
        implicitHeight: 560
        minimumSize: Qt.size(implicitWidth, implicitHeight)
        maximumSize: Qt.size(implicitWidth, implicitHeight)
        visible: true
        onVisibleChanged: if (!visible)
            Qt.quit()

        Shortcut {
            sequence: "Escape"
            onActivated: Qt.quit()
        }

        Column {
            id: layout
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            MaterialSegmentedButton {
                id: tabs
                labels: ["Screen", "Window"]
                currentIndex: root.tab
                selectionMode: MaterialSegmentedButton.Single
                color: "transparent"
                checkedColor: Theme.secondaryContainer
                textColor: Theme.onSurfaceVariantColor
                checkedTextColor: Theme.onSecondaryContainerColor
                borderColor: Theme.outline

                onToggled: (index, checked) => {
                    if (checked)
                        root.tab = index;
                }
            }

            GridView {
                id: grid
                width: parent.width
                height: layout.height - tabs.height - restoreBox.height - layout.spacing * 2
                clip: true
                cellWidth: Math.floor(width / 2)
                cellHeight: Math.round((cellWidth - 12) * 9 / 16) + 40
                boundsBehavior: Flickable.StopAtBounds
                model: root.tab === 0 ? root.screenItems : root.windowItems

                delegate: Item {
                    id: cell
                    required property var modelData

                    width: grid.cellWidth
                    height: grid.cellHeight

                    Item {
                        anchors.fill: parent
                        anchors.margins: 6

                        ClippingRectangle {
                            id: card
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            height: parent.height - 28
                            radius: 16
                            color: Theme.surfaceContainerHighest

                            ScreencopyView {
                                id: sc
                                readonly property real sw: implicitWidth > 0 ? implicitWidth : 16
                                readonly property real sh: implicitHeight > 0 ? implicitHeight : 10
                                readonly property real fill: Math.max(card.width / sw, card.height / sh)

                                anchors.centerIn: parent
                                width: sw * fill
                                height: sh * fill
                                live: true
                                captureSource: cell.modelData.kind === "screen" ? cell.modelData.screen : root.toplevelFor(cell.modelData.addr)
                            }

                            Text {
                                anchors.centerIn: parent
                                visible: !sc.hasContent
                                text: "No preview"
                                font.pixelSize: 12
                                color: Theme.onSurfaceVariantColor
                                opacity: 0.6
                            }
                        }

                        Rectangle {
                            anchors.fill: card
                            radius: card.radius
                            color: "transparent"
                            border.width: area.containsMouse ? 2 : 1
                            border.color: area.containsMouse ? Theme.primary : Theme.outlineVariant
                        }

                        Text {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: card.bottom
                            anchors.topMargin: 6
                            horizontalAlignment: Text.AlignHCenter
                            text: cell.modelData.label
                            elide: Text.ElideRight
                            font.pixelSize: 12
                            color: area.containsMouse ? Theme.primary : Theme.onBackgroundColor
                        }

                        MouseArea {
                            id: area
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.pick(cell.modelData.kind, cell.modelData.target)
                        }
                    }
                }
            }

            MaterialCheckbox {
                id: restoreBox
                text: "Allow a restore token"
                checked: root.token
                color: Theme.primary
                uncheckedColor: Theme.onSurfaceVariantColor
                checkmarkColor: Theme.onPrimaryColor
                textColor: Theme.onBackgroundColor
                errorColor: Theme.error
                onToggled: root.token = checked
            }
        }
    }
}
