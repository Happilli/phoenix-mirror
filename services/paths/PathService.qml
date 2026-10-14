pragma Singleton
import Quickshell
import QtQuick

QtObject {
    readonly property string home: Quickshell.env("HOME")
    readonly property string runtime: Quickshell.env("XDG_RUNTIME_DIR") || "/tmp"
}
