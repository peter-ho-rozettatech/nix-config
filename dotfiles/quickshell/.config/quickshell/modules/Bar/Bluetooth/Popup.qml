import QtQuick
import Quickshell
import "../../Common"

OverlayPanel {
    id: bluetoothPopup

    property var module
    property var barWindow
    property QtObject colors
    property QtObject fontsConfig
    property QtObject popupsConfig
        screen: barWindow ? barWindow.screen : null
        open: module && module.showPopup
        onCloseRequested: if (module) module.showPopup = false

        readonly property int popupPadding: popupsConfig ? popupsConfig.padding : 16
        readonly property int popupMargin: popupsConfig ? popupsConfig.margin : 8
        readonly property int popupCornerRadius: popupsConfig ? popupsConfig.cornerRadius : 4
        readonly property int popupItemSpacing: popupsConfig ? popupsConfig.itemSpacing : 4

        Rectangle {
            id: bluetoothCard
            width: 320
            height: bluetoothPopupCol.height + bluetoothPopup.popupMargin
            x: module ? module.popupX(width) : 0
            y: (barWindow ? barWindow.height : 0) + 4
            color: colors.bg
            border.color: colors.border
            radius: bluetoothPopup.popupCornerRadius
            opacity: bluetoothPopup.open ? 1.0 : 0.0
            scale: bluetoothPopup.open ? 1.0 : 0.98
            transformOrigin: Item.Top

            Behavior on opacity {
                NumberAnimation { duration: 180 }
            }
            Behavior on scale {
                NumberAnimation { duration: 180 }
            }

            Column {
                id: bluetoothPopupCol
                anchors.centerIn: parent
                width: parent.width - bluetoothPopup.popupPadding
                spacing: bluetoothPopup.popupItemSpacing

                Text {
                    text: "Bluetooth"
                    color: colors.fg
                    font.family: fontsConfig.defaultFamily
                    font.pixelSize: fontsConfig.defaultSize
                    font.bold: true
                }

                Text {
                    text: module.adapterText()
                    color: module.enabled ? colors.green : colors.comment
                    font.family: fontsConfig.defaultFamily
                    font.pixelSize: fontsConfig.defaultSize
                    elide: Text.ElideRight
                    width: parent.width
                }

                Item {
                    width: 1
                    height: 4
                }

                Text {
                    text: "Connected"
                    color: colors.fg
                    font.family: fontsConfig.defaultFamily
                    font.pixelSize: fontsConfig.defaultSize
                    font.bold: true
                    visible: module.connectedDevices.length > 0
                }

                Repeater {
                    model: module.connectedDevices
                    delegate: Row {
                        width: bluetoothPopupCol.width
                        spacing: 8

                        Text {
                            text: module.displayName(modelData)
                            color: colors.fg
                            font.family: fontsConfig.defaultFamily
                            font.pixelSize: fontsConfig.defaultSize
                            width: parent.width - 92
                            elide: Text.ElideRight
                        }

                        Text {
                            text: module.statusText(modelData)
                            color: colors.blue
                            font.family: fontsConfig.defaultFamily
                            font.pixelSize: fontsConfig.defaultSize - 1
                            width: 84
                            horizontalAlignment: Text.AlignRight
                            elide: Text.ElideRight
                        }
                    }
                }

                Text {
                    text: "No connected devices"
                    color: colors.comment
                    font.family: fontsConfig.defaultFamily
                    font.pixelSize: fontsConfig.defaultSize
                    visible: module.connectedDevices.length === 0
                }

                Item {
                    width: 1
                    height: 4
                }

                Text {
                    text: "Paired"
                    color: colors.fg
                    font.family: fontsConfig.defaultFamily
                    font.pixelSize: fontsConfig.defaultSize
                    font.bold: true
                    visible: module.pairedDevices.length > 0
                }

                Repeater {
                    model: module.pairedDevices
                    delegate: Row {
                        width: bluetoothPopupCol.width
                        spacing: 8

                        Text {
                            text: module.displayName(modelData)
                            color: modelData.connected ? colors.fg : colors.comment
                            font.family: fontsConfig.defaultFamily
                            font.pixelSize: fontsConfig.defaultSize
                            width: parent.width - 92
                            elide: Text.ElideRight
                        }

                        Text {
                            text: module.statusText(modelData)
                            color: modelData.connected ? colors.blue : colors.comment
                            font.family: fontsConfig.defaultFamily
                            font.pixelSize: fontsConfig.defaultSize - 1
                            width: 84
                            horizontalAlignment: Text.AlignRight
                            elide: Text.ElideRight
                        }
                    }
                }

                Text {
                    text: module.available ? "No paired devices" : "Bluetooth adapter unavailable"
                    color: colors.comment
                    font.family: fontsConfig.defaultFamily
                    font.pixelSize: fontsConfig.defaultSize
                    visible: module.pairedDevices.length === 0
                }

                Item {
                    width: 1
                    height: 6
                }

                Rectangle {
                    width: parent.width
                    height: openBluemanText.height + 8
                    color: openBluemanMouse.containsMouse ? colors.bg_highlight : "transparent"
                    radius: 4

                    Text {
                        id: openBluemanText
                        anchors.centerIn: parent
                        text: "Open Blueman"
                        color: colors.fg
                        font.family: fontsConfig.defaultFamily
                        font.pixelSize: fontsConfig.defaultSize
                    }

                    MouseArea {
                        id: openBluemanMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            module.showPopup = false;
                            Quickshell.execDetached({
                                command: ["blueman-manager"]
                            });
                        }
                    }
                }
            }
        }
    }
