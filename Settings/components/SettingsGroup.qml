import QtQuick
import qs.services.theme
import qs.configuration.Settings

Item {
    id: root

    default property alias entries: col.data

    width: parent ? parent.width : 0
    height: col.implicitHeight

    component Entry: Item {
        id: entry

        property string key: ""
        property string title: ""
        property string description: ""
        property real minHeight: 0
        default property alias control: slot.data

        readonly property real limit: slot.limit
        readonly property bool stacked: width < 560
        readonly property real pad: 20
        readonly property bool targeted: key !== "" && SettingsConfig.focusKey === key

        function locate() {
            pulse.restart();
            revealTimer.restart();
        }

        width: parent ? parent.width : 0
        height: Math.max(minHeight, stacked ? textCol.implicitHeight + slot.height + (slot.height > 0 ? 12 : 0) + 28 : Math.max(68, textCol.implicitHeight + 28, slot.height + 28))

        onTargetedChanged: if (targeted)
            locate()

        Component.onCompleted: if (targeted)
            locate()

        Timer {
            id: revealTimer
            interval: 160
            onTriggered: {
                const f = SettingsConfig.scroller;
                if (!f)
                    return;
                const c = f.contentItem;
                let p = entry.parent;
                while (p && p !== c)
                    p = p.parent;
                if (!p)
                    return;
                const y = entry.mapToItem(c, 0, 0).y;
                f.contentY = Math.max(0, Math.min(Math.max(0, f.contentHeight - f.height), y - f.height / 3));
            }
        }
        Timer {
            interval: 1600
            running: entry.targeted
            onTriggered: SettingsConfig.focusKey = ""
        }

        Rectangle {
            id: glow
            anchors.fill: parent
            anchors.margins: 4
            radius: 12
            color: Qt.alpha(Theme.primary, 0.14)
            border.width: 2
            border.color: Theme.primary
            opacity: 0
            scale: 1
            z: -1
        }

        SequentialAnimation {
            id: pulse

            ParallelAnimation {
                NumberAnimation {
                    target: glow
                    property: "opacity"
                    to: 1
                    duration: 120
                }
                SpringAnimation {
                    target: glow
                    property: "scale"
                    from: 0.94
                    to: 1
                    spring: 5
                    damping: 0.2
                    epsilon: 0.002
                }
            }

            PauseAnimation {
                duration: 900
            }

            NumberAnimation {
                target: glow
                property: "opacity"
                to: 0
                duration: 400
            }
        }

        Column {
            id: textCol
            x: entry.pad
            y: entry.stacked ? 14 : (entry.height - height) / 2
            width: entry.stacked ? entry.width - entry.pad * 2 : Math.max(0, entry.width - entry.pad * 2 - slot.width - 16)
            spacing: 2

            Text {
                width: parent.width
                text: entry.title
                wrapMode: Text.Wrap
                font.pixelSize: 15
                font.weight: Font.Medium
                color: Theme.onBackgroundColor
            }

            Text {
                width: parent.width
                visible: text !== ""
                text: entry.description
                wrapMode: Text.Wrap
                font.pixelSize: 12
                color: Theme.onSurfaceVariantColor
                opacity: 0.75
            }
        }

        Item {
            id: slot

            readonly property real limit: entry.stacked ? entry.width - entry.pad * 2 : Math.max(160, (entry.width - entry.pad * 2) * 0.55)

            x: entry.stacked ? entry.pad : entry.width - entry.pad - width
            y: entry.stacked ? textCol.y + textCol.implicitHeight + 12 : (entry.height - height) / 2
            width: childrenRect.width
            height: childrenRect.height
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 14
        color: Theme.surfaceContainerLow
    }

    Column {
        id: col
        width: parent.width
    }
}
