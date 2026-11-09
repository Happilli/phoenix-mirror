import QtQuick
import Ryu.Ui
import qs.services.theme

ClippingRectangle {
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
    readonly property real cm: centerM
    property real w: wantW
    Behavior on w {
        enabled: root.settled
        SpringAnimation {
            spring: 3
            damping: 0.4
            epsilon: 0.25
        }
    }
    property real h: wantH
    Behavior on h {
        enabled: root.settled
        SpringAnimation {
            spring: 3
            damping: 0.4
            epsilon: 0.25
        }
    }
    readonly property real parentW: parent ? parent.width : 0
    readonly property real parentH: parent ? parent.height : 0
    width: shown ? Math.max(0, w) : 0
    height: shown ? Math.max(0, h) : 0
    x: {
        if (vertical) {
            if (edge === "left")
                return attach + gap;
            return attach - gap - width;
        }
        return Math.round(Math.max(edgeMargin, Math.min(cm - width / 2, parentW - width - edgeMargin)));
    }
    y: {
        if (!vertical) {
            if (edge === "top")
                return attach + gap;
            return attach - gap - height;
        }
        return Math.round(Math.max(edgeMargin, Math.min(cm - height / 2, parentH - height - edgeMargin)));
    }
    visible: shown && height > 0.5 && width > 0.5
    color: Theme.background
    radius: cardRadius
    HoverHandler {
        id: hover
    }
    Item {
        id: holder
        anchors.fill: parent
    }
}
