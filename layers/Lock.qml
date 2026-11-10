import QtQuick
import Quickshell
import qs.components.lock
import qs.configuration.Lock

Scope {
    SessionLock {
        id: sl
        onFinished: LockConfig.release()
    }

    Connections {
        target: LockConfig

        function onLockRequested() {
            sl.engage();
        }
    }
}
