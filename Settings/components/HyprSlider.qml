import QtQuick
import qs.configuration.Hypr

SettingsGroup.Entry {
    id: row

    property string prop: ""
    property real from: 0
    property real to: 1
    property real step: 1
    property bool stops: false
    property real displayScale: 1
    property string suffix: ""

    key: "hypr." + prop

    SettingsValueSlider {
        from: row.from
        to: row.to
        stepSize: row.step
        showStops: row.stops
        displayScale: row.displayScale
        suffix: row.suffix
        value: HyprConfig.get(row.prop) ?? row.from
        onMoved: HyprConfig.set(row.prop, Number(value.toFixed(2)))
    }
}
