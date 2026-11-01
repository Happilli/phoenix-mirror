//@ pragma DropExpensiveFonts
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
