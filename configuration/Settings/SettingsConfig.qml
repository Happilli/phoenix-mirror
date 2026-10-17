pragma Singleton
import QtQuick

QtObject {
    property bool open: false
    property string page: "widgets"

    readonly property var pages: [
        {
            key: "widgets",
            headline: "Widgets",
            // supporting: "Desktop clock",
            leadingIcon: "\uf009"
        }
    ]

    readonly property int pageIndex: Math.max(0, pages.findIndex(p => p.key === page))

    function toggle() {
        open = !open;
    }

    function go(key) {
        page = key;
    }
}
