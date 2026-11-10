pragma ComponentBehavior: Bound
import QtQuick
import Ryu.Extraa
import px.services.theme
import px.configuration.Widgets
import px.Settings.components

SettingsPage {
    id: page
    title: "Widgets"

    readonly property real contentWidth: width - margin * 2
    readonly property bool wide: contentWidth >= 820
    readonly property real gutter: 14
    readonly property real edgeGap: 8
    readonly property real previewWidth: wide ? Math.min(780, contentWidth * 0.64) - edgeGap : Math.min(contentWidth, 780) - edgeGap * 2
    readonly property real quickWidth: wide ? contentWidth - previewWidth - edgeGap - gutter : contentWidth

    header: Item {
        id: hdr

        width: parent.width
        height: page.wide ? Math.max(pv.height + page.edgeGap, quick.height) : page.edgeGap + pv.height + page.gutter + quick.height

        DesktopPreview {
            id: pv
            x: page.wide ? hdr.width - width - page.edgeGap : (hdr.width - width) / 2
            y: page.edgeGap
            width: page.previewWidth
        }

        SettingsGroup {
            id: quick
            x: 0
            y: page.wide ? 0 : page.edgeGap + pv.height + page.gutter
            width: page.quickWidth

            SettingsGroup.Entry {
                id: showEntry
                key: "clock.show"
                title: "Show clock"
                description: "Display the clock on your desktop wallpaper"

                SettingsSwitch {
                    checked: ClockConfig.enabled
                    onToggled: ClockConfig.set("enabled", checked)
                }
            }

            SettingsGroup.Entry {
                id: colorEntry
                key: "clock.color"
                title: "Color"
                description: "Tint of the clock digits"
                Grid {
                    id: colorGrid

                    readonly property real avail: Math.max(200, Math.min(parent?.limit ?? 360, 360))
                    readonly property real cellW: (avail - spacing) / 2

                    columns: 2
                    spacing: 8

                    Repeater {
                        model: ClockConfig.colorOptions

                        SettingsChip {
                            id: tone
                            required property var modelData
                            required property int index

                            width: colorGrid.cellW
                            type: MaterialChip.Filter
                            label: modelData.label
                            selected: ClockConfig.colorKey === modelData.key
                            onToggled: ClockConfig.set("colorKey", tone.modelData.key)
                        }
                    }
                }
            }

            SettingsGroup.Entry {
                id: sizeEntry
                key: "clock.size"
                title: "Size"
                description: "Overall size of the clock"

                SettingsValueSlider {
                    from: 120
                    to: 600
                    value: ClockConfig.size
                    onMoved: ClockConfig.set("size", Math.round(value))
                }
            }

            SettingsGroup.Entry {
                id: randomEntry
                key: "clock.random"
                title: "Randomize position"
                description: "Pick a spot based on the current wallpaper"

                SettingsCheckbox {
                    checked: ClockConfig.randomizePosition
                    onToggled: ClockConfig.set("randomizePosition", checked)
                }
            }

            SettingsGroup.Entry {
                id: alignEntry
                key: "clock.alignment"
                minHeight: page.wide ? pv.height - showEntry.height - colorEntry.height - sizeEntry.height - randomEntry.height : 0
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
        }
    }

    SettingsGroup {
        SettingsGroup.Entry {
            key: "clock.orientation"
            title: "Orientation"
            description: "Stack the digits or place them side by side"

            SettingsSegmented {
                labels: ["Vertical", "Horizontal"]
                currentIndex: ClockConfig.orientation
                onPicked: index => ClockConfig.set("orientation", index)
            }
        }

        SettingsGroup.Entry {
            key: "clock.separator"
            visible: ClockConfig.orientation === 1
            title: "Separator"
            description: "Show the colon between hours and minutes"

            SettingsCheckbox {
                checked: ClockConfig.showSeparator
                onToggled: ClockConfig.set("showSeparator", checked)
            }
        }

        SettingsGroup.Entry {
            key: "clock.weight"
            title: "Font weight"
            description: "Thickness of the digits"

            SettingsValueSlider {
                from: 100
                to: 900
                value: ClockConfig.fontWeight
                onMoved: ClockConfig.set("fontWeight", Math.round(value))
            }
        }

        SettingsGroup.Entry {
            key: "clock.24h"
            title: "24-hour time"
            description: "Turn off to use 12-hour time"

            SettingsCheckbox {
                checked: ClockConfig.use24Hour
                onToggled: ClockConfig.set("use24Hour", checked)
            }
        }

        SettingsGroup.Entry {
            key: "clock.ampm"
            visible: !ClockConfig.use24Hour
            title: "Show AM/PM"
            description: "Display the period next to the time"

            SettingsCheckbox {
                checked: ClockConfig.showAmPm
                onToggled: ClockConfig.set("showAmPm", checked)
            }
        }

        SettingsGroup.Entry {
            key: "clock.ampmPos"
            visible: !ClockConfig.use24Hour && ClockConfig.showAmPm
            title: "AM/PM position"
            description: "Where the period sits relative to the digits"

            Row {
                spacing: 4

                Repeater {
                    model: ["Beside", "Below", "Superscript"]

                    SettingsRadio {
                        id: periodOption
                        required property string modelData
                        required property int index

                        group: "amPmStyle"
                        text: modelData
                        checked: ClockConfig.amPmStyle === index
                        onToggled: ClockConfig.set("amPmStyle", periodOption.index)
                    }
                }
            }
        }
    }

    SettingsGroup {
        SettingsGroup.Entry {
            key: "clock.margin"
            title: "Margin"
            description: "Distance from the screen edges"

            SettingsValueSlider {
                from: 0
                to: 200
                value: ClockConfig.margin
                onMoved: ClockConfig.set("margin", Math.round(value))
            }
        }

        Repeater {
            model: [
                {
                    key: "padding",
                    title: "Padding",
                    description: "Inner margin around the clock",
                    from: 0,
                    to: 50,
                    horizontal: false
                },
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
                    key: "letterSpacing",
                    title: "Letter spacing",
                    description: "Tracking between characters",
                    from: -0.2,
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
                }
            ]

            SettingsGroup.Entry {
                id: tune
                required property var modelData

                key: "clock." + modelData.key
                visible: !modelData.horizontal || ClockConfig.orientation === 1
                title: modelData.title
                description: modelData.description

                SettingsValueSlider {
                    from: tune.modelData.from
                    to: tune.modelData.to
                    value: ClockConfig.get(tune.modelData.key)
                    onMoved: ClockConfig.set(tune.modelData.key, Math.round(value * 1000) / 1000)
                }
            }
        }

        SettingsGroup.Entry {
            key: "clock.reset"
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
