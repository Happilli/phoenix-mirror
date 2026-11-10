pragma Singleton
import QtQuick
import Ryu.Sway
import Ryu.Notifications

QtObject {
    id: root

    readonly property var list: serverx.trackedNotifications
    property var queue: []
    property bool processing: false

    signal notificationReady(var n)
    signal dismissNotification(int id)

    function focusedScreen() {
        return Sway.focusedMonitor?.name ?? Sway.monitors.values[0]?.name ?? "";
    }

    function enqueue(n) {
        queue.push({
            "id": n.id,
            "screenName": focusedScreen(),
            "summary": n.summary || "Notification",
            "body": n.body || "",
            "appName": n.appName || "",
            "image": (typeof n.image === "string") ? n.image : "",
            "appIcon": (typeof n.appIcon === "string") ? n.appIcon : ""
        });
        if (!processing) {
            processNext();
        }
    }

    function processNext() {
        if (queue.length === 0) {
            processing = false;
            watchdoggo.stop();
            return;
        }
        processing = true;
        watchdoggo.restart();
        notificationReady(queue.shift());
    }

    function onItemEntered() {
        watchdoggo.stop();
        Qt.callLater(processNext);
    }

    function dismiss(id) {
        dismissNotification(id);
    }

    property Timer watchdog: Timer {
        id: watchdoggo
        interval: 1500
        onTriggered: {
            root.processing = false;
            root.processNext();
        }
    }

    property NotificationServer server: NotificationServer {
        id: serverx
        imageSupported: true
        bodyHyperlinksSupported: true
        inlineReplySupported: true
        actionsSupported: true
        persistenceSupported: true
        bodyImagesSupported: true
        bodyMarkupSupported: true
        bodySupported: true
        extraHints: ["values"]
        keepOnReload: false
        actionIconsSupported: true
        onNotification: n => {
            n.tracked = true;
            root.enqueue(n);
        }
    }
}
