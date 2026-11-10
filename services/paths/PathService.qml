pragma Singleton

import QtQuick
import Ryu.Io

QtObject {
    readonly property string home: Env.get("HOME")
    readonly property string runtime: Env.get("XDG_RUNTIME_DIR") || "/tmp"
}
