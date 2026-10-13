pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    property bool shown: false
    property string key: "volume"

    function show(k) {
        key = k;
        shown = true;
        hideTimer.restart();
    }

    Timer {
        id: hideTimer
        interval: 1500
        onTriggered: root.shown = false
    }
}
