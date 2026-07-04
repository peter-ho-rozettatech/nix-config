import QtQuick
import Quickshell

PopupWindow {
    id: caffeinePicker

    property var module
    property var barWindow
    property QtObject colors
    property QtObject fontsConfig
    property QtObject popupsConfig
        visible: module && module.showPicker
        grabFocus: true
        anchor.window: barWindow
        anchor.edges: Edges.Bottom | Edges.Left
        anchor.rect.x: module ? module.popupAnchorX(width) : 0
        anchor.rect.y: barWindow ? barWindow.height : 0
        anchor.rect.width: 1
        anchor.rect.height: 1
        implicitWidth: pickerCol.width + popupsConfig.padding
        implicitHeight: pickerCol.height + popupsConfig.margin
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            color: colors.bg
            border.color: colors.border
            radius: popupsConfig.cornerRadius

            Column {
                id: pickerCol
                anchors.centerIn: parent
                spacing: popupsConfig.itemSpacing

                Repeater {
                    model: [
                        {
                            label: "15m",
                            value: 15
                        },
                        {
                            label: "30m",
                            value: 30
                        },
                        {
                            label: "01h",
                            value: 60
                        },
                        {
                            label: "02h",
                            value: 120
                        },
                        {
                            label: "04h",
                            value: 240
                        },
                        {
                            label: "08h",
                            value: 480
                        }
                    ]

                    delegate: Rectangle {
                        width: pickerRow.width
                        height: pickerRow.height
                        color: pickerMouse.containsMouse ? colors.bg_highlight : "transparent"
                        radius: 2

                        Text {
                            id: pickerRow
                            text: modelData.label
                            color: colors.fg
                            font.family: fontsConfig.defaultFamily
                            font.pixelSize: fontsConfig.defaultSize
                            leftPadding: 8
                            rightPadding: 8
                            topPadding: 2
                            bottomPadding: 2
                        }

                        MouseArea {
                            id: pickerMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: module.activateWithDuration(modelData.value)
                        }
                    }
                }
            }
        }

        Timer {
            id: pickerTimer
            interval: popupsConfig.timeoutMs
            running: module && module.showPicker
            onTriggered: if (module) module.showPicker = false
        }
    }
