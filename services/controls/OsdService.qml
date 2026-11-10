pragma Singleton

import QtQuick

QtObject {
    id: root

    property bool shown: false
    property string key: "volume"

    function show(k) {
        key = k;
        shown = true;
        hideTimer.restart();
    }

    property Timer hideTimer: Timer {
        interval: 1500
        onTriggered: root.shown = false
    }
}
