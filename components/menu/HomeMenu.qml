import QtQuick
import Ryu.Io
import Ryu.Extraa
import px.services.paths
import px.services.theme

Item {
    id: root

    readonly property string monkeyTheme: PathService.home + "/.local/state/ryu/monkeytype.json"
    readonly property string refreshScript: Qt.resolvedUrl("../../scripts/refresh.sh").toString().replace("file://", "")

    function openMonkey() {
        Exec.detached(["sh", "-c", 'f="$1"; [ -f "$f" ] || exit 1; exec helium-browser --new-tab "https://monkeytype.com/?customTheme=$(base64 -w0 "$f")"', "sh", monkeyTheme]);
    }

    function refresh() {
        Exec.detached(["bash", refreshScript]);
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
        shortcutColor: Theme.onSurfaceVariantColor
        dangerColor: Theme.error
        separatorColor: Theme.outlineVariant
        borderWidth: 1
        borderColor: Theme.outlineVariant
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
                Exec.detached(["systemctl", "poweroff"]);
                break;
            }
        }
    }
}
