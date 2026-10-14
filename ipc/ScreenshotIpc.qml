import Quickshell.Io
import qs.configuration.Screenshot

IpcHandler {
    target: "screenshot"

    function capture(): string {
        return ScreenshotConfig.captureFocused() ? "capturing focused screen" : "busy";
    }
}
