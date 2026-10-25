pragma Singleton
import QtQuick

QtObject {
    property bool open: false
    property string page: "widgets"
    property string query: ""
    property string focusKey: ""
    property var scroller: null

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

    readonly property var entries: [
        {
            key: "clock.show",
            headline: "Show clock",
            supporting: "Display the clock on your desktop wallpaper",
            trailingText: "Widgets",
            leadingIcon: "\uf017",
            page: "widgets"
        },
        {
            key: "clock.color",
            headline: "Color",
            supporting: "Tint of the clock digits",
            trailingText: "Widgets",
            leadingIcon: "\udb80\udf01",
            page: "widgets"
        },
        {
            key: "clock.size",
            headline: "Size",
            supporting: "Overall size of the clock",
            trailingText: "Widgets",
            leadingIcon: "\uf0b2",
            page: "widgets"
        },
        {
            key: "clock.random",
            headline: "Randomize position",
            supporting: "Pick a spot based on the current wallpaper",
            trailingText: "Widgets",
            leadingIcon: "\uf074",
            page: "widgets"
        },
        {
            key: "clock.alignment",
            headline: "Alignment",
            supporting: "Where the clock sits on the screen",
            trailingText: "Widgets",
            leadingIcon: "\uf037",
            page: "widgets"
        },
        {
            key: "clock.orientation",
            headline: "Orientation",
            supporting: "Stack the digits or place them side by side",
            trailingText: "Widgets",
            leadingIcon: "\uf021",
            page: "widgets"
        },
        {
            key: "clock.separator",
            headline: "Separator",
            supporting: "Show the colon between hours and minutes",
            trailingText: "Widgets",
            leadingIcon: "\uf12c",
            page: "widgets"
        },
        {
            key: "clock.weight",
            headline: "Font weight",
            supporting: "Thickness of the digits",
            trailingText: "Widgets",
            leadingIcon: "\uf032",
            page: "widgets"
        },
        {
            key: "clock.24h",
            headline: "24-hour time",
            supporting: "Turn off to use 12-hour time",
            trailingText: "Widgets",
            leadingIcon: "\uf017",
            page: "widgets"
        },
        {
            key: "clock.ampm",
            headline: "Show AM/PM",
            supporting: "Display the period next to the time",
            trailingText: "Widgets",
            leadingIcon: "\uf186",
            page: "widgets"
        },
        {
            key: "clock.ampmPos",
            headline: "AM/PM position",
            supporting: "Where the period sits relative to the digits",
            trailingText: "Widgets",
            leadingIcon: "\uebe3",
            page: "widgets"
        },
        {
            key: "clock.margin",
            headline: "Margin",
            supporting: "Distance from the screen edges",
            trailingText: "Widgets",
            leadingIcon: "\udb80\udf53",
            page: "widgets"
        },
        {
            key: "clock.padding",
            headline: "Padding",
            supporting: "Inner margin around the clock",
            trailingText: "Widgets",
            leadingIcon: "\uf0b2",
            page: "widgets"
        },
        {
            key: "clock.gap",
            headline: "Digit gap",
            supporting: "Space cut between touching digits",
            trailingText: "Widgets",
            leadingIcon: "\uf1de",
            page: "widgets"
        },
        {
            key: "clock.overlap",
            headline: "Overlap",
            supporting: "How much neighbouring digits overlap",
            trailingText: "Widgets",
            leadingIcon: "\uf1de",
            page: "widgets"
        },
        {
            key: "clock.letterSpacing",
            headline: "Letter spacing",
            supporting: "Tracking between characters",
            trailingText: "Widgets",
            leadingIcon: "\uf1de",
            page: "widgets"
        },
        {
            key: "clock.groupGap",
            headline: "Group gap",
            supporting: "Space between hours, separator and minutes",
            trailingText: "Widgets",
            leadingIcon: "\uf1de",
            page: "widgets"
        },
        {
            key: "clock.reset",
            headline: "Reset to defaults",
            supporting: "Restore every clock setting",
            trailingText: "Widgets",
            leadingIcon: "\uf2ea",
            page: "widgets"
        },
        {
            key: "wall.appearance",
            headline: "Appearance",
            supporting: "Switch between dark and light mode",
            trailingText: "Wallpaper",
            leadingIcon: "\ueac6",
            page: "wallpaper"
        },
        {
            key: "wall.scheme",
            headline: "Color scheme",
            supporting: "How colors are generated from the wallpaper",
            trailingText: "Wallpaper",
            leadingIcon: "\udb80\udfd8",
            page: "wallpaper"
        },
        {
            key: "wall.folder",
            headline: "Folder",
            supporting: "Where wallpapers are loaded from",
            trailingText: "Wallpaper",
            leadingIcon: "\uf07c",
            page: "wallpaper"
        }
    ]

    readonly property var results: {
        const q = query.trim().toLowerCase();
        if (q === "")
            return entries;
        return entries.filter(e => (e.headline + " " + e.supporting + " " + e.trailingText).toLowerCase().includes(q));
    }

    readonly property int pageIndex: Math.max(0, pages.findIndex(p => p.key === page))
    readonly property string currentTitle: pages[pageIndex].headline

    function toggle() {
        open = !open;
    }

    function go(key) {
        page = key;
    }

    function reveal(key, targetPage) {
        page = targetPage;
        focusKey = "";
        focusKey = key;
    }
}
