pragma ComponentBehavior: Bound
import QtQuick
import qs.configuration.Wallpaper

Item {
    id: root

    property int current: 0
    property real position: current
    property real scroll: 0

    readonly property real cardWidth: 360
    readonly property real gap: 12
    readonly property real step: cardWidth + gap
    readonly property real centerX: (width - cardWidth) / 2

    onCurrentChanged: WallpaperConfig.setWallpaper(walls.get(current, "filePath"))
    Behavior on position {
        SpringAnimation {
            spring: 4.0
            damping: 2.0
            epsilon: 1.0
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
                root.current = Math.min(walls.count, root.current + 1);
                root.scroll = 0;
            } else if (root.scroll <= -50) {
                root.current = Math.max(0, root.current - 1);
                root.scroll = 0;
            }
        }
    }

    Repeater {
        model: walls.count
        Image {
            required property int index
            visible: (index - root.position) < 6
            x: root.centerX + (index - root.position) * root.step
            source: visible ? "file://" + walls.get(index, "filePath") : ""
            height: root.height
            width: 360
            sourceSize.height: root.height
            asynchronous: true
            fillMode: Image.PreserveAspectCrop
        }
    }
}
