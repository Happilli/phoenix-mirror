//@ pragma DropExpensiveFonts
//@ pragma Env QSG_RENDER_LOOP=basic
import Quickshell
import qs.layers
import qs.ipc
import qs.Picker
import qs.Settings

ShellRoot {
    Scope {
        IpcRegistry {}
        Home {}
        AboveHome {}
        PickerWindow {}
        BeyondHome {}
        Lock {}
        SettingsWindow {}
    }
}
