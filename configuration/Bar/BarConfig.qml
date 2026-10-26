pragma Singleton
import QtQuick
import Quickshell
import qs.services.state

Singleton {
    id: root

    readonly property var edges: ["top", "bottom", "left", "right"]
    readonly property var labels: ["Top", "Bottom", "Left", "Right"]
    readonly property int minContent: 46

    property string edge: StateService.get("barEdge", "bottom")
    property int thickness: StateService.get("barThickness", 60)
    property int radius: StateService.get("barRadius", 15)

    readonly property bool horizontal: edge === "top" || edge === "bottom"
    readonly property int edgeIndex: Math.max(0, edges.indexOf(edge))

    function setEdge(e) {
        if (edges.indexOf(e) < 0 || e === edge)
            return;
        edge = e;
        StateService.set("barEdge", e);
    }

    function setThickness(v) {
        const t = Math.max(radius + minContent, Math.min(140, Math.round(v)));
        thickness = t;
        StateService.set("barThickness", t);
    }

    function setRadius(v) {
        const r = Math.max(0, Math.min(thickness - minContent, Math.round(v)));
        radius = r;
        StateService.set("barRadius", r);
    }
}
