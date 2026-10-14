import QtQuick
import qs.services.theme
import qs.configuration.Screenshot

Item {
    id: root

    property point a: Qt.point(0, 0)
    property point b: Qt.point(0, 0)
    property bool dragging: false

    readonly property real sx: Math.min(a.x, b.x)
    readonly property real sy: Math.min(a.y, b.y)
    readonly property real sw: Math.abs(a.x - b.x)
    readonly property real sh: Math.abs(a.y - b.y)
    readonly property bool has: dragging && sw > 1 && sh > 1
    readonly property real ratio: width > 0 && frozen.implicitWidth > 0 ? frozen.implicitWidth / width : 1

    focus: true
    Component.onCompleted: forceActiveFocus()
    Keys.onEscapePressed: ScreenshotConfig.finishSelect("", null)

    Image {
        id: frozen
        anchors.fill: parent
        source: "file://" + ScreenshotConfig.selectSource
        fillMode: Image.Stretch
        cache: false
    }

    Rectangle {
        x: 0
        y: 0
        width: parent.width
        height: root.has ? root.sy : parent.height
        color: Qt.alpha("black", 0.55)
    }
    Rectangle {
        x: 0
        y: root.sy + root.sh
        width: parent.width
        height: root.has ? parent.height - y : 0
        color: Qt.alpha("black", 0.55)
    }
    Rectangle {
        x: 0
        y: root.sy
        width: root.has ? root.sx : 0
        height: root.sh
        color: Qt.alpha("black", 0.55)
    }
    Rectangle {
        x: root.sx + root.sw
        y: root.sy
        width: root.has ? parent.width - x : 0
        height: root.sh
        color: Qt.alpha("black", 0.55)
    }

    Rectangle {
        visible: root.has
        x: root.sx
        y: root.sy
        width: root.sw
        height: root.sh
        color: "transparent"
        border.width: 2
        border.color: Theme.primary
    }

    Rectangle {
        visible: root.has
        x: root.sx
        y: root.sy + root.sh + 8
        width: label.implicitWidth + 16
        height: 24
        radius: 12
        color: Theme.background

        Text {
            id: label
            anchors.centerIn: parent
            text: Math.round(root.sw * root.ratio) + " × " + Math.round(root.sh * root.ratio)
            font.pixelSize: 12
            font.weight: Font.Medium
            color: Theme.primary
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.CrossCursor
        acceptedButtons: Qt.LeftButton

        onPressed: mouse => {
            root.a = Qt.point(mouse.x, mouse.y);
            root.b = root.a;
            root.dragging = true;
        }
        onPositionChanged: mouse => {
            if (root.dragging) {
                root.b = Qt.point(Math.max(0, Math.min(width, mouse.x)), Math.max(0, Math.min(height, mouse.y)));
            }
        }
        onReleased: {
            const k = root.ratio;
            const ok = root.sw > 4 && root.sh > 4;
            const geom = Math.round(root.sw * k) + "x" + Math.round(root.sh * k) + "+" + Math.round(root.sx * k) + "+" + Math.round(root.sy * k);
            const rect = {
                x: Math.round(root.sx),
                y: Math.round(root.sy),
                w: Math.round(root.sw),
                h: Math.round(root.sh)
            };
            root.dragging = false;
            ScreenshotConfig.finishSelect(ok ? geom : "", ok ? rect : null);
        }
    }
}
