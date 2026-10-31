pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Shapes
import Ryu.Extraa
import qs.services.theme

Rectangle {
    id: card

    property int order: 0
    property string label: ""
    property string center: ""
    property string detail: ""
    property real value: 0
    property color tone: Theme.primary
    property real shown: value
    property real reveal: 1
    property int lead: 0
    property int startSide: 0

    readonly property bool hovered: hoverHandler.hovered
    property bool armed: false
    property int side: 0
    property real trace: armed ? 1 : 0

    readonly property real enter: Math.max(0, Math.min(1, reveal * 1.8 - order * 0.22))
    readonly property real lineWidth: 2
    readonly property real inset: lineWidth / 2
    readonly property real arcRadius: Math.max(0, radius - inset)
    readonly property real perimeter: 2 * (width - 2 * inset - 2 * arcRadius) + 2 * (height - 2 * inset - 2 * arcRadius) + 2 * Math.PI * arcRadius

    readonly property string outline: {
        const l = inset;
        const t = inset;
        const rt = width - inset;
        const b = height - inset;
        const r = arcRadius;
        const m = height / 2;
        const a = " " + r + " " + r + " 0 0 0 ";
        if (side === 0)
            return "M " + l + " " + m + " L " + l + " " + (b - r) + " A" + a + (l + r) + " " + b + " L " + (rt - r) + " " + b + " A" + a + rt + " " + (b - r) + " L " + rt + " " + (t + r) + " A" + a + (rt - r) + " " + t + " L " + (l + r) + " " + t + " A" + a + l + " " + (t + r) + " L " + l + " " + m;
        return "M " + rt + " " + m + " L " + rt + " " + (t + r) + " A" + a + (rt - r) + " " + t + " L " + (l + r) + " " + t + " A" + a + l + " " + (t + r) + " L " + l + " " + (b - r) + " A" + a + (l + r) + " " + b + " L " + (rt - r) + " " + b + " A" + a + rt + " " + (b - r) + " L " + rt + " " + m;
    }

    function apply() {
        if (hovered) {
            if (!armed)
                side = startSide;
            if (lead > 0) {
                delay.interval = lead;
                delay.restart();
                return;
            }
        }
        delay.stop();
        armed = hovered;
    }

    width: 142
    height: 178
    radius: 20
    color: "transparent"
    border.width: 1
    border.color: Theme.outlineVariant
    opacity: enter
    scale: 0.9 + 0.1 * enter

    transform: Translate {
        y: (1 - card.enter) * 14
    }

    onHoveredChanged: Qt.callLater(card.apply)

    Behavior on shown {
        NumberAnimation {
            duration: 450
            easing.type: Easing.OutCubic
        }
    }

    Behavior on trace {
        NumberAnimation {
            duration: 650
            easing.type: Easing.OutCubic
        }
    }

    Timer {
        id: delay
        onTriggered: card.armed = card.hovered
    }

    HoverHandler {
        id: hoverHandler
    }

    Shape {
        anchors.fill: parent
        visible: card.trace > 0.001
        layer.enabled: true
        layer.samples: 4

        ShapePath {
            fillColor: "transparent"
            strokeColor: card.tone
            strokeWidth: card.lineWidth
            capStyle: ShapePath.FlatCap
            joinStyle: ShapePath.RoundJoin
            strokeStyle: ShapePath.DashLine
            dashOffset: 0
            dashPattern: [card.trace * card.perimeter / card.lineWidth, card.perimeter / card.lineWidth + 2]

            PathSvg {
                path: card.outline
            }
        }
    }

    Text {
        anchors.top: parent.top
        anchors.topMargin: 14
        anchors.horizontalCenter: parent.horizontalCenter
        text: card.label
        font.pixelSize: 12
        font.weight: Font.DemiBold
        font.letterSpacing: 1.2
        color: Theme.onSurfaceVariantColor
    }

    Item {
        id: box
        anchors.top: parent.top
        anchors.topMargin: 40
        anchors.horizontalCenter: parent.horizontalCenter
        width: 92
        height: 92

        WavyProgress {
            anchors.fill: parent
            style: WavyProgress.Circular
            indeterminate: false
            progress: Math.max(0, Math.min(1, card.shown))
            color: card.tone
            trackColor: Qt.alpha(card.tone, 0.18)
            strokeWidth: 5
            amplitude: 1.5
            wavelength: 22
            waveSpeed: 0.5
            gap: 10
        }

        Text {
            anchors.centerIn: parent
            text: card.center
            font.pixelSize: 20
            font.bold: true
            color: Theme.onBackgroundColor
        }
    }

    Text {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 14
        anchors.horizontalCenter: parent.horizontalCenter
        visible: card.detail.trim() !== ""
        text: card.detail
        font.pixelSize: 11
        font.weight: Font.Medium
        color: Theme.onSurfaceVariantColor
    }
}
