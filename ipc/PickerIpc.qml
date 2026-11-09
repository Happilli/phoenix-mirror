import Ryu.Ipc
import qs.configuration.Picker

IpcHandler {
    target: "picker"
    function toggle(windows: string, workspaces: string): void {
        PickerConfig.toggle(windows, workspaces);
    }
}
