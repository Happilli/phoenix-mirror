import Qt.labs.folderlistmodel
import px.configuration.Wallpaper

FolderListModel {
    signal loaded

    folder: "file://" + WallpaperConfig.folder
    nameFilters: ["*.jpeg", "*.jpg", "*.png", "*.webp"]
    showDirs: false
    sortField: FolderListModel.Name

    onStatusChanged: if (status === FolderListModel.Ready) {
        loaded();
    }
}
