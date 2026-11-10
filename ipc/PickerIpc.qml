import Ryu.Ipc
import qs.configuration.Picker

IpcHandler {
    target: "picker"

    function toggle(): void {
        PickerConfig.toggle();
    }
}
