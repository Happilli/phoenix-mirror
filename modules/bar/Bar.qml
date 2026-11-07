pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Shapes
import qs.services.theme
import qs.configuration.Bar

Item {
    id: root

    property real radius
    property color colour
    property var screen
    property Item target: controls
    property bool notchOpen: false

    readonly property Item popupS: host
    readonly property Item hitbox: hit

    readonly property string edge: BarConfig.edge
    readonly property bool floating: BarConfig.floating
    readonly property bool horizontal: edge === "top" || edge === "bottom"
    readonly property bool lowFlat: edge === "bottom" || edge === "right"
    readonly property real length: horizontal ? width : height
    readonly property real thickness: horizontal ? height : width

    readonly property real notchPadding: 4
    readonly property real notchRadius: 18
    readonly property real notchRadiusBottom: 30
    readonly property real itemGap: 8
    readonly property real tightGap: 0
    readonly property real slideShift: 6
    readonly property real popupGap: 10
    readonly property real closedGap: 4
    readonly property real dateShift: notchRadius + notchPadding + 12

    readonly property real topLine: floating ? 0 : radius
    readonly property real edgePad: floating ? Math.max(itemGap + notchPadding, radius * 0.5) : itemGap + notchPadding
    readonly property real rightPad: edgePad
    readonly property real batteryPad: floating ? edgePad : radius + notchPadding + notchRadius - 10
    readonly property real leftTrim: Math.max(0, batteryPad - closedGap)
    readonly property real sessionLift: floating ? Math.max(0, radius + notchPadding + notchRadius - batteryPad) : 0

    readonly property real cc: floating ? thickness / 2 : (lowFlat ? thickness / 2 + radius / 2 : thickness / 2 - radius / 2)
    readonly property real attach: floating ? (lowFlat ? 0 : thickness) : (lowFlat ? radius : thickness - radius)

    readonly property var permanent: floating ? [] : [battery, recordingIndicator]
    readonly property var popupLoaders: [warLoader, controlsLoader, powerLoader, calendarLoader, previewLoader, nightLoader, mediaLoader, startLoader]
    readonly property var activeLoader: popupLoaders.find(l => l.owner === target) ?? null
    readonly property var activeContent: activeLoader ? activeLoader.item : null
    readonly property bool popupShown: notchOpen && activeLoader !== null

    readonly property Item hoveredItem: {
        if (powerSlot.hovered || powerProfile.hovered)
            return powerProfile;
        if (dailyWar.hovered)
            return dailyWar;
        if (controls.hovered)
            return controls;
        if (dateSlot.hovered)
            return datetime;
        if (openedApp.hoveredCell)
            return appSlot;
        if (sessionButton.hovered || sessionSlot.hovered)
            return sessionButton;
        if (nightMode.hovered || nightSlot.hovered)
            return nightMode;
        if (startMenu.hovered || startSlot.hovered)
            return startMenu;
        if (mediaButton.hovered || mediaSlot.hovered)
            return mediaButton;
        if (host.hovered)
            return target;
        return null;
    }

    readonly property int groupIndex: {
        if (!notchOpen)
            return -1;
        if (target === startMenu)
            return 1;
        if (target === nightMode)
            return 2;
        if (target === mediaButton)
            return 3;
        return -1;
    }

    property real dateOffset: (notchOpen && target === datetime) ? dateShift : 0
    property real recOffset: (notchOpen && target === powerProfile) ? dateShift : 0
    property real pairOffset: (notchOpen && (target === powerProfile || target === dailyWar)) ? slideShift : 0
    property real startOffset: groupShift(1)
    property real nightOffset: groupShift(2)
    property real mediaOffset: groupShift(3)
    readonly property bool sessionWanted: notchOpen && target === sessionButton
    property bool sessionLifted: false
    property real leftShift: sessionLifted ? -sessionLift : (sessionWanted ? 0 : leftTrim)

    onSessionWantedChanged: {
        if (sessionWanted) {
            liftTimer.stop();
            sessionLifted = true;
        } else if (notchOpen || !floating) {
            liftTimer.stop();
            sessionLifted = false;
        } else {
            liftTimer.restart();
        }
    }

    readonly property real mSessionClosed: batteryPad - leftTrim
    readonly property real mSessionSlot: batteryPad - leftShift
    readonly property real mWorkspace: mSessionSlot + lenOf(sessionButton) + itemGap
    readonly property real mStartSlot: mWorkspace + lenOf(workspace) + itemGap
    readonly property real mNightSlot: mStartSlot + lenOf(startMenu) + tightGap
    readonly property real mMediaSlot: mNightSlot + lenOf(nightMode) + tightGap
    readonly property real mStart: mStartSlot + startOffset
    readonly property real mNight: mNightSlot + nightOffset
    readonly property real mMedia: mMediaSlot + mediaOffset
    readonly property real mApps: mMediaSlot + lenOf(mediaButton) + itemGap

    readonly property real mBattery: length - rightPad - lenOf(battery)
    readonly property real mDateSlot: mBattery - itemGap - lenOf(datetime)
    readonly property real mControlsSlot: mDateSlot - itemGap - lenOf(controls)
    readonly property real mWarSlot: mControlsSlot - itemGap - lenOf(dailyWar)
    readonly property real mPowerBase: mWarSlot - tightGap - lenOf(powerProfile)
    readonly property real mDate: mDateSlot - dateOffset
    readonly property real mControls: mControlsSlot - dateOffset
    readonly property real mWar: mWarSlot - dateOffset
    readonly property real mPowerSlot: mPowerBase - dateOffset
    readonly property real mPower: mPowerSlot - pairOffset
    readonly property real mRec: mPower - 16 - recOffset - lenOf(recordingIndicator)

    readonly property real targetM: {
        if (target === datetime)
            return mDateSlot - dateShift;
        if (target === controls)
            return mControlsSlot;
        if (target === dailyWar)
            return mWarSlot;
        if (target === powerProfile)
            return mPowerBase - slideShift;
        if (target === sessionButton)
            return mSessionSlot;
        if (target === startMenu)
            return mStartSlot;
        if (target === nightMode)
            return mNightSlot;
        if (target === mediaButton)
            return mMediaSlot;
        return along(target);
    }

    readonly property real spanL: targetM - notchPadding
    readonly property real spanR: targetM + lenOf(target) + notchPadding

    property real notchProgress: notchOpen ? 1 : 0
    property real appOffset: openedApp.lastM
    property bool lagAnimated: true
    property real lagL: 0
    property real lagR: 0

    readonly property real l2: spanL + lagL
    readonly property real l3: spanR + lagR

    readonly property real crossSize: horizontal ? controls.height : controls.width
    readonly property real fullFloorY: floating ? Math.min(thickness / 2 + crossSize / 2 + notchPadding, thickness - 4) : Math.min(thickness / 2 + radius / 2 + crossSize / 2 + notchPadding, thickness)
    readonly property real permanentDepth: Math.max(0, fullFloorY - topLine)
    readonly property real depth: permanentDepth * notchProgress

    readonly property string outlinePath: buildPath()

    function groupShift(i) {
        if (groupIndex < 0 || groupIndex === i)
            return 0;
        return i < groupIndex ? -slideShift : slideShift;
    }

    function lenOf(item) {
        return horizontal ? item.width : item.height;
    }

    function along(item) {
        return horizontal ? item.x : item.y;
    }

    function px(m, item) {
        return horizontal ? m : cc - item.width / 2;
    }

    function py(m, item) {
        return horizontal ? cc - item.height / 2 : m;
    }

    function pt(u, w) {
        switch (edge) {
        case "top":
            return u + " " + (thickness - w);
        case "left":
            return (thickness - w) + " " + u;
        case "right":
            return w + " " + u;
        }
        return u + " " + w;
    }

    function buildPath() {
        const R = radius;
        const W = length;
        const H = thickness;
        const T = topLine;
        const r = Math.max(0, Math.min(R, H / 2, W / 2));
        const inset = floating ? r : R;

        const cuts = [];
        for (const item of permanent) {
            const d = permanentDepth * (item.cutProgress ?? 1);
            if (d < 0.5)
                continue;
            const s = along(item);
            cuts.push({
                l: s - notchPadding,
                r: s + lenOf(item) + notchPadding,
                d: d
            });
        }
        if (depth > 0.5)
            cuts.push({
                l: l2,
                r: l3,
                d: depth
            });
        cuts.sort((a, b) => a.l - b.l);

        const last = cuts.length - 1;
        const mergedL = !floating && R > 0 && last >= 0 && cuts[0].l < R;
        const mergedR = !floating && R > 0 && last >= 0 && cuts[last].r > W - R;

        let head;
        if (floating)
            head = `M ${pt(0, H - r)} L ${pt(0, r)} Q ${pt(0, 0)} ${pt(r, 0)}`;
        else if (mergedL)
            head = `M ${pt(0, H)} L ${pt(0, 0)}`;
        else
            head = `M ${pt(0, H)} L ${pt(0, 0)} Q ${pt(0, R)} ${pt(R, R)}`;

        let body = "";
        for (let i = 0; i < cuts.length; i++) {
            const c = cuts[i];
            const f = T + c.d;
            const rt = Math.min(notchRadius, c.d / 2);
            const first = i === 0;
            const end = i === last;
            const rtL = first ? Math.min(rt, Math.max(0, c.l - inset)) : rt;
            const rtR = end ? Math.min(rt, Math.max(0, W - inset - c.r)) : rt;

            if (mergedL && first) {
                const xs = Math.max(0, c.l);
                const t = Math.sqrt(xs / R);
                const ys = R * (2 * t - t * t);
                const rb = Math.min(notchRadiusBottom, (c.r - xs) / 2, Math.max(0, f - ys));
                const rj = Math.min(notchRadius, Math.max(0, f - rb - ys));
                const chord = Math.hypot(xs, ys);
                const s = chord > 0 ? Math.min(0.5, rj / chord) : 0;

                if (rj > 0.5 && s > 0) {
                    const u = 1 - s;
                    body += ` Q ${pt(0, u * t * R)} ${pt(u * u * xs, 2 * u * s * t * R + u * u * ys)}`;
                    body += ` Q ${pt(xs, ys)} ${pt(xs, ys + rj)}`;
                } else {
                    body += ` Q ${pt(0, t * R)} ${pt(xs, ys)}`;
                }
                body += ` L ${pt(xs, f - rb)} Q ${pt(xs, f)} ${pt(xs + rb, f)}`;
            } else {
                const rbL = Math.min(notchRadiusBottom, (c.r - c.l) / 2, Math.max(0, c.d - rtL));
                body += ` L ${pt(c.l - rtL, T)} Q ${pt(c.l, T)} ${pt(c.l, T + rtL)}`;
                body += ` L ${pt(c.l, f - rbL)} Q ${pt(c.l, f)} ${pt(c.l + rbL, f)}`;
            }

            if (mergedR && end) {
                const xe = Math.min(W, c.r);
                const t = Math.sqrt((W - xe) / R);
                const ye = R * (2 * t - t * t);
                const rb = Math.min(notchRadiusBottom, (xe - Math.max(0, c.l)) / 2, Math.max(0, f - ye));
                const rj = Math.min(notchRadius, Math.max(0, f - rb - ye));
                const chord = Math.hypot(W - xe, ye);
                const s = chord > 0 ? Math.min(0.5, rj / chord) : 0;

                body += ` L ${pt(xe - rb, f)} Q ${pt(xe, f)} ${pt(xe, f - rb)}`;

                if (rj > 0.5 && s > 0) {
                    const k = (1 - s) * (1 - s);
                    const bx = k * xe + (1 - k) * W;
                    const by = k * ye + 2 * s * (1 - s) * t * R;
                    body += ` L ${pt(xe, ye + rj)} Q ${pt(xe, ye)} ${pt(bx, by)}`;
                    body += ` Q ${pt(W, (1 - s) * t * R)} ${pt(W, 0)}`;
                } else {
                    body += ` L ${pt(xe, ye)} Q ${pt(W, t * R)} ${pt(W, 0)}`;
                }
            } else {
                const rbR = Math.min(notchRadiusBottom, (c.r - c.l) / 2, Math.max(0, c.d - rtR));
                body += ` L ${pt(c.r - rbR, f)} Q ${pt(c.r, f)} ${pt(c.r, f - rbR)}`;
                body += ` L ${pt(c.r, T + rtR)} Q ${pt(c.r, T)} ${pt(c.r + rtR, T)}`;
            }
        }

        let tail;
        if (floating)
            tail = ` L ${pt(W - r, 0)} Q ${pt(W, 0)} ${pt(W, r)} L ${pt(W, H - r)} Q ${pt(W, H)} ${pt(W - r, H)} L ${pt(r, H)} Q ${pt(0, H)} ${pt(0, H - r)} Z`;
        else if (mergedR)
            tail = ` L ${pt(W, H)} Z`;
        else
            tail = ` L ${pt(W - R, R)} Q ${pt(W, R)} ${pt(W, 0)} L ${pt(W, H)} Z`;

        return head + body + tail;
    }

    onHoveredItemChanged: {
        if (!hoveredItem) {
            closeTimer.restart();
            return;
        }
        const keep = notchOpen;
        const oldL = l2;
        const oldR = l3;
        target = hoveredItem;
        lagAnimated = false;
        lagL = keep ? oldL - spanL : 0;
        lagR = keep ? oldR - spanR : 0;
        lagAnimated = true;
        lagL = 0;
        lagR = 0;
        closeTimer.stop();
        notchOpen = true;
    }

    Behavior on dateOffset {
        NumberAnimation {
            duration: 180
            easing.type: Easing.OutCubic
        }
    }

    Behavior on recOffset {
        NumberAnimation {
            duration: 180
            easing.type: Easing.OutCubic
        }
    }

    Behavior on pairOffset {
        NumberAnimation {
            duration: 180
            easing.type: Easing.OutCubic
        }
    }

    Behavior on startOffset {
        NumberAnimation {
            duration: 180
            easing.type: Easing.OutCubic
        }
    }

    Behavior on nightOffset {
        NumberAnimation {
            duration: 180
            easing.type: Easing.OutCubic
        }
    }

    Behavior on mediaOffset {
        NumberAnimation {
            duration: 180
            easing.type: Easing.OutCubic
        }
    }

    Behavior on leftShift {
        NumberAnimation {
            duration: 180
            easing.type: Easing.OutCubic
        }
    }

    Behavior on notchProgress {
        SpringAnimation {
            spring: 4
            damping: 0.25
            epsilon: 0.25
        }
    }

    Behavior on appOffset {
        enabled: root.notchOpen && root.target === appSlot
        SpringAnimation {
            spring: 3
            damping: 0.4
            epsilon: 0.25
        }
    }

    Behavior on lagL {
        enabled: root.lagAnimated
        SpringAnimation {
            spring: 3
            damping: 0.4
            epsilon: 0.25
        }
    }

    Behavior on lagR {
        enabled: root.lagAnimated
        SpringAnimation {
            spring: 3
            damping: 0.4
            epsilon: 0.25
        }
    }

    HoverHandler {
        id: barHover
    }

    Timer {
        id: closeTimer
        interval: (barHover.hovered || root.popupShown) ? 260 : 100
        onTriggered: root.notchOpen = false
    }

    Timer {
        id: liftTimer
        interval: 100
        onTriggered: root.sessionLifted = false
    }

    Item {
        id: hit
        anchors.fill: parent
        anchors.topMargin: root.edge === "bottom" ? root.topLine : 0
        anchors.bottomMargin: root.edge === "top" ? root.topLine : 0
        anchors.leftMargin: root.edge === "right" ? root.topLine : 0
        anchors.rightMargin: root.edge === "left" ? root.topLine : 0
    }

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            pathHints: ShapePath.PathSolid | ShapePath.PathNonIntersecting
            fillColor: root.colour
            strokeWidth: -1
            strokeColor: "transparent"

            PathSvg {
                path: root.outlinePath
            }
        }
    }

    Item {
        id: sessionSlot
        readonly property bool hovered: sessionHover.hovered
        width: root.horizontal ? root.lenOf(sessionButton) + root.leftTrim : 40
        height: root.horizontal ? 40 : root.lenOf(sessionButton) + root.leftTrim
        x: root.px(root.mSessionClosed, sessionSlot)
        y: root.py(root.mSessionClosed, sessionSlot)

        HoverHandler {
            id: sessionHover
        }
    }

    Item {
        id: startSlot
        readonly property bool hovered: startHover.hovered
        width: 40
        height: 40
        x: root.px(root.mStartSlot, startSlot)
        y: root.py(root.mStartSlot, startSlot)

        HoverHandler {
            id: startHover
        }
    }

    Item {
        id: nightSlot
        readonly property bool hovered: nightHover.hovered
        width: 40
        height: 40
        x: root.px(root.mNightSlot, nightSlot)
        y: root.py(root.mNightSlot, nightSlot)

        HoverHandler {
            id: nightHover
        }
    }

    Item {
        id: mediaSlot
        readonly property bool hovered: mediaHover.hovered
        width: root.horizontal ? mediaButton.width : 40
        height: root.horizontal ? 40 : mediaButton.height
        x: root.px(root.mMediaSlot, mediaSlot)
        y: root.py(root.mMediaSlot, mediaSlot)

        HoverHandler {
            id: mediaHover
        }
    }

    Item {
        id: dateSlot
        readonly property bool hovered: dateHover.hovered
        width: root.horizontal ? datetime.width : 40
        height: root.horizontal ? 40 : datetime.height
        x: root.px(root.mDateSlot, dateSlot)
        y: root.py(root.mDateSlot, dateSlot)

        HoverHandler {
            id: dateHover
        }
    }

    Item {
        id: powerSlot
        readonly property bool hovered: powerHover.hovered
        width: 40
        height: 40
        x: root.px(root.mPowerSlot, powerSlot)
        y: root.py(root.mPowerSlot, powerSlot)

        HoverHandler {
            id: powerHover
        }
    }

    Item {
        id: appSlot
        width: 40
        height: 40
        x: root.px(root.mApps + root.appOffset, appSlot)
        y: root.py(root.mApps + root.appOffset, appSlot)
    }

    SessionButton {
        id: sessionButton
        vertical: !root.horizontal
        open: root.notchOpen && root.target === sessionButton
        x: root.px(root.mSessionSlot, sessionButton)
        y: root.py(root.mSessionSlot, sessionButton)
    }

    Workspace {
        id: workspace
        screen: root.screen
        vertical: !root.horizontal
        x: root.px(root.mWorkspace, workspace)
        y: root.py(root.mWorkspace, workspace)
    }

    StartButton {
        id: startMenu
        open: root.notchOpen && root.target === startMenu
        x: root.px(root.mStart, startMenu)
        y: root.py(root.mStart, startMenu)
    }

    NightModeButton {
        id: nightMode
        x: root.px(root.mNight, nightMode)
        y: root.py(root.mNight, nightMode)
    }

    MediaButton {
        id: mediaButton
        vertical: !root.horizontal
        open: root.notchOpen && root.target === mediaButton
        x: root.px(root.mMedia, mediaButton)
        y: root.py(root.mMedia, mediaButton)
    }

    OpenedApp {
        id: openedApp
        vertical: !root.horizontal
        notched: root.notchOpen && root.target === appSlot
        pushAmount: root.notchPadding + 2
        x: root.px(root.mApps, openedApp)
        y: root.py(root.mApps, openedApp)
    }

    Battery {
        id: battery
        vertical: !root.horizontal
        x: root.px(root.mBattery, battery)
        y: root.py(root.mBattery, battery)
    }

    DateTime {
        id: datetime
        vertical: !root.horizontal
        x: root.px(root.mDate, datetime)
        y: root.py(root.mDate, datetime)
    }

    Controls {
        id: controls
        vertical: !root.horizontal
        x: root.px(root.mControls, controls)
        y: root.py(root.mControls, controls)
    }

    RecordingIndicator {
        id: recordingIndicator
        vertical: !root.horizontal
        x: root.px(root.mRec, recordingIndicator)
        y: root.py(root.mRec, recordingIndicator)
    }

    DailyWarButton {
        id: dailyWar
        open: root.notchOpen && root.target === dailyWar
        x: root.px(root.mWar, dailyWar)
        y: root.py(root.mWar, dailyWar)
    }

    PowerProfileButton {
        id: powerProfile
        x: root.px(root.mPower, powerProfile)
        y: root.py(root.mPower, powerProfile)
    }

    PopupHost {
        id: host
        shown: root.popupShown
        content: root.activeContent
        gap: root.popupGap
        edge: root.edge
        centerM: (root.l2 + root.l3) / 2
        attach: root.attach

        Loader {
            id: warLoader
            readonly property Item owner: dailyWar
            anchors.centerIn: parent
            active: root.notchOpen && root.target === owner
            sourceComponent: DailyWarPopup {
                active: true
            }
        }

        Loader {
            id: controlsLoader
            readonly property Item owner: controls
            anchors.centerIn: parent
            active: root.notchOpen && root.target === owner
            sourceComponent: ControlsPopup {
                pill: controls
                active: true
            }
        }

        Loader {
            id: powerLoader
            readonly property Item owner: powerProfile
            anchors.centerIn: parent
            active: root.notchOpen && root.target === owner
            sourceComponent: PowerProfilePopup {
                active: true
            }
        }

        Loader {
            id: calendarLoader
            readonly property Item owner: datetime
            anchors.centerIn: parent
            active: root.notchOpen && root.target === owner
            sourceComponent: CalendarPopup {
                active: true
            }
        }

        Loader {
            id: previewLoader
            readonly property Item owner: appSlot
            anchors.centerIn: parent
            active: root.notchOpen && root.target === owner
            sourceComponent: WindowPreviewPopup {
                active: true
                group: openedApp.hoverGroup
                maxWidth: root.horizontal ? root.width - 2 * host.edgeMargin - host.pad * 2 : (root.parent ? root.parent.width : 1920) - root.thickness - (root.floating ? BarConfig.dockMargin : 0) - root.popupGap - 2 * host.edgeMargin - host.pad * 2
            }
        }

        Loader {
            id: nightLoader
            readonly property Item owner: nightMode
            anchors.centerIn: parent
            active: root.notchOpen && root.target === owner
            sourceComponent: NightModePopup {
                active: true
            }
        }

        Loader {
            id: mediaLoader
            readonly property Item owner: mediaButton
            anchors.centerIn: parent
            active: root.notchOpen && root.target === owner
            sourceComponent: MediaPopup {
                active: true
            }
        }

        Loader {
            id: startLoader
            readonly property Item owner: startMenu
            x: host.pad
            y: root.edge === "top" ? host.pad : parent.height - height - host.pad
            active: root.notchOpen && root.target === owner
            sourceComponent: StartMenuPopup {
                active: true
            }
        }
    }
}
