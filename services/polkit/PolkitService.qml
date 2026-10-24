pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Polkit

Singleton {
    id: root

    readonly property bool active: agent.isActive
    readonly property var flow: agent.flow
    readonly property bool shown: active || verified

    property bool pending: false
    property bool verified: false

    function submit(text) {
        if (!agent.flow)
            return;
        pending = true;
        pendingTimeout.restart();
        agent.flow.submit(text);
    }

    onActiveChanged: {
        if (active) {
            verified = false;
            pending = false;
        } else if (pending) {
            pending = false;
            pendingTimeout.stop();
            verified = true;
            verifiedHold.restart();
        }
    }

    Connections {
        target: agent.flow

        function onFailedChanged() {
            if (agent.flow?.failed) {
                root.pending = false;
                pendingTimeout.stop();
            }
        }
    }

    Timer {
        id: verifiedHold
        interval: 700
        onTriggered: root.verified = false
    }

    Timer {
        id: pendingTimeout
        interval: 8000
        onTriggered: root.pending = false
    }

    PolkitAgent {
        id: agent
    }
}
