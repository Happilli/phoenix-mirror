pragma Singleton
import QtQuick
import Quickshell
import Ryu.Io
import qs.services.paths

Singleton {
    id: root

    property string date: ""
    property var challenge: null
    property var language: null
    property bool loaded: false

    function labelOf(v) {
        if (v === null || v === undefined)
            return "";
        if (typeof v === "string")
            return v;
        return v.title ?? v.name ?? v.label ?? JSON.stringify(v);
    }

    function detailOf(v) {
        if (v && typeof v === "object")
            return v.description ?? v.desc ?? v.summary ?? "";
        return "";
    }

    readonly property string difficulty: {
        const d = (challenge && typeof challenge === "object") ? challenge.difficulty : null;
        return typeof d === "string" ? d : "";
    }
    readonly property string challengeTitle: labelOf(challenge)
    readonly property string challengeDetail: detailOf(challenge)
    readonly property string languageName: labelOf(language)

    Timer {
        id: reloadTimer
        interval: 100
        onTriggered: file.reload()
    }

    FileView {
        id: file
        path: PathService.home + "/.cache/todaywarpick.json"
        watchChanges: true
        onFileChanged: reloadTimer.restart()
        onLoadFailed: err => root.loaded = false
        onLoaded: {
            const raw = text();
            if (raw.trim() === "")
                return;
            try {
                const d = JSON.parse(raw);
                root.date = d.date ?? "";
                root.challenge = d.challenge ?? null;
                root.language = d.language ?? null;
                root.loaded = true;
            } catch (e) {
                console.log("dailywar parse error: ", e);
            }
        }
    }
}
