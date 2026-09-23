import QtQuick
import QtQuick.Shapes

Item {
    id: root
    property real radius
    property color colour
    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            pathHints: ShapePath.PathSolid | ShapePath.PathNonIntersecting
            fillColor: root.colour
            strokeWidth: 0
            startX: 0
            startY: 0
            PathArc {
                x: root.radius
                y: Math.min(root.radius, root.height / 2)
                radiusX: root.radius
                radiusY: Math.min(root.radius, root.height / 2)
            }
            PathLine {
                x: root.radius
                y: Math.max(root.height - root.radius, root.height / 2)
            }
            PathArc {
                x: root.radius * 2
                y: root.height
                radiusX: root.radius
                radiusY: Math.min(root.radius, root.height / 2)
                direction: PathArc.Counterclockwise
            }
            PathLine {
                x: root.width - root.radius * 2
                y: root.height
            }
            PathArc {
                x: root.width - root.radius
                y: Math.max(root.height - root.radius, root.height / 2)
                radiusX: root.radius
                radiusY: Math.min(root.radius, root.height / 2)
                direction: PathArc.Counterclockwise
            }
            PathLine {
                x: root.width - root.radius
                y: Math.min(root.radius, root.height / 2)
            }
            PathArc {
                x: root.width
                y: 0
                radiusX: root.radius
                radiusY: Math.min(root.radius, root.height / 2)
            }
        }
    }
}
