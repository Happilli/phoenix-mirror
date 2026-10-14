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

    readonly property var permanent: [battery, recordingIndicator]

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
        if (target === mediaButton)
            return mediaLoader.item;
        if (target === startMenu)
            return startLoader.item;
        if (target === dailyWar)
            return warLoader.item;
        return null;
    }

    readonly property bool popupShown: notchOpen && (target === controls || target === powerProfile || target === datetime || target === appSlot || target === nightMode || target === mediaButton || target === startMenu || target === dailyWar)
    readonly property Item hoveredItem: {
        if (powerHover.hovered)
            return powerProfile;
        if (warHover.hovered)
            return dailyWar;
        if (ctrlHover.hovered && dateHover.hovered)
            return (notchOpen && target === datetime) ? datetime : controls;
        if (ctrlHover.hovered)
            return controls;
        if (dateHover.hovered)
            return datetime;
        if (openedApp.hoveredCell)
            return appSlot;
        if (mediaHover.hovered)
            return mediaButton;
        if (nightHover.hovered)
            return nightMode;
        if (startHover.hovered)
            return startMenu;
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

    property real recOffset: (notchOpen && target === powerProfile) ? dateShift : 0
    Behavior on recOffset {
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
        if (target === dailyWar)
            return dateSlot.x - itemGap - controls.width - itemGap - dailyWar.width;
        if (target === powerProfile)
            return dateSlot.x - itemGap - controls.width - itemGap - dailyWar.width - itemGap - powerProfile.width;
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
            const k = item.cutProgress ?? 1;
            if (permanentDepth * k < 0.5) {
                continue;
            }
            cuts.push({
                l: item.x - notchPadding,
                r: item.x + item.width + notchPadding,
                d: permanentDepth * k
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
        StartButton {
            id: startMenu
            open: root.notchOpen && root.target === startMenu
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: workspace.right
            anchors.verticalCenterOffset: root.radius / 2
            anchors.leftMargin: root.itemGap
            HoverHandler {
                id: startHover
            }
        }
        NightModeButton {
            id: nightMode
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: startMenu.right
            anchors.verticalCenterOffset: root.radius / 2
            anchors.leftMargin: root.itemGap
            HoverHandler {
                id: nightHover
            }
        }
        MediaButton {
            id: mediaButton
            open: root.notchOpen && root.target === mediaButton
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: nightMode.right
            anchors.verticalCenterOffset: root.radius / 2
            anchors.leftMargin: root.itemGap
            HoverHandler {
                id: mediaHover
            }
        }
        OpenedApp {
            id: openedApp
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: mediaButton.right
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

        RecordingIndicator {
            id: recordingIndicator
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: powerProfile.left
            anchors.verticalCenterOffset: root.radius / 2
            anchors.rightMargin: 16 + root.recOffset
        }
        DailyWarButton {
            id: dailyWar
            open: root.notchOpen && root.target === dailyWar
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: controls.left
            anchors.verticalCenterOffset: root.radius / 2
            anchors.rightMargin: root.itemGap
        }
        PowerProfileButton {
            id: powerProfile
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: dailyWar.left
            anchors.verticalCenterOffset: root.radius / 2
            anchors.rightMargin: root.itemGap
        }
        Item {
            id: warHit
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: dateSlot.left
            anchors.verticalCenterOffset: root.radius / 2
            anchors.rightMargin: root.itemGap + controls.width + root.itemGap + root.dateOffset
            width: dailyWar.width
            height: 40
            HoverHandler {
                id: warHover
            }
        }
        Item {
            id: powerHit
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: dateSlot.left
            anchors.verticalCenterOffset: root.radius / 2
            anchors.rightMargin: root.itemGap + controls.width + root.itemGap + dailyWar.width + root.itemGap + root.dateOffset
            width: powerProfile.width
            height: 40
            HoverHandler {
                id: powerHover
            }
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
            id: warLoader
            anchors.centerIn: parent
            active: root.notchOpen && root.target === dailyWar
            sourceComponent: DailyWarPopup {
                active: true
            }
        }
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
        Loader {
            id: mediaLoader
            anchors.centerIn: parent
            active: root.notchOpen && root.target === mediaButton
            sourceComponent: MediaPopup {
                active: true
            }
        }
        Loader {
            id: startLoader
            anchors.left: parent.left
            anchors.leftMargin: host.pad
            anchors.bottom: parent.bottom
            anchors.bottomMargin: host.pad
            active: root.notchOpen && root.target === startMenu
            sourceComponent: StartMenuPopup {
                active: true
            }
        }
    }
}
