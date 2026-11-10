import Ryu.Ipc
import px.configuration.Clipboard

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
