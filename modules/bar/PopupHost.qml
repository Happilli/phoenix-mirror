import QtQuick
import Quickshell.Widgets
import qs.services.theme

Item {
    id: root

    required property bool shown
    required property real centerX
    required property real bottomY
    property Item content: null
    property real pad: 8
    property real gap: 0
    property real cardRadius: 20
    property real edgeMargin: 12

    readonly property bool hovered: hover.hovered
    default property alias slot: holder.data

    property real lastW: 0
    property real lastH: 0
    property bool settled: false

    readonly property real wantW: content ? content.implicitWidth + pad * 2 : lastW
    readonly property real wantH: content ? content.implicitHeight + pad * 2 : lastH

    onWantWChanged: if (content)
        lastW = wantW
    onWantHChanged: if (content)
        lastH = wantH

    onShownChanged: {
        if (shown) {
            Qt.callLater(() => root.settled = root.shown);
        } else {
            settled = false;
        }
    }

    property real cx: centerX
    Behavior on cx {
        enabled: root.settled
        SpringAnimation {
            spring: 3
            damping: 0.4
            epsilon: 0.25
        }
    }

    property real w: wantW
    Behavior on w {
        enabled: root.settled
        SpringAnimation {
            spring: 3
            damping: 0.4
            epsilon: 0.25
        }
    }

    property real h: wantH + gap
    Behavior on h {
        enabled: root.settled
        SpringAnimation {
            spring: 3
            damping: 0.4
            epsilon: 0.25
        }
    }

    readonly property real parentW: parent ? parent.width : 0

    width: shown ? Math.max(0, w) : 0
    height: shown ? Math.max(0, h) : 0
    x: Math.round(Math.max(edgeMargin, Math.min(cx - width / 2, parentW - width - edgeMargin)))
    y: bottomY - height
    visible: shown && height > 0.5

    HoverHandler {
        id: hover
    }

    ClippingRectangle {
        anchors.fill: parent
        anchors.bottomMargin: Math.min(root.gap, root.height)
        color: Theme.background
        radius: root.cardRadius

        Item {
            id: holder
            anchors.fill: parent
        }
    }
}
