import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import ".."
import "." as Local

BaseModule {
    id: root

    hoverHighlight: true
    property bool expanded: false
    readonly property real globalX: popupAnchor.globalX
    property var barWindow: null
    property QtObject popupsConfig: parent.popupsConfig
    property var hiddenIds: []
    property var idMap: ({})
    property var overflowNames: ({})

    text: expanded ? "󰅃" : "󰅀"

    function popupX(popupWidth) {
        return popupAnchor.popupX(popupWidth);
    }

    function closePopup() {
        root.expanded = false;
    }

    Local.Popup {
        module: root
        barWindow: root.barWindow
        colors: root.colors
        fontsConfig: root.fontsConfig
        popupsConfig: root.popupsConfig
        hiddenIds: root.hiddenIds
        idMap: root.idMap
        overflowNames: root.overflowNames
    }

    PopupAnchor {
        id: popupAnchor
        module: root
        barWindow: root.barWindow
    }

    onXChanged: popupAnchor.updatePosition()
    onWidthChanged: popupAnchor.updatePosition()
    onBarWindowChanged: popupAnchor.updatePosition()
    Component.onCompleted: popupAnchor.updatePosition()

    onClicked: {
        popupAnchor.updatePosition();
        expanded = !expanded;
    }
}
