import QtQuick
import QtQuick.Shapes
import px.services.theme
import px.configuration.Screenshot

Item {
    id: root

    property point a: Qt.point(0, 0)
    property point b: Qt.point(0, 0)
    property bool dragging: false
    property var pts: []
    property point cur: Qt.point(0, 0)
    property bool seen: false
    property real lastX: 0
    property real lastY: 0
    property real aim: 0
    property real angle: aim

    readonly property bool lasso: ScreenshotConfig.lassoMode
    readonly property real iconOffset: 0
    readonly property real sx: Math.min(a.x, b.x)
    readonly property real sy: Math.min(a.y, b.y)
    readonly property real sw: Math.abs(a.x - b.x)
    readonly property real sh: Math.abs(a.y - b.y)
    readonly property bool has: dragging && sw > 1 && sh > 1

    function steer(x, y) {
        const dx = x - lastX;
        const dy = y - lastY;
        if (Math.hypot(dx, dy) < 5)
            return;
        const t = Math.atan2(dy, dx) * 180 / Math.PI + iconOffset;
        aim += ((t - aim) % 360 + 540) % 360 - 180;
        lastX = x;
        lastY = y;
    }

    function finishLasso() {
        dragging = false;
        if (pts.length < 3) {
            pts = [];
            ScreenshotConfig.finishSelect("", null);
            return;
        }
        let x0 = 1e9, y0 = 1e9, x1 = 0, y1 = 0;
        for (const p of pts) {
            x0 = Math.min(x0, p.x);
            y0 = Math.min(y0, p.y);
            x1 = Math.max(x1, p.x);
            y1 = Math.max(y1, p.y);
        }
        if (x1 - x0 <= 4 || y1 - y0 <= 4) {
            pts = [];
            ScreenshotConfig.finishSelect("", null);
            return;
        }
        const rect = {
            x: x0,
            y: y0,
            w: x1 - x0,
            h: y1 - y0,
            sw: root.width
        };
        const poly = pts.map(p => ({
                    x: p.x,
                    y: p.y
                }));
        pts = [];
        ScreenshotConfig.finishLasso(rect, poly);
    }

    focus: true
    Component.onCompleted: forceActiveFocus()
    Keys.onEscapePressed: ScreenshotConfig.finishSelect("", null)

    Behavior on angle {
        SpringAnimation {
            spring: 3
            damping: 0.3
            epsilon: 0.05
        }
    }

    Rectangle {
        x: 0
        y: 0
        width: parent.width
        height: root.has ? root.sy : parent.height
        color: Theme.scrim
        opacity: 0.55
        visible: !root.lasso
    }

    Rectangle {
        x: 0
        y: root.sy + root.sh
        width: parent.width
        height: root.has ? parent.height - y : 0
        color: Theme.scrim
        opacity: 0.55
        visible: !root.lasso
    }

    Rectangle {
        x: 0
        y: root.sy
        width: root.has ? root.sx : 0
        height: root.sh
        color: Theme.scrim
        opacity: 0.55
        visible: !root.lasso
    }

    Rectangle {
        x: root.sx + root.sw
        y: root.sy
        width: root.has ? parent.width - x : 0
        height: root.sh
        color: Theme.scrim
        opacity: 0.55
        visible: !root.lasso
    }

    Shape {
        anchors.fill: parent
        visible: root.lasso
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillRule: ShapePath.OddEvenFill
            fillColor: Qt.alpha(Theme.scrim, 0.55)
            strokeWidth: -1
            strokeColor: "transparent"

            PathSvg {
                path: {
                    let d = "M 0 0 L " + root.width + " 0 L " + root.width + " " + root.height + " L 0 " + root.height + " Z";
                    const all = root.pts.length > 0 ? root.pts.concat([root.cur]) : [];
                    if (all.length > 2) {
                        d += " M " + all[0].x + " " + all[0].y;
                        for (let i = 1; i < all.length; i++)
                            d += " L " + all[i].x + " " + all[i].y;
                        d += " Z";
                    }
                    return d;
                }
            }
        }
    }
    Rectangle {
        visible: root.has && !root.lasso
        x: root.sx
        y: root.sy
        width: root.sw
        height: root.sh
        color: "transparent"
        border.width: 2
        border.color: Theme.primary
    }

    Rectangle {
        visible: root.has && !root.lasso
        x: root.sx
        y: root.sy + root.sh + 8
        width: label.implicitWidth + 16
        height: 24
        radius: 12
        color: Theme.background

        Text {
            id: label
            anchors.centerIn: parent
            text: Math.round(root.sw) + " × " + Math.round(root.sh)
            font.pixelSize: 12
            font.weight: Font.Medium
            color: Theme.primary
        }
    }

    Shape {
        anchors.fill: parent
        visible: root.lasso && root.pts.length > 1
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeWidth: 2
            strokeColor: Theme.primary
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin

            PathPolyline {
                path: root.pts.concat([root.cur])
            }
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: root.lasso
        cursorShape: root.lasso ? Qt.BlankCursor : Qt.CrossCursor
        acceptedButtons: Qt.LeftButton

        onPressed: mouse => {
            if (root.lasso) {
                root.pts = [Qt.point(mouse.x, mouse.y)];
                root.dragging = true;
                return;
            }
            root.a = Qt.point(mouse.x, mouse.y);
            root.b = root.a;
            root.dragging = true;
        }

        onPositionChanged: mouse => {
            const x = Math.max(0, Math.min(width, mouse.x));
            const y = Math.max(0, Math.min(height, mouse.y));
            if (root.lasso) {
                if (!root.seen) {
                    root.lastX = x;
                    root.lastY = y;
                }
                root.cur = Qt.point(x, y);
                root.seen = true;
                root.steer(x, y);
                if (root.dragging) {
                    const last = root.pts[root.pts.length - 1];
                    if (Math.hypot(x - last.x, y - last.y) >= 3)
                        root.pts = root.pts.concat([Qt.point(x, y)]);
                }
                return;
            }
            if (root.dragging)
                root.b = Qt.point(x, y);
        }

        onReleased: {
            if (root.lasso) {
                root.finishLasso();
                return;
            }
            const ok = root.sw > 4 && root.sh > 4;
            const rect = {
                x: Math.round(root.sx),
                y: Math.round(root.sy),
                w: Math.round(root.sw),
                h: Math.round(root.sh),
                sw: Math.round(root.width)
            };
            root.dragging = false;
            ScreenshotConfig.finishSelect(ok ? "go" : "", ok ? rect : null);
        }
    }

    Item {
        id: scissors
        z: 10
        visible: root.lasso && root.seen
        x: root.cur.x
        y: root.cur.y
        width: 0
        height: 0
        rotation: root.angle
        scale: area.pressed ? 0.86 : 1

        Behavior on scale {
            SpringAnimation {
                spring: 5
                damping: 0.4
                epsilon: 0.005
            }
        }

        Text {
            x: -width * 0.5
            y: -height / 2
            text: "\uf0c4"
            font.pixelSize: 20
            color: Theme.primary
            style: Text.Outline
            styleColor: Theme.scrim
        }
    }
}
