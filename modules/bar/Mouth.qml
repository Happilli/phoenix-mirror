pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Shapes
import qs.services.theme
import qs.services.ryuski

Rectangle {
    id: root

    property bool open: false
    property real energy: 0
    property var bands: new Array(8).fill(0)

    readonly property bool speaking: RyuskiService.speaking
    readonly property real mouthWidth: 40
    readonly property real mouthHeight: 24
    readonly property bool lively: open || speaking || energy > 0.05
    readonly property color accent: lively ? Theme.primary : Theme.onSurfaceVariantColor
    readonly property string stringPath: {
        const n = bands.length, w = mouthWidth, h = mouthHeight, pts = [];
        const smile = 3 * (1 - Math.min(1, energy * 2));
        for (let i = 0; i < n * 2; ++i) {
            const t = i / (n * 2 - 1);
            const env = Math.sin(t * Math.PI);
            const lvl = Math.min(1, bands[i < n ? n - 1 - i : i - n]);
            pts.push([2 + t * (w - 4), h / 2 + smile * env + (i % 2 ? -1 : 1) * lvl * h * 0.42 * env]);
        }
        let d = "M" + pts[0];
        for (let i = 1; i < pts.length - 1; ++i) {
            d += " Q" + pts[i] + " " + (pts[i][0] + pts[i + 1][0]) / 2 + "," + (pts[i][1] + pts[i + 1][1]) / 2;
        }
        return d + " L" + pts[pts.length - 1];
    }

    signal clicked

    function hit(amount) {
        energy = Math.min(1, energy + amount * 0.6);
        bands = bands.map(v => Math.max(v, amount * (0.35 + 0.65 * Math.random())));
    }

    width: mouthWidth
    height: 40
    radius: height / 2
    color: Theme.background
    scale: area.pressed ? 0.94 : 1

    Behavior on scale {
        SpringAnimation {
            spring: 5
            damping: 0.3
            epsilon: 0.001
        }
    }

    Timer {
        interval: 16
        repeat: true
        running: root.speaking || root.energy > 0.002
        onTriggered: {
            if (root.speaking && Math.random() < 0.2)
                root.hit(0.5 + 0.5 * Math.random());
            root.energy *= 0.94;
            root.bands = root.bands.map(v => v * 0.93);
        }
    }

    Shape {
        anchors.centerIn: parent
        width: root.mouthWidth
        height: root.mouthHeight
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeWidth: 2.5
            strokeColor: root.accent
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin

            Behavior on strokeColor {
                ColorAnimation {
                    duration: 150
                }
            }

            PathSvg {
                path: root.stringPath
            }
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
