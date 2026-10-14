pragma ComponentBehavior: Bound
import QtQuick
import qs.services.theme
import qs.services.media

Item {
    id: root

    property bool running: false
    property int bars: 33
    property real barSpacing: 3

    function sample(pos) {
        const s = MediaService.spectrum;
        const lo = Math.floor(pos);
        const hi = Math.min(MediaService.bandCount - 1, lo + 1);
        const f = pos - lo;
        return (s[lo] ?? 0) * (1 - f) + (s[hi] ?? 0) * f;
    }

    VisualizerClient {
        enabled: root.running
    }

    Row {
        anchors.fill: parent
        spacing: root.barSpacing

        Repeater {
            model: root.bars

            Item {
                id: slot
                required property int index
                readonly property real d: Math.abs(index - (root.bars - 1) / 2) / ((root.bars - 1) / 2)
                readonly property real level: root.sample(d * (MediaService.bandCount - 1))

                width: (root.width - (root.bars - 1) * root.barSpacing) / root.bars
                height: root.height

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width
                    height: Math.max(3, slot.level * root.height)
                    radius: width / 2
                    color: Theme.primary
                    opacity: 0.35 + 0.65 * slot.level
                }
            }
        }
    }
}
