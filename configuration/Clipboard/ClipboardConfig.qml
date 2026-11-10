pragma Singleton
import QtQuick
import Quickshell
import Ryu.Sway

Singleton {
    id: root

    property bool open: false
    property string screenName: ""

    function focusedName() {
        return Sway.focusedMonitor?.name ?? Quickshell.screens[0]?.name ?? "";
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
