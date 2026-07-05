import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import ".."
import "." as Local

BaseModule {
    id: root

    hoverHighlight: true
    property bool active: false
    property int remainingSeconds: 0
    property bool showPicker: false
    readonly property real globalX: popupAnchor.globalX
    property var barWindow: null
    property bool inOverflow: false
    property var overflowAnchorModule: null
    property QtObject popupsConfig: parent.popupsConfig
    property QtObject overlayConfig: parent.overlayConfig

    text: {
        if (!active)
            return "󰾪";
        if (remainingSeconds > 0) {
            var m = Math.floor(remainingSeconds / 60);
            var h = Math.floor(m / 60);
            if (h > 0)
                return "󰅶 " + h + "h" + (m % 60 > 0 ? (m % 60) + "m" : "");
            return "󰅶 " + m + "m";
        }
        return "󰅶";
    }

    Process {
        id: inhibitProcess
        running: root.active
        command: ["systemd-inhibit", "--what=idle", "--who=caffeine", "--why=manual inhibit", "--mode=block", "sleep", "infinity"]
    }

    Timer {
        id: countdownTimer
        interval: 1000
        repeat: true
        running: root.active && root.remainingSeconds > 0
        onTriggered: {
            root.remainingSeconds--;
            if (root.remainingSeconds <= 0)
                root.active = false;
        }
    }

    function activateWithDuration(minutes) {
        root.remainingSeconds = minutes * 60;
        root.active = true;
        root.showPicker = false;
    }

    function popupAnchorX(popupWidth) {
        return popupAnchor.anchorX(popupWidth);
    }

    function closePopup() {
        root.showPicker = false;
    }

    Local.Popup {
        module: root
        barWindow: root.barWindow
        colors: root.colors
        fontsConfig: root.fontsConfig
        popupsConfig: root.popupsConfig
        overlayConfig: root.overlayConfig
    }

    PopupAnchor {
        id: popupAnchor
        module: root
        barWindow: root.barWindow
        inOverflow: root.inOverflow
        overflowAnchorModule: root.overflowAnchorModule
    }

    onXChanged: popupAnchor.updatePosition()
    onWidthChanged: popupAnchor.updatePosition()
    Component.onCompleted: popupAnchor.updatePosition()

    onClicked: {
        if (root.showPicker) {
            root.showPicker = false;
            return;
        }
        root.remainingSeconds = 0;
        root.active = !root.active;
    }

    onRightClicked: {
        popupAnchor.updatePosition();
        root.showPicker = !root.showPicker;
    }

    signal activateWithMinutes(int minutes)
}
