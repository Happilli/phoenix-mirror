pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Dialogs
import Ryu.Extraa
import qs.services.theme
import qs.configuration.Wallpaper
import qs.configuration.Bar
import qs.components.Wallpaper
import qs.Settings.components

SettingsPage {
    id: page
    title: "General"

    readonly property var schemeLabels: Theme.schemes.map(s => s.replace("scheme-", "").replace(/-/g, " "))
    readonly property int schemeIndex: Theme.schemes.indexOf(Theme.scheme)

    readonly property real contentWidth: width - margin * 2
    readonly property bool wide: contentWidth >= 820
    readonly property real gutter: 14
    readonly property real carouselWidth: wide ? Math.min(720, contentWidth * 0.6) : contentWidth
    readonly property real stackedCarouselHeight: Math.max(150, Math.min(240, height * 0.28))
    readonly property real quickWidth: wide ? contentWidth - carouselWidth - gutter : contentWidth

    function toPath(url) {
        return decodeURIComponent(String(url).replace(/^file:\/\//, ""));
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

    header: Item {
        id: hdr

        width: parent.width
        height: page.wide ? quick.height : carousel.height + page.gutter + quick.height

        WallpaperCarousel {
            id: carousel
            x: page.wide ? hdr.width - width : 0
            y: 0
            width: page.carouselWidth
            height: page.wide ? quick.height : page.stackedCarouselHeight
        }

        SettingsGroup {
            id: quick
            x: 0
            y: page.wide ? 0 : carousel.height + page.gutter
            width: page.quickWidth

            SettingsGroup.Entry {
                key: "wall.appearance"
                title: "Appearance"
                description: "Switch between dark and light mode"

                SettingsChoice {
                    labels: ["Dark", "Light"]
                    currentIndex: Theme.isDark ? 0 : 1
                    onPicked: index => Theme.setMode(index === 0 ? "dark" : "light")
                }
            }

            SettingsGroup.Entry {
                key: "wall.scheme"
                title: "Color scheme"
                description: "How colors are generated from the wallpaper"

                Column {
                    id: schemeCol

                    readonly property real avail: parent?.limit ?? 360
                    readonly property int per: avail >= 400 ? 4 : 2
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

            SettingsGroup.Entry {
                key: "wall.folder"
                title: "Folder"
                description: "Where wallpapers are loaded from. Press Enter to apply"

                Row {
                    id: folderRow

                    readonly property real avail: parent?.limit ?? 360

                    spacing: 8

                    Item {
                        width: Math.max(140, Math.min(360, folderRow.avail - 180))
                        height: 40

                        Connections {
                            target: WallpaperConfig

                            function onFolderChanged() {
                                pathInput.text = WallpaperConfig.folder;
                            }
                        }

                        TextInput {
                            id: pathInput
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 8
                            leftPadding: 1
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
                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            height: pathInput.activeFocus ? 2 : 1
                            color: pathInput.activeFocus ? Theme.primary : Theme.outlineVariant

                            Behavior on color {
                                ColorAnimation {
                                    duration: 150
                                }
                            }
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
    }

    SettingsGroup {
        SettingsGroup.Entry {
            key: "bar.edge"
            title: "Bar position"
            description: "Screen edge the bar docks to"

            SettingsChoice {
                labels: BarConfig.labels
                currentIndex: BarConfig.edgeIndex
                onPicked: index => BarConfig.setEdge(BarConfig.edges[index])
            }
        }

        SettingsGroup.Entry {
            key: "bar.thickness"
            title: "Bar thickness"
            description: "Size of the bar across the screen edge"

            SettingsSlider {
                from: 56
                to: 140
                value: BarConfig.thickness
                onMoved: BarConfig.setThickness(value)
            }
        }

        SettingsGroup.Entry {
            key: "bar.radius"
            title: "Bar corner radius"
            description: "Rounding of the bar edges"

            SettingsSlider {
                from: 0
                to: 30
                value: BarConfig.radius
                onMoved: BarConfig.setRadius(value)
            }
        }
    }
}
