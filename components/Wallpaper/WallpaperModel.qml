import Qt.labs.folderlistmodel
import qs.services.paths

FolderListModel {
    signal loaded

    folder: "file://" + PathService.home + "/Pictures"
    nameFilters: ["*.jpeg", "*.jpg"]
    showDirs: false
    sortField: FolderListModel.Name

    onStatusChanged: if (status === FolderListModel.Ready) {
        loaded();
    }
}
