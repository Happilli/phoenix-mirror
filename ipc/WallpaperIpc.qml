import Ryu.Ipc
import px.configuration.Wallpaper

IpcHandler {
    target: "wallpaper"
    function setWallpaper(path: string): string {
        if (!path || path.length == 0) {
            return "invalid path";
        }
        WallpaperConfig.setWallpaper(path);
        return "wallpaper set: " + path;
    }
}
