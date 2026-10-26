pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Widgets
import Ryu.Extraa
import qs.services.theme
import qs.services.media

Item {
    id: root

    required property bool active

    readonly property int disc: 160
    readonly property int artSize: 130
    readonly property int rowGap: 18
    readonly property int minContent: 340
    readonly property int maxText: 300
    readonly property real secondsPerTurn: 30
    readonly property real spinSpeed: 26

    readonly property real wantText: Math.max(titleMetrics.advanceWidth, artistMetrics.advanceWidth, albumMetrics.advanceWidth, headerMetrics.advanceWidth + 36)
    readonly property real textWidth: Math.max(150, Math.min(maxText, Math.ceil(wantText) + 4))
    readonly property real contentWidth: Math.max(minContent, disc + rowGap + textWidth)

    readonly property real length: MediaService.player?.length ?? 0
    property real position: 0
    property bool seeking: false
    property bool scrubDirty: false
    property real seekFrac: 0
    property real angle: 0
    property real lastPointer: 0
    property real enter: 0

    readonly property bool holding: seeking || settle.running
    readonly property real frac: holding ? seekFrac : (length > 0 ? Math.max(0, Math.min(1, position / length)) : 0)

    function flushSeek() {
        if (!scrubDirty)
            return;
        scrubDirty = false;
        if (MediaService.player && length > 0)
            MediaService.player.position = seekFrac * length;
    }

    function endSeek() {
        flushSeek();
        position = seekFrac * length;
        settle.restart();
        seeking = false;
    }

    function scrubTo(next) {
        const clamped = Math.max(0, Math.min(1, next));
        if (length > 0)
            angle += (clamped - seekFrac) * length / secondsPerTurn * 360;
        seekFrac = clamped;
        scrubDirty = true;
    }

    anchors.centerIn: parent
    implicitWidth: contentWidth
    implicitHeight: column.implicitHeight
    visible: active

    Component.onCompleted: enter = 1

    TextMetrics {
        id: titleMetrics
        text: MediaService.title
        font.pixelSize: 18
        font.weight: Font.DemiBold
    }

    TextMetrics {
        id: artistMetrics
        text: MediaService.artist
        font.pixelSize: 13
    }

    TextMetrics {
        id: albumMetrics
        text: MediaService.album
        font.pixelSize: 11
    }

    TextMetrics {
        id: headerMetrics
        text: MediaService.identity.toUpperCase()
        font.pixelSize: 10
        font.weight: Font.DemiBold
        font.letterSpacing: 1.2
    }

    Binding {
        target: root
        property: "position"
        value: MediaService.player?.position ?? 0
        when: !root.holding
    }

    Behavior on enter {
        NumberAnimation {
            duration: 260
            easing.type: Easing.OutCubic
        }
    }

    Behavior on position {
        enabled: !root.holding
        NumberAnimation {
            duration: 500
            easing.type: Easing.Linear
        }
    }

    Timer {
        id: settle
        interval: 700
    }

    Timer {
        interval: 70
        repeat: true
        running: root.seeking
        onTriggered: root.flushSeek()
    }

    Timer {
        interval: 500
        repeat: true
        running: root.active && MediaService.isPlaying
        onTriggered: MediaService.player?.positionChanged()
    }

    FrameAnimation {
        running: root.active && MediaService.isPlaying && !root.seeking
        onTriggered: root.angle = (root.angle + frameTime * root.spinSpeed) % 360
    }

    Column {
        id: column
        x: 0
        y: (1 - root.enter) * 8
        width: root.contentWidth
        spacing: 18
        opacity: root.enter

        Row {
            width: parent.width
            height: root.disc
            spacing: root.rowGap

            Item {
                width: root.disc
                height: root.disc

                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: Theme.surfaceContainer
                    border.width: 1
                    border.color: Qt.alpha(Theme.primary, 0.18)
                }

                Item {
                    id: spinner
                    anchors.fill: parent
                    rotation: root.angle

                    Repeater {
                        model: 3

                        Rectangle {
                            id: groove
                            required property int index

                            anchors.centerIn: parent
                            width: root.disc - 6 - index * 8
                            height: width
                            radius: width / 2
                            color: "transparent"
                            border.width: 1
                            border.color: Qt.alpha(Theme.onSurfaceVariantColor, 0.08 + (index % 2) * 0.05)
                        }
                    }

                    ClippingRectangle {
                        anchors.centerIn: parent
                        width: root.artSize
                        height: root.artSize
                        radius: width / 2
                        color: Theme.surfaceContainerHighest

                        Image {
                            anchors.fill: parent
                            source: MediaService.artUrl
                            visible: MediaService.artUrl !== ""
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: false
                            opacity: status === Image.Ready ? 1 : 0

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 200
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: MediaService.artUrl === ""
                            text: "\uf001"
                            font.pixelSize: 34
                            color: Theme.onSurfaceVariantColor
                            opacity: 0.4
                        }
                    }

                    Rectangle {
                        anchors.centerIn: parent
                        width: root.artSize
                        height: width
                        radius: width / 2
                        color: "transparent"
                        border.width: 2
                        border.color: Qt.alpha(Theme.primary, 0.5)
                    }

                    Rectangle {
                        anchors.centerIn: parent
                        width: 14
                        height: width
                        radius: width / 2
                        color: Theme.background
                        border.width: 2
                        border.color: Qt.alpha(Theme.primary, 0.6)
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: MediaService.player?.canSeek ?? false
                    cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor

                    function pointerAngle(m) {
                        return Math.atan2(m.y - height / 2, m.x - width / 2) * 180 / Math.PI;
                    }

                    onPressed: m => {
                        const dx = m.x - width / 2;
                        const dy = m.y - height / 2;
                        if (Math.sqrt(dx * dx + dy * dy) > width / 2) {
                            m.accepted = false;
                            return;
                        }
                        root.lastPointer = pointerAngle(m);
                        root.seekFrac = root.frac;
                        root.seeking = true;
                    }

                    onPositionChanged: m => {
                        if (!pressed)
                            return;
                        const a = pointerAngle(m);
                        let d = a - root.lastPointer;
                        if (d > 180)
                            d -= 360;
                        else if (d < -180)
                            d += 360;
                        root.lastPointer = a;
                        root.angle += d;
                        if (root.length > 0) {
                            root.seekFrac = Math.max(0, Math.min(1, root.seekFrac + (d / 360 * root.secondsPerTurn) / root.length));
                            root.scrubDirty = true;
                        }
                    }

                    onReleased: root.endSeek()

                    onCanceled: root.endSeek()
                }
            }

            Column {
                width: root.textWidth
                anchors.verticalCenter: parent.verticalCenter
                spacing: 5

                Item {
                    width: parent.width
                    height: 28

                    Text {
                        anchors.left: parent.left
                        anchors.right: toggle.left
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        text: MediaService.identity.toUpperCase()
                        wrapMode: Text.NoWrap
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                        font.letterSpacing: 1.2
                        color: Theme.primary
                        opacity: 0.8
                    }

                    MaterialIconButton {
                        id: toggle
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        width: 28
                        height: 28
                        type: MaterialIconButton.Tonal
                        shape: MaterialIconButton.Round
                        iconText: "\uf001"
                        iconSize: 12
                        color: MediaService.visualizerEnabled ? Theme.primary : Theme.surfaceContainerHighest
                        iconColor: MediaService.visualizerEnabled ? Theme.onPrimaryColor : Theme.onSurfaceVariantColor
                        onClicked: MediaService.toggleVisualizer()
                    }
                }

                Text {
                    width: parent.width
                    text: MediaService.title
                    wrapMode: Text.Wrap
                    font.pixelSize: 18
                    font.weight: Font.DemiBold
                    lineHeight: 1.1
                    color: Theme.onBackgroundColor
                }

                Text {
                    width: parent.width
                    visible: text !== ""
                    text: MediaService.artist
                    wrapMode: Text.Wrap
                    font.pixelSize: 13
                    color: Theme.onSurfaceVariantColor
                    opacity: 0.9
                }

                Text {
                    width: parent.width
                    visible: text !== ""
                    text: MediaService.album
                    wrapMode: Text.Wrap
                    font.pixelSize: 11
                    color: Theme.onSurfaceVariantColor
                    opacity: 0.55
                }
            }
        }

        Column {
            width: parent.width
            spacing: 4

            Item {
                width: parent.width
                height: 16

                WavyProgress {
                    anchors.fill: parent
                    style: WavyProgress.Linear
                    indeterminate: false
                    progress: root.frac
                    color: Theme.primary
                    trackColor: Theme.surfaceContainerHighest
                    strokeWidth: 4
                    gap: 4
                    wavelength: 30
                    waveSpeed: 0.67
                    amplitude: MediaService.isPlaying ? 2.5 : 0

                    Behavior on amplitude {
                        NumberAnimation {
                            duration: 400
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -4
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    enabled: MediaService.player?.canSeek ?? false

                    function update(mouse) {
                        root.scrubTo(mouse.x / width);
                    }

                    onPressed: mouse => {
                        root.seekFrac = root.frac;
                        root.seeking = true;
                        update(mouse);
                    }
                    onPositionChanged: mouse => {
                        if (pressed)
                            update(mouse);
                    }
                    onReleased: mouse => {
                        update(mouse);
                        root.endSeek();
                    }
                    onCanceled: root.endSeek()
                }
            }

            Item {
                width: parent.width
                height: timeLeft.implicitHeight

                Text {
                    id: timeLeft
                    anchors.left: parent.left
                    text: MediaService.formatTime(root.frac * root.length)
                    font.pixelSize: 11
                    color: Theme.onSurfaceVariantColor
                    opacity: 0.7
                }

                Text {
                    anchors.right: parent.right
                    text: MediaService.formatTime(root.length)
                    font.pixelSize: 11
                    color: Theme.onSurfaceVariantColor
                    opacity: 0.7
                }
            }
        }
    }
}
