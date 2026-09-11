import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQml
import Quickshell
import Quickshell.Networking

BaseModule {
    id: root

    hoverHighlight: true
    property string connectionType: "disconnected"
    property string essid: ""
    property real signalStrength: 0
    property string icon: "󰌙"

    // Signal-driven refresh with a 5s backstop poll; reads are spawn-free property lookups.
    Timer {
        interval: 5000
        repeat: true
        running: true
        onTriggered: updateNetwork()
    }

    Timer {
        id: refreshDebounce
        interval: 500
        repeat: false
        onTriggered: updateNetwork()
    }

    function requestRefresh() {
        refreshDebounce.restart();
    }

    Connections {
        target: Networking
        function onConnectivityChanged() {
            root.requestRefresh();
        }
        function onWifiEnabledChanged() {
            root.requestRefresh();
        }
    }

    Connections {
        target: Networking.devices
        function onValuesChanged() {
            root.requestRefresh();
        }
        function onObjectInsertedPost() {
            root.requestRefresh();
        }
        function onObjectRemovedPost() {
            root.requestRefresh();
        }
    }

    // Subtype-only signals need ignoreUnknownSignals.
    Instantiator {
        model: Networking.devices
        delegate: Item {
            Connections {
                target: modelData
                ignoreUnknownSignals: true
                function onConnectedChanged() {
                    root.requestRefresh();
                }
                function onStateChanged() {
                    root.requestRefresh();
                }
                function onAddressChanged() {
                    root.requestRefresh();
                }
                function onHasLinkChanged() {
                    root.requestRefresh();
                }
            }
            Instantiator {
                model: modelData.networks
                delegate: Connections {
                    target: modelData
                    ignoreUnknownSignals: true
                    function onConnectedChanged() {
                        root.requestRefresh();
                    }
                    function onStateChanged() {
                        root.requestRefresh();
                    }
                    function onSignalStrengthChanged() {
                        root.requestRefresh();
                    }
                }
            }
        }
    }

    Component.onCompleted: updateNetwork()

    function updateNetwork() {
        var devs = (Networking.devices && Networking.devices.values) ? Networking.devices.values : [];
        var foundWifi = null;
        var foundWired = false;

        for (var i = 0; i < devs.length; i++) {
            var d = devs[i];
            var nets = (d.networks && d.networks.values) ? d.networks.values : [];
            for (var j = 0; j < nets.length; j++) {
                if (nets[j].connected) {
                    if (nets[j].signalStrength !== undefined) {
                        foundWifi = nets[j];
                    } else {
                        foundWired = true;
                    }
                }
            }
            if (!foundWifi && !foundWired && d.hasLink) {
                foundWired = true;
            }
        }

        if (foundWifi) {
            connectionType = "wifi";
            essid = foundWifi.name || "";
            // signalStrength is a 0-1 fraction.
            var s = Number(foundWifi.signalStrength) || 0;
            signalStrength = s <= 1 ? s * 100 : s;
        } else if (foundWired) {
            connectionType = "ethernet";
            essid = "";
            signalStrength = 0;
        } else {
            connectionType = "disconnected";
            essid = "";
            signalStrength = 0;
        }
        updateIcon();
    }

    function updateIcon() {
        if (connectionType === "disconnected") {
            icon = "󰌙";
        } else if (connectionType === "ethernet") {
            icon = "󰈀";
        } else if (connectionType === "wifi") {
            var signalIndex = Math.floor((signalStrength / 100) * 4);
            if (signalIndex < 0)
                signalIndex = 0;
            if (signalIndex > 4)
                signalIndex = 4;

            var wifiIcons = ["󰤯", "󰤟", "󰤢", "󰤥", "󰤨"];
            icon = wifiIcons[signalIndex];
        } else {
            icon = "󰌷";
        }
    }

    text: icon

    onClicked: {
        updateNetwork();
        Quickshell.execDetached({
            command: ["nm-connection-editor"]
        });
    }
}
