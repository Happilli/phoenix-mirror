pragma Singleton
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root

    readonly property var list: server.trackedNotifications
    NotificationServer {
        id: server
        imageSupported: true
        bodyHyperlinksSupported: true
        inlineReplySupported: true
        actionsSupported: true
        persistenceSupported: true
        bodyImagesSupported: true
        bodyMarkupSupported: true
        extraHints: ["values"]
        keepOnReload: true
        actionIconsSupported: true

        onNotification: n => {
            n.tracked = true;
        }
    }
}
