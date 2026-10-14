pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.services.paths
import qs.configuration.Screenshot

Singleton {
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
        const args = ["wl-screenrec", "-f", file].concat(targetArgs, audioArgs(audio));
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
        if (picking) {
            return "busy";
        }
        pendingAudio = audio;
        picking = ScreenshotConfig.captureRegionForRecording();
        return picking ? "select a region" : "busy";
    }

    Connections {
        target: ScreenshotConfig

        function onRegionPicked(screenName, rect) {
            if (!rect) {
                root.picking = false;
                return;
            }
            const s = Quickshell.screens.find(m => m.name === screenName);
            const gx = rect.x + (s ? s.x : 0);
            const gy = rect.y + (s ? s.y : 0);
            root.pendingTarget = ["-g", gx + "," + gy + " " + rect.w + "x" + rect.h];
            startDelay.restart();
        }

        function onFinished() {
            if (root.picking && !ScreenshotConfig.selecting && !startDelay.running) {
                root.picking = false;
            }
        }
    }

    Timer {
        id: startDelay
        interval: 150
        onTriggered: {
            root.begin(root.pendingTarget, root.pendingAudio);
            root.picking = false;
        }
    }

    Process {
        id: recorder
        onExited: code => {
            const saved = root.file;
            root.recording = false;
            Quickshell.execDetached(["notify-send", "-a", "Recorder", "Recording saved", saved]);
        }
    }
}
