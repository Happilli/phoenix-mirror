pragma Singleton
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource

    PwObjectTracker {
        objects: [root.sink, root.source]
    }

    readonly property real volume: sink?.audio?.volume ?? 1
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property real micVolume: source?.audio?.volume ?? 1
    readonly property bool micMuted: source?.audio?.muted ?? false

    function clamp(v) {
        return Math.max(0, Math.min(1, v));
    }
    function setVolume(v) {
        if (sink?.audio) {
            sink.audio.volume = clamp(v);
            if (sink.audio.muted && v > 0) {
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
