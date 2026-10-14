pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland

Scope {
    id: root

    signal finished

    property bool released: false

    function release() {
        if (released) {
            return;
        }
        released = true;
        lock.locked = false;
        finished();
    }

    Component.onCompleted: lock.locked = true

    LockContext {
        id: lockContext
        onUnlocked: fallback.start()
    }

    Timer {
        id: fallback
        interval: 700
        onTriggered: root.release()
    }

    WlSessionLock {
        id: lock
        locked: false

        WlSessionLockSurface {
            id: surface

            LockSurface {
                anchors.fill: parent
                context: lockContext
                screenName: surface.screen?.name ?? ""
            }
        }
    }
}
