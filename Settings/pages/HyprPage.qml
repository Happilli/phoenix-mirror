pragma ComponentBehavior: Bound
import QtQuick
import qs.configuration.Hypr
import qs.Settings.components

SettingsPage {
    id: page
    title: "Hyprland"

    HyprSection {
        title: "layout and spacing"
        description: "How windows are arranged and spaced"
        keys: ["layout", "gaps_in", "gaps_out", "border_size"]

        SettingsGroup.Entry {
            key: "hypr.layout"
            title: "Layout"
            description: "How tiled windows are arranged"

            SettingsSegmented {
                labels: HyprConfig.layoutLabels
                currentIndex: Math.max(0, HyprConfig.layouts.indexOf(HyprConfig.get("layout")))
                onPicked: index => HyprConfig.set("layout", HyprConfig.layouts[index])
            }
        }

        SettingsGroup.Entry {
            key: "hypr.gaps_in"
            title: "Inner gaps"
            description: "Space between windows"

            SettingsValueSlider {
                from: 0
                to: 30
                stepSize: 1
                value: HyprConfig.get("gaps_in") ?? 0
                onMoved: HyprConfig.set("gaps_in", value)
            }
        }

        SettingsGroup.Entry {
            key: "hypr.gaps_out"
            title: "Outer gaps"
            description: "Space between windows and the screen edge"

            SettingsValueSlider {
                from: 0
                to: 60
                stepSize: 1
                value: HyprConfig.get("gaps_out") ?? 0
                onMoved: HyprConfig.set("gaps_out", value)
            }
        }

        SettingsGroup.Entry {
            key: "hypr.border_size"
            title: "Border size"
            description: "Thickness of the active window border"

            SettingsValueSlider {
                from: 0
                to: 6
                stepSize: 1
                showStops: true
                value: HyprConfig.get("border_size") ?? 0
                onMoved: HyprConfig.set("border_size", value)
            }
        }
    }

    HyprSection {
        title: "window appearance"
        description: "Corners, transparency and shadows"
        keys: ["rounding", "active_opacity", "inactive_opacity", "dim_inactive", "shadow_enabled"]

        SettingsGroup.Entry {
            key: "hypr.rounding"
            title: "Corner radius"
            description: "Rounding of window corners"

            SettingsValueSlider {
                from: 0
                to: 30
                stepSize: 1
                value: HyprConfig.get("rounding") ?? 0
                onMoved: HyprConfig.set("rounding", value)
            }
        }

        SettingsGroup.Entry {
            key: "hypr.active_opacity"
            title: "Active opacity"
            description: "Opacity of the focused window"

            SettingsValueSlider {
                from: 0.3
                to: 1
                stepSize: 0.01
                displayScale: 100
                suffix: "%"
                value: HyprConfig.get("active_opacity") ?? 1
                onMoved: HyprConfig.set("active_opacity", Number(value.toFixed(2)))
            }
        }

        SettingsGroup.Entry {
            key: "hypr.inactive_opacity"
            title: "Inactive opacity"
            description: "Opacity of unfocused windows"

            SettingsValueSlider {
                from: 0.3
                to: 1
                stepSize: 0.01
                displayScale: 100
                suffix: "%"
                value: HyprConfig.get("inactive_opacity") ?? 1
                onMoved: HyprConfig.set("inactive_opacity", Number(value.toFixed(2)))
            }
        }

        HyprSwitch {
            key: "hypr.dim_inactive"
            prop: "dim_inactive"
            title: "Dim inactive"
            description: "Darken windows that are not focused"
        }

        HyprSwitch {
            key: "hypr.shadow"
            prop: "shadow_enabled"
            title: "Window shadows"
            description: "Draw a shadow behind windows"
        }
    }

    HyprSection {
        title: "blur"
        description: "Blur behind transparent windows"
        keys: ["blur_enabled", "blur_size", "blur_passes"]

        HyprSwitch {
            key: "hypr.blur"
            prop: "blur_enabled"
            title: "Blur"
            description: "Blur the area behind transparent windows"
        }

        SettingsGroup.Entry {
            key: "hypr.blur_size"
            visible: !!HyprConfig.get("blur_enabled")
            title: "Blur size"
            description: "How far the blur spreads"

            SettingsValueSlider {
                from: 1
                to: 20
                stepSize: 1
                value: HyprConfig.get("blur_size") ?? 1
                onMoved: HyprConfig.set("blur_size", value)
            }
        }

        SettingsGroup.Entry {
            key: "hypr.blur_passes"
            visible: !!HyprConfig.get("blur_enabled")
            title: "Blur passes"
            description: "More passes look smoother but cost more GPU"

            SettingsValueSlider {
                from: 1
                to: 6
                stepSize: 1
                showStops: true
                value: HyprConfig.get("blur_passes") ?? 1
                onMoved: HyprConfig.set("blur_passes", value)
            }
        }
    }

    HyprSection {
        title: "animations"
        description: "Window and workspace motion"
        keys: ["animations_enabled"]

        HyprSwitch {
            key: "hypr.animations"
            prop: "animations_enabled"
            title: "Animations"
            description: "Master switch for window and workspace animations"
        }
    }
}
