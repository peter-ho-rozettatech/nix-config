import QtQuick

Item {
    id: root

    property var module: parent
    property var barWindow: null
    property bool inOverflow: false
    property var overflowAnchorModule: null
    property real globalX: 0

    readonly property var anchorModule: inOverflow && overflowAnchorModule ? overflowAnchorModule : module

    function updatePosition() {
        if (!module)
            return;
        var pos = module.mapToItem(null, 0, 0);
        root.globalX = pos.x;
    }

    function anchorX(popupWidth) {
        var anchor = root.anchorModule;
        if (!anchor)
            return 0;
        return anchor.globalX + (anchor.width - popupWidth) / 2;
    }

    function popupX(popupWidth) {
        if (!root.barWindow)
            return 0;
        return Math.max(8, Math.min(root.anchorX(popupWidth), root.barWindow.width - popupWidth - 8));
    }
}
