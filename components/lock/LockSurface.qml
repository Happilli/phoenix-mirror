pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import qs.services.theme
import qs.configuration.Lock
import qs.components.metal
import qs.configuration.Bar

Item {
    id: root

    required property var context
    required property string screenName

    property bool exiting: false
    property real enter: 0
    property real leave: 0
    property real warp: 0

    readonly property int length: context.currentText.length
    readonly property bool failed: context.showFailure
    readonly property real presence: enter * (1 - leave)

    property color accent: failed ? Theme.error : Theme.primary
    property color iconColor: failed ? Theme.onErrorColor : Theme.onPrimaryColor
    property real dialAngle: exiting ? 720 : length * 21.6

    readonly property real maxAngle: -6
    readonly property real zoom: 0.5
    readonly property real dim: 0.5
    readonly property real tilt: warp * maxAngle
    readonly property real aspect: Math.max(width, height) / Math.max(1, Math.min(width, height))
    readonly property real angleRad: Math.abs(tilt) * Math.PI / 180
    readonly property real coverScale: Math.cos(angleRad) + aspect * Math.sin(angleRad)
    readonly property real stageScale: Math.max(1 + zoom * warp, coverScale)

    focus: true
    clip: true

    Behavior on accent {
        ColorAnimation {
            duration: 150
        }
    }

    Behavior on iconColor {
        ColorAnimation {
            duration: 150
        }
    }

    Behavior on enter {
        NumberAnimation {
            duration: 900
            easing.type: Easing.OutCubic
        }
    }

    Behavior on leave {
        NumberAnimation {
            duration: 450
            easing.type: Easing.InCubic
        }
    }

    Behavior on warp {
        NumberAnimation {
            duration: root.exiting ? 650 : 1100
            easing.type: root.exiting ? Easing.InOutCubic : Easing.OutBack
            easing.overshoot: 1.1
        }
    }

    Behavior on dialAngle {
        NumberAnimation {
            duration: 450
            easing.type: Easing.OutCubic
        }
    }

    Component.onCompleted: {
        forceActiveFocus();
        enter = 1;
        warp = 1;
    }

    Keys.onPressed: e => {
        e.accepted = true;
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
    }

    Item {
        id: stage
        anchors.fill: parent
        rotation: root.tilt
        scale: root.stageScale
        transformOrigin: Item.Center

        Image {
            id: bg
            anchors.fill: parent
            source: root.screenName !== "" ? "file://" + LockConfig.backgroundFor(root.screenName) : ""
            fillMode: Image.PreserveAspectCrop
            cache: false
            smooth: true
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
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.surfaceContainerLow
        opacity: root.dim * root.presence
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.forceActiveFocus()
    }

    Item {
        id: vault
        anchors.centerIn: parent

        readonly property real size: Math.min(root.width, root.height) * 0.38
        readonly property real hub: size * 0.34
        readonly property real rim: size * 0.045
        readonly property real spokeWidth: size * 0.02
        readonly property real knob: size * 0.15
        readonly property real reach: size / 2 + knob / 2 + size * 0.015
        readonly property real pad: size * 0.07
        readonly property real extent: (reach + knob / 2 + pad) * 2 + 4
        readonly property real angle: root.dialAngle - 180 * (1 - root.enter)
        readonly property string path: wheelPath(angle)
        readonly property string hubPath: circle(hub / 2, hub / 2, hub / 2, true)

        function circle(cx, cy, r, clockwise) {
            const s = clockwise ? 1 : 0;
            return `M ${cx + r} ${cy} A ${r} ${r} 0 1 ${s} ${cx - r} ${cy} A ${r} ${r} 0 1 ${s} ${cx + r} ${cy} Z `;
        }

        function wheelPath(deg) {
            const c = extent / 2;
            const half = spokeWidth / 2;
            const r0 = hub / 2 - 1;
            const off = deg * Math.PI / 180;
            let p = circle(c, c, size / 2, true) + circle(c, c, size / 2 - rim, false) + circle(c, c, hub / 2, true);
            for (let i = 0; i < 8; i++) {
                const a = i * Math.PI / 4 + off;
                const dx = Math.sin(a);
                const dy = -Math.cos(a);
                const nx = Math.cos(a) * half;
                const ny = Math.sin(a) * half;
                const x0 = c + dx * r0;
                const y0 = c + dy * r0;
                const x1 = c + dx * reach;
                const y1 = c + dy * reach;
                p += `M ${x0 - nx} ${y0 - ny} L ${x1 - nx} ${y1 - ny} L ${x1 + nx} ${y1 + ny} L ${x0 + nx} ${y0 + ny} Z `;
                p += circle(x1, y1, knob / 2, true);
            }
            return p;
        }

        width: size
        height: size
        scale: 0.9 + 0.1 * root.enter + 0.06 * root.leave

        Item {
            anchors.centerIn: parent
            width: vault.extent
            height: vault.extent
            opacity: root.presence

            Shape {
                anchors.fill: parent
                preferredRendererType: Shape.CurveRenderer
                opacity: 0.5
                transform: Translate {
                    x: vault.size * 0.012
                    y: vault.size * 0.024
                }

                layer.enabled: true
                layer.smooth: true
                layer.effect: MultiEffect {
                    autoPaddingEnabled: false
                    blurEnabled: true
                    blurMax: 32
                    blur: 0.4
                }

                ShapePath {
                    fillRule: ShapePath.WindingFill
                    fillColor: "black"
                    strokeWidth: -1
                    strokeColor: "transparent"

                    PathSvg {
                        path: vault.path
                    }
                }
            }
            Metal {
                anchors.fill: parent
                kind: "wheel"
                base: root.accent
                path: vault.path
                extent: vault.extent
            }

            Metal {
                anchors.centerIn: parent
                width: vault.hub
                height: vault.hub
                kind: "hub"
                path: vault.hubPath
                hubSize: vault.hub
            }

            Text {
                anchors.centerIn: parent
                text: root.failed ? "\uf071" : root.exiting ? "\uf09c" : "\uf023"
                font.pixelSize: vault.hub * 0.5
                scale: 0.8 + 0.2 * root.enter
                color: root.iconColor
            }
        }
    }

    Connections {
        target: root.context

        function onUnlocked() {
            root.exiting = true;
            root.leave = 1;
            root.warp = 0;
        }
    }
}
