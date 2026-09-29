pragma Singleton
import Quickshell
import qs.configuration.Wallpaper
import Quickshell.Io
import qs.services.paths
import QtQuick

Singleton {
    id: root
    property string lastText: ""
    property bool queued: false

    property var md3: ({})
    property var palette: ({})
    property var base16: ({})

    function md3_returner(keys) {
        return md3[keys] ?? "transparent";
    }

    readonly property color background: md3_returner("background")
    readonly property color error: md3_returner("error")
    readonly property color onBackground: md3_returner("on_background")
    readonly property color primary: md3_returner("primary")
    readonly property color onPrimary: md3_returner("on_primary")

    function generate() {
        if (matugen.running) {
            root.queued = true;
            return;
        }
        const src = WallpaperConfig.currentWallpaper.toString().replace("file://", "");
        matugen.command = ["matugen", "--prefer", "saturation", "image", src];
        matugen.running = true;
    }

    Process {
        id: matugen
        onRunningChanged: {
            if (!running && root.queued) {
                root.generate();
                root.queued = false;
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
