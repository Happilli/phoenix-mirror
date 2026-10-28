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

                SettingsSegmented {
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
                    readonly property int perRow: avail >= 380 ? 4 : 2
                    readonly property int rows: Math.ceil(page.schemeLabels.length / perRow)
                    readonly property real gap: 2
                    readonly property real minPad: 8
                    readonly property int labelWeight: 400

                    FontMetrics {
                        id: fm
                        font.pixelSize: 14
                        font.weight: schemeCol.labelWeight
                    }

                    function textWidth(s) {
                        return fm.advanceWidth(s);
                    }

                    function rowText(r) {
                        const labels = page.schemeLabels.slice(r * perRow, r * perRow + perRow);
                        let t = 0;
                        for (const l of labels)
                            t += textWidth(l);
                        return t;
                    }

                    readonly property real target: {
                        let w = 0;
                        for (let r = 0; r < rows; ++r) {
                            const n = Math.min(perRow, page.schemeLabels.length - r * perRow);
                            w = Math.max(w, rowText(r) + n * 2 * minPad + gap * (n - 1));
                        }
                        return w;
                    }

                    spacing: 6
                    Repeater {
                        model: schemeCol.rows

                        SettingsButtonGroup {
                            id: grp
                            required property int index

                            readonly property int start: index * schemeCol.perRow
                            readonly property var rowLabels: page.schemeLabels.slice(start, start + schemeCol.perRow)
                            readonly property int n: rowLabels.length

                            labels: rowLabels
                            fontWeight: schemeCol.labelWeight
                            currentIndex: page.schemeIndex - start
                            horizontalPadding: Math.max(schemeCol.minPad, (schemeCol.target - schemeCol.rowText(index) - schemeCol.gap * (n - 1)) / (2 * n))
                            onPicked: i => Theme.setScheme(Theme.schemes[grp.start + i])
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
            key: "bar.style"
            title: "Bar style"
            description: "Horizon melts into the screen edge, Floating hovers free of it"

            Row {
                spacing: 8

                Repeater {
                    model: BarConfig.styleLabels

                    SettingsRadio {
                        id: styleOption
                        required property string modelData
                        required property int index

                        group: "barStyle"
                        text: modelData
                        checked: BarConfig.styleIndex === index
                        onToggled: BarConfig.setStyle(BarConfig.styles[styleOption.index])
                    }
                }
            }
        }

        SettingsGroup.Entry {
            key: "bar.edge"
            title: "Bar position"
            description: "Screen edge the bar docks to"

            SettingsSegmented {
                labels: BarConfig.labels
                currentIndex: BarConfig.edgeIndex
                onPicked: index => BarConfig.setEdge(BarConfig.edges[index])
            }
        }

        Repeater {
            model: [
                {
                    side: "left",
                    title: "Margin left"
                },
                {
                    side: "right",
                    title: "Margin right"
                },
                {
                    side: "top",
                    title: "Margin top"
                },
                {
                    side: "bottom",
                    title: "Margin bottom"
                }
            ]

            SettingsGroup.Entry {
                id: margin
                required property var modelData

                key: "bar.margin." + modelData.side
                visible: BarConfig.floating && BarConfig.opposite !== modelData.side
                title: modelData.title
                description: "Gap between the floating bar and the " + modelData.side + " screen edge"

                SettingsValueSlider {
                    from: 0
                    to: 120
                    value: BarConfig.marginOf(margin.modelData.side)
                    onMoved: BarConfig.setMargin(margin.modelData.side, value)
                }
            }
        }

        SettingsGroup.Entry {
            key: "bar.thickness"
            title: "Bar thickness"
            description: "Size of the bar across the screen edge"

            SettingsValueSlider {
                from: BarConfig.minThickness
                to: BarConfig.maxThickness
                value: BarConfig.thickness
                onMoved: BarConfig.setThickness(value)
            }
        }

        SettingsGroup.Entry {
            key: "bar.radius"
            title: "Bar corner radius"
            description: "Rounding of the bar edges. Floating can go full pill"

            SettingsValueSlider {
                from: 0
                to: BarConfig.maxRadius
                value: BarConfig.radius
                onMoved: BarConfig.setRadius(value)
            }
        }
    }
}
