import QtQuick
import "../../Common"

OverlayHost {
    id: batteryPopup

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
            id: batteryCard
            width: 360
            height: batteryPopupCol.height + batteryPopup.popupMargin
            x: module ? module.popupX(width) : 0
            y: (barWindow ? barWindow.height : 0) + 4
            color: colors.bg
            border.color: colors.border
            radius: batteryPopup.popupCornerRadius
            opacity: batteryPopup.open ? 1.0 : 0.0
            scale: batteryPopup.open ? 1.0 : 0.98
            transformOrigin: Item.Top

            Behavior on opacity {
                NumberAnimation { duration: 180 }
            }
            Behavior on scale {
                NumberAnimation { duration: 180 }
            }

            Column {
                id: batteryPopupCol
                anchors.centerIn: parent
                width: parent.width - batteryPopup.popupPadding
                spacing: batteryPopup.popupItemSpacing

                Text {
                    text: "Battery"
                    color: colors.fg
                    font.family: fontsConfig.defaultFamily
                    font.pixelSize: fontsConfig.defaultSize
                    font.bold: true
                }

                Repeater {
                    model: module.batteries
                    delegate: Column {
                        width: batteryPopupCol.width
                        spacing: batteryPopup.popupItemSpacing

                        Item {
                            width: 1
                            height: modelData.index === 0 ? 2 : 8
                        }

                        Text {
                            text: "Battery " + (modelData.index + 1)
                            color: colors.comment
                            font.family: fontsConfig.defaultFamily
                            font.pixelSize: fontsConfig.defaultSize - 1
                            font.bold: true
                        }

                        Row {
                            width: parent.width
                            spacing: 8

                            Text {
                                text: modelData.icon + " " + modelData.percentage + "%"
                                color: modelData.isCritical ? colors.red : (modelData.isWarning ? colors.yellow : colors.fg)
                                font.family: fontsConfig.defaultFamily
                                font.pixelSize: fontsConfig.defaultSize
                                width: 92
                            }

                            Text {
                                text: modelData.state
                                color: modelData.isPlugged ? colors.green : colors.fg
                                font.family: fontsConfig.defaultFamily
                                font.pixelSize: fontsConfig.defaultSize
                                width: parent.width - 100
                                elide: Text.ElideRight
                            }
                        }

                        Text {
                            text: modelData.isCritical ? "Critical" : (modelData.isWarning ? "Warning" : "")
                            visible: text !== ""
                            color: modelData.isCritical ? colors.red : colors.yellow
                            font.family: fontsConfig.defaultFamily
                            font.pixelSize: fontsConfig.defaultSize - 1
                        }

                        Repeater {
                            model: module.detailRows(modelData)
                            delegate: Row {
                                width: batteryPopupCol.width
                                spacing: 8

                                Text {
                                    text: modelData.label
                                    color: colors.comment
                                    font.family: fontsConfig.defaultFamily
                                    font.pixelSize: fontsConfig.defaultSize - 1
                                    width: 112
                                    elide: Text.ElideRight
                                }

                                Text {
                                    text: modelData.value
                                    color: colors.fg
                                    font.family: fontsConfig.defaultFamily
                                    font.pixelSize: fontsConfig.defaultSize - 1
                                    width: parent.width - 120
                                    horizontalAlignment: Text.AlignRight
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }
                }
            }
        }
    }
