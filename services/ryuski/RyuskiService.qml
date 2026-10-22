pragma Singleton
import QtQuick
import Quickshell
import Ryuski

Singleton {
    id: root

    readonly property bool ready: bot.ready
    readonly property bool busy: bot.busy
    readonly property bool speaking: bot.speaking
    readonly property string notice: bot.notice

    signal replied(string text, bool ok)

    function submit(line) {
        bot.submit(line);
    }

    function warm() {
        bot.warm();
    }

    function cool() {
        bot.cool();
    }

    Assistant {
        id: bot
        onReplied: (text, ok) => root.replied(text, ok)
    }
}
