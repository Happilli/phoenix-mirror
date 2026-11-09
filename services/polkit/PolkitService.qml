pragma Singleton
import QtQuick
import Ryu.Polkit

QtObject {
    id: root
    readonly property bool active: agent.isActive
    readonly property var flow: agent.flow
    readonly property bool shown: active || verified
    property bool pending: false
    property bool verified: false
    function submit(text) {
        if (!root.flow)
            return;
        pending = true;
        verifiedHold.stop();
        pendingTimeout.restart();
        root.flow.submit(text);
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
    property Connections flowWatcher: Connections {
        target: root.agent.flow
        function onFailedChanged() {
            if (root.agent.flow?.failed) {
                root.pending = false;
                root.pendingTimeout.stop();
            }
        }
    }
    property Timer verifiedHold: Timer {
        interval: 700
        onTriggered: root.verified = false
    }
    property Timer pendingTimeout: Timer {
        interval: 8000
        onTriggered: root.pending = false
    }
    property PolkitAgent agent: PolkitAgent {}
}
