pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import qs.services.theme
import qs.configuration.Lock

Rectangle {
    id: root

    required property var context
    required property string screenName

    property bool exiting: false
    property real enter: 0
    property real leave: 0
    property real energy: 0
    property real phase: 0
    property var bands: new Array(24).fill(0)

    readonly property int length: context.currentText.length
    readonly property bool failed: context.showFailure
    readonly property color accent: failed ? Theme.error : Theme.primary
    readonly property real presence: Math.max(0, Math.min(1, enter)) * (1 - leave)
    readonly property string stringPath: {
        const n = bands.length, w = 380, h = 90, pts = [];
        for (let i = 0; i < n * 2; ++i) {
            const t = i / (n * 2 - 1);
            const lvl = Math.min(1, bands[i < n ? n - 1 - i : i - n]);
            pts.push([12 + t * (w - 24), h / 2 + (i % 2 ? -1 : 1) * lvl * h * 0.42 * Math.sin(t * Math.PI)]);
        }
        let d = "M" + pts[0];
        for (let i = 1; i < pts.length - 1; ++i) {
            d += " Q" + pts[i] + " " + (pts[i][0] + pts[i + 1][0]) / 2 + "," + (pts[i][1] + pts[i + 1][1]) / 2;
        }
        return d + " L" + pts[pts.length - 1];
    }

    function hit(amount) {
        energy = Math.min(1, energy + amount * 0.6);
        bands = bands.map(v => Math.max(v, amount * (0.35 + 0.65 * Math.random())));
    }

    color: Theme.background
    focus: true

    Behavior on enter {
        NumberAnimation {
            duration: 700
            easing.type: Easing.OutCubic
        }
    }

    Behavior on leave {
        NumberAnimation {
            duration: 450
            easing.type: Easing.InCubic
        }
    }

    Component.onCompleted: {
        forceActiveFocus();
        enter = 1;
    }

    onLengthChanged: {
        hit(0.9);
        ring.t = 0;
        ringAnim.restart();
    }

    onFailedChanged: {
        if (failed) {
            hit(2);
            shake.x = 18;
            shakeSpring.restart();
        }
    }

    Timer {
        interval: 16
        repeat: true
        running: root.energy > 0.002
        onTriggered: {
            root.phase += 0.03 + root.energy * 0.3;
            root.energy *= 0.94;
            root.bands = root.bands.map(v => v * 0.93);
        }
    }

    Keys.onPressed: e => {
        if (exiting || context.unlockInProgress) {
            return;
        }
        const ctrl = e.modifiers & Qt.ControlModifier;
        if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) {
            context.tryUnlock();
        } else if (e.key === Qt.Key_Backspace) {
            context.currentText = ctrl ? "" : context.currentText.slice(0, -1);
        } else if (e.key === Qt.Key_Escape) {
            context.currentText = "";
        } else if (!ctrl && e.text >= " " && e.text !== "\x7f") {
            context.currentText += e.text;
        }
        e.accepted = true;
    }

    Image {
        id: bg
        anchors.fill: parent
        source: root.screenName !== "" ? "file://" + LockConfig.backgroundFor(root.screenName) : ""
        fillMode: Image.PreserveAspectCrop
        cache: false
        layer.enabled: true
    }

    MultiEffect {
        anchors.fill: bg
        source: bg
        blurEnabled: true
        blurMax: 32
        blur: root.presence * 0.6
        autoPaddingEnabled: false
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.forceActiveFocus()
    }

    Item {
        id: content
        anchors.centerIn: parent
        width: 260
        height: 260
        opacity: root.presence
        scale: 0.96 + 0.04 * root.enter + 0.06 * root.leave
        transform: Translate {
            id: shake
        }

        SpringAnimation {
            id: shakeSpring
            target: shake
            property: "x"
            to: 0
            spring: 6
            damping: 0.2
            epsilon: 0.5
        }

        Rectangle {
            id: ring
            property real t: 1
            anchors.centerIn: parent
            width: 88
            height: width
            radius: width / 2
            color: "transparent"
            border.width: 1.5
            border.color: root.accent
            scale: 1 + t * 1.2
            opacity: (1 - t) * 0.55

            NumberAnimation {
                id: ringAnim
                target: ring
                property: "t"
                to: 1
                duration: 850
                easing.type: Easing.OutCubic
            }
        }

        Repeater {
            model: 60

            Item {
                id: tick
                required property int index
                readonly property real wave: 0.5 + 0.5 * Math.cos(index * Math.PI / 5 - root.phase)
                readonly property real wave2: 0.5 + 0.5 * Math.cos(index * Math.PI / 10 + root.phase * 0.6)

                anchors.centerIn: parent
                rotation: index * 6

                Rectangle {
                    width: 2
                    height: 3 + 20 * root.energy * (0.65 * tick.wave + 0.35 * tick.wave2)
                    radius: 1
                    x: -1
                    y: -58 - height
                    color: root.accent
                    opacity: 0.18 + 0.72 * root.energy * (0.4 + 0.6 * tick.wave)
                }
            }
        }

        Rectangle {
            anchors.centerIn: parent
            width: 88
            height: width
            radius: width / 2
            color: Qt.alpha(Theme.surfaceContainer, 0.75)
            border.width: 1
            border.color: root.failed ? Theme.error : Qt.alpha(Theme.primary, 0.15 + 0.7 * root.energy)
            scale: (0.8 + 0.2 * root.enter) * (1 + 0.2 * root.energy)

            Behavior on scale {
                SpringAnimation {
                    spring: 5
                    damping: 0.2
                    epsilon: 0.001
                }
            }

            Text {
                anchors.centerIn: parent
                text: root.failed ? "\uf071" : root.exiting ? "\uf09c" : "\uf023"
                font.pixelSize: 30
                color: root.failed ? Theme.error : (root.exiting || root.length > 0) ? Theme.primary : Theme.onSurfaceVariantColor

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }
            }
        }

        Shape {
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height / 2 + 96
            width: 380
            height: 90
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                strokeWidth: 2.5
                strokeColor: root.accent
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap
                joinStyle: ShapePath.RoundJoin

                PathSvg {
                    path: root.stringPath
                }
            }
        }
    }

    Connections {
        target: root.context

        function onUnlocked() {
            root.exiting = true;
            root.hit(2);
            root.leave = 1;
        }
    }
}
