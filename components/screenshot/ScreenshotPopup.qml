pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Widgets
import Ryu.Extraa
import qs.services.theme
import qs.services.screenshot
import qs.configuration.Bar
import qs.components.metal

Item {
    id: root

    required property string screenName

    property string last: ""
    property real progress: ScreenshotService.active && ScreenshotService.screenName === screenName ? 1 : 0
    readonly property bool shown: progress > 0.01

    readonly property real pad: 10
    readonly property real btn: 40

    width: shown ? 380 : 0
    height: shown ? 272 : 0
    visible: shown

    Behavior on progress {
        SpringAnimation {
            spring: 3.5
            damping: 0.28
            mass: 1
            epsilon: 0.002
        }
    }

    Connections {
        target: ScreenshotService

        function onPathChanged() {
            if (ScreenshotService.path !== "") {
                root.last = ScreenshotService.path;
                life.restart();
            }
        }
    }

    Timer {
        id: life
        interval: 8000
        running: ScreenshotService.active && root.progress > 0.5 && !hover.hovered
        onTriggered: ScreenshotService.dismiss()
    }

    HoverHandler {
        id: hover
    }

    Loader {
        anchors.fill: parent
        active: root.shown

        sourceComponent: Rectangle {
            id: card

            property real pop: root.progress > 0.5 ? 1 : 0

            Behavior on pop {
                SpringAnimation {
                    spring: 4
                    damping: 0.22
                    epsilon: 0.002
                }
            }

            radius: 24
            color: Theme.background
            border.width: 1
            border.color: Qt.alpha(Theme.primary, BarConfig.metallic ? 0.3 : 0.15)
            scale: 0.9 + 0.1 * pop

            Metal {
                anchors.fill: parent
                kind: "backdrop"
                radius: card.radius
            }

            Metal {
                anchors.fill: parent
                kind: "innerRim"
                radius: card.radius
            }

            ClippingRectangle {
                x: root.pad
                y: root.pad
                width: card.width - root.pad * 2
                height: card.height - root.pad * 3 - root.btn
                radius: 16
                color: Theme.surfaceContainerHighest

                Image {
                    anchors.fill: parent
                    source: root.last !== "" ? "file://" + root.last : ""
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    cache: false
                }
            }

            Row {
                x: root.pad
                y: card.height - root.pad - root.btn
                spacing: 8

                MaterialIconButton {
                    readonly property bool done: ScreenshotService.savedPath !== ""
                    type: MaterialIconButton.Tonal
                    sizeStyle: MaterialIconButton.Small
                    widthStyle: MaterialIconButton.Wide
                    iconText: done ? "\uf00c" : "\uf019"
                    color: done ? Qt.alpha(Theme.primary, 0.22) : Theme.surfaceContainerHighest
                    iconColor: done ? Theme.primary : Theme.onSurfaceVariantColor
                    onClicked: ScreenshotService.save()
                }

                MaterialIconButton {
                    readonly property bool done: ScreenshotService.copied
                    type: MaterialIconButton.Tonal
                    sizeStyle: MaterialIconButton.Small
                    widthStyle: MaterialIconButton.Wide
                    iconText: done ? "\uf00c" : "\uf0c5"
                    color: done ? Qt.alpha(Theme.primary, 0.22) : Theme.surfaceContainerHighest
                    iconColor: done ? Theme.primary : Theme.onSurfaceVariantColor
                    onClicked: ScreenshotService.copy()
                }
            }

            MaterialIconButton {
                x: card.width - root.pad - width
                y: card.height - root.pad - height
                type: MaterialIconButton.Standard
                sizeStyle: MaterialIconButton.Small
                iconText: "\uf00d"
                iconColor: Theme.onSurfaceVariantColor
                onClicked: ScreenshotService.dismiss()
            }
        }
    }
}
