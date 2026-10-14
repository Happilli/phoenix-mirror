pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Widgets
import Ryu.Extraa
import qs.services.theme
import qs.services.media

Item {
    id: root

    required property bool active

    readonly property int contentWidth: 340
    readonly property int pad: 14
    readonly property int coverSize: 92

    readonly property real length: MediaService.player?.length ?? 0
    property real position: MediaService.player?.position ?? 0
    property bool seeking: false
    property real seekFrac: 0
    property real enter: 0

    readonly property real frac: seeking ? seekFrac : (length > 0 ? Math.max(0, Math.min(1, position / length)) : 0)

    anchors.centerIn: parent
    implicitWidth: contentWidth + pad * 2
    implicitHeight: column.implicitHeight + pad * 2
    visible: active

    Component.onCompleted: enter = 1

    Behavior on enter {
        NumberAnimation {
            duration: 260
            easing.type: Easing.OutCubic
        }
    }

    Behavior on position {
        enabled: !root.seeking
        NumberAnimation {
            duration: 500
            easing.type: Easing.Linear
        }
    }

    Timer {
        interval: 500
        repeat: true
        running: root.active && MediaService.isPlaying
        onTriggered: MediaService.player?.positionChanged()
    }

    Column {
        id: column
        x: root.pad
        y: root.pad + (1 - root.enter) * 8
        width: root.contentWidth
        spacing: 14
        opacity: root.enter

        Row {
            width: parent.width
            height: root.coverSize
            spacing: 14

            ClippingRectangle {
                width: root.coverSize
                height: root.coverSize
                radius: 18
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
                    font.pixelSize: 32
                    color: Theme.onSurfaceVariantColor
                    opacity: 0.5
                }
            }

            Column {
                width: parent.width - root.coverSize - parent.spacing
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                Text {
                    width: parent.width
                    text: MediaService.identity.toUpperCase()
                    visible: text !== ""
                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                    font.letterSpacing: 1.2
                    color: Theme.primary
                    opacity: 0.8
                    elide: Text.ElideRight
                }

                Text {
                    width: parent.width
                    text: MediaService.title
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                    color: Theme.onBackgroundColor
                }

                Text {
                    width: parent.width
                    visible: text !== ""
                    text: MediaService.artist
                    elide: Text.ElideRight
                    font.pixelSize: 13
                    color: Theme.onSurfaceVariantColor
                    opacity: 0.85
                }

                Text {
                    width: parent.width
                    visible: text !== ""
                    text: MediaService.album
                    elide: Text.ElideRight
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
                        root.seekFrac = Math.max(0, Math.min(1, mouse.x / width));
                    }

                    onPressed: mouse => {
                        root.seeking = true;
                        update(mouse);
                    }
                    onPositionChanged: mouse => {
                        if (pressed)
                            update(mouse);
                    }
                    onReleased: mouse => {
                        update(mouse);
                        if (MediaService.player && root.length > 0)
                            MediaService.player.position = root.seekFrac * root.length;
                        root.position = root.seekFrac * root.length;
                        root.seeking = false;
                    }
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

        Item {
            width: parent.width
            height: 48

            Row {
                anchors.centerIn: parent
                spacing: 12

                MaterialIconButton {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 40
                    height: 40
                    enabled: MediaService.player?.canGoPrevious ?? false
                    type: MaterialIconButton.Tonal
                    shape: MaterialIconButton.Round
                    iconText: "\uf04a"
                    iconSize: 16
                    color: Theme.surfaceContainerHighest
                    iconColor: Theme.onSurfaceVariantColor
                    onClicked: MediaService.previous()
                }

                MaterialIconButton {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 52
                    height: 48
                    enabled: MediaService.hasPlayer
                    type: MaterialIconButton.Filled
                    shape: MediaService.isPlaying ? MaterialIconButton.Square : MaterialIconButton.Round
                    springStiffness: 380
                    springDamping: 0.28
                    iconText: MediaService.isPlaying ? "\uf04c" : "\uf04b"
                    iconSize: 20
                    color: Theme.primary
                    iconColor: Theme.onPrimaryColor
                    onClicked: MediaService.togglePlaying()
                }

                MaterialIconButton {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 40
                    height: 40
                    enabled: MediaService.player?.canGoNext ?? false
                    type: MaterialIconButton.Tonal
                    shape: MaterialIconButton.Round
                    iconText: "\uf04e"
                    iconSize: 16
                    color: Theme.surfaceContainerHighest
                    iconColor: Theme.onSurfaceVariantColor
                    onClicked: MediaService.next()
                }
            }
            MaterialIconButton {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: 40
                height: 40
                type: MaterialIconButton.Tonal
                shape: MaterialIconButton.Round
                iconText: "\uf001"
                iconSize: 16
                color: MediaService.visualizerEnabled ? Theme.primary : Theme.surfaceContainerHighest
                iconColor: MediaService.visualizerEnabled ? Theme.onPrimaryColor : Theme.onSurfaceVariantColor
                onClicked: MediaService.toggleVisualizer()
            }
        }

        MediaVisualizer {
            width: parent.width
            height: 44
            running: root.active
        }
    }
}
