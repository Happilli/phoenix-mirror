import QtQuick
import Quickshell
import Ryu.Extraa
import qs.services.paths
import qs.services.theme

Item {
    id: root

    readonly property string monkeyTheme: PathService.home + "/.local/state/ryu/monkeytype.json"
    readonly property string refreshScript: Qt.resolvedUrl("../../scripts/refresh.sh").toString().replace("file://", "")

    function openMonkey() {
        Quickshell.execDetached(["sh", "-c", 'f="$1"; [ -f "$f" ] || exit 1; exec helium-browser --new-tab "https://monkeytype.com/?customTheme=$(base64 -w0 "$f")"', "sh", monkeyTheme]);
    }

    function refresh() {
        Quickshell.execDetached(["bash", refreshScript]);
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onPressed: mouse => {
            if (mouse.button === Qt.RightButton)
                menu.popup(mouse.x, mouse.y);
            else
                menu.close();
        }
    }

    MaterialMenu {
        id: menu
        color: Theme.background
        textColor: Theme.onSurfaceVariantColor
        shortcutColor: Qt.alpha(Theme.onSurfaceVariantColor, 0.6)
        dangerColor: Theme.error
        separatorColor: Qt.alpha(Theme.primary, 0.15)
        borderWidth: 1
        borderColor: Qt.alpha(Theme.primary, 0.15)

        model: [
            {
                action: "refresh",
                label: "Refresh",
                icon: "\uefa7"
            },
            {
                action: "mode",
                label: Theme.isDark ? "Light" : "Dark",
                icon: Theme.isDark ? "\udb81\udd94" : "\uf522"
            },
            {
                action: "monkey",
                label: "Monkey",
                icon: "\uf11c"
            },
            "-",
            {
                action: "shutdown",
                label: "Shutdown",
                icon: "\uf011",
                danger: true
            }
        ]

        onTriggered: (index, item) => {
            switch (item.action) {
            case "refresh":
                root.refresh();
                break;
            case "mode":
                Theme.toggleMode();
                break;
            case "monkey":
                root.openMonkey();
                break;
            case "shutdown":
                Quickshell.execDetached(["systemctl", "poweroff"]);
                break;
            }
        }
    }
}
