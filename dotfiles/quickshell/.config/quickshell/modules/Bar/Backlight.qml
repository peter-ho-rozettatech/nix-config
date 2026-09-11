import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell

BaseModule {
    id: root

    hoverHighlight: true
    readonly property real brightness: brightnessControl ? brightnessControl.brightness : 0
    property string icon: "󰃞"
    property QtObject intervalsConfig: parent.intervalsConfig
    property QtObject thresholdsConfig: parent.thresholdsConfig
    property var brightnessControl

    Component.onCompleted: updateIcon()
    onBrightnessChanged: updateIcon()

    function updateIcon() {
        if (!thresholdsConfig || !thresholdsConfig.brightness)
            return;

        var lowThreshold = thresholdsConfig.brightness.low;
        var mediumThreshold = thresholdsConfig.brightness.medium;

        if (brightness < lowThreshold) {
            icon = "󰃞";
        } else if (brightness < mediumThreshold) {
            icon = "󰃟";
        } else {
            icon = "󰃠";
        }
    }

    text: icon

    onClicked: {
        Quickshell.execDetached({
            command: ["quickshell", "ipc", "call", "quickshell-osd", "brightnessShow"]
        });
    }
}
