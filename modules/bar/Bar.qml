pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Shapes
import qs.configuration.Bar

Item {
    id: root

    property real radius
    property color colour
    property var screen
    readonly property Item popupS: host

    readonly property string edge: BarConfig.edge
    readonly property bool horizontal: edge === "top" || edge === "bottom"
    readonly property bool lowFlat: edge === "bottom" || edge === "right"
    readonly property real length: horizontal ? width : height
    readonly property real thickness: horizontal ? height : width
    readonly property real cc: lowFlat ? thickness / 2 + radius / 2 : thickness / 2 - radius / 2
    readonly property real attach: lowFlat ? radius : thickness - radius

    readonly property real notchPadding: 4
    readonly property real notchRadius: 18
    readonly property real notchRadiusBottom: 30
    readonly property real itemGap: 8
    readonly property real tightGap: 0
    readonly property real slideShift: 6
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
        if (nightMode.hovered)
            return nightMode;
        if (startMenu.hovered)
            return startMenu;
        if (mediaButton.hovered)
            return mediaButton;
        if (nightSlot.hovered)
            return nightMode;
        if (startSlot.hovered)
            return startMenu;
        if (mediaSlot.hovered)
            return mediaButton;
        if (host.hovered)
            return target;
        return null;
    }
    property Item target: controls
    property bool notchOpen: false

    readonly property int groupIndex: {
        if (!notchOpen)
            return -1;
        if (target === startMenu)
            return 0;
        if (target === nightMode)
            return 1;
        if (target === mediaButton)
            return 2;
        return -1;
    }

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

    property real pairOffset: (notchOpen && (target === powerProfile || target === dailyWar)) ? slideShift : 0
    Behavior on pairOffset {
        NumberAnimation {
            duration: 180
            easing.type: Easing.OutCubic
        }
    }

    property real startOffset: groupShift(0)
    Behavior on startOffset {
        NumberAnimation {
            duration: 180
            easing.type: Easing.OutCubic
        }
    }

    property real nightOffset: groupShift(1)
    Behavior on nightOffset {
        NumberAnimation {
            duration: 180
            easing.type: Easing.OutCubic
        }
    }

    property real mediaOffset: groupShift(2)
    Behavior on mediaOffset {
        NumberAnimation {
            duration: 180
            easing.type: Easing.OutCubic
        }
    }

    readonly property real mWorkspace: itemGap + notchPadding
    readonly property real mStartSlot: mWorkspace + lenOf(workspace) + itemGap
    readonly property real mNightSlot: mStartSlot + lenOf(startMenu) + tightGap
    readonly property real mMediaSlot: mNightSlot + lenOf(nightMode) + tightGap
    readonly property real mStart: mStartSlot + startOffset
    readonly property real mNight: mNightSlot + nightOffset
    readonly property real mMedia: mMediaSlot + mediaOffset
    readonly property real mApps: mMediaSlot + lenOf(mediaButton) + itemGap

    readonly property real mBattery: length - (radius + notchPadding + notchRadius - 10) - lenOf(battery)
    readonly property real mDateSlot: mBattery - itemGap - lenOf(datetime)
    readonly property real mDate: mDateSlot - dateOffset
    readonly property real mControls: mDateSlot - itemGap - dateOffset - lenOf(controls)
    readonly property real mWar: mControls - itemGap - lenOf(dailyWar)
    readonly property real mPowerSlot: mWar - tightGap - lenOf(powerProfile)
    readonly property real mPower: mPowerSlot - pairOffset
    readonly property real mRec: mPower - 16 - recOffset - lenOf(recordingIndicator)

    readonly property real targetM: {
        if (target === datetime)
            return mDateSlot - dateShift;
        if (target === controls)
            return mDateSlot - itemGap - lenOf(controls);
        if (target === dailyWar)
            return mDateSlot - itemGap - lenOf(controls) - itemGap - lenOf(dailyWar);
        if (target === powerProfile)
            return mDateSlot - itemGap - lenOf(controls) - itemGap - lenOf(dailyWar) - tightGap - lenOf(powerProfile) - slideShift;
        if (target === startMenu)
            return mStartSlot;
        if (target === nightMode)
            return mNightSlot;
        if (target === mediaButton)
            return mMediaSlot;
        return along(target);
    }

    property real notchProgress: notchOpen ? 1 : 0
    Behavior on notchProgress {
        SpringAnimation {
            spring: 4
            damping: 0.25
            epsilon: 0.25
        }
    }
    property real appOffset: openedApp.lastM
    Behavior on appOffset {
        enabled: root.notchOpen && root.target === appSlot
        SpringAnimation {
            spring: 3
            damping: 0.4
            epsilon: 0.25
        }
    }

    readonly property real spanL: targetM - notchPadding
    readonly property real spanR: targetM + lenOf(target) + notchPadding

    property bool lagAnimated: true
    property real lagL: 0
    property real lagR: 0

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

    readonly property real l2: spanL + lagL
    readonly property real l3: spanR + lagR

    readonly property real crossSize: horizontal ? controls.height : controls.width
    readonly property real fullFloorY: Math.min(thickness / 2 + radius / 2 + crossSize / 2 + notchPadding, thickness)
    readonly property real permanentDepth: Math.max(0, fullFloorY - radius)
    readonly property real depth: permanentDepth * notchProgress

    function outline() {
        const R = radius;
        const W = length;
        const H = thickness;
        const cuts = [];
        for (const item of permanent) {
            const k = item.cutProgress ?? 1;
            if (permanentDepth * k < 0.5) {
                continue;
            }
            const s = along(item);
            cuts.push({
                l: s - notchPadding,
                r: s + lenOf(item) + notchPadding,
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

        let p = `M ${pt(0, H)} L ${pt(0, 0)} Q ${pt(0, R)} ${pt(R, R)}`;
        for (const c of cuts) {
            const f = R + c.d;
            const rt = Math.min(notchRadius, c.d / 2);
            const rb = Math.min(notchRadiusBottom, (c.r - c.l) / 2, Math.max(0, c.d - rt));
            p += ` L ${pt(c.l - rt, R)} Q ${pt(c.l, R)} ${pt(c.l, R + rt)}`;
            p += ` L ${pt(c.l, f - rb)} Q ${pt(c.l, f)} ${pt(c.l + rb, f)}`;
            p += ` L ${pt(c.r - rb, f)} Q ${pt(c.r, f)} ${pt(c.r, f - rb)}`;
            p += ` L ${pt(c.r, R + rt)} Q ${pt(c.r, R)} ${pt(c.r + rt, R)}`;
        }
        p += ` L ${pt(W - R, R)} Q ${pt(W, R)} ${pt(W, 0)} L ${pt(W, H)} Z`;
        return p;
    }

    readonly property string outlinePath: outline()

    onHoveredItemChanged: {
        if (hoveredItem) {
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
        } else {
            closeTimer.restart();
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
    }

    Item {
        id: startSlot
        width: 40
        height: 40
        x: root.px(root.mStartSlot, startSlot)
        y: root.py(root.mStartSlot, startSlot)

        readonly property bool hovered: startHover.hovered

        HoverHandler {
            id: startHover
        }
    }
    Item {
        id: nightSlot
        width: 40
        height: 40
        x: root.px(root.mNightSlot, nightSlot)
        y: root.py(root.mNightSlot, nightSlot)

        readonly property bool hovered: nightHover.hovered

        HoverHandler {
            id: nightHover
        }
    }
    Item {
        id: mediaSlot
        width: root.horizontal ? mediaButton.width : 40
        height: root.horizontal ? 40 : mediaButton.height
        x: root.px(root.mMediaSlot, mediaSlot)
        y: root.py(root.mMediaSlot, mediaSlot)

        readonly property bool hovered: mediaHover.hovered

        HoverHandler {
            id: mediaHover
        }
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
    Item {
        id: appSlot
        width: 40
        height: 40
        x: root.px(root.mApps + root.appOffset, appSlot)
        y: root.py(root.mApps + root.appOffset, appSlot)
    }
    Battery {
        id: battery
        vertical: !root.horizontal
        x: root.px(root.mBattery, battery)
        y: root.py(root.mBattery, battery)
    }
    Item {
        id: dateSlot
        width: root.horizontal ? datetime.width : 40
        height: root.horizontal ? 40 : datetime.height
        x: root.px(root.mDateSlot, dateSlot)
        y: root.py(root.mDateSlot, dateSlot)

        readonly property bool hovered: dateHover.hovered

        HoverHandler {
            id: dateHover
        }
    }
    Item {
        id: powerSlot
        width: 40
        height: 40
        x: root.px(root.mPowerSlot, powerSlot)
        y: root.py(root.mPowerSlot, powerSlot)

        readonly property bool hovered: powerHover.hovered

        HoverHandler {
            id: powerHover
        }
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
                maxWidth: root.horizontal ? root.width - 2 * host.edgeMargin - host.pad * 2 : (root.parent ? root.parent.width : 1920) - root.thickness - root.popupGap - 2 * host.edgeMargin - host.pad * 2
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
            x: host.pad
            y: root.edge === "top" ? host.pad : parent.height - height - host.pad
            active: root.notchOpen && root.target === startMenu
            sourceComponent: StartMenuPopup {
                active: true
            }
        }
    }
}
