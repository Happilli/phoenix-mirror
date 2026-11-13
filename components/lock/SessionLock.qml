pragma ComponentBehavior: Bound

import QtQuick
import Ryu.Shell
import Ryu.Wayland as Wl
import px.configuration.Lock

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

    property LockContext lockCtx: LockContext {
        id: lockContext
    }

    property QtObject lock: Wl.WlSessionLock {
        id: sessionLock

        color: "#ff00ff"
        onFinished: root.release()

        Wl.WlSessionLockSurface {
            id: surface
            LockSurface {
                anchors.fill: parent
                context: lockContext
                screenName: surface.screenName
                shown: surface.painted
                onExited: root.release()
            }
        }
    }

    Component.onCompleted: {
        const paths = {};
        for (const s of Screens.list) {
            paths[s.name] = LockConfig.backgroundFor(s.name);
        }
        sessionLock.backgrounds = paths;
        sessionLock.locked = true;
    }
}
