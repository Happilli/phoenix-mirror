import Qt.labs.folderlistmodel
import qs.services.paths

FolderListModel {
    folder: "file://" + PathService.home + "/Pictures"
    nameFilters: ["*.jpeg", "*.jpg"]
    showDirs: false
    sortField: FolderListModel.Name
}
