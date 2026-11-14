pragma Singleton
import QtQuick
import Ryu.Io
import px.services.paths
import px.configuration.Screenshot

QtObject {
    id: root

    property bool recording: false
    property bool picking: false
    property string file: ""
    property string pendingAudio: ""
    property var pendingTarget: []
    property real startedAt: 0
    readonly property string dir: PathService.home + "/Videos/"

    function audioArgs(audio) {
        const a = (audio ?? "").trim();
        if (a === "" || a === "none" || a === "off") {
            return [];
        }
        return ["--audio", "--audio-device", a];
    }

    function begin(targetArgs, audio) {
        file = dir + "/recording_" + Qt.formatDateTime(new Date(), "yyyy-MM-dd_hh-mm-ss") + ".mp4";
        const args = ["wl-screenrec", "-f", file, "--low-power=off"].concat(targetArgs, audioArgs(audio));
        recorder.command = ["sh", "-c", 'mkdir -p "$1" && shift && exec "$@"', "sh", dir].concat(args);
        recorder.running = true;
        startedAt = Date.now();
        recording = true;
    }

    function stop() {
        if (recorder.running) {
            recorder.signal(2);
        }
    }

    function toggleScreen(audio) {
        if (recording) {
            stop();
            return "stopped";
        }
        if (picking || ScreenshotConfig.selecting || ScreenshotConfig.capturing) {
            return "busy";
        }
        const name = ScreenshotConfig.focusedName();
        begin(name !== "" ? ["-o", name] : [], audio);
        return "recording screen";
    }

    function toggleRegion(audio) {
        if (recording) {
            stop();
            return "stopped";
        }
        if (picking || ScreenshotConfig.selecting || ScreenshotConfig.capturing) {
            return "busy";
        }
        pendingAudio = audio;
        picking = true;
        if (!ScreenshotConfig.pickRegion()) {
            picking = false;
            return "busy";
        }
        return "select a region";
    }

    property Connections picker: Connections {
        target: ScreenshotConfig

        function onRegionPicked(name, rect) {
            if (!rect) {
                root.picking = false;
                return;
            }
            const s = Qt.application.screens.find(x => x.name === name);
            const ox = s ? s.virtualX : 0;
            const oy = s ? s.virtualY : 0;
            root.pendingTarget = ["-g", (ox + rect.x) + "," + (oy + rect.y) + " " + rect.w + "x" + rect.h];
            root.startDelay.restart();
        }
    }

    property Timer startDelay: Timer {
        interval: 150
        onTriggered: {
            root.begin(root.pendingTarget, root.pendingAudio);
            root.picking = false;
        }
    }

    property Process recorder: Process {
        onExited: code => {
            const saved = root.file;
            root.recording = false;
            Exec.detached(["notify-send", "-a", "Recorder", "Recording saved", saved]);
        }
        onFailed: message => root.recording = false
    }
}
