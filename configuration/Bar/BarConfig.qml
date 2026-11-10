pragma Singleton

import QtQuick
import px.services.state

QtObject {
    id: root

    readonly property var edges: ["top", "bottom", "left", "right"]
    readonly property var labels: ["Top", "Bottom", "Left", "Right"]
    readonly property var styles: ["horizon", "floating"]
    readonly property var styleLabels: ["Horizon", "Floating"]
    readonly property int minContent: 40
    readonly property int minFloatThickness: 45
    readonly property int maxThickness: 140
    readonly property int maxHorizonRadius: 30

    property string edge: StateService.get("barEdge", "bottom")
    property string style: StateService.get("barStyle", "horizon")
    property int thicknessHorizon: StateService.get("barThicknessHorizon", 60)
    property int radiusHorizon: StateService.get("barRadiusHorizon", 15)
    property int thicknessFloating: StateService.get("barThicknessFloating", StateService.get("barThickness", 60))
    property int radiusFloating: StateService.get("barRadiusFloating", StateService.get("barRadius", 15))
    property int marginLeft: StateService.get("barMarginLeft", StateService.get("barMargin", 10))
    property int marginRight: StateService.get("barMarginRight", StateService.get("barMargin", 10))
    property int marginTop: StateService.get("barMarginTop", StateService.get("barMargin", 10))
    property int marginBottom: StateService.get("barMarginBottom", StateService.get("barMargin", 10))

    readonly property bool horizontal: edge === "top" || edge === "bottom"
    readonly property bool floating: style === "floating"
    readonly property int edgeIndex: Math.max(0, edges.indexOf(edge))
    readonly property int styleIndex: Math.max(0, styles.indexOf(style))
    readonly property int horizonRadius: Math.max(0, Math.min(maxHorizonRadius, radiusHorizon))
    readonly property int horizonThickness: Math.min(maxThickness, Math.max(thicknessHorizon, horizonRadius + minContent))
    readonly property int floatThickness: Math.max(minFloatThickness, Math.min(maxThickness, thicknessFloating))
    readonly property int floatRadius: Math.max(0, Math.min(Math.floor(floatThickness / 2), radiusFloating))
    readonly property int thickness: floating ? floatThickness : horizonThickness
    readonly property int radius: floating ? floatRadius : horizonRadius
    readonly property int maxRadius: floating ? Math.floor(floatThickness / 2) : Math.max(0, Math.min(maxHorizonRadius, horizonThickness - minContent))
    readonly property int minThickness: floating ? minFloatThickness : horizonRadius + minContent
    readonly property string opposite: edge === "top" ? "bottom" : edge === "bottom" ? "top" : edge === "left" ? "right" : "left"
    readonly property int dockMargin: marginOf(edge)

    function marginOf(side) {
        switch (side) {
        case "left":
            return marginLeft;
        case "right":
            return marginRight;
        case "top":
            return marginTop;
        }
        return marginBottom;
    }

    function setMargin(side, v) {
        const m = Math.max(0, Math.min(120, Math.round(v)));
        switch (side) {
        case "left":
            marginLeft = m;
            StateService.set("barMarginLeft", m);
            break;
        case "right":
            marginRight = m;
            StateService.set("barMarginRight", m);
            break;
        case "top":
            marginTop = m;
            StateService.set("barMarginTop", m);
            break;
        case "bottom":
            marginBottom = m;
            StateService.set("barMarginBottom", m);
            break;
        }
    }

    function setEdge(e) {
        if (edges.indexOf(e) < 0 || e === edge)
            return;
        edge = e;
        StateService.set("barEdge", e);
    }

    function setStyle(s) {
        if (styles.indexOf(s) < 0 || s === style)
            return;
        style = s;
        StateService.set("barStyle", s);
    }

    function setThickness(v) {
        const t = Math.max(minThickness, Math.min(maxThickness, Math.round(v)));
        if (floating) {
            thicknessFloating = t;
            StateService.set("barThicknessFloating", t);
        } else {
            thicknessHorizon = t;
            StateService.set("barThicknessHorizon", t);
        }
    }

    function setRadius(v) {
        const r = Math.max(0, Math.min(maxRadius, Math.round(v)));
        if (floating) {
            radiusFloating = r;
            StateService.set("barRadiusFloating", r);
        } else {
            radiusHorizon = r;
            StateService.set("barRadiusHorizon", r);
        }
    }
}
