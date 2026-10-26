import QtQuick
import Quickshell.Widgets
import qs.services.theme

Item {
    id: root

    required property bool shown
    required property real centerM
    required property real attach
    property string edge: "bottom"
    property Item content: null
    property real pad: 8
    property real gap: 0
    property real cardRadius: 20
    property real edgeMargin: 12

    readonly property bool vertical: edge === "left" || edge === "right"
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

    property real cm: centerM
    Behavior on cm {
        enabled: root.settled
        SpringAnimation {
            spring: 3
            damping: 0.4
            epsilon: 0.25
        }
    }

    property real w: wantW + (vertical ? gap : 0)
    Behavior on w {
        enabled: root.settled
        SpringAnimation {
            spring: 3
            damping: 0.4
            epsilon: 0.25
        }
    }

    property real h: wantH + (vertical ? 0 : gap)
    Behavior on h {
        enabled: root.settled
        SpringAnimation {
            spring: 3
            damping: 0.25
            epsilon: 0.25
        }
    }

    readonly property real parentW: parent ? parent.width : 0
    readonly property real parentH: parent ? parent.height : 0

    width: shown ? Math.max(0, w) : 0
    height: shown ? Math.max(0, h) : 0
    x: vertical ? (edge === "left" ? attach : attach - width) : Math.round(Math.max(edgeMargin, Math.min(cm - width / 2, parentW - width - edgeMargin)))
    y: vertical ? Math.round(Math.max(edgeMargin, Math.min(cm - height / 2, parentH - height - edgeMargin))) : (edge === "top" ? attach : attach - height)
    visible: shown && height > 0.5 && width > 0.5

    HoverHandler {
        id: hover
    }

    ClippingRectangle {
        anchors.fill: parent
        anchors.bottomMargin: root.edge === "bottom" ? Math.min(root.gap, root.height) : 0
        anchors.topMargin: root.edge === "top" ? Math.min(root.gap, root.height) : 0
        anchors.leftMargin: root.edge === "left" ? Math.min(root.gap, root.width) : 0
        anchors.rightMargin: root.edge === "right" ? Math.min(root.gap, root.width) : 0
        color: Theme.background
        radius: root.cardRadius

        Item {
            id: holder
            anchors.fill: parent
        }
    }
}
