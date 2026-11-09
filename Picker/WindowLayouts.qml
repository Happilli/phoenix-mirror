pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services.theme
import qs.configuration.Picker
import qs.components

Flickable {
    id: root

    property bool shown: false
    property var hot: null
    property var last: null

    readonly property real gap: 12
    readonly property real cardW: Math.floor((width - gap) / 2)
    readonly property var groups: PickerConfig.groups
    readonly property var names: groups.map(g => g.name)

    readonly property var geo: {
        const c = last?.card;
        const w = c?.g?.wins.find(x => x.key === last.key);
        if (!w)
            return null;
        return {
            x: c.x + (w.x - c.g.mx) * c.s,
            y: c.y + (w.y - c.g.my) * c.s,
            w: Math.max(4, w.w * c.s),
            h: Math.max(4, w.h * c.s)
        };
    }

    function reset() {
        hot = null;
        last = null;
    }

    opacity: shown ? 1 : 0
    enabled: shown
    z: shown ? 1 : 0
    clip: true
    contentWidth: width
    contentHeight: flow.implicitHeight
    boundsBehavior: Flickable.StopAtBounds

    onShownChanged: reset()

    Flow {
        id: flow
        width: root.width
        spacing: root.gap

        Repeater {
            model: ScriptModel {
                values: root.names
            }

            Item {
                id: card
                required property string modelData

                readonly property var g: PickerConfig.groupMap[modelData] ?? null
                readonly property real s: g && g.mw > 0 ? root.cardW / g.mw : 0
                readonly property var hotWin: root.hot?.card === card ? g?.wins.find(w => w.key === root.hot.key) ?? null : null

                width: root.cardW
                height: g ? g.mh * s + 30 : 0

                Rectangle {
                    id: screen
                    width: card.width
                    height: card.g ? card.g.mh * card.s : 0
                    color: Theme.background
                    border.width: 1
                    border.color: Theme.outlineVariant
                    clip: true

                    Repeater {
                        model: ScriptModel {
                            values: card.g ? card.g.wins.map(w => w.key) : []
                        }

                        Rectangle {
                            id: box
                            required property string modelData

                            readonly property var win: card.g?.wins.find(w => w.key === modelData) ?? null
                            readonly property bool alive: win !== null && PickerConfig.open

                            visible: win !== null
                            opacity: win && !win.shareable ? 0.45 : 1
                            x: win ? (win.x - card.g.mx) * card.s : 0
                            y: win ? (win.y - card.g.my) * card.s : 0
                            width: win ? Math.max(4, win.w * card.s) : 0
                            height: win ? Math.max(4, win.h * card.s) : 0
                            z: win?.floating ? 1 : 0
                            color: Theme.surfaceContainerHigh
                            clip: true

                            FillScreencopy {
                                opacity: hasContent ? 1 : 0
                                captureSource: box.alive ? box.win.wl : null
                                live: box.alive
                            }

                            HoverHandler {
                                onHoveredChanged: {
                                    if (hovered)
                                        root.hot = root.last = {
                                            card: card,
                                            key: box.modelData
                                        };
                                    else if (root.hot?.key === box.modelData)
                                        root.hot = null;
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                enabled: box.win !== null && box.win.shareable
                                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: PickerConfig.pick("window", box.win.item.target)
                            }
                        }
                    }
                }

                Text {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: screen.bottom
                    anchors.topMargin: 6
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                    font.pixelSize: 12
                    color: card.hotWin ? Theme.primary : Theme.onBackgroundColor
                    text: card.hotWin ? card.hotWin.label + (card.hotWin.shareable ? "" : "  ·  reopen picker to share") : "Workspace " + card.modelData
                }
            }
        }
    }

    Rectangle {
        id: pill

        z: 100
        x: root.geo?.x ?? 0
        y: root.geo?.y ?? 0
        width: root.geo?.w ?? 0
        height: root.geo?.h ?? 0
        color: "transparent"
        border.width: 2
        border.color: Theme.primary
        opacity: root.hot && root.geo ? 1 : 0
        visible: opacity > 0.01

        Behavior on opacity {
            NumberAnimation {
                duration: 120
            }
        }
        Behavior on x {
            enabled: pill.visible
            SpringAnimation {
                spring: 5
                damping: 0.32
                epsilon: 0.25
            }
        }
        Behavior on y {
            enabled: pill.visible
            SpringAnimation {
                spring: 5
                damping: 0.32
                epsilon: 0.25
            }
        }
        Behavior on width {
            enabled: pill.visible
            SpringAnimation {
                spring: 5
                damping: 0.32
                epsilon: 0.25
            }
        }
        Behavior on height {
            enabled: pill.visible
            SpringAnimation {
                spring: 5
                damping: 0.32
                epsilon: 0.25
            }
        }
    }

    Text {
        anchors.centerIn: parent
        visible: root.groups.length === 0
        text: "No shareable windows"
        font.pixelSize: 14
        color: Theme.onSurfaceVariantColor
    }
}
