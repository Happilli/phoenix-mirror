pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property var sensorNames: ["coretemp", "k10temp", "zenpower", "cpu_thermal"]

    property int clients: 0
    readonly property bool running: clients > 0

    property real cpu: 0
    property real ramUsed: 0
    property real ramTotal: 0
    property real temp: 0
    property real diskUsed: 0
    property real diskTotal: 0
    property string tempPath: ""

    readonly property real ram: ramTotal > 0 ? ramUsed / ramTotal : 0
    readonly property real disk: diskTotal > 0 ? diskUsed / diskTotal : 0

    property real prevTotal: 0
    property real prevIdle: 0

    function acquire() {
        clients++;
    }

    function release() {
        clients = Math.max(0, clients - 1);
    }

    function readCpu(raw) {
        const p = raw.split("\n")[0].trim().split(/\s+/).slice(1, 9).map(Number);
        if (p.length < 8)
            return;
        const idle = p[3] + p[4];
        const total = p.reduce((a, b) => a + b, 0);
        if (prevTotal > 0 && total > prevTotal)
            cpu = Math.max(0, Math.min(1, 1 - (idle - prevIdle) / (total - prevTotal)));
        prevTotal = total;
        prevIdle = idle;
    }

    function readMem(raw) {
        const t = /MemTotal:\s+(\d+)/.exec(raw);
        const a = /MemAvailable:\s+(\d+)/.exec(raw);
        if (!t || !a)
            return;
        ramTotal = Number(t[1]) / 1048576;
        ramUsed = (Number(t[1]) - Number(a[1])) / 1048576;
    }

    function readDisk(raw) {
        const parts = raw.trim().split("\n")[1]?.trim().split(/\s+/);
        if (!parts || parts.length < 3)
            return;
        diskTotal = Number(parts[1]) / 1073741824;
        diskUsed = Number(parts[2]) / 1073741824;
    }

    onRunningChanged: if (!running) {
        prevTotal = 0;
        prevIdle = 0;
    }

    Instantiator {
        model: 16

        delegate: FileView {
            required property int index

            path: "/sys/class/hwmon/hwmon" + index + "/name"
            blockLoading: true
            onLoaded: {
                if (root.tempPath === "" && root.sensorNames.includes(text().trim()))
                    root.tempPath = "/sys/class/hwmon/hwmon" + index + "/temp1_input";
            }
        }
    }

    FileView {
        id: cpuFile
        path: "/proc/stat"
        onLoaded: root.readCpu(text())
    }

    FileView {
        id: memFile
        path: "/proc/meminfo"
        onLoaded: root.readMem(text())
    }

    FileView {
        id: tempFile
        path: root.tempPath
        onLoaded: root.temp = Number(text()) / 1000
    }

    Timer {
        interval: 1000
        repeat: true
        running: root.running
        triggeredOnStart: true
        onTriggered: {
            cpuFile.reload();
            memFile.reload();
            tempFile.reload();
        }
    }

    Timer {
        interval: 5000
        repeat: true
        running: root.running
        triggeredOnStart: true
        onTriggered: if (!disk.running)
            disk.running = true
    }

    Process {
        id: disk
        command: ["df", "-P", "-B1", "/"]
        stdout: StdioCollector {
            onStreamFinished: root.readDisk(text)
        }
    }
}
