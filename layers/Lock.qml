import QtQuick
import Ryu.Shell
import Ryu.Ui
import px.components.lock
import px.configuration.Lock

Scope {
    LazyLoader {
        active: LockConfig.active

        SessionLock {
            onFinished: LockConfig.release()
        }
    }
}
