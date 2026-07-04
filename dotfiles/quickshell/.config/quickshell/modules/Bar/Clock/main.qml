import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import ".."
import "." as Local

BaseModule {
    id: root
    hoverHighlight: true
    property QtObject intervalsConfig: parent.intervalsConfig
    property QtObject popupsConfig: parent.popupsConfig
    property var barWindow: null

    // Calendar popup state
    property bool showPopup: false
    readonly property real globalX: popupAnchor.globalX

    // Month currently in view (0-indexed month)
    property int viewYear: new Date().getFullYear()
    property int viewMonth: new Date().getMonth()
    property bool weekStartsOnMonday: true

    readonly property var _today: new Date()
    readonly property int _todayYear: _today.getFullYear()
    readonly property int _todayMonth: _today.getMonth()
    readonly property int _todayDay: _today.getDate()

    readonly property var _monthNames: ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]

    readonly property string monthLabel: _monthNames[viewMonth] + " " + viewYear

    readonly property var weekdayLabels: weekStartsOnMonday ? ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"] : ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]

    readonly property var cellModel: {
        var cells = [];
        var firstOfMonth = new Date(viewYear, viewMonth, 1);
        var startWeekday = firstOfMonth.getDay(); // 0 = Sunday
        var lead = weekStartsOnMonday ? (startWeekday + 6) % 7 : startWeekday;
        var daysInMonth = new Date(viewYear, viewMonth + 1, 0).getDate();
        var daysInPrevMonth = new Date(viewYear, viewMonth, 0).getDate();

        for (var i = 0; i < 42; i++) {
            var dayNum;
            var inMonth = true;
            if (i < lead) {
                dayNum = daysInPrevMonth - lead + 1 + i;
                inMonth = false;
            } else if (i >= lead + daysInMonth) {
                dayNum = i - lead - daysInMonth + 1;
                inMonth = false;
            } else {
                dayNum = i - lead + 1;
            }
            var isToday = inMonth && viewYear === _todayYear && viewMonth === _todayMonth && dayNum === _todayDay;
            cells.push({
                "day": dayNum,
                "inMonth": inMonth,
                "isToday": isToday
            });
        }
        return cells;
    }

    Timer {
        id: clockTimer
        interval: intervalsConfig.clock
        repeat: true
        running: true
        onTriggered: updateTime()
    }

    Component.onCompleted: updateTime()

    function updateTime() {
        var now = new Date();
        var year = now.getFullYear();
        var month = String(now.getMonth() + 1).padStart(2, '0');
        var day = String(now.getDate()).padStart(2, '0');
        var hours = String(now.getHours()).padStart(2, '0');
        var minutes = String(now.getMinutes()).padStart(2, '0');

        text = year + "-" + month + "-" + day + " " + hours + ":" + minutes;
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
    }

    PopupAnchor {
        id: popupAnchor
        module: root
        barWindow: root.barWindow
    }

    function goPrevMonth() {
        if (root.viewMonth === 0) {
            root.viewMonth = 11;
            root.viewYear -= 1;
        } else {
            root.viewMonth -= 1;
        }
    }

    function goNextMonth() {
        if (root.viewMonth === 11) {
            root.viewMonth = 0;
            root.viewYear += 1;
        } else {
            root.viewMonth += 1;
        }
    }

    function goToday() {
        root.viewYear = root._todayYear;
        root.viewMonth = root._todayMonth;
    }

    onClicked: {
        popupAnchor.updatePosition();
        showPopup = !showPopup;
    }

    onXChanged: popupAnchor.updatePosition()
    onWidthChanged: popupAnchor.updatePosition()
}
