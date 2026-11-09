import QtQuick
import Ryu.Pam

QtObject {
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
        pamCtx.start();
    }

    property PamContext pam: PamContext {
        id: pamCtx
        configDirectory: Qt.resolvedUrl("pam").toString().replace("file://", "")
        config: "password.conf"

        onPamMessage: {
            if (pamCtx.responseRequired) {
                pamCtx.respond(root.currentText);
            }
        }

        onError: err => {
            root.unlockInProgress = false;
            root.showFailure = true;
            root.currentText = "";
        }

        onCompleted: result => {
            root.unlockInProgress = false;
            if (result === PamResult.Success) {
                root.showFailure = false;
                root.unlocked();
            } else {
                root.currentText = "";
                root.showFailure = true;
            }
        }
    }
}
