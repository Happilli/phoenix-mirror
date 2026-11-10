import Ryu.Ipc
import px.configuration.Picker

IpcHandler {
    target: "picker"

    function toggle(): void {
        PickerConfig.toggle();
    }
}
