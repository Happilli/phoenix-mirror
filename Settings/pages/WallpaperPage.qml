import QtQuick
import QtQuick.Dialogs
import Ryu.Extraa
import qs.services.theme
import qs.configuration.Wallpaper
import qs.components.Wallpaper
import qs.Settings.components

SettingsPage {
    id: page
    title: "Wallpaper"

    readonly property var schemeLabels: Theme.schemes.map(s => s.replace("scheme-", "").replace(/-/g, " "))
    readonly property int schemeIndex: Theme.schemes.indexOf(Theme.scheme)

    function toPath(url) {
        return decodeURIComponent(String(url).replace(/^file:\/\//, ""));
    }

    header: WallpaperCarousel {
        width: parent.width
        height: Math.max(130, Math.min(240, page.height * 0.28))
    }

    FolderDialog {
        id: folderDialog
        title: "Wallpaper folder"
        currentFolder: "file://" + WallpaperConfig.folder
        onAccepted: WallpaperConfig.setFolder(page.toPath(selectedFolder))
    }

    FileDialog {
        id: fileDialog
        title: "Choose a picture"
        currentFolder: "file://" + WallpaperConfig.folder
        nameFilters: ["Images (*.jpg *.jpeg *.png *.webp)"]
        onAccepted: {
            const path = page.toPath(selectedFile);
            WallpaperConfig.setFolder(path.substring(0, path.lastIndexOf("/")));
            WallpaperConfig.setWallpaper(path);
            Theme.generate();
        }
    }

    SettingsGroup {
        SettingsGroup.Entry {
            title: "Folder"
            description: "Where wallpapers are loaded from. Press Enter to apply"

            Row {
                id: folderRow

                readonly property real avail: parent?.limit ?? 360

                spacing: 8

                Rectangle {
                    width: Math.max(140, Math.min(360, folderRow.avail - 180))
                    height: 40
                    radius: 20
                    color: Theme.surfaceContainerHighest
                    border.width: 2
                    border.color: pathInput.activeFocus ? Theme.primary : "transparent"

                    Connections {
                        target: WallpaperConfig

                        function onFolderChanged() {
                            pathInput.text = WallpaperConfig.folder;
                        }
                    }

                    TextInput {
                        id: pathInput
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        verticalAlignment: TextInput.AlignVCenter
                        clip: true
                        text: WallpaperConfig.folder
                        font.pixelSize: 13
                        color: Theme.onBackgroundColor
                        selectionColor: Qt.alpha(Theme.primary, 0.3)
                        selectedTextColor: Theme.onBackgroundColor

                        onAccepted: {
                            WallpaperConfig.setFolder(text);
                            focus = false;
                        }
                        onActiveFocusChanged: if (!activeFocus)
                            text = WallpaperConfig.folder
                        Keys.onEscapePressed: focus = false
                    }
                }

                MaterialIconButton {
                    type: MaterialIconButton.Tonal
                    sizeStyle: MaterialIconButton.Small
                    widthStyle: MaterialIconButton.Wide
                    iconText: "\uf07c"
                    color: Theme.surfaceContainerHighest
                    iconColor: Theme.onSurfaceVariantColor
                    onClicked: folderDialog.open()
                }

                MaterialIconButton {
                    type: MaterialIconButton.Tonal
                    sizeStyle: MaterialIconButton.Small
                    widthStyle: MaterialIconButton.Wide
                    iconText: "\uf03e"
                    color: Theme.surfaceContainerHighest
                    iconColor: Theme.onSurfaceVariantColor
                    onClicked: fileDialog.open()
                }

                MaterialIconButton {
                    type: MaterialIconButton.Tonal
                    sizeStyle: MaterialIconButton.Small
                    widthStyle: MaterialIconButton.Wide
                    iconText: "\uf2ea"
                    color: Theme.surfaceContainerHighest
                    iconColor: Theme.error
                    onClicked: WallpaperConfig.resetFolder()
                }
            }
        }
    }

    SettingsGroup {
        SettingsGroup.Entry {
            title: "Appearance"
            description: "Switch between dark and light mode"

            SettingsChoice {
                labels: ["Dark", "Light"]
                currentIndex: Theme.isDark ? 0 : 1
                onPicked: index => Theme.setMode(index === 0 ? "dark" : "light")
            }
        }

        SettingsGroup.Entry {
            title: "Color scheme"
            description: "How colors are generated from the wallpaper"

            Column {
                id: schemeCol

                readonly property real avail: parent?.limit ?? 360
                readonly property int per: avail >= 360 ? 4 : 2
                readonly property var rows: {
                    const out = [];
                    for (let i = 0; i < page.schemeLabels.length; i += per)
                        out.push({
                            start: i,
                            labels: page.schemeLabels.slice(i, i + per)
                        });
                    return out;
                }

                spacing: 6

                Repeater {
                    model: schemeCol.rows

                    SettingsChoice {
                        id: choice
                        required property var modelData

                        labels: modelData.labels
                        currentIndex: page.schemeIndex - modelData.start
                        onPicked: index => Theme.setScheme(Theme.schemes[choice.modelData.start + index])
                    }
                }
            }
        }
    }
}
