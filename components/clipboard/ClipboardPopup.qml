pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Widgets
import Ryu.Extraa
import Ryu.Clipsh
import qs.services.theme
import qs.configuration.Clipboard

Item {
    id: root

    property real shownHeight: 0
    property int hoveredIndex: -1

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
    readonly property real wantHeight: fullHeight

    width: 440
    height: Math.max(0, shownHeight)

    function sync() {
        const next = entries;
        const keep = new Set(next);
        for (let i = shown.count - 1; i >= 0; i--) {
            if (!keep.has(shown.get(i).entry))
                shown.remove(i);
        }
        for (let i = 0; i < next.length; i++) {
            if (i < shown.count && shown.get(i).entry === next[i])
                continue;
            let found = -1;
            for (let j = i + 1; j < shown.count; j++) {
                if (shown.get(j).entry === next[i]) {
                    found = j;
                    break;
                }
            }
            if (found >= 0)
                shown.move(found, i, 1);
            else
                shown.insert(i, {
                    "entry": next[i]
                });
        }
        while (shown.count > next.length)
            shown.remove(shown.count - 1);
    }

    ListModel {
        id: shown
    }

    Behavior on shownHeight {
        SpringAnimation {
            spring: 3
            damping: 0.23
            epsilon: 0.33
        }
    }

    onWantHeightChanged: shownHeight = wantHeight

    onEntriesChanged: {
        hoveredIndex = -1;
        sync();
    }

    Component.onCompleted: {
        board.fetchHistory();
        search.forceActiveFocus();
        shownHeight = wantHeight;
        sync();
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
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
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
                keyNavigationEnabled: false
                highlightFollowsCurrentItem: false
                currentIndex: -1
                model: shown

                add: Transition {
                    ParallelAnimation {
                        NumberAnimation {
                            property: "opacity"
                            from: 0
                            to: 1
                            duration: 180
                        }
                        NumberAnimation {
                            property: "scale"
                            from: 0.94
                            to: 1
                            duration: 180
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                remove: Transition {
                    ParallelAnimation {
                        NumberAnimation {
                            property: "opacity"
                            to: 0
                            duration: 140
                        }
                        NumberAnimation {
                            property: "scale"
                            to: 0.94
                            duration: 140
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                displaced: Transition {
                    NumberAnimation {
                        property: "y"
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }

                highlight: Rectangle {
                    id: pill

                    readonly property bool tracking: root.hoveredIndex >= 0 && list.currentItem !== null

                    y: list.currentItem ? list.currentItem.y : 0
                    width: list.width
                    height: list.currentItem ? list.currentItem.height : 0
                    radius: 14
                    color: Theme.surfaceContainerHighest
                    opacity: tracking ? 1 : 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 120
                        }
                    }

                    Behavior on y {
                        enabled: pill.opacity > 0.01
                        SpringAnimation {
                            spring: 5
                            damping: 0.32
                            epsilon: 0.25
                        }
                    }

                    Behavior on height {
                        enabled: pill.opacity > 0.01
                        SpringAnimation {
                            spring: 5
                            damping: 0.32
                            epsilon: 0.25
                        }
                    }
                }

                delegate: Item {
                    id: row
                    required property string entry
                    required property int index

                    readonly property bool isImage: board.isImage(entry)
                    readonly property bool hovered: root.hoveredIndex === index
                    property string imageUrl: ""

                    width: list.width
                    height: isImage ? root.imageRow : root.textRow

                    Component.onCompleted: if (isImage)
                        imageUrl = board.tempImagePath(entry)

                    Connections {
                        target: board

                        function onImageReady(entry, url) {
                            if (entry === row.entry)
                                row.imageUrl = url;
                        }
                    }

                    HoverHandler {
                        onHoveredChanged: {
                            if (hovered) {
                                root.hoveredIndex = row.index;
                                list.currentIndex = row.index;
                            } else if (root.hoveredIndex === row.index) {
                                root.hoveredIndex = -1;
                            }
                        }
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

                    Rectangle {
                        visible: row.isImage
                        anchors.fill: parent
                        radius: 14
                        color: "transparent"
                        border.width: 2
                        border.color: Theme.primary
                        opacity: row.hovered ? 1 : 0

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 120
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: board.copyItem(row.entry)
                    }

                    Text {
                        visible: !row.isImage
                        anchors.left: parent.left
                        anchors.leftMargin: 14
                        anchors.right: parent.right
                        anchors.rightMargin: 48
                        anchors.verticalCenter: parent.verticalCenter
                        text: board.previewText(row.entry, 160)
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                        font.pixelSize: 13
                        color: row.hovered ? Theme.primary : Theme.onSurfaceVariantColor
                    }

                    Text {
                        id: deleteIcon
                        anchors.right: parent.right
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        text: "\uf00d"
                        font.pixelSize: 14
                        color: Theme.error
                        opacity: deleteArea.containsMouse ? 1 : 0.7

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 120
                            }
                        }

                        MouseArea {
                            id: deleteArea
                            anchors.fill: parent
                            anchors.margins: -8
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: board.deleteItem(row.entry)
                        }
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
