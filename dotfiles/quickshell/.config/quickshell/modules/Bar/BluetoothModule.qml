import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Bluetooth

BaseModule {
    id: root

    property var adapter: Bluetooth.defaultAdapter
    property var devices: Bluetooth.devices.values
    property var connectedDevices: devices.filter(function (device) {
        return device.connected;
    })
    property var pairedDevices: devices.filter(function (device) {
        return (device.paired || device.bonded) && !device.connected;
    })
    property bool available: adapter != null
    property bool enabled: available && adapter.enabled
    property bool showPopup: false
    property real globalX: 0
    property var barWindow: null
    property bool inOverflow: false
    property var overflowAnchorModule: null
    property QtObject popupsConfig: parent.popupsConfig
    property string icon: !available ? "󰂲" : !enabled ? "󰂲" : connectedDevices.length > 0 ? "󰂱" : "󰂯"

    hoverEnabled: true
    hoverHighlight: true
    text: icon
    textColor: !available || !enabled ? colors.comment : connectedDevices.length > 0 ? colors.blue : colors.fg

    function updatePosition() {
        var pos = root.mapToItem(null, 0, 0);
        root.globalX = pos.x;
    }

    function displayName(device) {
        if (!device)
            return "Unknown device";
        if (device.name)
            return device.name;
        if (device.deviceName)
            return device.deviceName;
        return device.address;
    }

    function statusText(device) {
        if (device.connected)
            return device.batteryAvailable ? "Connected " + Math.round(device.battery * 100) + "%" : "Connected";
        if (device.pairing)
            return "Pairing";
        if (device.paired || device.bonded)
            return "Paired";
        return "Known";
    }

    function adapterText() {
        if (!available)
            return "No adapter";
        return (adapter.name || adapter.adapterId || "Bluetooth") + (enabled ? " on" : " off");
    }

    function popupX(popupWidth) {
        if (!root.barWindow)
            return 0;
        var anchor = root.inOverflow && root.overflowAnchorModule ? root.overflowAnchorModule : root;
        return Math.max(8, Math.min(anchor.globalX + (anchor.width - popupWidth) / 2, root.barWindow.width - popupWidth - 8));
    }

    function closePopup() {
        root.showPopup = false;
    }

    BluetoothPopup {
        module: root
        barWindow: root.barWindow
        colors: root.colors
        fontsConfig: root.fontsConfig
        popupsConfig: root.popupsConfig
    }

    onXChanged: updatePosition()
    onWidthChanged: updatePosition()
    Component.onCompleted: updatePosition()

    onClicked: {
        updatePosition();
        showPopup = !showPopup;
    }
}
