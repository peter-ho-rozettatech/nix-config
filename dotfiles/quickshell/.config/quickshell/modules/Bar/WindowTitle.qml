import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

BaseModule {
    id: root

    property string title: ""

    text: title
    visible: title.length > 0 && width > (moduleConfig ? moduleConfig.widthPadding : 0)
    clip: true
    horizontalAlignment: Text.AlignLeft
    elide: Text.ElideRight
}
