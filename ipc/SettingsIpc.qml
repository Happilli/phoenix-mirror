import Ryu.Ipc
import px.configuration.Settings

IpcHandler {
    target: "settings"
    function toggle(): void {
        SettingsConfig.toggle();
    }
    function open(): void {
        SettingsConfig.open = true;
    }
}
