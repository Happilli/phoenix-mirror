pragma ComponentBehavior: Bound

import QtQuick
import Ryu.Io
import Ryu.Wayland as Wl
import px.services.theme

Item {
    id: root

    required property var context
    required property var host
    required property string screenName

    signal exited

    property bool exiting: false
    property real enter: 0
    property real leave: 0
    property real warp: 0
    property bool shown: false

    function log(message) {
        if (host)
            host.log(message);
    }

    onShownChanged: {
        log("animations start shown=" + shown);
        if (shown) {
            forceActiveFocus();
            enter = 1;
            warp = 1;
        }
    }

    Component.onCompleted: log("scene created " + width + "x" + height)

    readonly property int length: context.currentText.length
    readonly property bool failed: context.showFailure
    readonly property bool busy: context.unlockInProgress
    readonly property real presence: enter * (1 - leave)
    readonly property real frameMargin: 28
    readonly property int maxShown: 48
    readonly property string user: Env.get("USER") || "user"
    readonly property string hashes: (length > maxShown ? "…" : "") + "#".repeat(Math.min(length, maxShown))
    readonly property color accent: failed ? Theme.error : Theme.primary
    readonly property color dimText: Theme.onSurfaceVariantColor
    readonly property string statusText: {
        if (exiting)
            return "access granted";
        if (failed)
            return "access denied";
        if (busy)
            return "verifying";
        return length + " chars";
    }
    readonly property color statusColor: exiting ? Theme.primary : (failed ? Theme.error : dimText)

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
            duration: 1100
            easing.type: Easing.OutBack
            easing.overshoot: 1.1
        }
    }

    NumberAnimation {
        id: exitWarp
        target: root
        property: "warp"
        to: 0
        duration: 650
        easing.type: Easing.InOutCubic
        onFinished: {
            root.log("exit animation finished");
            root.exited();
        }
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

        Wl.LockBackdrop {
            anchors.fill: parent
            screenName: root.screenName
        }
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: root.frameMargin
        color: Theme.surfaceContainerLow
        border.width: 2
        border.color: Theme.primary
        opacity: root.dim * root.presence
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.forceActiveFocus()
    }

    Item {
        id: frame
        anchors.fill: parent
        anchors.margins: root.frameMargin
        opacity: root.presence
        scale: 0.985 + 0.015 * root.enter

        TermText {
            x: 38
            y: 16
            text: "[ phoenix ]"
            font.pixelSize: 16
            color: root.accent
        }

        TermText {
            x: 38
            y: frame.height - 16 - implicitHeight
            text: "[ " + root.statusText + " ]"
            font.pixelSize: 16
            color: root.statusColor
        }

        TermText {
            x: frame.width - 38 - implicitWidth
            y: frame.height - 16 - implicitHeight
            text: "[ enter unlock · esc clear ]"
            font.pixelSize: 16
            color: root.dimText
        }

        Column {
            x: 40
            y: 64
            spacing: 6

            TermText {
                text: "session locked"
                color: root.dimText
            }

            TermText {
                text: "user: " + root.user
                color: root.dimText
            }

            Item {
                width: 1
                height: 10
            }

            Row {
                TermText {
                    text: "password "
                    color: root.dimText
                }

                TermText {
                    text: root.hashes
                    color: root.accent
                }
            }
        }
    }

    Connections {
        target: root.context

        function onUnlocked() {
            root.log("password accepted, exiting");
            root.exiting = true;
            root.leave = 1;
            exitWarp.start();
        }
    }
}
