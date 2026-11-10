import Ryu.Ipc
import px.services.recorder

IpcHandler {
    target: "recorder"
    function toggleScreen(audio: string): string {
        return RecorderService.toggleScreen(audio);
    }
    function toggleRegion(audio: string): string {
        return RecorderService.toggleRegion(audio);
    }
}
