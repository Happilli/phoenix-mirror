pragma Singleton
import Quickshell
import QtQuick

QtObject {
    readonly property string home: Quickshell.env("HOME")
    readonly property url defaultWallpaper: home + "/Pictures/ann.jpeg".toString()
}
