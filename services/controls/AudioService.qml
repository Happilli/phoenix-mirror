pragma Singleton
import QtQuick
import Ryu.Audio

QtObject {
    id: root

    readonly property real curve: 0.6

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource

    readonly property PwObjectTracker tracker: PwObjectTracker {
        objects: [root.sink, root.source]
    }

    readonly property real volume: Math.pow(sink?.audio?.volume ?? 1, 1 / curve)
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property real micVolume: source?.audio?.volume ?? 1
    readonly property bool micMuted: source?.audio?.muted ?? false

    function clamp(v) {
        return Math.max(0, Math.min(1, v));
    }

    function setVolume(v) {
        if (sink?.audio) {
            const c = clamp(v);
            sink.audio.volume = Math.pow(c, curve);
            if (sink.audio.muted && c > 0) {
                sink.audio.muted = false;
            }
        }
    }

    function setMicVolume(v) {
        if (!source?.audio) {
            return;
        }
        const next = clamp(v);
        source.audio.volume = next;
        source.audio.muted = next <= 0;
    }

    function toggleMute() {
        if (sink?.audio) {
            sink.audio.muted = !sink.audio.muted;
        }
    }

    function toggleMicMute() {
        if (source?.audio) {
            source.audio.muted = !source.audio.muted;
        }
    }
}
