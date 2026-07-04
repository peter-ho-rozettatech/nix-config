import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell

BaseModule {
    id: root

    hoverHighlight: true
    property bool expanded: false
    property real globalX: 0
    property var barWindow: null
    property QtObject popupsConfig: parent.popupsConfig
    property var hiddenIds: []
    property var idMap: ({})
    property var overflowNames: ({})

    text: expanded ? "󰅃" : "󰅀"

    function updatePosition() {
        var pos = root.mapToItem(null, 0, 0);
        root.globalX = pos.x;
    }

    function popupX(popupWidth) {
        if (!root.barWindow)
            return 0;
        return Math.max(8, Math.min(root.globalX + (root.width - popupWidth) / 2, root.barWindow.width - popupWidth - 8));
    }

    function closePopup() {
        root.expanded = false;
    }

    TrayPopup {
        module: root
        barWindow: root.barWindow
        colors: root.colors
        fontsConfig: root.fontsConfig
        popupsConfig: root.popupsConfig
        hiddenIds: root.hiddenIds
        idMap: root.idMap
        overflowNames: root.overflowNames
    }

    onXChanged: updatePosition()
    onWidthChanged: updatePosition()
    onBarWindowChanged: updatePosition()
    Component.onCompleted: updatePosition()

    onClicked: {
        updatePosition();
        expanded = !expanded;
    }
}
