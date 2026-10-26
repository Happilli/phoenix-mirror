pragma Singleton
import QtQuick

QtObject {
    property bool open: false
    property string page: "general"
    property string query: ""
    property string focusKey: ""
    property var scroller: null

    readonly property var pages: [
        {
            key: "general",
            headline: "General",
            leadingIcon: "\uf013"
        },
        {
            key: "widgets",
            headline: "Widgets",
            leadingIcon: "\uf009"
        },
        {
            key: "hyprland",
            headline: "Hyprland",
            leadingIcon: "\uf108"
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
            trailingText: "General",
            leadingIcon: "\ueac6",
            page: "general"
        },
        {
            key: "wall.scheme",
            headline: "Color scheme",
            supporting: "How colors are generated from the wallpaper",
            trailingText: "General",
            leadingIcon: "\udb80\udfd8",
            page: "general"
        },
        {
            key: "wall.folder",
            headline: "Wallpaper folder",
            supporting: "Where wallpapers are loaded from",
            trailingText: "General",
            leadingIcon: "\uf07c",
            page: "general"
        },
        {
            key: "bar.style",
            headline: "Bar style",
            supporting: "Horizon melts into the screen edge, Floating hovers free of it",
            trailingText: "General",
            leadingIcon: "\uf2d0",
            page: "general"
        },
        {
            key: "bar.edge",
            headline: "Bar position",
            supporting: "Screen edge the bar docks to",
            trailingText: "General",
            leadingIcon: "\uf0c9",
            page: "general"
        },
        {
            key: "bar.margin.left",
            headline: "Margin left",
            supporting: "Gap between the floating bar and the left screen edge",
            trailingText: "General",
            leadingIcon: "\udb80\udf53",
            page: "general"
        },
        {
            key: "bar.margin.right",
            headline: "Margin right",
            supporting: "Gap between the floating bar and the right screen edge",
            trailingText: "General",
            leadingIcon: "\udb80\udf53",
            page: "general"
        },
        {
            key: "bar.margin.top",
            headline: "Margin top",
            supporting: "Gap between the floating bar and the top screen edge",
            trailingText: "General",
            leadingIcon: "\udb80\udf53",
            page: "general"
        },
        {
            key: "bar.margin.bottom",
            headline: "Margin bottom",
            supporting: "Gap between the floating bar and the bottom screen edge",
            trailingText: "General",
            leadingIcon: "\udb80\udf53",
            page: "general"
        },
        {
            key: "bar.thickness",
            headline: "Bar thickness",
            supporting: "Size of the bar across the screen edge",
            trailingText: "General",
            leadingIcon: "\uf0b2",
            page: "general"
        },
        {
            key: "bar.radius",
            headline: "Bar corner radius",
            supporting: "Rounding of the bar edges",
            trailingText: "General",
            leadingIcon: "\uf1de",
            page: "general"
        },
        {
            key: "hypr.layout",
            headline: "Layout",
            supporting: "How tiled windows are arranged",
            trailingText: "Hyprland",
            leadingIcon: "\uf009",
            page: "hyprland"
        },
        {
            key: "hypr.gaps_in",
            headline: "Inner gaps",
            supporting: "Space between windows",
            trailingText: "Hyprland",
            leadingIcon: "\uf1de",
            page: "hyprland"
        },
        {
            key: "hypr.gaps_out",
            headline: "Outer gaps",
            supporting: "Space between windows and the screen edge",
            trailingText: "Hyprland",
            leadingIcon: "\uf1de",
            page: "hyprland"
        },
        {
            key: "hypr.border_size",
            headline: "Border size",
            supporting: "Thickness of the active window border",
            trailingText: "Hyprland",
            leadingIcon: "\uf0b2",
            page: "hyprland"
        },
        {
            key: "hypr.rounding",
            headline: "Corner radius",
            supporting: "Rounding of window corners",
            trailingText: "Hyprland",
            leadingIcon: "\uf1de",
            page: "hyprland"
        },
        {
            key: "hypr.active_opacity",
            headline: "Active opacity",
            supporting: "Opacity of the focused window",
            trailingText: "Hyprland",
            leadingIcon: "\uf042",
            page: "hyprland"
        },
        {
            key: "hypr.inactive_opacity",
            headline: "Inactive opacity",
            supporting: "Opacity of unfocused windows",
            trailingText: "Hyprland",
            leadingIcon: "\uf042",
            page: "hyprland"
        },
        {
            key: "hypr.dim_inactive",
            headline: "Dim inactive",
            supporting: "Darken windows that are not focused",
            trailingText: "Hyprland",
            leadingIcon: "\uf042",
            page: "hyprland"
        },
        {
            key: "hypr.shadow",
            headline: "Window shadows",
            supporting: "Draw a shadow behind windows",
            trailingText: "Hyprland",
            leadingIcon: "\uf042",
            page: "hyprland"
        },
        {
            key: "hypr.blur",
            headline: "Blur",
            supporting: "Blur the area behind transparent windows",
            trailingText: "Hyprland",
            leadingIcon: "\uf042",
            page: "hyprland"
        },
        {
            key: "hypr.blur_size",
            headline: "Blur size",
            supporting: "How far the blur spreads",
            trailingText: "Hyprland",
            leadingIcon: "\uf042",
            page: "hyprland"
        },
        {
            key: "hypr.blur_passes",
            headline: "Blur passes",
            supporting: "More passes look smoother but cost more GPU",
            trailingText: "Hyprland",
            leadingIcon: "\uf042",
            page: "hyprland"
        },
        {
            key: "hypr.animations",
            headline: "Animations",
            supporting: "Master switch for window and workspace animations",
            trailingText: "Hyprland",
            leadingIcon: "\uf04b",
            page: "hyprland"
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
