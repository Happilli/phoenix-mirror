import QtQuick
import px.services.theme
import px.services.recorder

Rectangle {
    id: root

    property bool vertical: false

    readonly property bool active: RecorderService.recording
    property real cutProgress: active ? 1 : 0
    property int seconds: 0

    function pad(n) {
        return n < 10 ? "0" + n : "" + n;
    }

    readonly property string timeText: {
        const h = Math.floor(seconds / 3600);
        const m = Math.floor((seconds % 3600) / 60);
        const s = seconds % 60;
        return h > 0 ? h + ":" + pad(m) + ":" + pad(s) : pad(m) + ":" + pad(s);
    }

    width: vertical ? 44 : group.implicitWidth + 24
    height: vertical ? group.implicitHeight + 24 : 40
    radius: Math.min(width, height) / 2
    color: Theme.surfaceContainer
    opacity: Math.max(0, (cutProgress - 0.3) / 0.7)
    scale: 0.8 + 0.2 * cutProgress
    transformOrigin: Item.Center
    visible: cutProgress > 0.01

    Behavior on cutProgress {
        NumberAnimation {
            duration: 380
            easing.type: Easing.OutCubic
        }
    }

    Timer {
        interval: 1000
        repeat: true
        running: root.active
        triggeredOnStart: true
        onTriggered: root.seconds = Math.max(0, Math.floor((Date.now() - RecorderService.startedAt) / 1000))
    }

    TextMetrics {
        id: metrics
        font: label.font
        text: root.seconds >= 3600 ? "0:00:00" : "00:00"
    }

    Grid {
        id: group
        anchors.centerIn: parent
        flow: root.vertical ? Grid.TopToBottom : Grid.LeftToRight
        columns: root.vertical ? 1 : 2
        spacing: root.vertical ? 6 : 10
        horizontalItemAlignment: Grid.AlignHCenter
        verticalItemAlignment: Grid.AlignVCenter

        Rectangle {
            width: 12
            height: 12
            radius: 6
            color: Theme.error
        }

        Text {
            id: label
            width: metrics.advanceWidth
            text: root.timeText
            color: Theme.onSurfaceVariantColor
            font.pixelSize: root.vertical ? 11 : 16
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: RecorderService.stop()
    }
}
