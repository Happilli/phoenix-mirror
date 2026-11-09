import Ryu.Ipc
import qs.configuration.Clipboard

IpcHandler {
    target: "clipboard"
    function toggle(): void {
        ClipboardConfig.toggle();
    }
    function show(): void {
        ClipboardConfig.show();
    }
    function hide(): void {
        ClipboardConfig.hide();
    }
}
