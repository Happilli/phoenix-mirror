pragma Singleton
import Quickshell
import qs.configuration.Wallpaper
import Quickshell.Io
import qs.services.paths
import qs.services.state
import QtQuick

Singleton {
    id: root
    property string mode: StateService.get("mode", "dark")
    property string lastText: ""
    property bool queued: false
    readonly property bool isDark: mode === "dark"

    property var md3: ({})
    property var palette: ({})
    property var base16: ({})

    function md3_returner(keys) {
        return md3[keys] ?? "transparent";
    }

    readonly property color background: md3_returner("background")
    readonly property color onBackgroundColor: md3_returner("on_background")
    readonly property color error: md3_returner("error")
    readonly property color onErrorColor: md3_returner("on_error")
    readonly property color primary: md3_returner("primary")
    readonly property color onPrimaryColor: md3_returner("on_primary")
    readonly property color surfaceContainerHighest: md3_returner("surface_container_highest")
    readonly property color surfaceContainer: md3_returner("surface_container")
    readonly property color onSurfaceVariantColor: md3_returner("on_surface_variant")

    function setMode(newMode) {
        if (newMode !== "light" && newMode !== "dark")
            return;
        if (newMode === mode)
            return;
        StateService.set("mode", newMode);
        generate();
    }
    function toggleMode() {
        return setMode(isDark ? "light" : "dark");
    }

    function generate() {
        if (matugen.running) {
            root.queued = true;
            return;
        }
        const src = WallpaperConfig.currentWallpaper.toString().replace("file://", "");
        matugen.command = ["matugen", "--mode", root.mode, "--type", "scheme-content", "--source-color-index", "0", "image", src];
        matugen.running = true;
    }

    Process {
        id: matugen
        onRunningChanged: {
            if (!running && root.queued) {
                root.queued = false;
                root.generate();
            }
        }
    }
    FileView {
        path: PathService.home + "/.local/state/ryu/colors.json"
        watchChanges: true
        onFileChanged: reload()
        onLoadFailed: err => console.log("error loading file: ", err)
        onLoaded: {
            const raw = text();
            if (raw === root.lastText) {
                return;
            }
            let data;
            try {
                data = JSON.parse(raw);
            } catch (e) {
                console.log("parsing error: ", e);
                return;
            }
            root.lastText = raw;
            root.md3 = data.md3 ?? {};
            root.palette = data.palette ?? {};
            root.base16 = data.base16 ?? {};
        }
    }
}
