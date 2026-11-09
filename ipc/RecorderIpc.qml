import Ryu.Ipc
import qs.services.recorder

IpcHandler {
    target: "recorder"
    function toggleScreen(audio: string): string {
        return RecorderService.toggleScreen(audio);
    }
    function toggleRegion(audio: string): string {
        return RecorderService.toggleRegion(audio);
    }
}
