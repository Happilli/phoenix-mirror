pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import qs.services.theme
import qs.configuration.Bar

Loader {
    id: root

    property string kind: "soft"
    property real radius: 0
    property color base: Theme.background
    property string path: ""
    property real strokeWidth: 0
    property color strokeColor: "transparent"
    property bool gradientY: true
    property real extent: 0
    property real hubSize: 0
    property bool bloom: true

    active: kind === "shape" || kind === "wheel" || BarConfig.metallic
    sourceComponent: {
        switch (kind) {
        case "backdrop":
            return backdrop;
        case "gloss":
            return gloss;
        case "inset":
            return inset;
        case "rim":
            return rim;
        case "innerRim":
            return innerRim;
        case "shape":
            return BarConfig.metallic ? shapeMetal : shapeFlat;
        case "wheel":
            return BarConfig.metallic ? wheelMetal : wheelFlat;
        case "hub":
            return hub;
        }
        return soft;
    }

    Component {
        id: backdrop
        Rectangle {
            radius: root.radius
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: Qt.tint(root.base, Qt.alpha(Theme.onBackgroundColor, 0.14))
                }
                GradientStop {
                    position: 0.45
                    color: root.base
                }
                GradientStop {
                    position: 1.0
                    color: Qt.darker(root.base, 1.5)
                }
            }
        }
    }

    Component {
        id: gloss
        Rectangle {
            radius: root.radius
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: Qt.rgba(1, 1, 1, 0.32)
                }
                GradientStop {
                    position: 0.5
                    color: Qt.rgba(1, 1, 1, 0)
                }
                GradientStop {
                    position: 1.0
                    color: Qt.rgba(0, 0, 0, 0.32)
                }
            }
        }
    }

    Component {
        id: soft
        Rectangle {
            radius: root.radius
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: Qt.rgba(1, 1, 1, 0.12)
                }
                GradientStop {
                    position: 0.5
                    color: Qt.rgba(1, 1, 1, 0)
                }
                GradientStop {
                    position: 1.0
                    color: Qt.rgba(0, 0, 0, 0.3)
                }
            }
        }
    }

    Component {
        id: inset
        Rectangle {
            radius: root.radius
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: Qt.rgba(0, 0, 0, 0.28)
                }
                GradientStop {
                    position: 0.5
                    color: Qt.rgba(0, 0, 0, 0)
                }
                GradientStop {
                    position: 1.0
                    color: Qt.rgba(1, 1, 1, 0.08)
                }
            }
        }
    }

    Component {
        id: rim
        Rectangle {
            radius: root.radius
            color: "transparent"
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.16)
        }
    }

    Component {
        id: innerRim
        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: Math.max(0, root.radius - 1)
            color: "transparent"
            border.width: 1
            border.color: Qt.alpha(Theme.onBackgroundColor, 0.12)
        }
    }

    Component {
        id: shapeFlat
        Shape {
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                pathHints: ShapePath.PathSolid | ShapePath.PathNonIntersecting
                fillColor: root.base
                strokeWidth: root.strokeWidth
                strokeColor: root.strokeColor

                PathSvg {
                    path: root.path
                }
            }
        }
    }

    Component {
        id: shapeMetal
        Shape {
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                pathHints: ShapePath.PathSolid | ShapePath.PathNonIntersecting
                fillColor: root.base
                strokeWidth: root.strokeWidth
                strokeColor: root.strokeColor

                fillGradient: LinearGradient {
                    x1: 0
                    y1: 0
                    x2: root.gradientY ? 0 : root.width
                    y2: root.gradientY ? root.height : 0

                    GradientStop {
                        position: 0.0
                        color: Qt.tint(root.base, Qt.alpha(Theme.onBackgroundColor, 0.14))
                    }
                    GradientStop {
                        position: 0.45
                        color: root.base
                    }
                    GradientStop {
                        position: 1.0
                        color: Qt.darker(root.base, 1.5)
                    }
                }

                PathSvg {
                    path: root.path
                }
            }
        }
    }

    Component {
        id: wheelFlat
        Shape {
            preferredRendererType: Shape.CurveRenderer
            ShapePath {
                fillRule: ShapePath.WindingFill
                fillColor: root.base
                strokeWidth: -1
                strokeColor: "transparent"

                PathSvg {
                    path: root.path
                }
            }
        }
    }

    Component {
        id: wheelMetal
        Shape {
            preferredRendererType: Shape.CurveRenderer

            layer.enabled: true
            layer.smooth: true
            layer.samples: 4
            layer.effect: MultiEffect {
                autoPaddingEnabled: false
                shadowEnabled: root.bloom
                shadowColor: root.base
                shadowBlur: 0.3
                shadowOpacity: 0.5
            }

            ShapePath {
                fillRule: ShapePath.WindingFill
                strokeWidth: -1
                strokeColor: "transparent"

                fillGradient: LinearGradient {
                    x1: root.extent * 0.18
                    y1: root.extent * 0.08
                    x2: root.extent * 0.82
                    y2: root.extent * 0.92

                    GradientStop {
                        position: 0.0
                        color: Qt.lighter(root.base, 1.55)
                    }
                    GradientStop {
                        position: 0.4
                        color: root.base
                    }
                    GradientStop {
                        position: 1.0
                        color: Qt.darker(root.base, 1.8)
                    }
                }

                PathSvg {
                    path: root.path
                }
            }
        }
    }

    Component {
        id: hub
        Shape {
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                strokeWidth: -1
                strokeColor: "transparent"

                fillGradient: RadialGradient {
                    centerX: root.hubSize / 2
                    centerY: root.hubSize / 2
                    centerRadius: root.hubSize / 2
                    focalX: root.hubSize * 0.36
                    focalY: root.hubSize * 0.3
                    focalRadius: 0

                    GradientStop {
                        position: 0.0
                        color: Qt.rgba(1, 1, 1, 0.38)
                    }
                    GradientStop {
                        position: 0.55
                        color: Qt.rgba(1, 1, 1, 0)
                    }
                    GradientStop {
                        position: 1.0
                        color: Qt.rgba(0, 0, 0, 0.35)
                    }
                }

                PathSvg {
                    path: root.path
                }
            }
        }
    }
}
