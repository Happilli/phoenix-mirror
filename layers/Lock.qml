import QtQuick
import Ryu.Shell
import px.components.lock
import px.configuration.Lock

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
