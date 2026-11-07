pragma ComponentBehavior: Bound
import QtQuick
import Ryu.Extraa
import qs.configuration.Wallpaper
import qs.services.theme

Item {
    id: root

    property var items: []

    function rebuild() {
        const out = [];
        for (let i = 0; i < walls.count; i++) {
            out.push({
                image: "file://" + walls.get(i, "filePath")
            });
        }
        items = out;
        syncToCurrent();
    }

    function syncToCurrent() {
        const target = WallpaperConfig.currentWallpaper.toString();
        for (let i = 0; i < walls.count; i++) {
            if ("file://" + walls.get(i, "filePath") === target) {
                carousel.scrollTo(i, false);
                return;
            }
        }
    }

    function select(index) {
        if (index < 0 || index >= walls.count)
            return;
        WallpaperConfig.setWallpaper(walls.get(index, "filePath"));
        Theme.generate();
    }

    WallpaperModel {
        id: walls
        onLoaded: root.rebuild()
    }

    Connections {
        target: WallpaperConfig

        function onCurrentWallpaperChanged() {
            const p = walls.get(carousel.currentIndex, "filePath");
            if (p === undefined || "file://" + p !== WallpaperConfig.currentWallpaper.toString())
                root.syncToCurrent();
        }
    }

    MaterialCarousel {
        id: carousel
        anchors.fill: parent
        model: root.items
        type: MaterialCarousel.CenteredHero
        activeFocusOnTab: true
        itemRadius: 24
        itemSpacing: 8
        itemColor: Theme.surfaceContainerHighest
        stateLayerColor: Theme.shadow

        HoverHandler {
            onHoveredChanged: if (hovered && !carousel.activeFocus)
                carousel.forceActiveFocus()
        }

        onClicked: (index, item) => root.select(index)
    }
}
