pragma ComponentBehavior: Bound
import QtQuick
import qs.services.theme
import qs.services.stats

Item {
    id: root

    property real reveal: 1
    property int current: -1
    property int last: -1
    property int link: -1
    property int linkDir: 1

    readonly property real cardWidth: 142
    readonly property real cardHeight: 178
    readonly property real gap: 14
    readonly property int leadDelay: 220

    function report(i, hovered) {
        if (hovered) {
            idle.stop();
            if (last >= 0 && Math.abs(last - i) === 1) {
                link = Math.min(last, i);
                linkDir = i > last ? 1 : -1;
            } else {
                link = -1;
            }
            current = i;
            last = i;
        } else if (current === i) {
            current = -1;
            idle.restart();
        }
    }

    function leadFor(i) {
        return link >= 0 && i === last ? leadDelay : 0;
    }

    function sideFor(i) {
        return link >= 0 && i === last && linkDir < 0 ? 1 : 0;
    }

    Component.onCompleted: SystemStatsService.acquire()
    Component.onDestruction: SystemStatsService.release()

    Timer {
        id: idle
        interval: 280
        onTriggered: {
            root.last = -1;
            root.link = -1;
        }
    }

    Item {
        id: strip
        anchors.centerIn: parent
        width: row.width
        height: root.cardHeight

        Row {
            id: row
            spacing: root.gap

            StatCard {
                order: 0
                reveal: root.reveal
                lead: root.leadFor(0)
                startSide: root.sideFor(0)
                label: "CPU"
                value: SystemStatsService.cpu
                center: Math.round(SystemStatsService.cpu * 100) + "%"
                detail: SystemStatsService.cpu >= 0.8 ? "heavy load" : (SystemStatsService.cpu >= 0.3 ? "active" : "idle")
                tone: SystemStatsService.cpu >= 0.9 ? Theme.error : Theme.primary
                onHoveredChanged: root.report(0, hovered)
            }

            StatCard {
                order: 1
                reveal: root.reveal
                lead: root.leadFor(1)
                startSide: root.sideFor(1)
                label: "RAM"
                value: SystemStatsService.ram
                center: Math.round(SystemStatsService.ram * 100) + "%"
                detail: SystemStatsService.ramUsed.toFixed(1) + " / " + SystemStatsService.ramTotal.toFixed(1) + " GB"
                tone: SystemStatsService.ram >= 0.9 ? Theme.error : Theme.secondary
                onHoveredChanged: root.report(1, hovered)
            }

            StatCard {
                order: 2
                reveal: root.reveal
                lead: root.leadFor(2)
                startSide: root.sideFor(2)
                label: "TEMP"
                value: SystemStatsService.temp / 100
                center: Math.round(SystemStatsService.temp) + " C"
                detail: SystemStatsService.temp >= 85 ? "too hot" : (SystemStatsService.temp >= 70 ? "warm" : "cool")
                tone: SystemStatsService.temp >= 85 ? Theme.error : Theme.tertiary
                onHoveredChanged: root.report(2, hovered)
            }

            StatCard {
                order: 3
                reveal: root.reveal
                lead: root.leadFor(3)
                startSide: root.sideFor(3)
                label: "DISK"
                value: SystemStatsService.disk
                center: Math.round(SystemStatsService.disk * 100) + "%"
                detail: SystemStatsService.diskUsed.toFixed(0) + " / " + SystemStatsService.diskTotal.toFixed(0) + " GB"
                tone: SystemStatsService.disk >= 0.9 ? Theme.error : Theme.primary
                onHoveredChanged: root.report(3, hovered)
            }
        }

        Repeater {
            model: 3

            Item {
                id: pipe
                required property int index

                readonly property bool lit: root.link === index
                property real fill: lit ? 1 : 0
                property int dir: 1

                x: index * (root.cardWidth + root.gap) + root.cardWidth
                y: root.cardHeight / 2 - 1
                width: root.gap
                height: 2
                opacity: Math.max(0, Math.min(1, root.reveal))

                onLitChanged: if (lit)
                    dir = root.linkDir

                Behavior on fill {
                    NumberAnimation {
                        duration: 220
                        easing.type: Easing.OutCubic
                    }
                }

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: pipe.width
                    height: 1
                    color: Theme.outlineVariant
                }

                Rectangle {
                    x: pipe.dir > 0 ? 0 : pipe.width - width
                    width: pipe.width * pipe.fill
                    height: 2
                    color: Theme.primary
                }
            }
        }
    }
}
