pragma Singleton
import QtQuick
import qs.services.paths
import qs.services.state

QtObject {
    id: root

    readonly property url defaultWallpaper: "file://" + PathService.home + "/Pictures/kakarot.jpeg".toString()
    property url currentWallpaper: StateService.get("wallpaper", defaultWallpaper.toString())

    function setWallpaper(path) {
        const p = String(path);
        currentWallpaper = p.startsWith("file://") ? p : "file://" + p;
        StateService.set("wallpaper", currentWallpaper.toString());
    }
}
