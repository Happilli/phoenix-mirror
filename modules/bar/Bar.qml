pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Shapes

Item {
    id: root
    property real radius
    property color colour
    property var screen
    readonly property Item popupS: host

    readonly property real notchPadding: 4
    readonly property real notchRadius: 18
    readonly property real notchRadiusBottom: 30
    readonly property real itemGap: 8
    readonly property real popupGap: 10
    readonly property real dateShift: notchRadius + notchPadding + 12

    readonly property var permanent: [battery]

    readonly property var activeContent: {
        if (target === controls)
            return controlsLoader.item;
        if (target === powerProfile)
            return powerLoader.item;
        if (target === datetime)
            return calendarLoader.item;
        if (target === appSlot)
            return previewLoader.item;
        if (target === nightMode)
            return nightLoader.item;
        return null;
    }

    readonly property bool popupShown: notchOpen && (target === controls || target === powerProfile || target === datetime || target === appSlot || target === nightMode)
    readonly property Item hoveredItem: {
        if (powerHover.hovered)
            return powerProfile;
        if (ctrlHover.hovered && dateHover.hovered)
            return (notchOpen && target === datetime) ? datetime : controls;
        if (ctrlHover.hovered)
            return controls;
        if (dateHover.hovered)
            return datetime;
        if (openedApp.hoveredCell)
            return appSlot;
        if (nightHover.hovered)
            return nightMode;
        if (host.hovered)
            return target;
        return null;
    }
    property Item target: controls
    property bool notchOpen: false

    property real dateOffset: (notchOpen && target === datetime) ? dateShift : 0
    Behavior on dateOffset {
        NumberAnimation {
            duration: 180
            easing.type: Easing.OutCubic
        }
    }

    readonly property real targetX: {
        if (target === datetime)
            return dateSlot.x - dateShift;
        if (target === controls)
            return dateSlot.x - itemGap - controls.width;
        if (target === powerProfile)
            return dateSlot.x - itemGap - controls.width - itemGap - powerProfile.width;
        return target.x;
    }

    property real notchProgress: notchOpen ? 1 : 0
    Behavior on notchProgress {
        SpringAnimation {
            spring: 4
            damping: 0.25
            epsilon: 0.25
        }
    }

    property real l2: targetX - notchPadding
    property real l3: targetX + target.width + notchPadding
    Behavior on l2 {
        enabled: root.notchOpen
        SpringAnimation {
            spring: 3
            damping: 0.4
            epsilon: 0.25
        }
    }
    Behavior on l3 {
        enabled: root.notchOpen
        SpringAnimation {
            spring: 3
            damping: 0.4
            epsilon: 0.25
        }
    }

    readonly property real fullFloorY: Math.min(controls.y + controls.height + notchPadding, height)
    readonly property real permanentDepth: Math.max(0, fullFloorY - radius)
    readonly property real depth: permanentDepth * notchProgress

    function outline() {
        const R = radius;
        const W = width;
        const H = height;
        const cuts = [];
        for (const item of permanent) {
            cuts.push({
                l: item.x - notchPadding,
                r: item.x + item.width + notchPadding,
                d: permanentDepth
            });
        }
        if (depth > 0.5) {
            cuts.push({
                l: l2,
                r: l3,
                d: depth
            });
        }
        cuts.sort((a, b) => a.l - b.l);

        let p = `M 0 ${H} L 0 0 Q 0 ${R} ${R} ${R}`;
        for (const c of cuts) {
            const f = R + c.d;
            const rt = Math.min(notchRadius, c.d / 2);
            const rb = Math.min(notchRadiusBottom, Math.max(0, c.d - rt));
            p += ` L ${c.l - rt} ${R} Q ${c.l} ${R} ${c.l} ${R + rt}`;
            p += ` L ${c.l} ${f - rb} Q ${c.l} ${f} ${c.l + rb} ${f}`;
            p += ` L ${c.r - rb} ${f} Q ${c.r} ${f} ${c.r} ${f - rb}`;
            p += ` L ${c.r} ${R + rt} Q ${c.r} ${R} ${c.r + rt} ${R}`;
        }
        p += ` L ${W - R} ${R} Q ${W} ${R} ${W} 0 L ${W} ${H} Z`;
        return p;
    }

    readonly property string outlinePath: outline()

    onHoveredItemChanged: {
        if (hoveredItem) {
            target = hoveredItem;
            closeTimer.stop();
            notchOpen = true;
        } else {
            closeTimer.restart();
        }
    }

    Timer {
        id: closeTimer
        interval: 80
        onTriggered: root.notchOpen = false
    }

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            pathHints: ShapePath.PathSolid | ShapePath.PathNonIntersecting
            fillColor: root.colour
            strokeWidth: 0
            PathSvg {
                path: root.outlinePath
            }
        }
        Workspace {
            id: workspace
            screen: root.screen
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.verticalCenterOffset: root.radius / 2
            anchors.leftMargin: root.itemGap + root.notchPadding 
        }
        NightModeButton {
            id: nightMode
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: workspace.right
            anchors.verticalCenterOffset: root.radius / 2
            anchors.leftMargin: root.itemGap 
            HoverHandler {
                id: nightHover
            }
        }
        OpenedApp {
            id: openedApp
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: nightMode.right
            anchors.verticalCenterOffset: root.radius / 2
            anchors.leftMargin: root.itemGap
        }
        Item {
            id: appSlot
            x: openedApp.x + openedApp.lastX
            width: 32
        }
        Battery {
            id: battery
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.verticalCenterOffset: root.radius / 2
            anchors.rightMargin: root.radius + root.notchPadding + root.notchRadius - 10
        }
        Item {
            id: dateSlot
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: battery.left
            anchors.verticalCenterOffset: root.radius / 2
            anchors.rightMargin: root.itemGap
            width: datetime.width
            height: 40
        }
        Item {
            id: dateHit
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: dateSlot.right
            anchors.verticalCenterOffset: root.radius / 2
            width: dateSlot.width + root.dateShift
            height: 40
            HoverHandler {
                id: dateHover
            }
        }

        Item {
            id: ctrlHit
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: dateSlot.left
            anchors.verticalCenterOffset: root.radius / 2
            anchors.rightMargin: root.itemGap
            width: controls.width + root.dateOffset
            height: 40
            HoverHandler {
                id: ctrlHover
            }
        }

        DateTime {
            id: datetime
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: dateSlot.right
            anchors.verticalCenterOffset: root.radius / 2
            anchors.rightMargin: root.dateOffset
        }
        Controls {
            id: controls
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: dateSlot.left
            anchors.verticalCenterOffset: root.radius / 2
            anchors.rightMargin: root.itemGap + root.dateOffset
        }
        PowerProfileButton {
            id: powerProfile
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: controls.left
            anchors.verticalCenterOffset: root.radius / 2
            anchors.rightMargin: root.itemGap
        }
        Item {
            id: powerHit
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: dateSlot.left
            anchors.verticalCenterOffset: root.radius / 2
            anchors.rightMargin: root.itemGap + controls.width + root.itemGap
            width: powerProfile.width + root.dateOffset
            height: 40
            HoverHandler {
                id: powerHover
            }
        }
        NotificationsIndicator {
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: powerProfile.left
            anchors.verticalCenterOffset: root.radius / 2
            anchors.rightMargin: root.notchPadding + root.notchRadius + 8
        }
    }

    PopupHost {
        id: host
        shown: root.popupShown
        content: root.activeContent
        gap: root.popupGap
        centerX: root.targetX + root.target.width / 2
        bottomY: root.radius

        Loader {
            id: controlsLoader
            anchors.centerIn: parent
            active: root.notchOpen && root.target === controls
            sourceComponent: ControlsPopup {
                pill: controls
                active: true
            }
        }
        Loader {
            id: powerLoader
            anchors.centerIn: parent
            active: root.notchOpen && root.target === powerProfile
            sourceComponent: PowerProfilePopup {
                active: true
            }
        }
        Loader {
            id: calendarLoader
            anchors.centerIn: parent
            active: root.notchOpen && root.target === datetime
            sourceComponent: CalendarPopup {
                active: true
            }
        }
        Loader {
            id: previewLoader
            anchors.centerIn: parent
            active: root.notchOpen && root.target === appSlot
            sourceComponent: WindowPreviewPopup {
                active: true
                group: openedApp.hoverGroup
                maxWidth: root.width - 2 * host.edgeMargin - host.pad * 2
            }
        }
        Loader {
            id: nightLoader
            anchors.centerIn: parent
            active: root.notchOpen && root.target === nightMode
            sourceComponent: NightModePopup {
                active: true
            }
        }
    }
}
