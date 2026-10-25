import QtQuick
import Ryu.Extraa
import qs.services.theme

MaterialSlider {
    // qmllint disable missing-property
    readonly property real avail: parent?.limit ?? 300
    // qmllint enable missing-property

    width: Math.max(140, Math.min(300, avail))
    sizeStyle: MaterialSlider.Small
    outerRadius: 8
    handleGap: 3
    innerRadius: 2
    showStops: false
    showValueIndicator: false
    trackColor: Theme.surfaceContainerHighest
    color: Theme.primary
    handleColor: Theme.primary
}
