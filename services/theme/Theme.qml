pragma Singleton
import Quickshell
import qs.configuration.Wallpaper
import Quickshell.Io

Singleton {
    id: root
    property bool queued: false
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
}
