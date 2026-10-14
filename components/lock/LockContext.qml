import QtQuick
import Quickshell
import Quickshell.Services.Pam

Scope {
    id: root

    signal unlocked

    property string currentText: ""
    property bool unlockInProgress: false
    property bool showFailure: false

    onCurrentTextChanged: {
        if (currentText.length > 0) {
            showFailure = false;
        }
    }

    function tryUnlock() {
        if (currentText === "" || unlockInProgress) {
            return;
        }
        unlockInProgress = true;
        pam.start();
    }

    PamContext {
        id: pam
        configDirectory: Qt.resolvedUrl("pam").toString().replace("file://", "")
        config: "password.conf"

        onPamMessage: {
            if (this.responseRequired) {
                this.respond(root.currentText);
            }
        }

        onError: err => {
            root.unlockInProgress = false;
            root.showFailure = true;
            root.currentText = "";
        }

        onCompleted: result => {
            root.unlockInProgress = false;
            root.currentText = "";
            if (result === PamResult.Success) {
                root.showFailure = false;
                root.unlocked();
            } else {
                root.showFailure = true;
            }
        }
    }
}
