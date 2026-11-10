import QtQuick
import Ryu.Extraa
import px.services.theme
import px.services.network

Item {
    id: root

    property bool open: false

    readonly property bool hovered: hover.hovered
    readonly property var wifi: NetworkService.client
    readonly property bool linked: wifi.connectedSsid !== ""
    readonly property int strength: {
        const n = wifi.networks.find(x => x.connected);
        return n ? (n.strength ?? 0) : 0;
    }

    readonly property string glyph: {
        if (!wifi.powered)
            return "\udb82\udd2b";
        if (!linked || strength <= 25)
            return "\udb82\udd1f";
        if (strength <= 50)
            return "\udb82\udd22";
        if (strength <= 75)
            return "\udb82\udd25";
        return "\udb82\udd28";
    }

    implicitWidth: 40
    implicitHeight: 40

    HoverHandler {
        id: hover
    }

    MaterialIconButton {
        anchors.fill: parent
        type: MaterialIconButton.Standard
        shape: MaterialIconButton.Round
        iconText: root.glyph
        iconSize: 22
        iconColor: (root.open || root.linked) ? Theme.primary : Theme.onSurfaceVariantColor
        color: Theme.background
        opacity: root.wifi.powered ? 1 : 0.6
        onClicked: root.wifi.powered = !root.wifi.powered
    }
}
