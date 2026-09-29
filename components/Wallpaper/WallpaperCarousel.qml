pragma ComponentBehavior: Bound
import QtQuick
import qs.configuration.Wallpaper
import Quickshell.Widgets
import qs.services.theme

Item {
    id: root

    property int current: 0
    property real position: current
    property real scroll: 0

    readonly property real preferredCardWidth: 360
    readonly property real minSideWidth: 60
    readonly property real maxSideWidth: 120
    readonly property int visionRange: 7
    readonly property real gap: 12
    readonly property real radius: 30

    readonly property real centerWidth: Math.min(0.6 * width, preferredCardWidth)
    readonly property real sideWidth: {
        const leftOver = (width - centerWidth) / 2;
        const rawCount = Math.max(1, Math.round(leftOver / maxSideWidth + gap));
        const fitted = leftOver / rawCount - gap;
        return Math.max(minSideWidth, Math.min(maxSideWidth, fitted));
    }
    readonly property real farWidth: minSideWidth

    function lerp(from, to, t) {
        return from + (to - from) * t;
    }
    function widthForDistance(distance) {
        const clamped = Math.min(distance, 2);
        if (clamped <= 1) {
            return lerp(centerWidth, sideWidth, clamped);
        }
        return lerp(sideWidth, farWidth, clamped - 1);
    }
    function widthFor(index) {
        return widthForDistance(Math.abs(index - position));
    }
    function leftFor(index) {
        const baseIndex = Math.floor(position);
        const progressCandidate = position - baseIndex;
        let x = lerp(width / 2 - centerWidth / 2, width / 2 - centerWidth / 2 - (gap + sideWidth), progressCandidate);
        for (let i = baseIndex; i < index; i++) {
            x += widthFor(i) + gap;
        }
        for (let i = baseIndex - 1; i >= index; i--) {
            x -= widthFor(i) + gap;
        }

        return x;
    }

    onCurrentChanged: {
        if (walls.count) {
            WallpaperConfig.setWallpaper(walls.get(current, "filePath"));
            Theme.generate();
        }
    }
    Behavior on position {
        SpringAnimation {
            spring: 1.7
            damping: 0.5
            epsilon: 0.005
        }
    }
    WallpaperModel {
        id: walls
    }
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        onWheel: wheel => {
            root.scroll -= wheel.pixelDelta.x;
            if (root.scroll >= 50) {
                root.current = Math.min(walls.count - 1, root.current + 1);
                root.scroll = 0;
            } else if (root.scroll <= -50) {
                root.current = Math.max(0, root.current - 1);
                root.scroll = 0;
            }
        }
    }
    ClippingRectangle {
        anchors.fill: parent
        radius: root.radius
        color: "transparent"
        Repeater {
            model: walls.count
            ClippingRectangle {
                id: card
                required property int index
                readonly property bool near: Math.abs(index - root.position) < root.visionRange
                visible: near
                x: near ? root.leftFor(index) : 0
                height: root.height
                width: near ? root.widthFor(index) : 0
                radius: root.radius
                Image {
                    anchors.fill: parent
                    source: card.visible ? "file://" + walls.get(card.index, "filePath") : ""
                    sourceSize.height: 220
                    asynchronous: true
                    fillMode: Image.PreserveAspectCrop
                }
            }
        }
    }
}
