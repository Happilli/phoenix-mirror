pragma Singleton

import QtQuick
import Ryu.Io
import px.services.paths

QtObject {
    id: root

    property var data: ({})

    function get(key, fallback) {
        return data[key] ?? fallback;
    }

    function set(key, value) {
        if (data[key] === value) {
            return;
        }
        const next = Object.assign({}, data);
        next[key] = value;
        data = next;
        file.setText(JSON.stringify(data, null, 2));
    }

    property FileView file: FileView {
        path: PathService.home + "/.local/state/ryu/state.json"
        blockLoading: true
        atomicWrites: true

        onLoaded: {
            try {
                root.data = JSON.parse(text());
            } catch (e) {
                console.log("parsing failure: ", e);
            }
        }

        onLoadFailed: error => {
            if (error == FileViewError.FileNotFound) {
                console.log("file not found");
                root.file.setText("{}");
            } else {
                console.log("some failure");
            }
        }
    }
}
