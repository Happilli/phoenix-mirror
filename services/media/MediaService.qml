pragma ComponentBehavior: Bound
pragma Singleton
import QtQuick
import QtQml
import Quickshell
import Quickshell.Services.Mpris
import Ryu.Cleave
import qs.services.state
import qs.services.controls

Singleton {
    id: root

    property MprisPlayer player: null

    readonly property bool hasPlayer: player !== null
    readonly property bool isPlaying: player?.isPlaying ?? false
    readonly property string title: player?.trackTitle || "Nothing playing"
    readonly property string artist: player?.trackArtist ?? ""
    readonly property string album: player?.trackAlbum ?? ""
    readonly property string artUrl: player?.trackArtUrl ?? ""
    readonly property string identity: player?.identity ?? ""

    function toggleVisualizer() {
        visualizerEnabled = !visualizerEnabled;
        StateService.set("visualizer", visualizerEnabled);
    }
    readonly property string visualizerSource: {
        const n = AudioService.sink?.name ?? "";
        return n !== "" ? n + ".monitor" : "";
    }

    readonly property int bandCount: 32
    property var spectrum: new Array(bandCount).fill(0)
    property real ref: 0.01
    property int clients: 0
    property bool decaying: false
    property bool visualizerEnabled: StateService.get("visualizer", true)
    readonly property bool capturing: visualizerEnabled && clients > 0 && isPlaying && visualizerSource !== ""

    onCapturingChanged: {
        if (capturing) {
            decaying = true;
            cleave.startCapture();
        } else {
            cleave.stopCapture();
        }
    }

    function acquire() {
        clients++;
    }

    function release() {
        clients = Math.max(0, clients - 1);
    }

    function pick() {
        let playing = null;
        let current = null;
        let first = null;
        for (let i = 0; i < tracker.count; i++) {
            const p = (tracker.objectAt(i) as Tracked)?.modelData ?? null;
            if (!p) {
                continue;
            }
            first = first ?? p;
            if (p.isPlaying) {
                playing = p;
                break;
            }
            if (p === root.player) {
                current = p;
            }
        }
        root.player = playing ?? current ?? first;
    }

    function formatTime(seconds) {
        if (!seconds || seconds < 0)
            return "0:00";
        const m = Math.floor(seconds / 60);
        const s = Math.floor(seconds % 60);
        return m + ":" + (s < 10 ? "0" : "") + s;
    }

    function togglePlaying() {
        if (player?.canTogglePlaying)
            player.togglePlaying();
    }

    function next() {
        if (player?.canGoNext)
            player.next();
    }

    function previous() {
        if (player?.canGoPrevious)
            player.previous();
    }

    component Tracked: QtObject {
        required property MprisPlayer modelData
        readonly property bool playing: modelData?.isPlaying ?? false

        onPlayingChanged: root.pick()
    }

    Instantiator {
        id: tracker
        model: Mpris.players
        delegate: Tracked {}
        onObjectAdded: root.pick()
        onObjectRemoved: Qt.callLater(root.pick)
    }

    Cleave {
        id: cleave
        bandCount: 64
        smoothing: 0.3
        peakDecay: 0.006
        silenceThreshold: 0.0001
        source: root.visualizerSource
        debugMode: false
        onError: msg => console.warn("[MediaService]", msg)
    }

    FrameAnimation {
        running: root.capturing || root.decaying
        onTriggered: {
            const raw = root.capturing ? cleave.magnitudes : null;
            const n = raw ? raw.length : 0;

            let peak = 0;
            for (let k = 0; k < n; k++)
                peak = Math.max(peak, raw[k] || 0);
            root.ref = peak > root.ref ? root.ref + (peak - root.ref) * 0.3 : Math.max(0.01, root.ref * 0.997);

            const count = root.bandCount;
            const targets = new Array(count).fill(0);
            if (n > 1) {
                for (let i = 0; i < count; i++) {
                    const pos = i / (count - 1) * (n - 1);
                    const lo = Math.floor(pos);
                    const hi = Math.min(n - 1, lo + 1);
                    const f = pos - lo;
                    const m = (raw[lo] || 0) * (1 - f) + (raw[hi] || 0) * f;
                    targets[i] = Math.pow(Math.min(1, m / root.ref), 0.7);
                }
            }

            const next = new Array(count);
            let maxLevel = 0;
            for (let i = 0; i < count; i++) {
                const a = targets[Math.max(0, i - 1)];
                const b = targets[i];
                const c = targets[Math.min(count - 1, i + 1)];
                const target = a * 0.25 + b * 0.5 + c * 0.25;
                const prev = root.spectrum[i] ?? 0;
                const rate = target > prev ? 0.4 : 0.12;
                const v = prev + (target - prev) * rate;
                next[i] = v;
                maxLevel = Math.max(maxLevel, v);
            }
            root.spectrum = next;

            if (!root.capturing && maxLevel < 0.002) {
                root.spectrum = new Array(count).fill(0);
                root.ref = 0.01;
                root.decaying = false;
            }
        }
    }
}
