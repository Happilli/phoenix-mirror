import Ryu.Ipc
import qs.configuration.Settings

IpcHandler {
    target: "settings"
    function toggle(): void {
        SettingsConfig.toggle();
    }
    function open(): void {
        SettingsConfig.open = true;
    }
}
