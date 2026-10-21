import QtQuick
import Quickshell
import Ryu.Extraa
import qs.services.theme
import qs.configuration.Widgets
import qs.Settings.components

SettingsPage {
    title: "Widgets"

    header: DesktopPreview {
        readonly property real screenWidth: Quickshell.screens[0]?.width ?? 1920
        readonly property bool large: parent.width / screenWidth > 0.6

        width: large ? 800 : parent.width
    }

    SettingsGroup {
        SettingsGroup.Entry {
            title: "Show clock"
            description: "Display the clock on your desktop wallpaper"

            MaterialSwitch {
                checked: ClockConfig.enabled
                trackColor: Theme.surfaceContainerHighest
                checkedTrackColor: Theme.primary
                handleColor: Theme.onSurfaceVariantColor
                checkedHandleColor: Theme.onPrimaryColor
                borderColor: Theme.outline
                onToggled: ClockConfig.set("enabled", checked)
            }
        }

        SettingsGroup.Entry {
            title: "Color"
            description: "Tint of the clock digits"

            MaterialButtonGroup {
                labels: ClockConfig.colorOptions.map(o => o.label)
                selectionMode: MaterialButtonGroup.Single
                variant: MaterialButtonGroup.Connected
                sizeStyle: MaterialButtonGroup.ExtraSmall
                currentIndex: ClockConfig.colorOptions.findIndex(o => o.key === ClockConfig.colorKey)
                color: Theme.surfaceContainerHighest
                checkedColor: Theme.primary
                textColor: Theme.onSurfaceVariantColor
                checkedTextColor: Theme.onPrimaryColor

                onToggled: (index, checked) => {
                    if (checked)
                        ClockConfig.set("colorKey", ClockConfig.colorOptions[index].key);
                }
            }
        }

        SettingsGroup.Entry {
            title: "Size"
            description: "Overall size of the clock"

            MaterialSlider {
                width: 300
                from: 120
                to: 600
                sizeStyle: MaterialSlider.Small
                outerRadius: 8
                handleGap: 3
                innerRadius: 2
                value: ClockConfig.size
                showStops: false
                showValueIndicator: false
                trackColor: Theme.surfaceContainerHighest
                color: Theme.primary
                handleColor: Theme.primary

                onMoved: ClockConfig.set("size", Math.round(value))
            }
        }
    }

    SettingsGroup {
        SettingsGroup.Entry {
            title: "Orientation"
            description: "Stack the digits or place them side by side"

            MaterialButtonGroup {
                labels: ["Vertical", "Horizontal"]
                selectionMode: MaterialButtonGroup.Single
                variant: MaterialButtonGroup.Connected
                sizeStyle: MaterialButtonGroup.ExtraSmall
                currentIndex: ClockConfig.orientation
                color: Theme.surfaceContainerHighest
                checkedColor: Theme.primary
                textColor: Theme.onSurfaceVariantColor
                checkedTextColor: Theme.onPrimaryColor

                onToggled: (index, checked) => {
                    if (checked)
                        ClockConfig.set("orientation", index);
                }
            }
        }

        SettingsGroup.Entry {
            title: "Font weight"
            description: "Thickness of the digits"

            MaterialSlider {
                width: 300
                from: 100
                to: 900
                sizeStyle: MaterialSlider.Small
                outerRadius: 8
                handleGap: 3
                innerRadius: 2
                value: ClockConfig.fontWeight
                showStops: false
                showValueIndicator: false
                trackColor: Theme.surfaceContainerHighest
                color: Theme.primary
                handleColor: Theme.primary

                onMoved: ClockConfig.set("fontWeight", Math.round(value))
            }
        }

        SettingsGroup.Entry {
            title: "24-hour time"
            description: "Turn off to use 12-hour time"

            MaterialSwitch {
                checked: ClockConfig.use24Hour
                trackColor: Theme.surfaceContainerHighest
                checkedTrackColor: Theme.primary
                handleColor: Theme.onSurfaceVariantColor
                checkedHandleColor: Theme.onPrimaryColor
                borderColor: Theme.outline
                onToggled: ClockConfig.set("use24Hour", checked)
            }
        }

        SettingsGroup.Entry {
            visible: !ClockConfig.use24Hour
            title: "Show AM/PM"
            description: "Display the period next to the time"

            MaterialSwitch {
                checked: ClockConfig.showAmPm
                trackColor: Theme.surfaceContainerHighest
                checkedTrackColor: Theme.primary
                handleColor: Theme.onSurfaceVariantColor
                checkedHandleColor: Theme.onPrimaryColor
                borderColor: Theme.outline
                onToggled: ClockConfig.set("showAmPm", checked)
            }
        }

        SettingsGroup.Entry {
            visible: !ClockConfig.use24Hour && ClockConfig.showAmPm
            title: "AM/PM position"
            description: "Where the period sits relative to the digits"

            MaterialButtonGroup {
                labels: ["Beside", "Below", "Superscript"]
                selectionMode: MaterialButtonGroup.Single
                variant: MaterialButtonGroup.Connected
                sizeStyle: MaterialButtonGroup.ExtraSmall
                currentIndex: ClockConfig.amPmStyle
                color: Theme.surfaceContainerHighest
                checkedColor: Theme.primary
                textColor: Theme.onSurfaceVariantColor
                checkedTextColor: Theme.onPrimaryColor

                onToggled: (index, checked) => {
                    if (checked)
                        ClockConfig.set("amPmStyle", index);
                }
            }
        }

        SettingsGroup.Entry {
            visible: ClockConfig.orientation === 1
            title: "Separator"
            description: "Show the colon between hours and minutes"

            MaterialSwitch {
                checked: ClockConfig.showSeparator
                trackColor: Theme.surfaceContainerHighest
                checkedTrackColor: Theme.primary
                handleColor: Theme.onSurfaceVariantColor
                checkedHandleColor: Theme.onPrimaryColor
                borderColor: Theme.outline
                onToggled: ClockConfig.set("showSeparator", checked)
            }
        }
    }

    SettingsGroup {
        SettingsGroup.Entry {
            title: "Randomize position"
            description: "Pick a spot based on the current wallpaper"

            MaterialSwitch {
                checked: ClockConfig.randomizePosition
                trackColor: Theme.surfaceContainerHighest
                checkedTrackColor: Theme.primary
                handleColor: Theme.onSurfaceVariantColor
                checkedHandleColor: Theme.onPrimaryColor
                borderColor: Theme.outline
                onToggled: ClockConfig.set("randomizePosition", checked)
            }
        }

        SettingsGroup.Entry {
            title: "Alignment"
            description: "Where the clock sits on the screen"

            Grid {
                columns: 3
                spacing: 6
                opacity: ClockConfig.randomizePosition ? 0.4 : 1

                Repeater {
                    model: 9

                    Rectangle {
                        id: cell
                        required property int index

                        readonly property int col: index % 3
                        readonly property int row: Math.floor(index / 3)
                        readonly property bool selected: ClockConfig.hAlign === col && ClockConfig.vAlign === row

                        width: 30
                        height: 30
                        radius: 8
                        border.width: 2
                        border.color: Theme.outlineVariant
                        color: selected ? Theme.primary : (area.containsMouse && !ClockConfig.randomizePosition ? Theme.surfaceBright : Theme.surfaceContainerHighest)

                        MouseArea {
                            id: area
                            anchors.fill: parent
                            enabled: !ClockConfig.randomizePosition
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                ClockConfig.set("hAlign", cell.col);
                                ClockConfig.set("vAlign", cell.row);
                            }
                        }
                    }
                }
            }
        }

        SettingsGroup.Entry {
            title: "Margin"
            description: "Distance from the screen edges"

            MaterialSlider {
                width: 300
                from: 0
                to: 200
                sizeStyle: MaterialSlider.Small
                outerRadius: 8
                handleGap: 3
                innerRadius: 2
                value: ClockConfig.margin
                showStops: false
                showValueIndicator: false
                trackColor: Theme.surfaceContainerHighest
                color: Theme.primary
                handleColor: Theme.primary

                onMoved: ClockConfig.set("margin", Math.round(value))
            }
        }
    }

    SettingsGroup {
        Repeater {
            model: [
                {
                    key: "gap",
                    title: "Digit gap",
                    description: "Space cut between touching digits",
                    from: 0,
                    to: 0.15,
                    horizontal: false
                },
                {
                    key: "overlap",
                    title: "Overlap",
                    description: "How much neighbouring digits overlap",
                    from: -0.1,
                    to: 0.2,
                    horizontal: false
                },
                {
                    key: "groupGap",
                    title: "Group gap",
                    description: "Space between hours, separator and minutes",
                    from: 0,
                    to: 0.4,
                    horizontal: true
                },
                {
                    key: "letterSpacing",
                    title: "Letter spacing",
                    description: "Tracking between characters",
                    from: -0.2,
                    to: 0.2,
                    horizontal: false
                },
                {
                    key: "padding",
                    title: "Padding",
                    description: "Inner margin around the clock",
                    from: 0,
                    to: 50,
                    horizontal: false
                }
            ]

            SettingsGroup.Entry {
                id: tune
                required property var modelData

                visible: !modelData.horizontal || ClockConfig.orientation === 1
                title: modelData.title
                description: modelData.description

                MaterialSlider {
                    width: 300
                    from: tune.modelData.from
                    to: tune.modelData.to
                    sizeStyle: MaterialSlider.Small
                    outerRadius: 8
                    handleGap: 3
                    innerRadius: 2
                    value: ClockConfig.get(tune.modelData.key)
                    showStops: false
                    showValueIndicator: false
                    trackColor: Theme.surfaceContainerHighest
                    color: Theme.primary
                    handleColor: Theme.primary

                    onMoved: ClockConfig.set(tune.modelData.key, Math.round(value * 1000) / 1000)
                }
            }
        }

        SettingsGroup.Entry {
            title: "Reset to defaults"
            description: "Restore every clock setting"

            MaterialIconButton {
                type: MaterialIconButton.Tonal
                sizeStyle: MaterialIconButton.Small
                widthStyle: MaterialIconButton.Wide
                iconText: "\uf2ea"
                color: Theme.surfaceContainerHighest
                iconColor: Theme.error
                onClicked: ClockConfig.reset()
            }
        }
    }
}
