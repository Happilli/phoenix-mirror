pragma ComponentBehavior: Bound
import QtQuick
import Ryu.Extraa
import qs.services.theme
import qs.configuration.Widgets
import qs.Settings.components

SettingsPage {
    header: SettingsSection {
        DesktopPreview {
            width: parent.width
        }
    }

    SettingsSection {
        SwitchRow {
            label: "Show on desktop"
            description: "Display the clock on your wallpaper"
            checked: ClockConfig.enabled
            onToggled: value => ClockConfig.set("enabled", value)
        }

        ChoiceRow {
            enabled: ClockConfig.enabled
            label: "Horizontal position"
            labels: ["Left", "Center", "Right"]
            currentIndex: ClockConfig.hAlign
            onPicked: index => ClockConfig.set("hAlign", index)
        }

        ChoiceRow {
            enabled: ClockConfig.enabled
            label: "Vertical position"
            labels: ["Top", "Center", "Bottom"]
            currentIndex: ClockConfig.vAlign
            onPicked: index => ClockConfig.set("vAlign", index)
        }

        SliderRow {
            enabled: ClockConfig.enabled
            label: "Size"
            from: 120
            to: 600
            step: 10
            decimals: 0
            unit: " px"
            value: ClockConfig.size
            onMoved: v => ClockConfig.set("size", Math.round(v))
        }

        SliderRow {
            enabled: ClockConfig.enabled
            label: "Edge margin"
            description: "Distance from the screen edge"
            from: 0
            to: 200
            step: 4
            decimals: 0
            unit: " px"
            value: ClockConfig.margin
            onMoved: v => ClockConfig.set("margin", Math.round(v))
        }
    }

    SettingsSection {
        ChoiceRow {
            label: "Orientation"
            description: "Stack hours over minutes, or place them side by side"
            labels: ["Vertical", "Horizontal"]
            currentIndex: ClockConfig.orientation
            onPicked: index => ClockConfig.set("orientation", index)
        }

        SwitchRow {
            label: "24-hour time"
            description: "Turn off to use a 12-hour clock"
            checked: ClockConfig.use24Hour
            onToggled: value => ClockConfig.set("use24Hour", value)
        }

        SwitchRow {
            enabled: !ClockConfig.use24Hour
            label: "Show AM / PM"
            description: "Only available in 12-hour mode"
            checked: ClockConfig.showAmPm
            onToggled: value => ClockConfig.set("showAmPm", value)
        }

        ChoiceRow {
            visible: !ClockConfig.use24Hour && ClockConfig.showAmPm
            label: "AM / PM position"
            labels: ["Beside", "Below", "Superscript"]
            currentIndex: ClockConfig.amPmStyle
            onPicked: index => ClockConfig.set("amPmStyle", index)
        }

        SwitchRow {
            enabled: ClockConfig.orientation === 1
            label: "Separator"
            description: "The colon between hours and minutes (horizontal only)"
            checked: ClockConfig.showSeparator
            onToggled: value => ClockConfig.set("showSeparator", value)
        }
    }

    SettingsSection {
        SliderRow {
            label: "Weight"
            from: 100
            to: 900
            step: 100
            decimals: 0
            value: ClockConfig.fontWeight
            onMoved: v => ClockConfig.set("fontWeight", Math.round(v))
        }

        SliderRow {
            label: "Digit cut"
            description: "Gap carved where digits overlap"
            from: 0
            to: 0.15
            value: ClockConfig.gap
            onMoved: v => ClockConfig.set("gap", v)
        }

        SliderRow {
            label: "Overlap"
            from: 0
            to: 0.15
            value: ClockConfig.overlap
            onMoved: v => ClockConfig.set("overlap", v)
        }

        SliderRow {
            enabled: ClockConfig.orientation === 1
            label: "Group gap"
            description: "Space between hours, separator and minutes"
            from: 0
            to: 0.4
            value: ClockConfig.groupGap
            onMoved: v => ClockConfig.set("groupGap", v)
        }

        SliderRow {
            label: "Letter spacing"
            from: -0.15
            to: 0.1
            value: ClockConfig.letterSpacing
            onMoved: v => ClockConfig.set("letterSpacing", v)
        }

        SliderRow {
            label: "Padding"
            from: 0
            to: 40
            step: 1
            decimals: 0
            unit: " px"
            value: ClockConfig.padding
            onMoved: v => ClockConfig.set("padding", v)
        }
    }

    SettingsSection {
        Flow {
            width: parent.width
            spacing: 8

            Repeater {
                model: ClockConfig.colorOptions

                Rectangle {
                    id: chip
                    required property var modelData

                    readonly property bool checked: ClockConfig.colorKey === modelData.key

                    width: chipRow.implicitWidth + 28
                    height: 36
                    radius: height / 2
                    color: checked ? Qt.alpha(Theme.primary, 0.2) : (chipArea.containsMouse ? Qt.alpha(Theme.primary, 0.1) : Theme.surfaceContainerHighest)
                    border.width: checked ? 2 : 0
                    border.color: Theme.primary

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }

                    Row {
                        id: chipRow
                        anchors.centerIn: parent
                        spacing: 8

                        Rectangle {
                            width: 14
                            height: 14
                            radius: 7
                            anchors.verticalCenter: parent.verticalCenter
                            color: ClockConfig.colorFor(chip.modelData.key)
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: chip.modelData.label
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            color: chip.checked ? Theme.primary : Theme.onSurfaceVariantColor
                        }
                    }

                    MouseArea {
                        id: chipArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: ClockConfig.set("colorKey", chip.modelData.key)
                    }
                }
            }
        }
    }

    SettingsSection {
        SettingsRow {
            label: "Reset clock"
            description: "Restore every clock setting to its default"

            MaterialIconButton {
                type: MaterialIconButton.Tonal
                sizeStyle: MaterialIconButton.Small
                widthStyle: MaterialIconButton.Wide
                iconText: "\uf0e2"
                color: Theme.surfaceContainerHighest
                iconColor: Theme.onSurfaceVariantColor
                onClicked: ClockConfig.reset()
            }
        }
    }
}
