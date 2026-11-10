pragma Singleton
import QtQuick
import Ryu.Wayland
import px.services.state

QtObject {
    id: root

    readonly property var keys: ["temperature", "gamma"]
    readonly property real minTemp: 2000
    readonly property real maxTemp: 6500
    readonly property real minGamma: 0.2

    property bool active: StateService.get("nightActive", false)
    property real temperature: StateService.get("nightTemp", 4000)
    property real gamma: StateService.get("nightGamma", 1)

    property Timer saver: Timer {
        interval: 400
        onTriggered: {
            StateService.set("nightActive", root.active);
            StateService.set("nightTemp", root.temperature);
            StateService.set("nightGamma", root.gamma);
        }
    }

    function valueOf(key) {
        if (key === "temperature")
            return (temperature - minTemp) / (maxTemp - minTemp);
        if (key === "gamma")
            return (gamma - minGamma) / (1 - minGamma);
        return 0;
    }

    function setValue(key, v) {
        const c = Math.max(0, Math.min(1, v));
        if (key === "temperature")
            temperature = minTemp + c * (maxTemp - minTemp);
        else if (key === "gamma")
            gamma = minGamma + c * (1 - minGamma);
        else
            return;
        active = true;
        persist();
    }

    function toggle() {
        active = !active;
        persist();
    }

    function persist() {
        root.saver.restart();
    }

    function apply() {
        NightLight.temperature = root.temperature;
        NightLight.gamma = root.gamma;
        NightLight.active = root.active;
    }

    onActiveChanged: root.apply()
    onTemperatureChanged: root.apply()
    onGammaChanged: root.apply()

    Component.onCompleted: {
        if (root.active)
            root.apply();
    }
}
