import QtQuick
import Ryu.Widgets
import px.configuration.Widgets

Loader {
    active: ClockConfig.enabled
    width: ClockConfig.size
    height: ClockConfig.orientation === 0 ? ClockConfig.size * 1.1 : ClockConfig.size * 0.45
    x: ClockConfig.place(ClockConfig.hPos, parent.width, width, ClockConfig.margin)
    y: ClockConfig.place(ClockConfig.vPos, parent.height, height, ClockConfig.margin)

    sourceComponent: DigitalClock {
        orientation: ClockConfig.orientation
        use24Hour: ClockConfig.use24Hour
        showAmPm: ClockConfig.showAmPm
        amPmStyle: ClockConfig.amPmStyle
        showSeparator: ClockConfig.showSeparator
        fontWeight: ClockConfig.fontWeight
        gap: ClockConfig.gap
        overlap: ClockConfig.overlap
        groupGap: ClockConfig.groupGap
        letterSpacing: ClockConfig.letterSpacing
        padding: ClockConfig.padding
        color: ClockConfig.tint
    }
}
