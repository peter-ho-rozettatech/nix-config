import QtQuick
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import "../../Common"

OverlayPanel {
    id: trayPopup

    property var module
    property var barWindow
    property QtObject colors
    property QtObject fontsConfig
    property QtObject popupsConfig
    property var hiddenIds: []
    property var idMap: ({})
    property var overflowNames: ({})
        screen: barWindow ? barWindow.screen : null
        open: module && module.expanded
        onCloseRequested: if (module) module.expanded = false

        Rectangle {
            id: trayCard
            width: trayPopupCol.width + (popupsConfig ? popupsConfig.padding : 0)
            height: trayPopupCol.height + (popupsConfig ? popupsConfig.margin : 0)
            x: module ? module.popupX(width) : 0
            y: (barWindow ? barWindow.height : 0) + 4
            color: colors.bg
            border.color: colors.border
            radius: popupsConfig.cornerRadius
            opacity: trayPopup.open ? 1.0 : 0.0
            scale: trayPopup.open ? 1.0 : 0.98
            transformOrigin: Item.Top

            Behavior on opacity {
                NumberAnimation { duration: 180 }
            }
            Behavior on scale {
                NumberAnimation { duration: 180 }
            }

            Column {
                id: trayPopupCol
                anchors.centerIn: parent
                spacing: popupsConfig.itemSpacing

                Row {
                    id: trayRow
                    spacing: popupsConfig.itemSpacing

                    Repeater {
                        model: SystemTray.items
                        delegate: Item {
                            readonly property int _iconSize: popupsConfig.trayIconSize > 0 ? popupsConfig.trayIconSize : fontsConfig.defaultSize + popupsConfig.trayIconOffset
                            readonly property int _pad: 8
                            width: _iconSize + _pad * 2
                            height: _iconSize + _pad * 2

                            Rectangle {
                                anchors.fill: parent
                                radius: 4
                                color: mouse.containsMouse ? colors.bg_highlight : "transparent"
                            }

                            IconImage {
                                id: icon
                                anchors.centerIn: parent
                                implicitSize: parent._iconSize
                                source: modelData.icon
                            }

                            MouseArea {
                                id: mouse
                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                onClicked: function (mse) {
                                    const ix = mse.x - (width - icon.width) / 2;
                                    const iy = mse.y - (height - icon.height) / 2;
                                    if (mse.button === Qt.RightButton) {
                                        modelData.secondaryActivate(ix, iy);
                                    } else {
                                        modelData.activate(ix, iy);
                                    }
                                }
                            }
                        }
                    }
                }

                // Overflow: right-side bar modules hidden to make room for
                // the centered clock, reachable here via their normal click
                // action. Nothing hidden → the row is not rendered.
                Row {
                    spacing: popupsConfig.itemSpacing
                    visible: hiddenIds.length > 0

                    Repeater {
                        model: hiddenIds
                        delegate: Item {
                            readonly property var _mod: idMap[modelData]
                            width: ovContent.width + 16
                            height: fontsConfig.defaultSize + 12

                            Rectangle {
                                anchors.fill: parent
                                radius: 4
                                color: ovMouse.containsMouse ? colors.bg_highlight : "transparent"
                            }

                            Row {
                                id: ovContent
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 8
                                spacing: 6

                                Text {
                                    text: _mod ? _mod.text : ""
                                    color: colors.fg
                                    font.family: fontsConfig.defaultFamily
                                    font.pixelSize: fontsConfig.defaultSize
                                }

                                Text {
                                    text: overflowNames[modelData] || modelData
                                    color: colors.fg
                                    font.family: fontsConfig.defaultFamily
                                    font.pixelSize: fontsConfig.defaultSize
                                }
                            }

                            MouseArea {
                                id: ovMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: if (_mod) _mod.clicked()
                            }
                        }
                    }
                }
            }
        }
    }
