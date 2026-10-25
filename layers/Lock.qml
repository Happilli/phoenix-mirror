pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs.components.lock
import qs.configuration.Lock

Scope {
    LazyLoader {
        id: loader

        component: Component {
            SessionLock {
                onFinished: {
                    LockConfig.release();
                    Qt.callLater(() => loader.active = false);
                }
            }
        }
    }

    Connections {
        target: LockConfig

        function onLockRequested() {
            loader.active = true;
        }
    }
}
