pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Widgets
import Ryu.Extraa
import Ryu.Clipsh
import qs.services.theme
import qs.configuration.Clipboard

Item {
    id: root

    property bool open: true
    property real shownHeight: 0

    signal closed

    readonly property real pad: 12
    readonly property real searchScale: 0.85
    readonly property real wipeSize: 40
    readonly property real maxHeight: 540
    readonly property real imageRow: 140
    readonly property real textRow: 52
    readonly property real rowGap: 6
    readonly property real emptyArea: 60
    readonly property string query: search.text.trim().toLowerCase()
    readonly property var entries: {
        const all = board.history;
        if (query === "")
            return all;
        return all.filter(e => board.previewText(e, 400).toLowerCase().includes(query));
    }
    readonly property real contentHeight: {
        const items = entries;
        if (items.length === 0)
            return emptyArea;
        let h = 0;
        for (const e of items)
            h += board.isImage(e) ? imageRow : textRow;
        return h + rowGap * (items.length - 1);
    }
    readonly property real fullHeight: Math.min(maxHeight, pad + 48 + 8 + contentHeight + pad)
    readonly property real wantHeight: open ? fullHeight : 0

    width: 440
    height: Math.max(0, shownHeight)

    Behavior on shownHeight {
        SpringAnimation {
            spring: 3.5
            damping: 0.3
            epsilon: 0.5
        }
    }

    onWantHeightChanged: shownHeight = wantHeight

    onShownHeightChanged: {
        if (!open && shownHeight <= 1)
            closed();
    }

    Component.onCompleted: {
        board.fetchHistory();
        search.forceActiveFocus();
        shownHeight = wantHeight;
    }

    Shortcut {
        sequence: "Escape"
        onActivated: ClipboardConfig.hide()
    }

    Clipsh {
        id: board
        onItemCopied: ClipboardConfig.hide()
    }

    ClippingRectangle {
        id: card
        anchors.fill: parent
        radius: 24
        color: Theme.background
        border.width: 1
        border.color: Qt.alpha(Theme.primary, 0.15)

        MouseArea {
            anchors.fill: parent
        }

        Item {
            id: body
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            height: root.fullHeight

            Item {
                id: searchRow
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: root.pad
                height: 48

                MaterialSearchBox {
                    id: search
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: (searchRow.width - root.wipeSize - 8) / root.searchScale
                    scale: root.searchScale
                    transformOrigin: Item.Left
                    placeholderText: "Search clipboard"
                    color: Theme.surfaceContainerHighest
                    textColor: Theme.onSurfaceVariantColor
                    placeholderColor: Theme.onSurfaceVariantColor
                    iconColor: Theme.onSurfaceVariantColor
                    cursorColor: Theme.primary
                    borderWidth: 2
                    borderColor: "transparent"
                    selectionColor: Qt.alpha(Theme.primary, 0.3)
                    onAccepted: if (root.entries.length > 0)
                        board.copyItem(root.entries[0])
                }

                MaterialIconButton {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    type: MaterialIconButton.Tonal
                    shape: MaterialIconButton.Round
                    sizeStyle: MaterialIconButton.Small
                    iconText: "\uf1f8"
                    iconSize: 18
                    color: Theme.surfaceContainerHighest
                    iconColor: Theme.onSurfaceVariantColor
                    onClicked: board.wipe()
                }
            }

            ListView {
                id: list
                anchors.top: searchRow.bottom
                anchors.topMargin: 8
                anchors.bottom: parent.bottom
                anchors.bottomMargin: root.pad
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: root.pad
                anchors.rightMargin: root.pad
                clip: true
                spacing: root.rowGap
                boundsBehavior: Flickable.StopAtBounds
                model: root.entries

                delegate: Item {
                    id: row
                    required property string modelData

                    readonly property bool isImage: board.isImage(modelData)
                    property string imageUrl: ""

                    width: list.width
                    height: isImage ? root.imageRow : root.textRow

                    Component.onCompleted: if (isImage)
                        imageUrl = board.tempImagePath(modelData)

                    Connections {
                        target: board

                        function onImageReady(entry, url) {
                            if (entry === row.modelData)
                                row.imageUrl = url;
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: 14
                        color: area.containsMouse ? Theme.surfaceContainerHighest : Theme.surfaceContainer
                    }

                    ClippingRectangle {
                        id: thumb
                        visible: row.isImage
                        anchors.fill: parent
                        radius: 14
                        color: Theme.surfaceContainerHighest

                        Image {
                            anchors.fill: parent
                            source: row.imageUrl
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: false
                            opacity: status === Image.Ready ? 1 : 0

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 150
                                }
                            }
                        }
                    }

                    MouseArea {
                        id: area
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: board.copyItem(row.modelData)
                    }

                    Text {
                        visible: !row.isImage
                        anchors.left: parent.left
                        anchors.leftMargin: 14
                        anchors.right: parent.right
                        anchors.rightMargin: 48
                        anchors.verticalCenter: parent.verticalCenter
                        text: board.previewText(row.modelData, 160)
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                        font.pixelSize: 13
                        color: area.containsMouse ? Theme.primary : Theme.onSurfaceVariantColor
                    }

                    MaterialIconButton {
                        anchors.right: parent.right
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        type: MaterialIconButton.Standard
                        shape: MaterialIconButton.Round
                        sizeStyle: MaterialIconButton.ExtraSmall
                        iconText: "\uf00d"
                        iconSize: 14
                        iconColor: Theme.onSurfaceVariantColor
                        onClicked: board.deleteItem(row.modelData)
                    }
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: searchRow.bottom
                anchors.topMargin: 8 + root.emptyArea / 2 - height / 2
                visible: root.entries.length === 0 && !board.loading
                text: root.query === "" ? "Nothing copied yet" : "No matches"
                font.pixelSize: 13
                color: Theme.onSurfaceVariantColor
                opacity: 0.7
            }
        }
    }
}
