pragma ComponentBehavior: Bound
import QtQuick
import Ryu.Wayland as Wl
import qs.services.theme

QtObject {
    id: root

    signal finished

    property bool released: false

    function release() {
        if (released) {
            return;
        }
        released = true;
        sessionLock.locked = false;
        finished();
    }

    function engage() {
        released = false;
        lockContext.currentText = "";
        lockContext.showFailure = false;
        sessionLock.locked = true;
    }

    property LockContext lockCtx: LockContext {
        id: lockContext
        onUnlocked: fallbackTimer.start()
    }

    property Timer fallback: Timer {
        id: fallbackTimer
        interval: 700
        onTriggered: root.release()
    }

    property QtObject lock: Wl.WlSessionLock {
        id: sessionLock
        locked: false
        color: Theme.background
        onFinished: root.release()

        Wl.WlSessionLockSurface {
            id: surface
            color: Theme.background

            Loader {
                anchors.fill: parent
                focus: true
                active: surface.ready
                sourceComponent: LockSurface {
                    context: lockContext
                    screenName: surface.screen?.name ?? ""
                }
            }
        }
    }
}
