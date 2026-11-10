pragma Singleton

import QtQuick
import Ryu.Sway
import Ryu.Shell

QtObject {
    id: root

    property bool open: false
    property string screenName: ""

    function focusedName() {
        return Sway.focusedMonitor?.name ?? Screens.list[0]?.name ?? "";
    }

    function show() {
        screenName = focusedName();
        open = true;
    }

    function hide() {
        open = false;
    }

    function toggle() {
        open ? hide() : show();
    }
}
