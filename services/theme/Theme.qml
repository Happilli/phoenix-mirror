pragma Singleton

import QtQuick
import Ryu.Io
import px.configuration.Wallpaper
import px.services.paths
import px.services.state

QtObject {
    id: root

    property string mode: StateService.get("mode", "dark")
    property string scheme: StateService.get("scheme", "scheme-content")
    property string lastText: ""
    property bool queued: false
    readonly property bool isDark: mode === "dark"

    property var md3: ({})
    property var palette: ({})
    property var base16: ({})

    readonly property color background: md3.background ?? "transparent"
    readonly property color onBackgroundColor: md3.on_background ?? "transparent"
    readonly property color error: md3.error ?? "transparent"
    readonly property color onErrorColor: md3.on_error ?? "transparent"
    readonly property color primary: md3.primary ?? "transparent"
    readonly property color onPrimaryColor: md3.on_primary ?? "transparent"
    readonly property color surface: md3.surface ?? "transparent"
    readonly property color surfaceDim: md3.surface_dim ?? "transparent"
    readonly property color surfaceBright: md3.surface_bright ?? "transparent"
    readonly property color surfaceVariant: md3.surface_variant ?? "transparent"
    readonly property color surfaceTint: md3.surface_tint ?? "transparent"
    readonly property color surfaceContainerLowest: md3.surface_container_lowest ?? "transparent"
    readonly property color surfaceContainerLow: md3.surface_container_low ?? "transparent"
    readonly property color surfaceContainer: md3.surface_container ?? "transparent"
    readonly property color surfaceContainerHigh: md3.surface_container_high ?? "transparent"
    readonly property color surfaceContainerHighest: md3.surface_container_highest ?? "transparent"
    readonly property color onSurfaceColor: md3.on_surface ?? "transparent"
    readonly property color onSurfaceVariantColor: md3.on_surface_variant ?? "transparent"
    readonly property color outline: md3.outline ?? "transparent"
    readonly property color outlineVariant: md3.outline_variant ?? "transparent"
    readonly property color primaryContainer: md3.primary_container ?? "transparent"
    readonly property color onPrimaryContainerColor: md3.on_primary_container ?? "transparent"
    readonly property color inversePrimary: md3.inverse_primary ?? "transparent"
    readonly property color secondary: md3.secondary ?? "transparent"
    readonly property color onSecondaryColor: md3.on_secondary ?? "transparent"
    readonly property color secondaryContainer: md3.secondary_container ?? "transparent"
    readonly property color onSecondaryContainerColor: md3.on_secondary_container ?? "transparent"
    readonly property color tertiary: md3.tertiary ?? "transparent"
    readonly property color onTertiaryColor: md3.on_tertiary ?? "transparent"
    readonly property color tertiaryContainer: md3.tertiary_container ?? "transparent"
    readonly property color onTertiaryContainerColor: md3.on_tertiary_container ?? "transparent"
    readonly property color errorContainer: md3.error_container ?? "transparent"
    readonly property color onErrorContainerColor: md3.on_error_container ?? "transparent"
    readonly property color inverseSurface: md3.inverse_surface ?? "transparent"
    readonly property color inverseOnSurfaceColor: md3.inverse_on_surface ?? "transparent"
    readonly property color scrim: md3.scrim ?? "transparent"
    readonly property color shadow: md3.shadow ?? "transparent"

    readonly property var schemes: ["scheme-content", "scheme-expressive", "scheme-fidelity", "scheme-fruit-salad", "scheme-monochrome", "scheme-neutral", "scheme-rainbow", "scheme-tonal-spot"]

    function setScheme(s) {
        if (s === scheme)
            return;
        StateService.set("scheme", s);
        generate();
    }

    function setMode(newMode) {
        if (newMode !== "light" && newMode !== "dark")
            return;
        if (newMode === mode)
            return;
        StateService.set("mode", newMode);
        generate();
    }

    function toggleMode() {
        return setMode(isDark ? "light" : "dark");
    }

    function generate() {
        if (matugen.running) {
            root.queued = true;
            return;
        }
        const src = WallpaperConfig.currentWallpaper.toString().replace("file://", "");
        matugen.command = ["matugen", "--mode", root.mode, "--type", root.scheme, "--source-color-index", "0", "image", src];
        matugen.running = true;
    }

    property Process matugen: Process {
        onRunningChanged: {
            if (!running && root.queued) {
                root.queued = false;
                root.generate();
            }
        }
    }

    property Timer reloadTimer: Timer {
        interval: 50
        onTriggered: root.colorsFile.reload()
    }

    property FileView colorsFile: FileView {
        path: PathService.home + "/.local/state/ryu/colors.json"
        watchChanges: true

        onFileChanged: root.reloadTimer.restart()
        onLoadFailed: err => console.log("error loading file: ", err)

        onLoaded: {
            const raw = text();
            if (raw.trim() === "" || raw === root.lastText)
                return;
            let data;
            try {
                data = JSON.parse(raw);
            } catch (e) {
                console.log("parsing error: ", e);
                return;
            }
            root.lastText = raw;
            root.md3 = data.md3 ?? {};
            root.palette = data.palette ?? {};
            root.base16 = data.base16 ?? {};
        }
    }
}
