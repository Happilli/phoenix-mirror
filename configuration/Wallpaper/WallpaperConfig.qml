pragma Singleton
import QtQuick
import px.services.paths
import px.services.state

QtObject {
    id: root

    readonly property string defaultFolder: PathService.home + "/Pictures"
    readonly property url defaultWallpaper: "file://" + PathService.home + "/Pictures/kakarot.jpeg".toString()

    property string folder: StateService.get("wallpaperFolder", defaultFolder)
    property url currentWallpaper: StateService.get("wallpaper", defaultWallpaper.toString())

    function setFolder(path) {
        let p = String(path).trim().replace(/^file:\/\//, "");
        if (p.startsWith("~"))
            p = PathService.home + p.slice(1);
        if (p.length > 1)
            p = p.replace(/\/+$/, "");
        if (p === "")
            return;
        folder = p;
        StateService.set("wallpaperFolder", p);
    }

    function resetFolder() {
        setFolder(defaultFolder);
    }

    function setWallpaper(path) {
        const p = String(path);
        currentWallpaper = p.startsWith("file://") ? p : "file://" + p;
        StateService.set("wallpaper", currentWallpaper.toString());
    }
}
