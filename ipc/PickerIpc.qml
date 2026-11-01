import Quickshell.Io
import qs.configuration.Picker

IpcHandler {
    target: "picker"

    function toggle(): void {
        PickerConfig.toggle();
    }
}
