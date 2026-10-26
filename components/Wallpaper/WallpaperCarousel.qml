pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.configuration.Wallpaper
import qs.services.theme

Item {
    id: root

    property int current: 0
    property real position: 0
    property real scroll: 0
    property bool animate: false
    property bool ready: false

    readonly property int visionRange: 4
    readonly property int reach: visionRange + 2
    readonly property real gap: 8
    readonly property real radius: 24

    readonly property real centerWidth: Math.min(0.56 * width, 600)
    readonly property real budget: Math.max(0, (width - centerWidth) / 2 - gap * 3)
    readonly property real sideWidth: Math.max(18, budget * 0.46)
    readonly property real midWidth: Math.max(14, budget * 0.32)
    readonly property real farWidth: Math.max(10, budget * 0.22)
    readonly property real decodeHeight: Math.ceil(Math.max(height, centerWidth * 0.75) / 50) * 50

    readonly property int base: Math.floor(position)
    readonly property real baseLeft: lerp(width / 2 - centerWidth / 2, width / 2 - centerWidth / 2 - (gap + sideWidth), position - base)
    readonly property var windowIndices: {
        const out = [];
        const lo = Math.max(0, base - reach);
        const hi = Math.min(walls.count - 1, base + reach);
        for (let i = lo; i <= hi; i++)
            out.push(i);
        return out;
    }

    opacity: ready ? 1 : 0

    Behavior on opacity {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

    function lerp(from, to, t) {
        return from + (to - from) * t;
    }

    function widthForDistance(distance) {
        const d = Math.min(distance, 4);
        if (d <= 1)
            return lerp(centerWidth, sideWidth, d);
        if (d <= 2)
            return lerp(sideWidth, midWidth, d - 1);
        if (d <= 3)
            return lerp(midWidth, farWidth, d - 2);
        return lerp(farWidth, farWidth * 0.4, d - 3);
    }

    function widthFor(index) {
        return widthForDistance(Math.abs(index - position));
    }

    function leftFor(index) {
        let x = baseLeft;
        for (let i = base; i < index; i++)
            x += widthFor(i) + gap;
        for (let i = base - 1; i >= index; i--)
            x -= widthFor(i) + gap;
        return x;
    }

    function fadeFor(index) {
        const d = Math.abs(index - position);
        return d <= 3 ? 1 : Math.max(0, 4 - d);
    }

    function syncToCurrent() {
        const target = WallpaperConfig.currentWallpaper.toString();
        let found = 0;
        for (let i = 0; i < walls.count; i++) {
            if ("file://" + walls.get(i, "filePath") === target) {
                found = i;
                break;
            }
        }
        animate = false;
        current = found;
        position = found;
        ready = true;
        settle.restart();
    }

    function select(index) {
        if (index < 0 || index === current || index >= walls.count)
            return;
        current = index;
        position = index;
        WallpaperConfig.setWallpaper(walls.get(index, "filePath"));
        Theme.generate();
    }

    Behavior on position {
        enabled: root.animate
        SpringAnimation {
            spring: 1.7
            damping: 0.5
            epsilon: 0.005
        }
    }

    Timer {
        id: settle
        interval: 120
        onTriggered: root.animate = true
    }

    Connections {
        target: WallpaperConfig

        function onCurrentWallpaperChanged() {
            if (walls.count > 0 && walls.get(root.current, "filePath") !== undefined && "file://" + walls.get(root.current, "filePath") !== WallpaperConfig.currentWallpaper.toString())
                root.syncToCurrent();
        }
    }

    WallpaperModel {
        id: walls
        onLoaded: root.syncToCurrent()
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        onWheel: wheel => {
            root.scroll -= wheel.pixelDelta.x !== 0 ? wheel.pixelDelta.x : wheel.angleDelta.y / 2;
            if (root.scroll >= 50) {
                root.select(root.current + 1);
                root.scroll = 0;
            } else if (root.scroll <= -50) {
                root.select(root.current - 1);
                root.scroll = 0;
            }
        }
    }

    ClippingRectangle {
        anchors.fill: parent
        radius: root.radius
        color: "transparent"

        Repeater {
            model: ScriptModel {
                values: root.windowIndices
            }

            ClippingRectangle {
                id: card
                required property int modelData

                readonly property int index: modelData
                readonly property bool near: Math.abs(index - root.position) < root.visionRange

                visible: near
                color: Theme.surfaceContainerHighest
                x: near ? root.leftFor(index) : 0
                height: root.height
                width: near ? root.widthFor(index) : 0
                radius: Math.min(root.radius, width / 2)
                opacity: near ? root.fadeFor(index) : 0

                Image {
                    anchors.fill: parent
                    source: "file://" + walls.get(card.index, "filePath")
                    sourceSize.height: root.decodeHeight
                    asynchronous: true
                    fillMode: Image.PreserveAspectCrop
                    opacity: status === Image.Ready ? 1 : 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 150
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.select(card.index)
                }
            }
        }
    }
}
