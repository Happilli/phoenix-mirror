pragma ComponentBehavior: Bound
import QtQuick
import qs.configuration.Hypr
import qs.Settings.components

SettingsPage {
    id: page
    title: "Hyprland"

    HyprSection {
        title: "Layout and spacing"
        description: "How windows are arranged and spaced"
        keys: ["layout", "gaps_in", "gaps_out", "border_size"]

        SettingsGroup.Entry {
            key: "hypr.layout"
            title: "Layout"
            description: "How tiled windows are arranged"

            SettingsChoice {
                labels: HyprConfig.layoutLabels
                currentIndex: Math.max(0, HyprConfig.layouts.indexOf(HyprConfig.get("layout")))
                onPicked: index => HyprConfig.set("layout", HyprConfig.layouts[index])
            }
        }

        Repeater {
            model: [
                {
                    key: "gaps_in",
                    title: "Inner gaps",
                    description: "Space between windows",
                    from: 0,
                    to: 30,
                    step: 1,
                    stops: false
                },
                {
                    key: "gaps_out",
                    title: "Outer gaps",
                    description: "Space between windows and the screen edge",
                    from: 0,
                    to: 60,
                    step: 1,
                    stops: false
                },
                {
                    key: "border_size",
                    title: "Border size",
                    description: "Thickness of the active window border",
                    from: 0,
                    to: 6,
                    step: 1,
                    stops: true
                }
            ]

            SettingsGroup.Entry {
                id: spacing
                required property var modelData

                key: "hypr." + modelData.key
                title: modelData.title
                description: modelData.description

                SettingsValueSlider {
                    from: spacing.modelData.from
                    to: spacing.modelData.to
                    stepSize: spacing.modelData.step
                    showStops: spacing.modelData.stops
                    value: HyprConfig.get(spacing.modelData.key) ?? spacing.modelData.from
                    onMoved: HyprConfig.set(spacing.modelData.key, value)
                }
            }
        }
    }

    HyprSection {
        title: "Window appearance"
        description: "Corners, transparency and shadows"
        keys: ["rounding", "active_opacity", "inactive_opacity", "dim_inactive", "shadow_enabled"]

        Repeater {
            model: [
                {
                    key: "rounding",
                    title: "Corner radius",
                    description: "Rounding of window corners",
                    from: 0,
                    to: 30,
                    step: 1,
                    scale: 1,
                    suffix: ""
                },
                {
                    key: "active_opacity",
                    title: "Active opacity",
                    description: "Opacity of the focused window",
                    from: 0.3,
                    to: 1,
                    step: 0.01,
                    scale: 100,
                    suffix: "%"
                },
                {
                    key: "inactive_opacity",
                    title: "Inactive opacity",
                    description: "Opacity of unfocused windows",
                    from: 0.3,
                    to: 1,
                    step: 0.01,
                    scale: 100,
                    suffix: "%"
                }
            ]

            SettingsGroup.Entry {
                id: look
                required property var modelData

                key: "hypr." + modelData.key
                title: modelData.title
                description: modelData.description

                SettingsValueSlider {
                    from: look.modelData.from
                    to: look.modelData.to
                    stepSize: look.modelData.step
                    showStops: false
                    displayScale: look.modelData.scale
                    suffix: look.modelData.suffix
                    value: HyprConfig.get(look.modelData.key) ?? look.modelData.from
                    onMoved: HyprConfig.set(look.modelData.key, Number(value.toFixed(2)))
                }
            }
        }

        SettingsGroup.Entry {
            key: "hypr.dim_inactive"
            title: "Dim inactive"
            description: "Darken windows that are not focused"

            SettingsSwitch {
                checked: !!HyprConfig.get("dim_inactive")
                onToggled: HyprConfig.set("dim_inactive", checked)
            }
        }

        SettingsGroup.Entry {
            key: "hypr.shadow"
            title: "Window shadows"
            description: "Draw a shadow behind windows"

            SettingsSwitch {
                checked: !!HyprConfig.get("shadow_enabled")
                onToggled: HyprConfig.set("shadow_enabled", checked)
            }
        }
    }

    HyprSection {
        title: "Blur"
        description: "Blur behind transparent windows"
        keys: ["blur_enabled", "blur_size", "blur_passes"]

        SettingsGroup.Entry {
            key: "hypr.blur"
            title: "Blur"
            description: "Blur the area behind transparent windows"

            SettingsSwitch {
                checked: !!HyprConfig.get("blur_enabled")
                onToggled: HyprConfig.set("blur_enabled", checked)
            }
        }

        Repeater {
            model: [
                {
                    key: "blur_size",
                    title: "Blur size",
                    description: "How far the blur spreads",
                    from: 1,
                    to: 20,
                    step: 1
                },
                {
                    key: "blur_passes",
                    title: "Blur passes",
                    description: "More passes look smoother but cost more GPU",
                    from: 1,
                    to: 6,
                    step: 1
                }
            ]

            SettingsGroup.Entry {
                id: blur
                required property var modelData

                key: "hypr." + modelData.key
                visible: !!HyprConfig.get("blur_enabled")
                title: modelData.title
                description: modelData.description

                SettingsValueSlider {
                    from: blur.modelData.from
                    to: blur.modelData.to
                    stepSize: blur.modelData.step
                    showStops: true
                    value: HyprConfig.get(blur.modelData.key) ?? blur.modelData.from
                    onMoved: HyprConfig.set(blur.modelData.key, value)
                }
            }
        }
    }

    HyprSection {
        title: "Animations"
        description: "Window and workspace motion"
        keys: ["animations_enabled"]

        SettingsGroup.Entry {
            key: "hypr.animations"
            title: "Animations"
            description: "Master switch for window and workspace animations"

            SettingsSwitch {
                checked: !!HyprConfig.get("animations_enabled")
                onToggled: HyprConfig.set("animations_enabled", checked)
            }
        }
    }
}
