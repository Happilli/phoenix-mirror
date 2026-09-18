pragma Singleton
import QtQuick
import qs.services.paths

QtObject {
    id: root

    readonly property url defaultWallpaper: "file://" + PathService.home + "/Pictures/kakarot.jpeg".toString()
    property url currentWallpaper: root.defaultWallpaper

    function setWallpaper(path) {
        currentWallpaper = path.startsWith("file://") ? path : "file://" + path;
    }
}
