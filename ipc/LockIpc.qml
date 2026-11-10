import Ryu.Ipc
import px.configuration.Lock

IpcHandler {
    target: "lock"
    function lock(): string {
        LockConfig.requestLock();
        return "locking";
    }
    function locked(): bool {
        return LockConfig.active;
    }
}
