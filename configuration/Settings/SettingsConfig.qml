pragma Singleton
import QtQuick

QtObject {
    property bool open: false
    property string page: "widgets"

    readonly property var pages: [
        {
            key: "widgets",
            headline: "Widgets",
            leadingIcon: "\uf009"
        },
        {
            key: "wallpaper",
            headline: "Wallpaper",
            leadingIcon: "\uf03e"
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
