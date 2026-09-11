import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.UPower
import ".."
import "." as Local

BaseModule {
    id: root

    // batteries re-evaluates on UPower signals; refreshTick is a missed-signal safety net.
    readonly property var batteries: buildBatteries()
    readonly property bool hasBattery: batteries.length > 0
    readonly property bool hasWarning: batteries.some(function (b) {
        return b.isWarning;
    })
    readonly property bool hasCritical: batteries.some(function (b) {
        return b.isCritical;
    })
    readonly property string batteryText: {
        if (!batteries || batteries.length === 0)
            return "󰁺 --%";
        var parts = [];
        for (var i = 0; i < batteries.length; i++)
            parts.push(batteries[i].icon + " " + batteries[i].percentage + "%");
        return parts.join(" | ");
    }

    property bool showPopup: false
    readonly property real globalX: popupAnchor.globalX
    property var barWindow: null
    property bool inOverflow: false
    property var overflowAnchorModule: null
    property QtObject thresholdsConfig: parent.thresholdsConfig
    property QtObject popupsConfig: parent.popupsConfig
    property QtObject overlayConfig: parent.overlayConfig

    hoverHighlight: true

    property int refreshTick: 0

    Timer {
        interval: 30000
        repeat: true
        running: true
        onTriggered: root.refreshTick++
    }

    Component.onCompleted: popupAnchor.updatePosition()

    function stateString(s) {
        var t = "";
        try {
            t = UPowerDeviceState.toString(s);
        } catch (e) {
            t = "";
        }
        // toString yields "Pending Charge" style labels — compare spaceless.
        var k = String(t).toLowerCase().replace(/ /g, "");
        if (k === "charging")
            return "charging";
        if (k === "discharging")
            return "discharging";
        if (k === "fullycharged")
            return "fully-charged";
        if (k === "pendingcharge")
            return "pending-charge";
        if (k === "pendingdischarge")
            return "pending-discharge";
        if (k === "empty")
            return "empty";
        return "unknown";
    }

    function formatSeconds(s) {
        if (!s || s <= 0)
            return "";
        var h = Math.floor(s / 3600);
        var m = Math.round((s % 3600) / 60);
        if (m === 60) {
            h += 1;
            m = 0;
        }
        if (h > 0)
            return h + "h " + m + "m";
        return m + " min";
    }

    function buildBatteries() {
        // Register refreshTick as a binding dependency.
        root.refreshTick;
        var devs = (UPower.devices && UPower.devices.values) ? UPower.devices.values : [];
        var out = [];
        var idx = 0;
        for (var i = 0; i < devs.length; i++) {
            var d = devs[i];
            if (!d || (d.type !== UPowerDeviceType.Battery && !d.isLaptopBattery))                continue;
            if (d.isPresent === false)
                continue;

            // Quickshell reports 0-1 fractions, not 0-100 like the upower CLI.
            var rawPct = Number(d.percentage) || 0;
            var pct = rawPct <= 1 ? Math.round(rawPct * 100) : Math.round(rawPct);
            var rawHealth = Number(d.healthPercentage) || 0;
            var health = rawHealth <= 1 && rawHealth > 0 ? rawHealth * 100 : rawHealth;
            var st = stateString(d.state);
            var isCharging = st === "charging";
            var isPlugged = st === "charging" || st === "fully-charged" || st === "pending-charge";
            var battery = {
                nativePath: d.nativePath || "",
                vendor: "",
                model: d.model || "",
                serial: "",
                percentage: pct,
                state: st,
                energy: d.energy || 0,
                energyFull: 0,
                energyFullDesign: d.energyCapacity || 0,
                energyRate: Math.abs(d.changeRate || 0),
                voltage: 0,
                capacity: d.healthSupported ? health : 0,
                chargeCycles: "",
                technology: "",
                capacityLevel: "",
                voltageMinDesign: 0,
                chargeStartThreshold: "",
                chargeEndThreshold: "",
                chargeThresholdSupported: "",
                updated: "",
                powerSupply: d.powerSupply ? "yes" : "no",
                present: "yes",
                rechargeable: "",
                timeToEmpty: formatSeconds(d.timeToEmpty),
                timeToFull: formatSeconds(d.timeToFull),
                isCharging: isCharging,
                isPlugged: isPlugged,
                icon: getBatteryIcon(pct, st),
                index: idx
            };
            battery.isWarning = pct <= thresholdsConfig.battery.warning && !isCharging;
            battery.isCritical = pct <= thresholdsConfig.battery.critical && !isCharging;
            out.push(battery);
            idx++;
        }
        return out;
    }

    function addDetailRow(rows, label, value, suffix) {
        if (value === undefined || value === null || value === "" || value === 0)
            return;
        rows.push({
            label: label,
            value: suffix ? value + suffix : String(value)
        });
    }

    function detailRows(battery) {
        var rows = [];
        addDetailRow(rows, "Native path", battery.nativePath, "");
        addDetailRow(rows, "Model", battery.model, "");
        addDetailRow(rows, "State", battery.state, "");
        addDetailRow(rows, "Energy", battery.energy ? battery.energy.toFixed(2) : 0, " Wh");
        addDetailRow(rows, "Design", battery.energyFullDesign ? battery.energyFullDesign.toFixed(2) : 0, " Wh");
        addDetailRow(rows, "Rate", battery.energyRate ? battery.energyRate.toFixed(2) : 0, " W");
        addDetailRow(rows, "Health", battery.capacity ? battery.capacity.toFixed(1) : 0, "%");
        addDetailRow(rows, "Power supply", battery.powerSupply, "");
        addDetailRow(rows, "Present", battery.present, "");
        addDetailRow(rows, "Time to empty", battery.timeToEmpty, "");
        addDetailRow(rows, "Time to full", battery.timeToFull, "");
        return rows;
    }

    function getBatteryIcon(percentage, state) {
        var icons = ["󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"];
        var iconIndex = Math.floor((percentage / 100) * 10);
        if (iconIndex < 0)
            iconIndex = 0;
        if (iconIndex > icons.length - 1)
            iconIndex = icons.length - 1;

        var icon = icons[iconIndex];

        if (state === "charging") {
            icon = "󰂄";
        } else if (state === "fully-charged" || state === "pending-charge") {
            icon = "󰚥";
        }

        return icon;
    }

    function popupX(popupWidth) {
        return popupAnchor.popupX(popupWidth);
    }

    function closePopup() {
        root.showPopup = false;
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

    onClicked: {
        popupAnchor.updatePosition();
        showPopup = !showPopup;
    }

    onXChanged: popupAnchor.updatePosition()
    onWidthChanged: popupAnchor.updatePosition()

    visible: hasBattery

    text: batteryText

    textColor: hasCritical ? colors.base08 : (hasWarning ? colors.base0A : colors.base05)
}
